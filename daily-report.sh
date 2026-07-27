#!/bin/bash
# ==========================================================
# ERP Monitor - Reporte Diario
# ==========================================================

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$BASE_DIR/config/config.sh"

source "$BASE_DIR/lib/logger.sh"
source "$BASE_DIR/lib/history.sh"
source "$BASE_DIR/lib/statistics.sh"
source "$BASE_DIR/lib/charts.sh"
source "$BASE_DIR/lib/telegram.sh"

# ==========================================================
# Inicializar
# ==========================================================

history_init
statistics_load
generate_all_charts

# ==========================================================
# Obtener estadísticas
# ==========================================================

CPU_AVG=$(get_cpu_average)
CPU_MAX=$(get_cpu_max)
CPU_MIN=$(get_cpu_min)

RAM_AVG=$(get_ram_average)
RAM_MAX=$(get_ram_max)
RAM_MIN=$(get_ram_min)

DISK_AVG=$(get_disk_average)
DISK_MAX=$(get_disk_max)
DISK_MIN=$(get_disk_min)

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
# Contar eventos del día
# ==========================================================

TODAY=$(date +%F)

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
Promedio : ${DISK_AVG} %
Máximo   : ${DISK_MAX} %
Mínimo   : ${DISK_MIN} %

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
# Enviar gráficos
# ==========================================================

send_photo "${CHARTS_DIR}/cpu.png" "CPU"

send_photo "${CHARTS_DIR}/ram.png" "RAM"

send_photo "${CHARTS_DIR}/disk.png" "Disco"

send_photo "${CHARTS_DIR}/api.png" "Backend"

send_photo "${CHARTS_DIR}/login.png" "Login"

send_photo "${CHARTS_DIR}/postgres.png" "PostgreSQL"

send_photo "${CHARTS_DIR}/ssl.png" "SSL"

exit 0