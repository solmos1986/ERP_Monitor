#!/bin/bash
# ==========================================================
# ERP Monitor
# Archivo: monitor.sh
# Descripción:
#   Punto de entrada principal del monitor.
# ==========================================================

set -euo pipefail

# ==========================================================
# Directorio raíz
# ==========================================================

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ==========================================================
# Configuración
# ==========================================================

source "$ROOT_DIR/config/config.sh"

# ==========================================================
# Librerías
# ==========================================================

source "$ROOT_DIR/lib/logger.sh"
source "$ROOT_DIR/lib/state.sh"
source "$ROOT_DIR/lib/report.sh"
source "$ROOT_DIR/lib/telegram.sh"

# ==========================================================
# Checks
# ==========================================================

source "$ROOT_DIR/checks/cpu.sh"
source "$ROOT_DIR/checks/ram.sh"
source "$ROOT_DIR/checks/disk.sh"
source "$ROOT_DIR/checks/api.sh"
source "$ROOT_DIR/checks/login.sh"
source "$ROOT_DIR/checks/postgres.sh"
source "$ROOT_DIR/checks/ssl.sh"

# ==========================================================
# Estado general del monitor
# ==========================================================

MONITOR_STATUS=0

# ==========================================================
# Registro de checks
#
# Formato:
#   "Nombre|Función"
# ==========================================================

CHECKS=(

    "CPU|check_cpu"
    "RAM|check_ram"
    "DISK|check_disk"
    "API|check_api"
    "LOGIN|check_login"
    "POSTGRESQL|check_postgres"
    "SSL|check_ssl"

)

# ==========================================================
# Ejecutar un check
# ==========================================================

run_check() {

    local name="$1"
    local function="$2"
    local result

    log_info "Verificando ${name}..."

    # Ejecutar el check sin que set -e finalice el monitor
    set +e
    "$function"
    result=$?
    set -e

    case "$result" in

        0)
            ;;

        1)

            if [ "$MONITOR_STATUS" -lt 1 ]; then
                MONITOR_STATUS=1
            fi
            ;;

        2)

            MONITOR_STATUS=2
            ;;

        *)

            log_error "${name} devolvió código inesperado (${result})."
            MONITOR_STATUS=2
            ;;

    esac

}

# ==========================================================
# Inicio
# ==========================================================

clear_report

log_info "==============================================="
log_info "Iniciando ERP Monitor"
log_info "Ambiente : ${APP_ENV:-production}"
log_info "Fecha    : $(date '+%Y-%m-%d %H:%M:%S')"
log_info "==============================================="

# ==========================================================
# Ejecutar todos los checks registrados
# ==========================================================

for item in "${CHECKS[@]}"
do

    IFS="|" read -r name function <<< "$item"

    run_check "$name" "$function"

done

# ==========================================================
# Enviar reporte de cambios
# ==========================================================

send_change_report

# ==========================================================
# Resultado final
# ==========================================================

case "$MONITOR_STATUS" in

    0)
        log_success "ERP Monitor finalizado correctamente."
        ;;

    1)
        log_warn "ERP Monitor finalizado con advertencias."
        ;;

    2)
        log_error "ERP Monitor finalizado con errores."
        ;;

esac

exit "$MONITOR_STATUS"