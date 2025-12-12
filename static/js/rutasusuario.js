// ==========================================
// RUTAS DE RECOLECCIÓN - JAVASCRIPT
// ==========================================

// Estado global del formulario
let currentStep = 1;
let selectedCanjes = [];
let direccionCompleta = '';

// ==========================================
// INICIALIZACIÓN
// ==========================================

document.addEventListener('DOMContentLoaded', function() {
    initializeForm();
    initializeCanjeSelection();
    setupDateRestrictions();
    setupFormSubmit();
});

function setupFormSubmit() {
    const form = document.getElementById('nuevaRecoleccionForm');
    if (!form) return;
    
    form.addEventListener('submit', function(e) {
        e.preventDefault();
        
        // Construir FormData con los datos del formulario
        const formData = new FormData(form);
        
        // Agregar los IDs de canjes seleccionados al FormData
        // Limpiar canjes[] si existen
        const currentCanjesArray = formData.getAll('canjes[]');
        formData.delete('canjes[]');
        
        // Agregar cada canje seleccionado
        selectedCanjes.forEach(canje => {
            formData.append('canjes[]', canje.id);
        });
        
        // Agregar la dirección completa
        formData.set('direccion', direccionCompleta);
        
        console.log('[DEBUG] FormData a enviar:');
        for (let [key, value] of formData.entries()) {
            console.log(`  ${key}: ${value}`);
        }
        
        // Enviar el formulario
        form.submit();
    });
}

// ==========================================
// GESTIÓN DE PASOS DEL FORMULARIO
// ==========================================

function initializeForm() {
    showStep(1);
}

function showStep(step) {
    // Ocultar todos los pasos
    document.querySelectorAll('.form-step').forEach(el => {
        el.classList.remove('active');
        el.style.display = 'none';
    });

    // Mostrar el paso actual
    const stepElement = document.getElementById(`step-${step}`);
    if (stepElement) {
        stepElement.classList.add('active');
        stepElement.style.display = 'block';
    }

    currentStep = step;
    updateProgressBar(step);
}

function nextStep(step) {
    if (validateStep(currentStep)) {
        // Si va al paso 4, llenar el resumen
        if (step === 4) {
            llenarResumenPaso4();
        }
        showStep(step);
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }
}

function llenarResumenPaso4() {
    // Obtener datos del formulario
    const fecha = document.getElementById('fecha_preferida').value;
    const hora = document.getElementById('hora_preferida').value;
    const notas = document.getElementById('notas_adicionales').value;
    
    // Formatear fecha
    const fechaObj = new Date(fecha + 'T00:00:00');
    const fechaFormateada = fechaObj.toLocaleDateString('es-CO', { 
        weekday: 'long', 
        year: 'numeric', 
        month: 'long', 
        day: 'numeric' 
    });
    
    // Formatear hora
    const horaNum = parseInt(hora.split(':')[0]);
    const minutos = hora.split(':')[1];
    const horaFormateada = `${horaNum > 12 ? horaNum - 12 : horaNum}:${minutos} ${horaNum >= 12 ? 'PM' : 'AM'}`;
    
    // Llenar resumen de materiales
    let materialesHTML = '';
    if (selectedCanjes && selectedCanjes.length > 0) {
        selectedCanjes.forEach(canje => {
            materialesHTML += `
                <div class="d-flex justify-content-between align-items-center mb-2 p-3" style="background: white; border-radius: 8px; border: 1px solid #e5e7eb;">
                    <div>
                        <i class="fas fa-leaf text-success me-2"></i>
                        <strong>${canje.material}</strong>
                    </div>
                    <div>
                        <span class="badge bg-primary me-1">${canje.peso} kg</span>
                        <span class="badge bg-warning text-dark">${canje.puntos} pts</span>
                    </div>
                </div>
            `;
        });
    } else {
        materialesHTML = '<p class="text-muted mb-0">No se seleccionaron canjes específicos</p>';
    }
    
    document.getElementById('resumen_materiales_paso4').innerHTML = materialesHTML;
    document.getElementById('resumen_direccion_paso4').textContent = direccionCompleta || 'No especificada';
    document.getElementById('resumen_fecha_paso4').textContent = fechaFormateada;
    document.getElementById('resumen_hora_paso4').textContent = horaFormateada;
    
    // Mostrar/ocultar notas
    if (notas && notas.trim()) {
        document.getElementById('resumen_notas_container_paso4').style.display = 'block';
        document.getElementById('resumen_notas_paso4').textContent = notas;
    } else {
        document.getElementById('resumen_notas_container_paso4').style.display = 'none';
    }
}

