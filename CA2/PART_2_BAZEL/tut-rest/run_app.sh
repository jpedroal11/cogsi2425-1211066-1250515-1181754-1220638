#!/bin/bash
# Script para executar a aplicação a partir da distribuição

set -e

DIST_DIR=$1

echo "🚀 Executando aplicação..."

# Detectar sistema operacional
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    # Windows
    echo "Sistema: Windows"
    "$DIST_DIR/bin/payroll_app.bat"
else
    # Linux/Mac
    echo "Sistema: Linux/Mac"
    "$DIST_DIR/bin/payroll_app"
fi

