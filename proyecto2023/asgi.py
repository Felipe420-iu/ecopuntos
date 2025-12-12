"""
ASGI config for proyecto2023 project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/5.2/howto/deployment/asgi/
"""

import os
from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter, URLRouter
from channels.auth import AuthMiddlewareStack
from channels.security.websocket import AllowedHostsOriginValidator

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'proyecto2023.settings')

# Inicializar la app WSGI/ASGI para asegurar que las aplicaciones estén cargadas
django_asgi_app = get_asgi_application()

# Importar routing de WebSockets DESPUÉS de inicializar Django.
# Evita importar modelos antes de que el registry de apps esté listo.
try:
    from core.routing import websocket_urlpatterns
except Exception:
    websocket_urlpatterns = []

application = ProtocolTypeRouter({
    "http": django_asgi_app,
    "websocket": AllowedHostsOriginValidator(
        AuthMiddlewareStack(
            URLRouter(websocket_urlpatterns)
        )
    ),
})