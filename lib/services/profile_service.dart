import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/flutter_flow/uploaded_file.dart';
import '/auth/firebase_auth/auth_util.dart';

class ProfileService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Upload profile photo to Firebase Storage and return the download URL
  static Future<String?> uploadProfilePhoto(FFUploadedFile photo) async {
    try {
      print('Starting photo upload...');
      final user = currentUser;
      if (user == null) {
        print('Upload failed: user not authenticated');
        return null;
      }
      
      if (photo.bytes == null || photo.bytes!.isEmpty) {
        print('Upload failed: photo bytes are null or empty');
        return null;
      }
      
      print('Photo bytes length: ${photo.bytes!.length}');
      print('User ID: ${user.uid}');

      final String fileName = 'profile_photos/${user.uid ?? "unknown"}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = _storage.ref().child(fileName);
      
      print('Uploading to Firebase Storage: $fileName');
      
      final UploadTask uploadTask = storageRef.putData(
        photo.bytes!,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': user.uid ?? 'unknown',
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Add timeout and progress tracking
      print('Waiting for upload completion...');
      final TaskSnapshot snapshot = await uploadTask.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('Upload timed out after 30 seconds');
          uploadTask.cancel();
          throw Exception('Upload timeout');
        },
      );
      
      print('Upload completed, getting download URL...');
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      print('Download URL obtained: $downloadUrl');
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile photo: $e');
      print('Error type: ${e.runtimeType}');
      return null;
    }
  }

  /// Update user profile with interests and preferences
  static Future<bool> updateUserProfile({
    String? favoriteDestination,
    String? tripType,
    List<String>? foodPreferences,
    List<String>? hobbies,
    String? profilePhotoUrl,
    String? instagramLink,
  }) async {
    try {
      final user = currentUser;
      print('Current user: ${user?.uid}');
      if (user == null || user.uid == null) {
        print('User not authenticated - user is null or uid is null');
        return false;
      }

      final Map<String, dynamic> updateData = {};
      print('Building update data...');
      
      if (favoriteDestination != null && favoriteDestination.isNotEmpty) {
        print('Adding favoriteDestination: $favoriteDestination');
        updateData['favoriteDestination'] = favoriteDestination;
      } else {
        print('Skipping favoriteDestination - null or empty');
      }
      
      if (tripType != null && tripType.isNotEmpty) {
        print('Adding tripType: $tripType');
        updateData['tripType'] = tripType;
      } else {
        print('Skipping tripType - null or empty');
      }
      
      if (foodPreferences != null && foodPreferences.isNotEmpty) {
        print('Adding foodPreferences: $foodPreferences');
        updateData['foodPreferences'] = foodPreferences;
      } else {
        print('Skipping foodPreferences - null or empty');
      }
      
      if (hobbies != null && hobbies.isNotEmpty) {
        print('Adding hobbies: $hobbies');
        updateData['hobbies'] = hobbies;
      } else {
        print('Skipping hobbies - null or empty');
      }
      
      if (profilePhotoUrl != null && profilePhotoUrl.isNotEmpty) {
        print('Adding profilePhotoUrl: $profilePhotoUrl');
        updateData['profilePhotoUrl'] = profilePhotoUrl;
      } else {
        print('Skipping profilePhotoUrl - null or empty');
      }
      
      if (instagramLink != null && instagramLink.isNotEmpty) {
        print('Adding instagramLink: $instagramLink');
        updateData['instagramLink'] = instagramLink;
      } else {
        print('Skipping instagramLink - null or empty');
      }

      // Add timestamp for tracking
      updateData['profileUpdatedAt'] = DateTime.now();
      print('Final update data: $updateData');

      if (updateData.length <= 1) { // Only timestamp, no actual data
        print('No data to update - only timestamp present');
        return false; // Return false instead of throwing
      }

      print('Saving to Firestore...');
      await _firestore.collection('users').doc(user.uid!).set(updateData, SetOptions(merge: true));
      print('Profile saved successfully');
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  /// Save complete user profile including photo upload
  static Future<bool> saveUserProfileWithPhoto({
    String? favoriteDestination,
    String? tripType,
    List<String>? foodPreferences,
    List<String>? hobbies,
    FFUploadedFile? profilePhoto,
    String? instagramLink,
  }) async {
    try {
      print('Starting profile save with data:');
      print('  favoriteDestination: $favoriteDestination');
      print('  tripType: $tripType');
      print('  foodPreferences: $foodPreferences');
      print('  hobbies: $hobbies');
      print('  instagramLink: $instagramLink');
      print('  profilePhoto: ${profilePhoto != null ? "provided" : "null"}');
      
      String? photoUrl;
      
      // Convert photo to base64 for immediate display
      if (profilePhoto != null && profilePhoto.bytes != null && profilePhoto.bytes!.isNotEmpty) {
        print('Converting photo to base64...');
        final base64String = base64Encode(profilePhoto.bytes!);
        photoUrl = 'data:image/jpeg;base64,$base64String';
        print('Photo ready (${(profilePhoto.bytes!.length / 1024).round()}KB)');
      }
      
      // Update profile with all data (prioritize travel preferences)
      print('Calling updateUserProfile...');
      print('About to save - favoriteDestination: $favoriteDestination, tripType: $tripType');
      final result = await updateUserProfile(
        favoriteDestination: favoriteDestination,
        tripType: tripType,
        foodPreferences: foodPreferences,
        hobbies: hobbies,
        profilePhotoUrl: photoUrl,
        instagramLink: instagramLink,
      );
      print('updateUserProfile result: $result');
      return result;
    } catch (e) {
      print('Error saving user profile: $e');
      return false;
    }
  }

  /// Delete old profile photo when updating with a new one
  static Future<void> deleteOldProfilePhoto(String? oldPhotoUrl) async {
    if (oldPhotoUrl == null || oldPhotoUrl.isEmpty) return;
    
    try {
      final Reference photoRef = _storage.refFromURL(oldPhotoUrl);
      await photoRef.delete();
    } catch (e) {
      print('Error deleting old profile photo: $e');
      // Don't throw error, just log it
    }
  }

  /// Validate Instagram URL
  static bool isValidInstagramUrl(String? url) {
    if (url == null || url.isEmpty) return true; // Optional field
    
    return url.startsWith('https://instagram.com/') || 
           url.startsWith('https://www.instagram.com/');
  }

  /// Extract Instagram username from URL
  static String? getInstagramUsername(String? url) {
    if (url == null || url.isEmpty) return null;
    
    try {
      if (url.startsWith('https://instagram.com/')) {
        return url.substring('https://instagram.com/'.length).split('/')[0];
      } else if (url.startsWith('https://www.instagram.com/')) {
        return url.substring('https://www.instagram.com/'.length).split('/')[0];
      }
    } catch (e) {
      print('Error extracting Instagram username: $e');
    }
    
    return null;
  }
}
