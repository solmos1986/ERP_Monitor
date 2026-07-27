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
source "$ROOT_DIR/lib/state.sh"
source "$ROOT_DIR/lib/report.sh"

# ==========================================================
# Ejecutar Check
# ==========================================================

check_cpu() {

    log_info "Verificando CPU..."

    local idle
    local usage
    local status
    local code

    local STATE_KEY="CPU"

    #########################################################
    # Obtener porcentaje de CPU utilizada
    #########################################################

    idle=$(top -bn1 | awk '/Cpu\(s\)/ {print $8}')
    usage=$(awk "BEGIN {printf \"%.0f\", 100 - $idle}")

    #########################################################
    # Evaluar estado
    #########################################################

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

    #########################################################
    # Registrar log
    #########################################################

    log_check \
        "CPU" \
        "$status" \
        "Uso CPU ${usage}%" \
        ""

    #########################################################
    # Reportar cambios
    #########################################################

    if state_changed "$STATE_KEY" "$status"; then

        report_change \
            "CPU" \
            "$status" \
            "Servidor" \
            "Uso actual de CPU: ${usage}%."

    fi

    return $code

}

# ==========================================================
# Ejecución directa
# ==========================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    check_cpu
    exit $?

fi