# 🔔 Sistema de Notificaciones - Correcciones Implementadas

## 📋 Resumen de Cambios

### ✅ Problemas Corregidos

1. **Notificaciones no se marcaban como leídas**
   - ✅ Agregado `@login_required` a endpoints de notificaciones
   - ✅ Corregido el guardado con `notificacion.save()`
   - ✅ Cambiado formato de respuesta `fecha_creacion` → `created_at` para compatibilidad con JS

2. **Dashboard mostraba todas las notificaciones**
   - ✅ Agregado parámetro `?unread_only=true` a la petición
   - ✅ Backend ahora filtra solo notificaciones no leídas cuando se solicita
   - ✅ JavaScript actualizado para usar el filtro

3. **Faltaba sistema de notificación automática**
   - ✅ Creado endpoint `/api/notifications/latest-unread/` para obtener la más reciente
   - ✅ Implementado modal automático que se muestra al entrar al dashboard
   - ✅ Modal muestra título, mensaje y motivo (si existe)
   - ✅ Botón "Aceptar" marca la notificación como leída y cierra el modal

4. **Faltaba campo motivo en notificaciones**
   - ✅ Agregado campo `motivo` al modelo `Notificacion`
   - ✅ Migración creada: `0044_add_motivo_to_notificacion.py`
   - ✅ Campo incluido en respuestas de API

5. **Historial de rutas no mostraba motivo de reagendamiento**
   - ✅ Agregado bloque para mostrar motivo en historial
   - ✅ Estilos implementados con diseño amarillo/warning

---

## 🗂️ Archivos Modificados

### Backend (Django)

#### `core/models.py`
- ✅ Agregado campo `motivo` al modelo `Notificacion`

#### `core/views.py`
- ✅ `get_notifications()`: Agregado `@login_required`, parámetro `unread_only`, campo `motivo`
- ✅ `mark_notification_read()`: Agregado `@login_required`, corregido duplicado
- ✅ **NUEVO**: `get_latest_unread_notification()`: Endpoint para obtener notificación más reciente

#### `core/urls.py`
- ✅ Agregada ruta: `path('api/notifications/latest-unread/', ...)`

#### `core/migrations/0044_add_motivo_to_notificacion.py`
- ✅ **NUEVA**: Migración para agregar campo `motivo`

### Frontend (Templates & JS)

#### `core/templates/core/components/notification_modal.html`
- ✅ **NUEVO**: Modal completo con estilos y JavaScript
- ✅ Muestra notificación automáticamente al cargar dashboard
- ✅ Botón "Aceptar" marca como leída y cierra modal
- ✅ Diseño responsive con animaciones

#### `core/templates/core/dashusuario.html`
- ✅ Incluido `{% include 'core/components/notification_modal.html' %}`

#### `core/templates/core/rutasusuario.html`
- ✅ Agregado bloque para mostrar motivo en historial de rutas
- ✅ Estilos CSS para `.motivo-reagendamiento`

#### `static/js/dashboard/navigation.js`
- ✅ Agregado `?unread_only=true` a `loadNotifications()`

---

## 🧪 Cómo Probar

### 1. Aplicar Migraciones

```bash
python manage.py migrate
```

### 2. Crear Notificación de Prueba

```bash
python test_notificacion_motivo.py
```

Este script:
- Busca un usuario regular en la BD
- Crea una notificación con título, mensaje y motivo
- Te indica con qué usuario iniciar sesión

### 3. Probar el Flujo Completo

1. **Iniciar sesión** con el usuario indicado
2. **Ir al dashboard**: `/dashusuario/`
3. **Verificar**:
   - ✅ Modal aparece automáticamente con la notificación
   - ✅ Muestra título, mensaje y motivo (en recuadro amarillo)
   - ✅ Hacer clic en "Aceptar"
   - ✅ Modal se cierra
   - ✅ Badge de notificaciones se actualiza
4. **Recargar la página**:
   - ✅ Modal NO vuelve a aparecer (la notificación está marcada como leída)
5. **Verificar campana de notificaciones**:
   - ✅ Solo muestra notificaciones no leídas
   - ✅ Al hacer clic en una notificación, se marca como leída
   - ✅ Badge disminuye correctamente

### 4. Probar desde Admin

1. Ir a `/admin/core/notificacion/`
2. Crear nueva notificación:
   - Usuario: seleccionar un usuario
   - Título: "Prueba desde Admin"
   - Mensaje: "Esta es una prueba"
   - Motivo: "Solo para verificar"
   - Tipo: Sistema
   - Leída: ❌ (dejar sin marcar)
3. Guardar
4. Iniciar sesión como ese usuario
5. Ir al dashboard
6. Verificar que el modal aparece con el motivo

---

## 🔧 Endpoints API

### Obtener Notificaciones
```http
GET /api/notifications/
GET /api/notifications/?unread_only=true
```