function prevStep(step) {
    showStep(step);
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

function validateStep(step) {
    switch(step) {
        case 1:
            return validateDireccion();
        case 2:
            return validateCanjesSelection();
        case 3:
            return validateFechaHora();
        default:
            return true;
    }
}

function validateDireccion() {
    if (!direccionCompleta || direccionCompleta.trim() === '') {
        showToast('Por favor ingresa una dirección de recolección', 'warning');
        return false;
    }
    return true;
}

function validateCanjesSelection() {
    if (selectedCanjes.length === 0) {
        showToast('Por favor selecciona al menos un canje para recolección', 'warning');
        return false;
    }
    return true;
}

function validateFechaHora() {
    const fecha = document.getElementById('fecha_preferida').value;
    const hora = document.getElementById('hora_preferida').value;

    if (!fecha) {
        showToast('Por favor selecciona una fecha', 'warning');
        return false;
    }

    if (!hora) {
        showToast('Por favor selecciona una hora', 'warning');
        return false;
    }

    return true;
}

function updateProgressBar(step) {
    for(let i = 1; i <= 4; i++) {
        const progressStep = document.querySelector(`.progress-step[data-step="${i}"]`);
        if (progressStep) {
            if (i < step) {
                progressStep.classList.add('completed');
                progressStep.classList.remove('active');
            } else if (i === step) {
                progressStep.classList.add('active');
                progressStep.classList.remove('completed');
            } else {
                progressStep.classList.remove('active', 'completed');
            }
        }
    }
}

// ==========================================
// GESTIÓN DE SELECCIÓN DE CANJES
// ==========================================

function initializeCanjeSelection() {
    document.querySelectorAll('.canje-checkbox').forEach(checkbox => {
        checkbox.addEventListener('change', handleCanjeSelection);
    });

    document.querySelectorAll('.canje-card').forEach(card => {
        card.addEventListener('click', function(e) {
            if (e.target.type !== 'checkbox') {
                const checkbox = this.querySelector('.canje-checkbox');
                if (checkbox) {
                    checkbox.checked = !checkbox.checked;
                    checkbox.dispatchEvent(new Event('change'));
                }
            }
        });
    });
}

function handleCanjeSelection(e) {
    const canjeId = e.target.value;
    const card = e.target.closest('.canje-card');

    if (e.target.checked) {
        // Extraer información del canje desde el card
        const materialElement = card.querySelector('h6');
        const textoCompleto = card.textContent;
        
        // Extraer peso y puntos del texto
        const pesoMatch = textoCompleto.match(/Peso:\s*([\d.]+)\s*kg/);
        const puntosMatch = textoCompleto.match(/Puntos:\s*([\d.]+)/);
        
        // Limpiar el nombre del material (quitando el ícono)
        const materialNombre = materialElement ? materialElement.textContent.replace(/\s+/g, ' ').trim() : 'Material';
        
        const canjeData = {
            id: canjeId,
            material: materialNombre,
            peso: pesoMatch ? pesoMatch[1] : '0',
            puntos: puntosMatch ? puntosMatch[1] : '0'
        };
        
        selectedCanjes.push(canjeData);
        card.classList.add('selected');
    } else {
        selectedCanjes = selectedCanjes.filter(c => c.id !== canjeId);
        card.classList.remove('selected');
    }

    updateSelectionSummary();
}

function updateSelectionSummary() {
    const summaryContainer = document.getElementById('selected-canjes-summary');
    if (!summaryContainer) return;

    if (selectedCanjes.length === 0) {
        summaryContainer.innerHTML = '<p class="text-muted">No has seleccionado ningún canje</p>';
        return;
    }

    let html = `<p><strong>${selectedCanjes.length}</strong> canje(s) seleccionado(s)</p><ul class="list-unstyled mt-2">`;
    
    selectedCanjes.forEach(canje => {
        html += `<li><i class="fas fa-check-circle text-success me-2"></i>${canje.material} (${canje.peso} kg)</li>`;
    });
    
    html += '</ul>';
    summaryContainer.innerHTML = html;
}

// ==========================================
// ZONAS DE IBAGUÉ
// ==========================================

const ZONAS_IBAGUE = {
    'zona1': {
        nombre: 'Zona 1 (Sur)',
        barrios: [
            'Ricaurte Parte Alta', 'Ricaurte Parte Baja', 'Urb albania 2', 'Miramar', 'San Isidro', 
            'Colinas del Sur', 'Villa Marina', 'Villa Claudia', 'Villa Ilusión', 'La Unión', 
            'Brisas del Sur', 'Villa Teresa', 'Balcones del Sur', 'San Antonio', 'San Jorge', 
            'Boquerón', 'Jazmín', 'El Tejar', 'La Florida', 'Granada', 'El Refugio', 
            'Praderas de San Mateo'
        ]
    },
    'zona2': {
        nombre: 'Zona 2 (Centro)',
        barrios: [
            'La Libertad', 'Augusto E. Medina', 'Baltazar', 'Centro', 'Combeima', 'Estación', 
            'Interlaken', 'La Pola', 'La Pola parte alta', 'Edén de la Pola', 'Libertador', 
            'Pueblo Nuevo', 'San Pedro Alejandrino', 'Brisas del Combeima', 'Chapetón', 'La Vega', 
            'Calambeo', '20 de Julio', '7 de Agosto', 'Alaska', 'Ancón', 'Belén', 
            'Carmenza Rocha', 'Avenida', 'El Carmen', 'Altos de Calambeo', 'Boyacá', 'Hipódromo'
        ]
    },
    'zona3': {
        nombre: 'Zona 3 (Norte/Nororiente)',
        barrios: [
            'Antonio Nariño', 'Belalcázar', 'El Carmen', 'Fenalco', 'San Simón', 'Ancón', 
            'Ancón Parte Alta', 'Entrerrios', 'La Granja', 'La Paz', 'Palermo', 'San Simón Parte Alta', 
            'San Simón Parte Baja', 'Piedrapintada', 'Calarcá', 'Gaitán', 'Limonar', 'San Carlos', 
            'Asturias', 'Altamira', 'Centenario', 'Claret', 'Macarena', 'Montecarlo', 'Jordán 4ª Etapa', 
            'Jordán 6ª Etapa', 'Jordán 7ª Etapa', 'Jordán 8ª Etapa', 'Jordán 9ª Etapa', 'Prados del Norte', 
            'La Campiña', 'Arkacentro', 'Los Arrayanes', 'Villa Mayorga', 'El Vergel', 'Colinas del Norte', 
            'Protecho', 'Protecho Salado', 'El Salado Parte Alta', 'El Salado Parte Baja', 'La Misión', 
            'Nuevo Horizonte', 'Portal del Salado', 'Torres del Vergel', 'El Salado', 'Villa del Norte', 
            'San Lucas', 'Oviedo', 'Modelia', 'Arkaniza', 'Ciudadela Comfenalco', 'El Topacio', 
            'Garzones', 'La Ceiba', 'Miramar', 'Palmeras', 'San Francisco', 'Santa Rita', 
            'Ciudad Simón Bolívar', 'El Jardín Santander', 'Nueva Armero', 'Comfenalco', 'El Jardín', 
            'La Cima', 'Picaleña', 'Villa Donia', 'Villa Esperanza', 'Villa Restrepo'
        ]
    }
};

function detectarZonaPorBarrio(barrioSeleccionado) {
    for (const [key, zona] of Object.entries(ZONAS_IBAGUE)) {
        if (zona.barrios.includes(barrioSeleccionado)) {
            return zona.nombre;
        }
    }
    return 'No detectada';
}

function generarOpcionesBarrios() {
    let opciones = '<option value="">Selecciona un barrio</option>';
    
    for (const [key, zona] of Object.entries(ZONAS_IBAGUE)) {
        opciones += `<optgroup label="${zona.nombre}">`;
        zona.barrios.forEach(barrio => {
            opciones += `<option value="${barrio}">${barrio}</option>`;
        });
        opciones += '</optgroup>';
    }
    
    return opciones;
}

// ==========================================
// MODAL DE DIRECCIÓN
// ==========================================

function showDireccionModal() {
    const modalHTML = `
        <div class="modal fade" id="direccionModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content" style="border-radius: 15px; border: none; box-shadow: 0 10px 30px rgba(0,0,0,0.1);">
                    <div class="modal-header" style="background: linear-gradient(135deg, #4CAF50, #45a049); color: white; border-radius: 15px 15px 0 0;">
                        <h5 class="modal-title">
                            <i class="fas fa-map-marker-alt me-2"></i>Información de Dirección
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body" style="padding: 30px;">
                        <p class="text-muted mb-4">
                            <i class="fas fa-info-circle me-2"></i>
                            Proporciona la información detallada para la recolección en tu domicilio
                        </p>
                        
                        <div class="row">
                            <div class="col-md-12 mb-3">
                                <label for="modal_direccion_principal" class="form-label fw-bold">Dirección Principal *</label>
                                <input type="text" class="form-control modern-input" id="modal_direccion_principal" 
                                       placeholder="Calle, carrera, avenida y número" required>
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-4 mb-3">
                                <label for="modal_barrio" class="form-label fw-bold">Barrio/Sector *</label>
                                <select class="form-control modern-input" id="modal_barrio" required onchange="actualizarZonaPorBarrio()">
                                    ${generarOpcionesBarrios()}
                                </select>
                            </div>
                            <div class="col-md-4 mb-3">
                                <label for="modal_ciudad" class="form-label fw-bold">Ciudad *</label>
                                <input type="text" class="form-control modern-input" id="modal_ciudad" 
                                       value="Ibagué" readonly>
                            </div>
                            <div class="col-md-4 mb-3">
                                <label for="modal_zona" class="form-label fw-bold">Zona</label>
                                <input type="text" class="form-control modern-input" id="modal_zona" 
                                       value="No detectada" readonly style="background-color: #f8f9fa; font-weight: 600; color: #666;">
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="modal_complemento" class="form-label">Complemento</label>
                                <input type="text" class="form-control modern-input" id="modal_complemento" 
                                       placeholder="Apartamento, casa, edificio, etc.">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="modal_referencias" class="form-label">Referencias</label>
                                <input type="text" class="form-control modern-input" id="modal_referencias" 
                                       placeholder="Puntos de referencia cercanos">
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-12 mb-3">
                                <label for="modal_instrucciones" class="form-label">Instrucciones especiales</label>
                                <textarea class="form-control modern-input" id="modal_instrucciones" rows="3"
                                          placeholder="Información adicional para el conductor (portería, código de acceso, etc.)"></textarea>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer" style="border: none; padding: 20px 30px;">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                            <i class="fas fa-times me-2"></i>Cancelar
                        </button>
                        <button type="button" class="btn btn-success" onclick="saveDireccionAndContinue()" 
                                style="background: linear-gradient(135deg, #4CAF50, #45a049); border: none;">
                            <i class="fas fa-check me-2"></i>Confirmar Dirección
                        </button>
                    </div>
                </div>
            </div>
        </div>
    `;
    
    if (!document.getElementById('direccionModal')) {
        document.body.insertAdjacentHTML('beforeend', modalHTML);
    }
    
    const modal = new bootstrap.Modal(document.getElementById('direccionModal'));
    modal.show();
}

function actualizarZonaPorBarrio() {
    const barrioSelect = document.getElementById('modal_barrio');
    const zonaInput = document.getElementById('modal_zona');
    
    if (!barrioSelect || !zonaInput) return;
    
    const barrioSeleccionado = barrioSelect.value;
    
    if (!barrioSeleccionado) {
        zonaInput.value = 'No detectada';
        zonaInput.style.color = '#666';
        zonaInput.style.fontWeight = '600';
        return;
    }
    
    const zonaDetectada = detectarZonaPorBarrio(barrioSeleccionado);
    zonaInput.value = zonaDetectada;
    
    // Cambiar color según la zona detectada
    if (zonaDetectada !== 'No detectada') {
        zonaInput.style.color = '#10b981';
        zonaInput.style.fontWeight = '700';
    } else {
        zonaInput.style.color = '#666';
        zonaInput.style.fontWeight = '600';
    }
}

function saveDireccionAndContinue() {
    const direccionPrincipal = document.getElementById('modal_direccion_principal').value.trim();
    const barrio = document.getElementById('modal_barrio').value.trim();
    const ciudad = document.getElementById('modal_ciudad').value.trim();
    
    if (!direccionPrincipal || !barrio || !ciudad) {
        showToast('Por favor completa todos los campos obligatorios de dirección', 'warning');
        return;
    }
    
    const complemento = document.getElementById('modal_complemento').value.trim();
    const referencias = document.getElementById('modal_referencias').value.trim();
    const instrucciones = document.getElementById('modal_instrucciones').value.trim();
    
    direccionCompleta = direccionPrincipal + ', ' + barrio + ', ' + ciudad;
    if (complemento) direccionCompleta += ' (' + complemento + ')';
    if (referencias) direccionCompleta += ' - Ref: ' + referencias;
    if (instrucciones) direccionCompleta += ' - ' + instrucciones;
    
    let hiddenDireccion = document.getElementById('hidden_direccion');
    if (!hiddenDireccion) {
        hiddenDireccion = document.createElement('input');
        hiddenDireccion.type = 'hidden';
        hiddenDireccion.id = 'hidden_direccion';
        hiddenDireccion.name = 'direccion';
        document.getElementById('nuevaRecoleccionForm').appendChild(hiddenDireccion);
    }
    hiddenDireccion.value = direccionCompleta;
    
    const modal = bootstrap.Modal.getInstance(document.getElementById('direccionModal'));
    modal.hide();
    
    showStep(2);
    showToast('Dirección guardada correctamente', 'success');
}

// ==========================================
// RESTRICCIONES DE FECHA
// ==========================================

function setupDateRestrictions() {
    const fechaInput = document.getElementById('fecha_preferida');
    if (fechaInput) {
        const today = new Date();
        const tomorrow = new Date(today);
        tomorrow.setDate(tomorrow.getDate() + 1);
        
        const maxDate = new Date(today);
        maxDate.setDate(maxDate.getDate() + 30);
        
        fechaInput.min = tomorrow.toISOString().split('T')[0];
        fechaInput.max = maxDate.toISOString().split('T')[0];
    }
}

// ==========================================
// UTILIDADES
// ==========================================

function showToast(message, type = 'info') {
    const bgColor = {
        'success': 'bg-success',
        'warning': 'bg-warning',
        'danger': 'bg-danger',
        'info': 'bg-info'
    }[type] || 'bg-info';

    const toastHtml = `
        <div class="toast align-items-center text-white ${bgColor} border-0" role="alert" style="position: fixed; top: 20px; right: 20px; z-index: 9999;">
            <div class="d-flex">
                <div class="toast-body">
                    ${message}
                </div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
            </div>
        </div>
    `;

    document.body.insertAdjacentHTML('beforeend', toastHtml);
    const toastElement = document.body.lastElementChild;
    const toast = new bootstrap.Toast(toastElement);
    toast.show();

    toastElement.addEventListener('hidden.bs.toast', () => {
        toastElement.remove();
    });
}

function formatCurrency(amount) {
    return new Intl.NumberFormat('es-CO', {
        style: 'currency',
        currency: 'COP',
        minimumFractionDigits: 0
    }).format(amount);
}

function formatDate(dateString) {
    const date = new Date(dateString);
    return new Intl.DateTimeFormat('es-CO', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric'
    }).format(date);
}

