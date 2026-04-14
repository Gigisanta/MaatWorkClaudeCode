---
paths:
  - "**/*.rs"
  - "**/Cargo.toml"
  - "**/Cargo.lock"
---
# Rust Security

> This file extends [common/security.md](../common/security.md) with Rust specific content.

## Secret Management

```rust
// NEVER: Hardcoded secrets
let api_key = "sk-proj-xxxxx";

// ALWAYS: Environment variables
let api_key = env::var("OPENAI_API_KEY")
    .expect("OPENAI_API_KEY not configured");
```

## Security Scanning

- Use **cargo-audit** for dependency vulnerability scanning:
  ```bash
  cargo audit
  ```
- Use **cargo-audit** with **cargo-deny** for comprehensive supply chain security:
  ```bash
  cargo deny check advisories
  ```

## Unsafe Code

- Minimize `unsafe` blocks; isolate them in dedicated modules
- Document safety invariants in unsafe code
- Review unsafe code with security-reviewer agent

## Memory Safety

- Leverage Rust's ownership model; avoid manual memory management
- Use `unsafe` only when necessary for FFI or performance

## Reference

See skill: `rust-review` for Rust-specific security considerations.