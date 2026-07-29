#!/bin/bash
# ==========================================================
# ERP Monitor - Charts Library
# Archivo: lib/charts.sh
#
# Descripción:
#   Generación de gráficos PNG utilizando gnuplot.
#
# Responsabilidades:
#   - Verificar gnuplot
#   - Inicializar carpeta charts
#   - Generar gráfico CPU + RAM
#
# NO envía Telegram.
# NO modifica history.
# NO modifica estadísticas.
# ==========================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/config/config.sh"

# Utilizar la zona horaria configurada por el monitor
export TZ="$TIMEZONE"

source "$ROOT_DIR/lib/history.sh"

# ==========================================================
# Variables
# ==========================================================

CHARTS_DIR="${BASE_DIR}/charts"
CHART_HISTORY_FILE=""

# ==========================================================
# Inicializar módulo
# ==========================================================

charts_init() {

    local report_date="$1"

    mkdir -p "$CHARTS_DIR"

    CHART_HISTORY_FILE="${HISTORY_DIR}/${report_date}.csv"

    if [ ! -f "$CHART_HISTORY_FILE" ]; then
        echo "No existe el histórico: $CHART_HISTORY_FILE" >&2
        return 1
    fi

    if ! command -v gnuplot >/dev/null 2>&1; then
        echo "gnuplot no está instalado." >&2
        return 1
    fi

    return 0
}

# ==========================================================
# Obtener índice de una columna
# ==========================================================

chart_column_index() {

    local column="$1"

    head -n1 "$CHART_HISTORY_FILE" \
        | tr ',' '\n' \
        | nl -v0 \
        | awk -v c="$column" '$2==c {print $1}'
}

# ==========================================================
# CPU + RAM
# ==========================================================

generate_system_chart() {

    local report_date="$1"

    charts_init "$report_date" || return 1

    local cpu_index
    local ram_index

    cpu_index=$(chart_column_index "cpu")
    ram_index=$(chart_column_index "ram")

    if [ -z "$cpu_index" ] || [ -z "$ram_index" ]; then
        echo "No se encontraron las columnas CPU o RAM." >&2
        return 1
    fi

    gnuplot <<EOF

set terminal pngcairo enhanced size 1100,420 font "Arial,11"

set output "${CHARTS_DIR}/system_metrics.png"

set datafile separator ","

set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set format x "%H:%M"

set title "Uso de Recursos del Sistema" font ",14"

set xlabel "Hora"
set ylabel "Porcentaje (%)"

set grid xtics ytics lc rgb "#DDDDDD"

set border linewidth 1.2

set tics out

set key top left

set lmargin 10
set rmargin 5
set tmargin 2
set bmargin 4

set yrange [0:100]

plot \
"${CHART_HISTORY_FILE}" using 1:$((cpu_index+1)) \
title "CPU" \
with lines lw 2 lc rgb "#E53935", \
"${CHART_HISTORY_FILE}" using 1:$((ram_index+1)) \
title "RAM" \
with lines lw 2 lc rgb "#1E88E5"

EOF
}

# ==========================================================
# Generar todos los gráficos
# ==========================================================

generate_all_charts() {

    local report_date="${1:-$(date +%F)}"

    generate_system_chart "$report_date" || return 1

    return 0
}