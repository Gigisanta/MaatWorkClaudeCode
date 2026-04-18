# Bun Hooks

> This file extends [common/hooks.md](../common/hooks.md) with Bun specific content.

## Bun-specific PostToolUse Hooks

### Auto-format with Biome (Bun-compatible)

```json
{
  "matcher": "Edit|Write",
  "hooks": [
    {
      "type": "command",
      "command": "npx @biomejs/biome check --write $FILE_PATH",
      "async": true
    }
  ]
}
```

## Build Hooks

### Pre-build Validation

```bash
# package.json scripts
{
  "scripts": {
    "prebuild": "bun run typecheck && bun run lint",
    "build": "bun build src/index.ts --outdir=dist --target=bun",
    "postbuild": "echo 'Build complete'"
  }
}
```

### Type Check

```typescript
// scripts/typecheck.ts
import { exec } from 'child_process'
import { promisify } from 'util'

const execAsync = promisify(exec)

async function typecheck() {
  try {
    await execAsync('bun run tsc --noEmit')
    console.log('TypeScript: OK')
  } catch (error) {
    console.error('TypeScript errors found')
    process.exit(1)
  }
}

typecheck()
```

## Dev Server Hooks

### Auto-restart Configuration

```json
{
  "scripts": {
    "dev": "bun --watch src/index.ts"
  }
}
```

## Bun Install Hooks

```json
{
  "scripts": {
    "postinstall": "bun run generate-types"
  }
}
```

## Testing Hooks

### Pre-test Setup

```json
{
  "scripts": {
    "pretest": "bun run db:reset",
    "test": "bun test",
    "posttest": "bun run coverage"
  }
}
```

## Environment Validation Hook

```typescript
// hooks/validate-env.ts
const required = [
  'DATABASE_URL',
  'JWT_SECRET',
  'API_KEY'
]

const missing = required.filter(key => !process.env[key])

if (missing.length > 0) {
  console.error(`Missing required environment variables:\n  - ${missing.join('\n  - ')}`)
  process.exit(1)
}
```
