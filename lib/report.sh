#!/bin/bash
# ==========================================================
# ERP Monitor - Report Manager
# Archivo: lib/report.sh
# Descripción:
#   Construye el reporte de cambios detectados por los checks.
# ==========================================================

REPORT=""

# ==========================================================
# Icono según estado
# ==========================================================
report_icon() {

    case "$1" in
        OK)
            echo "🟢"
            ;;
        WARNING*)
            echo "🟡"
            ;;
        ERROR|CRITICAL|EXPIRED|NO_CERTIFICATE)
            echo "🔴"
            ;;
        *)
            echo "⚪"
            ;;
    esac

}

# ==========================================================
# Estado visible
#
# Convierte estados internos a estados visibles.
# ==========================================================
report_status() {

    case "$1" in

        WARNING*)
            echo "WARNING"
            ;;

        EXPIRED|NO_CERTIFICATE|CRITICAL)
            echo "ERROR"
            ;;

        *)
            echo "$1"
            ;;

    esac

}

# ==========================================================
# Encabezado del reporte
# ==========================================================
report_header() {

    printf "<b>🚨 ERP Monitor - Cambios Detectados</b>\n"
    printf "Fecha: %s\n\n" "$(date '+%Y-%m-%d %H:%M:%S')"

}

# ==========================================================
# Agregar un evento al reporte
#
# Uso:
#
# report_change \
#     "SSL" \
#     "WARNING_30" \
#     "apigymcloud.aplus-security.com" \
#     "El certificado expira en 29 días."
# ==========================================================
report_change() {

    local service="$1"
    local status="$2"
    local resource="$3"
    local detail="$4"

    local icon
    local visible_status

    icon=$(report_icon "$status")
    visible_status=$(report_status "$status")

    REPORT+="${icon} <b>${service}</b>\n"
    REPORT+="Recurso : ${resource}\n"
    REPORT+="Estado  : ${visible_status}\n"
    REPORT+="Detalle : ${detail}\n\n"

}

# ==========================================================
# ¿Hay cambios?
#
# Return:
#   0 = Sí
#   1 = No
# ==========================================================
has_changes() {

    [ -n "$REPORT" ]

}

# ==========================================================
# Obtener reporte completo
# ==========================================================
get_report() {

    if [ -z "$REPORT" ]; then
        return
    fi

    report_header

    printf "%b" "$REPORT"

}

# ==========================================================
# Limpiar reporte
# ==========================================================
clear_report() {

    REPORT=""

}