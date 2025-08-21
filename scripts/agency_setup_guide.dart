import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Simple script to add agencies via Firebase web console
/// This creates the JSON data needed for manual import
void main() async {
  print('🚀 Generating agency data for Firebase import...');
  
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
      'status': 'active',
    },
    {
      'name': 'Family Fun Adventures',
      'description': 'Kid-friendly destinations and family-oriented activities designed to create unforgettable memories for all ages.',
      'logo': 'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?ixlib=rb-4.0.3&auto=format&fit=crop&w=300&q=80',
      'contact_email': 'family@funadventures.com',
      'contact_phone': '+1-555-0654',
      'website': 'https://familyfunadventures.com',
      'location': 'Orlando, USA',
      'rating': 4.5,
      'total_trips': 20,
      'status': 'active',
    },
  ];
  
  print('📋 Agency Data Generated:');
  print('========================');
  
  for (int i = 0; i < agencies.length; i++) {
    final agency = agencies[i];
    print('');
    print('Agency ${i + 1}: ${agency['name']}');
    print('Description: ${agency['description']}');
    print('Location: ${agency['location']}');
    print('Rating: ${agency['rating']}');
    print('Total Trips: ${agency['total_trips']}');
    print('Status: ${agency['status']}');
    print('Contact: ${agency['contact_email']}');
    print('Website: ${agency['website']}');
    print('Logo URL: ${agency['logo']}');
    print('---');
  }
  
  print('');
  print('🔥 Manual Setup Instructions:');
  print('============================');
  print('1. Go to Firebase Console → Firestore Database');
  print('2. Create a new collection called "agencies"');
  print('3. Add each agency as a new document with the above data');
  print('4. Remember to add "created_at" field with current timestamp');
  print('');
  print('📝 For each agency document, add these fields:');
  print('- name (string)');
  print('- description (string)');
  print('- logo (string)');
  print('- contact_email (string)');
  print('- contact_phone (string)');
  print('- website (string)');
  print('- location (string)');
  print('- rating (number)');
  print('- total_trips (number)');
  print('- status (string)');
  print('- created_at (timestamp)');
  print('');
  print('💡 After creating agencies, you can test:');
  print('- Navigate to agencies list from home page');
  print('- View agency details and trips');
  print('- Search functionality with agency names');
  
  print('');
  print('🏁 Setup guide completed!');
}
