import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  print('🔍 Testing database connectivity and data availability...');
  
  try {
    // Initialize Firebase (you may need to adjust this based on your setup)
    await Firebase.initializeApp();
    
    final firestore = FirebaseFirestore.instance;
    
    print('\n📊 Checking agencies collection...');
    await checkAgenciesCollection(firestore);
    
    print('\n📊 Checking agency_reviews collection...');
    await checkAgencyReviewsCollection(firestore);
    
    print('\n📊 Checking reviews collection...');
    await checkReviewsCollection(firestore);
    
    print('\n✅ Database connectivity test completed!');
    
  } catch (e) {
    print('❌ Error during connectivity test: $e');
    exit(1);
  }
}

Future<void> checkAgenciesCollection(FirebaseFirestore firestore) async {
  try {
    final snapshot = await firestore.collection('agency').limit(10).get();
    
    print('   Agencies found: ${snapshot.docs.length}');
    
    if (snapshot.docs.isEmpty) {
      print('   ⚠️  No agencies found - adding sample agencies...');
      await addSampleAgencies(firestore);
    } else {
      print('   ✅ Agencies data exists:');
      for (var doc in snapshot.docs) {
        final data = doc.data();
        print('      - ${data['name'] ?? 'Unknown'} (Rating: ${data['rating'] ?? 0.0})');
      }
    }
  } catch (e) {
    print('   ❌ Error checking agencies: $e');
  }
}

Future<void> checkAgencyReviewsCollection(FirebaseFirestore firestore) async {
  try {
    final snapshot = await firestore.collection('agency_reviews').limit(10).get();
    
    print('   Agency reviews found: ${snapshot.docs.length}');
    
    if (snapshot.docs.isEmpty) {
      print('   ⚠️  No agency reviews found');
      
      // Check if we have agencies to create reviews for
      final agenciesSnapshot = await firestore.collection('agency').limit(3).get();
      if (agenciesSnapshot.docs.isNotEmpty) {
        print('   ✨ Adding sample agency reviews...');
        await addSampleAgencyReviews(firestore, agenciesSnapshot.docs);
      } else {
        print('   ⚠️  Cannot add reviews - no agencies available');
      }
    } else {
      print('   ✅ Agency reviews data exists:');
      for (var doc in snapshot.docs) {
        final data = doc.data();
        print('      - ${data['user_name'] ?? 'Anonymous'} rated ${data['agency_name'] ?? 'Unknown Agency'}: ${data['rating'] ?? 0.0}/5');
      }
    }
  } catch (e) {
    print('   ❌ Error checking agency reviews: $e');
  }
}

Future<void> checkReviewsCollection(FirebaseFirestore firestore) async {
  try {
    final snapshot = await firestore.collection('reviews').limit(10).get();
    
    print('   Trip reviews found: ${snapshot.docs.length}');
    
    if (snapshot.docs.isEmpty) {
      print('   ⚠️  No trip reviews found - this is normal if no trips have been completed');
    } else {
      print('   ✅ Trip reviews data exists:');
      for (var doc in snapshot.docs) {
        final data = doc.data();
        print('      - ${data['user_name'] ?? 'Anonymous'} rated trip "${data['trip_title'] ?? 'Unknown Trip'}": ${data['rating'] ?? 0.0}/5');
      }
    }
  } catch (e) {
    print('   ❌ Error checking trip reviews: $e');
  }
}

