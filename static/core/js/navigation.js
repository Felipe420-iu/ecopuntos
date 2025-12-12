/**
 * NAVIGATION.JS - Sistema de Navegación y Scroll
 * Gestiona el comportamiento del navbar y la navegación suave
 */

(function() {
  'use strict';

  /**
   * Actualiza el estado del navbar al hacer scroll
   */
  function updateNavbarOnScroll() {
    const navbar = document.querySelector('.navbar-eco');
    if (!navbar) return;

    const scrollY = window.scrollY;
    
    if (scrollY > 50) {
      navbar.classList.add('scrolled');
    } else {
      navbar.classList.remove('scrolled');
    }
  }

  /**
   * Resalta el enlace activo según la sección visible
   */
  function highlightActiveSection() {
    const sections = document.querySelectorAll('section[id]');
    const navLinks = document.querySelectorAll('.nav-link-eco');
    
    if (sections.length === 0 || navLinks.length === 0) return;

    const scrollY = window.pageYOffset;

    sections.forEach(section => {
      const sectionHeight = section.offsetHeight;
      const sectionTop = section.offsetTop - 100; // Offset para compensar navbar
      const sectionId = section.getAttribute('id');
      
      if (scrollY > sectionTop && scrollY <= sectionTop + sectionHeight) {
        navLinks.forEach(link => {
          link.classList.remove('active');
          if (link.getAttribute('href') === `#${sectionId}`) {
            link.classList.add('active');
          }
        });
      }
    });
  }

  /**
   * Scroll suave al hacer click en enlaces del navbar
   */
  function setupSmoothScroll() {
    // Solo aplicar a enlaces de navegación específicos, no a todos los enlaces con #
    const navLinks = document.querySelectorAll('.nav-link-eco, .navbar-nav a[href^="#"]');
    
    navLinks.forEach(link => {
      link.addEventListener('click', function(e) {
        const href = this.getAttribute('href');
        
        // Ignorar enlaces que no son anclas válidas
        if (href === '#' || href === '#!' || !href) return;
        
        const targetElement = document.querySelector(href);
        if (!targetElement) return;
        
        e.preventDefault();
        
        // Cerrar el menú móvil si está abierto
        const navbarCollapse = document.querySelector('.navbar-collapse');
        const navbarToggler = document.querySelector('.navbar-toggler-eco');
        
        if (navbarCollapse && navbarCollapse.classList.contains('show')) {
          navbarToggler.click();
        }
        
        // Calcular posición con offset del navbar
        const navbar = document.querySelector('.navbar-eco');
        const navbarHeight = navbar ? navbar.offsetHeight : 70;
        const targetPosition = targetElement.offsetTop - navbarHeight - 20;
        
        // Scroll suave
        window.scrollTo({
          top: targetPosition,
          behavior: 'smooth'
        });
      });
    });
  }

  /**
   * Cierra el menú móvil al hacer click fuera
   */
  function setupMobileMenuClose() {
    const navbarCollapse = document.querySelector('.navbar-collapse');
    const navbarToggler = document.querySelector('.navbar-toggler-eco');
    
    if (!navbarCollapse || !navbarToggler) return;

    document.addEventListener('click', function(e) {
      const isClickInsideNavbar = navbarCollapse.contains(e.target) || navbarToggler.contains(e.target);
      
      if (!isClickInsideNavbar && navbarCollapse.classList.contains('show')) {
        navbarToggler.click();
      }
    });
  }

  /**
   * Agrega efecto de hover en los enlaces del navbar
   */
  function setupNavLinkEffects() {
    const navLinks = document.querySelectorAll('.nav-link-eco');
    
    navLinks.forEach(link => {
      link.addEventListener('mouseenter', function() {
        this.style.transform = 'translateY(-2px)';
      });
      
      link.addEventListener('mouseleave', function() {
        this.style.transform = 'translateY(0)';
      });
    });
  }

  /**
   * Muestra/oculta el botón de "Volver arriba"
   */
  function setupBackToTop() {
    const backToTopBtn = document.getElementById('back-to-top');
    if (!backToTopBtn) return;

    window.addEventListener('scroll', function() {
      if (window.scrollY > 300) {
        backToTopBtn.style.display = 'flex';
        backToTopBtn.style.opacity = '1';
      } else {
        backToTopBtn.style.opacity = '0';
        setTimeout(() => {
          if (window.scrollY <= 300) {
            backToTopBtn.style.display = 'none';
          }
        }, 300);
      }
    });

    backToTopBtn.addEventListener('click', function(e) {
      e.preventDefault();
      window.scrollTo({
        top: 0,
        behavior: 'smooth'
      });
    });
  }

  /**
   * Throttle function para optimizar eventos de scroll
   */
  function throttle(func, delay) {
    let lastCall = 0;
    return function(...args) {
      const now = Date.now();
      if (now - lastCall >= delay) {
        lastCall = now;
        func(...args);
      }
    };
  }

  /**
   * Inicializa todos los handlers de navegación
   */
  function initNavigation() {
    console.log('🧭 Inicializando sistema de navegación...');
    
    // Setup scroll handlers con throttle
    const throttledScrollHandler = throttle(() => {
      updateNavbarOnScroll();
      highlightActiveSection();
    }, 100);
    
    window.addEventListener('scroll', throttledScrollHandler);
    
    // Setup smooth scroll
    setupSmoothScroll();
    
    // Setup mobile menu
    setupMobileMenuClose();
    
    // Setup nav link effects
    setupNavLinkEffects();
    
    // Setup back to top button
    setupBackToTop();
    
    // Initial check
    updateNavbarOnScroll();
    highlightActiveSection();
    
    console.log('✅ Sistema de navegación inicializado');
  }

  // Inicializar cuando el DOM esté listo
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initNavigation);
  } else {
    initNavigation();
  }

  // Exportar funciones para uso externo
  window.NavigationSystem = {
    updateNavbar: updateNavbarOnScroll,
    highlightActive: highlightActiveSection,
    init: initNavigation
  };

})();
