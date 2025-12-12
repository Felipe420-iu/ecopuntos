"""
WSGI config for proyecto2023 project.

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/5.2/howto/deployment/wsgi/
"""

import os

from django.core.wsgi import get_wsgi_application
import traceback
import sys

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'proyecto2023.settings')

# Envolver la aplicación WSGI para imprimir tracebacks no manejados en los logs
# Esto facilita capturar la causa del cierre/crash del worker en plataformas PaaS.
_application = get_wsgi_application()

def application(environ, start_response):
	try:
		return _application(environ, start_response)
	except Exception:
		traceback.print_exc()
		# Re-lanzar para que Gunicorn lo maneje también
		raise
