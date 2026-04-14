---
paths:
  - "**/*.test.ts"
  - "**/*.spec.ts"
  - "**/tests/**/*.ts"
---
# Bun Testing

> This file extends [common/testing.md](../common/testing.md) with Bun specific content.

## Bun Test Framework

Use **bun test** as the primary test runner (built-in, fast).

```typescript
import { describe, test, expect, beforeEach } from 'bun:test'

describe('Math utilities', () => {
  test('should add numbers', () => {
    expect(1 + 2).toBe(3)
  })
})
```

## Test File Patterns

```
project/
├── src/
│   ├── utils.ts
│   └── utils.test.ts    # Co-located test
├── tests/
│   ├── setup.ts         # Global setup
│   └── integration/
│       └── api.test.ts
└── *.test.ts           # Root level tests
```

## Unit Testing

### Functions

```typescript
import { describe, test, expect } from 'bun:test'
import { calculateTotal, formatCurrency } from './math'

describe('calculateTotal', () => {
  test('should sum line items', () => {
    const items = [
      { price: 10, quantity: 2 },
      { price: 5, quantity: 3 }
    ]
    expect(calculateTotal(items)).toBe(35)
  })

  test('should handle empty array', () => {
    expect(calculateTotal([])).toBe(0)
  })
})
```

### Async Functions

```typescript
import { describe, test, expect } from 'bun:test'

describe('fetchPrice', () => {
  test('should fetch and parse price', async () => {
    const price = await fetchPrice('BTC')
    expect(typeof price).toBe('number')
    expect(price).toBeGreaterThan(0)
  })
})
```

## Mocking

### Mock Functions

```typescript
import { describe, test, expect, vi } from 'bun:test'

test('should call onSuccess callback', () => {
  const onSuccess = vi.fn()
  processPayment(100, { onSuccess })

  expect(onSuccess).toHaveBeenCalled()
  expect(onSuccess).toHaveBeenCalledWith(expect.objectContaining({
    amount: 100,
    status: 'completed'
  }))
})
```

### Mock Modules

```typescript
import { describe, test, expect, vi } from 'bun:test'

vi.mock('./email', () => ({
  sendEmail: vi.fn().mockResolvedValue({ id: 'email-123' })
}))

test('should send notification email', async () => {
  const { sendEmail } = await import('./email')
  await notifyUser('user-1')

  expect(sendEmail).toHaveBeenCalledWith(
    expect.objectContaining({
      to: 'user@example.com',
      subject: 'Notification'
    })
  )
})
```

### Mock Fetch

```typescript
global.fetch = vi.fn().mockResolvedValue({
  ok: true,
  json: async () => ({ price: 50000 }),
  status: 200
})

test('should fetch crypto price', async () => {
  const price = await getCryptoPrice('BTC')
  expect(price).toBe(50000)
})
```

## Database Testing (bun:sqlite)

```typescript
import { describe, test, expect, beforeEach } from 'bun:test'
import { Database } from 'bun:sqlite'
import { UserService } from './user-service'

describe('UserService', () => {
  let db: Database
  let userService: UserService

  beforeEach(() => {
    db = new Database(':memory:')
    db.run(`CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT)`)
    userService = new UserService(db)
  })

  test('should create user', () => {
    const user = userService.create({ name: 'Alice' })
    expect(user.id).toBe(1)
    expect(user.name).toBe('Alice')
  })
})
```

## HTTP Testing

```typescript
import { describe, test, expect, beforeAll, afterAll } from 'bun:test'
import type { Server } from 'bun'

let server: Server

beforeAll(() => {
  server = Bun.serve({
    port: 0, // Random available port
    async fetch(req) {
      const url = new URL(req.url)
      if (url.pathname === '/api/health') {
        return Response.json({ status: 'ok' })
      }
      return new Response('Not Found', { status: 404 })
    }
  })
})

afterAll(() => {
  server.stop()
})

describe('API Server', () => {
  test('GET /api/health', async () => {
    const response = await fetch(`http://localhost:${server.port}/api/health`)
    expect(response.status).toBe(200)
    expect(await response.json()).toEqual({ status: 'ok' })
  })
})
```

## Running Tests

```bash
# Run all tests
bun test

# Run specific file
bun test src/math.test.ts

# Run with coverage
bun test --coverage

# Run in watch mode (dev)
bun test --watch
```

## Coverage Requirements

**Minimum: 80%**

```bash
bun test --coverage --coverageThreshold='{"functions":80,"lines":80,"branches":80}'
```
