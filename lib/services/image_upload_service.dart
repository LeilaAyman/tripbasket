import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '/auth/firebase_auth/auth_util.dart';

class ImageUploadService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery or camera
  static Future<XFile?> pickImage({
    ImageSource source = ImageSource.gallery,
    int imageQuality = 85,
    double? maxWidth,
    double? maxHeight,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
      return image;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Upload image to Firebase Storage and return the download URL
  static Future<String?> uploadImage({
    required XFile imageFile,
    required String folderPath,
    required String fileName,
    Function(double)? onProgress,
  }) async {
    try {
      // Create reference
      final ref = _storage.ref().child('$folderPath/$fileName');

      // Upload task
      UploadTask uploadTask;
      
      if (kIsWeb) {
        // Web upload
        final bytes = await imageFile.readAsBytes();
        uploadTask = ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        // Mobile upload
        final file = File(imageFile.path);
        uploadTask = ref.putFile(
          file,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      }

      // Listen to progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for completion
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      print('Image uploaded successfully: $downloadUrl');
      return downloadUrl;

    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Upload profile picture for current user
  static Future<String?> uploadUserProfilePicture(XFile imageFile, {
    Function(double)? onProgress,
  }) async {
    if (!loggedIn) {
      print('User must be logged in to upload profile picture');
      return null;
    }

    final fileName = 'profile_${currentUserUid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    final downloadUrl = await uploadImage(
      imageFile: imageFile,
      folderPath: 'profile_pictures',
      fileName: fileName,
      onProgress: onProgress,
    );

    if (downloadUrl != null) {
      // Update user document with new profile picture URL
      await updateUserProfilePicture(downloadUrl);
    }

    return downloadUrl;
  }

  /// Upload profile picture for agency
  static Future<String?> uploadAgencyProfilePicture(
    XFile imageFile, 
    String agencyId, {
    Function(double)? onProgress,
  }) async {
    final fileName = 'agency_${agencyId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    final downloadUrl = await uploadImage(
      imageFile: imageFile,
      folderPath: 'agency_pictures',
      fileName: fileName,
      onProgress: onProgress,
    );

    if (downloadUrl != null) {
      // Update agency document with new profile picture URL
      await updateAgencyProfilePicture(agencyId, downloadUrl);
    }

    return downloadUrl;
  }

  /// Update user profile picture URL in Firestore and Firebase Auth
  static Future<void> updateUserProfilePicture(String downloadUrl) async {
    try {
      // Update Firebase Auth user profile
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePhotoURL(downloadUrl);
      }

      // Update Firestore user document
      if (currentUserDocument != null) {
        await currentUserDocument!.reference.update({
          'photo_url': downloadUrl,
          'profile_photo_url': downloadUrl,
          'updated_time': FieldValue.serverTimestamp(),
        });
      }

      print('User profile picture updated successfully');
    } catch (e) {
      print('Error updating user profile picture: $e');
      rethrow;
    }
  }

  /// Update agency profile picture URL in Firestore
  static Future<void> updateAgencyProfilePicture(String agencyId, String downloadUrl) async {
    try {
      await _firestore.collection('agencies').doc(agencyId).update({
        'profile_picture_url': downloadUrl,
        'updated_time': FieldValue.serverTimestamp(),
      });

      print('Agency profile picture updated successfully');
    } catch (e) {
      print('Error updating agency profile picture: $e');
      rethrow;
    }
  }

  /// Show image source selection dialog
  static Future<ImageSource?> showImageSourceDialog(context) async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              if (!kIsWeb) // Camera not available on web
                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('Camera'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  /// Show image upload progress dialog
  static void showUploadProgressDialog(
    context, {
    required Future<String?> uploadFuture,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return FutureBuilder<String?>(
          future: uploadFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Uploading image...'),
                  ],
                ),
              );
            } else {
              // Upload completed
              SchedulerBinding.instance.addPostFrameCallback((_) {
                Navigator.pop(context);
                if (snapshot.hasError) {
                  onError(snapshot.error.toString());
                } else if (snapshot.data != null) {
                  onSuccess(snapshot.data!);
                } else {
                  onError('Failed to upload image');
                }
              });

              return SizedBox.shrink();
            }
          },
        );
      },
    );
  }

  /// Delete image from Firebase Storage
  static Future<bool> deleteImage(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      print('Image deleted successfully');
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }
}