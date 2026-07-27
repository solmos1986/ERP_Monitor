#!/bin/bash
# ==========================================================
# ERP Monitor - Telegram
# Archivo: lib/telegram.sh
# Descripción:
#   Funciones para enviar mensajes mediante Telegram.
# ==========================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/config/config.sh"
source "$ROOT_DIR/lib/logger.sh"
source "$ROOT_DIR/lib/report.sh"

# ==========================================================
# Enviar mensaje
#
# Uso:
# send_message "<b>Hola Mundo</b>"
# ==========================================================
send_message() {

    local text="$1"

    if [ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ]; then
        log_warn "Telegram no configurado."
        return 1
    fi

    local response

    response=$(curl -s \
        --connect-timeout 10 \
        --max-time 30 \
        -X POST \
        "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d chat_id="$TELEGRAM_CHAT_ID" \
        -d parse_mode="HTML" \
        --data-urlencode text="$text")

    local curl_status=$?

    #########################################################
    # Error de conexión
    #########################################################

    if [ $curl_status -ne 0 ]; then

        log_error "No fue posible conectar con Telegram (curl=$curl_status)."

        return 1

    fi

    #########################################################
    # Validar respuesta JSON
    #########################################################

    if echo "$response" | grep -q '"ok":true'; then

        log_success "Mensaje enviado correctamente a Telegram."

        return 0

    fi

    #########################################################
    # Telegram respondió error
    #########################################################

    local description

    description=$(echo "$response" \
        | sed -n 's/.*"description":"\([^"]*\)".*/\1/p')

    if [ -z "$description" ]; then
        description="Respuesta desconocida."
    fi

    log_error "Telegram rechazó el mensaje: $description"

    return 1

}

# ==========================================================
# Enviar imagen
#
# Uso:
# send_photo "/tmp/cpu.png" "CPU"
# ==========================================================
send_photo() {

    local file="$1"
    local caption="$2"

    if [ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ]; then
        log_warn "Telegram no configurado."
        return 1
    fi

    if [ ! -f "$file" ]; then
        log_error "La imagen no existe: $file"
        return 1
    fi

    local response

    response=$(curl -s \
        --connect-timeout 10 \
        --max-time 60 \
        -X POST \
        "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendPhoto" \
        -F chat_id="$TELEGRAM_CHAT_ID" \
        -F photo=@"$file" \
        -F caption="$caption")

    local curl_status=$?

    #########################################################
    # Error de conexión
    #########################################################

    if [ $curl_status -ne 0 ]; then

        log_error "No fue posible enviar la imagen a Telegram (curl=$curl_status)."

        return 1

    fi

    #########################################################
    # Validar respuesta JSON
    #########################################################

    if echo "$response" | grep -q '"ok":true'; then

        log_success "Imagen enviada correctamente a Telegram."

        return 0

    fi

    #########################################################
    # Telegram respondió error
    #########################################################

    local description

    description=$(echo "$response" \
        | sed -n 's/.*"description":"\([^"]*\)".*/\1/p')

    if [ -z "$description" ]; then
        description="Respuesta desconocida."
    fi

    log_error "Telegram rechazó la imagen: $description"

    return 1

}

# ==========================================================
# Enviar reporte de cambios
# ==========================================================
send_change_report() {

    if ! has_changes; then
        return 0
    fi

    send_message "$(get_report)"

    local result=$?

    if [ $result -eq 0 ]; then
        clear_report
    fi

    return $result

}

# ==========================================================
# Enviar reporte diario
#
# (Preparado para futuras versiones)
# ==========================================================
send_daily_report() {

    local report="$1"

    send_message "$report"

}