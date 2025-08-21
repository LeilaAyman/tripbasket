import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';

/// Script to fix agency references for users who should have agency access
/// This script helps resolve the issue where agency dashboard appears empty
/// because users don't have proper agency_reference set in their user document.

Future<void> main() async {
  print('🔧 Starting Agency Reference Fix Script...');
  
  // Initialize Firebase (you'll need to configure this for your project)
  await Firebase.initializeApp();
  
  final firestore = FirebaseFirestore.instance;
  
  try {
    // Step 1: Find all agencies
    print('\n📋 Step 1: Finding all agencies...');
    final agenciesSnapshot = await firestore.collection('agencies').get();
    print('Found ${agenciesSnapshot.docs.length} agencies');
    
    for (final agencyDoc in agenciesSnapshot.docs) {
      final agencyData = agencyDoc.data();
      print('  - Agency: ${agencyData['name'] ?? agencyDoc.id}');
    }
    
    // Step 2: Find users with 'agency' role but no agency_reference
    print('\n🔍 Step 2: Finding users with agency role but no agency reference...');
    final usersSnapshot = await firestore.collection('users').get();
    
    final problematicUsers = <QueryDocumentSnapshot>[];
    
    for (final userDoc in usersSnapshot.docs) {
      final userData = userDoc.data();
      final roles = List<String>.from(userData['role'] ?? []);
      final agencyRef = userData['agency_reference'];
      
      if (roles.contains('agency') && agencyRef == null) {
        problematicUsers.add(userDoc);
        print('  ⚠️  User ${userData['email'] ?? userDoc.id} has agency role but no agency_reference');
      }
    }
    
    if (problematicUsers.isEmpty) {
      print('✅ All agency users have proper agency references!');
      return;
    }
    
    // Step 3: Interactive fix
    print('\n🔨 Step 3: Fix Options');
    print('Found ${problematicUsers.length} users that need fixing.');
    print('');
    print('Choose an option:');
    print('1. Create new agency for each user');
    print('2. Assign users to existing agency');
    print('3. Show detailed analysis only');
    print('4. Exit');
    
    stdout.write('Enter choice (1-4): ');
    final choice = stdin.readLineSync();
    
    switch (choice) {
      case '1':
        await createNewAgenciesForUsers(firestore, problematicUsers);
        break;
      case '2':
        await assignUsersToExistingAgency(firestore, problematicUsers, agenciesSnapshot.docs);
        break;
      case '3':
        await showDetailedAnalysis(firestore);
        break;
      case '4':
      default:
        print('Exiting...');
        break;
    }
    
  } catch (e) {
    print('❌ Error: $e');
  }
}

Future<void> createNewAgenciesForUsers(FirebaseFirestore firestore, List<QueryDocumentSnapshot> users) async {
  print('\n🏢 Creating new agencies for users...');
  
  for (final userDoc in users) {
    final userData = userDoc.data() as Map<String, dynamic>;
    final userEmail = userData['email'] ?? 'Unknown';
    final userName = userData['name'] ?? userData['display_name'] ?? 'Unknown';
    
    try {
      // Create new agency
      final agencyData = {
        'name': '$userName\'s Agency',
        'description': 'Auto-created agency for $userEmail',
        'created_at': FieldValue.serverTimestamp(),
        'owner_email': userEmail,
        'status': 'active',
      };
      
      final agencyRef = await firestore.collection('agencies').add(agencyData);
      print('  ✅ Created agency: ${agencyData['name']} (ID: ${agencyRef.id})');
      
      // Update user with agency reference
      await userDoc.reference.update({
        'agency_reference': agencyRef,
      });
      print('  ✅ Updated user $userEmail with agency reference');
      
    } catch (e) {
      print('  ❌ Failed to create agency for $userEmail: $e');
    }
  }
}

