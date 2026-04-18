# Next.js Hooks

> This file extends [common/hooks.md](../common/hooks.md) with Next.js specific content.

## Next.js Hook Events

```json
{
  "PreToolUse": [
    {
      "matcher": "Bash",
      "hooks": [
        {
          "type": "command",
          "command": "echo 'Checking Next.js dev server...'",
          "description": "Notify about Next.js context"
        }
      ]
    }
  ]
}
```

## PostToolUse Hooks for Next.js

### Auto-revalidate After DB Changes

```typescript
// hooks/post-db-change.ts
import { revalidatePath, revalidateTag } from 'next/cache'

export function revalidateAfterDbChange(model: string) {
  switch (model) {
    case 'deal':
      revalidatePath('/pipeline')
      revalidatePath('/contacts')
      revalidateTag('deals')
      break
    case 'contact':
      revalidatePath('/contacts')
      revalidateTag('contacts')
      break
  }
}
```

## Useful Hook Patterns

### Type-safe Environment Variables

```typescript
// hooks/validate-env.ts
export function validateEnv() {
  const required = ['DATABASE_URL', 'JWT_SECRET']
  for (const key of required) {
    if (!process.env[key]) {
      throw new Error(`Missing required env: ${key}`)
    }
  }
}
```

## Build-related Hooks

```bash
# Pre-build validation
"prebuild": "tsc --noEmit && prisma generate"

# Post-build hook
"postbuild": "echo 'Build complete - run tests before deploy'"
```
