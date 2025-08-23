import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class KycUtils {
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5 MB

  static Future<bool> uploadNationalId({
    required String uid,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (picked == null) return false;

      final fileBytes = await picked.readAsBytes();
      
      // Check file size
      if (fileBytes.length > maxFileSizeBytes) {
        throw Exception('File size exceeds 5 MB limit');
      }

      final ext = picked.name?.split('.').last.toLowerCase() ?? 'jpg';
      final contentType = (ext == 'png') ? 'image/png' : 'image/jpeg';

      // Upload to Firebase Storage
      final ref = FirebaseStorage.instance.ref('users/$uid/kyc/national_id.$ext');
      await ref.putData(fileBytes, SettableMetadata(contentType: contentType));
      final url = await ref.getDownloadURL();

      // Update user document
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'nationalIdUrl': url,
        'nationalIdUploadedAt': FieldValue.serverTimestamp(),
        'nationalIdStatus': 'uploaded',
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading National ID: $e');
      }
      rethrow;
    }
  }

  static Future<bool> hasValidNationalId(String uid) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      
      if (!userDoc.exists) return false;
      
      final data = userDoc.data()!;
      final url = data['nationalIdUrl'] as String?;
      final status = data['nationalIdStatus'] as String?;
      
      return url != null && 
             url.isNotEmpty && 
             (status == 'uploaded' || status == 'verified');
    } catch (e) {
      if (kDebugMode) {
        print('Error checking National ID status: $e');
      }
      return false;
    }
  }

  static String getNationalIdStatusDisplay(String? status) {
    switch (status) {
      case 'missing':
        return 'Not uploaded';
      case 'uploaded':
        return 'Under review';
      case 'verified':
        return 'Verified';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Not uploaded';
    }
  }

  static bool canBook(String? status) {
    return status == 'uploaded' || status == 'verified';
  }
}