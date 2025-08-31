import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Simple script to check existing bookings and their agency references
/// This will help debug the permission issues
void main() async {
  print('🔍 Checking bookings collection for agency_reference field...');
  
  try {
    // This would need to be run with proper Firebase initialization
    // For now, this is a template for manual checking
    
    print('''
📋 To check your bookings collection manually:

1. Go to Firebase Console → Firestore Database
2. Navigate to the "bookings" collection
3. Check if existing bookings have the "agency_reference" field
4. If not, you need to migrate existing bookings

Expected fields in each booking document:
- user_reference: DocumentReference to users collection
- trip_reference: DocumentReference to trips collection  
- agency_reference: DocumentReference to agency collection (NEW)
- booking_status: "pending_agency_approval", "confirmed", "denied", etc.
- payment_status: "completed", "pending", "failed"
- created_at: Timestamp
- total_amount: Number

🚨 If agency_reference is missing from existing bookings:
   Run the migration script or manually add agency references
''');

  } catch (e) {
    print('Error: $e');
  }
}