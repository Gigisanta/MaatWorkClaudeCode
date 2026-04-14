---
paths:
  - "**/*.rs"
  - "**/Cargo.toml"
  - "**/Cargo.lock"
---
# Rust Coding Style

> This file extends [common/coding-style.md](../common/coding-style.md) with Rust specific content.

## Formatting

- **rustfmt** is mandatory — no style debates
- Run `cargo fmt` before committing

## Ownership and Borrowing

- Follow ownership rules strictly; avoid `unsafe` unless necessary
- Prefer borrowing over cloning when possible
- Use `&mut` only when modification is required

## Error Handling

Use `Result<T, E>` for fallible operations and `?` for error propagation:

```rust
fn read_config(path: &Path) -> Result<Config, io::Error> {
    let content = fs::read_to_string(path)?;
    serde_json::from_str(&content).map_err(|e| io::Error::new(io::ErrorKind::InvalidData, e))
}
```

## Immutability

Prefer immutable data structures:

```rust
// WRONG: Mutable variable
let mut config = Config::new();
config.port = 8080;

// CORRECT: Immutable with builder pattern
let config = Config::builder()
    .port(8080)
    .build();
```

## Crate Organization

- Keep modules small (<800 lines)
- Use `mod.rs` for module grouping
- Separate public API (`lib.rs`) from implementation

## Reference

See skill: `rust-patterns` for comprehensive Rust idioms and patterns.