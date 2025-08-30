import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

class ImageUploadUtils {
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5 MB

  /// Upload trip image to Firebase Storage
  static Future<String?> uploadTripImage({
    required String agencyId,
    required String tripId,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      if (kDebugMode) {
        print('Starting single image upload - agencyId: $agencyId, tripId: $tripId, source: $source');
      }
      
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (kDebugMode) {
        print('Image picker result: ${picked?.name ?? 'null'}');
      }
      
      if (picked == null) return null;

      final fileBytes = await picked.readAsBytes();
      
      // Check file size
      if (fileBytes.length > maxFileSizeBytes) {
        throw Exception('File size exceeds 5 MB limit. Please choose a smaller image.');
      }

      final ext = picked.name?.split('.').last.toLowerCase() ?? 'jpg';
      final contentType = _getContentType(ext);

      // Validate image format
      if (!_isValidImageFormat(ext)) {
        throw Exception('Invalid image format. Please use JPG, PNG, or WebP.');
      }

      // Upload to Firebase Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${tripId}_${timestamp}.$ext';
      final ref = FirebaseStorage.instance.ref('trips/$agencyId/images/$fileName');
      
      if (kDebugMode) {
        print('Uploading to Firebase Storage: trips/$agencyId/images/$fileName');
      }
      
      await ref.putData(fileBytes, SettableMetadata(contentType: contentType)).timeout(
        const Duration(minutes: 2),
        onTimeout: () => throw Exception('Upload timed out after 2 minutes'),
      );
      
      if (kDebugMode) {
        print('Upload completed, getting download URL...');
      }
      
      final url = await ref.getDownloadURL().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Failed to get download URL after 30 seconds'),
      );

      return url;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading trip image: $e');
      }
      rethrow;
    }
  }

  /// Upload profile image to Firebase Storage
  static Future<String?> uploadProfileImage({
    required String userId,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 90,
      );
      
      if (picked == null) return null;

      final fileBytes = await picked.readAsBytes();
      
      // Check file size
      if (fileBytes.length > maxFileSizeBytes) {
        throw Exception('File size exceeds 5 MB limit. Please choose a smaller image.');
      }

      final ext = picked.name?.split('.').last.toLowerCase() ?? 'jpg';
      final contentType = _getContentType(ext);

      // Validate image format
      if (!_isValidImageFormat(ext)) {
        throw Exception('Invalid image format. Please use JPG, PNG, or WebP.');
      }

      // Upload to Firebase Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'profile_${timestamp}.$ext';
      final ref = FirebaseStorage.instance.ref('users/$userId/profile/$fileName');
      
      await ref.putData(fileBytes, SettableMetadata(contentType: contentType));
      final url = await ref.getDownloadURL();

      return url;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading profile image: $e');
      }
      rethrow;
    }
  }

  /// Pick multiple images for gallery
  static Future<List<String>> uploadMultipleImages({
    required String agencyId,
    required String tripId,
    int maxImages = 5,
  }) async {
    try {
      if (kDebugMode) {
        print('Starting multiple image upload - agencyId: $agencyId, tripId: $tripId, maxImages: $maxImages');
      }
      
      final picker = ImagePicker();
      final picked = await picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (kDebugMode) {
        print('Image picker returned ${picked.length} images');
      }
      
      if (picked.isEmpty) return [];

      if (picked.length > maxImages) {
        throw Exception('Maximum $maxImages images allowed. Please select fewer images.');
      }

      // Validate all files first before uploading
      for (int i = 0; i < picked.length; i++) {
        final file = picked[i];
        final fileBytes = await file.readAsBytes();
        
        // Check file size
        if (fileBytes.length > maxFileSizeBytes) {
          throw Exception('Image ${i + 1} exceeds 5 MB limit. Please choose smaller images.');
        }

        final ext = file.name?.split('.').last.toLowerCase() ?? 'jpg';

        // Validate image format
        if (!_isValidImageFormat(ext)) {
          throw Exception('Image ${i + 1} has invalid format. Please use JPG, PNG, or WebP.');
        }
      }

      // Upload all images in parallel for better performance
      final uploadTasks = picked.asMap().entries.map((entry) async {
        final index = entry.key;
        final file = entry.value;
        
        final fileBytes = await file.readAsBytes();
        final ext = file.name?.split('.').last.toLowerCase() ?? 'jpg';
        final contentType = _getContentType(ext);
        
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = '${tripId}_gallery_${index}_${timestamp}.$ext';
        final ref = FirebaseStorage.instance.ref('trips/$agencyId/gallery/$fileName');
        
        if (kDebugMode) {
          print('Uploading image ${index + 1} to Firebase Storage: trips/$agencyId/gallery/$fileName');
        }
        
        await ref.putData(fileBytes, SettableMetadata(contentType: contentType)).timeout(
          const Duration(minutes: 2),
          onTimeout: () => throw Exception('Upload of image ${index + 1} timed out after 2 minutes'),
        );
        
        return await ref.getDownloadURL().timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception('Failed to get download URL for image ${index + 1} after 30 seconds'),
        );
      });

      // Wait for all uploads to complete
      if (kDebugMode) {
        print('Starting parallel upload of ${uploadTasks.length} images');
      }
      
      final uploadedUrls = await Future.wait(uploadTasks);
      
      if (kDebugMode) {
        print('Upload completed successfully. URLs: $uploadedUrls');
      }
      
      return uploadedUrls;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading multiple images: $e');
      }
      rethrow;
    }
  }

  /// Get content type based on file extension
  static String _getContentType(String ext) {
    switch (ext.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  /// Validate if the image format is supported
  static bool _isValidImageFormat(String ext) {
    final supportedFormats = ['jpg', 'jpeg', 'png', 'webp'];
    return supportedFormats.contains(ext.toLowerCase());
  }

  /// Delete image from Firebase Storage
  static Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting image: $e');
      }
      // Don't rethrow for delete operations, as the image might already be deleted
    }
  }
}