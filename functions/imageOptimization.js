/**
 * Firebase Cloud Function for TripBasket Image Optimization
 * Automatically optimizes uploaded images:
 * - Converts JPG/PNG → WebP at 70-80% quality
 * - Resizes images larger than 1920px width to max 1920px
 * - Stores optimized version in Firebase Storage
 * - Updates download URLs to use optimized versions
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const sharp = require('sharp');
const { Storage } = require('@google-cloud/storage');

// Use lazy initialization to avoid conflicts
let storage;
let db;

function initServices() {
  if (!storage) {
    storage = new Storage();
    db = admin.firestore();
  }
  return { storage, db };
}

// Configuration
const OPTIMIZATION_CONFIG = {
  webpQuality: 75,        // 75% quality for WebP
  jpegQuality: 80,        // 80% quality for JPEG fallback
  maxWidth: 1920,         // Maximum width
  maxHeight: 1080,        // Maximum height
  optimizedPrefix: 'optimized_',
  skipOptimization: [     // Skip these file patterns
    'favicon',
    'icon-',
    'launcher',
    'thumbnail_'
  ]
};

/**
 * Cloud Function triggered when an image is uploaded to Firebase Storage
 */
exports.optimizeUploadedImage = functions.storage.object().onFinalize(async (object) => {
  const { bucket, name, contentType } = object;
  
  // Only process image files
  if (!contentType || !contentType.startsWith('image/')) {
    console.log('Not an image file, skipping optimization.');
    return null;
  }
  
  // Skip already optimized images
  if (name.includes(OPTIMIZATION_CONFIG.optimizedPrefix)) {
    console.log('Already optimized image, skipping.');
    return null;
  }
  
  // Skip small icons and system files
  if (OPTIMIZATION_CONFIG.skipOptimization.some(pattern => name.toLowerCase().includes(pattern))) {
    console.log('Skipping optimization for system/icon file:', name);
    return null;
  }
  
  try {
    console.log(`Starting optimization for: ${name}`);
    
    // Initialize services
    const { storage, db } = initServices();
    
    // Download the original image
    const bucketRef = storage.bucket(bucket);
    const originalFile = bucketRef.file(name);
    
    // Check if file still exists
    const [exists] = await originalFile.exists();
    if (!exists) {
      console.log('Original file no longer exists, skipping.');
      return null;
    }
    
    // Download image data
    const [imageBuffer] = await originalFile.download();
    
    // Get image metadata
    const metadata = await sharp(imageBuffer).metadata();
    console.log(`Original image: ${metadata.width}x${metadata.height}, ${metadata.format}, ${imageBuffer.length} bytes`);
    
    // Determine if resizing is needed
    let needsResize = false;
    let newWidth = metadata.width;
    let newHeight = metadata.height;
    
    if (metadata.width > OPTIMIZATION_CONFIG.maxWidth || metadata.height > OPTIMIZATION_CONFIG.maxHeight) {
      const ratio = Math.min(
        OPTIMIZATION_CONFIG.maxWidth / metadata.width,
        OPTIMIZATION_CONFIG.maxHeight / metadata.height
      );
      newWidth = Math.round(metadata.width * ratio);
      newHeight = Math.round(metadata.height * ratio);
      needsResize = true;
    }
    
    // Create Sharp pipeline
    let sharpPipeline = sharp(imageBuffer);
    
    // Apply resizing if needed
    if (needsResize) {
      sharpPipeline = sharpPipeline.resize(newWidth, newHeight, {
        kernel: sharp.kernel.lanczos3,
        withoutEnlargement: true
      });
      console.log(`Resizing from ${metadata.width}x${metadata.height} to ${newWidth}x${newHeight}`);
    }
    
    // Convert to WebP
    const optimizedBuffer = await sharpPipeline
      .webp({ 
        quality: OPTIMIZATION_CONFIG.webpQuality,
        effort: 6,  // Maximum compression effort
        progressive: true
      })
      .toBuffer();
    
    console.log(`Optimized size: ${optimizedBuffer.length} bytes`);
    
    // Generate optimized filename
    const pathParts = name.split('/');
    const filename = pathParts.pop();
    const directory = pathParts.join('/');
    const filenameWithoutExt = filename.split('.')[0];
    
    const optimizedFilename = `${OPTIMIZATION_CONFIG.optimizedPrefix}${filenameWithoutExt}.webp`;
    const optimizedPath = directory ? `${directory}/${optimizedFilename}` : optimizedFilename;
    
    // Upload optimized image
    const optimizedFile = bucketRef.file(optimizedPath);
    await optimizedFile.save(optimizedBuffer, {
      metadata: {
        contentType: 'image/webp',
        metadata: {
          originalFile: name,
          optimizedBy: 'tripbasket-image-optimizer',
          originalSize: imageBuffer.length,
          optimizedSize: optimizedBuffer.length,
          compressionRatio: ((imageBuffer.length - optimizedBuffer.length) / imageBuffer.length * 100).toFixed(2) + '%',
          originalDimensions: `${metadata.width}x${metadata.height}`,
          optimizedDimensions: `${newWidth}x${newHeight}`,
          optimizedAt: new Date().toISOString()
        }
      }
    });
    
    // Make optimized file publicly accessible if original was public
    try {
      const [originalMetadata] = await originalFile.getMetadata();
      if (originalMetadata.metadata && originalMetadata.metadata.firebaseStorageDownloadTokens) {
        await optimizedFile.makePublic();
      }
    } catch (error) {
      console.log('Could not make optimized file public:', error);
    }
    
    // Get download URLs
    const [optimizedUrl] = await optimizedFile.getSignedUrl({
      action: 'read',
      expires: '03-09-2491' // Far future date
    });
    
    // Log optimization results
    const savings = imageBuffer.length - optimizedBuffer.length;
    const savingsPercent = (savings / imageBuffer.length * 100).toFixed(2);
    
    console.log(`✅ Optimization completed:`);
    console.log(`   Original: ${imageBuffer.length} bytes`);
    console.log(`   Optimized: ${optimizedBuffer.length} bytes`);
    console.log(`   Savings: ${savings} bytes (${savingsPercent}%)`);
    console.log(`   Optimized file: ${optimizedPath}`);
    console.log(`   Download URL: ${optimizedUrl}`);
    
    // Update any Firestore documents that reference this image
    await updateImageReferences(name, optimizedPath, optimizedUrl, db);
    
    return {
      success: true,
      originalFile: name,
      optimizedFile: optimizedPath,
      originalSize: imageBuffer.length,
      optimizedSize: optimizedBuffer.length,
      savings: savings,
      savingsPercent: savingsPercent
    };
    
  } catch (error) {
    console.error('Error optimizing image:', error);
    return {
      success: false,
      error: error.message,
      originalFile: name
    };
  }
});

