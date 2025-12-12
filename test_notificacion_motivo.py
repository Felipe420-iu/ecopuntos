"""
Script para crear una notificación de prueba con motivo de reagendamiento
Uso: python test_notificacion_motivo.py
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
from core.models import Usuario, Notificacion

def crear_notificacion_prueba():
    """Crea una notificación de prueba con motivo para el primer usuario regular"""
    
    print("🔍 Buscando usuario regular...")
    
    # Buscar el primer usuario que no sea superusuario
    usuario = Usuario.objects.filter(
        is_superuser=False,
        is_active=True
    ).first()
    
    if not usuario:
        print("❌ No se encontró ningún usuario regular en la base de datos")
        print("   Crea un usuario primero con: python manage.py createsuperuser")
        return
    
    print(f"✓ Usuario encontrado: {usuario.username} ({usuario.email})")
    
    # Crear notificación de reagendamiento con motivo
    notificacion = Notificacion.objects.create(
        usuario=usuario,
        titulo='Ruta de Recolección Reagendada',
        mensaje='Tu ruta de recolección ha sido reprogramada para el próximo martes 10 de diciembre a las 10:00 AM.',
        motivo='El conductor anterior tuvo un inconveniente mecánico con el vehículo. Hemos asignado un nuevo conductor para garantizar tu servicio.',
        tipo='sistema',
        leida=False,
        fecha_creacion=timezone.now()
    )
    
    print(f"✅ Notificación creada exitosamente:")
    print(f"   ID: {notificacion.id}")
    print(f"   Título: {notificacion.titulo}")
    print(f"   Mensaje: {notificacion.mensaje}")
    print(f"   Motivo: {notificacion.motivo}")
    print(f"   Usuario: {notificacion.usuario.username}")
    print(f"   Leída: {notificacion.leida}")
    print()
    print("🔔 Ahora puedes:")
    print(f"   1. Iniciar sesión como: {usuario.username}")
    print("   2. Ir al dashboard (/dashusuario/)")
    print("   3. Verás el modal con la notificación automáticamente")

if __name__ == '__main__':
    print("=" * 60)
    print("  CREAR NOTIFICACIÓN DE PRUEBA CON MOTIVO")
    print("=" * 60)
    print()
    
    try:
        crear_notificacion_prueba()
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
    
    print()
    print("=" * 60)
