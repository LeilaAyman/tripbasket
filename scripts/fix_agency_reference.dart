import 'package:cloud_firestore/cloud_firestore.dart';

/// Script to fix agency reference fields in Firestore
Future<void> main() async {
  final firestore = FirebaseFirestore.instance;
  
  print('🔧 Fixing agency reference fields...');
  
  try {
    // Get the agency user document
    final userRef = firestore.collection('users').doc('ECsowJa7vEarctaJq6LdFgSWHXV2');
    final userDoc = await userRef.get();
    
    if (!userDoc.exists) {
      print('❌ User document not found');
      return;
    }
    
    print('📄 Current user data: ${userDoc.data()}');
    
    // Get the agency document reference
    final agencyRef = firestore.collection('agencies').doc('adventure_world_travel');
    final agencyDoc = await agencyRef.get();
    
    if (!agencyDoc.exists) {
      print('❌ Agency document not found');
      return;
    }
    
    print('🏢 Agency exists: ${agencyDoc.id}');
    
    // Update the user document with proper agency reference
    await userRef.update({
      'agency_reference': agencyRef,
    });
    
    print('✅ Updated user document with agency reference');
    
    // Verify the update
    final updatedDoc = await userRef.get();
    print('📄 Updated user data: ${updatedDoc.data()}');
    
    print('🎉 Agency reference fix completed!');
    
  } catch (e) {
    print('❌ Error: $e');
  }
}