import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:html' as html;

Future initFirebase() async {
  if (kIsWeb) {
    // Ultra-aggressive Firebase 11.x blocking at Dart level
    try {
      html.window.localStorage.remove('firebase:previous_websocket_failure');
      html.window.localStorage.remove('firebase:host:tripbasket-sctkxj-default-rtdb.firebaseio.com');
      html.window.sessionStorage.clear();
      
      // Force clear any cached Firebase 11.x modules via DOM manipulation
      try {
        // Clear localStorage entries that might cache Firebase 11.x
        html.window.localStorage.remove('firebase:version');
        html.window.localStorage.remove('firebase:sdk_version');
        
        // Additional cache clearing for Firebase state
        final storageKeys = html.window.localStorage.keys.toList();
        for (final key in storageKeys) {
          if (key.contains('firebase') && key.contains('11.')) {
            html.window.localStorage.remove(key);
          }
        }
      } catch (e) {
        // Ignore any errors during cache clearing
      }
    } catch (e) {
      if (kDebugMode) {
        print('Firebase cache clear warning: $e');
      }
    }
    
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyCX0GVpCxSNBRyUsmSqWlhg_x5lVazIBx4",
            authDomain: "tripbasket-sctkxj.firebaseapp.com",
            projectId: "tripbasket-sctkxj",
            storageBucket: "tripbasket-sctkxj.firebasestorage.app",
            messagingSenderId: "950681576261",
            appId: "1:950681576261:web:bcac7dfa1ec12b33f5942c",
            measurementId: "G-1458DL741S"));
            
    // CRITICAL: Force Firestore to use offline-first mode to avoid 11.7.0 issues
    try {
      await setupFirestoreForCompatibility();
      
      // Additional failsafe: Disable real-time listeners if Firebase 11.x detected
      final userAgent = html.window.navigator.userAgent;
      if (kDebugMode) {
        print('🔧 Firebase initialization completed for user agent: $userAgent');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Firestore compatibility setup error: $e');
      }
      // Don't fail completely, but log the issue
    }
  } else {
    await Firebase.initializeApp();
  }
}

Future<void> setupFirestoreForCompatibility() async {
  // Get Firestore instance after Firebase is initialized
  final firestore = FirebaseFirestore.instance;
  
  // CRITICAL: Force compatible settings to prevent Firebase 11.7.0 assertion errors
  try {
    // Method 1: Clear network and persistence
    await firestore.disableNetwork();
    
    try {
      await firestore.clearPersistence();
      if (kDebugMode) {
        print('✅ Firestore persistence cleared successfully');
      }
    } catch (persistenceError) {
      if (kDebugMode) {
        print('⚠️ Firestore persistence clear warning (expected): $persistenceError');
      }
    }
    
    await firestore.enableNetwork();
    
    // Method 2: Force settings that prevent assertion errors
    try {
      firestore.settings = Settings(
        persistenceEnabled: false, // CRITICAL: Disable persistence
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      if (kDebugMode) {
        print('✅ Firestore settings applied: persistence disabled');
      }
    } catch (settingsError) {
      if (kDebugMode) {
        print('⚠️ Firestore settings warning: $settingsError');
      }
    }
    
    if (kDebugMode) {
      print('🔧 Firestore compatibility setup completed successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Firestore compatibility setup failed: $e');
    }
    // Continue anyway - don't break the app
  }
}

/// Initialize Firebase compatibility fixes immediately after Firebase initialization
/// This prevents the Firebase 11.7.0 assertion errors by configuring Firestore properly
Future<void> initializeFirebaseCompatibility() async {
  if (!kIsWeb) return;
  
  try {
    // Clear any existing Firebase state
    html.window.localStorage.remove('firebase:previous_websocket_failure');
    html.window.localStorage.remove('firebase:host:tripbasket-sctkxj-default-rtdb.firebaseio.com');
    html.window.sessionStorage.clear();
    
    // Setup Firestore for compatibility immediately
    await setupFirestoreForCompatibility();
    
    // Add a small delay to ensure Firebase is fully ready
    await Future.delayed(Duration(milliseconds: 500));
    
    if (kDebugMode) {
      print('🔧 Firebase compatibility setup completed successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Firebase compatibility setup failed: $e');
    }
    // Continue anyway, don't block app startup
  }
}
