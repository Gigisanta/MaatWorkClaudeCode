---
paths:
  - "**/*.rs"
  - "**/Cargo.toml"
  - "**/Cargo.lock"
---
# Rust Testing

> This file extends [common/testing.md](../common/testing.md) with Rust specific content.

## Framework

Use **built-in test module** with `#[cfg(test)]` and `cargo test`.

## Test Organization

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_something() {
        assert_eq!(2 + 2, 4);
    }
}
```

## Test Categories

1. **Unit tests**: Inside each module with `#[cfg(test)]`
2. **Integration tests**: In `tests/` directory
3. **Doc tests**: Inline with `///` comments

## Coverage

```bash
cargo test
cargo tarpaulin --output --exclude-files benches/*
```

## Reference

See skill: `rust-testing` for detailed Rust testing patterns including property-based testing and benchmarks.