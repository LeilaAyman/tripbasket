import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '/backend/backend.dart';

class ReviewImportUtils {
  /// Import reviews from CSV data
  static Future<ReviewImportResult> importReviewsFromCsv({
    required String csvData,
    required DocumentReference agencyRef,
  }) async {
    try {
      final lines = csvData.split('\n');
      if (lines.isEmpty) {
        throw Exception('CSV file is empty');
      }

      // Expected CSV format: trip_title, user_name, rating, comment, date (optional)
      final header = lines[0].toLowerCase();
      if (!header.contains('trip_title') || 
          !header.contains('user_name') || 
          !header.contains('rating') || 
          !header.contains('comment')) {
        throw Exception('Invalid CSV format. Required columns: trip_title, user_name, rating, comment');
      }

      final headerParts = lines[0].split(',').map((e) => e.trim().toLowerCase()).toList();
      final tripTitleIndex = headerParts.indexOf('trip_title');
      final userNameIndex = headerParts.indexOf('user_name');
      final ratingIndex = headerParts.indexOf('rating');
      final commentIndex = headerParts.indexOf('comment');
      final dateIndex = headerParts.indexOf('date');

      List<String> errors = [];
      List<ReviewImportData> successfulImports = [];
      int skipped = 0;

      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        try {
          final parts = _parseCsvLine(line);
          if (parts.length < 4) {
            errors.add('Line ${i + 1}: Not enough columns');
            continue;
          }

          final tripTitle = parts[tripTitleIndex].trim();
          final userName = parts[userNameIndex].trim();
          final ratingStr = parts[ratingIndex].trim();
          final comment = parts[commentIndex].trim();

          // Validate required fields
          if (tripTitle.isEmpty || userName.isEmpty || ratingStr.isEmpty || comment.isEmpty) {
            errors.add('Line ${i + 1}: Missing required fields');
            continue;
          }

          // Validate rating
          final rating = double.tryParse(ratingStr);
          if (rating == null || rating < 1.0 || rating > 5.0) {
            errors.add('Line ${i + 1}: Invalid rating (must be 1.0-5.0)');
            continue;
          }

          // Parse date if provided
          DateTime? reviewDate;
          if (dateIndex >= 0 && dateIndex < parts.length && parts[dateIndex].trim().isNotEmpty) {
            try {
              reviewDate = DateTime.parse(parts[dateIndex].trim());
            } catch (e) {
              // Use current date if date parsing fails
              reviewDate = DateTime.now();
            }
          } else {
            reviewDate = DateTime.now();
          }

          // Find matching trip by title and agency
          final tripQuery = await FirebaseFirestore.instance
              .collection('trips')
              .where('title', isEqualTo: tripTitle)
              .where('agency_reference', isEqualTo: agencyRef)
              .limit(1)
              .get();

          if (tripQuery.docs.isEmpty) {
            errors.add('Line ${i + 1}: Trip "$tripTitle" not found for this agency');
            continue;
          }

          final tripRef = tripQuery.docs.first.reference;

          // Check if review already exists for this user and trip
          final existingReview = await FirebaseFirestore.instance
              .collection('reviews')
              .where('trip_reference', isEqualTo: tripRef)
              .where('user_name', isEqualTo: userName)
              .limit(1)
              .get();

          if (existingReview.docs.isNotEmpty) {
            skipped++;
            continue;
          }

          successfulImports.add(ReviewImportData(
            tripReference: tripRef,
            tripTitle: tripTitle,
            userName: userName,
            rating: rating,
            comment: comment,
            createdAt: reviewDate,
          ));
        } catch (e) {
          errors.add('Line ${i + 1}: ${e.toString()}');
        }
      }

      // Import successful reviews
      for (final reviewData in successfulImports) {
        await FirebaseFirestore.instance.collection('reviews').add({
          'trip_reference': reviewData.tripReference,
          'trip_title': reviewData.tripTitle,
          'user_name': reviewData.userName,
          'user_photo': '', // Empty for imported reviews
          'user_reference': null, // No user reference for imported reviews
          'rating': reviewData.rating,
          'comment': reviewData.comment,
          'created_at': reviewData.createdAt,
          'helpful_count': 0,
        });

        // Update trip rating
        await _updateTripRating(reviewData.tripReference);
      }

      return ReviewImportResult(
        successful: successfulImports.length,
        skipped: skipped,
        errors: errors,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error importing reviews: $e');
      }
      rethrow;
    }
  }

  /// Parse CSV line handling quoted fields
  static List<String> _parseCsvLine(String line) {
    List<String> result = [];
    StringBuffer current = StringBuffer();
    bool inQuotes = false;
    
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      
      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          // Escaped quote
          current.write('"');
          i++; // Skip next quote
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        result.add(current.toString());
        current.clear();
      } else {
        current.write(char);
      }
    }
    
    result.add(current.toString());
    return result;
  }

  /// Update trip's average rating based on all reviews
  static Future<void> _updateTripRating(DocumentReference tripRef) async {
    try {
      final reviews = await FirebaseFirestore.instance
          .collection('reviews')
          .where('trip_reference', isEqualTo: tripRef)
          .get();

      if (reviews.docs.isEmpty) return;

      double totalRating = 0;
      for (final doc in reviews.docs) {
        final rating = (doc.data()['rating'] as num?)?.toDouble() ?? 0.0;
        totalRating += rating;
      }

      final averageRating = totalRating / reviews.docs.length;

      await tripRef.update({
        'rating': averageRating,
        'rating_avg': averageRating,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error updating trip rating: $e');
      }
    }
  }

  /// Generate sample CSV template
  static String generateCsvTemplate() {
    return 'trip_title,user_name,rating,comment,date\n'
           '"Example Trip to Paris","John Smith",5.0,"Amazing experience! Highly recommend.",2024-01-15\n'
           '"Beach Resort Getaway","Sarah Johnson",4.5,"Great trip but could use more activities.",2024-01-20\n'
           '"Mountain Adventure","Mike Chen",4.0,"Beautiful scenery and good guide.",2024-02-01';
  }
}

class ReviewImportData {
  final DocumentReference tripReference;
  final String tripTitle;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewImportData({
    required this.tripReference,
    required this.tripTitle,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}

class ReviewImportResult {
  final int successful;
  final int skipped;
  final List<String> errors;

  ReviewImportResult({
    required this.successful,
    required this.skipped,
    required this.errors,
  });

  bool get hasErrors => errors.isNotEmpty;
  int get total => successful + skipped;
  String get summary => 'Imported: $successful, Skipped: $skipped, Errors: ${errors.length}';
}