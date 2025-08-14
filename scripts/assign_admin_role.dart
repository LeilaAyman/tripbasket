import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Get Firestore instance
  final firestore = FirebaseFirestore.instance;
  
  // Replace this with your user's email or UID
  final String userEmail = 'David.j@gmail.com'; // Update this to your email
  
  try {
    // Query for user document by email
    final QuerySnapshot userQuery = await firestore
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .get();
    
    if (userQuery.docs.isEmpty) {
      print('❌ User not found with email: $userEmail');
      print('Make sure the email matches exactly what\'s in your Firebase Auth.');
      return;
    }
    
    // Get the user document
    final DocumentSnapshot userDoc = userQuery.docs.first;
    final String userId = userDoc.id;
    
    print('✅ Found user: $userId');
    print('Current data: ${userDoc.data()}');
    
    // Update the user document to add admin role
    await firestore.collection('users').doc(userId).update({
      'role': ['admin'] // This creates an array with 'admin' role
    });
    
    print('✅ Successfully assigned admin role to user: $userEmail');
    print('🎉 You now have admin privileges!');
    
    // Verify the update
    final DocumentSnapshot updatedDoc = await firestore
        .collection('users')
        .doc(userId)
        .get();
    
    print('Updated user data: ${updatedDoc.data()}');
    
  } catch (e) {
    print('❌ Error assigning admin role: $e');
  }
}
