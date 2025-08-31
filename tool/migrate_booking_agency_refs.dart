import 'package:cloud_firestore/cloud_firestore.dart';

/// Migration script to add agency_reference to existing bookings
/// This script will:
/// 1. Query all bookings without agency_reference
/// 2. Look up the trip for each booking to get the agency_reference  
/// 3. Update the booking with the correct agency_reference
/// 
/// Run this script through Firebase Functions or a similar server environment

class BookingMigrationScript {
  
  /// Main migration function
  static Future<void> migrateBookingAgencyReferences() async {
    print('🚀 Starting booking migration...');
    
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Get all bookings that don't have agency_reference field
      final bookingsQuery = await firestore
          .collection('bookings')
          .get();
      
      print('📊 Found ${bookingsQuery.docs.length} bookings to check');
      
      int updatedCount = 0;
      int skippedCount = 0;
      int errorCount = 0;
      
      for (final bookingDoc in bookingsQuery.docs) {
        try {
          final bookingData = bookingDoc.data();
          
          // Skip if agency_reference already exists
          if (bookingData.containsKey('agency_reference') && 
              bookingData['agency_reference'] != null) {
            skippedCount++;
            continue;
          }
          
          // Get trip reference from booking
          final tripRef = bookingData['trip_reference'] as DocumentReference?;
          
          if (tripRef == null) {
            print('❌ Booking ${bookingDoc.id} has no trip_reference');
            errorCount++;
            continue;
          }
          
          // Get the trip document to find agency_reference
          final tripDoc = await tripRef.get();
          
          if (!tripDoc.exists) {
            print('❌ Trip ${tripRef.id} not found for booking ${bookingDoc.id}');
            errorCount++;
            continue;
          }
          
          final tripData = tripDoc.data() as Map<String, dynamic>;
          final agencyRef = tripData['agency_reference'] as DocumentReference?;
          
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
    }
  }
  
  /// Check migration status
  static Future<void> checkMigrationStatus() async {
    try {
      final firestore = FirebaseFirestore.instance;
      
      final allBookings = await firestore.collection('bookings').get();
      final bookingsWithAgency = await firestore
          .collection('bookings')
          .where('agency_reference', isNotEqualTo: null)
          .get();
      
      print('''
📊 Migration Status:
   • Total bookings: ${allBookings.docs.length}
   • With agency_reference: ${bookingsWithAgency.docs.length}
   • Missing agency_reference: ${allBookings.docs.length - bookingsWithAgency.docs.length}
      ''');
      
    } catch (e) {
      print('Error checking status: $e');
    }
  }
}

/// Run the migration
void main() async {
  print('📋 Booking Agency Reference Migration Script');
  print('This script should be run in a Firebase Functions environment');
  print('or with proper Firebase initialization.');
  print('');
  print('To run manually:');
  print('1. Copy the migration logic to a Firebase Function');
  print('2. Deploy and trigger the function');
  print('3. Or run through Firebase CLI with proper auth');
  
  // Uncomment to run (requires Firebase initialization):
  // await BookingMigrationScript.checkMigrationStatus();
  // await BookingMigrationScript.migrateBookingAgencyReferences();
}