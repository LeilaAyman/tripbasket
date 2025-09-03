const admin = require('firebase-admin');
const { getFirestore } = require('firebase-admin/firestore');

// Initialize Firebase Admin
admin.initializeApp({
  projectId: 'tripbasket-sctkxj'
});

const db = getFirestore();

async function cleanupCart() {
  console.log('🧹 Starting cart cleanup...');
  
  try {
    // Get all cart items
    const cartSnapshot = await db.collection('cart').get();
    console.log(`📦 Found ${cartSnapshot.docs.length} cart items`);
    
    let deletedCount = 0;
    let validCount = 0;
    
    for (const cartDoc of cartSnapshot.docs) {
      const cartData = cartDoc.data();
      const tripReference = cartData.tripReference;
      
      if (!tripReference) {
        console.log(`❌ Cart item ${cartDoc.id} has null trip reference, deleting...`);
        await cartDoc.ref.delete();
        deletedCount++;
        continue;
      }
      
      // Check if the referenced trip still exists
      try {
        const tripDoc = await tripReference.get();
        if (!tripDoc.exists) {
          console.log(`❌ Trip ${tripReference.id} no longer exists, deleting cart item ${cartDoc.id}...`);
          await cartDoc.ref.delete();
          deletedCount++;
        } else {
          console.log(`✅ Cart item ${cartDoc.id} references valid trip ${tripReference.id}`);
          validCount++;
        }
      } catch (e) {
        console.log(`❌ Error checking trip ${tripReference.id}, deleting cart item ${cartDoc.id}: ${e.message}`);
        await cartDoc.ref.delete();
        deletedCount++;
      }
      
      // Small delay to avoid hitting rate limits
      await new Promise(resolve => setTimeout(resolve, 100));
    }
    
    console.log('🎉 Cleanup completed!');
    console.log(`✅ Valid cart items: ${validCount}`);
    console.log(`❌ Deleted orphaned items: ${deletedCount}`);
    
  } catch (e) {
    console.log(`💥 Error during cleanup: ${e.message}`);
  }
  
  process.exit(0);
}

cleanupCart();