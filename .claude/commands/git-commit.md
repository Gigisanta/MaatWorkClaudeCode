---
description: Analyze changes and create conventional commit messages
allowed-tools: [Read, Bash(git status), Bash(git diff), Bash(git log), Grep, Glob]
argument-hint: [type?] [message?]
---

# Git Commit Command

Create conventional commits following `rules/common/git-workflow.md` format.

## Commit Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code refactoring |
| `docs` | Documentation changes |
| `test` | Test updates |
| `chore` | Maintenance tasks |
| `perf` | Performance improvements |
| `ci` | CI/CD changes |

## Workflow

### 1. Check Status

Run `git status` to see changed files and `git diff` to review changes.

### 2. Analyze Changes

For each changed file, determine:
- What type of change is it?
- What is the scope (file/component)?
- What does it do?

### 3. Generate Commit Message

Format: `<type>: <description>`

- Use imperative mood ("add feature" not "added feature")
- Keep subject line under 72 characters
- Reference issues when applicable

### 4. Safety Checks

**Protected Branches Warning:**
- Warn before committing to `main`, `master`, `production`
- Suggest creating a feature branch instead

**Pre-Commit Validation:**
- No hardcoded secrets (API keys, passwords, tokens)
- All user inputs validated
- Proper error handling in place

### 5. Confirmation

Confirm with user before executing `git commit`.

## Usage

```
/git-commit                    # Interactive: analyze changes and prompt for type/message
/git-commit feat "add login"   # Direct: create commit with type and message
/git-commit fix "null pointer"  # Direct: bug fix commit
```

## Example Session

```
Agent: Analyzing changes...

Changed files:
- src/auth/login.ts (new feature)
- src/auth/login.test.ts (tests)
- src/utils/validation.ts (refactor)

Changes summary:
- login.ts: Add OAuth2 login flow with JWT tokens
- login.test.ts: Add unit tests for login flow
- validation.ts: Extract validation to reusable utils

Suggested commit:
feat: add OAuth2 login with JWT support

Full commit message:
feat: add OAuth2 login with JWT support

- Implement OAuth2 authentication flow
- Add JWT token generation and validation
- Include unit tests for login flow
- Extract validation logic to shared utils

Proceed with commit? (y/n)
```

## Implementation

```bash
# Get status and diff
git status --short
git diff --stat

# Check for protected branch
PROTECTED_BRANCHES="main master production"
CURRENT_BRANCH=$(git branch --show-current)

if [[ " $PROTECTED_BRANCHES " =~ " $CURRENT_BRANCH " ]]; then
  echo "WARNING: Committing directly to protected branch '$CURRENT_BRANCH'"
  echo "Consider creating a feature branch instead."
fi

# Create commit
git add <files>
git commit -m "<type>: <description>"
```

## Integration

- References `rules/common/git-workflow.md` for commit format
- Uses `rules/common/security.md` for pre-commit security checks
- Integrates with `code-review` command for pre-commit review
