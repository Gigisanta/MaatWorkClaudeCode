# MaatWorkClaudeCode

Configuración completa de Claude Code para compartir entre equipos MaatWork.

## Instalación Rápida

```bash
git clone https://github.com/Gigisanta/MaatWorkClaudeCode.git ~/.claude-template
cd ~/.claude-template
bash scripts/install.sh
```

## Qué Incluye

### Rules (Estándares de Codificación)
- **common/** - Reglas universales (testing 80%, security, performance, patterns)
- **typescript/** - TypeScript + JavaScript (tipos, React patterns, Next.js)
- **nextjs/** - Next.js App Router (Server Components, routing, API routes)
- **bun/** - Bun runtime (APIs nativas, SQLite, WebSocket)
- **python/** - Python (PEP 8, type annotations, pytest)
- **php/** - PHP (PSR-12, Laravel patterns)
- **swift/** - Swift (value types, actors, Swift Testing)

### Skills (~60 skills especializados)
- `brainstorming` - Lluvia de ideas estructurada
- `systematic-debugging` - Debugging en 4 fases
- `test-driven-development` - TDD workflow
- `writing-plans` - Planificación de implementación
- `vercel-plugin/*` - 20+ skills de Vercel (deployment, functions, routing, etc.)
- `frontend-design`, `ui-design-system` - Diseño de interfaces
- `coding-standards`, `software-architecture` - Arquitectura de código

### Agents (~40 agentes)
- `code-reviewer` - Code review por severidad
- `architect`, `architect-review` - Decisiones arquitectónicas
- `frontend-developer`, `mobile-developer` - Desarrollo full-stack
- `error-detective`, `performance-engineer` - Troubleshooting
- `deployment-engineer`, `devops-engineer` - DevOps y CI/CD
- `data-engineer`, `api-documenter` - Datos y APIs

### Commands (8 comandos personalizados)
| Comando | Descripción |
|---------|-------------|
| `/build` | Build automático con detección de proyecto |
| `/deploy` | Despliegue a dev, staging, prod, preview |
| `/test` | Ejecutar tests con coverage reporting |
| `/review` | Code review estructurado por severidad |
| `/debug` | Debugging sistemático en 4 fases |
| `/git-commit` | Commit con análisis automático |
| `/refactor-code` | Refactoring inteligente |
| `/mcp` | Gestión de MCP servers |

### Hooks (Automatización)
- `auto-format.sh` - Auto-formateo con Biome/Prettier
- `secrets-detector.sh` - Detección de secretos
- `typecheck.sh` - Type checking
- `log-commands.sh` - Logging de comandos

### Configuración
- `settings.json` - Configuración principal
- `settings.local.json` - Configuración local (API keys, permissions)
- `mcp.json` - MCP servers (Context7, Brave Search)

## Requisitos

- Claude Code instalado (https://claude.ai/code)
- Git
- Bash 4.0+

## Post-Instalación

### 1. Agregar tus API Keys

Edita `~/.claude/mcp.json` con tus API keys:
- `UPSTASH_CONTEXT7_API_KEY` - Para Context7 (documentación en tiempo real)
  - Obtén tu key en: https://console.upstash.com/
- `BRAVE_API_KEY` - Para Brave Search (búsquedas web)
  - Obtén tu key en: https://brave.com/search/api/

### 2. Instalar Plugins (opcional)

```bash
claude plugins install claude-plugins-official
claude plugins install claude-hud
```

### 3. Verificar Instalación

```bash
claude config show
```

## Estructura

```
.claude/
├── rules/           # Estándares de codificación por lenguaje
│   ├── common/     # Reglas universales
│   ├── typescript/
│   ├── nextjs/
│   ├── bun/
│   ├── python/
│   ├── php/
│   └── swift/
├── skills/         # ~60 skills especializados
├── agents/         # ~40 agentes de código
├── commands/       # Comandos personalizados (8)
├── hooks/          # Scripts de automatización
├── settings.json   # Configuración principal
├── settings.local.json  # Configuración local
└── mcp.json        # MCP servers
```

## Sincronizar Cambios

Si haces cambios en tu configuración local y quieres subirlos:

```bash
cd ~/.claude-template
bash scripts/sync-config.sh
git add -A
git commit -m "tu mensaje"
git push
```

## Actualizar en Nuevo Equipo

```bash
git clone https://github.com/Gigisanta/MaatWorkClaudeCode.git ~/.claude-template
cd ~/.claude-template
bash scripts/install.sh
# Agregar API keys en ~/.claude/mcp.json
```

## Configuración de Permisos

Los permisos por defecto permiten:
- Lectura/escritura en archivos de código (`.ts`, `.js`, `.tsx`, `.css`, `.json`, `.md`)
- Comandos Git, npm, pnpm, yarn, bun
- MCP servers de búsqueda (Brave) y documentación (Context7)

Los permisos peligrosos (`rm -rf`, `sudo`, `curl`, `wget`) están denegados por defecto.

## Créditos

Configuración original creada por el equipo MaatWork.
