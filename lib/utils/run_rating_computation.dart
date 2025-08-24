import 'package:firebase_core/firebase_core.dart';
import '/firebase_options.dart';
import '/utils/compute_trip_ratings.dart';

/// Simple script to compute and backfill rating averages for all trips
/// 
/// To run this script:
/// 1. Make sure your Firebase project is properly configured
/// 2. Run: flutter run lib/utils/run_rating_computation.dart
/// 3. Check the console for progress updates
/// 
/// This will:
/// - Query all trips in your Firestore database
/// - For each trip, compute the average rating from its reviews
/// - Update the trip document with rating_avg and rating_count fields
Future<void> main() async {
  print('🚀 Starting Trip Rating Computation Script');
  print('=========================================');
  
  try {
    // Initialize Firebase
    print('🔧 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
    
    // Run the computation
    await TripRatingComputer.computeAndUpdateAllTripRatings();
    
    print('');
    print('✅ SCRIPT COMPLETED SUCCESSFULLY!');
    print('🎯 All trip ratings have been computed and updated');
    print('💡 You can now see real rating data in your trip cards');
    
  } catch (e, stackTrace) {
    print('');
    print('❌ SCRIPT FAILED!');
    print('💥 Error: $e');
    print('📍 Stack trace: $stackTrace');
    print('');
    print('🔧 Troubleshooting:');
    print('   1. Make sure Firebase is properly configured');
    print('   2. Check your Firestore security rules allow reads/writes');
    print('   3. Verify your internet connection');
    print('   4. Ensure you have proper Firebase permissions');
  }
}