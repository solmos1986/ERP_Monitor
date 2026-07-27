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
source "$ROOT_DIR/lib/state.sh"
source "$ROOT_DIR/lib/report.sh"

# ==========================================================
# Ejecutar Check
# ==========================================================

check_ram() {

    log_info "Verificando RAM..."

    local usage
    local status
    local code

    local STATE_KEY="RAM"

    #########################################################
    # Obtener porcentaje de RAM utilizada
    #########################################################

    usage=$(free | awk '/Mem:/ {printf "%.0f", ($3/$2)*100}')

    #########################################################
    # Guardar métrica para histórico
    #########################################################

    RAM_VALUE="$usage"

    #########################################################
    # Evaluar estado
    #########################################################

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

    #########################################################
    # Registrar log
    #########################################################

    log_check \
        "RAM" \
        "$status" \
        "Uso RAM ${usage}%" \
        ""

    #########################################################
    # Reportar cambios
    #########################################################

    if state_changed "$STATE_KEY" "$status"; then

        report_change \
            "RAM" \
            "$status" \
            "Servidor" \
            "Uso actual de RAM: ${usage}%."

    fi

    return $code

}

# ==========================================================
# Ejecución directa
# ==========================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    check_ram
    exit $?

fi