// ==========================================
// MODAL DE DETALLES DE REAGENDAMIENTO
// ==========================================

// Variable global para almacenar el ID de la ruta actual
let rutaActualId = null;

function verDetallesReagendamiento(data) {
    console.log('verDetallesReagendamiento llamado con:', data);
    
    // Guardar el ID de la ruta
    rutaActualId = data.rutaId;
    
    // Verificar que el modal existe
    const modalElement = document.getElementById('detallesReagendamientoModal');
    if (!modalElement) {
        console.error('Modal no encontrado en el DOM');
        return;
    }
    
    // Poblar el modal con los datos - con validación
    const elements = {
        'modal_ruta_nombre': data.rutaNombre,
        'modal_material': data.material,
        'modal_peso': data.peso,
        'modal_puntos': data.puntos,
        'modal_fecha_original': data.fechaOriginal,
        'modal_motivo': data.motivo || 'No especificado',
        'modal_direccion': data.direccion
    };
    
    for (const [id, value] of Object.entries(elements)) {
        const element = document.getElementById(id);
        if (element) {
            element.textContent = value;
        } else {
            console.warn(`Elemento ${id} no encontrado`);
        }
    }
    
    // Mostrar el modal
    try {
        const modal = new bootstrap.Modal(modalElement);
        modal.show();
    } catch (error) {
        console.error('Error al mostrar modal:', error);
    }
}

