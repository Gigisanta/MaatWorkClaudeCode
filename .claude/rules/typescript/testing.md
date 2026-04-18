# TypeScript/JavaScript Testing

> This file extends [common/testing.md](../common/testing.md) with TypeScript/JavaScript specific content.

## Framework

Use **Vitest** as the primary test framework for TypeScript projects.

## Test Structure

### File Organization

```
tests/
├── unit/           # Unit tests (co-located with source or in tests/unit/)
├── integration/    # API and DB integration tests
└── e2e/           # Playwright E2E tests (tests/e2e/)
```

### Naming Conventions

- Files: `*.test.ts` or `*.spec.ts`
- Test functions: `describe('UnitName')`, `it('should do something')`
- Co-located tests: `ComponentName.test.tsx` next to `ComponentName.tsx`

## Unit Testing

### React Components (Testing Library)

```typescript
import { render, screen } from '@testing-library/react'
import { userEvent } from '@testing-library/user-event'

// WRONG: Implementation detail testing
const button = container.querySelector('.submit-btn')

// CORRECT: Behavior testing
render(<UserForm onSubmit={mockSubmit} />)
await userEvent.click(screen.getByRole('button', { name: /submit/i }))
expect(mockSubmit).toHaveBeenCalledWith(expectedData)
```

### Hooks Testing

```typescript
import { renderHook, act } from '@testing-library/react'
import { useCounter } from './useCounter'

it('should increment', () => {
  const { result } = renderHook(() => useCounter())
  act(() => result.current.increment())
  expect(result.current.count).toBe(1)
})
```

### Utilities and Functions

```typescript
import { describe, it, expect } from 'vitest'
import { formatCurrency } from './format'

describe('formatCurrency', () => {
  it('should format USD correctly', () => {
    expect(formatCurrency(1234.56, 'USD')).toBe('$1,234.56')
  })
})
```

## Integration Testing

### API Routes (Next.js)

```typescript
import { describe, it, expect } from 'vitest'
import { POST } from './route'
import { generatePayload } from '@/tests/helpers'

describe('POST /api/items', () => {
  it('should create item and return 201', async () => {
    const payload = generatePayload({ name: 'Test Item' })
    const response = await POST(new Request('http://localhost', {
      method: 'POST',
      body: JSON.stringify(payload),
      headers: { 'Content-Type': 'application/json' }
    }))

    expect(response.status).toBe(201)
    const data = await response.json()
    expect(data.item).toMatchObject({ name: 'Test Item' })
  })
})
```

### Database Tests

```typescript
import { describe, it, expect, beforeEach } from 'vitest'
import { db } from '@/lib/db'

describe('Item operations', () => {
  beforeEach(async () => {
    await db.item.deleteMany()
  })

  it('should create an item', async () => {
    const item = await db.item.create({
      data: {
        name: 'Test',
        quantity: 10,
        userId: 'user-1'
      }
    })
    expect(item.name).toBe('Test')
  })
})
```

## E2E Testing (Playwright)

### Page Objects

```typescript
import { test, expect, Page } from '@playwright/test'

export class ItemPage {
  constructor(private page: Page) {}

  async createItem(name: string) {
    await this.page.getByRole('button', { name: /new item/i }).click()
    await this.page.getByLabel(/item name/i).fill(name)
    await this.page.getByRole('button', { name: /save/i }).click()
  }

  async gotoList() {
    await this.page.goto('/items')
  }
}

test('should create item through list page', async ({ page }) => {
  const itemPage = new ItemPage(page)
  await itemPage.gotoList()
  await itemPage.createItem('Enterprise Item')
  await expect(page.getByText('Enterprise Item')).toBeVisible()
})
```

## Coverage Requirements

**Minimum: 80%** for all TypeScript projects.

```bash
# Run with coverage
vitest run --coverage
vitest run --coverage --coverageThreshold='{"global":{"statements":80}}'
```

## Mocking

### Vitest Mocks

```typescript
import { vi, describe, it, expect } from 'vitest'

// Mock external modules
vi.mock('@/lib/email', () => ({
  sendEmail: vi.fn().mockResolvedValue({ id: 'email-123' })
}))

// Mock fetch
global.fetch = vi.fn().mockResolvedValue({
  ok: true,
  json: async () => ({ success: true })
})
```

### TanStack Query Testing

```typescript
import { renderHook, waitFor } from '@testing-library/react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { useUser } from './useUser'

const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } }
  })
  return ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  )
}

it('should fetch user', async () => {
  const { result } = renderHook(() => useUser('user-1'), { wrapper: createWrapper() })
  await waitFor(() => expect(result.current.isSuccess).toBe(true))
  expect(result.current.data).toMatchObject({ id: 'user-1' })
})
```

## Test Helpers

```typescript
// tests/helpers.ts
export function generatePayload<T>(overrides: Partial<T>): T {
  return {
    id: crypto.randomUUID(),
    createdAt: new Date().toISOString(),
    ...overrides
  } as T
}

export async function createTestUser(db: any) {
  return db.user.create({
    data: {
      email: `test-${Date.now()}@example.com`,
      name: 'Test User'
    }
  })
}
```

## Agent Support

- **e2e-runner** - Playwright E2E testing specialist
- Use `/test changed` to run tests for modified files only
