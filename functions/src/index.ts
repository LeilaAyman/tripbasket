import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

// Award 100 loyalty points when a booking is created with completed payment
export const onBookingCreate_awardPoints = functions.firestore
  .document("bookings/{bookingId}")
  .onCreate(async (snap, context) => {
    try {
      const data = snap.data() || {};
      const bookingId = context.params.bookingId;
      
      console.log(`Processing new booking ${bookingId}`, {
        dataKeys: Object.keys(data),
        user_reference: data.user_reference,
        payment_status: data.payment_status
      });
      
      // Extract user ID from user_reference DocumentReference
      let uid: string | undefined;
      
      if (data.user_reference) {
        // For DocumentReference, the ID is the last segment of the path
        if (data.user_reference.path) {
          // Extract from path like "users/abc123"
          uid = data.user_reference.path.split('/').pop();
        } else if (data.user_reference._path && data.user_reference._path.segments) {
          // Extract from segments array
          uid = data.user_reference._path.segments[data.user_reference._path.segments.length - 1];
        } else if (data.user_reference.id) {
          uid = data.user_reference.id;
        }
      }
      
      // Fallback to other possible field names
      uid = uid || data.userId || data.user_id || data.uid;
      
      if (!uid) {
        console.log("No uid found in booking, skipping.", { 
          bookingId, 
          dataKeys: Object.keys(data),
          user_reference: data.user_reference 
        });
        return;
      }
      
      console.log(`Found user ID: ${uid} for booking ${bookingId}`);
      
      // Check payment status - award points immediately for completed payments
      const paymentStatus = data.payment_status || '';
      console.log(`Payment status: ${paymentStatus}`);
      
      if (paymentStatus.toLowerCase() === 'completed') {
        const userRef = admin.firestore().doc(`users/${uid}`);
        
        console.log(`Incrementing points for user ${uid}`);
        await userRef.set({
          loyaltyPoints: admin.firestore.FieldValue.increment(100)
        }, { merge: true });
        
        console.log(`✅ Points incremented +100 for user ${uid} on booking ${bookingId}`);
      } else {
        console.log(`⏱️ Booking ${bookingId} not completed yet. Status: ${paymentStatus}`);
      }
      
    } catch (error) {
      console.error("❌ Error in onBookingCreate_awardPoints:", error);
    }
  });

// Award points when booking status changes to completed
export const onBookingUpdate_awardPoints = functions.firestore
  .document("bookings/{bookingId}")
  .onUpdate(async (change, context) => {
    try {
      const before = change.before.data() || {};
      const after = change.after.data() || {};
      const bookingId = context.params.bookingId;
      
      console.log(`Processing booking update ${bookingId}`, {
        beforeStatus: before.payment_status,
        afterStatus: after.payment_status
      });
      
      // Check if payment status just changed to completed
      const wasCompleted = before.payment_status?.toLowerCase() === 'completed';
      const isCompleted = after.payment_status?.toLowerCase() === 'completed';
      
      // Only award points if status just changed to completed (not already completed)
      if (!wasCompleted && isCompleted) {
        console.log(`🎉 Booking ${bookingId} just completed! Awarding points...`);
        
        // Extract user ID
        let uid: string | undefined;
        
        if (after.user_reference) {
          if (after.user_reference.path) {
            uid = after.user_reference.path.split('/').pop();
          } else if (after.user_reference._path && after.user_reference._path.segments) {
            uid = after.user_reference._path.segments[after.user_reference._path.segments.length - 1];
          } else if (after.user_reference.id) {
            uid = after.user_reference.id;
          }
        }
        
        uid = uid || after.userId || after.user_id || after.uid;
        
        if (!uid) {
          console.log("❌ No user ID found in booking update:", bookingId);
          return;
        }
        
        const userRef = admin.firestore().doc(`users/${uid}`);
        
        console.log(`Incrementing points for user ${uid} (status change)`);
        await userRef.set({
          loyaltyPoints: admin.firestore.FieldValue.increment(100)
        }, { merge: true });
        
        console.log(`✅ Points incremented +100 for user ${uid} on booking update ${bookingId}`);
      } else {
        console.log(`⏭️ No point award needed for booking ${bookingId}. Was: ${before.payment_status}, Now: ${after.payment_status}`);
      }
      
    } catch (error) {
      console.error("❌ Error in onBookingUpdate_awardPoints:", error);
    }
  });

