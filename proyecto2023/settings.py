from pathlib import Path
import os
from decouple import config, Csv
import dj_database_url

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = config('SECRET_KEY', default='django-insecure-ao8nz6_qvfg&3*-k&66w($dl)y6v480e@tm6^t1n^tj@+8b%n-')

# SECURITY WARNING: don't run with debug turned on in production!
# Por seguridad, el valor por defecto de DEBUG es False. En desarrollo puedes activar
# DEBUG mediante la variable de entorno DEBUG=True.
DEBUG = config('DEBUG', default=False, cast=bool)

# Incluir por defecto los hosts locales y dominios Railway para evitar rechazos por ALLOWED_HOSTS
# en despliegues en Railway. En producción, configura la variable ALLOWED_HOSTS en Railway.
ALLOWED_HOSTS = config('ALLOWED_HOSTS', default='localhost,127.0.0.1,.railway.app,*.up.railway.app', cast=Csv())

# Application definition

INSTALLED_APPS = [
    'daphne',  # Debe ir primero para WebSocket/ASGI
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    
    # Third party apps
    'rest_framework',
    'rest_framework_simplejwt',
    'corsheaders',
    'crispy_forms',
    'crispy_bootstrap5',
    'channels',
    # 'django_ratelimit',  # Reemplazado por sistema personalizado más simple
    
    'core',
    'api',  
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',  # Para servir archivos estáticos
    'corsheaders.middleware.CorsMiddleware',  # Para CORS de API
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'core.session_validation_middleware.SessionValidationMiddleware',  # Validación de sesiones cerradas por admin
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'core.middleware.SecurityMiddleware',
    'core.middleware.UserStatusMiddleware',  # Middleware para verificar usuarios desactivados/suspendidos
]

ROOT_URLCONF = 'proyecto2023.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

# Database
# https://docs.djangoproject.com/en/5.2/ref/settings/#databases

# Database configuration
DATABASE_URL = config('DATABASE_URL', default='sqlite:///db.sqlite3')

if DATABASE_URL.startswith('sqlite'):
    # Configuración SQLite para desarrollo local
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': BASE_DIR / 'db.sqlite3',
        }
    }
else:
    # Configuración PostgreSQL para producción (Railway)
    DATABASES = {
        'default': dj_database_url.parse(DATABASE_URL, conn_max_age=600)
    }
    # Solo agregar SSL si es necesario (Supabase, etc.)
    if 'supabase' in DATABASE_URL or 'amazonaws' in DATABASE_URL:
        DATABASES['default']['OPTIONS'] = {'sslmode': 'require'}

# Password validation
# https://docs.djangoproject.com/en/5.2/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# Internationalization
# https://docs.djangoproject.com/en/5.2/topics/i18n/

LANGUAGE_CODE = 'es-co'

TIME_ZONE = 'America/Bogota'

USE_I18N = True

USE_TZ = True

# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/5.2/howto/static-files/

STATIC_URL = '/static/'

# Add this line to define STATIC_ROOT
STATIC_ROOT = BASE_DIR / 'staticfiles'

# Keep your existing STATICFILES_DIRS configuration
STATICFILES_DIRS = [
    BASE_DIR / 'core' / 'static',
    BASE_DIR / 'static',  # Archivos CSS del dashboard modular
]
# Media files (local by default, S3/Spaces when env vars present)
USE_S3 = config('USE_S3', default=False, cast=bool)
AWS_ACCESS_KEY_ID = config('AWS_ACCESS_KEY_ID', default='')
AWS_SECRET_ACCESS_KEY = config('AWS_SECRET_ACCESS_KEY', default='')
AWS_STORAGE_BUCKET_NAME = config('AWS_STORAGE_BUCKET_NAME', default='')
AWS_S3_REGION_NAME = config('AWS_S3_REGION_NAME', default='')
AWS_S3_ENDPOINT_URL = config('AWS_S3_ENDPOINT_URL', default='')  # e.g. https://nyc3.digitaloceanspaces.com
AWS_S3_CUSTOM_DOMAIN = config('AWS_S3_CUSTOM_DOMAIN', default='')

# Default to local media
MEDIA_ROOT = BASE_DIR / 'media'
MEDIA_URL = '/media/'

