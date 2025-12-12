import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'proyecto2023.settings')
django.setup()

from core.models import Usuario

# Buscar conductores
conductores = Usuario.objects.filter(role='conductor')
print(f"Total de conductores: {conductores.count()}")

for conductor in conductores:
    print(f"\nConductor: {conductor.username}")
    print(f"  - ID: {conductor.id}")
    print(f"  - Email: {conductor.email}")
    print(f"  - Zona asignada: {conductor.zona_asignada}")
    print(f"  - Role: {conductor.role}")

# Verificar si hay algún conductor con sesión activa
print("\n" + "="*50)
if conductores.exists():
    primer_conductor = conductores.first()
    print(f"\nPrimer conductor encontrado: {primer_conductor.username}")
    print(f"Zona asignada: {primer_conductor.zona_asignada}")
    if primer_conductor.zona_asignada:
        print("✅ El conductor TIENE zona asignada")
    else:
        print("❌ El conductor NO tiene zona asignada")
