import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Script to update trip itineraries in Firestore
/// Run this to add proper itinerary arrays to Japan and Paris trips
void main() async {
  print('🚀 Starting itinerary update script...');
  
  // Initialize Firebase (make sure this matches your firebase config)
  await Firebase.initializeApp();
  
  // Get Firestore instance
  final firestore = FirebaseFirestore.instance;
  
  // Define itineraries for each trip
  final Map<String, List<String>> tripItineraries = {
    
    // Japan Trip Itinerary
    'japan': [
      'Day 1: Arrival in Tokyo - Check into hotel in Shibuya + Evening at Tokyo Skytree',
      'Day 2: Traditional Tokyo - Senso-ji Temple + Asakusa district + Imperial Palace Gardens',
      'Day 3: Modern Tokyo - Harajuku + Shibuya Crossing + Robot Restaurant show',
      'Day 4: Day trip to Mount Fuji - 5th Station + Lake Kawaguchi + Traditional onsen',
      'Day 5: Tech & Culture - TeamLab Digital Art Museum + Ginza shopping + Farewell dinner'
    ],
    
    // Paris Trip Itinerary  
    'paris': [
      'Day 1: Arrival in Paris - Eiffel Tower visit + Seine river cruise + Welcome dinner',
      'Day 2: Art & Culture - Louvre Museum + Tuileries Garden + Champs-Élysées shopping',
      'Day 3: Royal Experience - Versailles Palace day trip + Gardens tour',
      'Day 4: Montmartre Adventure - Sacré-Cœur + Artists\' Quarter + Moulin Rouge show',
      'Day 5: Final Exploration - Notre-Dame area + Latin Quarter + Departure'
    ],
  };
  
  try {
    // Query all trips to find the ones we need to update
    final QuerySnapshot tripsSnapshot = await firestore.collection('trips').get();
    
    print('📋 Found ${tripsSnapshot.docs.length} trips in database');
    
    for (QueryDocumentSnapshot doc in tripsSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final String tripName = (data['name'] ?? '').toString().toLowerCase();
      
      print('\\n🔍 Processing trip: "${data['name']}"');
      
      // Check if this trip needs an itinerary update
      String? itineraryKey;
      if (tripName.contains('japan') || tripName.contains('tokyo')) {
        itineraryKey = 'japan';
      } else if (tripName.contains('paris')) {
        itineraryKey = 'paris';
      }
      
      if (itineraryKey != null) {
        final List<String> newItinerary = tripItineraries[itineraryKey]!;
        
        print('📝 Updating ${data['name']} with ${newItinerary.length} itinerary items:');
        for (int i = 0; i < newItinerary.length; i++) {
          print('   ${i + 1}. ${newItinerary[i]}');
        }
        
        // Update the document
        await doc.reference.update({
          'itenarary': newItinerary,
        });
        
        print('✅ Successfully updated ${data['name']}!');
      } else {
        print('⏭️  Skipping ${data['name']} (no itinerary update needed)');
      }
    }
    
    print('\\n🎉 Itinerary update completed successfully!');
    print('💡 Your trips now have proper itinerary arrays in the database.');
    
  } catch (e) {
    print('❌ Error updating itineraries: $e');
  }
}
