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
#   - Generar gráficos desde el histórico
#
# NO envía Telegram.
# NO modifica history.
# NO modifica estadísticas.
# ==========================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/config/config.sh"
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

    mkdir -p "$CHARTS_DIR"

    CHART_HISTORY_FILE="${HISTORY_DIR}/$(date +%F).csv"

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
# Función genérica para generar gráficos
# ==========================================================

generate_chart() {

    local column="$1"
    local title="$2"
    local ylabel="$3"
    local output="$4"
    local color="$5"

    local index
    local yrange=""

    index=$(chart_column_index "$column")

    if [ -z "$index" ]; then
        echo "No existe la columna '$column'" >&2
        return 1
    fi

    # Rangos recomendados según el tipo de métrica
    case "$column" in
        cpu|ram|disk)
            yrange="set yrange [0:100]"
            ;;
        ssl_days)
            yrange="set yrange [0:*]"
            ;;
        *)
            yrange="set autoscale y"
            ;;
    esac

    gnuplot <<EOF

set terminal pngcairo enhanced size 1100,420 font "Arial,11"

set output "${CHARTS_DIR}/${output}"

set datafile separator ","

set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set format x "%H:%M"

set title "${title}" font ",14"

set xlabel "Hora"
set ylabel "${ylabel}"

set grid xtics ytics lc rgb "#DDDDDD"

set border linewidth 1.2

set tics out

set key off

set lmargin 10
set rmargin 5
set tmargin 2
set bmargin 4

set style line 1 \
    lc rgb "${color}" \
    lw 2.5 \
    pt 7 \
    ps 0.6

$yrange

plot "${CHART_HISTORY_FILE}" \
using 1:$((index+1)) \
with linespoints ls 1 \
pointtype 7 \
pointsize 0.6

EOF

}
# ==========================================================
# CPU
# ==========================================================

generate_cpu_chart() {

    charts_init || return 1

    generate_chart \
        "cpu" \
        "Uso de CPU" \
        "CPU (%)" \
        "cpu.png" \
        "#E53935"

}

# ==========================================================
# RAM
# ==========================================================

generate_ram_chart() {

    charts_init || return 1

    generate_chart \
        "ram" \
        "Uso de Memoria RAM" \
        "RAM (%)" \
        "ram.png" \
        "#1E88E5"

}

# ==========================================================
# Disco
# ==========================================================

generate_disk_chart() {

    charts_init || return 1

    generate_chart \
        "disk" \
        "Uso de Disco" \
        "Disco (%)" \
        "disk.png" \
        "#FB8C00"

}

# ==========================================================
# Generar gráficos básicos
# ==========================================================

generate_basic_charts() {

    generate_cpu_chart
    generate_ram_chart
    generate_disk_chart

}
# ==========================================================
# Backend API
# ==========================================================

generate_api_chart() {

    charts_init || return 1

    generate_chart \
        "api_ms" \
        "Tiempo de respuesta Backend" \
        "Milisegundos (ms)" \
        "api.png" \
        "#43A047"

}

# ==========================================================
# Login
# ==========================================================

generate_login_chart() {

    charts_init || return 1

    generate_chart \
        "login_ms" \
        "Tiempo de Login" \
        "Milisegundos (ms)" \
        "login.png" \
        "#8E24AA"

}

# ==========================================================
# PostgreSQL
# ==========================================================

generate_postgres_chart() {

    charts_init || return 1

    generate_chart \
        "postgres_ms" \
        "Tiempo de respuesta PostgreSQL" \
        "Milisegundos (ms)" \
        "postgres.png" \
        "#6D4C41"

}

# ==========================================================
# SSL
# ==========================================================

generate_ssl_chart() {

    charts_init || return 1

    generate_chart \
        "ssl_days" \
        "Días restantes del certificado SSL" \
        "Días" \
        "ssl.png" \
        "#00897B"

}

# ==========================================================
# Generar TODOS los gráficos
# ==========================================================

generate_all_charts() {

    charts_init || return 1

    generate_cpu_chart || return 1
    generate_ram_chart || return 1
    generate_disk_chart || return 1

    generate_api_chart || return 1
    generate_login_chart || return 1
    generate_postgres_chart || return 1

    generate_ssl_chart || return 1

    return 0

}