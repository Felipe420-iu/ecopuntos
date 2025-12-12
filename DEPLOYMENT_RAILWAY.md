# 🚀 Guía de Despliegue en Railway - EcoPuntos

## 📋 Índice
1. [Preparación del Proyecto](#preparación-del-proyecto)
2. [Despliegue en Railway](#despliegue-en-railway)
3. [Configuración de Variables de Entorno](#configuración-de-variables-de-entorno)
4. [Configuración de Base de Datos PostgreSQL](#configuración-de-base-de-datos)
5. [Configuración de Redis](#configuración-de-redis)
6. [Verificación y Troubleshooting](#verificación-y-troubleshooting)

---

## ✅ Preparación del Proyecto

Tu proyecto **EcoPuntos** está completamente preparado para despliegue en Railway con:

### Archivos Generados:
- ✅ `Procfile` - Comandos de inicio para Railway
- ✅ `runtime.txt` - Versión de Python
- ✅ `railway.json` - Configuración específica de Railway
- ✅ `requirements.txt` - Dependencias de producción
- ✅ `.env.example` - Plantilla de variables de entorno
- ✅ `Dockerfile` - Contenedor optimizado para producción
- ✅ `docker-compose.yml` - Para desarrollo local
- ✅ `.dockerignore` - Optimización del build

### Configuración de Producción:
- ✅ DEBUG = False por defecto
- ✅ ALLOWED_HOSTS incluye Railway (.railway.app)
- ✅ Whitenoise configurado para archivos estáticos
- ✅ Base de datos PostgreSQL lista (compatible con Railway)
- ✅ Gunicorn con 4 workers optimizados

---

## 🚂 Despliegue en Railway

### Paso 1: Crear Proyecto en Railway

1. **Ir a [Railway.app](https://railway.app)**
2. **Crear cuenta** o iniciar sesión (GitHub OAuth recomendado)
3. **Click en "New Project"**
4. **Seleccionar "Deploy from GitHub repo"**
5. **Autorizar Railway** a acceder a tu repositorio
6. **Seleccionar el repositorio** `ecopuntos1.0`

### Paso 2: Configurar el Servicio

Railway detectará automáticamente que es un proyecto Django y usará el `Procfile`.

---

## 🔐 Configuración de Variables de Entorno

### Variables OBLIGATORIAS:

En el panel de Railway, ve a tu proyecto → **Variables** y agrega:

```env
# Django
SECRET_KEY=genera-una-clave-secreta-super-segura-aqui
DEBUG=False
ALLOWED_HOSTS=.railway.app

# Base de datos (Railway lo proporciona automáticamente)
# DATABASE_URL se crea automáticamente al agregar PostgreSQL

# Google Gemini (Chatbot IA)
GOOGLE_API_KEY=tu-api-key-de-google-gemini

# Email (Gmail)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=tu-correo@gmail.com
EMAIL_HOST_PASSWORD=tu-contraseña-de-aplicacion-gmail
```

### Variables OPCIONALES:

```env
# Supabase (si lo usas)
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_KEY=tu-clave-anon-de-supabase

# Redis (Railway lo proporciona automáticamente)
# REDIS_URL se crea automáticamente al agregar Redis

# Seguridad
USE_HTTPS=True
LOG_LEVEL=INFO

# Chatbot IA
AI_PROVIDER=gemini
AI_MODEL=gemini-1.5-flash
AI_MAX_TOKENS=1024
AI_TEMPERATURE=0.7
CHATBOT_ENABLED=True
RATELIMIT_ENABLE=True
```

### 🔑 Generar SECRET_KEY Segura

Ejecuta en tu terminal local:

```bash
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

Copia el resultado y úsalo como `SECRET_KEY` en Railway.

---

## 🗄️ Configuración de Base de Datos PostgreSQL

### Opción 1: PostgreSQL de Railway (Recomendado)

1. En tu proyecto de Railway, click en **"New"** → **"Database"** → **"PostgreSQL"**
2. Railway creará automáticamente la variable `DATABASE_URL`
3. ✅ **Listo!** Django usará automáticamente esta base de datos

### Opción 2: Supabase PostgreSQL

Si prefieres usar Supabase:

1. Copia la URL de conexión desde Supabase
2. Agrega la variable en Railway:
```env
DATABASE_URL=postgresql://user:password@host:5432/database?sslmode=require
```

---

## 🔴 Configuración de Redis

### Para Cache y WebSockets:

1. En tu proyecto de Railway, click en **"New"** → **"Database"** → **"Redis"**
2. Railway creará automáticamente la variable `REDIS_URL`
3. ✅ **Listo!** El proyecto usará Redis para cache y WebSockets

### Sin Redis (Opcional):

Si no quieres Redis, el proyecto funcionará con cache en archivos (FileBasedCache).

---

## ✨ Migración y Archivos Estáticos

Railway ejecutará automáticamente estos comandos (definidos en `Procfile`):

```bash
python manage.py migrate --noinput
python manage.py collectstatic --noinput
```

No necesitas hacer nada adicional.

---

## 🔍 Verificación y Troubleshooting

### Verificar el Despliegue:

1. **Ver logs en tiempo real**: Railway → Tu Proyecto → **Deployments** → **View Logs**
2. **URL de tu aplicación**: Railway te dará una URL como `https://tu-proyecto.railway.app`
3. **Acceder al admin**: `https://tu-proyecto.railway.app/admin/`

### Comandos Útiles en Railway:

Railway permite ejecutar comandos en el contenedor:

```bash
# Crear superusuario
python manage.py createsuperuser

# Ver migraciones
python manage.py showmigrations

# Shell de Django
python manage.py shell
```

### Problemas Comunes:

#### ❌ Error: "DisallowedHost"
**Solución**: Agregar tu dominio de Railway a `ALLOWED_HOSTS`:
```env
ALLOWED_HOSTS=.railway.app,tu-dominio-custom.com
```

#### ❌ Error: "Static files not found"
**Solución**: Verificar que `collectstatic` se ejecutó correctamente en los logs.

#### ❌ Error: "Database connection refused"
**Solución**: Asegurar que agregaste PostgreSQL desde Railway y la variable `DATABASE_URL` existe.

#### ❌ Error: "ModuleNotFoundError"
**Solución**: Verificar que todas las dependencias están en `requirements.txt`.

---

## 🐳 Desarrollo Local con Docker

Para probar localmente antes de desplegar:

```bash
# Construir y levantar todos los servicios
docker-compose up -d

# Ver logs
docker-compose logs -f web

# Detener servicios
docker-compose down

# Reconstruir después de cambios
docker-compose up -d --build
```

Accede a: `http://localhost:8000`

---

## 📊 Monitoreo en Producción

Railway proporciona:
- 📈 **Métricas de CPU y Memoria**
- 📝 **Logs en tiempo real**
- 🔄 **Deploy automático** desde GitHub
- 🔙 **Rollback** a versiones anteriores

---

## 🎯 Checklist de Despliegue

- [ ] Proyecto subido a GitHub
- [ ] Cuenta de Railway creada
- [ ] Proyecto creado en Railway desde GitHub
- [ ] PostgreSQL agregado en Railway
- [ ] Redis agregado en Railway (opcional pero recomendado)
- [ ] Variables de entorno configuradas (SECRET_KEY, GOOGLE_API_KEY, etc.)
- [ ] Primer deploy completado exitosamente
- [ ] Migraciones ejecutadas automáticamente
- [ ] Archivos estáticos recolectados
- [ ] Acceso al admin funcional
- [ ] Dominio personalizado configurado (opcional)

---

## 🆘 Soporte

Si tienes problemas:

1. **Revisar logs de Railway** (Deployments → View Logs)
2. **Verificar variables de entorno**
3. **Revisar que DATABASE_URL existe**
4. **Consultar documentación**: [docs.railway.app](https://docs.railway.app)

---

## 📝 Notas Adicionales

### Dominio Personalizado:

Railway te permite agregar dominios personalizados:
1. Railway → Tu Proyecto → **Settings** → **Domains**
2. Agrega tu dominio
3. Actualiza `ALLOWED_HOSTS` con tu dominio

### Costo:

Railway ofrece:
- ✅ **Plan gratuito**: $5 de crédito mensual
- 💰 **Plan Pro**: $20/mes con recursos adicionales

---

## ✅ ¡Listo para Producción!

Tu proyecto EcoPuntos está completamente configurado y listo para desplegarse en Railway. Solo sigue los pasos anteriores y en minutos tendrás tu aplicación en producción. 🚀
