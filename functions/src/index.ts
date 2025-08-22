import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

// Award 100 loyalty points when a booking is completed/created
export const onBookingCreate = functions.firestore
  .document("bookings/{bookingId}")
  .onCreate(async (snap, context) => {
    try {
      const data = snap.data();
      
      // Extract user ID from various possible field names
      const uid = (data?.user_reference?.id || 
                   data?.userReference?.id || 
                   data?.userId || 
                   data?.user_id || 
                   data?.uid) as string | undefined;
      
      if (!uid) {
        console.log("No user ID found in booking document:", snap.id);
        return;
      }

      // Only award points for completed/paid bookings
      const paymentStatus = data?.payment_status || data?.paymentStatus || '';
      const bookingStatus = data?.booking_status || data?.bookingStatus || '';
      
      if (paymentStatus.toLowerCase() !== 'completed' && 
          paymentStatus.toLowerCase() !== 'paid' &&
          bookingStatus.toLowerCase() !== 'confirmed') {
        console.log(`Booking ${snap.id} not completed yet. Status: ${paymentStatus}/${bookingStatus}`);
        return;
      }

      const userRef = admin.firestore().doc(`users/${uid}`);
      
      // Award 100 points
      await userRef.set({
        loyaltyPoints: admin.firestore.FieldValue.increment(100)
      }, { merge: true });
      
      console.log(`Awarded 100 loyalty points to user ${uid} for booking ${snap.id}`);
      
    } catch (error) {
      console.error("Error awarding loyalty points:", error);
    }
  });

// Alternative: Award points when booking status changes to completed
export const onBookingUpdate = functions.firestore
  .document("bookings/{bookingId}")
  .onUpdate(async (change, context) => {
    try {
      const before = change.before.data();
      const after = change.after.data();
      
      // Check if payment/booking status just changed to completed
      const wasCompleted = (before?.payment_status?.toLowerCase() === 'completed' || 
                           before?.payment_status?.toLowerCase() === 'paid' ||
                           before?.booking_status?.toLowerCase() === 'confirmed');
      
      const isCompleted = (after?.payment_status?.toLowerCase() === 'completed' || 
                          after?.payment_status?.toLowerCase() === 'paid' ||
                          after?.booking_status?.toLowerCase() === 'confirmed');
      
      // Only award points if status just changed to completed (not already completed)
      if (!wasCompleted && isCompleted) {
        const uid = (after?.user_reference?.id || 
                     after?.userReference?.id || 
                     after?.userId || 
                     after?.user_id || 
                     after?.uid) as string | undefined;
        
        if (!uid) {
          console.log("No user ID found in booking update:", change.after.id);
          return;
        }

        const userRef = admin.firestore().doc(`users/${uid}`);
        
        // Award 100 points
        await userRef.set({
          loyaltyPoints: admin.firestore.FieldValue.increment(100)
        }, { merge: true });
        
        console.log(`Awarded 100 loyalty points to user ${uid} for completed booking ${change.after.id}`);
      }
      
    } catch (error) {
      console.error("Error awarding loyalty points on booking update:", error);
    }
  });

// Seed loyalty points for existing users
export const seedLoyaltyPoints = functions.https.onCall(async (data, context) => {
  // Only allow authenticated admin users
  if (!context.auth || !context.auth.token.admin) {
    throw new functions.https.HttpsError('unauthenticated', 'Admin access required');
  }
  
  try {
    const usersRef = admin.firestore().collection('users');
    const snapshot = await usersRef.get();
    
    const batch = admin.firestore().batch();
    let count = 0;
    
    snapshot.docs.forEach(doc => {
      const userData = doc.data();
      if (userData.loyaltyPoints === undefined) {
        batch.update(doc.ref, { loyaltyPoints: 0 });
        count++;
      }
    });
    
    await batch.commit();
    console.log(`Seeded loyaltyPoints = 0 for ${count} users`);
    return { success: true, updatedUsers: count };
    
  } catch (error) {
    console.error("Error seeding loyalty points:", error);
    throw new functions.https.HttpsError('internal', 'Failed to seed loyalty points');
  }
});