Future<void> assignUsersToExistingAgency(FirebaseFirestore firestore, List<QueryDocumentSnapshot> users, List<QueryDocumentSnapshot> agencies) async {
  if (agencies.isEmpty) {
    print('❌ No existing agencies found. Create one first.');
    return;
  }
  
  print('\n📋 Available agencies:');
  for (int i = 0; i < agencies.length; i++) {
    final agencyData = agencies[i].data() as Map<String, dynamic>;
    print('  ${i + 1}. ${agencyData['name'] ?? agencies[i].id}');
  }
  
  stdout.write('Select agency number (1-${agencies.length}): ');
  final agencyChoice = stdin.readLineSync();
  final agencyIndex = int.tryParse(agencyChoice ?? '') ?? 1;
  
  if (agencyIndex < 1 || agencyIndex > agencies.length) {
    print('❌ Invalid agency selection');
    return;
  }
  
  final selectedAgency = agencies[agencyIndex - 1];
  final selectedAgencyData = selectedAgency.data() as Map<String, dynamic>;
  
  print('\n🔗 Assigning users to: ${selectedAgencyData['name']}');
  
  for (final userDoc in users) {
    final userData = userDoc.data() as Map<String, dynamic>;
    final userEmail = userData['email'] ?? 'Unknown';
    
    try {
      await userDoc.reference.update({
        'agency_reference': selectedAgency.reference,
      });
      print('  ✅ Updated user $userEmail');
    } catch (e) {
      print('  ❌ Failed to update user $userEmail: $e');
    }
  }
}

Future<void> showDetailedAnalysis(FirebaseFirestore firestore) async {
  print('\n📊 Detailed Analysis');
  print('=' * 50);
  
  // Analyze users
  final usersSnapshot = await firestore.collection('users').get();
  print('👥 Users Analysis:');
  
  int totalUsers = usersSnapshot.docs.length;
  int agencyUsers = 0;
  int usersWithAgencyRef = 0;
  int problematicUsers = 0;
  
  for (final userDoc in usersSnapshot.docs) {
    final userData = userDoc.data();
    final roles = List<String>.from(userData['role'] ?? []);
    final agencyRef = userData['agency_reference'];
    final email = userData['email'] ?? userDoc.id;
    
    if (roles.contains('agency')) {
      agencyUsers++;
      if (agencyRef != null) {
        usersWithAgencyRef++;
      } else {
        problematicUsers++;
        print('  ⚠️  $email - Agency role but no reference');
      }
    }
  }
  
  print('  Total Users: $totalUsers');
  print('  Agency Role Users: $agencyUsers');
  print('  Agency Users with Reference: $usersWithAgencyRef');
  print('  Problematic Users: $problematicUsers');
  
  // Analyze trips
  final tripsSnapshot = await firestore.collection('trips').get();
  print('\n🎯 Trips Analysis:');
  
  int totalTrips = tripsSnapshot.docs.length;
  int tripsWithAgencyRef = 0;
  int orphanedTrips = 0;
  
  final agencyTripCounts = <String, int>{};
  
  for (final tripDoc in tripsSnapshot.docs) {
    final tripData = tripDoc.data();
    final agencyRef = tripData['agency_reference'] as DocumentReference?;
    
    if (agencyRef != null) {
      tripsWithAgencyRef++;
      final agencyId = agencyRef.id;
      agencyTripCounts[agencyId] = (agencyTripCounts[agencyId] ?? 0) + 1;
    } else {
      orphanedTrips++;
    }
  }
  
  print('  Total Trips: $totalTrips');
  print('  Trips with Agency Reference: $tripsWithAgencyRef');
  print('  Orphaned Trips: $orphanedTrips');
  
  if (agencyTripCounts.isNotEmpty) {
    print('  Trips per Agency:');
    agencyTripCounts.forEach((agencyId, count) {
      print('    $agencyId: $count trips');
    });
  }
  
  // Analyze agencies
  final agenciesSnapshot = await firestore.collection('agencies').get();
  print('\n🏢 Agencies Analysis:');
  print('  Total Agencies: ${agenciesSnapshot.docs.length}');
  
  for (final agencyDoc in agenciesSnapshot.docs) {
    final agencyData = agencyDoc.data();
    final name = agencyData['name'] ?? agencyDoc.id;
    final tripCount = agencyTripCounts[agencyDoc.id] ?? 0;
    print('    $name: $tripCount trips');
  }
}