// Manual function to award points for existing completed bookings (for testing/backfill)
export const awardPointsManually = functions.https.onCall(async (data, context) => {
  try {
    console.log("🔧 Manual points award triggered");
    
    // Get all completed bookings
    const bookingsSnapshot = await admin.firestore()
      .collection('bookings')
      .where('payment_status', '==', 'completed')
      .get();
    
    console.log(`Found ${bookingsSnapshot.docs.length} completed bookings`);
    
    let pointsAwarded = 0;
    const batch = admin.firestore().batch();
    
    for (const bookingDoc of bookingsSnapshot.docs) {
      const bookingData = bookingDoc.data();
      
      // Extract user ID
      let uid: string | undefined;
      
      if (bookingData.user_reference) {
        if (bookingData.user_reference.path) {
          uid = bookingData.user_reference.path.split('/').pop();
        } else if (bookingData.user_reference._path && bookingData.user_reference._path.segments) {
          uid = bookingData.user_reference._path.segments[bookingData.user_reference._path.segments.length - 1];
        } else if (bookingData.user_reference.id) {
          uid = bookingData.user_reference.id;
        }
      }
      
      uid = uid || bookingData.userId || bookingData.user_id || bookingData.uid;
      
      if (uid) {
        const userRef = admin.firestore().doc(`users/${uid}`);
        batch.set(userRef, {
          loyaltyPoints: admin.firestore.FieldValue.increment(100)
        }, { merge: true });
        pointsAwarded++;
        
        console.log(`✅ Queued 100 points for user ${uid} (booking ${bookingDoc.id})`);
      } else {
        console.log(`⚠️ No user ID found for booking ${bookingDoc.id}`);
      }
    }
    
    if (pointsAwarded > 0) {
      await batch.commit();
      console.log(`🎉 Awarded ${pointsAwarded * 100} total points to ${pointsAwarded} users`);
    }
    
    return { 
      success: true, 
      pointsAwarded: pointsAwarded * 100,
      bookingsProcessed: pointsAwarded 
    };
    
  } catch (error) {
    console.error("❌ Error in manual points award:", error);
    throw new functions.https.HttpsError('internal', 'Failed to award points');
  }
});

// Remove expired bookings daily at midnight
export const removeExpiredBookings = functions.pubsub
  .schedule('0 0 * * *') // Run daily at midnight
  .timeZone('Africa/Cairo')
  .onRun(async (context) => {
    try {
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      
      console.log(`🧹 Checking for expired bookings as of ${today.toISOString()}`);
      
      const bookingsSnapshot = await admin.firestore().collection('bookings').get();
      
      let expiredCount = 0;
      const batch = admin.firestore().batch();
      
      for (const bookingDoc of bookingsSnapshot.docs) {
        const bookingData = bookingDoc.data();
        
        if (bookingData.trip_reference) {
          try {
            const tripDoc = await bookingData.trip_reference.get();
            const tripData = tripDoc.data();
            
            if (tripData && tripData.start_date) {
              const tripStartDate = tripData.start_date.toDate();
              tripStartDate.setHours(0, 0, 0, 0);
              
              if (tripStartDate <= today) {
                console.log(`🗑️ Deleting expired booking ${bookingDoc.id} - trip started on ${tripStartDate.toISOString()}`);
                batch.delete(bookingDoc.ref);
                expiredCount++;
              }
            }
          } catch (error) {
            console.error(`❌ Error checking trip for booking ${bookingDoc.id}:`, error);
          }
        }
      }
      
      if (expiredCount > 0) {
        await batch.commit();
        console.log(`✅ Successfully removed ${expiredCount} expired bookings`);
      } else {
        console.log('✨ No expired bookings found');
      }
      
      return { expiredBookingsRemoved: expiredCount };
      
    } catch (error) {
      console.error("❌ Error removing expired bookings:", error);
      throw error;
    }
  });

// Manual function to remove expired bookings (for testing)
export const removeExpiredBookingsManually = functions.https.onCall(async (data, context) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const bookingsSnapshot = await admin.firestore().collection('bookings').get();
    
    let expiredCount = 0;
    const batch = admin.firestore().batch();
    
    for (const bookingDoc of bookingsSnapshot.docs) {
      const bookingData = bookingDoc.data();
      
      if (bookingData.trip_reference) {
        try {
          const tripDoc = await bookingData.trip_reference.get();
          const tripData = tripDoc.data();
          
          if (tripData && tripData.start_date) {
            const tripStartDate = tripData.start_date.toDate();
            tripStartDate.setHours(0, 0, 0, 0);
            
            if (tripStartDate <= today) {
              batch.delete(bookingDoc.ref);
              expiredCount++;
            }
          }
        } catch (error) {
          console.error(`Error checking trip for booking ${bookingDoc.id}:`, error);
        }
      }
    }
    
    if (expiredCount > 0) {
      await batch.commit();
    }
    
    return { 
      success: true, 
      expiredBookingsRemoved: expiredCount 
    };
    
  } catch (error) {
    console.error("Error removing expired bookings manually:", error);
    throw new functions.https.HttpsError('internal', 'Failed to remove expired bookings');
  }
});