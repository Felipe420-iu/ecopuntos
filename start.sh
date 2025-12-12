#!/bin/bash
set -x

echo "==== START.SH VERBOSE START ===="
date
echo "Running migrations..."
python manage.py migrate --noinput

echo "Collecting static files..."
python manage.py collectstatic --noinput || echo "collectstatic failed, continuing..."

echo "Ensuring superuser exists (create_superadmin)..."
## build command with optional username/email args (password should stay in env vars)
# Use a portable approach that works in /bin/bash -c
CREATE_CMD="python create_superadmin.py --use-railway --migrate"
if [ -n "${DJANGO_SUPERUSER_USERNAME:-}" ]; then
  CREATE_CMD="$CREATE_CMD --username \"${DJANGO_SUPERUSER_USERNAME}\""
fi
if [ -n "${DJANGO_SUPERUSER_EMAIL:-}" ]; then
  CREATE_CMD="$CREATE_CMD --email \"${DJANGO_SUPERUSER_EMAIL}\""
fi

# Execute command (password must be in env var DJANGO_SUPERUSER_PASSWORD in Railway)
sh -c "$CREATE_CMD" || echo "create_superadmin failed or skipped, continuing..."

echo "Starting server..."
echo "Starting Daphne ASGI on port ${PORT:-8080}..."
echo "Python version: $(python -V 2>&1)"
echo "PORT=${PORT:-unset} DEBUG=${DEBUG:-unset} DATABASE_URL=$(if [ -n "${DATABASE_URL:-}" ]; then echo 'set'; else echo 'unset'; fi)"

# Ensure Python output isn't buffered so logs appear in real-time in Railway
export PYTHONUNBUFFERED=1
echo "PYTHONUNBUFFERED=${PYTHONUNBUFFERED} LOG_LEVEL=${LOG_LEVEL:-unset}"

echo "==== START.SH: launch Daphne (simplified) ===="
echo "--- ASGI import test ---"
python -c "import proyecto2023.asgi; print('ASGI import OK')" || echo 'ASGI import FAILED'

# Simple Daphne launch without exec
PORT=${PORT:-8080}
DAPHNE_MODULE="proyecto2023.asgi:application"
echo "🚀 Starting Daphne on 0.0.0.0:${PORT}"
echo "Module: ${DAPHNE_MODULE}"

# Direct run (not exec) to see what happens
daphne -b 0.0.0.0 -p ${PORT} --verbosity 2 --access-log - ${DAPHNE_MODULE}
