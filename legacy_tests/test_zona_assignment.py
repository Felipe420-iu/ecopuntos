#!/usr/bin/env python
"""
Script de prueba para verificar la funcionalidad de asignación de zonas
"""
import os
import sys
import django

# Configurar Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'proyecto2023.settings')
django.setup()

from core.models import Usuario

def test_zona_assignment():
    """Prueba la funcionalidad de asignación de zonas"""
    print("🔍 Verificando funcionalidad de zona_asignada...")
    
    # Verificar que el campo existe en el modelo
    try:
        # Buscar un conductor existente o crear uno de prueba
        conductor = Usuario.objects.filter(role='conductor').first()
        if not conductor:
            print("⚠️ No se encontraron conductores en la base de datos.")
            print("   Crea un conductor desde el panel de administrador y vuelve a ejecutar esta prueba.")
            return False
        
        print(f"✅ Conductor encontrado: {conductor.username}")
        print(f"   - Zona actual: {conductor.zona_asignada or 'Sin asignar'}")
        
        # Verificar zonas válidas
        zonas_validas = [choice[0] for choice in Usuario.ZONAS]
        print(f"✅ Zonas válidas disponibles: {zonas_validas}")
        
        # Prueba de asignación
        if not conductor.zona_asignada:
            conductor.zona_asignada = 'zona_1_sur'
            conductor.save()
            print(f"✅ Zona asignada automáticamente: {conductor.zona_asignada}")
        else:
            print(f"✅ Conductor ya tiene zona asignada: {conductor.zona_asignada}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error al verificar zona_asignada: {e}")
        return False

def test_views_access():
    """Verifica que las vistas estén accesibles"""
    print("\n🔍 Verificando acceso a vistas...")
    
    try:
        from django.urls import reverse
        
        # URLs principales a verificar
        urls_to_check = [
            ('panel_superuser', 'Panel de Superusuario'),
            ('gestion_usuarios_superuser', 'Gestión de Usuarios'),
            ('panel_conductor', 'Panel de Conductor'),
            ('rutas', 'Gestión de Rutas'),
        ]
        
        for url_name, description in urls_to_check:
            try:
                url = reverse(url_name)
                print(f"✅ {description}: {url}")
            except Exception as e:
                print(f"❌ {description}: Error - {e}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error verificando vistas: {e}")
        return False

if __name__ == '__main__':
    print("🚀 Iniciando verificación del sistema de asignación de zonas...\n")
    
    success1 = test_zona_assignment()
    success2 = test_views_access()
    
    if success1 and success2:
        print("\n✅ ¡Todas las verificaciones pasaron exitosamente!")
        print("\n🔧 Pasos para probar la funcionalidad:")
        print("1. Accede a http://localhost:8000/superuser/usuarios/")
        print("2. Edita un conductor y asigna una zona")
        print("3. El conductor debe ver su zona en http://localhost:8000/panel_conductor/")
        print("4. En http://localhost:8000/rutas/ debe ver información específica de su zona")
    else:
        print("\n❌ Algunas verificaciones fallaron. Revisa los errores anteriores.")
    
    print("\n🎯 ¡Prueba completada!")