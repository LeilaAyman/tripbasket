import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> connectTripsToAgencies() async {
  final firestore = FirebaseFirestore.instance;
  final tripsCollection = firestore.collection('trips');
  final agencyCollection = firestore.collection('agency');
  
  print('Connecting trips to agencies...');
  
  try {
    // Get all trips
    final tripsSnapshot = await tripsCollection.get();
    final trips = tripsSnapshot.docs;
    
    // Get agency references
    final adventureRef = agencyCollection.doc('adventure_world_travel');
    final luxuryRef = agencyCollection.doc('luxury_escapes_intl');
    final culturalRef = agencyCollection.doc('cultural_heritage_tours');
    final ecoRef = agencyCollection.doc('eco_travel_solutions');
    final familyRef = agencyCollection.doc('family_fun_adventures');
    
    print('Found ${trips.length} trips to connect...');
    
    // Connect trips to agencies based on their characteristics
    for (int i = 0; i < trips.length; i++) {
      final trip = trips[i];
      final tripData = trip.data() as Map<String, dynamic>;
      final tripName = (tripData['name'] ?? '').toString().toLowerCase();
      final tripDescription = (tripData['description'] ?? '').toString().toLowerCase();
      
      DocumentReference? agencyRef;
      
      // Assign agencies based on trip content
      if (tripName.contains('adventure') || tripName.contains('hiking') || 
          tripName.contains('trek') || tripDescription.contains('adventure') ||
          tripDescription.contains('outdoor') || tripDescription.contains('extreme')) {
        agencyRef = adventureRef;
      } else if (tripName.contains('luxury') || tripName.contains('premium') ||
                 tripDescription.contains('luxury') || tripDescription.contains('5-star') ||
                 tripDescription.contains('premium')) {
        agencyRef = luxuryRef;
      } else if (tripName.contains('heritage') || tripName.contains('cultural') ||
                 tripName.contains('history') || tripDescription.contains('cultural') ||
                 tripDescription.contains('heritage') || tripDescription.contains('historical')) {
        agencyRef = culturalRef;
      } else if (tripName.contains('eco') || tripName.contains('green') ||
                 tripName.contains('nature') || tripDescription.contains('eco') ||
                 tripDescription.contains('sustainable') || tripDescription.contains('nature')) {
        agencyRef = ecoRef;
      } else if (tripName.contains('family') || tripDescription.contains('family') ||
                 tripDescription.contains('kids') || tripDescription.contains('children')) {
        agencyRef = familyRef;
      } else {
        // Distribute remaining trips evenly among agencies
        final agencies = [adventureRef, luxuryRef, culturalRef, ecoRef, familyRef];
        agencyRef = agencies[i % agencies.length];
      }
      
      // Update the trip with agency reference
      await trip.reference.update({
        'agency_reference': agencyRef,
      });
      
      print('✅ Connected "${tripData['name']}" to agency');
    }
    
    print('🎉 Successfully connected all trips to agencies!');
    
  } catch (e) {
    print('❌ Error connecting trips to agencies: $e');
  }
}
