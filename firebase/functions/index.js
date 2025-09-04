const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.onUserDeleted = functions.auth.user().onDelete(async (user) => {
  let firestore = admin.firestore();
  let userRef = firestore.doc("users/" + user.uid);
  
  try {
    // Delete user document from Firestore
    await userRef.delete();
    
    // Delete related bookings
    const bookingsQuery = firestore.collection("bookings").where("user_uid", "==", user.uid);
    const bookingsSnapshot = await bookingsQuery.get();
    
    const batch = firestore.batch();
    bookingsSnapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });
    
    await batch.commit();
    
    console.log(`Successfully deleted user ${user.uid} and related data`);
  } catch (error) {
    console.error(`Error deleting user ${user.uid} data:`, error);
  }
});

// Function to completely delete a user (both Auth and Firestore)
exports.deleteUserCompletely = functions.https.onCall(async (data, context) => {
  // Allow authenticated users (remove admin-only restriction for now)
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Authentication required');
  }
  
  const { email, uid } = data;
  
  if (!email && !uid) {
    throw new functions.https.HttpsError('invalid-argument', 'Either email or uid must be provided');
  }
  
  try {
    let userRecord;
    let targetUid;
    
    // Get user record by email or uid
    try {
      if (uid) {
        userRecord = await admin.auth().getUser(uid);
        targetUid = uid;
      } else if (email) {
        userRecord = await admin.auth().getUserByEmail(email);
        targetUid = userRecord.uid;
      }
    } catch (authError) {
      if (authError.code === 'auth/user-not-found') {
        // User not in Auth, but might be in Firestore
        console.log(`User ${email || uid} not found in Firebase Auth, checking Firestore only`);
      } else {
        throw authError;
      }
    }
    
    // Delete from Firestore
    const firestore = admin.firestore();
    let bookingsDeleted = 0;
    let firestoreDeleted = false;
    
    // If we don't have targetUid, try to find it in Firestore
    if (!targetUid && email) {
      const userQuery = await firestore.collection('users').where('email', '==', email).limit(1).get();
      if (!userQuery.empty) {
        targetUid = userQuery.docs[0].id;
      }
    }
    
    if (targetUid) {
      // Delete user document
      const userRef = firestore.doc(`users/${targetUid}`);
      await userRef.delete();
      firestoreDeleted = true;
      
      // Delete related bookings
      const bookingsQuery = firestore.collection("bookings").where("user_uid", "==", targetUid);
      const bookingsSnapshot = await bookingsQuery.get();
      
      const batch = firestore.batch();
      bookingsSnapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
        bookingsDeleted++;
      });
      
      if (bookingsDeleted > 0) {
        await batch.commit();
      }
    }
    
    // Delete from Firebase Auth (if user exists)
    let authDeleted = false;
    if (userRecord && targetUid) {
      try {
        await admin.auth().deleteUser(targetUid);
        authDeleted = true;
        console.log(`Successfully deleted user ${email || targetUid} from Firebase Auth`);
      } catch (authDeleteError) {
        console.error(`Failed to delete user from Auth: ${authDeleteError.message}`);
      }
    }
    
    return {
      success: true,
      details: {
        authDeleted: authDeleted,
        firestoreDeleted: firestoreDeleted,
        bookingsDeleted: bookingsDeleted,
        message: `User deletion completed. Auth: ${authDeleted}, Firestore: ${firestoreDeleted}, Bookings: ${bookingsDeleted}`
      }
    };
    
  } catch (error) {
    console.error('Error in deleteUserCompletely:', error);
    throw new functions.https.HttpsError('internal', `Failed to delete user: ${error.message}`);
  }
});

// Function to send 2FA email verification codes
exports.send2FAEmail = functions.https.onCall(async (data, context) => {
  // Allow authenticated users
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Authentication required');
  }
  
  const { email, code } = data;
  
  if (!email || !code) {
    throw new functions.https.HttpsError('invalid-argument', 'Email and code are required');
  }
  
  try {
    // For now, just log the code (development mode)
    console.log(`📧 Verification code for ${email}: ${code}`);
    
    // TODO: Add real email service later (SendGrid, AWS SES, etc.)
    // For development, we'll return success with the code in console
    
    return {
      success: true,
      message: 'Verification code logged to console (development mode)',
      developmentCode: code // This will be printed in your app console
    };
    
  } catch (error) {
    console.error('Error in send2FAEmail:', error);
    throw new functions.https.HttpsError('internal', `Failed to send email: ${error.message}`);
  }
});

// Admin function to add a new trip
exports.addBaliTrip = functions.https.onRequest(async (req, res) => {
  try {
    const firestore = admin.firestore();
    
    const newTrip = {
      title: 'Bali Adventure',
      description: 'Discover the beauty of Bali with temples, beaches, and culture.',
      location: 'Bali, Indonesia',
      price: 800,
      image: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f3/Pura_Ulun_Danu_Bratan.jpg/1280px-Pura_Ulun_Danu_Bratan.jpg',
      itenarary: [
        'Day 1: Arrival in Bali - Ubud rice terraces + Welcome dinner',
        'Day 2: Temple Tour - Tanah Lot + Uluwatu Temple + Traditional dance',
        'Day 3: Beach Day - Seminyak beach + Water sports + Sunset dinner',
        'Day 4: Cultural Experience - Monkey Forest + Art villages + Cooking class',
        'Day 5: Mount Batur sunrise hike + Hot springs + Departure'
      ],
      available_seats: 18,
      status: 'approved',
      start_date: admin.firestore.Timestamp.fromDate(new Date(2025, 9, 1)), // October 1, 2025
      end_date: admin.firestore.Timestamp.fromDate(new Date(2025, 9, 5))    // October 5, 2025
    };
    
    const docRef = await firestore.collection('trips').add(newTrip);
    
    res.status(200).json({
      success: true,
      message: 'Bali Adventure trip added successfully!',
      tripId: docRef.id,
      tripData: newTrip
    });
    
  } catch (error) {
    console.error('Error adding Bali trip:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});
