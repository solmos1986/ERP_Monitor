#!/bin/bash
# ==========================================================
# ERP Monitor - Logger
# Archivo: lib/logger.sh
# Descripción:
#   Funciones para registrar eventos y resultados de checks.
# ==========================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

LOG_DIR="$ROOT_DIR/logs"
mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/$(date '+%Y-%m-%d').log"

# ==========================================================
# Fecha/Hora
# ==========================================================
timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

# ==========================================================
# Escritura base
# ==========================================================
write_log() {
    local level="$1"
    local message="$2"

    echo "[$(timestamp)] [$level] $message" >> "$LOG_FILE"
}

# ==========================================================
# Logs generales
# ==========================================================
log_info() {
    write_log "INFO" "$1"
}

log_success() {
    write_log "SUCCESS" "$1"
}

log_warn() {
    write_log "WARNING" "$1"
}

log_error() {
    write_log "ERROR" "$1"
}

# ==========================================================
# Registro estructurado de checks
#
# Uso:
# log_check "API" "OK" "Backend operativo" "45ms"
# log_check "CPU" "WARNING" "82%" ""
# log_check "LOGIN" "ERROR" "401 Unauthorized" "210ms"
# ==========================================================
log_check() {

    local check="$1"
    local status="$2"
    local message="$3"
    local time="$4"

    local log="[CHECK] $(printf '%-12s' "$check") STATUS=$(printf '%-8s' "$status") MESSAGE=\"$message\""

    if [ -n "$time" ]; then
        log="$log TIME=$time"
    fi

    echo "[$(timestamp)] $log" >> "$LOG_FILE"
}