function cancelarRuta() {
    if (!rutaActualId) {
        console.error('No hay ruta seleccionada');
        return;
    }
    
    const rutaId = rutaActualId;
    
    if (!confirm('¿Estás seguro de que deseas cancelar esta ruta? Esta acción no se puede deshacer.')) {
        return;
    }
    
    // Usar el CSRF_TOKEN global definido en el template
    const csrfToken = typeof CSRF_TOKEN !== 'undefined' ? CSRF_TOKEN : '';
    
    fetch(`/rutasusuario/cancelar/${rutaId}/`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRFToken': csrfToken
        }
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showToast('Ruta cancelada exitosamente', 'success');
            // Cerrar el modal
            const modal = bootstrap.Modal.getInstance(document.getElementById('detallesReagendamientoModal'));
            modal.hide();
            // Recargar la página después de 1 segundo
            setTimeout(() => {
                location.reload();
            }, 1000);
        } else {
            showToast(data.error || 'Error al cancelar la ruta', 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showToast('Error al cancelar la ruta', 'error');
    });
}

function reagendarRuta() {
    if (!rutaActualId) {
        console.error('No hay ruta seleccionada');
        return;
    }
    
    // Cerrar el modal de detalles
    const modalDetalles = bootstrap.Modal.getInstance(document.getElementById('detallesReagendamientoModal'));
    if (modalDetalles) {
        modalDetalles.hide();
    }
    
    // Configurar el formulario de reagendamiento
    document.getElementById('reagendar_ruta_id').value = rutaActualId;
    
    // Configurar fecha mínima (mañana)
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    const minDate = tomorrow.toISOString().split('T')[0];
    document.getElementById('reagendar_fecha').setAttribute('min', minDate);
    document.getElementById('reagendar_fecha').value = '';
    document.getElementById('reagendar_hora').value = '';
    document.getElementById('reagendar_notas').value = '';
    
    // Agregar validación para deshabilitar domingos y festivos
    setupReagendarDateRestrictions();
    
    // Abrir el modal de reagendamiento
    setTimeout(() => {
        const modalReagendar = new bootstrap.Modal(document.getElementById('modalReagendarRuta'));
        modalReagendar.show();
    }, 300);
}

