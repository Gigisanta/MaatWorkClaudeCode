#!/bin/bash
set -e

echo "=== MaatWorkClaudeCode Installer ==="
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Verificar requisitos
if ! command -v claude &> /dev/null; then
    echo -e "${RED}Error: Claude Code no esta instalado${NC}"
    echo "Instalalo desde: https://claude.ai/code"
    exit 1
fi

# Backup de configuracion actual (si existe)
if [ -d "$HOME/.claude" ]; then
    echo -e "${YELLOW}Respaldando configuracion actual...${NC}"
    BACKUP_DIR="$HOME/.claude.backup.$(date +%Y%m%d_%H%M%S)"
    cp -r "$HOME/.claude" "$BACKUP_DIR"
    echo -e "${GREEN}Backup guardado en: $BACKUP_DIR${NC}"
fi

# Detectar directorio del repo
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

echo ""
echo "Instalando configuracion..."

# Copiar archivos
echo "- Copiando rules..."
cp -r "$REPO_DIR/.claude/rules" "$HOME/.claude/"

echo "- Copiando skills..."
cp -r "$REPO_DIR/.claude/skills" "$HOME/.claude/"

echo "- Copiando agents..."
cp -r "$REPO_DIR/.claude/agents" "$HOME/.claude/"

echo "- Copiando commands..."
cp -r "$REPO_DIR/.claude/commands" "$HOME/.claude/"

echo "- Copiando hooks..."
cp -r "$REPO_DIR/.claude/hooks" "$HOME/.claude/"

echo "- Copiando plugins config..."
cp -r "$REPO_DIR/.claude/plugins" "$HOME/.claude/"

echo "- Copiando settings.json..."
cp "$REPO_DIR/.claude/settings.json" "$HOME/.claude/"

echo "- Copiando mcp.json (template)..."
cp "$REPO_DIR/.claude/mcp.json" "$HOME/.claude/"

echo ""
echo -e "${GREEN}Configuracion copiada exitosamente!${NC}"
echo ""

# Solicitar API keys
echo "=== Configuracion de API Keys ==="
echo ""
read -p "Ingresa tu UPSTASH_CONTEXT7_API_KEY (o Enter para omitir): " context7_key
read -p "Ingresa tu BRAVE_API_KEY (o Enter para omitir): " brave_key

if [ -n "$context7_key" ]; then
    sed -i.bak "s/TU_UPSTASH_CONTEXT7_API_KEY/$context7_key/g" "$HOME/.claude/mcp.json"
    rm -f "$HOME/.claude/mcp.json.bak"
    echo -e "${GREEN}Context7 API key configurada${NC}"
fi

if [ -n "$brave_key" ]; then
    sed -i.bak "s/TU_BRAVE_API_KEY/$brave_key/g" "$HOME/.claude/mcp.json"
    rm -f "$HOME/.claude/mcp.json.bak"
    echo -e "${GREEN}Brave API key configurada${NC}"
fi

echo ""
echo "=== Instalacion completada ==="
echo ""
echo "Proximos pasos:"
echo "1. Reiniciar Claude Code"
echo "2. Ejecutar: claude plugins install claude-plugins-official"
echo "3. Verificar con: claude config show"
echo ""
