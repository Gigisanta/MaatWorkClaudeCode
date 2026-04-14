#!/bin/bash
# Sincroniza cambios de vuelta al repo

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

echo "Sincronizando configuracion local -> repo..."
echo ""

# Copiar desde ~/.claude hacia el repo
echo "- Sincronizando rules..."
rsync -av --exclude='.DS_Store' "$HOME/.claude/rules/" "$REPO_DIR/.claude/rules/"

echo "- Sincronizando skills..."
rsync -av --exclude='.DS_Store' --exclude='find-skills' "$HOME/.claude/skills/" "$REPO_DIR/.claude/skills/"

echo "- Sincronizando agents..."
rsync -av --exclude='.DS_Store' "$HOME/.claude/agents/" "$REPO_DIR/.claude/agents/"

echo "- Sincronizando commands..."
rsync -av --exclude='.DS_Store' "$HOME/.claude/commands/" "$REPO_DIR/.claude/commands/"

echo "- Sincronizando hooks..."
rsync -av --exclude='.DS_Store' "$HOME/.claude/hooks/" "$REPO_DIR/.claude/hooks/"

echo ""
echo "Cambios sincronizados. Ahora haz commit y push:"
echo "cd $REPO_DIR"
echo "git add -A"
echo "git commit -m 'Actualizacion de configuracion'"
echo "git push"
