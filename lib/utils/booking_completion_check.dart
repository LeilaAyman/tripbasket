import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';

/// Utility class to check if a user can review a trip based on booking completion
class BookingCompletionCheck {
  
  /// Checks if the current user has completed a booking for the given trip
  /// Returns true if the user can write a review (booking completed), false otherwise
  static Future<bool> canReviewTrip(DocumentReference tripReference) async {
    if (!loggedIn || currentUserReference == null) {
      return false;
    }

    try {
      // Check if user has any completed bookings for this trip
      final completedBookings = await queryBookingsRecordOnce(
        queryBuilder: (q) => q
            .where('user_reference', isEqualTo: currentUserReference)
            .where('trip_reference', isEqualTo: tripReference)
            .where('status', isEqualTo: 'completed'), // Assuming 'completed' status exists
      );

      return completedBookings.isNotEmpty;
    } catch (e) {
      print('Error checking booking completion: $e');
      return false;
    }
  }

  /// Checks if the current user has any booking (any status) for the given trip
  /// This can be used for other features like showing booking details
  static Future<bool> hasBookingForTrip(DocumentReference tripReference) async {
    if (!loggedIn || currentUserReference == null) {
      return false;
    }

    try {
      final bookings = await queryBookingsRecordOnce(
        queryBuilder: (q) => q
            .where('user_reference', isEqualTo: currentUserReference)
            .where('trip_reference', isEqualTo: tripReference),
      );

      return bookings.isNotEmpty;
    } catch (e) {
      print('Error checking user bookings: $e');
      return false;
    }
  }

  /// Gets the booking status for the current user's booking of a specific trip
  /// Returns null if no booking exists, otherwise returns the status string
  static Future<String?> getBookingStatus(DocumentReference tripReference) async {
    if (!loggedIn || currentUserReference == null) {
      return null;
    }

    try {
      final bookings = await queryBookingsRecordOnce(
        queryBuilder: (q) => q
            .where('user_reference', isEqualTo: currentUserReference)
            .where('trip_reference', isEqualTo: tripReference),
        singleRecord: true,
      );

      if (bookings.isNotEmpty) {
        return bookings.first.status;
      }
      return null;
    } catch (e) {
      print('Error getting booking status: $e');
      return null;
    }
  }

  /// Shows an appropriate message to the user about why they can't review
  static String getReviewRestrictionMessage(String? bookingStatus) {
    if (bookingStatus == null) {
      return 'You must book and complete this trip before you can write a review.';
    }
    
    switch (bookingStatus.toLowerCase()) {
      case 'pending':
      case 'confirmed':
        return 'You can write a review after completing your trip.';
      case 'cancelled':
        return 'Cannot review cancelled bookings.';
      case 'completed':
        return ''; // No restriction message needed
      default:
        return 'Trip must be completed before writing a review.';
    }
  }

  /// Future enhancement: Check if enough time has passed since trip completion
  /// to allow review submission (e.g., within 30 days of trip end date)
  static Future<bool> isWithinReviewPeriod(DocumentReference tripReference) async {
    // This could be implemented later based on trip end dates and business rules
    // For now, return true to allow reviews any time after completion
    return true;
  }
}