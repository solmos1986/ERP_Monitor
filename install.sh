#!/bin/bash
# ==========================================================
# ERP Monitor - Instalador
# Archivo: install.sh
# Descripción:
#   Instala las dependencias necesarias para el monitor.
# ==========================================================

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=================================================="
echo " ERP Monitor - Instalación"
echo "=================================================="

# ==========================================================
# Verificar permisos
# ==========================================================

if [ "$EUID" -ne 0 ]; then
    echo "❌ Este script debe ejecutarse como root."
    echo ""
    echo "Ejemplo:"
    echo "sudo ./install.sh"
    exit 1
fi

# ==========================================================
# Actualizar repositorios
# ==========================================================

echo ""
echo "📦 Actualizando repositorios..."

apt-get update

# ==========================================================
# Instalar dependencias
# ==========================================================

echo ""
echo "📦 Instalando dependencias..."

apt-get install -y \
    curl \
    jq \
    bc

# ==========================================================
# Verificar instalación
# ==========================================================

echo ""
echo "🔍 Verificando dependencias..."

for cmd in curl jq bc; do

    if command -v "$cmd" >/dev/null 2>&1; then
        echo "   ✅ $cmd"
    else
        echo "   ❌ Error instalando $cmd"
        exit 1
    fi

done

# ==========================================================
# Crear directorios
# ==========================================================

echo ""
echo "📁 Verificando directorios..."

mkdir -p "$ROOT_DIR/logs"
mkdir -p "$ROOT_DIR/state"

# ==========================================================
# Permisos
# ==========================================================

echo ""
echo "🔑 Asignando permisos..."

find "$ROOT_DIR" -type f -name "*.sh" -exec chmod +x {} \;

# ==========================================================
# Finalización
# ==========================================================

echo ""
echo "=================================================="
echo "✅ Instalación completada correctamente."
echo "=================================================="
echo ""
echo "Puede ejecutar el monitor con:"
echo ""
echo "./monitor.sh"
echo ""