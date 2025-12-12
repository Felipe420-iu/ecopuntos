"""
Script para probar el flujo completo de notificaciones
Uso: python test_flujo_notificaciones.py
"""

import os
import sys
import django
from pathlib import Path

# Configurar el path para Django
BASE_DIR = Path(__file__).resolve().parent
sys.path.append(str(BASE_DIR))

# Configurar Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'proyecto2023.settings')
django.setup()

from django.utils import timezone
from core.models import Usuario, Notificacion, Ruta

def test_notificaciones():
    """Prueba el sistema completo de notificaciones"""
    
    print("=" * 70)
    print("  TEST COMPLETO DEL SISTEMA DE NOTIFICACIONES")
    print("=" * 70)
    print()
    
    # 1. Buscar usuario
    print("1️⃣  Buscando usuario PIOLINES...")
    try:
        usuario = Usuario.objects.get(username='PIOLINES')
        print(f"   ✅ Usuario encontrado: {usuario.username} ({usuario.email})")
    except Usuario.DoesNotExist:
        print("   ❌ Usuario PIOLINES no encontrado")
        usuario = Usuario.objects.filter(is_superuser=False, is_active=True).first()
        if usuario:
            print(f"   📌 Usando usuario alternativo: {usuario.username}")
        else:
            print("   ❌ No hay usuarios disponibles")
            return
    print()
    
    # 2. Verificar notificaciones existentes
    print("2️⃣  Verificando notificaciones existentes...")
    notifs_totales = Notificacion.objects.filter(usuario=usuario).count()
    notifs_no_leidas = Notificacion.objects.filter(usuario=usuario, leida=False).count()
    print(f"   📊 Total de notificaciones: {notifs_totales}")
    print(f"   📬 No leídas: {notifs_no_leidas}")
    print()
    
    # 3. Mostrar últimas 3 notificaciones no leídas
    print("3️⃣  Últimas notificaciones no leídas:")
    notifs = Notificacion.objects.filter(
        usuario=usuario, 
        leida=False
    ).order_by('-fecha_creacion')[:3]
    
    if notifs.exists():
        for i, notif in enumerate(notifs, 1):
            print(f"   {i}. ID: {notif.id}")
            print(f"      Título: {notif.titulo}")
            print(f"      Mensaje: {notif.mensaje[:60]}...")
            print(f"      Motivo: {notif.motivo if notif.motivo else 'Sin motivo'}")
            print(f"      Fecha: {notif.fecha_creacion.strftime('%d/%m/%Y %H:%M')}")
            print()
    else:
        print("   ℹ️  No hay notificaciones no leídas")
        print()
    
    # 4. Verificar rutas
    print("4️⃣  Verificando rutas del usuario...")
    rutas = Ruta.objects.filter(usuario=usuario).order_by('-fecha_creacion')[:3]
    print(f"   📍 Total de rutas: {Ruta.objects.filter(usuario=usuario).count()}")
    
    if rutas.exists():
        print(f"   📝 Últimas 3 rutas:")
        for i, ruta in enumerate(rutas, 1):
            print(f"   {i}. ID: {ruta.id} | Estado: {ruta.estado}")
            print(f"      Fecha: {ruta.fecha} {ruta.hora}")
            print(f"      Motivo reagendamiento: {ruta.motivo_reagendamiento if hasattr(ruta, 'motivo_reagendamiento') and ruta.motivo_reagendamiento else 'Sin motivo'}")
            print()
    else:
        print("   ℹ️  No tiene rutas registradas")
        print()
    
    # 5. Crear notificación de prueba
    print("5️⃣  Creando nueva notificación de prueba...")
    try:
        nueva_notif = Notificacion.objects.create(
            usuario=usuario,
            titulo='🧪 Notificación de Prueba Sistema Completo',
            mensaje='Esta es una notificación de prueba para verificar que el modal se muestre correctamente al entrar al dashboard.',
            motivo='Este es el motivo de prueba que debería aparecer en el recuadro amarillo del modal.',
            tipo='sistema',
            leida=False
        )
        print(f"   ✅ Notificación creada - ID: {nueva_notif.id}")
        print()
    except Exception as e:
        print(f"   ❌ Error creando notificación: {e}")
        print()
    
    # 6. Instrucciones para probar
    print("=" * 70)
    print("  📋 INSTRUCCIONES PARA PROBAR:")
    print("=" * 70)
    print()
    print(f"1. Iniciar sesión como: {usuario.username}")
    print("2. Ir a: http://127.0.0.1:8000/dashusuario/")
    print("3. IMPORTANTE: Abrir DevTools (F12) → pestaña Console")
    print("4. Recargar la página y verificar:")
    print()
    print("   ✅ El modal debe aparecer automáticamente")
    print("   ✅ Debe mostrar el título de la notificación")
    print("   ✅ Debe mostrar el mensaje")
    print("   ✅ Debe mostrar el motivo en recuadro amarillo")
    print("   ✅ Botón 'Aceptar' debe cerrar el modal")
    print("   ✅ Al recargar NO debe volver a aparecer")
    print()
    print("5. Ir a: http://127.0.0.1:8000/rutasusuario/")
    print("6. Hacer clic en 'Historial de Rutas'")
    print("7. Verificar que se muestre el motivo de reagendamiento")
    print()
    print("📊 VERIFICACIÓN EN CONSOLA:")
    print("   Buscar en Console de DevTools:")
    print("   • '🔍 Verificando notificaciones...'")
    print("   • 'API Response' con la notificación")
    print("   • '✓ Notificación marcada como leída' (después de Aceptar)")
    print()
    print("🚨 SI EL MODAL NO APARECE:")
    print("   1. Verificar errores en Console")
    print("   2. Verificar que Bootstrap esté cargado")
    print("   3. Verificar que el endpoint responda:")
    print(f"      curl http://127.0.0.1:8000/api/notifications/latest-unread/")
    print()
    print("=" * 70)

if __name__ == '__main__':
    try:
        test_notificaciones()
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
