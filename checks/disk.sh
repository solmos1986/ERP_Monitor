#!/bin/bash
# ==========================================================
# ERP Monitor - Disk Check
# Archivo: checks/disk.sh
# Descripción:
#   Verifica el porcentaje de uso del disco.
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

check_disk() {

    log_info "Verificando Disco..."

    local usage
    local status
    local code

    local STATE_KEY="DISK"

    #########################################################
    # Obtener porcentaje de uso del disco (/)
    #########################################################

    usage=$(df -P / | awk 'NR==2 {gsub("%","",$5); print $5}')

    #########################################################
    # Evaluar estado
    #########################################################

    if [ "$usage" -ge "$DISK_CRITICAL" ]; then

        status="CRITICAL"
        code=2

    elif [ "$usage" -ge "$DISK_DANGER" ]; then

        status="DANGER"
        code=1

    elif [ "$usage" -ge "$DISK_WARNING" ]; then

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
        "DISK" \
        "$status" \
        "Uso Disco ${usage}%" \
        ""

    #########################################################
    # Reportar cambios
    #########################################################

    if state_changed "$STATE_KEY" "$status"; then

        report_change \
            "DISK" \
            "$status" \
            "/" \
            "Uso actual del disco: ${usage}%."

    fi

    return $code

}

# ==========================================================
# Ejecución directa
# ==========================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    check_disk
    exit $?

fi