#!/bin/bash
# Script de deployment para DEV

set -e  # Para em caso de erro

# Argumentos do Bazel
APP_JAR=$1
LIB_JAR=$2
CONFIG_FILE=$3
OUTPUT_DIR=$4
VERSION=$5

echo "🚀 Iniciando deployment para DEV..."

# 1. Criar estrutura de diretórios
mkdir -p "$OUTPUT_DIR/lib"
echo "✅ Diretório criado: $OUTPUT_DIR"

# 2. Copiar JAR principal
cp "$APP_JAR" "$OUTPUT_DIR/payroll_app.jar"
echo "✅ Copiado: payroll_app.jar"

# 3. Copiar biblioteca compilada
cp "$LIB_JAR" "$OUTPUT_DIR/lib/payroll_lib.jar"
echo "✅ Copiado: lib/payroll_lib.jar"

# 4. Processar ficheiro de configuração (substituir tokens)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
sed -e "s/@project.version@/$VERSION/g" \
    -e "s/@build.timestamp@/$TIMESTAMP/g" \
    "$CONFIG_FILE" > "$OUTPUT_DIR/application.properties"
echo "✅ Processado: application.properties"
echo "   - Version: $VERSION"
echo "   - Timestamp: $TIMESTAMP"

# 5. Criar ficheiro de manifesto
cat > "$OUTPUT_DIR/DEPLOYMENT_INFO.txt" << EOF
===========================================
   DEPLOYMENT INFORMATION
===========================================
Application: Payroll Application
Version: $VERSION
Build Date: $TIMESTAMP
Environment: Development (DEV)
===========================================
EOF
echo "✅ Criado: DEPLOYMENT_INFO.txt"

echo ""
echo "🎉 Deployment concluído com sucesso!"
echo "📂 Localização: $OUTPUT_DIR"

