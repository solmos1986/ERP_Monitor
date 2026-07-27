#!/bin/bash
# ==========================================================
# ERP Monitor - Statistics Library
# Archivo: lib/statistics.sh
# Descripción:
#   Funciones para calcular estadísticas a partir del
#   histórico generado por history.sh.
#
# Responsabilidades:
#   - Cargar CSV
#   - Promedios
#   - Máximos
#   - Mínimos
#
# NO envía Telegram.
# NO genera gráficos.
# NO modifica archivos.
# ==========================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/config/config.sh"

# ==========================================================
# Variables
# ==========================================================

STATISTICS_FILE=""

# ==========================================================
# Cargar archivo histórico
# ==========================================================

statistics_load() {

    local file="$1"

    if [ -z "$file" ]; then

        file="$HISTORY_DIR/$(date +%F).csv"

    fi

    if [ ! -f "$file" ]; then

        echo "Archivo histórico no encontrado: $file" >&2
        return 1

    fi

    STATISTICS_FILE="$file"

    return 0

}

# ==========================================================
# Obtener índice de una columna
# ==========================================================

column_index() {

    local column="$1"

    head -n1 "$STATISTICS_FILE" \
        | tr ',' '\n' \
        | nl -v0 \
        | awk -v c="$column" '$2==c {print $1}'

}

# ==========================================================
# Promedio de una columna
# ==========================================================

average_column() {

    local column="$1"

    local index

    index=$(column_index "$column")

    if [ -z "$index" ]; then
        echo 0
        return
    fi

    awk -F',' -v col="$((index+1))" '
        NR>1 {

            if ($col != "") {

                sum += $col
                count++

            }

        }

        END {

            if (count == 0)
                print 0
            else
                printf "%.2f", sum / count

        }

    ' "$STATISTICS_FILE"

}

# ==========================================================
# Valor máximo de una columna
# ==========================================================

max_column() {

    local column="$1"

    local index

    index=$(column_index "$column")

    if [ -z "$index" ]; then
        echo 0
        return
    fi

    awk -F',' -v col="$((index+1))" '

        NR==2 {

            max=$col

        }

        NR>2 {

            if ($col > max)
                max=$col

        }

        END {

            print max

        }

    ' "$STATISTICS_FILE"

}

# ==========================================================
# Valor mínimo de una columna
# ==========================================================

min_column() {

    local column="$1"

    local index

    index=$(column_index "$column")

    if [ -z "$index" ]; then
        echo 0
        return
    fi

    awk -F',' -v col="$((index+1))" '

        NR==2 {

            min=$col

        }

        NR>2 {

            if ($col < min)
                min=$col

        }

        END {

            print min

        }

    ' "$STATISTICS_FILE"

}
# ==========================================================
# CPU
# ==========================================================

get_cpu_average() {
    average_column "cpu"
}

get_cpu_max() {
    max_column "cpu"
}

get_cpu_min() {
    min_column "cpu"
}

# ==========================================================
# RAM
# ==========================================================

get_ram_average() {
    average_column "ram"
}

get_ram_max() {
    max_column "ram"
}

get_ram_min() {
    min_column "ram"
}

# ==========================================================
# DISK
# ==========================================================

get_disk_average() {
    average_column "disk"
}

get_disk_max() {
    max_column "disk"
}

get_disk_min() {
    min_column "disk"
}

# ==========================================================
# API
# ==========================================================

get_api_average() {
    average_column "api_ms"
}

get_api_max() {
    max_column "api_ms"
}

get_api_min() {
    min_column "api_ms"
}

# ==========================================================
# LOGIN
# ==========================================================

get_login_average() {
    average_column "login_ms"
}

get_login_max() {
    max_column "login_ms"
}

get_login_min() {
    min_column "login_ms"
}

# ==========================================================
# POSTGRES
# ==========================================================

get_postgres_average() {
    average_column "postgres_ms"
}

get_postgres_max() {
    max_column "postgres_ms"
}

get_postgres_min() {
    min_column "postgres_ms"
}

# ==========================================================
# SSL
# ==========================================================

get_ssl_average() {
    average_column "ssl_days"
}

get_ssl_max() {
    max_column "ssl_days"
}

get_ssl_min() {
    min_column "ssl_days"
}


# ==========================================================
# Pruebas
# ==========================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    statistics_load "$1" || exit 1

    echo "======================================"
    echo "ERP Monitor - Statistics"
    echo "======================================"

    echo "CPU      Avg: $(get_cpu_average)%  Max: $(get_cpu_max)%  Min: $(get_cpu_min)%"
    echo "RAM      Avg: $(get_ram_average)%  Max: $(get_ram_max)%  Min: $(get_ram_min)%"
    DISK_CURRENT=$(tail -n1 "$STATISTICS_FILE" | cut -d',' -f4)
    echo "DISK     Current: ${DISK_CURRENT}%"
    echo "API      Avg: $(get_api_average) ms  Max: $(get_api_max) ms  Min: $(get_api_min) ms"
    echo "LOGIN    Avg: $(get_login_average) ms  Max: $(get_login_max) ms  Min: $(get_login_min) ms"
    echo "POSTGRES Avg: $(get_postgres_average) ms  Max: $(get_postgres_max) ms  Min: $(get_postgres_min) ms"
    echo "SSL      Avg: $(get_ssl_average) días  Max: $(get_ssl_max) días  Min: $(get_ssl_min) días"

fi