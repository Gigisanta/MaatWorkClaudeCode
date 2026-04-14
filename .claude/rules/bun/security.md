---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/.env*"
---
# Bun Security

> This file extends [common/security.md](../common/security.md) with Bun specific content.

## Environment Variables

### Never Commit Secrets

```bash
# .gitignore
.env
.env.local
.env.*.local
*.pem
*.key
```

### Validate at Startup

```typescript
// lib/env.ts
const required = {
  API_KEY: 'string',
  DATABASE_URL: 'string',
  JWT_SECRET: 'string'
} as const

type EnvKey = keyof typeof required

function getEnv(key: EnvKey): string {
  const value = process.env[key]
  if (value === undefined) {
    throw new Error(`Missing required environment variable: ${key}`)
  }
  return value
}

// Usage
const apiKey = getEnv('API_KEY')
```

## Input Validation

### Use Zod for Runtime Validation

```typescript
import { z } from 'zod'

const configSchema = z.object({
  port: z.number().min(1).max(65535),
  logLevel: z.enum(['debug', 'info', 'warn', 'error']),
  features: z.object({
    auth: z.boolean(),
    analytics: z.boolean()
  })
})

const config = configSchema.parse(process.env)
// config is fully typed and validated
```

## HTTP Security

### Sanitize Request Input

```typescript
import { sanitize } from 'string-sanitize'

async function handleRequest(req: Request): Promise<Response> {
  const body = await req.json()

  // Sanitize user input
  const sanitized = {
    name: sanitize(body.name).trim(),
    email: sanitize(body.email).trim().toLowerCase()
  }

  // Validate with Zod
  const result = userSchema.safeParse(sanitized)
  if (!result.success) {
    return Response.json({ error: 'Invalid input' }, { status: 400 })
  }

  return processUser(result.data)
}
```

## SQL Injection Prevention

### Use Parameterized Queries

```typescript
import { Database } from 'bun:sqlite'

const db = new Database('app.db')

// SAFE: Parameterized query
const user = db
  .query<{ id: number, name: string }, [string]>(
    'SELECT id, name FROM users WHERE email = ?'
  )
  .get('user@example.com')

// WRONG: String interpolation (SQL injection risk)
const bad = db
  .query(`SELECT * FROM users WHERE email = '${email}'`)
  .get()
```

## Cryptographic Operations

### Secure Token Generation

```typescript
import { randomBytes, createHmac, timingSafeEqual } from 'crypto'

// Generate secure random token
function generateToken(length = 32): string {
  return randomBytes(length).toString('hex')
}

// Hash passwords with bcrypt-like approach
async function hashPassword(password: string): Promise<string> {
  const salt = randomBytes(16).toString('hex')
  const hash = createHmac('sha256', salt).update(password).digest('hex')
  return `${salt}:${hash}`
}

async function verifyPassword(password: string, stored: string): Promise<boolean> {
  const [salt, hash] = stored.split(':')
  const inputHash = createHmac('sha256', salt).update(password).digest('hex')

  const storedBuffer = Buffer.from(hash, 'hex')
  const inputBuffer = Buffer.from(inputHash, 'hex')

  return timingSafeEqual(storedBuffer, inputBuffer)
}
```

## CORS Configuration

```typescript
const server = Bun.serve({
  port: 3000,

  fetch(req) {
    // CORS headers
    const origin = req.headers.get('Origin')
    const allowedOrigins = ['https://app.example.com', 'https://admin.example.com']

    if (!allowedOrigins.includes(origin ?? '')) {
      return new Response('Forbidden', { status: 403 })
    }

    return new Response('Hello', {
      headers: {
        'Access-Control-Allow-Origin': origin!,
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization'
      }
    })
  }
})
```

## Rate Limiting

```typescript
import { Redis } from '@upstash/redis'

const redis = Redis.fromEnv()

interface RateLimitResult {
  success: boolean
  remaining: number
  reset: number
}

async function checkRateLimit(
  key: string,
  limit: number,
  windowSeconds: number
): Promise<RateLimitResult> {
  const now = Math.floor(Date.now() / 1000)
  const windowStart = now - windowSeconds

  // Remove old entries
  await redis.zremrangebyscore(key, 0, windowStart)

  // Count requests in window
  const count = await redis.zcard(key)

  if (count >= limit) {
    return {
      success: false,
      remaining: 0,
      reset: windowStart + windowSeconds
    }
  }

  // Add current request
  await redis.zadd(key, { score: now, member: `${now}-${Math.random()}` })
  await redis.expire(key, windowSeconds)

  return {
    success: true,
    remaining: limit - count - 1,
    reset: windowStart + windowSeconds
  }
}

// Usage in fetch handler
async function handleRequest(req: Request): Promise<Response> {
  const ip = req.headers.get('x-forwarded-for') ?? 'anonymous'
  const { success, remaining } = await checkRateLimit(`ratelimit:${ip}`, 100, 60)

  if (!success) {
    return Response.json(
      { error: 'Rate limit exceeded', remaining: 0 },
      { status: 429 }
    )
  }

  // Process request...
}
```

## File Upload Security

```typescript
async function handleUpload(req: Request): Promise<Response> {
  const formData = await req.formData()
  const file = formData.get('file') as File

  // Validate file size (max 10MB)
  const MAX_SIZE = 10 * 1024 * 1024
  if (file.size > MAX_SIZE) {
    return Response.json(
      { error: 'File too large (max 10MB)' },
      { status: 400 }
    )
  }

  // Validate MIME type
  const allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'application/pdf']
  if (!allowedTypes.includes(file.type)) {
    return Response.json(
      { error: 'Invalid file type' },
      { status: 400 }
    )
  }

  // Generate safe filename
  const ext = file.name.split('.').pop()
  const safeName = `${crypto.randomUUID()}.${ext}`

  // Save file
  const buffer = await file.arrayBuffer()
  await Bun.write(`./uploads/${safeName}`, buffer)

  return Response.json({ url: `/uploads/${safeName}` })
}
```