# Enable S3-compatible storage (django-storages) when requested or when AWS vars exist
if USE_S3 or (AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY and AWS_STORAGE_BUCKET_NAME):
    # Ensure django-storages esté disponible en INSTALLED_APPS
    if 'storages' not in INSTALLED_APPS:
        INSTALLED_APPS.append('storages')

    DEFAULT_FILE_STORAGE = 'storages.backends.s3boto3.S3Boto3Storage'
    AWS_DEFAULT_ACL = None
    AWS_QUERYSTRING_AUTH = False
    AWS_S3_OBJECT_PARAMETERS = {
        'CacheControl': 'max-age=86400',
    }

    # Construir MEDIA_URL
    if AWS_S3_CUSTOM_DOMAIN:
        MEDIA_URL = f'https://{AWS_S3_CUSTOM_DOMAIN}/'
    elif AWS_S3_ENDPOINT_URL:
        MEDIA_URL = f'{AWS_S3_ENDPOINT_URL.rstrip("/")}/{AWS_STORAGE_BUCKET_NAME}/'
    else:
        MEDIA_URL = f'https://{AWS_STORAGE_BUCKET_NAME}.s3.amazonaws.com/'

# Default primary key field type
# https://docs.djangoproject.com/en/5.2/ref/settings/#default-auto-field

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

AUTH_USER_MODEL = 'core.Usuario'

CRISPY_ALLOWED_TEMPLATE_PACKS = ["bootstrap5"]
CRISPY_TEMPLATE_PACK = "bootstrap5"

# Configuración de correo electrónico (DESHABILITADA - usar la configuración de abajo)
# Email configuration usando variables de entorno
# EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
# EMAIL_HOST = 'smtp.gmail.com'
# EMAIL_PORT = 587
# EMAIL_USE_TLS = True
# EMAIL_HOST_USER = 'noreply@ecopuntos.com'  # Cambia por tu remitente real
# EMAIL_HOST_PASSWORD = 'tu-contraseña-de-aplicación'  # Cambia por tu contraseña de aplicación
# DEFAULT_FROM_EMAIL = 'EcoPuntos <noreply@ecopuntos.com>'

# Configuración de autenticación
LOGIN_URL = '/iniciosesion/'
LOGIN_REDIRECT_URL = '/paneladmin/'
LOGOUT_REDIRECT_URL = '/'

# ======================================================================# CONFIGURACIONES ADICIONALES PARA PRODUCCIÓN Y NUEVAS FUNCIONALIDADES
# ======================================================================# Django REST Framework Configuration
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
        'rest_framework.authentication.SessionAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
    'DEFAULT_RENDERER_CLASSES': [
        'rest_framework.renderers.JSONRenderer',
    ],
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.AnonRateThrottle',
        'rest_framework.throttling.UserRateThrottle'
    ],
    'DEFAULT_THROTTLE_RATES': {
        'anon': '100/hour',
        'user': '1000/hour'
    }
}

# JWT Configuration
from datetime import timedelta
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=60),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
}

# CORS Configuration
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",  # React frontend
    "http://127.0.0.1:3000",
]
CORS_ALLOW_CREDENTIALS = True

# Cache Configuration - usar database cache para desarrollo (compatible con django-ratelimit)
REDIS_URL = config('REDIS_URL', default='')

# Usar file cache para desarrollo o cuando Redis no está disponible
if DEBUG or not REDIS_URL or REDIS_URL == 'redis://localhost:6379/0':
    CACHES = {
        'default': {
            'BACKEND': 'django.core.cache.backends.filebased.FileBasedCache',
            'LOCATION': BASE_DIR / 'cache',
            'TIMEOUT': 300,
            'OPTIONS': {
                'MAX_ENTRIES': 10000,
            }
        }
    }
else:
    # Redis configurado correctamente en Railway
    try:
        CACHES = {
            'default': {
                'BACKEND': 'django_redis.cache.RedisCache',
                'LOCATION': REDIS_URL,
                'OPTIONS': {
                    'CLIENT_CLASS': 'django_redis.client.DefaultClient',
                    'SOCKET_CONNECT_TIMEOUT': 5,
                    'SOCKET_TIMEOUT': 5,
                    'IGNORE_EXCEPTIONS': True,  # No romper si Redis falla
                },
                'KEY_PREFIX': 'ecopuntos',
                'TIMEOUT': 300,  # 5 minutos por defecto
            }
        }
    except Exception:
        # Fallback a file cache si hay algún problema
        CACHES = {
            'default': {
                'BACKEND': 'django.core.cache.backends.filebased.FileBasedCache',
                'LOCATION': BASE_DIR / 'cache',
                'TIMEOUT': 300,
                'OPTIONS': {
                    'MAX_ENTRIES': 10000,
                }
            }
        }

