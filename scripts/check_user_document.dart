import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Script to check user document status for debugging login issues
Future<void> main() async {
  await Firebase.initializeApp();
  
  final firestore = FirebaseFirestore.instance;
  
  // Check specific user document
  final email = 'adv@gmail.com';
  
  print('=== USER DOCUMENT CHECK FOR: $email ===');
  
  try {
    // Query users collection to find user by email
    final querySnapshot = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    
    if (querySnapshot.docs.isEmpty) {
      print('❌ NO USER DOCUMENT found for email: $email');
      print('This user may exist in Firebase Auth but not in Firestore');
      return;
    }
    
    final userDoc = querySnapshot.docs.first;
    final userData = userDoc.data();
    
    print('✅ User document found!');
    print('Document ID: ${userDoc.id}');
    print('User Data:');
    print('  - Email: ${userData['email']}');
    print('  - Display Name: ${userData['display_name']}');
    print('  - UID: ${userData['uid']}');
    print('  - Roles: ${userData['role']}');
    print('  - Agency Reference: ${userData['agency_reference']}');
    print('  - Created Time: ${userData['created_time']}');
    
    // Check access permissions
    final roles = userData['role'] as List<dynamic>? ?? [];
    final agencyRef = userData['agency_reference'];
    
    final isAdmin = roles.contains('admin');
    final isAgency = roles.contains('agency') || agencyRef != null;
    
    print('\n=== ACCESS ANALYSIS ===');
    print('Is Admin: $isAdmin');
    print('Is Agency: $isAgency');
    print('Has Access to Agency Dashboard: ${isAdmin || isAgency}');
    
    if (!isAdmin && !isAgency) {
      print('\n⚠️  LOGIN ISSUE IDENTIFIED:');
      print('User lacks required roles for agency dashboard access.');
      print('Solutions:');
      print('1. Add "admin" role to user');
      print('2. Add "agency" role to user');
      print('3. Assign agency reference to user');
    }
    
  } catch (e) {
    print('❌ Error checking user document: $e');
  }
}
