#!/bin/bash
# ==========================================================
# ERP Monitor - PostgreSQL Check
# Archivo: checks/postgres.sh
# Descripción:
#   Verifica que PostgreSQL esté operativo y responda
#   correctamente.
# ==========================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

source "$ROOT_DIR/config/config.sh"
source "$ROOT_DIR/lib/logger.sh"
source "$ROOT_DIR/lib/state.sh"
source "$ROOT_DIR/lib/report.sh"

# ==========================================================
# Ejecutar Check
# ==========================================================

check_postgres() {

    log_info "Verificando PostgreSQL..."

    local start_time
    local end_time
    local elapsed
    local result

    local STATE_KEY="POSTGRES"

    #########################################################
    # Docker disponible
    #########################################################

    if ! command -v docker >/dev/null 2>&1; then

        log_check \
            "POSTGRES" \
            "ERROR" \
            "Docker no disponible" \
            ""

        if state_changed "$STATE_KEY" "ERROR"; then

            report_change \
                "POSTGRES" \
                "ERROR" \
                "$POSTGRES_CONTAINER" \
                "Docker no está disponible."

        fi

        return 2

    fi

    #########################################################
    # Contenedor existe
    #########################################################

    if ! docker inspect "$POSTGRES_CONTAINER" >/dev/null 2>&1; then

        log_check \
            "POSTGRES" \
            "ERROR" \
            "Contenedor inexistente" \
            ""

        if state_changed "$STATE_KEY" "ERROR"; then

            report_change \
                "POSTGRES" \
                "ERROR" \
                "$POSTGRES_CONTAINER" \
                "El contenedor no existe."

        fi

        return 2

    fi

    #########################################################
    # Contenedor en ejecución
    #########################################################

    local running

    running=$(docker inspect \
        -f '{{.State.Running}}' \
        "$POSTGRES_CONTAINER" 2>/dev/null)

    if [ "$running" != "true" ]; then

        log_check \
            "POSTGRES" \
            "ERROR" \
            "Contenedor detenido" \
            ""

        if state_changed "$STATE_KEY" "ERROR"; then

            report_change \
                "POSTGRES" \
                "ERROR" \
                "$POSTGRES_CONTAINER" \
                "El contenedor está detenido."

        fi

        return 2

    fi

    #########################################################
    # Medir tiempo de respuesta
    #########################################################

    start_time=$(date +%s%3N)

    result=$(docker exec \
        "$POSTGRES_CONTAINER" \
        psql \
        -U "$POSTGRES_USER" \
        -d "$POSTGRES_DATABASE" \
        -tAc "SELECT 1;" 2>/dev/null)

    local exit_code=$?

    end_time=$(date +%s%3N)

    elapsed=$((end_time - start_time))

    #########################################################
    # Error de conexión
    #########################################################

    if [ $exit_code -ne 0 ]; then

        log_check \
            "POSTGRES" \
            "ERROR" \
            "No responde" \
            "${elapsed}ms"

        if state_changed "$STATE_KEY" "ERROR"; then

            report_change \
                "POSTGRES" \
                "ERROR" \
                "$POSTGRES_CONTAINER" \
                "La base de datos no responde."

        fi

        return 2

    fi

    #########################################################
    # Validar consulta
    #########################################################

    if [ "$result" != "1" ]; then

        log_check \
            "POSTGRES" \
            "ERROR" \
            "Respuesta inválida" \
            "${elapsed}ms"

        if state_changed "$STATE_KEY" "ERROR"; then

            report_change \
                "POSTGRES" \
                "ERROR" \
                "$POSTGRES_CONTAINER" \
                "La consulta de verificación devolvió una respuesta inválida."

        fi

        return 2

    fi

    #########################################################
    # Tiempo de respuesta crítico
    #########################################################

    if [ "$elapsed" -ge "$POSTGRES_RESPONSE_DANGER" ]; then

        log_check \
            "POSTGRES" \
            "ERROR" \
            "Respuesta muy lenta" \
            "${elapsed}ms"

        if state_changed "$STATE_KEY" "ERROR"; then

            report_change \
                "POSTGRES" \
                "ERROR" \
                "$POSTGRES_CONTAINER" \
                "Tiempo de respuesta: ${elapsed} ms."

        fi

        return 2

    fi

    #########################################################
    # Tiempo de respuesta lento
    #########################################################

    if [ "$elapsed" -ge "$POSTGRES_RESPONSE_WARNING" ]; then

        log_check \
            "POSTGRES" \
            "WARNING" \
            "Respuesta lenta" \
            "${elapsed}ms"

        if state_changed "$STATE_KEY" "WARNING"; then

            report_change \
                "POSTGRES" \
                "WARNING" \
                "$POSTGRES_CONTAINER" \
                "Tiempo de respuesta: ${elapsed} ms."

        fi

        return 1

    fi

    #########################################################
    # OK
    #########################################################

    log_check \
        "POSTGRES" \
        "OK" \
        "Base de datos operativa" \
        "${elapsed}ms"

    if state_changed "$STATE_KEY" "OK"; then

        report_change \
            "POSTGRES" \
            "OK" \
            "$POSTGRES_CONTAINER" \
            "Base de datos operativa (${elapsed} ms)."

    fi

    return 0

}

# ==========================================================
# Ejecución directa
# ==========================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

    check_postgres
    exit $?

fi