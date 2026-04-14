# MaatWorkClaudeCode

Configuración completa de Claude Code para compartir entre equipos MaatWork.

## Instalación Rápida

```bash
git clone https://github.com/Gigisanta/MaatWorkClaudeCode.git ~/.claude-template
cd ~/.claude-template
bash scripts/install.sh
```

## Qué Incluye

- **Rules**: Sistema de reglas de codificación para 11 lenguajes (TypeScript, Next.js, Go, Kotlin, Rust, Python, Bun, C++, Perl, PHP, Swift)
- **Skills**: ~60 skills especializados (brainstorming, systematic-debugging, tdd, writing-plans, vercel-plugin, etc.)
- **Agents**: ~30 agentes para code review, arquitectura, debugging, etc.
- **Commands**: 7 comandos personalizados (/build, /deploy, /test, /review, /debug, /git-commit, /mcp)
- **Hooks**: auto-format, log-commands, secrets-detector, typecheck

## Requisitos

- Claude Code instalado (https://claude.ai/code)
- Git
- Bash 4.0+

## Post-Instalación

1. **Agregar tus API Keys** - Editar `~/.claude/mcp.json`:
   - `UPSTASH_CONTEXT7_API_KEY` - Para Context7 (documentación en tiempo real)
   - `BRAVE_API_KEY` - Para Brave Search (búsquedas web)

2. **Reinstalar plugins** (opcional, se instalan automáticamente):
   ```bash
   claude plugins install claude-plugins-official
   ```

## Estructura

```
.claude/
├── rules/        # Reglas de codificación por lenguaje
│   ├── common/   # Reglas universales
│   ├── typescript/
│   ├── nextjs/
│   ├── golang/
│   └── ...
├── skills/       # Skills especializados (~60)
├── agents/       # Agentes de código (~30)
├── commands/     # Comandos personalizados (7)
├── hooks/        # Hooks de automatización
└── plugins/      # Configuración de plugins
```

## Comandos Disponibles

Una vez instalado, dispones de:

| Comando | Descripción |
|---------|-------------|
| `/build` | Build automático con detección de proyecto |
| `/deploy` | Despliegue a dev, staging, prod, preview |
| `/test` | Ejecutar tests con coverage reporting |
| `/review` | Code review estructurado por severidad |
| `/debug` | Debugging sistemático en 4 fases |
| `/git-commit` | Commit con análisis automático |
| `/mcp` | Gestión de MCP servers |

## Actualización del Repo

Si haces cambios en tu configuración local y quieres subirlos:

```bash
bash scripts/sync-config.sh
git add -A
git commit -m "tu mensaje"
git push
```

## Sincronizar en Nuevo Equipo

```bash
git clone https://github.com/Gigisanta/MaatWorkClaudeCode.git
cd MaatWorkClaudeCode
bash scripts/install.sh
# Agregar API keys en ~/.claude/mcp.json
```

## Créditos

Configuración original creada por el equipo MaatWork.
"""
