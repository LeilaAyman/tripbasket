// Simple Node.js script to diagnose Firestore data
// Run with: node diagnose_firestore.js

const admin = require('firebase-admin');

// Initialize Firebase Admin (you'll need to set up service account)
try {
  admin.initializeApp({
    // Firebase will use GOOGLE_APPLICATION_CREDENTIALS env var
    // or default service account if running on Google Cloud
  });
} catch (error) {
  console.log('⚠️  Firebase already initialized or missing credentials');
}

const db = admin.firestore();

async function checkCollections() {
  console.log('🔍 Diagnosing Firestore collections...\n');
  
  try {
    // Check agency collection
    console.log('📊 Checking "agency" collection...');
    const agencySnapshot = await db.collection('agency').limit(5).get();
    console.log(`   Found ${agencySnapshot.docs.length} agencies`);
    
    if (agencySnapshot.docs.length > 0) {
      agencySnapshot.docs.forEach(doc => {
        const data = doc.data();
        console.log(`   - ${data.name || 'Unknown'} (Rating: ${data.rating || 0})`);
      });
    } else {
      console.log('   ⚠️  No agencies found - this is likely why the list is empty');
    }
    
    console.log('\n📊 Checking "agency_reviews" collection...');
    const reviewsSnapshot = await db.collection('agency_reviews').limit(5).get();
    console.log(`   Found ${reviewsSnapshot.docs.length} agency reviews`);
    
    if (reviewsSnapshot.docs.length > 0) {
      reviewsSnapshot.docs.forEach(doc => {
        const data = doc.data();
        console.log(`   - ${data.user_name || 'Anonymous'} rated ${data.agency_name || 'Unknown'}: ${data.rating || 0}/5`);
      });
    } else {
      console.log('   ⚠️  No agency reviews found');
    }
    
    console.log('\n📊 Checking "reviews" (trip reviews) collection...');
    const tripReviewsSnapshot = await db.collection('reviews').limit(5).get();
    console.log(`   Found ${tripReviewsSnapshot.docs.length} trip reviews`);
    
  } catch (error) {
    console.error('❌ Error checking collections:', error.message);
    console.log('\n💡 Common issues:');
    console.log('   - Missing GOOGLE_APPLICATION_CREDENTIALS environment variable');
    console.log('   - Service account key not configured');
    console.log('   - Firestore rules too restrictive');
    console.log('   - Network connectivity issues');
  }
}

async function addSampleData() {
  console.log('\n✨ Adding sample agencies...');
  
  const sampleAgencies = [
    {
      agency_id: 'sample_001',
      name: 'Adventure Travel Co.',
      description: 'Specializing in adventure tourism and outdoor experiences.',
      location: 'Denver, Colorado',
      rating: 4.5,
      total_trips: 125,
      contact_email: 'info@adventuretravel.com',
      contact_phone: '+1-555-0123',
      website: 'https://adventuretravel.com',
      status: 'active',
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      logo: '',
    },
    {
      agency_id: 'sample_002', 
      name: 'Luxury Escapes Ltd.',
      description: 'Premium luxury travel experiences worldwide.',
      location: 'New York, NY',
      rating: 4.8,
      total_trips: 89,
      contact_email: 'contact@luxuryescapes.com',
      contact_phone: '+1-555-0456',
      website: 'https://luxuryescapes.com',
      status: 'active',
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      logo: '',
    }
  ];
  
  try {
    for (const agency of sampleAgencies) {
      await db.collection('agency').add(agency);
      console.log(`   ✅ Added ${agency.name}`);
    }
    
    console.log('\n✨ Adding sample agency reviews...');
    
    // Get the agencies we just added
    const agenciesSnapshot = await db.collection('agency').limit(2).get();
    
    const sampleReviews = [
      {
        user_name: 'Sarah Johnson',
        rating: 4.5,
        comment: 'Excellent service and professional staff. Highly recommend!',
        service_quality: 4.5,
        communication: 4.0,
        value_for_money: 4.5,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
        helpful_count: 0,
      },
      {
        user_name: 'Mike Wilson',
        rating: 5.0,
        comment: 'Amazing trip planning and execution. Everything was perfect!',
        service_quality: 5.0,
        communication: 5.0,
        value_for_money: 4.5,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
        helpful_count: 0,
      }
    ];
    
    let reviewIndex = 0;
    for (const agencyDoc of agenciesSnapshot.docs) {
      const agencyData = agencyDoc.data();
      const review = sampleReviews[reviewIndex % sampleReviews.length];
      
      await db.collection('agency_reviews').add({
        ...review,
        agency_reference: agencyDoc.ref,
        agency_name: agencyData.name || 'Unknown Agency',
        user_reference: null, // Will be set when real users review
      });
      
      console.log(`   ✅ Added review for ${agencyData.name}`);
      reviewIndex++;
    }
    
  } catch (error) {
    console.error('❌ Error adding sample data:', error.message);
  }
}

// Main execution
async function main() {
  await checkCollections();
  
  // Check if we should add sample data
  const agencySnapshot = await db.collection('agency').limit(1).get();
  if (agencySnapshot.docs.length === 0) {
    console.log('\n🤔 No agencies found. Would you like to add sample data?');
    console.log('Run: GOOGLE_APPLICATION_CREDENTIALS=path/to/service-account.json node diagnose_firestore.js --add-sample');
    
    if (process.argv.includes('--add-sample')) {
      await addSampleData();
      console.log('\n✅ Sample data added! Try refreshing your app.');
    }
  }
  
  console.log('\n🎯 Diagnosis complete!');
  process.exit(0);
}

main().catch(console.error);