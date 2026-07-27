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

# ==========================================================
# Ejecutar Check
# ==========================================================

check_postgres() {

    log_info "Verificando PostgreSQL..."

    local start_time
    local end_time
    local elapsed
    local result

    # ======================================================
    # Docker disponible
    # ======================================================

    if ! command -v docker >/dev/null 2>&1; then
        log_check "POSTGRES" "ERROR" "Docker no disponible" ""
        return 2
    fi

    # ======================================================
    # Contenedor en ejecución
    # ======================================================

    if ! docker inspect "$POSTGRES_CONTAINER" >/dev/null 2>&1; then
        log_check "POSTGRES" "ERROR" "Contenedor inexistente" ""
        return 2
    fi

    local running

    running=$(docker inspect \
        -f '{{.State.Running}}' \
        "$POSTGRES_CONTAINER" 2>/dev/null)

    if [ "$running" != "true" ]; then
        log_check "POSTGRES" "ERROR" "Contenedor detenido" ""
        return 2
    fi

    # ======================================================
    # Medir tiempo de respuesta
    # ======================================================

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

    # ======================================================
    # Error de conexión
    # ======================================================

    if [ $exit_code -ne 0 ]; then
        log_check "POSTGRES" "ERROR" "No responde" "${elapsed}ms"
        return 2
    fi

    # ======================================================
    # Validar consulta
    # ======================================================

    if [ "$result" != "1" ]; then
        log_check "POSTGRES" "ERROR" "Respuesta inválida" "${elapsed}ms"
        return 2
    fi

    # ======================================================
    # Tiempo de respuesta
    # ======================================================

    if [ "$elapsed" -ge "$POSTGRES_RESPONSE_DANGER" ]; then
        log_check "POSTGRES" "ERROR" "Respuesta muy lenta" "${elapsed}ms"
        return 2
    fi

    if [ "$elapsed" -ge "$POSTGRES_RESPONSE_WARNING" ]; then
        log_check "POSTGRES" "WARNING" "Respuesta lenta" "${elapsed}ms"
        return 1
    fi

    # ======================================================
    # Todo correcto
    # ======================================================

    log_check "POSTGRES" "OK" "Base de datos operativa" "${elapsed}ms"

    return 0
}

# ==========================================================
# Ejecución directa
# ==========================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_postgres
    exit $?
fi