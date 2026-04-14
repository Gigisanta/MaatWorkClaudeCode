---
paths:
  - "**/*.rs"
  - "**/Cargo.toml"
  - "**/Cargo.lock"
---
# Rust Hooks

> This file extends [common/hooks.md](../common/hooks.md) with Rust specific content.

## PostToolUse Hooks

Configure in `~/.claude/settings.json`:

- **rustfmt**: Auto-format `.rs` files after edit
- **cargo check**: Run type checking after editing `.rs` files
- **clippy**: Run linting with `cargo clippy --fix` for suggestions

## Stop Hooks

- **Cargo audit**: Check for vulnerable dependencies before session ends:
  ```bash
  cargo audit
  ```