import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'proyecto2023.settings')
django.setup()

from core.models import Usuario

# Cambiar contraseña del usuario Rodriguez
rodriguez = Usuario.objects.get(username='Rodriguez')
nueva_password = 'rodriguez123'
rodriguez.set_password(nueva_password)
rodriguez.save()

print("=" * 60)
print("✅ Contraseña actualizada exitosamente!")
print("=" * 60)
print(f"\n🔑 CREDENCIALES DEL CONDUCTOR RODRIGUEZ:")
print(f"\n   Usuario:     Rodriguez")
print(f"   Contraseña:  rodriguez123")
print(f"   Email:       {rodriguez.email}")
print(f"   Zona:        {rodriguez.get_zona_asignada_display()}")
print(f"\n📍 URL de login: http://127.0.0.1:8000/inicioadmin/")
print(f"   (O usa: http://127.0.0.1:8000/iniciosesion/)")
print("\n" + "=" * 60)
