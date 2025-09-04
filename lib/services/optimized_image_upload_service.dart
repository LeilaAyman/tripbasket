import 'dart:io';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:image_picker/image_picker.dart';

/// Service for handling optimized image uploads in TripBasket
/// - Handles both mobile (File) and web (Uint8List) uploads
/// - Automatically triggers cloud function optimization
/// - Provides optimization status tracking
/// - Manages optimized vs original image URLs
class OptimizedImageUploadService {
  static final OptimizedImageUploadService _instance = OptimizedImageUploadService._internal();
  factory OptimizedImageUploadService() => _instance;
  OptimizedImageUploadService._internal();
  
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  
  /// Upload an image with automatic optimization
  /// Returns the original URL immediately, optimization happens in background
  Future<ImageUploadResult> uploadWithOptimization({
    required String path,
    required dynamic imageData, // File for mobile, Uint8List for web
    required String filename,
    Map<String, String>? metadata,
    Function(double)? onProgress,
    bool waitForOptimization = false,
  }) async {
    try {
      print('🚀 Starting optimized upload: $filename to $path');
      
      // Upload original image first
      final uploadTask = _createUploadTask(path, imageData, filename, metadata);
      
      // Track progress if callback provided
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }
      
      // Wait for upload to complete
      final snapshot = await uploadTask;
      final originalUrl = await snapshot.ref.getDownloadURL();
      
      print('✅ Original upload completed: $originalUrl');
      
      final result = ImageUploadResult(
        originalUrl: originalUrl,
        originalPath: path,
        filename: filename,
        uploadedAt: DateTime.now(),
      );
      
      if (waitForOptimization) {
        print('⏳ Waiting for optimization to complete...');
        
        // Wait a moment for the cloud function to trigger
        await Future.delayed(Duration(seconds: 2));
        
        // Check for optimized version
        final optimizedResult = await _checkForOptimizedVersion(path, maxWaitTime: Duration(minutes: 2));
        if (optimizedResult != null) {
          result.optimizedUrl = optimizedResult.optimizedUrl;
          result.optimizedPath = optimizedResult.optimizedPath;
          result.optimizationCompleted = true;
          result.optimizationStats = optimizedResult.stats;
        }
      } else {
        // Start background optimization check
        _checkOptimizationInBackground(result);
      }
      
      return result;
      
    } catch (e) {
      print('❌ Error in optimized upload: $e');
      throw ImageUploadException('Failed to upload image: $e');
    }
  }
  
  /// Create upload task based on platform and data type
  UploadTask _createUploadTask(String path, dynamic imageData, String filename, Map<String, String>? metadata) {
    final ref = _storage.ref().child(path);
    
    UploadMetadata uploadMetadata = UploadMetadata(
      contentType: _getContentType(filename),
      customMetadata: {
        'originalFilename': filename,
        'uploadedBy': 'tripbasket-flutter',
        'uploadTimestamp': DateTime.now().toIso8601String(),
        ...?metadata,
      },
    );
    
    if (kIsWeb) {
      // Web: Use Uint8List
      if (imageData is Uint8List) {
        return ref.putData(imageData, uploadMetadata);
      } else {
        throw ArgumentError('Web uploads require Uint8List data');
      }
    } else {
      // Mobile: Use File
      if (imageData is File) {
        return ref.putFile(imageData, uploadMetadata);
      } else {
        throw ArgumentError('Mobile uploads require File data');
      }
    }
  }
  
  /// Check for optimized version in background
  void _checkOptimizationInBackground(ImageUploadResult result) async {
    try {
      await Future.delayed(Duration(seconds: 5)); // Give cloud function time to start
      
      final optimizedResult = await _checkForOptimizedVersion(
        result.originalPath,
        maxWaitTime: Duration(minutes: 5),
      );
      
      if (optimizedResult != null) {
        result.optimizedUrl = optimizedResult.optimizedUrl;
        result.optimizedPath = optimizedResult.optimizedPath;
        result.optimizationCompleted = true;
        result.optimizationStats = optimizedResult.stats;
        
        print('✅ Background optimization completed for ${result.filename}');
        
        // Notify listeners if any are registered
        result._notifyOptimizationComplete();
      }
    } catch (e) {
      print('⚠️ Background optimization check failed: $e');
    }
  }
  
  /// Check if optimized version exists
  Future<OptimizedImageResult?> _checkForOptimizedVersion(String originalPath, {Duration? maxWaitTime}) async {
    final maxWait = maxWaitTime ?? Duration(minutes: 2);
    final deadline = DateTime.now().add(maxWait);
    
    // Generate expected optimized path
    final pathParts = originalPath.split('/');
    final filename = pathParts.last;
    final directory = pathParts.take(pathParts.length - 1).join('/');
    final filenameWithoutExt = filename.split('.').first;
    
    final optimizedFilename = 'optimized_$filenameWithoutExt.webp';
    final optimizedPath = directory.isEmpty ? optimizedFilename : '$directory/$optimizedFilename';
    
    while (DateTime.now().isBefore(deadline)) {
      try {
        final optimizedRef = _storage.ref().child(optimizedPath);
        final optimizedUrl = await optimizedRef.getDownloadURL();
        
        // Get optimization metadata if available
        final metadata = await optimizedRef.getMetadata();
        final customMetadata = metadata.customMetadata ?? {};
        
        final stats = OptimizationStats(
          originalSize: int.tryParse(customMetadata['originalSize'] ?? '0') ?? 0,
          optimizedSize: int.tryParse(customMetadata['optimizedSize'] ?? '0') ?? 0,
          compressionRatio: customMetadata['compressionRatio'] ?? '0%',
          originalDimensions: customMetadata['originalDimensions'] ?? '',
          optimizedDimensions: customMetadata['optimizedDimensions'] ?? '',
        );
        
        return OptimizedImageResult(
          optimizedUrl: optimizedUrl,
          optimizedPath: optimizedPath,
          stats: stats,
        );
        
      } catch (e) {
        // File doesn't exist yet, wait and retry
        await Future.delayed(Duration(seconds: 5));
      }
    }
    
    print('⏰ Timeout waiting for optimization of $originalPath');
    return null;
  }
  
  /// Get content type from filename
  String _getContentType(String filename) {
    final extension = filename.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg'; // Default fallback
    }
  }
  
  /// Manually trigger optimization for existing images (admin only)
  Future<BulkOptimizationResult> triggerBulkOptimization({
    String? bucket,
    String? path,
  }) async {
    try {
      final callable = _functions.httpsCallable('optimizeExistingImages');
      final result = await callable.call({
        if (bucket != null) 'bucket': bucket,
        if (path != null) 'path': path,
      });
      
      final data = result.data as Map<String, dynamic>;
      
      return BulkOptimizationResult(
        message: data['message'] ?? '',
        totalFiles: data['totalFiles'] ?? 0,
        processed: data['processed'] ?? 0,
        successful: data['successful'] ?? 0,
        failed: data['failed'] ?? 0,
      );
      
    } catch (e) {
      print('❌ Error triggering bulk optimization: $e');
      throw ImageUploadException('Failed to trigger bulk optimization: $e');
    }
  }
  
  /// Get optimization statistics
  Future<OptimizationStats> getOptimizationStats() async {
    try {
      final callable = _functions.httpsCallable('getOptimizationStats');
      final result = await callable.call();
      
      final data = result.data as Map<String, dynamic>;
      
      return OptimizationStats(
        originalSize: data['totalOriginalSize'] ?? 0,
        optimizedSize: data['totalOptimizedSize'] ?? 0,
        compressionRatio: '${data['savingsPercent'] ?? 0}%',
        originalDimensions: '${data['originalImages'] ?? 0} images',
        optimizedDimensions: '${data['optimizedImages'] ?? 0} optimized',
      );
      
    } catch (e) {
      print('❌ Error getting optimization stats: $e');
      throw ImageUploadException('Failed to get optimization stats: $e');
    }
  }
  
  /// Helper to pick and upload image with optimization
  Future<ImageUploadResult?> pickAndUploadImage({
    required String uploadPath,
    ImageSource source = ImageSource.gallery,
    Map<String, String>? metadata,
    Function(double)? onProgress,
    bool waitForOptimization = false,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      
      if (image == null) return null;
      
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        return await uploadWithOptimization(
          path: '$uploadPath/${image.name}',
          imageData: bytes,
          filename: image.name,
          metadata: metadata,
          onProgress: onProgress,
          waitForOptimization: waitForOptimization,
        );
      } else {
        final file = File(image.path);
        return await uploadWithOptimization(
          path: '$uploadPath/${image.name}',
          imageData: file,
          filename: image.name,
          metadata: metadata,
          onProgress: onProgress,
          waitForOptimization: waitForOptimization,
        );
      }
      
    } catch (e) {
      print('❌ Error in pick and upload: $e');
      throw ImageUploadException('Failed to pick and upload image: $e');
    }
  }
}

