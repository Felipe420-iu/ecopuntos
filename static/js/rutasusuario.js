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
        
        // Validar el formulario antes de enviar
        if (!validateStep(4)) {
            return;
        }
        
        // Asegurar que los canjes seleccionados estén en el formulario
        const formData = new FormData(form);
        
        // Limpiar canjes[] existentes
        formData.delete('canjes[]');
        
        // Agregar cada canje seleccionado
        selectedCanjes.forEach(canje => {
            formData.append('canjes[]', canje.id);
        });
        
        // Asegurar que la dirección esté incluida
        if (direccionCompleta) {
            formData.set('direccion', direccionCompleta);
        }
        
        console.log('[DEBUG] FormData a enviar:');
        for (let [key, value] of formData.entries()) {
            console.log(`  ${key}: ${value}`);
        }
        
        // Crear un formulario temporal con todos los datos y enviarlo
        const tempForm = document.createElement('form');
        tempForm.method = 'POST';
        tempForm.action = form.action;
        
        // Copiar todos los datos al formulario temporal
        for (let [key, value] of formData.entries()) {
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = key;
            input.value = value;
            tempForm.appendChild(input);
        }
        
        document.body.appendChild(tempForm);
        tempForm.submit();
    });
}
    });
}

// ==========================================
// MODAL DE DIRECCIÓN
// ==========================================

function showDireccionModal() {
    const modalHTML = `
        <div class="modal fade" id="direccionModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content" style="border-radius: 15px; border: none;">
                    <div class="modal-header" style="background: linear-gradient(135deg, #4CAF50, #45a049); color: white;">
                        <h5 class="modal-title">
                            <i class="fas fa-map-marker-alt me-2"></i>Información de Dirección
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body" style="padding: 30px;">
                        <div class="row">
                            <div class="col-md-12 mb-3">
                                <label for="modal_direccion_principal" class="form-label fw-bold">Dirección Principal *</label>
                                <input type="text" class="form-control" id="modal_direccion_principal" 
                                       placeholder="Calle, carrera, avenida y número" required>
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="modal_barrio" class="form-label fw-bold">Barrio/Sector *</label>
                                <input type="text" class="form-control" id="modal_barrio" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="modal_ciudad" class="form-label fw-bold">Ciudad *</label>
                                <input type="text" class="form-control" id="modal_ciudad" value="Ibagué" readonly>
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-12 mb-3">
                                <label for="modal_referencias" class="form-label">Referencias</label>
                                <input type="text" class="form-control" id="modal_referencias" 
                                       placeholder="Puntos de referencia cercanos">
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                        <button type="button" class="btn btn-success" onclick="saveDireccionAndContinue()">
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

function saveDireccionAndContinue() {
    const direccionPrincipal = document.getElementById('modal_direccion_principal').value.trim();
    const barrio = document.getElementById('modal_barrio').value.trim();
    const ciudad = document.getElementById('modal_ciudad').value.trim();
    
    if (!direccionPrincipal || !barrio || !ciudad) {
        showToast('Por favor completa todos los campos obligatorios de dirección', 'warning');
        return;
    }
    
    const referencias = document.getElementById('modal_referencias').value.trim();
    
    direccionCompleta = direccionPrincipal + ', ' + barrio + ', ' + ciudad;
    if (referencias) direccionCompleta += ' - Ref: ' + referencias;
    
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
    
    showToast('Dirección guardada correctamente', 'success');
}

// ==========================================
// GESTIÓN DE PASOS DEL FORMULARIO
// ==========================================

function initializeForm() {
    showStep(1);
}

function showStep(step) {
    document.querySelectorAll('.form-step').forEach(el => {
        el.classList.remove('active');
        el.style.display = 'none';
    });

    const stepElement = document.getElementById(`step-${step}`);
    if (stepElement) {
        stepElement.classList.add('active');
        stepElement.style.display = 'block';
    }

    currentStep = step;
}

function nextStep(step) {
    if (validateStep(currentStep)) {
        if (step === 4) {
            llenarResumenPaso4();
        }
        showStep(step);
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }
}

function llenarResumenPaso4() {
    const fecha = document.getElementById('fecha_preferida').value;
    const hora = document.getElementById('hora_preferida').value;
    const notas = document.getElementById('notas_adicionales').value;
    
    const fechaObj = new Date(fecha + 'T00:00:00');
    const fechaFormateada = fechaObj.toLocaleDateString('es-CO', { 
        weekday: 'long', 
        year: 'numeric', 
        month: 'long', 
        day: 'numeric' 
    });
    
    const horaNum = parseInt(hora.split(':')[0]);
    const minutos = hora.split(':')[1];
    const horaFormateada = `${horaNum > 12 ? horaNum - 12 : horaNum}:${minutos} ${horaNum >= 12 ? 'PM' : 'AM'}`;
    
    let materialesHTML = '';
    if (selectedCanjes && selectedCanjes.length > 0) {
        selectedCanjes.forEach(canje => {
            materialesHTML += `
                <div class="d-flex justify-content-between align-items-center mb-2 p-3" style="background: white; border-radius: 8px;">
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
        const materialElement = card.querySelector('h6');
        const textoCompleto = card.textContent;
        
        const pesoMatch = textoCompleto.match(/Peso:\s*([\d.]+)\s*kg/);
        const puntosMatch = textoCompleto.match(/Puntos:\s*([\d.]+)/);
        
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