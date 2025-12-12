/**
 * VIDEOS.JS - Optimización de Videos y Backgrounds
 * Gestiona la carga inteligente de videos según el dispositivo
 */

(function() {
  'use strict';

  /**
   * Detecta si el dispositivo es móvil
   */
  function isMobileDevice() {
    return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
  }

  /**
   * Detecta si la conexión es lenta
   */
  function isSlowConnection() {
    const connection = navigator.connection || navigator.mozConnection || navigator.webkitConnection;
    if (connection) {
      // Si la conexión efectiva es 2g o slow-2g, considerarla lenta
      if (connection.effectiveType === '2g' || connection.effectiveType === 'slow-2g') {
        return true;
      }
      // Si saveData está activado, el usuario quiere ahorrar datos
      if (connection.saveData) {
        return true;
      }
    }
    return false;
  }

  /**
   * Optimiza el video según el dispositivo
   */
  function optimizeVideo(video) {
    if (!video) return;

    const isMobile = isMobileDevice();
    const slowConnection = isSlowConnection();

    // En móviles o conexiones lentas, no cargar el video
    if (isMobile || slowConnection) {
      video.style.display = 'none';
      
      // Buscar el contenedor padre
      const container = video.closest('.video-background, .category-video');
      if (container) {
        // Agregar clase para usar imagen de fallback
        container.classList.add('no-video');
        
        // Obtener el poster del video como background
        const poster = video.getAttribute('poster');
        if (poster) {
          container.style.backgroundImage = `url('${poster}')`;
          container.style.backgroundSize = 'cover';
          container.style.backgroundPosition = 'center';
        }
      }
      
      return;
    }

    // En dispositivos de escritorio
    video.setAttribute('preload', 'metadata'); // Solo cargar metadata inicialmente
    video.setAttribute('playsinline', ''); // Evitar fullscreen en iOS
    
    // Lazy loading: solo cargar cuando esté cerca del viewport
    if ('IntersectionObserver' in window) {
      const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            // El video está visible, cargar y reproducir
            const videoElement = entry.target;
            videoElement.load();
            videoElement.play().catch(err => {
              console.log('Autoplay prevented:', err);
            });
            observer.unobserve(videoElement);
          }
        });
      }, {
        rootMargin: '50px' // Empezar a cargar 50px antes de que sea visible
      });
      
      observer.observe(video);
    } else {
      // Fallback para navegadores sin IntersectionObserver
      video.load();
      video.play().catch(err => {
        console.log('Autoplay prevented:', err);
      });
    }
  }

  /**
   * Pausa videos cuando no están en el viewport
   */
  function pauseOffscreenVideos() {
    if (!('IntersectionObserver' in window)) return;

    const videos = document.querySelectorAll('video');
    
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        const video = entry.target;
        if (entry.isIntersecting) {
          video.play().catch(err => console.log('Play error:', err));
        } else {
          video.pause();
        }
      });
    }, {
      threshold: 0.25 // Video debe estar al menos 25% visible
    });

    videos.forEach(video => observer.observe(video));
  }

  /**
   * Gestiona el volumen de los videos
   */
  function setupVideoControls() {
    const videos = document.querySelectorAll('video');
    
    videos.forEach(video => {
      // Todos los videos de fondo deben estar silenciados
      video.muted = true;
      video.volume = 0;
      
      // Agregar control de hover para videos específicos (si se requiere)
      video.addEventListener('mouseenter', function() {
        // Opcional: agregar controles en hover
      });
    });
  }

  /**
   * Reinicia videos cuando terminan (para loops manuales)
   */
  function setupVideoLoops() {
    const videos = document.querySelectorAll('video');
    
    videos.forEach(video => {
      video.addEventListener('ended', function() {
        this.currentTime = 0;
        this.play().catch(err => console.log('Loop error:', err));
      });
    });
  }

  /**
   * Inicializa la optimización de videos
   */
  function initVideoOptimization() {
    console.log('🎥 Inicializando optimización de videos...');
    
    // Seleccionar todos los videos de la página
    const videos = document.querySelectorAll('video');
    
    if (videos.length === 0) {
      console.log('No se encontraron videos para optimizar');
      return;
    }

    console.log(`📹 Optimizando ${videos.length} videos...`);
    
    // Aplicar optimización a cada video
    videos.forEach(optimizeVideo);
    
    // Configurar controles
    setupVideoControls();
    
    // Configurar loops
    setupVideoLoops();
    
    // Pausar videos fuera del viewport
    pauseOffscreenVideos();
    
    console.log('✅ Optimización de videos completada');
  }

  /**
   * Muestra información de conexión (solo en desarrollo)
   */
  function logConnectionInfo() {
    const connection = navigator.connection || navigator.mozConnection || navigator.webkitConnection;
    if (connection) {
      console.log('📡 Información de conexión:', {
        effectiveType: connection.effectiveType,
        downlink: connection.downlink,
        rtt: connection.rtt,
        saveData: connection.saveData
      });
    }
    console.log('📱 Dispositivo móvil:', isMobileDevice());
    console.log('🐌 Conexión lenta:', isSlowConnection());
  }

  // Inicializar cuando el DOM esté listo
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initVideoOptimization);
  } else {
    initVideoOptimization();
  }

  // Log de información (comentar en producción)
  // logConnectionInfo();

  // Exportar funciones para uso externo si es necesario
  window.VideoOptimizer = {
    isMobileDevice,
    isSlowConnection,
    optimizeVideo,
    init: initVideoOptimization
  };

})();
