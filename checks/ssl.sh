#!/bin/bash
# ==========================================================
# ERP Monitor - SSL Check
# Archivo: checks/ssl.sh
# Descripción:
#   Verifica el estado de los certificados SSL.
# ==========================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/config/config.sh"
source "$ROOT_DIR/lib/logger.sh"

check_ssl() {

    log_info "Verificando certificados SSL..."

    local status=0

    for DOMAIN in "${SSL_DOMAINS[@]}"; do

        local start_time
        local end_time
        local elapsed

        start_time=$(date +%s%3N)

        local end_date

        end_date=$(echo | \
            openssl s_client \
                -servername "$DOMAIN" \
                -connect "${DOMAIN}:443" 2>/dev/null |
            openssl x509 -noout -enddate 2>/dev/null |
            cut -d= -f2)

        end_time=$(date +%s%3N)
        elapsed=$((end_time-start_time))

        if [ -z "$end_date" ]; then
            log_check "SSL" "ERROR" "$DOMAIN sin certificado" "${elapsed}ms"
            status=2
            continue
        fi

        local expire_epoch
        local now_epoch
        local days_left

        expire_epoch=$(date -d "$end_date" +%s)
        now_epoch=$(date +%s)

        days_left=$(( (expire_epoch-now_epoch)/86400 ))

        if [ "$days_left" -lt 0 ]; then
            log_check "SSL" "ERROR" "$DOMAIN expirado (${days_left} días)" "${elapsed}ms"
            status=2
            continue
        fi

        local warning=false

        for ALERT in "${SSL_ALERT_DAYS[@]}"; do

            if [ "$days_left" -le "$ALERT" ]; then
                warning=true
                break
            fi

        done

        if $warning; then

            log_check \
                "SSL" \
                "WARNING" \
                "$DOMAIN expira en ${days_left} días" \
                "${elapsed}ms"

            if [ $status -lt 1 ]; then
                status=1
            fi

        else

            log_check \
                "SSL" \
                "OK" \
                "$DOMAIN (${days_left} días restantes)" \
                "${elapsed}ms"

        fi

    done

    return $status
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_ssl
    exit $?
fi