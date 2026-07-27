#!/bin/bash
# ==========================================================
# ERP Monitor - SSL Check
# Archivo: checks/ssl.sh
# Descripción:
#   Verifica certificados SSL y detecta cambios de estado.
# ==========================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/config/config.sh"
source "$ROOT_DIR/lib/logger.sh"
source "$ROOT_DIR/lib/state.sh"
source "$ROOT_DIR/lib/report.sh"

check_ssl() {

    log_info "Verificando certificados SSL..."

    local global_status=0

    for DOMAIN in "${SSL_DOMAINS[@]}"; do

        local start_time
        local end_time
        local elapsed

        start_time=$(date +%s%3N)

        local end_date

        end_date=$(
            echo |
            openssl s_client \
                -servername "$DOMAIN" \
                -connect "${DOMAIN}:443" 2>/dev/null |
            openssl x509 -noout -enddate 2>/dev/null |
            cut -d= -f2
        )

        end_time=$(date +%s%3N)
        elapsed=$((end_time-start_time))

        local STATE_KEY="SSL_${DOMAIN}"

        ####################################################
        # No se pudo obtener certificado
        ####################################################

        if [ -z "$end_date" ]; then

            log_check \
                "SSL" \
                "ERROR" \
                "$DOMAIN sin certificado" \
                "${elapsed}ms"

            if state_changed "$STATE_KEY" "NO_CERTIFICATE"; then

                report_change \
                    "SSL" \
                    "NO_CERTIFICATE" \
                    "$DOMAIN" \
                    "No responde o no presenta un certificado SSL."

            fi

            global_status=2
            continue

        fi

        ####################################################
        # Calcular días restantes
        ####################################################

        local expire_epoch
        local now_epoch
        local days_left

        expire_epoch=$(date -d "$end_date" +%s)
        now_epoch=$(date +%s)

        days_left=$(((expire_epoch-now_epoch)/86400))

        ####################################################
        # Certificado expirado
        ####################################################

        if [ "$days_left" -lt 0 ]; then

            log_check \
                "SSL" \
                "ERROR" \
                "$DOMAIN expirado" \
                "${elapsed}ms"

            if state_changed "$STATE_KEY" "EXPIRED"; then

                report_change \
                    "SSL" \
                    "EXPIRED" \
                    "$DOMAIN" \
                    "El certificado SSL está expirado."

            fi

            global_status=2
            continue

        fi

        ####################################################
        # Buscar umbral de alerta
        ####################################################

        local warning_level=""

        for ALERT in "${SSL_ALERT_DAYS[@]}"; do

            if [ "$days_left" -le "$ALERT" ]; then
                warning_level="$ALERT"
            fi

        done

        ####################################################
        # WARNING
        ####################################################

        if [ -n "$warning_level" ]; then

            local STATE="WARNING_${warning_level}"

            log_check \
                "SSL" \
                "WARNING" \
                "$DOMAIN expira en ${days_left} días" \
                "${elapsed}ms"

            if state_changed "$STATE_KEY" "$STATE"; then

                report_change \
                    "SSL" \
                    "$STATE" \
                    "$DOMAIN" \
                    "El certificado expira en ${days_left} días."

            fi

            if [ "$global_status" -lt 1 ]; then
                global_status=1
            fi

            continue

        fi

        ####################################################
        # OK
        ####################################################

        log_check \
            "SSL" \
            "OK" \
            "$DOMAIN (${days_left} días restantes)" \
            "${elapsed}ms"

        if state_changed "$STATE_KEY" "OK"; then

            report_change \
                "SSL" \
                "OK" \
                "$DOMAIN" \
                "Certificado válido (${days_left} días restantes)."

        fi

    done

    return "$global_status"

}

# ==========================================================
# Ejecución directa
# ==========================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    check_ssl
    exit $?

fi