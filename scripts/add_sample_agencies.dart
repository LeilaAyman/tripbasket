import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

/// Script to add sample agencies to Firestore
void main() async {
  print('🚀 Starting to add sample agencies...');
  
  // Initialize Firebase with proper options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Get Firestore instance
  final firestore = FirebaseFirestore.instance;
  
  // Sample agencies data
  final List<Map<String, dynamic>> agencies = [
    {
      'name': 'Adventure World Travel',
      'description': 'Specializing in extreme adventures and outdoor experiences worldwide. From mountain climbing to deep-sea diving.',
      'logo': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
      'contact_email': 'info@adventureworld.com',
      'contact_phone': '+1-555-0123',
      'website': 'https://adventureworld.com',
      'location': 'New York, USA',
      'rating': 4.8,
      'total_trips': 25,
      'created_at': DateTime.now(),
      'status': 'active',
    },
    {
      'name': 'Luxury Escapes International',
      'description': 'Premium luxury travel experiences with 5-star accommodations and exclusive access to the world\'s finest destinations.',
      'logo': 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
      'contact_email': 'concierge@luxuryescapes.com',
      'contact_phone': '+1-555-0456',
      'website': 'https://luxuryescapes.com',
      'location': 'London, UK',
      'rating': 4.9,
      'total_trips': 18,
      'created_at': DateTime.now(),
      'status': 'active',
    },
    {
      'name': 'Cultural Heritage Tours',
      'description': 'Authentic cultural experiences and historical tours that connect you with local traditions and heritage sites.',
      'logo': 'https://images.unsplash.com/photo-1539650116574-75c0c6d73fb2?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
      'contact_email': 'explore@culturalheritage.com',
      'contact_phone': '+1-555-0789',
      'website': 'https://culturalheritage.com',
      'location': 'Rome, Italy',
      'rating': 4.7,
      'total_trips': 22,
      'created_at': DateTime.now(),
      'status': 'active',
    },
    {
      'name': 'Eco Travel Solutions',
      'description': 'Sustainable and eco-friendly travel options that minimize environmental impact while maximizing experiences.',
      'logo': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
      'contact_email': 'green@ecotravelsolutions.com',
      'contact_phone': '+1-555-0321',
      'website': 'https://ecotravelsolutions.com',
      'location': 'San Francisco, USA',
      'rating': 4.6,
      'total_trips': 15,
      'created_at': DateTime.now(),
      'status': 'active',
    },
    {
      'name': 'Family Fun Adventures',
      'description': 'Kid-friendly destinations and family-oriented activities designed to create unforgettable memories for all ages.',
      'logo': 'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
      'contact_email': 'family@funAdventures.com',
      'contact_phone': '+1-555-0654',
      'website': 'https://familyfunadventures.com',
      'location': 'Orlando, USA',
      'rating': 4.5,
      'total_trips': 20,
      'created_at': DateTime.now(),
      'status': 'active',
    },
  ];
  
  try {
    // Add each agency to Firestore
    final Map<String, DocumentReference> agencyRefs = {};
    
    for (int i = 0; i < agencies.length; i++) {
      final agency = agencies[i];
      DocumentReference docRef = await firestore.collection('agencies').add(agency);
      agencyRefs[agency['name']] = docRef;
      
      print('✅ Added agency ${i + 1}/5: "${agency['name']}"');
      print('   📄 Document ID: ${docRef.id}');
      print('   ⭐ Rating: ${agency['rating']}');
      print('   🗺️  Location: ${agency['location']}');
      print('   🎯 Trips: ${agency['total_trips']}');
      print('');
    }
    
    print('🎉 SUCCESS! All ${agencies.length} agencies added to database');
    print('');
    
    // Now update existing trips with agency references
    print('🔄 Updating existing trips with agency references...');
    
    final tripsSnapshot = await firestore.collection('trips').get();
    print('📋 Found ${tripsSnapshot.docs.length} trips to update');
    
    for (var doc in tripsSnapshot.docs) {
      final tripData = doc.data();
      final tripName = (tripData['title'] ?? '').toString().toLowerCase();
      final tripLocation = (tripData['location'] ?? '').toString().toLowerCase();
      
      DocumentReference? agencyRef;
      
      // Match trips to agencies based on content
      if (tripName.contains('adventure') || tripName.contains('dahab') || 
          tripLocation.contains('egypt') || tripLocation.contains('desert')) {
        agencyRef = agencyRefs['Adventure World Travel'];
      } else if (tripName.contains('paris') || tripName.contains('japan') || 
                 tripName.contains('tokyo') || tripName.contains('culture')) {
        agencyRef = agencyRefs['Cultural Heritage Tours'];
      } else if (tripName.contains('bali') || tripName.contains('beach') || 
                 tripLocation.contains('indonesia') || tripLocation.contains('island')) {
        agencyRef = agencyRefs['Eco Travel Solutions'];
      } else if (tripName.contains('luxury') || tripName.contains('premium')) {
        agencyRef = agencyRefs['Luxury Escapes International'];
      } else {
        // Default to Family Fun for other trips
        agencyRef = agencyRefs['Family Fun Adventures'];
      }
      
      if (agencyRef != null) {
        await doc.reference.update({
          'agency_reference': agencyRef,
        });
        
        print('✅ Updated trip "${tripData['title']}" with agency reference');
      }
    }
    
    print('🎉 All trips updated with agency references!');
    print('');
    print('📊 Summary:');
    print('   - Adventure World Travel (Adventure/Outdoor)');
    print('   - Luxury Escapes International (Luxury Travel)');
    print('   - Cultural Heritage Tours (Cultural/Historical)');
    print('   - Eco Travel Solutions (Sustainable Travel)');
    print('   - Family Fun Adventures (Family Travel)');
    print('');
    print('💡 Next steps:');
    print('   1. Test the agencies list page');
    print('   2. Verify agency trips filtering works');
    print('   3. Check agency-trip connections');
    
  } catch (e) {
    print('❌ Error adding agencies: $e');
  }
  
  print('🏁 Script completed - Sample agencies created!');
}
