import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/backend/schema/agencies_record.dart';
import '/backend/schema/users_record.dart';
import '/backend/schema/trips_record.dart';
import '/utils/agency_utils.dart';

/// Test script to verify agency dashboard isolation
/// This script helps test that agencies only see their own trips
class AgencyDashboardTest {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Test the agency dashboard isolation
  Future<void> testAgencyIsolation() async {
    print('=== TESTING AGENCY DASHBOARD ISOLATION ===');
    
    try {
      // Create two test agencies
      final agency1Ref = await _createTestAgency('Test Agency 1', 'AGY_TEST_001');
      final agency2Ref = await _createTestAgency('Test Agency 2', 'AGY_TEST_002');
      
      // Create test trips for each agency
      await _createTestTrip('Trip from Agency 1', agency1Ref);
      await _createTestTrip('Another Trip from Agency 1', agency1Ref);
      await _createTestTrip('Trip from Agency 2', agency2Ref);
      
      // Test querying trips for each agency
      await _testAgencyTripsQuery(agency1Ref, 'Agency 1');
      await _testAgencyTripsQuery(agency2Ref, 'Agency 2');
      
      print('✅ Agency isolation test completed successfully!');
      
    } catch (e) {
      print('❌ Agency isolation test failed: $e');
    }
  }
  
  /// Create a test agency
  Future<DocumentReference> _createTestAgency(String name, String agencyId) async {
    final agencyData = createAgenciesRecordData(
      agencyId: agencyId,
      name: name,
      description: 'Test agency for dashboard isolation',
      contactEmail: 'test@${name.toLowerCase().replaceAll(' ', '')}.com',
      contactPhone: '+1234567890',
      location: 'Test City',
      rating: 4.5,
      totalTrips: 0,
      createdAt: DateTime.now(),
      status: 'active',
    );
    
    final agencyRef = await _firestore.collection('agency').add(agencyData);
    print('✅ Created test agency: $name (${agencyRef.path})');
    return agencyRef;
  }
  
  /// Create a test trip for an agency
  Future<void> _createTestTrip(String title, DocumentReference agencyRef) async {
    final tripData = createTripsRecordData(
      title: title,
      description: 'Test trip for agency dashboard isolation',
      location: 'Test Location',
      price: 100,
      quantity: 10,
      availableSeats: 8,
      rating: 4.0,
      createdAt: DateTime.now(),
      agencyReference: agencyRef,
    );
    
    await _firestore.collection('trips').add(tripData);
    print('✅ Created test trip: $title');
  }
  
  /// Test querying trips for a specific agency
  Future<void> _testAgencyTripsQuery(DocumentReference agencyRef, String agencyName) async {
    print('\n--- Testing trips query for $agencyName ---');
    
    final query = await _firestore
        .collection('trips')
        .where('agency_reference', isEqualTo: agencyRef)
        .get();
    
    print('Found ${query.docs.length} trips for $agencyName:');
    for (final doc in query.docs) {
      final trip = TripsRecord.fromSnapshot(doc);
      print('  - ${trip.title} (Agency: ${trip.agencyReference?.path})');
    }
    
    // Verify all trips belong to the correct agency
    for (final doc in query.docs) {
      final trip = TripsRecord.fromSnapshot(doc);
      if (trip.agencyReference?.path != agencyRef.path) {
        throw Exception('Trip "${trip.title}" does not belong to $agencyName!');
      }
    }
    
    print('✅ All trips correctly isolated to $agencyName');
  }
  
  /// Setup a test user with agency access
  Future<void> setupTestAgencyUser(String userEmail, String agencyName) async {
    print('\n=== SETTING UP TEST AGENCY USER ===');
    
    try {
      // Find or create agency
      final agencyQuery = await _firestore
          .collection('agency')
          .where('name', isEqualTo: agencyName)
          .get();
      
      DocumentReference agencyRef;
      if (agencyQuery.docs.isEmpty) {
        // Create new agency
        final agencyId = AgencyUtils.generateAgencyId();
        final agencyData = createAgenciesRecordData(
          agencyId: agencyId,
          name: agencyName,
          description: 'Test agency for $userEmail',
          contactEmail: userEmail,
          contactPhone: '+1234567890',
          location: 'Test City',
          rating: 0.0,
          totalTrips: 0,
          createdAt: DateTime.now(),
          status: 'active',
        );
        
        agencyRef = await _firestore.collection('agency').add(agencyData);
        print('✅ Created new agency: $agencyName');
      } else {
        agencyRef = agencyQuery.docs.first.reference;
        print('✅ Found existing agency: $agencyName');
      }
      
      // Find user and update with agency reference
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .get();
      
      if (userQuery.docs.isEmpty) {
        print('❌ User not found: $userEmail');
        print('Please make sure the user is registered first.');
        return;
      }
      
      final userDoc = userQuery.docs.first;
      await userDoc.reference.update({
        'agency_reference': agencyRef,
        'role': ['agency'], // Set agency role
      });
      
      print('✅ Updated user $userEmail with agency access');
      print('   Agency: $agencyName');
      print('   Agency Reference: ${agencyRef.path}');
      print('   Roles: [agency]');
      
    } catch (e) {
      print('❌ Error setting up agency user: $e');
    }
  }
  
  /// Clean up test data
  Future<void> cleanupTestData() async {
    print('\n=== CLEANING UP TEST DATA ===');
    
    try {
      // Delete test agencies
      final agenciesQuery = await _firestore
          .collection('agency')
          .where('name', whereIn: ['Test Agency 1', 'Test Agency 2'])
          .get();
      
      for (final doc in agenciesQuery.docs) {
        await doc.reference.delete();
        print('✅ Deleted test agency: ${doc.data()['name']}');
      }
      
      // Delete test trips
      final tripsQuery = await _firestore
          .collection('trips')
          .where('title', whereIn: [
            'Trip from Agency 1',
            'Another Trip from Agency 1',
            'Trip from Agency 2'
          ])
          .get();
      
      for (final doc in tripsQuery.docs) {
        await doc.reference.delete();
        print('✅ Deleted test trip: ${doc.data()['title']}');
      }
      
      print('✅ Test data cleanup completed');
      
    } catch (e) {
      print('❌ Error during cleanup: $e');
    }
  }
}

/// Example usage
void main() async {
  final tester = AgencyDashboardTest();
  
  // Example 1: Test agency isolation
  await tester.testAgencyIsolation();
  
  // Example 2: Setup a user with agency access
  // Replace with actual user email
  await tester.setupTestAgencyUser('your-email@example.com', 'Your Agency Name');
  
  // Example 3: Clean up test data (optional)
  // await tester.cleanupTestData();
}
