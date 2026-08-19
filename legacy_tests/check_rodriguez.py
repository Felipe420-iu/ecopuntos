import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'proyecto2023.settings')
django.setup()

from core.models import Usuario

# Buscar el conductor Rodriguez
rodriguez = Usuario.objects.get(username='Rodriguez')
print(f"✅ Usuario encontrado:")
print(f"   Username: {rodriguez.username}")
print(f"   Email: {rodriguez.email}")
print(f"   Zona asignada: {rodriguez.zona_asignada}")
print(f"\n⚠️ La contraseña está encriptada en la base de datos.")
print(f"   Si no recuerdas la contraseña, puedo crear una nueva.")
print(f"\n📝 ¿Quieres que establezca una nueva contraseña? (por ejemplo: 'rodriguez123')")
