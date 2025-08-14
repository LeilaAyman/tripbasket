import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

void main() async {
  if (kDebugMode) {
    print('🚀 Starting to add new Bali trip to database...');
  }
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  if (kDebugMode) {
    print('✅ Firebase initialized');
  }
  
  // Get reference to trips collection
  final tripsCollection = FirebaseFirestore.instance.collection('trips');
  
  // Create new Bali trip data
  final newTrip = {
    'title': 'Bali Adventure',
    'description': 'Discover the beauty of Bali with temples, beaches, and culture.',
    'location': 'Bali, Indonesia',
    'price': 800,
    'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f3/Pura_Ulun_Danu_Bratan.jpg/1280px-Pura_Ulun_Danu_Bratan.jpg',
    'itenarary': [
      'Day 1: Arrival in Bali - Ubud rice terraces + Welcome dinner',
      'Day 2: Temple Tour - Tanah Lot + Uluwatu Temple + Traditional dance',
      'Day 3: Beach Day - Seminyak beach + Water sports + Sunset dinner',
      'Day 4: Cultural Experience - Monkey Forest + Art villages + Cooking class',
      'Day 5: Mount Batur sunrise hike + Hot springs + Departure'
    ],
    'available_seats': 18,
    'status': 'approved',
    'start_date': DateTime(2025, 10, 1),
    'end_date': DateTime(2025, 10, 5),
  };
  
  try {
    // Add the trip to Firestore
    DocumentReference docRef = await tripsCollection.add(newTrip);
    
    if (kDebugMode) {
      print('🎉 SUCCESS! New Bali trip added to database');
      print('📄 Document ID: ${docRef.id}');
      print('🏝️ Trip: ${newTrip['title']}');
      print('💰 Price: \$${newTrip['price']}');
      print('📍 Location: ${newTrip['location']}');
    }
    
    // Verify the trip was added by reading it back
    DocumentSnapshot doc = await docRef.get();
    if (doc.exists) {
      if (kDebugMode) {
        print('✅ Verification: Trip successfully saved in database');
      }
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (kDebugMode) {
        print('📋 Saved data: ${data['title']} - \$${data['price']}');
      }
    }
    
  } catch (e) {
    if (kDebugMode) {
      print('❌ Error adding trip: $e');
    }
  }
  
  if (kDebugMode) {
    print('🏁 Script completed - Bali Adventure trip added!');
  }
}
