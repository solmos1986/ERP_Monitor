#!/bin/bash
# ==========================================================
# ERP Monitor - Login Check
# Archivo: checks/login.sh
# Descripción:
#   Verifica que el ERP permita autenticarse correctamente.
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

check_login() {

    log_info "Verificando Login..."

    local response
    local body
    local http_code
    local time_ms
    local token
    local curl_exit

    local STATE_KEY="LOGIN"

    response=$(curl \
        --silent \
        --show-error \
        --connect-timeout "$LOGIN_TIMEOUT" \
        --max-time "$LOGIN_TIMEOUT" \
        --header "Content-Type: application/json" \
        --request POST \
        --data "{\"email\":\"$LOGIN_USER\",\"password\":\"$LOGIN_PASSWORD\"}" \
        --write-out "HTTPSTATUS:%{http_code};TIME:%{time_total}" \
        "$API_URL/auth/login")

    curl_exit=$?

    #########################################################
    # Error de conexión
    #########################################################

    if [ $curl_exit -ne 0 ]; then

        LOGIN_TIME=0

        log_check \
            "LOGIN" \
            "ERROR" \
            "No fue posible conectar" \
            ""

        if state_changed "$STATE_KEY" "ERROR"; then

            report_change \
                "LOGIN" \
                "ERROR" \
                "$API_URL/auth/login" \
                "No fue posible conectar con el servicio de autenticación."

        fi

        return 2

    fi

    body=$(echo "$response" | sed 's/HTTPSTATUS:.*//')

    http_code=$(echo "$response" | sed -n 's/.*HTTPSTATUS:\([0-9]*\);TIME:.*/\1/p')

    time_ms=$(echo "$response" | sed -n 's/.*TIME:\(.*\)$/\1/p')

    # Convertir segundos a milisegundos
    time_ms=$(awk "BEGIN {printf \"%d\", $time_ms * 1000}")

    #########################################################
    # Guardar métrica para histórico
    #########################################################

    LOGIN_TIME="$time_ms"

    #########################################################
    # Código HTTP
    #########################################################

    if [ "$http_code" != "200" ]; then

        log_check \
            "LOGIN" \
            "ERROR" \
            "HTTP $http_code" \
            "${time_ms}ms"

        if state_changed "$STATE_KEY" "ERROR"; then

            report_change \
                "LOGIN" \
                "ERROR" \
                "$API_URL/auth/login" \
                "El servicio respondió con HTTP ${http_code}."

        fi

        return 2

    fi

    #########################################################
    # Validar Token
    #########################################################

    token=$(echo "$body" | jq -r '.token // empty')

    if [ -z "$token" ]; then

        log_check \
            "LOGIN" \
            "ERROR" \
            "Token no recibido" \
            "${time_ms}ms"

        if state_changed "$STATE_KEY" "ERROR"; then

            report_change \
                "LOGIN" \
                "ERROR" \
                "$API_URL/auth/login" \
                "La autenticación no devolvió un token."

        fi

        return 2

    fi

    #########################################################
    # Tiempo de respuesta
    #########################################################

    if [ "$time_ms" -ge "$LOGIN_WARNING_MS" ]; then

        log_check \
            "LOGIN" \
            "WARNING" \
            "Login correcto pero lento" \
            "${time_ms}ms"

        if state_changed "$STATE_KEY" "WARNING"; then

            report_change \
                "LOGIN" \
                "WARNING" \
                "$API_URL/auth/login" \
                "Autenticación correcta (${time_ms} ms)."

        fi

        return 1

    fi

    #########################################################
    # OK
    #########################################################

    log_check \
        "LOGIN" \
        "OK" \
        "Autenticación correcta" \
        "${time_ms}ms"

    if state_changed "$STATE_KEY" "OK"; then

        report_change \
            "LOGIN" \
            "OK" \
            "$API_URL/auth/login" \
            "Autenticación correcta (${time_ms} ms)."

    fi

    return 0

}

# ==========================================================
# Ejecución directa
# ==========================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    check_login
    exit $?

fi