**Respuesta:**
```json
{
  "success": true,
  "notifications": [
    {
      "id": 1,
      "tipo": "general",
      "tipo_original": "sistema",
      "titulo": "Notificación",
      "mensaje": "Contenido...",
      "motivo": "Razón adicional...",
      "created_at": "2025-12-06T10:00:00Z",
      "leida": false
    }
  ],
  "unread_count": 1
}
```

### Obtener Notificación Más Reciente No Leída
```http
GET /api/notifications/latest-unread/
```

**Respuesta:**
```json
{
  "success": true,
  "has_notification": true,
  "notification": {
    "id": 1,
    "tipo": "general",
    "tipo_original": "sistema",
    "titulo": "Ruta Reagendada",
    "mensaje": "Tu ruta fue reagendada...",
    "motivo": "Problema con el vehículo...",
    "created_at": "2025-12-06T10:00:00Z",
    "leida": false
  }
}
```

### Marcar como Leída
```http
POST /api/notifications/mark-read/
Content-Type: application/json

{
  "notification_id": 1
}
```

**Respuesta:**
```json
{
  "success": true,
  "message": "Notificación marcada como leída"
}
```

### Marcar Todas como Leídas
```http
POST /api/notifications/mark-all-read/
```

**Respuesta:**
```json
{
  "success": true,
  "message": "Se marcaron 3 notificaciones como leídas",
  "updated_count": 3
}
```

---

## 🎨 Diseño del Modal

### Características
- ✅ Backdrop estático (no se cierra al hacer clic fuera)
- ✅ Header con gradiente verde
- ✅ Ícono animado con efecto pulse
- ✅ Motivo en recuadro amarillo con borde izquierdo
- ✅ Botón primario verde con hover effect
- ✅ Responsive para móviles
- ✅ Animaciones suaves

### Colores
- **Header**: Gradiente verde (#10b981 → #059669)
- **Motivo**: Fondo amarillo (#fff3cd) con borde #ffc107
- **Texto motivo**: #856404

---

## 🐛 Debugging

### Ver notificaciones de un usuario en consola Django

```python
python manage.py shell

from core.models import Notificacion, Usuario

# Ver todas las notificaciones de un usuario
usuario = Usuario.objects.get(username='tu_usuario')
notifs = Notificacion.objects.filter(usuario=usuario)
for n in notifs:
    print(f"ID: {n.id} | {n.titulo} | Leída: {n.leida} | Motivo: {n.motivo}")
```

### Marcar todas como no leídas (para probar)

```python
Notificacion.objects.filter(usuario=usuario).update(leida=False)
```

### Ver logs del modal en navegador

1. Abrir DevTools (F12)
2. Ir a pestaña Console
3. Buscar:
   - `🔍 Verificando notificaciones...`
   - `✓ Notificación marcada como leída`
   - Errores en rojo

---

## ✅ Checklist de Funcionalidad

- [x] Notificaciones se marcan como leídas en BD
- [x] Dashboard filtra solo no leídas
- [x] Campana muestra badge correcto
- [x] Modal aparece automáticamente
- [x] Modal muestra título, mensaje y motivo
- [x] Botón Aceptar marca como leída
- [x] Modal no vuelve a aparecer después de leída
- [x] Historial de rutas muestra motivo
- [x] API endpoints funcionan correctamente
- [x] Migración aplicada correctamente

---

## 📝 Notas Adicionales

### Comportamiento del Modal

1. **Se muestra solo si**:
   - El usuario tiene al menos una notificación no leída
   - Es la más reciente
   - El usuario acaba de entrar al dashboard

2. **No se muestra si**:
   - No hay notificaciones no leídas
   - La notificación ya fue leída
   - Hubo error en la petición

3. **Actualización automática**:
   - Al hacer clic en "Aceptar", se actualiza el badge
   - El sistema principal de notificaciones se recarga
   - No requiere refrescar la página

### Compatibilidad

- ✅ Compatible con sistema existente de notificaciones
- ✅ No interfiere con el dropdown de la campana
- ✅ Usa mismo CSRF token y sistema de autenticación
- ✅ Responsive para móviles y tablets

---

## 🚀 Próximos Pasos Sugeridos

1. **Notificaciones en tiempo real con WebSockets**
   - Integrar con Django Channels existente
   - Enviar notificación automática al usuario cuando se crea

2. **Sonido/Vibración**
   - Agregar sonido al mostrar modal
   - Vibración en móviles

3. **Botón de "Ver Después"**
   - No marcar como leída
   - Volver a mostrar en próxima sesión

4. **Historial completo de notificaciones**
   - Página dedicada `/notificaciones/`
   - Filtros por tipo y fecha
   - Búsqueda

---

## 📞 Soporte

Si encuentras algún problema:

1. Verifica que las migraciones estén aplicadas
2. Revisa la consola del navegador (F12)
3. Verifica que el usuario tenga notificaciones no leídas
4. Asegúrate de que el endpoint `/api/notifications/latest-unread/` responda correctamente

---

**Última actualización**: 6 de diciembre de 2025  
**Versión**: 1.0.0  
**Estado**: ✅ Completado y funcional
