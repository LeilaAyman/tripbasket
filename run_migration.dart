import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Quick migration runner script to add agency_reference to existing bookings

Future<void> main() async {
  print('🔥 Initializing Firebase...');
  
  // Initialize Firebase for web configuration
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCX0GVpCxSNBRyUsmSqWlhg_x5lVazIBx4",
      authDomain: "tripbasket-sctkxj.firebaseapp.com",
      projectId: "tripbasket-sctkxj",
      storageBucket: "tripbasket-sctkxj.firebasestorage.app",
      messagingSenderId: "950681576261",
      appId: "1:950681576261:web:bcac7dfa1ec12b33f5942c",
      measurementId: "G-1458DL741S"
    )
  );
  
  print('✅ Firebase initialized');
  
  await migrateBookingAgencyReferences();
}

/// Main migration function
Future<void> migrateBookingAgencyReferences() async {
  print('🚀 Starting booking migration...');
  
  try {
    final firestore = FirebaseFirestore.instance;
    
    // Get all bookings
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
        
        print('🔍 Processing booking ${bookingDoc.id}');
        print('   Data: ${bookingData.keys.join(', ')}');
        
        // Skip if agency_reference already exists
        if (bookingData.containsKey('agency_reference') && 
            bookingData['agency_reference'] != null) {
          print('⏭️ Booking ${bookingDoc.id} already has agency_reference: ${bookingData['agency_reference']}');
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
        
        print('   Trip reference: ${tripRef.path}');
        
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