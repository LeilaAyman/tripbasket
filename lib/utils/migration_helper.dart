import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper utility to migrate bookings and add agency references
class MigrationHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check and migrate existing bookings to add agency_reference
  static Future<void> migrateBookingAgencyReferences() async {
    print('🚀 Starting booking migration...');
    
    try {
      // Get all bookings
      final QuerySnapshot bookingsSnapshot = await _firestore
          .collection('bookings')
          .get();
      
      print('📊 Found ${bookingsSnapshot.docs.length} bookings to check');
      
      int updatedCount = 0;
      int skippedCount = 0;
      int errorCount = 0;
      
      for (final DocumentSnapshot bookingDoc in bookingsSnapshot.docs) {
        try {
          final Map<String, dynamic> bookingData = 
              bookingDoc.data() as Map<String, dynamic>;
          
          print('🔍 Processing booking ${bookingDoc.id}');
          print('   Data keys: ${bookingData.keys.join(', ')}');
          
          // Skip if agency_reference already exists
          if (bookingData.containsKey('agency_reference') && 
              bookingData['agency_reference'] != null) {
            print('⏭️ Booking ${bookingDoc.id} already has agency_reference');
            skippedCount++;
            continue;
          }
          
          // Get trip reference from booking
          final DocumentReference? tripRef = 
              bookingData['trip_reference'] as DocumentReference?;
          
          if (tripRef == null) {
            print('❌ Booking ${bookingDoc.id} has no trip_reference');
            errorCount++;
            continue;
          }
          
          print('   Trip reference: ${tripRef.path}');
          
          // Get the trip document to find agency_reference
          final DocumentSnapshot tripDoc = await tripRef.get();
          
          if (!tripDoc.exists) {
            print('❌ Trip ${tripRef.id} not found for booking ${bookingDoc.id}');
            errorCount++;
            continue;
          }
          
          final Map<String, dynamic> tripData = 
              tripDoc.data() as Map<String, dynamic>;
          final DocumentReference? agencyRef = 
              tripData['agency_reference'] as DocumentReference?;
          
          if (agencyRef == null) {
            print('⚠️ Trip ${tripRef.id} has no agency_reference');
            errorCount++;
            continue;
          }
          
          // Update the booking with agency_reference
          await bookingDoc.reference.update({
            'agency_reference': agencyRef,
          });
          
          print('✅ Updated booking ${bookingDoc.id} with agency ${agencyRef.path}');
          updatedCount++;
          
        } catch (e) {
          print('❌ Error updating booking ${bookingDoc.id}: $e');
          errorCount++;
        }
      }
      
      print('''
🎉 Migration completed!
📊 Statistics:
   • Updated: $updatedCount bookings
   • Skipped (already had agency_ref): $skippedCount bookings  
   • Errors: $errorCount bookings
      ''');
      
    } catch (e) {
      print('💥 Migration failed: $e');
      rethrow;
    }
  }
  
  /// Check migration status
  static Future<void> checkMigrationStatus() async {
    try {
      final QuerySnapshot allBookings = 
          await _firestore.collection('bookings').get();
      
      int withAgencyRef = 0;
      int withoutAgencyRef = 0;
      
      for (final DocumentSnapshot doc in allBookings.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('agency_reference') && 
            data['agency_reference'] != null) {
          withAgencyRef++;
        } else {
          withoutAgencyRef++;
        }
      }
      
      print('''
📊 Migration Status:
   • Total bookings: ${allBookings.docs.length}
   • With agency_reference: $withAgencyRef
   • Missing agency_reference: $withoutAgencyRef
      ''');
      
    } catch (e) {
      print('Error checking status: $e');
    }
  }
}