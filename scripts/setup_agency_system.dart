import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/backend/schema/agencies_record.dart';
import '/backend/schema/users_record.dart';
import '/utils/agency_utils.dart';

/// Script to set up the agency system
/// This script helps create agencies with unique IDs and connect them to users
class AgencySetupScript {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Create a new agency with a unique ID
  Future<DocumentReference> createAgency({
    required String name,
    required String description,
    required String contactEmail,
    required String contactPhone,
    required String location,
    String? logo,
    String? website,
  }) async {
    try {
      // Generate unique agency ID
      final agencyId = AgencyUtils.generateAgencyId();
      
      // Create agency data
      final agencyData = createAgenciesRecordData(
        agencyId: agencyId,
        name: name,
        description: description,
        logo: logo ?? '',
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        website: website ?? '',
        location: location,
        rating: 0.0,
        totalTrips: 0,
        createdAt: DateTime.now(),
        status: 'active',
      );
      
      // Add to Firestore
      final agencyRef = await _firestore.collection('agency').add(agencyData);
      
      print('✅ Agency created successfully!');
      print('   ID: $agencyId');
      print('   Name: $name');
      print('   Reference: ${agencyRef.path}');
      
      return agencyRef;
    } catch (e) {
      print('❌ Error creating agency: $e');
      rethrow;
    }
  }
  
  /// Connect a user to an agency
  Future<void> connectUserToAgency({
    required String userEmail,
    required DocumentReference agencyRef,
    List<String> roles = const ['agency'],
  }) async {
    try {
      // Find user by email
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .get();
      
      if (userQuery.docs.isEmpty) {
        print('❌ User not found with email: $userEmail');
        return;
      }
      
      final userDoc = userQuery.docs.first;
      
      // Update user with agency reference and roles
      await userDoc.reference.update({
        'agency_reference': agencyRef,
        'role': roles,
      });
      
      print('✅ User connected to agency successfully!');
      print('   User: $userEmail');
      print('   Agency: ${agencyRef.path}');
      print('   Roles: $roles');
    } catch (e) {
      print('❌ Error connecting user to agency: $e');
      rethrow;
    }
  }
  
  /// Create a complete agency setup (agency + user connection)
  Future<void> setupCompleteAgency({
    required String agencyName,
    required String agencyDescription,
    required String contactEmail,
    required String contactPhone,
    required String location,
    required String userEmail,
    String? logo,
    String? website,
  }) async {
    try {
      print('🚀 Setting up agency: $agencyName');
      
      // 1. Create agency
      final agencyRef = await createAgency(
        name: agencyName,
        description: agencyDescription,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        location: location,
        logo: logo,
        website: website,
      );
      
      // 2. Connect user to agency
      await connectUserToAgency(
        userEmail: userEmail,
        agencyRef: agencyRef,
      );
      
      print('🎉 Agency setup completed successfully!');
      print('   Agency ID: ${agencyRef.id}');
      print('   User Email: $userEmail');
      
    } catch (e) {
      print('❌ Error in complete agency setup: $e');
      rethrow;
    }
  }
  
  /// List all agencies
  Future<void> listAgencies() async {
    try {
      final agenciesSnapshot = await _firestore.collection('agency').get();
      
      print('📋 Found ${agenciesSnapshot.docs.length} agencies:');
      print('');
      
      for (final doc in agenciesSnapshot.docs) {
        final agency = AgenciesRecord.fromSnapshot(doc);
        print('🏢 ${agency.name}');
        print('   ID: ${agency.agencyId}');
        print('   Location: ${agency.location}');
        print('   Status: ${agency.status}');
        print('   Reference: ${doc.reference.path}');
        print('');
      }
    } catch (e) {
      print('❌ Error listing agencies: $e');
    }
  }
  
  /// List users connected to agencies
  Future<void> listAgencyUsers() async {
    try {
      final usersSnapshot = await _firestore
          .collection('users')
          .where('agency_reference', isNull: false)
          .get();
      
      print('👥 Found ${usersSnapshot.docs.length} users connected to agencies:');
      print('');
      
      for (final doc in usersSnapshot.docs) {
        final user = UsersRecord.fromSnapshot(doc);
        print('👤 ${user.displayName} (${user.email})');
        print('   Agency Reference: ${user.agencyReference?.path ?? 'None'}');
        print('   Roles: ${user.role.join(', ')}');
        print('');
      }
    } catch (e) {
      print('❌ Error listing agency users: $e');
    }
  }
  
  /// Example usage
  Future<void> runExample() async {
    print('🚀 Running Agency Setup Example...\n');
    
    // Example 1: Create a travel agency
    await setupCompleteAgency(
      agencyName: 'Adventure Travel Co.',
      agencyDescription: 'Premium adventure travel experiences worldwide',
      contactEmail: 'info@adventure-travel.com',
      contactPhone: '+1-555-0123',
      location: 'New York, NY',
      userEmail: 'admin@adventure-travel.com',
      website: 'https://adventure-travel.com',
    );
    
    print('\n' + '='*50 + '\n');
    
    // Example 2: Create another agency
    await setupCompleteAgency(
      agencyName: 'Luxury Tours Ltd.',
      agencyDescription: 'Exclusive luxury travel experiences',
      contactEmail: 'contact@luxury-tours.com',
      contactPhone: '+1-555-0456',
      location: 'Los Angeles, CA',
      userEmail: 'manager@luxury-tours.com',
      website: 'https://luxury-tours.com',
    );
    
    print('\n' + '='*50 + '\n');
    
    // List all agencies and users
    await listAgencies();
    await listAgencyUsers();
  }
}

/// Main function to run the script
void main() async {
  try {
    final script = AgencySetupScript();
    await script.runExample();
  } catch (e) {
    print('❌ Script execution failed: $e');
  }
}
