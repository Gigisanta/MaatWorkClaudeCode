---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
---
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
import { render, screen, fireEvent } from '@testing-library/react'
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

describe('POST /api/deals', () => {
  it('should create deal and return 201', async () => {
    const payload = generatePayload({ name: 'Test Deal' })
    const response = await POST(new Request('http://localhost', {
      method: 'POST',
      body: JSON.stringify(payload),
      headers: { 'Content-Type': 'application/json' }
    }))

    expect(response.status).toBe(201)
    const data = await response.json()
    expect(data.deal).toMatchObject({ name: 'Test Deal' })
  })
})
```

### Database Tests (Prisma)

```typescript
import { describe, it, expect, beforeEach } from 'vitest'
import { db } from '@/lib/db'

describe('Deal operations', () => {
  beforeEach(async () => {
    await db.deal.deleteMany()
  })

  it('should create a deal with stage', async () => {
    const deal = await db.deal.create({
      data: {
        name: 'Test',
        stage: 'PROSPECTO',
        userId: 'user-1'
      }
    })
    expect(deal.stage).toBe('PROSPECTO')
  })
})
```

## E2E Testing (Playwright)

### Page Objects

```typescript
import { test, expect, Page } from '@playwright/test'

export class DealPage {
  constructor(private page: Page) {}

  async createDeal(name: string) {
    await this.page.getByRole('button', { name: /new deal/i }).click()
    await this.page.getByLabel(/deal name/i).fill(name)
    await this.page.getByRole('button', { name: /save/i }).click()
  }

  async gotoPipeline() {
    await this.page.goto('/pipeline')
  }
}

test('should create deal through pipeline', async ({ page }) => {
  const dealPage = new DealPage(page)
  await dealPage.gotoPipeline()
  await dealPage.createDeal('Enterprise Deal')
  await expect(page.getByText('Enterprise Deal')).toBeVisible()
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

export async function createTestUser(db: PrismaClient) {
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
