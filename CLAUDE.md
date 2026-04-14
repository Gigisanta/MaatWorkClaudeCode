# MaatWorkClaudeCode

Este repo contiene la configuración completa de Claude Code para el equipo MaatWork.

## Estructura

- `.claude/rules/` - Reglas de codificación por lenguaje
- `.claude/skills/` - Skills especializados
- `.claude/agents/` - Agentes de código
- `.claude/commands/` - Comandos personalizados
- `.claude/hooks/` - Hooks de automatización
- `.claude/plugins/` - Configuración de plugins
- `scripts/` - Scripts de instalación y sincronización

## Instalación

```bash
git clone https://github.com/Gigisanta/MaatWorkClaudeCode.git
cd MaatWorkClaudeCode
bash scripts/install.sh
```

## Comandos Disponibles

Una vez instalado, dispones de:

- `/build` - Build automático con detección de proyecto
- `/deploy` - Despliegue a dev, staging, prod, preview
- `/test` - Ejecutar tests con coverage
- `/review` - Code review estructurado
- `/debug` - Debugging sistemático
- `/git-commit` - Commit con análisis automático
- `/mcp` - Gestión de MCP servers

## Actualización

Para sincronizar cambios desde tu configuración local al repo:

```bash
bash scripts/sync-config.sh
git add -A
git commit -m "tu mensaje"
git push
```
