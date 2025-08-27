import 'package:flutter/material.dart';
import 'lib/utils/compute_trip_ratings.dart';
import 'lib/backend/firebase/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await initFirebase();
  
  print('🔧 Starting rating fix utility...');
  print('This will recalculate and update ratings for all trips based on their reviews.');
  print('');
  
  try {
    await TripRatingComputer.computeAndUpdateAllTripRatings();
    print('');
    print('✅ Rating fix completed successfully!');
    print('You can now check your app - trips with reviews should show correct ratings.');
  } catch (e) {
    print('');
    print('❌ Error during rating fix: $e');
  }
}