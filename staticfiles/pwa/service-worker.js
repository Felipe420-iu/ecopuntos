// Service Worker para EcoPuntos PWA
const CACHE_NAME = 'ecopuntos-v1.0.0';
const RUNTIME_CACHE = 'ecopuntos-runtime';
const OFFLINE_URL = '/offline/';

// Archivos estáticos para cachear en instalación
const STATIC_CACHE_URLS = [
  '/',
  '/static/pwa/manifest.json',
  '/static/pwa/icons/eco.png',
  OFFLINE_URL
];

// Instalación del Service Worker
self.addEventListener('install', (event) => {
  console.log('[SW] Instalando Service Worker...');
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(async (cache) => {
        console.log('[SW] Precacheando archivos estáticos');
        // Intentar cachear cada recurso individualmente para evitar que un fallo detenga toda la instalación
        await Promise.all(STATIC_CACHE_URLS.map(async (url) => {
          try {
            const response = await fetch(url, { cache: 'reload' });
            if (!response || !response.ok) {
              console.warn('[SW] Recurso no disponible para precache:', url, response && response.status);
              return;
            }
            await cache.put(url, response.clone());
          } catch (err) {
            console.warn('[SW] Error al precachear', url, err);
          }
        }));
      })
      .catch((error) => {
        console.error('[SW] Error abriendo cache:', error);
      })
  );
  self.skipWaiting();
});

// Activación del Service Worker
self.addEventListener('activate', (event) => {
  console.log('[SW] Activando Service Worker...');
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME && cacheName !== RUNTIME_CACHE) {
            console.log('[SW] Eliminando caché antigua:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
  return self.clients.claim();
});

// Estrategia de caché: Network First con fallback a Cache
self.addEventListener('fetch', (event) => {
  // Ignorar solicitudes no HTTP/HTTPS
  if (!event.request.url.startsWith('http')) {
    return;
  }

  // Ignorar solicitudes POST, PUT, DELETE (solo cachear GET)
  if (event.request.method !== 'GET') {
    return;
  }

  event.respondWith((async () => {
    try {
      // Intentar primero la red
      const response = await fetch(event.request);

      // Si la respuesta del servidor es un error 5xx, intentar fallback a caché
      if (!response || response.status >= 500) {
        console.warn('[SW] Respuesta de red inválida o 5xx:', event.request.url, response && response.status);
        const cached = await caches.match(event.request);
        if (cached) return cached;

        if (event.request.mode === 'navigate') {
          const offlineResponse = await caches.match(OFFLINE_URL);
          if (offlineResponse) return offlineResponse;
        }

        // Devolver la respuesta original (por ejemplo 502) si no hay fallback
        return response;
      }

      // Si la respuesta es válida, clonarla y guardarla en caché (solo 200 y mismo origen)
      if (response && response.status === 200 && event.request.url.startsWith(self.location.origin)) {
        const responseClone = response.clone();
        caches.open(RUNTIME_CACHE).then((cache) => cache.put(event.request, responseClone)).catch((err) => {
          console.warn('[SW] Error guardando en cache runtime:', err);
        });
      }

      return response;
    } catch (err) {
      // Si falla la red (offline o excepción), buscar en caché
      console.log('[SW] Error en fetch, buscando en caché:', event.request.url, err);
      const cachedResponse = await caches.match(event.request);
      if (cachedResponse) return cachedResponse;

      // Si es navegación y no hay caché, mostrar página offline
      if (event.request.mode === 'navigate') {
        const offlineResponse = await caches.match(OFFLINE_URL);
        if (offlineResponse) return offlineResponse;
      }

      // Respuesta por defecto si nada funciona
      return new Response('Sin conexión. Por favor verifica tu red.', {
        status: 503,
        statusText: 'Service Unavailable',
        headers: new Headers({ 'Content-Type': 'text/plain' })
      });
    }
  })());
});

// Manejo de mensajes desde el cliente
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
  
  if (event.data && event.data.type === 'CLEAR_CACHE') {
    event.waitUntil(
      caches.keys().then((cacheNames) => {
        return Promise.all(
          cacheNames.map((cacheName) => caches.delete(cacheName))
        );
      })
    );
  }
});

// Sincronización en segundo plano
self.addEventListener('sync', (event) => {
  console.log('[SW] Sincronización en segundo plano:', event.tag);
  if (event.tag === 'sync-data') {
    event.waitUntil(syncData());
  }
});

async function syncData() {
  try {
    // Aquí puedes agregar lógica de sincronización
    console.log('[SW] Sincronizando datos...');
  } catch (error) {
    console.error('[SW] Error en sincronización:', error);
  }
}

// Notificaciones push (opcional para futuro)
self.addEventListener('push', (event) => {
  console.log('[SW] Push recibido');
  const options = {
    body: event.data ? event.data.text() : 'Nueva notificación de EcoPuntos',
    icon: '/static/pwa/icons/eco.png',
    badge: '/static/pwa/icons/eco.png',
    vibrate: [200, 100, 200],
    tag: 'ecopuntos-notification'
  };

  event.waitUntil(
    self.registration.showNotification('EcoPuntos', options)
  );
});

// Click en notificación
self.addEventListener('notificationclick', (event) => {
  console.log('[SW] Notificación clickeada');
  event.notification.close();
  event.waitUntil(
    clients.openWindow('/')
  );
});
