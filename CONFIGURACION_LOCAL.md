# Configuración para Desarrollo Local

## ✅ Cambios Realizados

El proyecto **EcoPuntos** ahora está configurado para desarrollo local usando `python manage.py runserver`.

### Modificaciones en `.env`

Se actualizó el archivo `.env` con los siguientes cambios:

```env
# Base de Datos
DATABASE_URL=sqlite:///db.sqlite3  # Cambió de PostgreSQL a SQLite

# Hosts permitidos
ALLOWED_HOSTS=localhost,127.0.0.1  # Solo hosts locales

# Redis (WebSockets)
# REDIS_URL=  # Comentado - usará InMemoryChannelLayer

# HTTPS
USE_HTTPS=False  # Deshabilitado para desarrollo
```

### Configuración Automática

El proyecto detecta automáticamente el entorno según las variables:

- **SQLite**: Si `DATABASE_URL=sqlite:///db.sqlite3`
- **Cache**: Usa `FileBasedCache` en carpeta `/cache`
- **WebSockets**: Usa `InMemoryChannelLayer` (sin Redis)
- **DEBUG=True**: Activa modo desarrollo

## 🚀 Cómo Ejecutar

```bash
# Iniciar servidor de desarrollo
python manage.py runserver

# O usar la tarea de VS Code
# Ctrl+Shift+P → "Tasks: Run Task" → "Iniciar proyecto Django"
```

El servidor estará disponible en: **http://127.0.0.1:8000/**

## 📋 Características Activas

✅ **Base de datos**: SQLite (`db.sqlite3`)  
✅ **Cache**: Basado en archivos (`/cache/`)  
✅ **WebSockets**: InMemory (sin Redis)  
✅ **Chatbot IA**: Google Gemini 2.5 Flash  
✅ **Email**: Gmail SMTP configurado  
✅ **PWA**: Service Worker activo  
✅ **Daphne**: Servidor ASGI para WebSockets  

## 🔄 Cambiar a Producción

Para volver a producción (Railway), modifica `.env`:

```env
DEBUG=False
DATABASE_URL=postgresql://...
REDIS_URL=redis://...
ALLOWED_HOSTS=.railway.app
USE_HTTPS=True
```

## 📝 Notas Importantes

- **Modelo de Usuario**: `AUTH_USER_MODEL = 'core.Usuario'` (NO usar `User` de Django)
- **Login URL**: Usa `reverse('iniciosesion')` no `reverse('login')`
- **Migraciones**: Ya aplicadas en `db.sqlite3`
- **WebSockets**: Funcionan con InMemory para chat en tiempo real
- **Sin cambios en código**: Solo configuración de entorno

## 🎮 Funcionalidades Completas

Todas las funcionalidades están activas:
- Sistema de autenticación personalizado
- Chatbot con IA (Google Gemini)
- WebSockets en tiempo real
- Gestión de canjes y rutas
- Sistema de puntos y gamificación
- PWA offline
- Notificaciones en tiempo real
- Panel de administrador
- Dashboard de conductor
- Dashboard de usuario
