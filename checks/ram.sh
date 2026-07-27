#!/bin/bash
# ==========================================================
# ERP Monitor - RAM Check
# Archivo: checks/ram.sh
# Descripción:
#   Verifica el porcentaje de uso de memoria RAM.
# ==========================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/config/config.sh"
source "$ROOT_DIR/lib/logger.sh"

# ==========================================================
# Ejecutar Check
# ==========================================================

check_ram() {

    log_info "Verificando RAM..."

    local usage
    local status
    local message
    local code

    # ======================================================
    # Obtener porcentaje de RAM utilizada
    # ======================================================

    usage=$(free | awk '/Mem:/ {printf "%.0f", ($3/$2)*100}')

    # ======================================================
    # Evaluar estado
    # ======================================================

    if [ "$usage" -ge "$RAM_CRITICAL" ]; then
        status="CRITICAL"
        code=2

    elif [ "$usage" -ge "$RAM_DANGER" ]; then
        status="DANGER"
        code=1

    elif [ "$usage" -ge "$RAM_WARNING" ]; then
        status="WARNING"
        code=1

    else
        status="OK"
        code=0
    fi

    message="Uso RAM ${usage}%"

    log_check "RAM" "$status" "$message" ""

    return $code
}

# ==========================================================
# Ejecución directa
# ==========================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_ram
    exit $?
fi