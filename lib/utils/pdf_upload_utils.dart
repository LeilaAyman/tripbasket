import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class PdfUploadUtils {
  static const int _maxFileSizeBytes = 10 * 1024 * 1024; // 10MB

  static Future<String?> uploadTripPdf({
    required String agencyId,
    required String tripId,
    String? filePath,
    Uint8List? fileBytes,
    required String fileName,
  }) async {
    try {
      Uint8List bytes;
      int fileSize;
      
      if (kIsWeb) {
        // Web platform: use bytes
        if (fileBytes == null) {
          throw Exception('File bytes are required for web platform');
        }
        bytes = fileBytes;
        fileSize = bytes.length;
      } else {
        // Mobile platform: use file path
        if (filePath == null) {
          throw Exception('File path is required for mobile platform');
        }
        final file = File(filePath);
        
        // Check if file exists
        if (!await file.exists()) {
          throw Exception('File does not exist');
        }
        
        bytes = await file.readAsBytes();
        fileSize = bytes.length;
      }
      
      // Check file size
      if (fileSize > _maxFileSizeBytes) {
        throw Exception('File size exceeds 10MB limit');
      }
      
      // Check file extension
      if (!fileName.toLowerCase().endsWith('.pdf')) {
        throw Exception('Only PDF files are allowed');
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sanitizedFileName = fileName.replaceAll(RegExp(r'[^\w\-_.]'), '');
      final storagePath = 'agencies/$agencyId/trips/$tripId/pdfs/${timestamp}_$sanitizedFileName';
      
      if (kDebugMode) {
        print('Uploading PDF to: $storagePath');
        print('File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
        print('Platform: ${kIsWeb ? 'Web' : 'Mobile'}');
      }
      
      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      final uploadTask = storageRef.putData(
        bytes,
        SettableMetadata(
          contentType: 'application/pdf',
          customMetadata: {
            'agencyId': agencyId,
            'tripId': tripId,
            'uploadedAt': DateTime.now().toIso8601String(),
            'originalFileName': fileName,
          },
        ),
      );
      
      // Wait for upload completion
      final snapshot = await uploadTask;
      
      if (snapshot.state == TaskState.success) {
        final downloadUrl = await snapshot.ref.getDownloadURL();
        
        if (kDebugMode) {
          print('PDF upload successful! Download URL: $downloadUrl');
        }
        
        return downloadUrl;
      } else {
        throw Exception('Upload failed with state: ${snapshot.state}');
      }
      
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Firebase error during PDF upload: ${e.code} - ${e.message}');
      }
      
      switch (e.code) {
        case 'storage/unauthorized':
          throw Exception('Permission denied. Please check your access rights.');
        case 'storage/canceled':
          throw Exception('Upload was canceled.');
        case 'storage/quota-exceeded':
          throw Exception('Storage quota exceeded.');
        case 'storage/invalid-format':
          throw Exception('Invalid PDF format.');
        case 'storage/invalid-argument':
          throw Exception('Invalid file or arguments.');
        default:
          throw Exception('Upload failed: ${e.message ?? e.code}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during PDF upload: $e');
      }
      
      if (e.toString().contains('Exception:')) {
        rethrow;
      } else {
        throw Exception('Failed to upload PDF: $e');
      }
    }
  }
  
  static Future<void> deleteTripPdf({
    required String agencyId,
    required String tripId,
    required String fileName,
  }) async {
    try {
      // Construct the file path (this is a best guess approach)
      final storagePath = 'agencies/$agencyId/trips/$tripId/pdfs/$fileName';
      
      if (kDebugMode) {
        print('Attempting to delete PDF: $storagePath');
      }
      
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      await storageRef.delete();
      
      if (kDebugMode) {
        print('PDF deleted successfully');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Firebase error during PDF deletion: ${e.code} - ${e.message}');
      }
      
      // Don't throw for file not found - it might have been deleted already
      if (e.code != 'storage/object-not-found') {
        throw Exception('Failed to delete PDF: ${e.message ?? e.code}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during PDF deletion: $e');
      }
      throw Exception('Failed to delete PDF: $e');
    }
  }
}