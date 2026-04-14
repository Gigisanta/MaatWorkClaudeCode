#!/bin/bash
set -e

echo "=== Plugin Setup ==="
echo ""

PLUGINS=(
    "qodo-skills@claude-plugins-official"
    "remember@claude-plugins-official"
    "product-tracking-skills@claude-plugins-official"
    "firecrawl@claude-plugins-official"
    "vercel@claude-plugins-official"
    "superpowers@claude-plugins-official"
    "chrome-devtools-mcp@claude-plugins-official"
    "code-review@claude-plugins-official"
    "context7@claude-plugins-official"
    "feature-dev@claude-plugins-official"
    "frontend-design@claude-plugins-official"
    "skill-creator@claude-plugins-official"
    "code-simplifier@claude-plugins-official"
)

for plugin in "${PLUGINS[@]}"; do
    echo "Installing $plugin..."
    claude plugins install "$plugin" 2>/dev/null || echo "  (puede requerir autenticacion manual)"
done

echo ""
echo "=== Plugin Setup Complete ==="
