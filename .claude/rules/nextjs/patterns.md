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
return apiResponse({ item })
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

const itemSchema = z.object({
  name: z.string().min(1, 'Name is required'),
  description: z.string().optional(),
  quantity: z.number().int().positive()
})

type ItemFormData = z.infer<typeof itemSchema>

export function ItemForm() {
  const form = useForm<ItemFormData>({
    resolver: zodResolver(itemSchema),
    defaultValues: { quantity: 1 }
  })

  async function onSubmit(data: ItemFormData) {
    const res = await fetch('/api/items', {
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
// app/@modal/(.)items/[id]/page.tsx
// Renders inside modal when visiting /items/123
export default function ItemModal() {
  return <ItemView itemId={params.id} />
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
// app/(dashboard)/items/page.tsx → /items
```

## Streaming Pattern

```tsx
// app/dashboard/page.tsx
import { Suspense } from 'react'

export default function DashboardPage() {
  return (
    <div>
      <DashboardStats />
      <Suspense fallback={<ItemsSkeleton />}>
        <RecentItems />
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

export async function createItem(formData: FormData) {
  await db.item.create({ data: formData })
  revalidatePath('/items')
  revalidateTag('items')
}
```
