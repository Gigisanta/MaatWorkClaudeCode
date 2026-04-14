---
name: test
description: Run tests with automatic framework detection and coverage reporting
scopes:
  - unit
  - integration
  - e2e
  - all
  - changed
---

# Test Command

Automatically detects the testing framework and executes tests with coverage reporting.

## Usage

```
/test [scope] [options]
```

**scope** (optional): Test scope to run. Defaults to `all`.

## Supported Scopes

| Scope | Description |
|-------|-------------|
| `unit` | Unit tests only |
| `integration` | Integration tests only |
| `e2e` | End-to-end tests only |
| `all` | All tests (unit + integration + e2e) |
| `changed` | Tests for changed files only |

## Automatic Framework Detection

| Project Type | Testing Framework |
|-------------|-------------------|
| Node.js | Jest, Mocha, Vitest, Jasmine |
| Go | go test, testify |
| Rust | cargo test |
| Python | pytest, unittest, nose2 |
| Java | JUnit, TestNG |

## Project-Specific Test Commands

### Node.js

```bash
# All tests
npm test / yarn test / pnpm test

# Unit tests (Jest)
npm test -- --testPathPattern=unit
npx jest --coverage

# Integration tests
npm run test:integration

# E2E tests
npm run test:e2e

# Changed files
npx jest --onlyChanged

# Coverage (80% minimum)
npx jest --coverage --coverageThreshold='{"global":{"statements":80}}'
```

### Go

```bash
# All tests
go test ./...

# Unit tests
go test -short ./...

# Integration tests
go test -tags=integration ./...

# E2E tests
go test -tags=e2e ./...

# Changed files
git diff --name-only HEAD~1 | grep '_test.go' | xargs go test

# Coverage
go test -coverprofile=coverage.out ./...
go tool cover -func=coverage.out
```

### Rust

```bash
# All tests
cargo test

# Unit tests
cargo test --lib

# Integration tests
cargo test --test '*'

# E2E tests
cargo test --test '*' -- --ignored

# Changed files
git diff --name-only HEAD~1 | grep '_test' | xargs -I{} dirname {} | uniq | xargs cargo test

# Coverage (tarpaulin)
cargo tarpaulin --out xml --out html
```

### Python

```bash
# All tests
pytest

# Unit tests
pytest tests/unit/

# Integration tests
pytest tests/integration/

# E2E tests
pytest tests/e2e/

# Changed files
pytest --changed-files

# Coverage (80% minimum)
pytest --cov=. --cov-report=term --cov-fail-under=80
```

### Java (JUnit)

```bash
# All tests
mvn test / ./gradle test

# Unit tests
mvn test -Dtest='*Test' -DfailIfNoTests=false

# Integration tests
mvn verify -Dintegration

# E2E tests
mvn verify -De2e

# Coverage (JaCoCo)
mvn test jacoco:report
./gradle test jacocoTestReport
```

## Coverage Requirements

**Minimum coverage: 80%**

The test command will fail if coverage falls below 80% for:
- Statements
- Branches
- Functions
- Lines

## TDD Integration

This command integrates with the `tdd-guide` workflow:

1. Write failing test first (RED)
2. Run test - should fail
3. Implement minimal code (GREEN)
4. Run test - should pass
5. Refactor (IMPROVE)
6. Verify coverage >= 80%

## Exit Codes

- `0`: All tests passed with >= 80% coverage
- `1`: Tests failed
- `2`: Coverage below 80%
- `3`: Project type not detected
- `4`: Invalid scope specified

## Examples

```
/test unit              # Run unit tests only
/test integration       # Run integration tests only
/test e2e               # Run e2e tests only
/test all               # Run all tests
/test changed           # Run tests for changed files
/test unit --coverage   # Run unit tests with coverage
```
