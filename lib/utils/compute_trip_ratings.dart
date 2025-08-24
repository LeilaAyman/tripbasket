import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/backend.dart';

class TripRatingComputer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> computeAndUpdateAllTripRatings() async {
    print('🔄 Starting rating computation for all trips...');
    
    try {
      final tripsQuery = await _firestore.collection('trips').get();
      final trips = tripsQuery.docs;
      
      print('📊 Found ${trips.length} trips to process');
      
      int processed = 0;
      int updated = 0;
      
      for (final tripDoc in trips) {
        try {
          final tripRef = tripDoc.reference;
          final result = await computeRatingForTrip(tripRef);
          
          if (result != null) {
            await tripRef.update({
              'rating_avg': result.average,
              'rating_count': result.count,
            });
            updated++;
            print('✅ Updated ${tripDoc.id}: ${result.count} reviews, avg ${result.average.toStringAsFixed(1)}');
          } else {
            await tripRef.update({
              'rating_avg': 0.0,
              'rating_count': 0,
            });
            print('📝 Set ${tripDoc.id}: No reviews found');
          }
          
          processed++;
          
        } catch (e) {
          print('❌ Error processing trip ${tripDoc.id}: $e');
        }
      }
      
      print('🎉 Completed! Processed $processed trips, updated $updated with ratings');
      
    } catch (e) {
      print('💥 Error in rating computation: $e');
      rethrow;
    }
  }

  static Future<RatingResult?> computeRatingForTrip(DocumentReference tripRef) async {
    try {
      print('🔍 Computing rating for trip: ${tripRef.path}');
      
      final reviewsQuery = await _firestore
          .collection('reviews')
          .where('trip_reference', isEqualTo: tripRef)
          .get();
      
      final reviews = reviewsQuery.docs;
      
      if (reviews.isEmpty) {
        print('📝 No reviews found for ${tripRef.id}');
        return null;
      }
      
      double totalRating = 0;
      int validReviews = 0;
      
      for (final reviewDoc in reviews) {
        final data = reviewDoc.data();
        final rating = data['rating'];
        
        if (rating != null && rating is num) {
          totalRating += rating.toDouble();
          validReviews++;
        }
      }
      
      if (validReviews == 0) {
        print('📝 No valid ratings found for ${tripRef.id}');
        return null;
      }
      
      final average = totalRating / validReviews;
      print('📊 Trip ${tripRef.id}: $validReviews reviews, average ${average.toStringAsFixed(1)}');
      
      return RatingResult(
        count: validReviews,
        average: average,
      );
      
    } catch (e) {
      print('❌ Error computing rating for ${tripRef.id}: $e');
      return null;
    }
  }

  static Future<void> updateRatingOnReviewChange(DocumentReference tripRef) async {
    print('🔄 Updating rating for trip after review change: ${tripRef.path}');
    
    try {
      final result = await computeRatingForTrip(tripRef);
      
      if (result != null) {
        await tripRef.update({
          'rating_avg': result.average,
          'rating_count': result.count,
        });
        print('✅ Updated trip rating: ${result.count} reviews, avg ${result.average.toStringAsFixed(1)}');
      } else {
        await tripRef.update({
          'rating_avg': 0.0,
          'rating_count': 0,
        });
        print('✅ Reset trip rating: No reviews');
      }
    } catch (e) {
      print('❌ Error updating trip rating: $e');
      rethrow;
    }
  }
}

class RatingResult {
  final int count;
  final double average;
  
  RatingResult({
    required this.count,
    required this.average,
  });
}