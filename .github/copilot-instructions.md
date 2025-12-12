# EcoPuntos - Instrucciones para Agentes IA

## 🏗️ Arquitectura del Proyecto

**EcoPuntos** es un sistema Django 5.2 de gestión de reciclaje con PWA, chatbot IA (Google Gemini 2.5 Flash) y WebSockets en tiempo real.

### Componentes Principales
- **Backend**: Django 5.2 + Django Channels (WebSockets/ASGI con Daphne)
- **Base de datos**: PostgreSQL (producción) / SQLite (desarrollo)
- **Cache/WebSockets**: Redis (producción) / InMemory (desarrollo)
- **IA**: Google Gemini 2.5 Flash (chatbot en `core/chatbot/`)
- **Servidor**: Gunicorn con workers gthread para Railway
- **Archivos estáticos**: WhiteNoise

## 🔑 Modelo de Usuario Personalizado

```python
AUTH_USER_MODEL = 'core.Usuario'  # NO usar django.contrib.auth.User
```

El modelo `Usuario` (en `core/models.py`) extiende `AbstractUser` con:
- Roles: `superuser`, `admin`, `conductor`, `user`
- Niveles de gamificación (5 niveles desde "Guardián Verde")
- Puntos múltiples: `puntos`, `puntos_juego`, `puntos_juego_vidrios`, etc.
- Campos de seguridad: `suspended`, `email_verificado`, `terminos_aceptados`

## 🛣️ URLs y Patrones de Navegación

**CRÍTICO**: Usa nombres de URL específicos, NO genéricos:
```python
# ❌ INCORRECTO
reverse('login')  # NO existe

# ✅ CORRECTO
reverse('iniciosesion')  # Login de usuarios
reverse('admin:login')   # Login del admin de Django
```

Principales URLs (`core/urls.py`):
- `/iniciosesion/` → `name='iniciosesion'`
- `/registrarse/` → `name='registrarse'`
- `/paneladmin/` → Panel de administrador
- `/dashconductor/` → Dashboard de conductor
- `/dashusuario/` → Dashboard de usuario regular
- `/chatbot/` → Interfaz del chatbot IA

## 🗄️ Configuración de Base de Datos

Detecta automáticamente el entorno:
```python
# SQLite para desarrollo local
DATABASE_URL = 'sqlite:///db.sqlite3'

# PostgreSQL para Railway (automático con plugin)
DATABASE_URL = 'postgresql://user:pass@host:5432/db'
```

## 🚀 Despliegue en Railway

### Archivos de Despliegue
- `railway.json`: Configuración con Nixpacks, ejecuta `start.sh`
- `start.sh`: Migraciones → collectstatic → Gunicorn
- `Procfile`: Alternativo (no se usa con `railway.json`)

### Variables de Entorno Requeridas
```bash
# Django
SECRET_KEY=<generado-seguro>
DEBUG=False
ALLOWED_HOSTS=.railway.app

# PostgreSQL (Railway genera DATABASE_URL automático)
DATABASE_URL=postgresql://...

# Redis (Railway genera REDIS_URL automático)
REDIS_URL=redis://...

# IA Chatbot
GOOGLE_API_KEY=<api-key-gemini>

# Email
EMAIL_HOST_USER=<gmail>
EMAIL_HOST_PASSWORD=<app-password>
```

### Cache y WebSockets
**Producción** (Railway con Redis):
```python
CACHES = {'default': {'BACKEND': 'django_redis.cache.RedisCache', 'LOCATION': REDIS_URL}}
CHANNEL_LAYERS = {'default': {'BACKEND': 'channels_redis.core.RedisChannelLayer', 'CONFIG': {'hosts': [REDIS_URL]}}}
```

**Desarrollo** (sin Redis):
```python
CACHES = {'default': {'BACKEND': 'django.core.cache.backends.filebased.FileBasedCache', 'LOCATION': BASE_DIR / 'cache'}}
CHANNEL_LAYERS = {'default': {'BACKEND': 'channels.layers.InMemoryChannelLayer'}}
```

## 🤖 Sistema de Chatbot

### Arquitectura WebSocket
- **Consumer**: `core/chatbot/consumers.py` → `ChatbotConsumer`
- **Routing**: `core/routing.py` → `/ws/chatbot/`
- **ASGI**: `proyecto2023/asgi.py` (Daphne + Channels)

### Servicios IA
```python
# core/chatbot/services/gemini_service.py
get_ai_service()  # Factory que retorna GeminiService
```

