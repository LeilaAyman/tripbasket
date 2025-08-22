import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Debug function to check your current points and bookings
Future<String> debugPointsAndBookings() async {
  try {
    if (!loggedIn || currentUserReference == null) {
      return 'Error: User not logged in';
    }

    // Get current user data
    final userDoc = await currentUserReference!.get();
    final userData = UsersRecord.fromSnapshot(userDoc);
    
    // Get all bookings for the current user
    final bookingsQuery = await BookingsRecord.collection
        .where('user_reference', isEqualTo: currentUserReference)
        .get();

    // Get completed bookings
    final completedBookings = bookingsQuery.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['payment_status']?.toString().toLowerCase() == 'completed';
    }).toList();

    StringBuffer result = StringBuffer();
    result.writeln('🔍 DEBUG REPORT:');
    result.writeln('');
    result.writeln('👤 User: ${userData.email}');
    result.writeln('🏆 Current Points: ${userData.loyaltyPoints}');
    result.writeln('📝 Total Bookings: ${bookingsQuery.docs.length}');
    result.writeln('✅ Completed Bookings: ${completedBookings.length}');
    result.writeln('');
    
    if (completedBookings.isNotEmpty) {
      result.writeln('📋 COMPLETED BOOKINGS:');
      for (int i = 0; i < completedBookings.length; i++) {
        final booking = completedBookings[i];
        final data = booking.data() as Map<String, dynamic>;
        result.writeln('${i + 1}. ${data['trip_title']} - \$${data['trip_price']} (${data['payment_status']})');
      }
      result.writeln('');
      result.writeln('💡 Expected Points: ${completedBookings.length * 100}');
      result.writeln('🚨 Points Gap: ${(completedBookings.length * 100) - userData.loyaltyPoints}');
    }

    return result.toString();
  } catch (e) {
    return 'Error debugging: $e';
  }
}

/// Reset loyaltyPoints field to 0 (in case it was stored as string)
Future<String> resetLoyaltyPointsField() async {
  try {
    if (!loggedIn || currentUserReference == null) {
      return 'Error: User not logged in';
    }

    await currentUserReference!.update({
      'loyaltyPoints': 0,
    });

    return 'Successfully reset loyaltyPoints field to 0 (number type)';
  } catch (e) {
    return 'Error resetting loyaltyPoints: $e';
  }
}