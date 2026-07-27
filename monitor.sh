#!/bin/bash

# ==========================================================
# ERP Monitor V1
# Archivo: monitor.sh
# Descripción:
# Ejecuta todos los checks y envía un resumen por Telegram.
# ==========================================================

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ==========================================================
# Cargar configuración
# ==========================================================

source "$ROOT_DIR/config/config.sh"

# Librerías
source "$ROOT_DIR/lib/logger.sh"
source "$ROOT_DIR/lib/telegram.sh"

# Checks
source "$ROOT_DIR/checks/cpu.sh"
source "$ROOT_DIR/checks/ram.sh"
source "$ROOT_DIR/checks/disk.sh"
source "$ROOT_DIR/checks/api.sh"
source "$ROOT_DIR/checks/login.sh"
source "$ROOT_DIR/checks/postgres.sh"

# ==========================================================
# Inicio
# ==========================================================

log_info "==============================================="
log_info "Iniciando ERP Monitor"
log_info "Modo: $MONITOR_MODE"
log_info "==============================================="

MESSAGE="<b>📊 ERP Monitor</b>

"

# ==========================================================
# Función para ejecutar un check
# ==========================================================

run_check() {

    local NAME="$1"
    local FUNCTION="$2"

    $FUNCTION
    local RESULT=$?

    case $RESULT in

        0)
            ICON="🟢"
            STATUS="OK"
            ;;

        1)
            ICON="🟡"
            STATUS="WARNING"
            ;;

        2)
            ICON="🔴"
            STATUS="CRITICAL"
            ;;

        *)
            ICON="⚫"
            STATUS="UNKNOWN"
            ;;

    esac

    printf -v LINE "%-12s %s" "$NAME" "$STATUS"

    MESSAGE+="${ICON} <code>${LINE}</code>"$'\n'
}

# ==========================================================
# Ejecutar checks
# ==========================================================

run_check "CPU" check_cpu
run_check "RAM" check_ram
run_check "DISK" check_disk
run_check "API" check_api
run_check "LOGIN" check_login
run_check "POSTGRES" check_postgres

# ==========================================================
# Pie del mensaje
# ==========================================================

MESSAGE+=$'\n'
MESSAGE+="<b>Modo:</b> ${MONITOR_MODE}"$'\n'
MESSAGE+="<b>Servidor:</b> $(hostname)"$'\n'
MESSAGE+="<b>Fecha:</b> $(date '+%d/%m/%Y %H:%M:%S')"

# ==========================================================
# Consola
# ==========================================================

echo
echo "==============================================="
echo "$MESSAGE"
echo "==============================================="
echo

# ==========================================================
# Telegram
# ==========================================================

if [[ "$MONITOR_MODE" == "development" ]]; then

    send_telegram "$MESSAGE"

else

    # En producción luego aquí irá la lógica
    # para enviar únicamente cambios de estado.
    send_telegram "$MESSAGE"

fi

log_success "Monitor finalizado."

exit 0