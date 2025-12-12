# Dockerfile para EcoPuntos (producción en Railway usando Daphne ASGI)
FROM python:3.12-slim

# Variables de entorno
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

# Dependencias del sistema necesarias para psycopg2 y compilación
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    procps \
    build-essential \
    libpq-dev \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar requirements e instalar paquetes Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código al contenedor
COPY . .

# Crear directorios y establecer permisos (útil para collectstatic/media/logs)
RUN mkdir -p logs media staticfiles \
 && adduser --disabled-password --gecos '' appuser \
 && chown -R appuser:appuser /app

USER appuser

# Exponer puerto documental (Railway proporciona $PORT en runtime)
EXPOSE 8080

# Aseguramos permisos sobre start.sh por si lo usas localmente, pero en producción
# el contenedor arrancará usando el CMD que inicia Daphne y escucha en ${PORT}.
USER root
RUN chmod +x /app/start.sh || true
USER appuser

## Temporarily use start.sh as ENTRYPOINT to gather verbose startup logs for debugging.
## This will run migrations/collectstatic and then exec Daphne. Remove when issue fixed.
USER root
RUN chmod +x /app/start.sh || true
USER appuser

ENTRYPOINT ["/bin/bash", "/app/start.sh"]