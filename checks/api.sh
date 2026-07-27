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
source "$ROOT_DIR/lib/state.sh"
source "$ROOT_DIR/lib/report.sh"

# ==========================================================
# Ejecutar Check
# ==========================================================

check_api() {

    log_info "Verificando API..."

    local response
    local http_code
    local time_ms
    local curl_exit

    local STATE_KEY="API"

    response=$(curl \
        --silent \
        --show-error \
        --output /dev/null \
        --write-out "%{http_code};%{time_total}" \
        --connect-timeout "$API_TIMEOUT" \
        "$API_URL/health")

    curl_exit=$?

    #########################################################
    # Error de conexión
    #########################################################

    if [ $curl_exit -ne 0 ]; then

        API_TIME=0

        log_check \
            "API" \
            "ERROR" \
            "No fue posible conectar" \
            ""

        if state_changed "$STATE_KEY" "ERROR"; then

            report_change \
                "API" \
                "ERROR" \
                "$API_URL" \
                "No fue posible conectar con la API."

        fi

        return 2

    fi

    http_code=$(echo "$response" | cut -d';' -f1)

    time_ms=$(echo "$response" | cut -d';' -f2)

    # Convertir segundos a milisegundos
    time_ms=$(awk "BEGIN {printf \"%d\", $time_ms * 1000}")

    #########################################################
    # Guardar métrica para histórico
    #########################################################

    API_TIME="$time_ms"

    #########################################################
    # Código HTTP distinto de 200
    #########################################################

    if [ "$http_code" != "200" ]; then

        log_check \
            "API" \
            "ERROR" \
            "HTTP $http_code" \
            "${time_ms}ms"

        if state_changed "$STATE_KEY" "ERROR"; then

            report_change \
                "API" \
                "ERROR" \
                "$API_URL" \
                "La API respondió con HTTP ${http_code}."

        fi

        return 2

    fi

    #########################################################
    # Respuesta lenta
    #########################################################

    if [ "$time_ms" -ge "$API_WARNING_MS" ]; then

        log_check \
            "API" \
            "WARNING" \
            "Respuesta lenta" \
            "${time_ms}ms"

        if state_changed "$STATE_KEY" "WARNING"; then

            report_change \
                "API" \
                "WARNING" \
                "$API_URL" \
                "Tiempo de respuesta: ${time_ms} ms."

        fi

        return 1

    fi

    #########################################################
    # OK
    #########################################################

    log_check \
        "API" \
        "OK" \
        "Disponible" \
        "${time_ms}ms"

    if state_changed "$STATE_KEY" "OK"; then

        report_change \
            "API" \
            "OK" \
            "$API_URL" \
            "Disponible (${time_ms} ms)."

    fi

    return 0

}

# ==========================================================
# Ejecución directa
# ==========================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    check_api
    exit $?

fi