/// Result of an image upload with optimization
class ImageUploadResult {
  final String originalUrl;
  final String originalPath;
  final String filename;
  final DateTime uploadedAt;
  
  String? optimizedUrl;
  String? optimizedPath;
  bool optimizationCompleted = false;
  OptimizationStats? optimizationStats;
  
  final List<Function()> _optimizationListeners = [];
  
  ImageUploadResult({
    required this.originalUrl,
    required this.originalPath,
    required this.filename,
    required this.uploadedAt,
    this.optimizedUrl,
    this.optimizedPath,
    this.optimizationCompleted = false,
    this.optimizationStats,
  });
  
  /// Get the best available URL (optimized if available, otherwise original)
  String get bestUrl => optimizedUrl ?? originalUrl;
  
  /// Get the best available path
  String get bestPath => optimizedPath ?? originalPath;
  
  /// Add listener for optimization completion
  void addOptimizationListener(Function() callback) {
    _optimizationListeners.add(callback);
  }
  
  /// Remove optimization listener
  void removeOptimizationListener(Function() callback) {
    _optimizationListeners.remove(callback);
  }
  
  /// Notify all listeners of optimization completion
  void _notifyOptimizationComplete() {
    for (final listener in _optimizationListeners) {
      try {
        listener();
      } catch (e) {
        print('Error in optimization listener: $e');
      }
    }
  }
}

