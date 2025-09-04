// Ultra-Performance Service Worker for TripBasket
// Targets: TBT < 500ms, Speed Index < 5s
const CACHE_NAME = 'tripbasket-v2.0-perf';
const ASSETS_CACHE = 'tripbasket-assets-v2.0';

// Critical resources for immediate caching
const CRITICAL_RESOURCES = [
  '/',
  '/main.dart.js',
  '/flutter.js',
  '/runtime.js', // Split bundle
  '/vendor.js',  // Split bundle
  '/app.js',     // Split bundle
  '/manifest.json',
  '/favicon.png'
];

// Asset patterns for performance-first caching
const ASSET_PATTERNS = [
  /\.(?:js|css|woff2|webp)$/,
  /\/assets\/images\/optimized\//,
  /\/icons\//
];

// Performance-optimized install
self.addEventListener('install', event => {
  console.log('🚀 SW: Installing performance-optimized service worker');
  
  event.waitUntil(
    Promise.all([
      // Cache critical resources immediately
      caches.open(CACHE_NAME).then(cache => {
        console.log('🎯 SW: Caching critical resources');
        return cache.addAll(CRITICAL_RESOURCES.map(url => new Request(url, {
          cache: 'reload' // Always get fresh versions during install
        })));
      }),
      
      // Open assets cache
      caches.open(ASSETS_CACHE)
    ]).then(() => {
      console.log('✅ SW: Installation complete');
      // Skip waiting for immediate activation
      return self.skipWaiting();
    }).catch(err => {
      console.error('❌ SW: Installation failed', err);
    })
  );
});

// Aggressive cache cleanup on activate
self.addEventListener('activate', event => {
  console.log('🔄 SW: Activating and cleaning old caches');
  
  event.waitUntil(
    Promise.all([
      // Clean up old caches
      caches.keys().then(cacheNames => {
        const deletions = cacheNames
          .filter(name => name.startsWith('tripbasket-') && !name.includes('v2.0'))
          .map(name => {
            console.log(`🗑️ SW: Deleting old cache: ${name}`);
            return caches.delete(name);
          });
        return Promise.all(deletions);
      }),
      
      // Take control of all clients immediately
      self.clients.claim()
    ]).then(() => {
      console.log('✅ SW: Activation complete, all clients claimed');
    })
  );
});

// Ultra-fast fetch strategy
self.addEventListener('fetch', event => {
  const { request } = event;
  const url = new URL(request.url);
  
  // Skip non-GET requests
  if (request.method !== 'GET') return;
  
  // Skip Firebase APIs and external resources during critical loading
  if (url.hostname !== self.location.hostname) {
    // Only cache Google Fonts and Firebase JS
    if (url.hostname.includes('gstatic.com') || url.hostname.includes('googleapis.com')) {
      event.respondWith(networkFirstWithFallback(request));
    }
    return;
  }
  
  // Critical resources: Cache-first with network fallback
  if (CRITICAL_RESOURCES.includes(url.pathname) || url.pathname === '/') {
    event.respondWith(cacheFirstStrategy(request));
    return;
  }
  
  // Split bundle files: Cache-first
  if (url.pathname.endsWith('.js') && (
    url.pathname.includes('runtime.js') || 
    url.pathname.includes('vendor.js') || 
    url.pathname.includes('app.js')
  )) {
    event.respondWith(cacheFirstStrategy(request));
    return;
  }
  
  // Assets: Cache-first with long TTL
  if (ASSET_PATTERNS.some(pattern => pattern.test(url.pathname))) {
    event.respondWith(cacheFirstStrategy(request, ASSETS_CACHE));
    return;
  }
  
  // Everything else: Network-first for freshness
  event.respondWith(networkFirstWithFallback(request));
});

// Cache-first strategy for maximum performance
async function cacheFirstStrategy(request, cacheName = CACHE_NAME) {
  try {
    const cache = await caches.open(cacheName);
    const cached = await cache.match(request);
    
    if (cached) {
      // Serve cached version immediately
      console.log(`⚡ SW: Cache hit for ${request.url}`);
      
      // Background update for critical resources
      if (CRITICAL_RESOURCES.includes(new URL(request.url).pathname)) {
        updateCacheInBackground(request, cache);
      }
      
      return cached;
    }
    
    // Not in cache, fetch from network
    console.log(`🌐 SW: Cache miss, fetching ${request.url}`);
    const response = await fetch(request);
    
    if (response.status === 200) {
      // Cache successful responses
      cache.put(request, response.clone());
    }
    
    return response;
  } catch (error) {
    console.error(`❌ SW: Cache-first failed for ${request.url}`, error);
    
    // Fallback for critical resources
    if (request.url.includes('.js') || request.url.includes('.css')) {
      return new Response('// Offline fallback', { 
        headers: { 'Content-Type': 'application/javascript' }
      });
    }
    
    throw error;
  }
}

// Network-first with cache fallback
async function networkFirstWithFallback(request) {
  try {
    const response = await fetch(request);
    
    if (response.status === 200) {
      // Cache successful responses for assets
      if (ASSET_PATTERNS.some(pattern => pattern.test(request.url))) {
        const cache = await caches.open(ASSETS_CACHE);
        cache.put(request, response.clone());
      }
    }
    
    return response;
  } catch (error) {
    console.log(`🔄 SW: Network failed, trying cache for ${request.url}`);
    
    // Try cache as fallback
    const cached = await caches.match(request);
    if (cached) {
      return cached;
    }
    
    throw error;
  }
}

// Background cache update for critical resources
async function updateCacheInBackground(request, cache) {
  try {
    const response = await fetch(request, { cache: 'reload' });
    if (response.status === 200) {
      await cache.put(request, response);
      console.log(`🔄 SW: Background updated cache for ${request.url}`);
    }
  } catch (error) {
    console.log(`⚠️ SW: Background update failed for ${request.url}`);
  }
}

// Background sync for critical updates
self.addEventListener('sync', event => {
  if (event.tag === 'critical-update') {
    event.waitUntil(
      updateCriticalAssets()
    );
  }
});

// Update critical assets in background
async function updateCriticalAssets() {
  try {
    const cache = await caches.open(STATIC_CACHE);
    const updatePromises = CRITICAL_ASSETS.map(async (asset) => {
      try {
        const response = await fetch(asset);
        if (response.ok) {
          await cache.put(asset, response);
        }
      } catch (err) {
        console.log('[SW] Failed to update asset:', asset, err);
      }
    });
    
    await Promise.all(updatePromises);
    console.log('[SW] Critical assets updated');
  } catch (err) {
    console.log('[SW] Failed to update critical assets:', err);
  }
}

// Push notifications (future enhancement)
self.addEventListener('push', event => {
  if (event.data) {
    const data = event.data.json();
    self.registration.showNotification(data.title, {
      body: data.body,
      icon: '/icon-192.png',
      badge: '/badge-72.png'
    });
  }
});