#!/bin/bash

# ==========================================================
# ERP Monitor V1
# Telegram Service
# ==========================================================

# Obtener directorio del script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Cargar configuración
source "$SCRIPT_DIR/../config/config.sh"
source "$SCRIPT_DIR/logger.sh"

# ==========================================================
# Enviar mensaje a Telegram
#
# Uso:
# send_telegram "Mensaje"
# ==========================================================

send_telegram() {

    local MESSAGE="$1"

    # Validar configuración
    if [[ -z "$TELEGRAM_BOT_TOKEN" ]]; then
        log_error "TELEGRAM_BOT_TOKEN no configurado."
        return 1
    fi

    if [[ -z "$TELEGRAM_CHAT_ID" ]]; then
        log_error "TELEGRAM_CHAT_ID no configurado."
        return 1
    fi

    # Enviar mensaje
    local RESPONSE

    RESPONSE=$(curl --silent \
        --show-error \
        --connect-timeout 10 \
        --max-time 20 \
        --request POST \
        "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        --data-urlencode "chat_id=${TELEGRAM_CHAT_ID}" \
        --data-urlencode "text=${MESSAGE}" \
        --data-urlencode "parse_mode=HTML")

    # Verificar respuesta
    if echo "$RESPONSE" | grep -q '"ok":true'; then
        return 0
    fi

    log_error "No se pudo enviar el mensaje a Telegram."
    log_error "$RESPONSE"

    return 1
}

# ==========================================================
# Permite ejecutar el script directamente para pruebas
#
# ./telegram.sh "Hola"
# ==========================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    if [[ $# -eq 0 ]]; then
        echo "Uso:"
        echo "./telegram.sh \"Mensaje\""
        exit 1
    fi

    send_telegram "$1"

    if [[ $? -eq 0 ]]; then
        echo "✅ Mensaje enviado correctamente."
    else
        echo "❌ Error enviando mensaje."
        exit 1
    fi

fi