/**
 * Update Firestore documents that reference the original image
 */
async function updateImageReferences(originalPath, optimizedPath, optimizedUrl, db) {
  try {
    console.log(`Updating references from ${originalPath} to ${optimizedPath}`);
    
    // Update trips collection
    const tripsSnapshot = await db.collection('trips')
      .where('image', '==', originalPath)
      .get();
    
    const updatePromises = [];
    
    tripsSnapshot.forEach(doc => {
      updatePromises.push(
        doc.ref.update({
          image: optimizedPath,
          imageUrl: optimizedUrl,
          optimizedAt: admin.firestore.FieldValue.serverTimestamp()
        })
      );
      console.log(`Updated trip document: ${doc.id}`);
    });
    
    // Update agencies collection
    const agenciesSnapshot = await db.collection('agencies')
      .where('logo', '==', originalPath)
      .get();
    
    agenciesSnapshot.forEach(doc => {
      updatePromises.push(
        doc.ref.update({
          logo: optimizedPath,
          logoUrl: optimizedUrl,
          optimizedAt: admin.firestore.FieldValue.serverTimestamp()
        })
      );
      console.log(`Updated agency document: ${doc.id}`);
    });
    
    // Update user profiles if they use this image
    const usersSnapshot = await db.collection('users')
      .where('photo_url', '==', originalPath)
      .get();
    
    usersSnapshot.forEach(doc => {
      updatePromises.push(
        doc.ref.update({
          photo_url: optimizedPath,
          photoUrl: optimizedUrl,
          optimizedAt: admin.firestore.FieldValue.serverTimestamp()
        })
      );
      console.log(`Updated user document: ${doc.id}`);
    });
    
    await Promise.all(updatePromises);
    console.log(`Updated ${updatePromises.length} document references`);
    
  } catch (error) {
    console.error('Error updating image references:', error);
  }
}

