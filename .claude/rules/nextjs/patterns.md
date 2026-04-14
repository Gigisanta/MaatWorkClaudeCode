---
paths:
  - "**/app/**/*.{ts,tsx}"
  - "**/src/app/**/*.{ts,tsx}"
---
# Next.js Patterns

> This file extends [patterns.md](../common/patterns.md) with Next.js specific patterns.

## API Response Format

Use consistent envelope for all API responses:

```typescript
// lib/api-response.ts
export function apiResponse<T>(data: T, status = 200) {
  return NextResponse.json({ success: true, data }, { status })
}

export function apiError(message: string, status = 400) {
  return NextResponse.json({ success: false, error: message }, { status })
}

// Usage
return apiResponse({ deal })
return apiError('Not found', 404)
```

## Authentication Pattern (Better Auth + jose)

```typescript
// lib/auth.ts
import { jwt, type JWT } from 'jose'

const secret = new TextEncoder().encode(process.env.JWT_SECRET!)

export async function auth() {
  const token = getCookie('session')
  if (!token) return null

  try {
    const verified = await jwt.verify(token, secret)
    return verified as JWT
  } catch {
    return null
  }
}

// Middleware protection
export function requireAuth(handler: NextRequest => Promise<NextResponse>) {
  return async (req: NextRequest) => {
    const session = await auth()
    if (!session) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }
    return handler(req, session)
  }
}
```

## Form Handling Pattern

```typescript
// Using React Hook Form + Zod
'use client'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'

const dealSchema = z.object({
  name: z.string().min(1, 'Name is required'),
  stage: z.string(),
  value: z.number().positive()
})

type DealFormData = z.infer<typeof dealSchema>

export function DealForm() {
  const form = useForm<DealFormData>({
    resolver: zodResolver(dealSchema),
    defaultValues: { stage: 'PROSPECTO', value: 0 }
  })

  async function onSubmit(data: DealFormData) {
    const res = await fetch('/api/deals', {
      method: 'POST',
      body: JSON.stringify(data)
    })
    if (res.ok) {
      // Success handling
    }
  }

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)}>
        {/* Form fields */}
      </form>
    </Form>
  )
}
```

## Parallel Routes Pattern

```tsx
// app/@modal/(.)contacts/[id]/page.tsx
// Renders inside modal when visiting /contacts/123
export default function ContactModal() {
  return <ContactView contactId={params.id} />
}

// app/@modal/default.tsx
// Renders nothing when no modal
export default function Default() {
  return null
}
```

## Route Groups

```tsx
// app/(marketing)/page.tsx      → /
// app/(marketing)/about/page.tsx → /about
// app/(dashboard)/layout.tsx    → Shared layout for dashboard routes
// app/(dashboard)/contacts/page.tsx → /contacts
```

## Streaming Pattern

```tsx
// app/dashboard/page.tsx
import { Suspense } from 'react'

export default function DashboardPage() {
  return (
    <div>
      <DashboardStats />
      <Suspense fallback={<DealsSkeleton />}>
        <RecentDeals />
      </Suspense>
    </div>
  )
}
```

## Revalidation Patterns

```typescript
// Time-based (ISR)
export const revalidate = 3600 // Revalidate every hour

// On-demand (revalidatePath, revalidateTag)
import { revalidatePath, revalidateTag } from 'next/cache'

export async function createDeal(formData: FormData) {
  await db.deal.create({ data: formData })
  revalidatePath('/pipeline')
  revalidatePath('/contacts')
}
```
