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
      print('=== IMAGE UPLOAD DEBUG START ===');
      print('Creating Firebase Storage reference: $folderPath/$fileName');
      print('Image file path: ${imageFile.path}');
      print('Image file name: ${imageFile.name}');
      
      // Create reference
      final ref = _storage.ref().child('$folderPath/$fileName');
      print('Storage reference created: ${ref.fullPath}');

      // Upload task
      UploadTask uploadTask;
      
      if (kIsWeb) {
        print('Preparing web upload...');
        // Web upload
        final bytes = await imageFile.readAsBytes();
        print('Image bytes length: ${bytes.length}');
        uploadTask = ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        print('Preparing mobile upload...');
        // Mobile upload
        final file = File(imageFile.path);
        print('File path: ${file.path}, exists: ${await file.exists()}');
        uploadTask = ref.putFile(
          file,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      }

      print('Starting upload task...');
      
      // Listen to progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          print('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
          onProgress(progress);
        });
      }

      // Wait for completion
      print('Waiting for upload completion...');
      final TaskSnapshot snapshot = await uploadTask;
      print('Upload task state: ${snapshot.state}');
      print('Bytes transferred: ${snapshot.bytesTransferred}');
      print('Total bytes: ${snapshot.totalBytes}');
      
      if (snapshot.state != TaskState.success) {
        throw Exception('Upload failed with state: ${snapshot.state}');
      }
      
      print('Upload completed successfully, getting download URL...');
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      if (downloadUrl.isEmpty) {
        throw Exception('Received empty download URL from Firebase Storage');
      }

      print('Image uploaded successfully: $downloadUrl');
      print('=== IMAGE UPLOAD DEBUG END ===');
      return downloadUrl;

    } catch (e) {
      print('Error uploading image: $e');
      if (e.toString().contains('permission')) {
        print('Permission error detected. Check Firebase Storage security rules.');
        throw Exception('Permission denied. Please check your access rights.');
      } else if (e.toString().contains('network')) {
        print('Network error detected. Check internet connection.');
        throw Exception('Network error. Please check your internet connection.');
      } else if (e.toString().contains('storage/')) {
        // Firebase Storage specific error
        throw Exception('Upload failed: ${e.toString().split('] ').last}');
      } else {
        throw Exception('Upload failed: $e');
      }
    }
  }

  /// Upload profile picture for current user
  static Future<String?> uploadUserProfilePicture(XFile imageFile, {
    Function(double)? onProgress,
  }) async {
    try {
      if (!loggedIn) {
        print('Error: User must be logged in to upload profile picture');
        throw Exception('User must be logged in to upload profile picture');
      }

      if (currentUserUid.isEmpty) {
        print('Error: Current user UID is empty');
        throw Exception('Current user UID is empty');
      }

      print('Starting profile picture upload for user: $currentUserUid');

      final fileName = 'profile_${currentUserUid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      print('Uploading image to Firebase Storage...');
      final downloadUrl = await uploadImage(
        imageFile: imageFile,
        folderPath: 'profile_pictures',
        fileName: fileName,
        onProgress: onProgress,
      );

      if (downloadUrl != null && downloadUrl.isNotEmpty) {
        print('Image uploaded successfully. Updating user document...');
        // Update user document with new profile picture URL
        await updateUserProfilePicture(downloadUrl);
        print('Profile picture upload completed successfully');
      } else {
        print('Error: Upload returned null or empty URL');
        throw Exception('Failed to get download URL from upload. Please try again.');
      }

      return downloadUrl;
    } catch (e) {
      print('Error in uploadUserProfilePicture: $e');
      rethrow;
    }
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
      print('Updating Firebase Auth user profile...');
      // Update Firebase Auth user profile
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePhotoURL(downloadUrl);
        print('Firebase Auth profile photo updated successfully');
      } else {
        print('Warning: No current Firebase Auth user found');
      }

      print('Updating Firestore user document...');
      // Update Firestore user document
      if (currentUserReference != null) {
        await currentUserReference!.update({
          'photo_url': downloadUrl,
          'profilePhotoUrl': downloadUrl,
        });
        print('Firestore user document updated successfully');
      } else {
        print('Warning: currentUserReference is null');
        // Try to create the user document reference manually
        if (currentUserUid.isNotEmpty) {
          final userDocRef = FirebaseFirestore.instance.collection('users').doc(currentUserUid);
          await userDocRef.update({
            'photo_url': downloadUrl,
            'profilePhotoUrl': downloadUrl,
          });
          print('Firestore user document updated using manual reference');
        } else {
          throw Exception('Cannot update user document: no user reference or UID available');
        }
      }

      print('User profile picture updated successfully');
    } catch (e) {
      print('Error updating user profile picture: $e');
      rethrow;
    }
  }

  /// Update agency logo URL in Firestore
  static Future<void> updateAgencyProfilePicture(String agencyId, String downloadUrl) async {
    try {
      print('Attempting to update agency logo for ID: $agencyId');
      
      // First check if the document exists
      final docRef = _firestore.collection('agency').doc(agencyId);
      final docSnapshot = await docRef.get();
      
      if (!docSnapshot.exists) {
        print('Agency document does not exist: $agencyId');
        // Create the document with just the logo for now
        await docRef.set({
          'logo': downloadUrl,
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print('Agency document created/updated with logo');
      } else {
        // Document exists, update it
        await docRef.update({
          'logo': downloadUrl,
          'updated_at': FieldValue.serverTimestamp(),
        });
        print('Agency logo updated successfully');
      }
    } catch (e) {
      print('Error updating agency logo: $e');
      if (e.toString().contains('not-found')) {
        throw Exception('Agency document not found. Please ensure the agency exists in the database.');
      }
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