/// Result of checking for optimized version
class OptimizedImageResult {
  final String optimizedUrl;
  final String optimizedPath;
  final OptimizationStats stats;
  
  OptimizedImageResult({
    required this.optimizedUrl,
    required this.optimizedPath,
    required this.stats,
  });
}

/// Statistics about image optimization
class OptimizationStats {
  final int originalSize;
  final int optimizedSize;
  final String compressionRatio;
  final String originalDimensions;
  final String optimizedDimensions;
  
  OptimizationStats({
    required this.originalSize,
    required this.optimizedSize,
    required this.compressionRatio,
    required this.originalDimensions,
    required this.optimizedDimensions,
  });
  
  int get savings => originalSize - optimizedSize;
  double get savingsPercent {
    if (originalSize == 0) return 0.0;
    return (savings / originalSize) * 100;
  }
}

/// Result of bulk optimization operation
class BulkOptimizationResult {
  final String message;
  final int totalFiles;
  final int processed;
  final int successful;
  final int failed;
  
  BulkOptimizationResult({
    required this.message,
    required this.totalFiles,
    required this.processed,
    required this.successful,
    required this.failed,
  });
}

/// Exception thrown by image upload operations
class ImageUploadException implements Exception {
  final String message;
  
  ImageUploadException(this.message);
  
  @override
  String toString() => 'ImageUploadException: $message';
}