function setupReagendarDateRestrictions() {
    const dateInput = document.getElementById('reagendar_fecha');
    if (!dateInput) return;
    
    // Festivos colombianos 2025-2026
    const holidays = [
        '2025-01-01', '2025-01-06', '2025-03-24', '2025-04-17', '2025-04-18',
        '2025-05-01', '2025-06-02', '2025-06-23', '2025-06-30', '2025-07-20',
        '2025-08-07', '2025-08-18', '2025-10-13', '2025-11-03', '2025-11-17',
        '2025-12-08', '2025-12-25',
        '2026-01-01', '2026-01-12', '2026-03-23', '2026-04-02', '2026-04-03',
        '2026-05-01', '2026-05-18', '2026-06-08', '2026-06-15', '2026-06-29',
        '2026-07-20', '2026-08-07', '2026-08-17', '2026-10-12', '2026-11-02',
        '2026-11-16', '2026-12-08', '2026-12-25'
    ];
    
    // Validar al cambiar fecha
    dateInput.addEventListener('change', function() {
        const selectedDate = new Date(this.value + 'T00:00:00');
        const dayOfWeek = selectedDate.getDay();
        
        // Verificar si es domingo (0)
        if (dayOfWeek === 0) {
            showToast('No se pueden programar recolecciones los domingos', 'warning');
            this.value = '';
            return;
        }
        
        // Verificar si es festivo
        if (holidays.includes(this.value)) {
            showToast('No se pueden programar recolecciones en días festivos', 'warning');
            this.value = '';
            return;
        }
    });
}

