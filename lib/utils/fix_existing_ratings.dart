import 'package:flutter/material.dart';
import '/utils/compute_trip_ratings.dart';

class FixExistingRatings {
  static Future<void> runFix() async {
    print('🔧 Starting fix for existing trip ratings...');
    
    try {
      await TripRatingComputer.computeAndUpdateAllTripRatings();
      print('✅ Fix completed successfully!');
    } catch (e) {
      print('❌ Error during fix: $e');
      rethrow;
    }
  }

  static Widget buildFixButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fixing trip ratings... This may take a moment.'),
            duration: Duration(seconds: 2),
          ),
        );

        try {
          await runFix();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Trip ratings fixed successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error fixing ratings: $e'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      },
      child: const Text('Fix Trip Ratings'),
    );
  }
}