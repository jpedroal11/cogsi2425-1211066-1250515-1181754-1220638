#!/bin/bash
# Script para criar distribuição instalável

set -e

APP_JAR=$1
LIB_JAR=$2
OUTPUT_DIR=$3
VERSION=$4

echo "📦 Criando distribuição instalável..."

# Criar estrutura de diretórios
mkdir -p "$OUTPUT_DIR/bin"
mkdir -p "$OUTPUT_DIR/lib"

# Copiar JARs
cp "$APP_JAR" "$OUTPUT_DIR/lib/payroll_app.jar"
cp "$LIB_JAR" "$OUTPUT_DIR/lib/payroll_lib.jar"

# Criar script de execução para Linux/Mac
cat > "$OUTPUT_DIR/bin/payroll_app" << 'EOF'
#!/bin/bash
# Script de execução para Linux/Mac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/../lib"

java -jar "$LIB_DIR/payroll_app.jar" "$@"
EOF

chmod +x "$OUTPUT_DIR/bin/payroll_app"

# Criar script de execução para Windows
cat > "$OUTPUT_DIR/bin/payroll_app.bat" << 'EOF'
@echo off
REM Script de execução para Windows

set SCRIPT_DIR=%~dp0
set LIB_DIR=%SCRIPT_DIR%..\lib

java -jar "%LIB_DIR%\payroll_app.jar" %*
EOF

echo "✅ Distribuição criada em: $OUTPUT_DIR"
echo "   - Scripts: bin/payroll_app (Linux/Mac) e bin/payroll_app.bat (Windows)"
echo "   - Bibliotecas: lib/"

