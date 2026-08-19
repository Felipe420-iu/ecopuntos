#!/usr/bin/env python
"""
create_superadmin.py

Script para crear o actualizar un superusuario Django no interactivo.
Usa las variables de entorno (recomendado en Railway) o solicitará datos por consola.

Variables de entorno soportadas:
- DJANGO_SETTINGS_MODULE (opcional, por defecto 'proyecto2023.settings')
- DJANGO_SUPERUSER_USERNAME
- DJANGO_SUPERUSER_EMAIL
- DJANGO_SUPERUSER_PASSWORD

Uso (PowerShell):
$env:DJANGO_SUPERUSER_USERNAME = 'admin'; $env:DJANGO_SUPERUSER_EMAIL = 'admin@example.com'; $env:DJANGO_SUPERUSER_PASSWORD = 'Secret123!'; python create_superadmin.py

"""
import os
import sys
import getpass

# Set default Django settings module if not present
import argparse
from django.core.exceptions import ImproperlyConfigured


def parse_args():
    p = argparse.ArgumentParser(description='Crear/Actualizar superusuario Django (soporta Railway env vars)')
    p.add_argument('--username', help='Nombre de usuario (override env DJANGO_SUPERUSER_USERNAME)')
    p.add_argument('--email', help='Email (override env DJANGO_SUPERUSER_EMAIL)')
    p.add_argument('--password', help='Password (override env DJANGO_SUPERUSER_PASSWORD)')
    p.add_argument('--database-url', help='URL de la base de datos (ej: postgresql://...)')
    p.add_argument('--use-railway', action='store_true', help='Usar RAILWAY_DATABASE_URL o DATABASE_URL del entorno')
    p.add_argument('--use-sqlite', action='store_true', help='Forzar sqlite local (sqlite:///db.sqlite3)')
    p.add_argument('--migrate', action='store_true', help='Ejecutar migraciones antes de crear el superusuario')
    return p.parse_args()


args = parse_args()

# Set default Django settings module if not present
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'proyecto2023.settings')

# Handle database URL overrides BEFORE importing Django
if args.use_sqlite:
    os.environ['DATABASE_URL'] = 'sqlite:///db.sqlite3'
    print("Usando sqlite local: DATABASE_URL=sqlite:///db.sqlite3")
elif args.database_url:
    os.environ['DATABASE_URL'] = args.database_url
    print("Usando DATABASE_URL desde argumento.")
elif args.use_railway:
    # Prefer explicit railway variable names, fallback to DATABASE_URL
    rail_db = os.environ.get('RAILWAY_DATABASE_URL') or os.environ.get('RAILWAY_POSTGRESQL_URL') or os.environ.get('DATABASE_URL')
    if rail_db:
        os.environ['DATABASE_URL'] = rail_db
        print('Usando DATABASE_URL desde Railway env var.')
    else:
        print('Advertencia: no se encontró RAILWAY_DATABASE_URL en el entorno. Se usará DATABASE_URL si existe.')

try:
    import django
except Exception as e:
    print("Error: Django no está instalado o no se puede importar.")
    print(e)
    sys.exit(1)

try:
    django.setup()
except ImproperlyConfigured as e:
    print("Error al configurar Django:", e)
    sys.exit(1)

from django.contrib.auth import get_user_model
from django.core.management import call_command
from django.db import OperationalError

User = get_user_model()

def get_env_or_input(varname, prompt_text, hide=False):
    val = os.environ.get(varname)
    # CLI arguments override env when provided
    arg_val = None
    if varname == 'DJANGO_SUPERUSER_USERNAME' and args.username:
        arg_val = args.username
    if varname == 'DJANGO_SUPERUSER_EMAIL' and args.email:
        arg_val = args.email
    if varname == 'DJANGO_SUPERUSER_PASSWORD' and args.password:
        arg_val = args.password

    if arg_val:
        return arg_val

    if val:
        return val
    # If running in a non-interactive environment (no TTY), do not prompt
    if hide:
        if not sys.stdin.isatty():
            return None
        return getpass.getpass(prompt_text + ': ')
    if not sys.stdin.isatty():
        return None
    return input(prompt_text + ': ')


def create_or_update_superuser(username, email, password):
    try:
        user = User.objects.filter(username=username).first()
        if user:
            print(f"Usuario existente encontrado: {username}. Actualizando permisos...")
            user.email = email or user.email
            user.is_active = True
            user.is_staff = True
            user.is_superuser = True
            # Si el modelo tiene campo 'role', lo marcamos
            if hasattr(user, 'role'):
                try:
                    user.role = 'superuser'
                except Exception:
                    pass
            if password:
                user.set_password(password)
            user.save()
            print(f"✅ Usuario '{username}' actualizado como superusuario.")
            return user
        else:
            # create_superuser should work for AbstractUser-based models
            if password:
                user = User.objects.create_superuser(username=username, email=email, password=password)
            else:
                user = User.objects.create_superuser(username=username, email=email)
            # Ensure custom role field if exists
            if hasattr(user, 'role'):
                try:
                    user.role = 'superuser'
                    user.save()
                except Exception:
                    pass
            print(f"✅ Superusuario '{username}' creado correctamente.")
            return user
    except Exception as e:
        print("Error creando/actualizando superusuario:", e)
        raise


def main():
    print("== Crear/Actualizar Superusuario Django ==")
    username = get_env_or_input('DJANGO_SUPERUSER_USERNAME', 'Nombre de usuario (DJANGO_SUPERUSER_USERNAME)')
    email = get_env_or_input('DJANGO_SUPERUSER_EMAIL', 'Email (DJANGO_SUPERUSER_EMAIL)')
    # Password: from arg/env then prompt securely
    password = args.password or os.environ.get('DJANGO_SUPERUSER_PASSWORD')
    if not password:
        password = get_env_or_input('DJANGO_SUPERUSER_PASSWORD', 'Contraseña (DJANGO_SUPERUSER_PASSWORD)', hide=True)

    # Run migrations if requested (useful en Railway shell)
    if args.migrate:
        try:
            print('Ejecutando migraciones: python manage.py migrate')
            call_command('migrate', interactive=False)
            print('Migraciones completadas.')
        except OperationalError as e:
            print('Error al aplicar migraciones (DB inaccesible o credenciales incorrectas):', e)
            sys.exit(4)

    if not username or not email or not password:
        print('\nError: username, email y password son requeridos. Aborting.')
        sys.exit(2)

    try:
        create_or_update_superuser(username, email, password)
    except Exception as e:
        print('Fallo al crear superusuario:', e)
        sys.exit(3)

if __name__ == '__main__':
    main()
