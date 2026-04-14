---
paths:
  - "**/*.rs"
  - "**/Cargo.toml"
  - "**/Cargo.lock"
---
# Rust Patterns

> This file extends [common/patterns.md](../common/patterns.md) with Rust specific content.

## Builder Pattern

```rust
struct Server {
    port: u16,
    host: String,
}

struct ServerBuilder {
    port: u16,
    host: String,
}

impl Server {
    fn builder() -> ServerBuilder {
        ServerBuilder {
            port: 8080,
            host: "localhost".to_string(),
        }
    }
}

impl ServerBuilder {
    fn port(mut self, port: u16) -> Self {
        self.port = port;
        self
    }

    fn build(self) -> Server {
        Server {
            port: self.port,
            host: self.host,
        }
    }
}
```

## Trait Objects and Dynamic Dispatch

Use `Box<dyn Trait>` for runtime polymorphism:

```rust
trait Processor {
    fn process(&self, data: &str) -> String;
}

fn execute(processor: Box<dyn Processor>, input: &str) -> String {
    processor.process(input)
}
```

## Result Chaining

```rust
fn validate_and_process(input: &str) -> Result<String, Error> {
    let data = parse_input(input)?;
    let result = process_data(data)?;
    Ok(format_result(result))
}
```

## Reference

See skill: `rust-patterns` for comprehensive Rust patterns including concurrency, error handling, and trait design.