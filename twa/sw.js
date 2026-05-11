// Service Worker for Calibration Calculator PWA
//
// CACHE_NAME bumps automatically when this file's bytes change because the
// version is appended below. To force a cache reset, change BUILD_TAG.
const BUILD_TAG = '2025-12-30';
const CACHE_NAME = `calib-calc::${BUILD_TAG}`;

const PRECACHE = [
    './',
    './index.html',
    './styles.css',
    './app.js',
    './manifest.json',
    './icons/Icon-192.png',
    './icons/Icon-512.png',
    './icons/apple-touch-icon.png',
    './icons/favicon-32.png',
];

// Install: precache the app shell. Use individual put() so a single missing
// asset (e.g. icons not yet generated) doesn't break install.
self.addEventListener('install', (event) => {
    event.waitUntil((async () => {
        const cache = await caches.open(CACHE_NAME);
        await Promise.all(PRECACHE.map(async (url) => {
            try {
                const res = await fetch(url, { cache: 'no-cache' });
                if (res.ok) await cache.put(url, res);
            } catch (e) {
                console.warn('[SW] precache skip:', url, e.message);
            }
        }));
        self.skipWaiting();
    })());
});

// Activate: purge old caches.
self.addEventListener('activate', (event) => {
    event.waitUntil((async () => {
        const keys = await caches.keys();
        await Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)));
        await self.clients.claim();
    })());
});

// Fetch strategy:
//   - Navigation requests  → network-first, fall back to cached index.html
//   - Same-origin static   → stale-while-revalidate
//   - Cross-origin (fonts) → cache-first with background refresh
self.addEventListener('fetch', (event) => {
    const req = event.request;
    if (req.method !== 'GET') return;

    const url = new URL(req.url);

    if (req.mode === 'navigate') {
        event.respondWith((async () => {
            try {
                const fresh = await fetch(req);
                const cache = await caches.open(CACHE_NAME);
                cache.put('./index.html', fresh.clone());
                return fresh;
            } catch {
                const cached = await caches.match('./index.html');
                return cached || Response.error();
            }
        })());
        return;
    }

    event.respondWith((async () => {
        const cache = await caches.open(CACHE_NAME);
        const cached = await cache.match(req);
        const networkFetch = fetch(req).then((res) => {
            if (res && res.ok && (url.origin === self.location.origin || res.type === 'cors')) {
                cache.put(req, res.clone()).catch(() => {});
            }
            return res;
        }).catch(() => null);
        return cached || (await networkFetch) || Response.error();
    })());
});

// Optional: clients can ask the SW to activate immediately.
self.addEventListener('message', (event) => {
    if (event.data && event.data.type === 'SKIP_WAITING') self.skipWaiting();
});
