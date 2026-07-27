#!/bin/bash

# ==========================================================
# ERP Monitor V1
# Configuration File
# ==========================================================

# ==========================================================
# SERVER
# ==========================================================

# Nombre del servidor
SERVER_NAME="ERP Producción Bolivia"

# Dominio principal
DOMAIN="apigymcloud.aplus-security.com"

# URL base de la API
API_URL="https://apigymcloud.aplus-security.com"

API_TIMEOUT=10

API_WARNING_MS=1000

# Zona horaria
TIMEZONE="America/La_Paz"

# ==========================================================
# ERP LOGIN
# ==========================================================

# Endpoint de autenticación
LOGIN_ENDPOINT="/auth/login"

# Usuario técnico de monitoreo
LOGIN_USER="monitor@erp.com"

# Contraseña del usuario técnico
LOGIN_PASSWORD="monitor.2026"

# Timeout máximo para peticiones HTTP (segundos)
LOGIN_TIMEOUT=10
LOGIN_WARNING_MS=1500

# User Agent utilizado por el monitor
HTTP_USER_AGENT="ERP-Monitor/1.0"

# ==========================================================
# TELEGRAM
# ==========================================================

# Token del Bot
TELEGRAM_BOT_TOKEN="8663978198:AAE0noehH_KKTgWU5SI3LbSOmr1ZJK5JpTw"

# Chat ID
TELEGRAM_CHAT_ID="5977858546"

# ==========================================================
# POSTGRESQL
# ==========================================================

POSTGRES_HOST="erp_postgres"
POSTGRES_PORT="5432"
POSTGRES_DATABASE="erp_saas"
POSTGRES_USER="erp_user"
POSTGRES_PASSWORD="Erp123456!"

# ==========================================================
# DOCKER
# ==========================================================

# Directorio donde se encuentra docker-compose.yml
DOCKER_COMPOSE_DIR="/opt/erp"

# Nombres de los contenedores
BACKEND_CONTAINER="erp_backend"
POSTGRES_CONTAINER="erp_postgres"

# ==========================================================
# BACKUP
# ==========================================================

# Directorio donde se almacenan los backups
BACKUP_DIR="/opt/backups"

# Prefijo del nombre del backup
BACKUP_PREFIX="erp_backup"

# Máxima antigüedad permitida del backup (horas)
BACKUP_MAX_AGE=26

# ==========================================================
# SSL
# ==========================================================

# Dominios a verificar
SSL_DOMAINS=(
    "apigymcloud.aplus-security.com"
)

# Alertas de vencimiento (días)
SSL_ALERT_DAYS=(
    30
    15
    7
    3
    1
)

# ==========================================================
# UMBRALES
# ==========================================================

# CPU (%)
CPU_WARNING=50
CPU_DANGER=70
CPU_CRITICAL=90

# RAM (%)
RAM_WARNING=50
RAM_DANGER=70
RAM_CRITICAL=90

# Disco (% utilizado)
DISK_WARNING=80
DISK_DANGER=90
DISK_CRITICAL=95

# Latencia Backend (ms)
BACKEND_RESPONSE_WARNING=500
BACKEND_RESPONSE_DANGER=1000

# Login ERP (ms)
LOGIN_RESPONSE_WARNING=1000
LOGIN_RESPONSE_DANGER=2000

# PostgreSQL (ms)
POSTGRES_RESPONSE_WARNING=300
POSTGRES_RESPONSE_DANGER=800

# ==========================================================
# DIRECTORIOS
# ==========================================================

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

LOG_DIR="$BASE_DIR/logs"
STATE_DIR="$BASE_DIR/state"
HISTORY_DIR="$BASE_DIR/history"

# ==========================================================
# MONITOR
# ==========================================================

# Intervalo principal de ejecución (segundos)
CHECK_INTERVAL=300

# Nivel de log
LOG_LEVEL="INFO"

# Cantidad de días que se conservan los logs
LOG_RETENTION_DAYS=30

# development | production
MONITOR_MODE="development"

# ==========================================================
# REPORTES
# ==========================================================

# Hora del resumen diario (formato 24 horas)
DAILY_REPORT_HOUR="08:00"

# ==========================================================
# FIN DEL ARCHIVO
# ==========================================================
