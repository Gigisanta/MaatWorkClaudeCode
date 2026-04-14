---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
---
# Bun Coding Style

> This file extends [common/coding-style.md](../common/coding-style.md) with Bun specific content.

## Bun Runtime

Use **Bun** as the default runtime (not Node.js).

### Package Manager

- Use `bun install` instead of `npm install`, `yarn`, or `pnpm`
- Bun auto-loads `.env` files, no need for `dotenv`

```bash
bun install
bun run dev
bun test
bun build
```

## File Structure

```
project/
├── src/
│   ├── cli/          # CLI entry points
│   ├── lib/          # Shared utilities
│   ├── services/     # Business logic
│   └── index.ts      # Main entry
├── tests/
│   └── *.test.ts    # Vitest or bun test
├── package.json
└── tsconfig.json
```

## TypeScript

- Use TypeScript for all `.ts`/`.tsx` files
- Explicit types for function signatures and exports
- No `any` - use `unknown` when type is unclear

```typescript
// CORRECT: Explicit types
export function fetchPrice(symbol: string): Promise<number> {
  return fetch(`https://api.exchange.com/price/${symbol}`)
    .then(res => res.json())
    .then(data => data.price)
}

// WRONG: Implicit any
export function fetchPrice(symbol) {
  return fetch(`https://api.exchange.com/price/${symbol}`)
}
```

## Bun-native APIs

### HTTP Server (Bun.serve)

```typescript
import type { Serve, Server } from 'bun'

const server: Server = Bun.serve({
  port: 3000,
  development: process.env.NODE_ENV !== 'production',

  async fetch(req) {
    const url = new URL(req.url)

    if (url.pathname === '/api/health') {
      return Response.json({ status: 'ok', timestamp: Date.now() })
    }

    return new Response('Not Found', { status: 404 })
  },

  error(error: Error) {
    console.error('Server error:', error)
    return new Response('Internal Server Error', { status: 500 })
  }
})

console.log(`Listening on http://localhost:${server.port}`)
```

### WebSocket Server

```typescript
Bun.serve({
  port: 3000,
  websocket: {
    open(ws) {
      console.log('Client connected')
    },
    message(ws, message) {
      ws.send(`Echo: ${message}`)
    },
    close(ws, code, reason) {
      console.log('Client disconnected')
    }
  },
  fetch(req) {
    return new Response('WebSocket server')
  }
})
```

### SQLite (bun:sqlite)

```typescript
import { Database } from 'bun:sqlite'

const db = new Database('app.db')

// Queries are auto-typed
const users = db.query<{ id: number, name: string }, string>(
  'SELECT id, name FROM users WHERE active = ?'
).all('true')

// Prepared statements
const insert = db.prepare('INSERT INTO users (name, email) VALUES (?, ?)')
insert.run('Alice', 'alice@example.com')
```

### File Operations

```typescript
// Use Bun.file for efficient file reading
const file = Bun.file('data.json')
const data = await file.json()

// Write files
await Bun.write('output.json', JSON.stringify(data, null, 2))

// File streaming
const readable = Bun.file('large.log').stream()
```

### Subprocess (bun:shell)

```typescript
import { $ } from 'bun'

// Simple command
const result = await $`ls -la`.text()

// Piped commands
const output = await $`cat package.json | grep name`.text()

// With arguments (safely escaped)
const files = await $`find . -name "*.ts"`.array()
```

## Environment Variables

Bun auto-loads `.env` files. No need for `dotenv` package.

```bash
# .env
API_KEY=your-secret-key
DATABASE_URL=postgres://...
```

```typescript
// Access directly - Bun auto-loads .env
const apiKey = process.env.API_KEY
```

## Console Output

- Use `console.log` for general output
- Use `console.error` for errors
- Use `Bun.write(stderr, ...)` for stderr without formatting

```typescript
console.log('Starting server...')
console.error('Failed to connect:', error.message)

// For raw stderr (no formatting)
import { stderr } from 'bun'
await Bun.write(stderr, `Error: ${error.message}\n`)
```

## Error Handling

```typescript
try {
  const response = await fetch('https://api.example.com/data')
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}: ${response.statusText}`)
  }
  const data = await response.json()
} catch (error) {
  console.error('Fetch failed:', error)
  throw error // Re-throw for caller to handle
}
```

## Immutability

Prefer pure functions and immutable patterns:

```typescript
// WRONG: Mutation
function addItem(list: string[], item: string): string[] {
  list.push(item) // MUTATION!
  return list
}

// CORRECT: Return new array
function addItem(list: readonly string[], item: string): string[] {
  return [...list, item]
}
```

## API Design

### JSON Response Pattern

```typescript
export function jsonResponse<T>(data: T, status = 200): Response {
  return Response.json({ success: true, data }, { status })
}

export function errorResponse(message: string, status = 400): Response {
  return Response.json({ success: false, error: message }, { status })
}

// Usage
return jsonResponse({ user: { id: 1, name: 'Alice' } })
return errorResponse('Invalid input', 400)
```

## Dependencies

Only install what's necessary. Bun resolves packages efficiently.

```bash
# Install production dependency
bun add zod

# Install dev dependency
bun add -d @types/bun vitest

# Install peer dependency
bun add -p ethers
```
