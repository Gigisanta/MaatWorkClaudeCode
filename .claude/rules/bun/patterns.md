---
paths:
  - "**/*.ts"
  - "**/*.tsx"
---
# Bun Patterns

> This file extends [patterns.md](../common/patterns.md) with Bun specific patterns.

## CLI Application Pattern

```typescript
#!/usr/bin/env bun
import { parseArgs } from 'util'

interface CLIOptions {
  verbose: boolean
  config: string
  input: string[]
}

const { values } = parseArgs({
  args: Bun.argv.slice(2),
  options: {
    verbose: {
      type: 'boolean',
      short: 'v',
      default: false
    },
    config: {
      type: 'string',
      short: 'c',
      default: './config.json'
    },
    input: {
      type: 'string',
      multiple: true,
      default: []
    }
  },
  allowPositionals: true
})

async function main() {
  if (values.verbose) {
    console.log('Starting with config:', values.config)
  }

  for (const file of values.input) {
    await processFile(file)
  }
}

main().catch(console.error)
```

## Service Pattern

```typescript
// services/price-service.ts
interface PriceData {
  symbol: string
  price: number
  timestamp: number
}

export class PriceService {
  private cache = new Map<string, { data: PriceData, expires: number }>()
  private readonly CACHE_TTL = 5000 // 5 seconds

  async getPrice(symbol: string): Promise<PriceData> {
    const cached = this.cache.get(symbol)
    if (cached && cached.expires > Date.now()) {
      return cached.data
    }

    const response = await fetch(`https://api.exchange.com/price/${symbol}`)
    const data: PriceData = await response.json()

    this.cache.set(symbol, {
      data,
      expires: Date.now() + this.CACHE_TTL
    })

    return data
  }

  clearCache() {
    this.cache.clear()
  }
}

export const priceService = new PriceService()
```

## Repository Pattern (SQLite)

```typescript
// repositories/user-repository.ts
import { Database } from 'bun:sqlite'

export interface User {
  id: number
  email: string
  name: string
  createdAt: string
}

export class UserRepository {
  constructor(private db: Database) {
    this.db.run(`
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP
      )
    `)
  }

  findByEmail(email: string): User | undefined {
    return this.db
      .query<User, string>('SELECT * FROM users WHERE email = ?')
      .get(email)
  }

  findById(id: number): User | undefined {
    return this.db
      .query<User, number>('SELECT * FROM users WHERE id = ?')
      .get(id)
  }

  create(data: Omit<User, 'id' | 'createdAt'>): User {
    const result = this.db
      .query('INSERT INTO users (email, name) VALUES (?, ?) RETURNING *')
      .get(data.email, data.name) as User
    return result
  }

  update(id: number, data: Partial<User>): boolean {
    const fields = Object.keys(data)
      .map(k => `${k} = ?`)
      .join(', ')
    const values = [...Object.values(data), id]

    const result = this.db
      .query(`UPDATE users SET ${fields} WHERE id = ?`)
      .run(...values)

    return result.changes > 0
  }

  delete(id: number): boolean {
    const result = this.db
      .query('DELETE FROM users WHERE id = ?')
      .run(id)
    return result.changes > 0
  }
}
```

## Event Emitter Pattern

```typescript
// events/emitter.ts
type EventMap = {
  'price:update': { symbol: string; price: number }
  'order:filled': { orderId: string; price: number }
  'error': { message: string }
}

type EventCallback<K extends keyof EventMap> = (data: EventMap[K]) => void

export class EventEmitter<Events extends Record<string, unknown>> {
  private listeners = new Map<keyof Events, Set<EventCallback<keyof Events>>>()

  on<K extends keyof Events>(event: K, callback: EventCallback<K>): () => void {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, new Set())
    }
    this.listeners.get(event)!.add(callback as EventCallback<keyof Events>)

    // Return unsubscribe function
    return () => this.off(event, callback)
  }

  off<K extends keyof Events>(event: K, callback: EventCallback<K>): void {
    this.listeners.get(event)?.delete(callback as EventCallback<keyof Events>)
  }

  emit<K extends keyof Events>(event: K, data: Events[K]): void {
    this.listeners.get(event)?.forEach(cb => cb(data))
  }
}

export const emitter = new EventEmitter<EventMap>()

// Usage
emitter.on('price:update', ({ symbol, price }) => {
  console.log(`${symbol}: $${price}`)
})
```

## Streaming Pattern

```typescript
// Process large files efficiently
const file = Bun.file('large-dataset.jsonl')

const stream = new ReadableStream({
  async start(controller) {
    for await (const line of file.lines()) {
      const data = JSON.parse(line)
      // Process line
      controller.enqueue(processData(data))
    }
    controller.close()
  }
})

// Or use Bun's built-in streaming
const lines = file.lines()

for await (const line of lines) {
  const data = JSON.parse(line)
  console.log('Processing:', data)
}
```

## Parallel Execution Pattern

```typescript
// Fetch multiple resources in parallel
async function fetchAllPrices(symbols: string[]) {
  const promises = symbols.map(symbol =>
    fetch(`https://api.exchange.com/price/${symbol}`)
      .then(res => res.json())
  )

  const results = await Promise.allSettled(promises)

  return results.map((result, i) => ({
    symbol: symbols[i],
    ...(result.status === 'fulfilled'
      ? { price: result.value.price, error: null }
      : { price: null, error: result.reason.message })
  }))
}
```

## Graceful Shutdown Pattern

```typescript
const server = Bun.serve({
  port: 3000,
  fetch(req) { /* ... */ }
})

const signals: Promise<void>[] = []

// Handle SIGTERM
signals.push(
  new Promise(resolve => {
    process.on('SIGTERM', () => {
      console.log('SIGTERM received, shutting down...')
      server.stop()
      resolve()
    })
  })
)

// Handle SIGINT
signals.push(
  new Promise(resolve => {
    process.on('SIGINT', () => {
      console.log('SIGINT received, shutting down...')
      server.stop()
      resolve()
    })
  })
)

await Promise.race(signals)
console.log('Server shut down gracefully')
```
