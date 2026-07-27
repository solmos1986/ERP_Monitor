#!/bin/bash
# ==========================================================
# ERP Monitor - CPU Check
# Archivo: checks/cpu.sh
# Descripción:
#   Verifica el porcentaje de uso de CPU.
# ==========================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/config/config.sh"
source "$ROOT_DIR/lib/logger.sh"

# ==========================================================
# Ejecutar Check
# ==========================================================

check_cpu() {

    log_info "Verificando CPU..."

    local idle
    local usage
    local status
    local message
    local code

    # ======================================================
    # Obtener porcentaje de CPU utilizada
    # ======================================================

    idle=$(top -bn1 | awk '/Cpu\(s\)/ {print $8}')
    usage=$(awk "BEGIN {printf \"%.0f\", 100 - $idle}")

    # ======================================================
    # Evaluar estado
    # ======================================================

    if [ "$usage" -ge "$CPU_CRITICAL" ]; then
        status="CRITICAL"
        code=2

    elif [ "$usage" -ge "$CPU_DANGER" ]; then
        status="DANGER"
        code=1

    elif [ "$usage" -ge "$CPU_WARNING" ]; then
        status="WARNING"
        code=1

    else
        status="OK"
        code=0
    fi

    message="Uso CPU ${usage}%"

    log_check "CPU" "$status" "$message" ""

    return $code
}

# ==========================================================
# Ejecución directa
# ==========================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_cpu
    exit $?
fi