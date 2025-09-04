"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
var _a, _b;
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteUserCompletely = exports.cleanupOrphanedCartItems = exports.removeExpiredBookingsManually = exports.removeExpiredBookings = exports.awardPointsManually = exports.onBookingUpdate_awardPoints = exports.onBookingCreate_awardPoints = exports.send2FAEmail = exports.getOptimizationStats = exports.optimizeExistingImages = exports.optimizeUploadedImage = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const nodemailer = __importStar(require("nodemailer"));
// Import image optimization functions
const imageOptimization = require('../imageOptimization');
exports.optimizeUploadedImage = imageOptimization.optimizeUploadedImage;
exports.optimizeExistingImages = imageOptimization.optimizeExistingImages;
exports.getOptimizationStats = imageOptimization.getOptimizationStats;
admin.initializeApp();
// Gmail configuration using app password - set these up in Firebase Functions config
const gmailEmail = (_a = functions.config().gmail) === null || _a === void 0 ? void 0 : _a.email;
const gmailPassword = (_b = functions.config().gmail) === null || _b === void 0 ? void 0 : _b.password;
// Create reusable transporter object using Gmail SMTP with app password
const mailTransporter = gmailEmail && gmailPassword ? nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: gmailEmail,
        pass: gmailPassword
    }
}) : null;
// Send verification email for 2FA
exports.send2FAEmail = functions.https.onCall(async (data, context) => {
    try {
        // Note: Removed authentication check since this is used for 2FA during login process
        const { email, code } = data;
        if (!email || !code) {
            throw new functions.https.HttpsError('invalid-argument', 'Email and code are required');
        }
        // Check if email configuration is available
        if (!mailTransporter) {
            console.log(`⚠️ Email not configured, code for ${email}: ${code}`);
            // For development - show in a more user-friendly way
            return {
                success: true,
                message: 'Email service not configured. Check console for verification code.',
                developmentCode: code // Only for development
            };
        }
        // Compose email
        const mailOptions = {
            from: gmailEmail,
            to: email,
            subject: 'TripBasket - Two-Factor Authentication Code',
            html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <div style="background: linear-gradient(135deg, #D76B30, #F2D83B); padding: 30px; text-align: center;">
            <h1 style="color: white; margin: 0;">TripBasket</h1>
            <p style="color: white; margin: 10px 0 0 0;">Your Travel Verification Code</p>
          </div>
          
          <div style="padding: 30px; background: #f9f9f9;">
            <h2 style="color: #333;">Security Verification Required</h2>
            <p style="color: #666; line-height: 1.6;">
              We received a request to verify your account. Please use the verification code below:
            </p>
            
            <div style="background: white; border: 2px solid #D76B30; border-radius: 8px; padding: 20px; text-align: center; margin: 20px 0;">
              <h1 style="color: #D76B30; font-size: 32px; letter-spacing: 4px; margin: 0;">${code}</h1>
            </div>
            
            <p style="color: #666; line-height: 1.6;">
              This code will expire in <strong>10 minutes</strong> for security purposes.
            </p>
            
            <p style="color: #666; line-height: 1.6;">
              If you didn't request this verification, please ignore this email or contact our support team.
            </p>
            
            <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;">
            
            <p style="color: #999; font-size: 12px; text-align: center;">
              This email was sent by TripBasket Security System<br>
              Please do not reply to this email.
            </p>
          </div>
        </div>
      `
        };
        // Send email
        await mailTransporter.sendMail(mailOptions);
        console.log(`✅ 2FA email sent successfully to ${email}`);
        return {
            success: true,
            message: 'Verification code sent successfully'
        };
    }
    catch (error) {
        console.error('❌ Error sending 2FA email:', error);
        if (error instanceof functions.https.HttpsError) {
            throw error;
        }
        throw new functions.https.HttpsError('internal', 'Failed to send verification email');
    }
});
// Award 100 loyalty points when a booking is created with completed payment
exports.onBookingCreate_awardPoints = functions.firestore
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
        let uid;
        if (data.user_reference) {
            // For DocumentReference, the ID is the last segment of the path
            if (data.user_reference.path) {
                // Extract from path like "users/abc123"
                uid = data.user_reference.path.split('/').pop();
            }
            else if (data.user_reference._path && data.user_reference._path.segments) {
                // Extract from segments array
                uid = data.user_reference._path.segments[data.user_reference._path.segments.length - 1];
            }
            else if (data.user_reference.id) {
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
        }
        else {
            console.log(`⏱️ Booking ${bookingId} not completed yet. Status: ${paymentStatus}`);
        }
    }
    catch (error) {
        console.error("❌ Error in onBookingCreate_awardPoints:", error);
    }
});
// Award points when booking status changes to completed
exports.onBookingUpdate_awardPoints = functions.firestore
    .document("bookings/{bookingId}")
    .onUpdate(async (change, context) => {
    var _a, _b;
    try {
        const before = change.before.data() || {};
        const after = change.after.data() || {};
        const bookingId = context.params.bookingId;
        console.log(`Processing booking update ${bookingId}`, {
            beforeStatus: before.payment_status,
            afterStatus: after.payment_status
        });
        // Check if payment status just changed to completed
        const wasCompleted = ((_a = before.payment_status) === null || _a === void 0 ? void 0 : _a.toLowerCase()) === 'completed';
        const isCompleted = ((_b = after.payment_status) === null || _b === void 0 ? void 0 : _b.toLowerCase()) === 'completed';
        // Only award points if status just changed to completed (not already completed)
        if (!wasCompleted && isCompleted) {
            console.log(`🎉 Booking ${bookingId} just completed! Awarding points...`);
            // Extract user ID
            let uid;
            if (after.user_reference) {
                if (after.user_reference.path) {
                    uid = after.user_reference.path.split('/').pop();
                }
                else if (after.user_reference._path && after.user_reference._path.segments) {
                    uid = after.user_reference._path.segments[after.user_reference._path.segments.length - 1];
                }
                else if (after.user_reference.id) {
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
        }
        else {
            console.log(`⏭️ No point award needed for booking ${bookingId}. Was: ${before.payment_status}, Now: ${after.payment_status}`);
        }
    }
    catch (error) {
        console.error("❌ Error in onBookingUpdate_awardPoints:", error);
    }
});
// Manual function to award points for existing completed bookings (for testing/backfill)
exports.awardPointsManually = functions.https.onCall(async (data, context) => {
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
            let uid;
            if (bookingData.user_reference) {
                if (bookingData.user_reference.path) {
                    uid = bookingData.user_reference.path.split('/').pop();
                }
                else if (bookingData.user_reference._path && bookingData.user_reference._path.segments) {
                    uid = bookingData.user_reference._path.segments[bookingData.user_reference._path.segments.length - 1];
                }
                else if (bookingData.user_reference.id) {
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
            }
            else {
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
    }
    catch (error) {
        console.error("❌ Error in manual points award:", error);
        throw new functions.https.HttpsError('internal', 'Failed to award points');
    }
});
// Remove expired bookings daily at midnight
exports.removeExpiredBookings = functions.pubsub
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
                }
                catch (error) {
                    console.error(`❌ Error checking trip for booking ${bookingDoc.id}:`, error);
                }
            }
        }
        if (expiredCount > 0) {
            await batch.commit();
            console.log(`✅ Successfully removed ${expiredCount} expired bookings`);
        }
        else {
            console.log('✨ No expired bookings found');
        }
        return { expiredBookingsRemoved: expiredCount };
    }
    catch (error) {
        console.error("❌ Error removing expired bookings:", error);
        throw error;
    }
});
// Manual function to remove expired bookings (for testing)
exports.removeExpiredBookingsManually = functions.https.onCall(async (data, context) => {
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
                }
                catch (error) {
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
    }
    catch (error) {
        console.error("Error removing expired bookings manually:", error);
        throw new functions.https.HttpsError('internal', 'Failed to remove expired bookings');
    }
});
// Clean up orphaned cart items that reference deleted trips
exports.cleanupOrphanedCartItems = functions.https.onCall(async (data, context) => {
    try {
        console.log('🧹 Starting cart cleanup...');
        // Get all cart items
        const cartSnapshot = await admin.firestore().collection('cart').get();
        console.log(`📦 Found ${cartSnapshot.docs.length} cart items`);
        let deletedCount = 0;
        let validCount = 0;
        const batch = admin.firestore().batch();
        for (const cartDoc of cartSnapshot.docs) {
            const cartData = cartDoc.data();
            const tripReference = cartData.tripReference;
            if (!tripReference) {
                console.log(`❌ Cart item ${cartDoc.id} has null trip reference, deleting...`);
                batch.delete(cartDoc.ref);
                deletedCount++;
                continue;
            }
            // Check if the referenced trip still exists
            try {
                const tripDoc = await tripReference.get();
                if (!tripDoc.exists) {
                    console.log(`❌ Trip ${tripReference.id} no longer exists, deleting cart item ${cartDoc.id}...`);
                    batch.delete(cartDoc.ref);
                    deletedCount++;
                }
                else {
                    console.log(`✅ Cart item ${cartDoc.id} references valid trip ${tripReference.id}`);
                    validCount++;
                }
            }
            catch (e) {
                console.log(`❌ Error checking trip ${tripReference.id}, deleting cart item ${cartDoc.id}: ${e}`);
                batch.delete(cartDoc.ref);
                deletedCount++;
            }
        }
        if (deletedCount > 0) {
            await batch.commit();
        }
        console.log('🎉 Cleanup completed!');
        console.log(`✅ Valid cart items: ${validCount}`);
        console.log(`❌ Deleted orphaned items: ${deletedCount}`);
        return {
            success: true,
            validCartItems: validCount,
            deletedOrphanedItems: deletedCount,
            message: `Cleanup completed! Found ${validCount} valid cart items and removed ${deletedCount} orphaned items.`
        };
    }
    catch (error) {
        console.error('💥 Error during cleanup:', error);
        throw new functions.https.HttpsError('internal', 'Failed to cleanup cart items');
    }
});
// Admin function to completely delete a user (both Auth and Firestore)
exports.deleteUserCompletely = functions.https.onCall(async (data, context) => {
    var _a;
    try {
        // Check if the caller is authenticated and is an admin
        if (!context.auth) {
            throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
        }
        // Get the caller's user document to check admin role
        const callerDoc = await admin.firestore()
            .doc(`users/${context.auth.uid}`)
            .get();
        if (!callerDoc.exists) {
            throw new functions.https.HttpsError('permission-denied', 'User document not found');
        }
        const callerData = callerDoc.data();
        const isAdmin = ((_a = callerData === null || callerData === void 0 ? void 0 : callerData.role) === null || _a === void 0 ? void 0 : _a.includes('admin')) || false;
        if (!isAdmin) {
            throw new functions.https.HttpsError('permission-denied', 'Only admins can delete users');
        }
        const { email, uid } = data;
        if (!email && !uid) {
            throw new functions.https.HttpsError('invalid-argument', 'Either email or uid must be provided');
        }
        let userToDelete;
        try {
            // Get user by email or uid
            if (uid) {
                userToDelete = await admin.auth().getUser(uid);
            }
            else if (email) {
                userToDelete = await admin.auth().getUserByEmail(email);
            }
        }
        catch (authError) {
            console.log(`User not found in Firebase Auth: ${email || uid}`);
        }
        const deletionResults = {
            authDeleted: false,
            firestoreDeleted: false,
            userEmail: email || (userToDelete === null || userToDelete === void 0 ? void 0 : userToDelete.email) || 'unknown',
            userUid: uid || (userToDelete === null || userToDelete === void 0 ? void 0 : userToDelete.uid) || 'unknown'
        };
        // Delete from Firebase Auth
        if (userToDelete) {
            try {
                await admin.auth().deleteUser(userToDelete.uid);
                deletionResults.authDeleted = true;
                console.log(`✅ Deleted user from Firebase Auth: ${userToDelete.email}`);
            }
            catch (authDeleteError) {
                console.error(`❌ Failed to delete user from Auth: ${authDeleteError}`);
            }
        }
        // Delete from Firestore
        const firestoreUid = uid || (userToDelete === null || userToDelete === void 0 ? void 0 : userToDelete.uid);
        if (firestoreUid) {
            try {
                await admin.firestore().doc(`users/${firestoreUid}`).delete();
                deletionResults.firestoreDeleted = true;
                console.log(`✅ Deleted user document from Firestore: ${firestoreUid}`);
            }
            catch (firestoreDeleteError) {
                console.error(`❌ Failed to delete user from Firestore: ${firestoreDeleteError}`);
            }
        }
        // Also check if there are any related data to clean up
        if (firestoreUid) {
            // Delete user's bookings
            const bookingsSnapshot = await admin.firestore()
                .collection('bookings')
                .where('user_reference', '==', admin.firestore().doc(`users/${firestoreUid}`))
                .get();
            const batch = admin.firestore().batch();
            let bookingsDeleted = 0;
            bookingsSnapshot.forEach(doc => {
                batch.delete(doc.ref);
                bookingsDeleted++;
            });
            if (bookingsDeleted > 0) {
                await batch.commit();
                console.log(`✅ Deleted ${bookingsDeleted} bookings for user ${firestoreUid}`);
            }
            deletionResults.bookingsDeleted = bookingsDeleted;
        }
        return {
            success: true,
            message: `User deletion completed`,
            details: deletionResults
        };
    }
    catch (error) {
        console.error("❌ Error in deleteUserCompletely:", error);
        const errorMessage = error instanceof Error ? error.message : 'Unknown error';
        throw new functions.https.HttpsError('internal', `Failed to delete user: ${errorMessage}`);
    }
});
