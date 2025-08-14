const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.onUserDeleted = functions.auth.user().onDelete(async (user) => {
  let firestore = admin.firestore();
  let userRef = firestore.doc("users/" + user.uid);
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