// ==========================================
// CONFIRMACIÓN DE SOLICITUD
// ==========================================

function confirmarReagendamiento() {
    const rutaId = document.getElementById('reagendar_ruta_id').value;
    const fecha = document.getElementById('reagendar_fecha').value;
    const hora = document.getElementById('reagendar_hora').value;
    const notas = document.getElementById('reagendar_notas').value;
    
    // Validar campos
    if (!fecha || !hora) {
        showToast('Por favor completa todos los campos obligatorios', 'warning');
        return;
    }
    
    // Validar que la fecha sea futura
    const selectedDate = new Date(fecha + 'T' + hora);
    const now = new Date();
    if (selectedDate <= now) {
        showToast('La fecha y hora deben ser futuras', 'warning');
        return;
    }
    
    const csrfToken = typeof CSRF_TOKEN !== 'undefined' ? CSRF_TOKEN : '';
    
    // Enviar solicitud al servidor
    fetch(`/rutasusuario/reagendar/${rutaId}/`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRFToken': csrfToken
        },
        body: JSON.stringify({
            fecha: fecha,
            hora: hora,
            notas: notas
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showToast('¡Ruta reagendada exitosamente! El conductor ha sido notificado', 'success');
            // Cerrar el modal
            const modal = bootstrap.Modal.getInstance(document.getElementById('modalReagendarRuta'));
            if (modal) {
                modal.hide();
            }
            // Recargar la página después de 2 segundos
            setTimeout(() => {
                location.reload();
            }, 2000);
        } else {
            showToast(data.error || 'Error al reagendar la ruta', 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showToast('Error al reagendar la ruta', 'error');
    });
}

// ==========================================
// FUNCIONES PARA REAGENDAR Y CANCELAR (Usuario)
// ==========================================

function abrirModalReagendar(rutaId, material, fecha, hora) {
    // Rellenar los datos del modal
    document.getElementById('rutaIdReagendar').value = rutaId;
    document.getElementById('materialReagendar').value = material;
    document.getElementById('fechaReagendarUsuario').value = fecha;
    document.getElementById('horaReagendarUsuario').value = hora;
    document.getElementById('notasReagendarUsuario').value = '';
    
    // Mostrar el modal
    const modal = new bootstrap.Modal(document.getElementById('modalReagendarRutaUsuario'));
    modal.show();
}

// Manejar el envío del formulario de reagendamiento
document.addEventListener('DOMContentLoaded', function() {
    const formReagendar = document.getElementById('formReagendarUsuario');
    if (formReagendar) {
        formReagendar.addEventListener('submit', function(e) {
            e.preventDefault();
            
            const rutaId = document.getElementById('rutaIdReagendar').value;
            const fecha = document.getElementById('fechaReagendarUsuario').value;
            const hora = document.getElementById('horaReagendarUsuario').value;
            const notas = document.getElementById('notasReagendarUsuario').value;
            
            if (!fecha || !hora) {
                showToast('Por favor completa fecha y hora', 'warning');
                return;
            }
            
            // Validar que sea fecha futura
            const selectedDate = new Date(fecha + 'T' + hora);
            const now = new Date();
            if (selectedDate <= now) {
                showToast('La fecha y hora deben ser futuras', 'warning');
                return;
            }
            
            const csrfToken = typeof CSRF_TOKEN !== 'undefined' ? CSRF_TOKEN : '';
            
            fetch(`/rutasusuario/reagendar/${rutaId}/`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRFToken': csrfToken
                },
                body: JSON.stringify({
                    fecha: fecha,
                    hora: hora,
                    notas: notas
                })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    showToast('¡Ruta reagendada exitosamente!', 'success');
                    // Cerrar modal
                    const modal = bootstrap.Modal.getInstance(document.getElementById('modalReagendarRutaUsuario'));
                    if (modal) modal.hide();
                    // Recargar página
                    setTimeout(() => location.reload(), 1500);
                } else {
                    showToast(data.error || 'Error al reagendar', 'error');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                showToast('Error al reagendar la ruta', 'error');
            });
        });
    }
});

// Variable global para almacenar la ruta a cancelar
let rutaAncancelar = null;

function confirmarCancelarRuta(rutaId, material) {
    rutaAncancelar = rutaId;
    document.getElementById('materialCancelar').textContent = material;
    
    const modal = new bootstrap.Modal(document.getElementById('modalCancelarRuta'));
    modal.show();
}

function confirmarCancelacion() {
    if (!rutaAncancelar) return;
    
    const csrfToken = typeof CSRF_TOKEN !== 'undefined' ? CSRF_TOKEN : '';
    
    fetch(`/rutasusuario/cancelar/${rutaAncancelar}/`, {
        method: 'POST',
        headers: {
            'X-CSRFToken': csrfToken
        }
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showToast('¡Ruta cancelada exitosamente!', 'success');
            // Cerrar modal
            const modal = bootstrap.Modal.getInstance(document.getElementById('modalCancelarRuta'));
            if (modal) modal.hide();
            // Recargar página
            setTimeout(() => location.reload(), 1500);
        } else {
            showToast(data.error || 'Error al cancelar', 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showToast('Error al cancelar la ruta', 'error');
    });
}

