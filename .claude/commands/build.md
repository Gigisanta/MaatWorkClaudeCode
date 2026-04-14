---
name: build
description: Build and compile the project with automatic project detection
targets:
  - dev
  - prod
  - test
  - lint
  - typecheck
  - all
---

# Build Command

Automatically detects the project type (Node/Go/Rust/Python/Java) and executes the appropriate build process.

## Usage

```
/build [target]
```

**target** (optional): The build target to execute. Defaults to `dev`.

## Supported Targets

| Target | Description |
|--------|-------------|
| `dev` | Development build with watch mode and hot reload |
| `prod` | Production build with optimizations and minification |
| `test` | Build for test environment |
| `lint` | Run linters only (ESLint, golangci-lint, clippy, etc.) |
| `typecheck` | Run type checking only (TypeScript, Go types, Rust borrow checker) |
| `all` | Run lint + typecheck + build in sequence |

## Automatic Project Detection

The build command detects the project type by scanning for characteristic files:

| Project Type | Detection Files |
|-------------|-----------------|
| Node.js | `package.json`, `node_modules/` |
| Go | `go.mod`, `*.go` files |
| Rust | `Cargo.toml`, `Cargo.lock` |
| Python | `requirements.txt`, `setup.py`, `pyproject.toml` |
| Java | `pom.xml` (Maven), `build.gradle` (Gradle) |

## Project-Specific Build Commands

### Node.js
```bash
# Development
npm run dev / yarn dev / pnpm dev

# Production
npm run build / yarn build / pnpm build

# With watch mode
npm run dev -- --watch

# Lint
npm run lint / yarn lint

# Type check
npm run typecheck / npx tsc --noEmit
```

### Go
```bash
# Development
go run .

# Production
go build -o app .

# With watch mode
reflex -s -r '\.go$' -R '*.mod' -d .

# Lint
golangci-lint run

# Type check
go vet ./...
```

### Rust
```bash
# Development
cargo build

# Production
cargo build --release

# With watch mode
cargo watch -x build -x test

# Lint
cargo clippy -- -D warnings

# Type check
cargo check
```

### Python
```bash
# Development
python -m your_package

# Production
python -m py_compile your_package/

# Lint
ruff check .
pylint your_package/

# Type check
mypy your_package/
```

### Java (Maven)
```bash
# Development
mvn compile

# Production
mvn package -DskipTests

# With watch mode
mvn compile -o 2>/dev/null || mvn compile

# Lint
mvn checkstyle:checkstyle

# Type check
mvn compiler:compile
```

### Java (Gradle)
```bash
# Development
./gradle compileJava

# Production
./gradle build -x test

# With watch mode
./gradle compileJava --continuous

# Lint
./gradle checkstyleMain

# Type check
./gradle compileJava
```

## Examples

```
/build dev          # Run development build
/build prod         # Run production build
/build lint         # Run linters only
/build typecheck    # Run type checker only
/build all          # Run all checks and build
```

## Exit Codes

- `0`: Build successful
- `1`: Build failed
- `2`: Project type not detected
- `3`: Invalid target specified
