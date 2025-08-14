import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Create a new trip document
  await addNewTrip();
  
  print('New trip added successfully!');
}

Future<void> addNewTrip() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  // Create the new trip data
  Map<String, dynamic> newTripData = {
    'title': 'Bali Paradise',
    'location': 'Bali, Indonesia',
    'description': 'Experience the magical beauty of Bali with pristine beaches, ancient temples, and vibrant culture.',
    'price': 800,
    'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2b/Tanah_Lot_Temple%2C_Bali%2C_Indonesia.jpg/1280px-Tanah_Lot_Temple%2C_Bali%2C_Indonesia.jpg',
    'available_seats': 25,
    'start_date': DateTime(2025, 10, 15),
    'end_date': DateTime(2025, 10, 22),
    'status': 'approved',
    'itenarary': [
      'Day 1: Arrival in Denpasar - Transfer to Ubud + Traditional welcome dinner',
      'Day 2: Cultural Tour - Tegallalang Rice Terraces + Sacred Monkey Forest + Art villages',
      'Day 3: Temple Hopping - Tanah Lot Temple + Uluwatu Temple + Kecak Fire Dance',
      'Day 4: Adventure Day - White water rafting + Sekumpul Waterfall trek',
      'Day 5: Beach Day - Seminyak Beach + Water sports + Beach club relaxation',
      'Day 6: Mount Batur Sunrise Trek + Hot springs + Coffee plantation tour',
      'Day 7: Shopping & Spa Day - Traditional markets + Balinese spa treatment + Departure'
    ]
  };
  
  try {
    // Add the new trip to the 'trips' collection
    DocumentReference docRef = await firestore.collection('trips').add(newTripData);
    print('Trip added with ID: ${docRef.id}');
    print('Trip details:');
    print('  Title: ${newTripData['title']}');
    print('  Location: ${newTripData['location']}');
    print('  Price: \$${newTripData['price']}');
    print('  Duration: ${newTripData['start_date']} to ${newTripData['end_date']}');
    print('  Available seats: ${newTripData['available_seats']}');
  } catch (e) {
    print('Error adding trip: $e');
  }
}
