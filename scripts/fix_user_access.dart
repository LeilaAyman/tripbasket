import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Script to fix user access by assigning admin role
Future<void> main() async {
  await Firebase.initializeApp();
  
  final firestore = FirebaseFirestore.instance;
  final email = 'adv@gmail.com';
  
  print('=== FIXING USER ACCESS FOR: $email ===');
  
  try {
    // Find user document by email
    final querySnapshot = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    
    if (querySnapshot.docs.isEmpty) {
      print('❌ User document not found. User may need to login once first to create the document.');
      return;
    }
    
    final userDoc = querySnapshot.docs.first;
    final currentData = userDoc.data();
    
    print('Current user data:');
    print('  - Email: ${currentData['email']}');
    print('  - Current roles: ${currentData['role']}');
    
    // Update user with admin role
    await userDoc.reference.update({
      'role': FieldValue.arrayUnion(['admin']),
    });
    
    print('✅ Successfully added admin role to user!');
    print('User should now have access to the agency dashboard.');
    
    // Verify the update
    final updatedDoc = await userDoc.reference.get();
    final updatedData = updatedDoc.data() as Map<String, dynamic>;
    print('Updated roles: ${updatedData['role']}');
    
  } catch (e) {
    print('❌ Error updating user: $e');
  }
}
