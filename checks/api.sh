#!/bin/bash
# ==========================================================
# ERP Monitor - API Check
# Archivo: checks/api.sh
# Descripción:
#   Verifica que la URL principal del ERP responda.
# ==========================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/config/config.sh"
source "$ROOT_DIR/lib/logger.sh"

# ==========================================================
# Ejecutar Check
# ==========================================================

check_api() {

    log_info "Verificando API..."

    local response
    local http_code
    local time_ms
    local curl_exit

    response=$(curl \
        --silent \
        --show-error \
        --output /dev/null \
        --write-out "%{http_code};%{time_total}" \
        --connect-timeout "$API_TIMEOUT" \
        "$API_URL")

    curl_exit=$?

    # ======================================================
    # Error de conexión
    # ======================================================

    if [ $curl_exit -ne 0 ]; then

        log_check "API" "ERROR" "No fue posible conectar" ""

        return 2
    fi

    http_code=$(echo "$response" | cut -d';' -f1)

    time_ms=$(echo "$response" | cut -d';' -f2)

    # convertir segundos a milisegundos
    time_ms=$(awk "BEGIN {printf \"%d\", $time_ms * 1000}")

    # ======================================================
    # Código HTTP distinto de 200
    # ======================================================

    if [ "$http_code" != "200" ]; then

        log_check "API" "ERROR" "HTTP $http_code" "${time_ms}ms"

        return 2
    fi

    # ======================================================
    # Respuesta lenta
    # ======================================================

    if [ "$time_ms" -ge "$API_WARNING_MS" ]; then

        log_check "API" "WARNING" "Respuesta lenta" "${time_ms}ms"

        return 1
    fi

    # ======================================================
    # Todo correcto
    # ======================================================

    log_check "API" "OK" "Disponible" "${time_ms}ms"

    return 0
}

# ==========================================================
# Ejecución directa
# ==========================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    check_api
    exit $?

fi