from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.views.generic import TemplateView
from django.http import HttpResponse, FileResponse
import os
from django.http import JsonResponse

# Vistas para PWA
def service_worker(request):
    """Sirve el service worker desde static"""
    file_path = os.path.join(settings.BASE_DIR, 'static', 'pwa', 'service-worker.js')
    try:
        with open(file_path, 'rb') as f:
            return HttpResponse(f.read(), content_type='application/javascript')
    except FileNotFoundError:
        return HttpResponse('Service Worker no encontrado', status=404)

def manifest(request):
    """Sirve el manifest desde static"""
    file_path = os.path.join(settings.BASE_DIR, 'static', 'pwa', 'manifest.json')
    try:
        with open(file_path, 'rb') as f:
            return HttpResponse(f.read(), content_type='application/manifest+json')
    except FileNotFoundError:
        return HttpResponse('Manifest no encontrado', status=404)

urlpatterns = [
    path('', include('core.urls')),  # Incluye todas las URLs de la aplicación core
    path('admin/', admin.site.urls),
    path('api/v1/', include('api.urls')),  # Incluye las URLs de la API REST
    # Health check simple para despliegues
    path('healthz', lambda request: JsonResponse({'status': 'ok'}), name='healthz'),
    
    # PWA URLs
    path('service-worker.js', service_worker, name='service_worker'),
    path('manifest.json', manifest, name='manifest'),
    path('offline/', TemplateView.as_view(template_name='core/offline.html'), name='offline'),
]

# Agregar debug toolbar solo en desarrollo
# if settings.DEBUG:
#     import debug_toolbar
#     urlpatterns = [
#         path('__debug__/', include(debug_toolbar.urls)),
#     ] + urlpatterns

# Configuración para servir archivos estáticos y de medios en desarrollo
if settings.DEBUG:
    from django.contrib.staticfiles.urls import staticfiles_urlpatterns
    urlpatterns += staticfiles_urlpatterns()
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
else:
    # Configuración para servir archivos estáticos y de medios en producción
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
        # URL para la página de inicio
