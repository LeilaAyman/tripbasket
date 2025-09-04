// TripBasket Optimized Service Worker
const CACHE_NAME = 'tripbasket-v2025-01-04';
const STATIC_CACHE = 'tripbasket-static-v1';
const DYNAMIC_CACHE = 'tripbasket-dynamic-v1';

// Critical resources to cache immediately
const CRITICAL_ASSETS = [
  '/',
  '/flutter.js',
  '/main.dart.js',
  '/assets/AssetManifest.json',
  '/assets/FontManifest.json',
  '/assets/images/optimized/200611101955-01-egypt-dahab.webp',
  '/manifest.json'
];

// Resources to cache on demand
const CACHE_PATTERNS = [
  /\/assets\/images\/optimized\/.+\.webp$/,
  /\/assets\/fonts\/.+\.(woff2|woff|ttf)$/,
  /\/assets\/.+\.json$/
];

// Install event - cache critical assets
self.addEventListener('install', event => {
  console.log('[SW] Installing service worker');
  event.waitUntil(
    caches.open(STATIC_CACHE)
      .then(cache => {
        console.log('[SW] Caching critical assets');
        return cache.addAll(CRITICAL_ASSETS);
      })
      .then(() => self.skipWaiting())
  );
});

// Activate event - clean old caches
self.addEventListener('activate', event => {
  console.log('[SW] Activating service worker');
  event.waitUntil(
    caches.keys()
      .then(cacheNames => {
        return Promise.all(
          cacheNames
            .filter(cacheName => 
              cacheName !== STATIC_CACHE && 
              cacheName !== DYNAMIC_CACHE
            )
            .map(cacheName => {
              console.log('[SW] Deleting old cache:', cacheName);
              return caches.delete(cacheName);
            })
        );
      })
      .then(() => self.clients.claim())
  );
});

// Fetch event - serve from cache with fallback
self.addEventListener('fetch', event => {
  const { request } = event;
  const url = new URL(request.url);
  
  // Skip non-GET requests
  if (request.method !== 'GET') {
    return;
  }
  
  // Skip Firebase and external API requests
  if (url.origin !== location.origin) {
    return;
  }
  
  event.respondWith(
    caches.match(request)
      .then(response => {
        // Return cached version if available
        if (response) {
          console.log('[SW] Serving from cache:', request.url);
          return response;
        }
        
        // Fetch and cache for supported resources
        return fetch(request)
          .then(response => {
            // Only cache successful responses
            if (!response || response.status !== 200 || response.type !== 'basic') {
              return response;
            }
            
            // Check if resource should be cached
            const shouldCache = CACHE_PATTERNS.some(pattern => 
              pattern.test(request.url)
            ) || CRITICAL_ASSETS.includes(url.pathname);
            
            if (shouldCache) {
              const responseToCache = response.clone();
              caches.open(DYNAMIC_CACHE)
                .then(cache => {
                  console.log('[SW] Caching resource:', request.url);
                  cache.put(request, responseToCache);
                });
            }
            
            return response;
          })
          .catch(() => {
            // Fallback for offline scenarios
            if (url.pathname === '/') {
              return caches.match('/');
            }
            
            // Return offline page or placeholder
            return new Response(
              '<html><body><h1>Offline</h1><p>Please check your connection.</p></body></html>',
              { headers: { 'Content-Type': 'text/html' } }
            );
          });
      })
  );
});

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