# Session Configuration
SESSION_ENGINE = 'django.contrib.sessions.backends.db'
SESSION_COOKIE_AGE = 900  # 15 minutos para usuarios regulares
SESSION_SAVE_EVERY_REQUEST = True
SESSION_EXPIRE_AT_BROWSER_CLOSE = True  # Cerrar sesión al cerrar navegador

# Configuración de timeouts diferenciados
ADMIN_SESSION_TIMEOUT = 600  # 10 minutos para administradores
USER_SESSION_TIMEOUT = 900   # 15 minutos para usuarios regulares

# Channels Configuration para WebSockets
ASGI_APPLICATION = 'proyecto2023.asgi.application'

# Usar InMemory cuando Redis no está disponible
if DEBUG or not REDIS_URL or REDIS_URL == 'redis://localhost:6379/0':
    CHANNEL_LAYERS = {
        'default': {
            'BACKEND': 'channels.layers.InMemoryChannelLayer'
        }
    }
else:
    CHANNEL_LAYERS = {
        'default': {
            'BACKEND': 'channels_redis.core.RedisChannelLayer',
            'CONFIG': {
                'hosts': [REDIS_URL],
            },
        },
    }

# Configuraciones de Seguridad Mejoradas
USE_HTTPS = config('USE_HTTPS', default=False, cast=bool)

# En producción (Railway), siempre usar HTTPS
if not DEBUG or USE_HTTPS:
    SECURE_SSL_REDIRECT = False  # Railway maneja SSL automáticamente
    SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
    SECURE_HSTS_SECONDS = 31536000  # 1 año
    SECURE_HSTS_INCLUDE_SUBDOMAINS = True
    SECURE_HSTS_PRELOAD = True
    SECURE_CONTENT_TYPE_NOSNIFF = True
    SECURE_BROWSER_XSS_FILTER = True
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True
    X_FRAME_OPTIONS = 'SAMEORIGIN'  # Cambiado de DENY a SAMEORIGIN para PWA

# Configuración PWA
PWA_APP_NAME = 'EcoPuntos'
PWA_APP_DESCRIPTION = 'Recicla, gana puntos y ayuda al medio ambiente'
PWA_APP_THEME_COLOR = '#4CAF50'
PWA_APP_BACKGROUND_COLOR = '#ffffff'
PWA_APP_DISPLAY = 'standalone'
PWA_APP_SCOPE = '/'
PWA_APP_ORIENTATION = 'portrait'
PWA_APP_START_URL = '/'
PWA_SERVICE_WORKER_PATH = '/service-worker.js'

# Configuración de Logging
# Configuración de logging optimizada para rendimiento
LOG_LEVEL = config('LOG_LEVEL', default='ERROR')
LOG_FILE_PATH = config('LOG_FILE_PATH', default='logs/ecopuntos.log')

# Crear directorio de logs si no existe
os.makedirs(os.path.dirname(LOG_FILE_PATH), exist_ok=True)

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'simple': {
            'format': '{levelname} {message}',
            'style': '{',
        },
        'detailed': {
            'format': '{asctime} {name} {levelname} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'null': {
            'class': 'logging.NullHandler',
        },
        'console': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',
            'formatter': 'detailed',
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'INFO',
    },
    'loggers': {
        'core.chatbot': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'django': {
            'handlers': ['console'],
            'level': 'INFO',
            'propagate': False,
        },
        'django.utils.autoreload': {
            'handlers': ['null'],
            'level': 'CRITICAL',
            'propagate': False,
        },
        'django.request': {
            'handlers': ['console'],
            'level': 'ERROR',
            'propagate': False,
        },
        'django.server': {
            'handlers': ['console'],
            'level': 'INFO',
            'propagate': False,
        },
        'django.template': {
            'handlers': ['console'],
            'level': 'ERROR',
            'propagate': False,
        },
        'django.db.backends': {
            'handlers': ['console'],
            'level': 'ERROR',
            'propagate': False,
        },
        'core': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'api': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
    },
}

# Configuración de archivos estáticos para producción
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

# Supabase removed — project uses PostgreSQL via DATABASE_URL

# Debug Toolbar Configuration (solo en desarrollo)
if DEBUG:
    INTERNAL_IPS = [
        '127.0.0.1',
        'localhost',
    ]
    
    DEBUG_TOOLBAR_CONFIG = {
        'SHOW_TOOLBAR_CALLBACK': lambda request: DEBUG,
    }

# Configuración de tiempo de zona para Colombia
TIME_ZONE = 'America/Bogota'
USE_TZ = True

# Configuración de idioma
LANGUAGE_CODE = 'es-co'
USE_I18N = True
USE_L10N = True

# ====================================
# CONFIGURACIÓN DE EMAIL CON GMAIL SMTP
# ====================================
# Backend de email - SMTP para enviar emails reales
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'

