/**
 * MODAL.JS - Sistema de Modales y Formularios
 * Gestiona el modal de donación y validación de formularios
 */

(function() {
  'use strict';

  /**
   * Inicializa el modal de donación
   */
  function initDonationModal() {
    const donationBtns = document.querySelectorAll('[data-bs-target="#donationModal"]');
    const modal = document.getElementById('donationModal');
    
    if (!modal) return;

    console.log('💰 Inicializando modal de donación...');

    // Agregar listeners a todos los botones de donación
    donationBtns.forEach(btn => {
      btn.addEventListener('click', function() {
        console.log('Modal de donación abierto');
      });
    });

    // Limpiar formulario cuando se cierra el modal
    modal.addEventListener('hidden.bs.modal', function() {
      const form = modal.querySelector('form');
      if (form) {
        form.reset();
        clearFormErrors(form);
      }
    });
  }

  /**
   * Valida el formulario de donación
   */
  function validateDonationForm(form) {
    if (!form) return false;

    let isValid = true;
    const errors = [];

    // Validar nombre
    const nameInput = form.querySelector('#donorName');
    if (nameInput && nameInput.value.trim() === '') {
      errors.push('El nombre es requerido');
      markFieldAsError(nameInput);
      isValid = false;
    } else if (nameInput) {
      markFieldAsValid(nameInput);
    }

    // Validar email
    const emailInput = form.querySelector('#donorEmail');
    if (emailInput) {
      const emailValue = emailInput.value.trim();
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      
      if (emailValue === '') {
        errors.push('El email es requerido');
        markFieldAsError(emailInput);
        isValid = false;
      } else if (!emailRegex.test(emailValue)) {
        errors.push('El email no es válido');
        markFieldAsError(emailInput);
        isValid = false;
      } else {
        markFieldAsValid(emailInput);
      }
    }

    // Validar monto
    const amountInput = form.querySelector('#donationAmount');
    if (amountInput) {
      const amount = parseFloat(amountInput.value);
      
      if (isNaN(amount) || amount <= 0) {
        errors.push('El monto debe ser mayor a 0');
        markFieldAsError(amountInput);
        isValid = false;
      } else {
        markFieldAsValid(amountInput);
      }
    }

    // Validar mensaje (opcional pero con límite)
    const messageInput = form.querySelector('#donationMessage');
    if (messageInput && messageInput.value.length > 500) {
      errors.push('El mensaje no puede exceder 500 caracteres');
      markFieldAsError(messageInput);
      isValid = false;
    } else if (messageInput) {
      markFieldAsValid(messageInput);
    }

    // Mostrar errores si hay
    if (!isValid) {
      showFormErrors(form, errors);
    }

    return isValid;
  }

  /**
   * Marca un campo como inválido
   */
  function markFieldAsError(field) {
    field.classList.add('is-invalid');
    field.classList.remove('is-valid');
  }

  /**
   * Marca un campo como válido
   */
  function markFieldAsValid(field) {
    field.classList.add('is-valid');
    field.classList.remove('is-invalid');
  }

  /**
   * Muestra errores del formulario
   */
  function showFormErrors(form, errors) {
    let errorContainer = form.querySelector('.form-errors');
    
    if (!errorContainer) {
      errorContainer = document.createElement('div');
      errorContainer.className = 'alert alert-danger form-errors mt-3';
      form.insertBefore(errorContainer, form.firstChild);
    }

    errorContainer.innerHTML = `
      <strong>Por favor corrige los siguientes errores:</strong>
      <ul class="mb-0 mt-2">
        ${errors.map(error => `<li>${error}</li>`).join('')}
      </ul>
    `;

    // Auto-hide después de 5 segundos
    setTimeout(() => {
      errorContainer.remove();
    }, 5000);
  }

  /**
   * Limpia los errores del formulario
   */
  function clearFormErrors(form) {
    const errorContainer = form.querySelector('.form-errors');
    if (errorContainer) {
      errorContainer.remove();
    }

    const fields = form.querySelectorAll('.is-invalid, .is-valid');
    fields.forEach(field => {
      field.classList.remove('is-invalid', 'is-valid');
    });
  }

  /**
   * Muestra mensaje de éxito
   */
  function showSuccessMessage(form, message) {
    const successContainer = document.createElement('div');
    successContainer.className = 'alert alert-success mt-3';
    successContainer.innerHTML = `
      <i class="fas fa-check-circle me-2"></i>
      <strong>${message}</strong>
    `;

    form.insertBefore(successContainer, form.firstChild);

    // Auto-hide y cerrar modal después de 3 segundos
    setTimeout(() => {
      successContainer.remove();
      const modal = form.closest('.modal');
      if (modal) {
        const bsModal = bootstrap.Modal.getInstance(modal);
        if (bsModal) bsModal.hide();
      }
    }, 3000);
  }

  /**
   * Maneja el envío del formulario de donación
   */
  function handleDonationSubmit(e) {
    e.preventDefault();
    
    const form = e.target;
    
    // Validar formulario
    if (!validateDonationForm(form)) {
      console.log('❌ Formulario inválido');
      return false;
    }

    console.log('✅ Formulario válido, enviando...');

    // Obtener datos del formulario
    const formData = new FormData(form);
    const data = Object.fromEntries(formData.entries());
    
    console.log('Datos de donación:', data);

    // Simular envío (aquí iría la llamada AJAX real)
    const submitBtn = form.querySelector('button[type="submit"]');
    const originalText = submitBtn.innerHTML;
    
    // Deshabilitar botón y mostrar loading
    submitBtn.disabled = true;
    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Procesando...';

    // Simular delay de red
    setTimeout(() => {
      submitBtn.disabled = false;
      submitBtn.innerHTML = originalText;
      
      // Mostrar mensaje de éxito
      showSuccessMessage(form, '¡Gracias por tu donación! Te contactaremos pronto.');
      
      // Limpiar formulario
      form.reset();
      clearFormErrors(form);
    }, 1500);

    return false;
  }

  /**
   * Agrega validación en tiempo real a los campos
   */
  function setupRealTimeValidation() {
    const forms = document.querySelectorAll('form');
    
    forms.forEach(form => {
      const inputs = form.querySelectorAll('input, textarea, select');
      
      inputs.forEach(input => {
        input.addEventListener('blur', function() {
          if (this.value.trim() !== '') {
            // Validar campo individual
            validateField(this);
          }
        });

        input.addEventListener('input', function() {
          // Limpiar error mientras el usuario escribe
          if (this.classList.contains('is-invalid')) {
            this.classList.remove('is-invalid');
          }
        });
      });
    });
  }

  /**
   * Valida un campo individual
   */
  function validateField(field) {
    const type = field.type;
    const value = field.value.trim();

    switch(type) {
      case 'email':
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(value)) {
          markFieldAsError(field);
        } else {
          markFieldAsValid(field);
        }
        break;
      
      case 'number':
        if (isNaN(value) || parseFloat(value) <= 0) {
          markFieldAsError(field);
        } else {
          markFieldAsValid(field);
        }
        break;
      
      default:
        if (value === '' && field.required) {
          markFieldAsError(field);
        } else if (value !== '') {
          markFieldAsValid(field);
        }
    }
  }

  /**
   * Inicializa los tooltips de Bootstrap
   */
  function initTooltips() {
    const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]');
    const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => {
      return new bootstrap.Tooltip(tooltipTriggerEl);
    });
    
    if (tooltipList.length > 0) {
      console.log(`💡 ${tooltipList.length} tooltips inicializados`);
    }
  }

  /**
   * Inicializa los popovers de Bootstrap
   */
  function initPopovers() {
    const popoverTriggerList = document.querySelectorAll('[data-bs-toggle="popover"]');
    const popoverList = [...popoverTriggerList].map(popoverTriggerEl => {
      return new bootstrap.Popover(popoverTriggerEl);
    });
    
    if (popoverList.length > 0) {
      console.log(`💬 ${popoverList.length} popovers inicializados`);
    }
  }

  /**
   * Inicializa el sistema de modales
   */
  function initModalSystem() {
    console.log('🪟 Inicializando sistema de modales...');
    
    // Inicializar modal de donación
    initDonationModal();
    
    // Setup validación en tiempo real
    setupRealTimeValidation();
    
    // Agregar handler al formulario de donación
    const donationForm = document.querySelector('#donationModal form');
    if (donationForm) {
      donationForm.addEventListener('submit', handleDonationSubmit);
    }
    
    // Inicializar tooltips y popovers
    initTooltips();
    initPopovers();
    
    console.log('✅ Sistema de modales inicializado');
  }

  // Inicializar cuando el DOM esté listo
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initModalSystem);
  } else {
    initModalSystem();
  }

  // Exportar funciones para uso externo
  window.ModalSystem = {
    validateForm: validateDonationForm,
    showSuccess: showSuccessMessage,
    init: initModalSystem
  };

})();
