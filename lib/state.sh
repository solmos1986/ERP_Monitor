#!/bin/bash
# ==========================================================
# ERP Monitor - State Manager
# Archivo: lib/state.sh
# Descripción:
#   Maneja estados persistentes de los checks.
# ==========================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

STATE_DIR="$ROOT_DIR/state"

mkdir -p "$STATE_DIR"

# ==========================================================
# Obtiene el archivo de estado
# ==========================================================
state_file() {
    local key="$1"

    # reemplazar caracteres inválidos
    key=$(echo "$key" | tr '/:' '__')

    echo "$STATE_DIR/${key}.state"
}

# ==========================================================
# Leer estado
#
# Uso:
# get_state "ssl_api"
# ==========================================================
get_state() {

    local file
    file=$(state_file "$1")

    if [ -f "$file" ]; then
        cat "$file"
    fi
}

# ==========================================================
# Guardar estado
#
# Uso:
# set_state "ssl_api" "30"
# ==========================================================
set_state() {

    local file
    file=$(state_file "$1")

    echo "$2" > "$file"
}

# ==========================================================
# Eliminar estado
#
# Uso:
# clear_state "ssl_api"
# ==========================================================
clear_state() {

    local file
    file=$(state_file "$1")

    rm -f "$file"
}

# ==========================================================
# Verifica si cambió el estado
#
# Retorna:
#   0 = cambió (y guarda automáticamente)
#   1 = sin cambios
#
# Uso:
#
# if state_changed "ssl_api" "30"; then
#     # enviar telegram
# fi
# ==========================================================
state_changed() {

    local key="$1"
    local new_state="$2"

    local old_state
    old_state=$(get_state "$key")

    if [ "$old_state" != "$new_state" ]; then
        set_state "$key" "$new_state"
        return 0
    fi

    return 1
}