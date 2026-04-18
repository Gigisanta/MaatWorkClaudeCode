# Next.js Security

> This file extends [common/security.md](../common/security.md) with Next.js specific content.

## Authentication Security

### Always Validate Sessions in API Routes

```typescript
// WRONG: No auth check
export async function GET() {
  const data = await db.item.findMany()
  return NextResponse.json({ data })
}

// CORRECT: Always validate auth
export async function GET() {
  const session = await auth()
  if (!session) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }
  const data = await db.item.findMany({
    where: { userId: session.user.id }
  })
  return NextResponse.json({ data })
}
```

### JWT Security

```typescript
// lib/auth.ts
const secret = new TextEncoder().encode(process.env.JWT_SECRET!)
const algorithm = 'HS256'

// Always verify, never trust
async function verifyToken(token: string) {
  try {
    return await jwt.verify(token, secret, { algorithms: [algorithm] })
  } catch {
    return null // Explicit null for invalid tokens
  }
}
```

## Authorization

### Role-based Access

```typescript
// lib/auth.ts
type UserRole = 'admin' | 'manager' | 'user'

export function requireRole(allowedRoles: UserRole[]) {
  return async (req: NextRequest) => {
    const session = await auth()
    if (!session) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }
    if (!allowedRoles.includes(session.user.role)) {
      return NextResponse.json({ error: 'Forbidden' }, { status: 403 })
    }
  }
}

// Usage in API route
const handler = requireRole(['admin', 'manager'])
export const GET = handler(async (req) => {
  // Only admins and managers reach here
})
```

## Input Validation

### Zod for API Input

```typescript
import { z } from 'zod'

const createItemSchema = z.object({
  name: z.string().min(1).max(255),
  category: z.string(),
  quantity: z.number().int().positive()
})

export async function POST(req: NextRequest) {
  const body = await req.json()

  const result = createItemSchema.safeParse(body)
  if (!result.success) {
    return NextResponse.json(
      { error: 'Validation failed', details: result.error },
      { status: 400 }
    )
  }

  const item = await db.item.create({ data: result.data })
  return NextResponse.json({ item }, { status: 201 })
}
```

## CSRF Protection

Next.js API Routes are protected by default when using:
- Same-site cookies
- Proper Content-Type headers
- Nonced CSP headers

## Rate Limiting

```typescript
import { Ratelimit } from '@upstash/ratelimit'
import { Redis } from '@upstash/redis'

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, '10 s') // 10 requests per 10 seconds
})

export async function POST(req: NextRequest) {
  const ip = req.headers.get('x-forwarded-for') ?? 'anonymous'
  const { success, remaining } = await ratelimit.limit(ip)

  if (!success) {
    return NextResponse.json(
      { error: 'Rate limit exceeded' },
      { status: 429 }
    )
  }
}
```

## Security Headers

```typescript
// middleware.ts or next.config.js
export function middleware(req: NextRequest) {
  const response = NextResponse.next()

  response.headers.set('X-Content-Type-Options', 'nosniff')
  response.headers.set('X-Frame-Options', 'DENY')
  response.headers.set('X-XSS-Protection', '1; mode=block')
  response.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin')

  return response
}

export const config = {
  matcher: ['/api/:path*', '/dashboard/:path*']
}
```

## Secret Management

- **NEVER** commit `.env` files
- Use `.env.example` with placeholder values
- Access secrets via `process.env` only in server-side code
- Never expose `JWT_SECRET` or `DATABASE_URL` to client

```bash
# .gitignore
.env
.env.local
.env.*.local
```

## SQL Injection Prevention

ORMs like Prisma automatically prevent SQL injection via parameterized queries.

```typescript
// SAFE: ORM parameterized queries
const items = await db.item.findMany({
  where: { userId: userInput } // ORM escapes automatically
})

// NEVER: Raw SQL with user input
const bad = await db.$queryRaw`SELECT * FROM items WHERE id = ${userInput}`
```
