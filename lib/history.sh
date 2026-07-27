#!/bin/bash

# ============================================
# HISTÓRICO DE MÉTRICAS
# ============================================

HISTORY_DIR="${BASE_DIR}/history"

# ============================================
# Inicializar histórico
# ============================================
history_init() {

    mkdir -p "$HISTORY_DIR"

    HISTORY_FILE="${HISTORY_DIR}/$(date +%F).csv"

    if [ ! -f "$HISTORY_FILE" ]; then
        echo "timestamp,cpu,ram,disk,api_ms,login_ms,postgres_ms,ssl_days" > "$HISTORY_FILE"
    fi
}

# ============================================
# Guardar muestra
# ============================================
history_save() {

    history_init

    echo "$(date '+%F %T'),${CPU_VALUE:-0},${RAM_VALUE:-0},${DISK_VALUE:-0},${API_TIME:-0},${LOGIN_TIME:-0},${POSTGRES_TIME:-0},${SSL_DAYS:-0}" \
        >> "$HISTORY_FILE"
}