Future<void> addSampleAgencies(FirebaseFirestore firestore) async {
  final sampleAgencies = [
    {
      'agency_id': 'sample_001',
      'name': 'Adventure Travel Co.',
      'description': 'Specializing in adventure tourism and outdoor experiences.',
      'location': 'Denver, Colorado',
      'rating': 4.5,
      'total_trips': 125,
      'contact_email': 'info@adventuretravel.com',
      'contact_phone': '+1-555-0123',
      'website': 'https://adventuretravel.com',
      'status': 'active',
      'created_at': FieldValue.serverTimestamp(),
      'logo': '',
    },
    {
      'agency_id': 'sample_002',
      'name': 'Luxury Escapes Ltd.',
      'description': 'Premium luxury travel experiences worldwide.',
      'location': 'New York, NY',
      'rating': 4.8,
      'total_trips': 89,
      'contact_email': 'contact@luxuryescapes.com',
      'contact_phone': '+1-555-0456',
      'website': 'https://luxuryescapes.com',
      'status': 'active',
      'created_at': FieldValue.serverTimestamp(),
      'logo': '',
    },
    {
      'agency_id': 'sample_003',
      'name': 'Budget Wanderer',
      'description': 'Affordable travel options for budget-conscious travelers.',
      'location': 'Austin, Texas',
      'rating': 4.2,
      'total_trips': 156,
      'contact_email': 'hello@budgetwanderer.com',
      'contact_phone': '+1-555-0789',
      'website': 'https://budgetwanderer.com',
      'status': 'active',
      'created_at': FieldValue.serverTimestamp(),
      'logo': '',
    },
  ];
  
  for (var agency in sampleAgencies) {
    await firestore.collection('agency').add(agency);
    print('      ✅ Added ${agency['name']}');
  }
}

Future<void> addSampleAgencyReviews(FirebaseFirestore firestore, List<QueryDocumentSnapshot> agencies) async {
  final sampleReviews = [
    {
      'user_name': 'Sarah Johnson',
      'rating': 4.5,
      'comment': 'Excellent service and professional staff. The trip planning was thorough and they were always available for questions. Highly recommend!',
      'service_quality': 4.5,
      'communication': 4.0,
      'value_for_money': 4.5,
      'created_at': FieldValue.serverTimestamp(),
    },
    {
      'user_name': 'Mike Wilson',
      'rating': 5.0,
      'comment': 'Amazing trip planning and execution. Everything was perfect! From booking to the actual trip, everything exceeded expectations.',
      'service_quality': 5.0,
      'communication': 5.0,
      'value_for_money': 4.5,
      'created_at': FieldValue.serverTimestamp(),
    },
    {
      'user_name': 'Emma Davis',
      'rating': 4.0,
      'comment': 'Good experience overall, minor issues with communication during the initial planning phase but everything worked out well.',
      'service_quality': 4.0,
      'communication': 3.5,
      'value_for_money': 4.0,
      'created_at': FieldValue.serverTimestamp(),
    },
    {
      'user_name': 'John Smith',
      'rating': 4.8,
      'comment': 'Outstanding luxury experience! Every detail was perfectly planned and executed. Worth every penny.',
      'service_quality': 5.0,
      'communication': 4.5,
      'value_for_money': 4.5,
      'created_at': FieldValue.serverTimestamp(),
    },
    {
      'user_name': 'Lisa Chen',
      'rating': 4.3,
      'comment': 'Great budget-friendly options without compromising on quality. The team was very helpful in finding deals.',
      'service_quality': 4.0,
      'communication': 4.5,
      'value_for_money': 4.5,
      'created_at': FieldValue.serverTimestamp(),
    },
  ];
  
  for (int i = 0; i < agencies.length && i < sampleReviews.length; i++) {
    final agency = agencies[i];
    final agencyData = agency.data() as Map<String, dynamic>;
    final review = sampleReviews[i];
    
    // Add a few reviews per agency
    for (int j = 0; j < 2; j++) {
      final reviewData = Map<String, dynamic>.from(review);
      if (j > 0) {
        // Vary the second review slightly
        reviewData['user_name'] = '${review['user_name']} ${j + 1}';
        reviewData['rating'] = (review['rating'] as double) - 0.2;
        reviewData['comment'] = 'Second review: ${review['comment']}';
      }
      
      await firestore.collection('agency_reviews').add({
        ...reviewData,
        'agency_reference': agency.reference,
        'agency_name': agencyData['name'] ?? 'Unknown Agency',
        'user_reference': null, // Will be set when real users review
        'helpful_count': 0,
      });
    }
    
    print('      ✅ Added reviews for ${agencyData['name']}');
  }
}