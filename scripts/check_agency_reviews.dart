import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  print('🔍 Checking agency reviews data...');
  
  try {
    // Initialize Firestore
    final firestore = FirebaseFirestore.instance;
    
    // Check if agency_reviews collection has data
    final reviewsSnapshot = await firestore.collection('agency_reviews').limit(10).get();
    
    print('📊 Agency reviews found: ${reviewsSnapshot.docs.length}');
    
    if (reviewsSnapshot.docs.isEmpty) {
      print('⚠️  No agency reviews found - this might be why reviews aren\'t loading');
      
      // Check if we have agencies
      final agenciesSnapshot = await firestore.collection('agencies').limit(5).get();
      print('🏢 Agencies found: ${agenciesSnapshot.docs.length}');
      
      if (agenciesSnapshot.docs.isNotEmpty) {
        print('✨ Adding sample agency reviews...');
        await addSampleReviews(firestore, agenciesSnapshot.docs);
      }
    } else {
      print('✅ Agency reviews data exists:');
      for (var doc in reviewsSnapshot.docs) {
        final data = doc.data();
        print('   - Review by ${data['user_name'] ?? 'Anonymous'} for ${data['agency_name'] ?? 'Unknown Agency'}');
      }
    }
  } catch (e) {
    print('❌ Error checking agency reviews: $e');
  }
}

Future<void> addSampleReviews(FirebaseFirestore firestore, List<QueryDocumentSnapshot> agencies) async {
  final sampleReviews = [
    {
      'user_name': 'Sarah Johnson',
      'rating': 4.5,
      'comment': 'Excellent service and professional staff. Highly recommend!',
      'service_quality': 4.5,
      'communication': 4.0,
      'value_for_money': 4.5,
      'created_at': DateTime.now().subtract(Duration(days: 7)),
    },
    {
      'user_name': 'Mike Wilson',
      'rating': 5.0,
      'comment': 'Amazing trip planning and execution. Everything was perfect!',
      'service_quality': 5.0,
      'communication': 5.0,
      'value_for_money': 4.5,
      'created_at': DateTime.now().subtract(Duration(days: 3)),
    },
    {
      'user_name': 'Emma Davis',
      'rating': 4.0,
      'comment': 'Good experience overall, minor issues with communication.',
      'service_quality': 4.0,
      'communication': 3.5,
      'value_for_money': 4.0,
      'created_at': DateTime.now().subtract(Duration(days: 1)),
    },
  ];

  for (int i = 0; i < agencies.length && i < 3; i++) {
    final agency = agencies[i];
    final agencyData = agency.data() as Map<String, dynamic>;
    final review = sampleReviews[i % sampleReviews.length];
    
    await firestore.collection('agency_reviews').add({
      ...review,
      'agency_reference': agency.reference,
      'agency_name': agencyData['name'] ?? 'Unknown Agency',
      'user_reference': firestore.collection('users').doc('sample_user_${i + 1}'),
      'helpful_count': 0,
    });
    
    print('   ✅ Added review for ${agencyData['name']}');
  }
}