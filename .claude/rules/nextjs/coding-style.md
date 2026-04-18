# Next.js Coding Style

> This file extends [common/coding-style.md](../common/coding-style.md) with Next.js specific content.

## Server vs Client Components

### Default to Server Components

- Use **Server Components** by default (no 'use client' directive)
- Add `'use client'` only when you need:
  - `useState`, `useReducer`, `useEffect`
  - Browser APIs (window, localStorage)
  - Event listeners
  - Custom hooks that use any of the above

```tsx
// DEFAULT: Server Component (no 'use client')
// app/dashboard/page.tsx
export default async function DashboardPage() {
  const data = await fetchDashboardData()
  return <DashboardStats data={data} />
}

// ONLY when needed: Client Component
'use client'
import { useState } from 'react'
export function ItemForm() {
  const [name, setName] = useState('')
  // ...
}
```

### Component Composition Pattern

```tsx
// Server Component fetches data
// app/items/page.tsx
export default async function ItemsPage() {
  const items = await fetchItems()
  return <ItemList items={items} />
}

// Client Component handles interactivity
'use client'
import { ItemList } from './ItemList'
```

## App Router Conventions

### File Naming

```
app/
├── page.tsx              # Route page (/)
├── layout.tsx            # Shared layout
├── loading.tsx           # Loading states
├── error.tsx            # Error boundaries
├── not-found.tsx        # 404 page
├── api/                 # API routes
│   ├── items/route.ts
│   └── users/route.ts
```

### Route Handlers

```typescript
// app/api/items/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { auth } from '@/lib/auth'

export async function GET(req: NextRequest) {
  const session = await auth()
  if (!session) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  const items = await fetchItemsByUser(session.user.id)
  return NextResponse.json({ items })
}

export async function POST(req: NextRequest) {
  const session = await auth()
  if (!session) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  const body = await req.json()
  const item = await createItem({ ...body, userId: session.user.id })
  return NextResponse.json({ item }, { status: 201 })
}
```

## Data Fetching

### Parallel Data Fetching

```typescript
// WRONG: Sequential (slow)
const user = await getUser(id)
const posts = await getPosts(id)

// CORRECT: Parallel
const [user, posts] = await Promise.all([
  getUser(id),
  getPosts(id)
])
```

### Caching Strategy

```typescript
// No cache (real-time)
export const dynamic = 'force-dynamic'

// Cache indefinitely
export const revalidate = false

// ISR (revalidate every hour)
export const revalidate = 3600
```

## Image Optimization

```tsx
import Image from 'next/image'

// Always specify dimensions
<Image
  src="/logo.png"
  alt="Company logo"
  width={180}
  height={40}
  priority
/>
```

## Environment Variables

```typescript
// Server-side only (never exposed to client)
DATABASE_URL=...

// Client-side (prefixed NEXT_PUBLIC_)
NEXT_PUBLIC_API_URL=https://api.example.com
```

## Error Handling

### API Route Errors

```typescript
export async function GET() {
  try {
    const data = await fetchData()
    return NextResponse.json({ data })
  } catch (error) {
    console.error('GET /api/items error:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}
```

### Client Error Boundaries

```tsx
'use client'
import { Component, type ReactNode } from 'react'

interface Props {
  children: ReactNode
  fallback: ReactNode
}

interface State {
  hasError: boolean
}

export class ErrorBoundary extends Component<Props, State> {
  state: State = { hasError: false }

  static getDerivedStateFromError(): State {
    return { hasError: true }
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback
    }
    return this.props.children
  }
}
```

## Performance

### Dynamic Imports (Reduce Bundle)

```tsx
import dynamic from 'next/dynamic'

const HeavyChart = dynamic(() => import('@/components/HeavyChart'), {
  loading: () => <Skeleton />,
  ssr: false
})
```

### Metadata

```typescript
import { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'App Name',
  description: 'Application description',
  openGraph: {
    title: 'App Name',
    images: ['/og-image.png']
  }
}
```
