#!/bin/bash
# ==========================================================
# ERP Monitor - Reporte Diario
# ==========================================================

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$BASE_DIR/config/config.sh"

# Utilizar la zona horaria configurada
export TZ="$TIMEZONE"

source "$BASE_DIR/lib/logger.sh"
source "$BASE_DIR/lib/history.sh"
source "$BASE_DIR/lib/statistics.sh"
source "$BASE_DIR/lib/charts.sh"
source "$BASE_DIR/lib/telegram.sh"

# ==========================================================
# Fecha del reporte
# ==========================================================

REPORT_DATE=$(date +%F)

# ==========================================================
# Inicializar
# ==========================================================

history_init
statistics_load
generate_all_charts "$REPORT_DATE"

# ==========================================================
# Obtener estadísticas
# ==========================================================

CPU_AVG=$(get_cpu_average)
CPU_MAX=$(get_cpu_max)
CPU_MIN=$(get_cpu_min)

RAM_AVG=$(get_ram_average)
RAM_MAX=$(get_ram_max)
RAM_MIN=$(get_ram_min)

API_AVG=$(get_api_average)
API_MAX=$(get_api_max)
API_MIN=$(get_api_min)

LOGIN_AVG=$(get_login_average)
LOGIN_MAX=$(get_login_max)
LOGIN_MIN=$(get_login_min)

POSTGRES_AVG=$(get_postgres_average)
POSTGRES_MAX=$(get_postgres_max)
POSTGRES_MIN=$(get_postgres_min)

SSL_AVG=$(get_ssl_average)
SSL_MAX=$(get_ssl_max)
SSL_MIN=$(get_ssl_min)

# ==========================================================
# Uso actual del disco
# ==========================================================

DISK_CURRENT=$(tail -n1 "$HISTORY_FILE" | cut -d',' -f4)

# ==========================================================
# Contar eventos del día
# ==========================================================

TODAY="$REPORT_DATE"

EVENTS=0
RECOVERIES=0

if [ -f "${LOG_DIR}/${TODAY}.log" ]; then

    EVENTS=$(grep -c "ERROR\|WARNING" "${LOG_DIR}/${TODAY}.log" 2>/dev/null || echo 0)
    RECOVERIES=$(grep -c "RECOVERY" "${LOG_DIR}/${TODAY}.log" 2>/dev/null || echo 0)

fi

# ==========================================================
# Construir mensaje
# ==========================================================

REPORT="📊 ERP Monitor - Reporte Diario

📅 $(date '+%d/%m/%Y')

━━━━━━━━━━━━━━━━━━

🖥 CPU
Promedio : ${CPU_AVG} %
Máximo   : ${CPU_MAX} %
Mínimo   : ${CPU_MIN} %

💾 RAM
Promedio : ${RAM_AVG} %
Máximo   : ${RAM_MAX} %
Mínimo   : ${RAM_MIN} %

💽 Disco
Uso actual : ${DISK_CURRENT} %

🌐 Backend
Promedio : ${API_AVG} ms
Máximo   : ${API_MAX} ms
Mínimo   : ${API_MIN} ms

🔐 Login
Promedio : ${LOGIN_AVG} ms
Máximo   : ${LOGIN_MAX} ms
Mínimo   : ${LOGIN_MIN} ms

🐘 PostgreSQL
Promedio : ${POSTGRES_AVG} ms
Máximo   : ${POSTGRES_MAX} ms
Mínimo   : ${POSTGRES_MIN} ms

🔒 SSL
Promedio : ${SSL_AVG} días
Máximo   : ${SSL_MAX} días
Mínimo   : ${SSL_MIN} días

━━━━━━━━━━━━━━━━━━

⚠ Eventos      : ${EVENTS}
✅ Recuperados : ${RECOVERIES}
"

# ==========================================================
# Enviar reporte
# ==========================================================

send_daily_report "$REPORT"

# ==========================================================
# Enviar gráfico
# ==========================================================

send_photo "${CHARTS_DIR}/system_metrics.png" "📊 Uso de CPU y Memoria RAM"

exit 0