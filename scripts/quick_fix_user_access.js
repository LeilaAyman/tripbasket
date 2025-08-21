// Firebase Admin SDK script to fix user access
// Run this in Firebase Functions or Admin SDK environment

const admin = require('firebase-admin');

// Initialize if not already done
if (!admin.apps.length) {
  admin.initializeApp();
}

const firestore = admin.firestore();

async function fixUserAccess() {
  const email = 'adv@gmail.com';
  
  try {
    console.log(`=== FIXING ACCESS FOR: ${email} ===`);
    
    // Find user document by email
    const usersQuery = await firestore
      .collection('users')
      .where('email', '==', email)
      .get();
    
    if (usersQuery.empty) {
      console.log('❌ User document not found. User needs to login once first.');
      return;
    }
    
    const userDoc = usersQuery.docs[0];
    const currentData = userDoc.data();
    
    console.log('Current user data:', {
      email: currentData.email,
      roles: currentData.role || []
    });
    
    // Add admin role to user
    await userDoc.ref.update({
      role: admin.firestore.FieldValue.arrayUnion('admin')
    });
    
    console.log('✅ Successfully added admin role to user!');
    console.log('User should now have access to all features.');
    
  } catch (error) {
    console.error('❌ Error:', error);
  }
}

fixUserAccess();
