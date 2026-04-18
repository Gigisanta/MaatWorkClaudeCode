# Next.js Testing

> This file extends [typescript/testing.md](../typescript/testing.md) with Next.js specific content.

## Vitest Configuration

```typescript
// vitest.config.mts
import { defineConfig } from 'vitest/config'
import tsconfigPaths from 'vite-tsconfig-paths'

export default defineConfig({
  plugins: [tsconfigPaths()],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./tests/setup.ts'],
    include: ['**/*.test.{ts,tsx}'],
    exclude: ['node_modules', '.next', 'playwright.config.ts']
  }
})
```

## Setup File

```typescript
// tests/setup.ts
import '@testing-library/jest-dom'
import { cleanup } from '@testing-library/react'
import { afterEach } from 'vitest'

afterEach(() => {
  cleanup()
})
```

## Testing API Routes

```typescript
// tests/api/items.test.ts
import { describe, it, expect } from 'vitest'
import { GET, POST } from '@/app/api/items/route'

describe('GET /api/items', () => {
  it('should return items for authenticated user', async () => {
    const request = new Request('http://localhost/api/items', {
      headers: { Cookie: 'session=valid-session-token' }
    })
    const response = await GET(request)
    expect(response.status).toBe(200)
  })

  it('should return 401 for unauthenticated', async () => {
    const request = new Request('http://localhost/api/items')
    const response = await GET(request)
    expect(response.status).toBe(401)
  })
})
```

## Testing Server Actions

```typescript
// app/actions/items.test.ts
import { describe, it, expect } from 'vitest'
import { createItem } from './items'

describe('createItem', () => {
  it('should create an item with proper data', async () => {
    const item = await createItem({
      name: 'Test Item',
      userId: 'user-1'
    })

    expect(item).toMatchObject({
      name: 'Test Item'
    })
  })
})
```

## Testing Components

```typescript
// components/ItemList.test.tsx
import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import { ItemList } from './ItemList'

describe('ItemList', () => {
  it('should render empty state', () => {
    render(<ItemList items={[]} />)
    expect(screen.getByText(/no items/i)).toBeInTheDocument()
  })

  it('should render item list', () => {
    const items = [
      { id: '1', name: 'Item 1' },
      { id: '2', name: 'Item 2' }
    ]
    render(<ItemList items={items} />)
    expect(screen.getByText('Item 1')).toBeInTheDocument()
    expect(screen.getByText('Item 2')).toBeInTheDocument()
  })
})
```

## Testing Forms

```typescript
import { describe, it, expect, vi } from 'vitest'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { ItemForm } from './ItemForm'

describe('ItemForm', () => {
  it('should validate required fields', async () => {
    const user = userEvent.setup()
    render(<ItemForm />)

    await user.click(screen.getByRole('button', { name: /save/i }))
    expect(screen.getByText(/name is required/i)).toBeInTheDocument()
  })

  it('should submit with valid data', async () => {
    const user = userEvent.setup()
    const onSubmit = vi.fn()
    render(<ItemForm onSubmit={onSubmit} />)

    await user.type(screen.getByLabel(/name/i), 'Test Item')
    await user.click(screen.getByRole('button', { name: /save/i }))

    expect(onSubmit).toHaveBeenCalledWith(
      expect.objectContaining({ name: 'Test Item' })
    )
  })
})
```

## Mocking Next.js Modules

```typescript
import { vi } from 'vitest'

// Mock next/navigation
vi.mock('next/navigation', () => ({
  useRouter: () => ({
    push: vi.fn(),
    replace: vi.fn(),
    refresh: vi.fn()
  }),
  usePathname: () => '/items'
}))

// Mock next/image
vi.mock('next/image', () => ({
  default: (props: ImageProps) => <img {...props} />
}))

// Mock server-only modules
vi.mock('@/lib/db', () => ({
  db: {
    item: {
      findMany: vi.fn().mockResolvedValue([])
    }
  }
}))
```

## Coverage for Next.js

```bash
# Required: 80% minimum
vitest run --coverage --coverageThreshold='{"global":{"statements":80,"branches":80,"functions":80,"lines":80}}'
```
