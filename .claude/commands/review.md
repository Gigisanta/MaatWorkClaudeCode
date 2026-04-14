---
name: review
description: Code review with multiple scopes and structured output
scopes:
  - changed
  - all
  - file
  - diff
  - pr
categories:
  - Critical
  - High
  - Medium
  - Low
---

# Code Review Command

Performs a comprehensive code review with structured output categorized by severity.

## Usage

```
/review [scope] [target]
```

**scope** (optional): Review scope. Defaults to `changed`.
**target** (optional): Specific file path, PR number, or diff spec.

## Supported Scopes

| Scope | Description |
|-------|-------------|
| `changed` | Review only files changed since last commit/branch |
| `all` | Review entire codebase |
| `file` | Review specific file(s) |
| `diff` | Review a diff (accepts git diff format) |
| `pr` | Review a pull request by number |

## Issue Categories

### Critical
- Security vulnerabilities (SQL injection, XSS, hardcoded secrets)
- Data loss risks
- Authentication/authorization bypasses
- Severe performance issues

### High
- Memory leaks
- Unhandled edge cases
- Missing error handling
- Inefficient algorithms

### Medium
- Code smells
- Suboptimal patterns
- Missing documentation
- Inconsistent naming

### Low
- Style violations
- Minor inefficiencies
- Cosmetic issues

## Language-Specific Rules

### Node.js / TypeScript
- No `any` types
- Proper error handling with custom error classes
- Async/await over raw promises
- Input validation on all public functions
- No hardcoded values (use constants)
- Security: no `eval()`, sanitize user input

### Go
- Error handling on every call
- Context propagation (`context.Context`)
- No goroutine leaks
- Proper mutex usage
- Input validation

### Rust
- No `unsafe` blocks without documentation
- Proper `Result` handling
- No panics in production code
- `Clone()` usage documented
- Lifetimes properly annotated

### Python
- Type hints on public APIs
- No wildcard imports (`from module import *`)
- Proper exception handling
- Docstrings on modules/classes/methods
- Security: no `eval()`, pickle handling

### Java
- No raw types (generics required)
- Resource cleanup (try-with-resources)
- Null handling
- Immutable patterns preferred
- Input validation

## Output Format

```markdown
# Code Review Report

**Scope:** [changed|all|file|diff|pr]
**Target:** [files/PR/diff]
**Date:** YYYY-MM-DD HH:MM

## Summary
- Critical: N
- High: N
- Medium: N
- Low: N
- **Total Issues:** N

## Critical Issues

### 1. [Issue Title]
**File:** `path/to/file`
**Line:** N
**Severity:** Critical

**Description:**
[Detailed description of the issue]

**Recommendation:**
[How to fix the issue]

---

## High Issues
[...]

## Medium Issues
[...]

## Low Issues
[...]
```

## Examples

```
/review changed           # Review changed files only
/review all               # Review entire codebase
/review file src/utils.js # Review specific file
/review diff HEAD~1       # Review diff from last commit
/review pr 123            # Review PR #123
```

## Integration with tdd-guide

The review command works best after:
1. Implementing a feature with TDD
2. Running `/test` to verify tests pass
3. Running `/review changed` to catch issues

## Exit Codes

- `0`: Review complete (issues found, none critical)
- `1`: Review complete with critical/high issues
- `2`: Scope not recognized
- `3`: Target not found

## Notes

- Reviews are static analysis based
- For runtime bugs, use systematic-debugging skill
- Security issues should use security-reviewer agent
- Complex architectural issues should use architect agent
