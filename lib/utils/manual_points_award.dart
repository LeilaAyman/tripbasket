import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Manual function to award 100 points for completed bookings
/// This is a temporary solution until Cloud Functions are deployed
Future<String> awardPointsForCompletedBookings() async {
  try {
    if (!loggedIn || currentUserReference == null) {
      return 'Error: User not logged in';
    }

    // Get all completed bookings for the current user
    final bookingsQuery = await BookingsRecord.collection
        .where('user_reference', isEqualTo: currentUserReference)
        .where('payment_status', isEqualTo: 'completed')
        .get();

    if (bookingsQuery.docs.isEmpty) {
      return 'No completed bookings found';
    }

    // Get current user's points
    final userDoc = await currentUserReference!.get();
    final userData = UsersRecord.fromSnapshot(userDoc);
    int currentPoints = userData.loyaltyPoints;

    // Calculate points to add (100 per booking)
    int pointsToAdd = bookingsQuery.docs.length * 100;

    // Update user's points using FieldValue.increment for atomic operation
    await currentUserReference!.update({
      'loyaltyPoints': FieldValue.increment(pointsToAdd),
    });

    return 'Successfully awarded $pointsToAdd points for ${bookingsQuery.docs.length} completed booking(s)!';
  } catch (e) {
    return 'Error awarding points: $e';
  }
}

/// Award 100 points for a specific booking (if not already awarded)
Future<String> awardPointsForBooking(String bookingId) async {
  try {
    if (!loggedIn || currentUserReference == null) {
      return 'Error: User not logged in';
    }

    // Check if the booking exists and belongs to the user
    final bookingDoc = await BookingsRecord.collection.doc(bookingId).get();
    
    if (!bookingDoc.exists) {
      return 'Booking not found';
    }

    final booking = BookingsRecord.fromSnapshot(bookingDoc);
    
    if (booking.userReference != currentUserReference) {
      return 'This booking does not belong to you';
    }

    if (booking.paymentStatus.toLowerCase() != 'completed') {
      return 'Booking payment is not completed';
    }

    // Add 100 points to user using FieldValue.increment for atomic operation
    await currentUserReference!.update({
      'loyaltyPoints': FieldValue.increment(100),
    });

    return 'Successfully awarded 100 points for this booking!';
  } catch (e) {
    return 'Error awarding points: $e';
  }
}