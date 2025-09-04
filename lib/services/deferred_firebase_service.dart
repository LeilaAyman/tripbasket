import 'dart:async';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

class DeferredFirebaseService {
  static bool _performanceInitialized = false;
  static bool _analyticsInitialized = false;
  static final Completer<void> _performanceCompleter = Completer<void>();
  static final Completer<void> _analyticsCompleter = Completer<void>();

  /// Initialize Firebase Performance after app startup to reduce initial load time
  static Future<void> initializePerformance() async {
    if (_performanceInitialized) return;
    
    try {
      // Defer performance monitoring initialization
      await Future.delayed(const Duration(milliseconds: 2000));
      
      if (!kDebugMode) {
        final performance = FirebasePerformance.instance;
        await performance.setPerformanceCollectionEnabled(true);
      }
      
      _performanceInitialized = true;
      _performanceCompleter.complete();
      
      if (kDebugMode) {
        print('Firebase Performance initialized (deferred)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Firebase Performance: $e');
      }
      _performanceCompleter.complete();
    }
  }

  /// Initialize Firebase Analytics after critical app functionality is loaded
  static Future<void> initializeAnalytics() async {
    if (_analyticsInitialized) return;
    
    try {
      // Defer analytics initialization even more
      await Future.delayed(const Duration(milliseconds: 3000));
      
      // Analytics initialization would go here
      // Note: Since this codebase doesn't seem to use Firebase Analytics,
      // this is mainly a placeholder for future implementation
      
      _analyticsInitialized = true;
      _analyticsCompleter.complete();
      
      if (kDebugMode) {
        print('Firebase Analytics initialized (deferred)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Firebase Analytics: $e');
      }
      _analyticsCompleter.complete();
    }
  }

  /// Wait for performance monitoring to be ready (optional)
  static Future<void> waitForPerformance() async {
    return _performanceCompleter.future;
  }

  /// Wait for analytics to be ready (optional)
  static Future<void> waitForAnalytics() async {
    return _analyticsCompleter.future;
  }

  /// Initialize all non-critical Firebase services
  static void initializeNonCriticalServices() {
    // Start both initializations in parallel, but don't wait for them
    Future.microtask(initializePerformance);
    Future.microtask(initializeAnalytics);
  }
}