### Modelos del Chatbot
- `ConversacionChatbot`: Sesiones de chat (1 por usuario)
- `MensajeChatbot`: Mensajes individuales
- `ContextoChatbot`: Contexto de usuario (puntos, nivel, canjes)

## 📊 Modelos Core del Dominio

Principales entidades (`core/models.py`):
- `MaterialTasa`: Materiales reciclables con puntos por kilo
- `Canje`: Solicitudes de canje (estados: `pendiente`, `aprobado`, `rechazado`)
- `RutaRecoleccion`: Rutas de recolección con conductor asignado
- `Recompensa`: Catálogo de recompensas canjeables
- `RedencionPuntos`: Historial de canjes de recompensas
- `Notificacion`: Sistema de notificaciones en tiempo real

## 🔒 Seguridad y Middleware

### Middlewares Personalizados
1. `SecurityMiddleware`: Headers de seguridad, rate limiting
2. `UserStatusMiddleware`: Verifica usuarios desactivados/suspendidos
3. `SessionValidationMiddleware`: Valida sesiones cerradas por admin

### Rate Limiting
```python
# core/ratelimit.py - Sistema personalizado más simple que django-ratelimit
RATELIMIT_RATES = {
    'login': '5/m',
    'chatbot_message': '30/m',
    'api_general': '100/h',
}
```

## 🛠️ Comandos de Desarrollo

### Iniciar Proyecto Local
```bash
python manage.py runserver  # HTTP básico
# O usar la tarea VS Code: "Iniciar proyecto Django"
```

### Testing
```bash
python manage.py test  # Todos los tests
pytest  # Con pytest
npm run test:design  # Tests de diseño con Playwright
```

### Gestión de Datos
```bash
python manage.py populate_recompensas  # Poblar recompensas
python manage.py cleanup_sessions  # Limpiar sesiones
python manage.py test_email  # Probar envío de emails
```

## 📁 Estructura de Directorios

```
core/
├── chatbot/              # Sistema de chatbot IA
│   ├── consumers.py      # WebSocket consumer
│   ├── services/         # Servicios de IA (Gemini)
│   ├── knowledge/        # Base de conocimiento
│   └── utils/            # Utilidades
├── management/commands/  # Comandos personalizados
├── middleware.py         # Middlewares de seguridad
├── models.py            # 20+ modelos de dominio
├── views.py             # Vistas principales
└── templates/           # Templates HTML

proyecto2023/
├── settings.py          # Configuración (523 líneas)
├── asgi.py              # ASGI para WebSockets
└── urls.py              # URLs principales

tests/                   # Tests automatizados
static/                  # CSS/JS/imágenes
staticfiles/             # Archivos estáticos compilados (collectstatic)
media/                   # Archivos subidos por usuarios
```

## ⚠️ Errores Comunes y Soluciones

### Error: "Reverse for 'login' not found"
```python
# ❌ No usar
reverse('login')

# ✅ Usar
reverse('iniciosesion')
```

### Error: Redis Connection Refused en Railway
```python
# Verificar que REDIS_URL esté configurado en Railway
# O cambiar a cache de archivos si Redis no está disponible
if not REDIS_URL or DEBUG:
    CACHES = {'default': {'BACKEND': 'django.core.cache.backends.filebased.FileBasedCache'}}
```

### Error: ALLOWED_HOSTS inválido
```python
# Railway requiere dominio .railway.app
ALLOWED_HOSTS = config('ALLOWED_HOSTS', default='localhost,127.0.0.1,.railway.app', cast=Csv())
```

## 📖 Documentación Adicional

- `README.md`: Overview completo del proyecto
- `DEPLOYMENT_RAILWAY.md`: Guía de despliegue en Railway
- `PWA_IMPLEMENTACION_COMPLETA.md`: Implementación PWA
- `GESTION_USUARIOS_README.md`: Sistema de usuarios
- `MEJORAS_ECOBOT.md`: Mejoras del chatbot

## 🎯 Convenciones del Código

1. **Templates**: Usar `{% load static %}` en todos los templates
2. **URLs**: Siempre usar `reverse()` o `{% url 'nombre' %}`, nunca hardcodear
3. **Permisos**: Usar decoradores `@login_required` y verificar roles con `user.is_conductor()`, `user.is_admin_user()`
4. **Queries**: Usar `select_related()` y `prefetch_related()` para optimización
5. **Timezone**: Configurado para `'America/Bogota'`, usar `timezone.now()` de Django
