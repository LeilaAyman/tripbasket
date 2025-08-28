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
      final user = currentUser;
      if (user == null) return null;

      final String fileName = 'profile_photos/${user.uid ?? "unknown"}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = _storage.ref().child(fileName);
      
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

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile photo: $e');
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
      if (user == null) return false;

      final Map<String, dynamic> updateData = {};
      
      if (favoriteDestination != null) {
        updateData['favoriteDestination'] = favoriteDestination;
      }
      
      if (tripType != null) {
        updateData['tripType'] = tripType;
      }
      
      if (foodPreferences != null) {
        updateData['foodPreferences'] = foodPreferences;
      }
      
      if (hobbies != null) {
        updateData['hobbies'] = hobbies;
      }
      
      if (profilePhotoUrl != null) {
        updateData['profilePhotoUrl'] = profilePhotoUrl;
      }
      
      if (instagramLink != null) {
        updateData['instagramLink'] = instagramLink;
      }

      await _firestore.collection('users').doc(user.uid ?? 'unknown').update(updateData);
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
      String? photoUrl;
      
      // Upload photo if provided
      if (profilePhoto != null) {
        photoUrl = await uploadProfilePhoto(profilePhoto);
        if (photoUrl == null) {
          print('Failed to upload profile photo');
          // Continue without photo rather than failing completely
        }
      }
      
      // Update profile with all data
      return await updateUserProfile(
        favoriteDestination: favoriteDestination,
        tripType: tripType,
        foodPreferences: foodPreferences,
        hobbies: hobbies,
        profilePhotoUrl: photoUrl,
        instagramLink: instagramLink,
      );
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