# Configuración de Gmail SMTP
EMAIL_HOST = config('EMAIL_HOST', default='smtp.gmail.com')
EMAIL_PORT = config('EMAIL_PORT', default=587, cast=int)
EMAIL_USE_SSL = config('EMAIL_USE_SSL', default=False, cast=bool)

# Credenciales de email (DEBEN estar configuradas en Railway)
EMAIL_HOST_USER = config('EMAIL_HOST_USER', default='')
EMAIL_HOST_PASSWORD = config('EMAIL_HOST_PASSWORD', default='')

# Configuración adicional
DEFAULT_FROM_EMAIL = config('DEFAULT_FROM_EMAIL', default=f'EcoPuntos <{EMAIL_HOST_USER}>')
SERVER_EMAIL = DEFAULT_FROM_EMAIL
EMAIL_TIMEOUT = 30

# Validación de configuración
if not EMAIL_HOST_USER or not EMAIL_HOST_PASSWORD:
    import warnings
    warnings.warn(
        'EMAIL_HOST_USER o EMAIL_HOST_PASSWORD no están configurados. '
        'El envío de emails fallará. Configura estas variables en Railway.',
        RuntimeWarning
    )

# ====================================
# CONFIGURACIÓN DEL CHATBOT IA
# ====================================
# Configuración de Google Gemini
GOOGLE_API_KEY = config('GOOGLE_API_KEY', default='')

# Configuración del chatbot - Solo Gemini 1.5 Flash
AI_PROVIDER = config('AI_PROVIDER', default='gemini')
AI_MODEL = config('AI_MODEL', default='gemini-1.5-flash')
AI_MAX_TOKENS = config('AI_MAX_TOKENS', default=1024, cast=int)
AI_TEMPERATURE = config('AI_TEMPERATURE', default=0.7, cast=float)

# Comportamiento del chatbot
AUTO_ESCALATE_KEYWORDS = config('AUTO_ESCALATE_KEYWORDS', default='humano,agente,supervisor,persona,admin').split(',')
CONFIDENCE_THRESHOLD = config('CONFIDENCE_THRESHOLD', default=0.7, cast=float)
MAX_CONVERSATION_TURNS = config('MAX_CONVERSATION_TURNS', default=20, cast=int)
CHATBOT_ENABLED = config('CHATBOT_ENABLED', default=True, cast=bool)

# ====================================
# CONFIGURACIÓN DE RATE LIMITING / THROTTLING
# ====================================

# Configuración global de django-ratelimit
RATELIMIT_ENABLE = config('RATELIMIT_ENABLE', default=True, cast=bool)  # ACTIVADO COMPLETAMENTE
RATELIMIT_USE_CACHE = 'default'  # Usar cache de Django

# Límites por tipo de operación
RATELIMIT_RATES = {
    # Autenticación (muy restrictivo)
    'login': '5/m',              # 5 intentos por minuto
    'register': '3/h',           # 3 registros por hora
    'password_reset': '3/h',     # 3 recuperaciones por hora
    
    # Operaciones del usuario normal
    'dashboard': '60/m',         # 60 vistas por minuto
    'canjes': '10/h',           # 10 solicitudes de canje por hora
    'rutas': '20/h',            # 20 solicitudes de recolección por hora
    'profile_update': '10/h',    # 10 actualizaciones de perfil por hora
    
    # Operaciones de conductor
    'aprobar_canje': '30/h',     # 30 aprobaciones por hora
    'rechazar_canje': '30/h',    # 30 rechazos por hora
    'confirmar_ruta': '40/h',    # 40 confirmaciones por hora
    'reagendar_ruta': '20/h',    # 20 reagendamientos por hora
    
    # Chatbot y soporte
    'chatbot_message': '30/m',   # 30 mensajes por minuto
    'chatbot_session': '100/h',  # 100 mensajes por hora por sesión
    
    # Emails
    'send_email': '5/h',         # 5 emails por hora
    'contact_form': '3/h',       # 3 formularios de contacto por hora
    
    # APIs generales
    'api_general': '100/h',      # 100 requests API por hora
    'api_admin': '500/h',        # 500 requests para admin
    
    # Por rol de usuario
    'user_general': '100/h',     # Usuarios normales
    'conductor_general': '200/h', # Conductores
    'admin_general': '500/h',    # Administradores
    'anonymous': '20/h',         # No autenticados
}

# Mensaje cuando se excede el límite
RATELIMIT_VIEW = 'core.views.ratelimit_error'  # Vista personalizada para errores

