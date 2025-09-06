import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:html' as html;

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyCX0GVpCxSNBRyUsmSqWlhg_x5lVazIBx4",
            authDomain: "tripbasket-sctkxj.firebaseapp.com",
            projectId: "tripbasket-sctkxj",
            storageBucket: "tripbasket-sctkxj.firebasestorage.app",
            messagingSenderId: "950681576261",
            appId: "1:950681576261:web:bcac7dfa1ec12b33f5942c",
            measurementId: "G-1458DL741S"));
            
    // Simple Firestore initialization
    try {
      await setupFirestoreForCompatibility();
      if (kDebugMode) {
        print('✅ Firebase initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Firestore setup warning: $e');
      }
    }
  } else {
    await Firebase.initializeApp();
  }
}

Future<void> setupFirestoreForCompatibility() async {
  try {
    final firestore = FirebaseFirestore.instance;
    firestore.settings = const Settings(
      persistenceEnabled: true,  // ✅ not forced off
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    if (kDebugMode) {
      print('✅ Firestore settings applied with safe configuration');
    }
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ Firestore setup error (gracefully handled): $e');
    }
    // Don't throw - let the app continue
  }
}