/**
 * HTTP function to manually trigger optimization for existing images
 */
exports.optimizeExistingImages = functions.https.onCall(async (data, context) => {
  // Check if user is authenticated and has admin privileges
  if (!context.auth || !context.auth.token.admin) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Only admin users can trigger bulk optimization.'
    );
  }
  
  const { bucket, path } = data;
  
  try {
    const { storage } = initServices();
    const bucketRef = storage.bucket(bucket || 'tripbasket-sctkxj.appspot.com');
    const [files] = await bucketRef.getFiles({ prefix: path || 'images/' });
    
    const optimizationPromises = [];
    
    for (const file of files) {
      const { name, metadata } = file;
      
      // Skip if already optimized or not an image
      if (name.includes(OPTIMIZATION_CONFIG.optimizedPrefix) || 
          !metadata.contentType?.startsWith('image/')) {
        continue;
      }
      
      // Trigger optimization by simulating the storage trigger
      optimizationPromises.push(
        exports.optimizeUploadedImage({
          bucket: bucketRef.name,
          name: name,
          contentType: metadata.contentType
        })
      );
    }
    
    const results = await Promise.allSettled(optimizationPromises);
    const successful = results.filter(r => r.status === 'fulfilled').length;
    const failed = results.filter(r => r.status === 'rejected').length;
    
    return {
      message: `Bulk optimization completed`,
      totalFiles: files.length,
      processed: optimizationPromises.length,
      successful,
      failed
    };
    
  } catch (error) {
    console.error('Error in bulk optimization:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

/**
 * HTTP function to get optimization statistics
 */
exports.getOptimizationStats = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  try {
    const { storage } = initServices();
    const bucket = storage.bucket();
    const [files] = await bucket.getFiles({ prefix: 'images/' });
    
    let totalOriginalSize = 0;
    let totalOptimizedSize = 0;
    let optimizedCount = 0;
    let originalCount = 0;
    
    for (const file of files) {
      const [metadata] = await file.getMetadata();
      
      if (file.name.includes(OPTIMIZATION_CONFIG.optimizedPrefix)) {
        optimizedCount++;
        if (metadata.metadata && metadata.metadata.optimizedSize) {
          totalOptimizedSize += parseInt(metadata.metadata.optimizedSize);
        }
      } else if (metadata.contentType?.startsWith('image/')) {
        originalCount++;
        totalOriginalSize += parseInt(metadata.size || 0);
      }
    }
    
    const totalSavings = totalOriginalSize - totalOptimizedSize;
    const savingsPercent = totalOriginalSize > 0 ? (totalSavings / totalOriginalSize * 100) : 0;
    
    return {
      totalFiles: files.length,
      originalImages: originalCount,
      optimizedImages: optimizedCount,
      totalOriginalSize,
      totalOptimizedSize,
      totalSavings,
      savingsPercent: savingsPercent.toFixed(2)
    };
    
  } catch (error) {
    console.error('Error getting optimization stats:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});