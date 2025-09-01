import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  print('Initializing Firebase...');
  
  try {
    // Initialize Firebase with minimal config for script execution
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "your-api-key", // These will be ignored in script mode
        appId: "your-app-id",
        messagingSenderId: "your-sender-id", 
        projectId: "tripbasket-sctkxj", // Your actual project ID
      ),
    );
    
    print('Firebase initialized successfully!');
    
    final firestore = FirebaseFirestore.instance;
    final agencyCollection = firestore.collection('agency');
    
    print('Adding sample agencies...');
    
    // Agency 1: Adventure World Travel
    await agencyCollection.doc('adventure_world_travel').set({
      'name': 'Adventure World Travel',
      'description': 'Specializing in thrilling outdoor adventures and extreme sports experiences around the globe.',
      'logo': '',
      'contact_email': 'info@adventureworld.com',
      'contact_phone': '+1-555-ADVENTURE',
      'website': 'https://www.adventureworld.com',
      'location': 'Global',
      'rating': 4.7,
      'total_trips': 45,
      'created_at': FieldValue.serverTimestamp(),
      'status': 'active',
    });
    print('✅ Added Adventure World Travel');
    
    // Agency 2: Luxury Escapes International
    await agencyCollection.doc('luxury_escapes_intl').set({
      'name': 'Luxury Escapes International',
      'description': 'Premium luxury travel experiences with 5-star accommodations and personalized service.',
      'logo': '',
      'contact_email': 'bookings@luxuryescapes.com',
      'contact_phone': '+1-555-LUXURY',
      'website': 'https://www.luxuryescapes.com',
      'location': 'International',
      'rating': 4.9,
      'total_trips': 28,
      'created_at': FieldValue.serverTimestamp(),
      'status': 'active',
    });
    print('✅ Added Luxury Escapes International');
    
    // Agency 3: Cultural Heritage Tours
    await agencyCollection.doc('cultural_heritage_tours').set({
      'name': 'Cultural Heritage Tours',
      'description': 'Authentic cultural experiences and historical site visits with expert local guides.',
      'logo': '',
      'contact_email': 'explore@culturalheritage.com',
      'contact_phone': '+1-555-CULTURE',
      'website': 'https://www.culturalheritage.com',
      'location': 'Worldwide',
      'rating': 4.5,
      'total_trips': 62,
      'created_at': FieldValue.serverTimestamp(),
      'status': 'active',
    });
    print('✅ Added Cultural Heritage Tours');
    
    // Agency 4: Eco Travel Solutions
    await agencyCollection.doc('eco_travel_solutions').set({
      'name': 'Eco Travel Solutions',
      'description': 'Sustainable and eco-friendly travel options that protect and preserve natural environments.',
      'logo': '',
      'contact_email': 'green@ecotravelsolutions.com',
      'contact_phone': '+1-555-ECOTRIP',
      'website': 'https://www.ecotravelsolutions.com',
      'location': 'Global',
      'rating': 4.6,
      'total_trips': 39,
      'created_at': FieldValue.serverTimestamp(),
      'status': 'active',
    });
    print('✅ Added Eco Travel Solutions');
    
    // Agency 5: Family Fun Adventures
    await agencyCollection.doc('family_fun_adventures').set({
      'name': 'Family Fun Adventures',
      'description': 'Family-friendly trips with activities suitable for all ages and memorable experiences for everyone.',
      'logo': '',
      'contact_email': 'fun@familyadventures.com',
      'contact_phone': '+1-555-FAMILY',
      'website': 'https://www.familyadventures.com',
      'location': 'Family Destinations',
      'rating': 4.4,
      'total_trips': 51,
      'created_at': FieldValue.serverTimestamp(),
      'status': 'active',
    });
    print('✅ Added Family Fun Adventures');
    
    print('\n🎉 Successfully added all 5 sample agencies to the database!');
    print('You can now test the agencies list and search functionality in your app.');
    
  } catch (e) {
    print('❌ Error: $e');
    print('\nIf you see Firebase initialization errors, you may need to:');
    print('1. Run this from within your Flutter app context, or');
    print('2. Add the agencies manually through Firebase console as described in MANUAL_AGENCY_SETUP.md');
  }
}
