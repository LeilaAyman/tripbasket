import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

Future<void> main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  
  print('🧹 Starting cart cleanup...');
  
  try {
    // Get all cart items
    final cartSnapshot = await firestore.collection('cart').get();
    print('📦 Found ${cartSnapshot.docs.length} cart items');
    
    int deletedCount = 0;
    int validCount = 0;
    
    for (final cartDoc in cartSnapshot.docs) {
      final cartData = cartDoc.data();
      final tripReference = cartData['tripReference'] as DocumentReference?;
      
      if (tripReference == null) {
        print('❌ Cart item ${cartDoc.id} has null trip reference, deleting...');
        await cartDoc.reference.delete();
        deletedCount++;
        continue;
      }
      
      // Check if the referenced trip still exists
      try {
        final tripDoc = await tripReference.get();
        if (!tripDoc.exists) {
          print('❌ Trip ${tripReference.id} no longer exists, deleting cart item ${cartDoc.id}...');
          await cartDoc.reference.delete();
          deletedCount++;
        } else {
          print('✅ Cart item ${cartDoc.id} references valid trip ${tripReference.id}');
          validCount++;
        }
      } catch (e) {
        print('❌ Error checking trip ${tripReference.id}, deleting cart item ${cartDoc.id}: $e');
        await cartDoc.reference.delete();
        deletedCount++;
      }
    }
    
    print('🎉 Cleanup completed!');
    print('✅ Valid cart items: $validCount');
    print('❌ Deleted orphaned items: $deletedCount');
    
  } catch (e) {
    print('💥 Error during cleanup: $e');
  }
  
  exit(0);
}