---
name: mcp-server-patterns
description: Build MCP servers with Node/TypeScript SDK — tools, resources, prompts, Zod validation, stdio vs Streamable HTTP. Use Context7 or official MCP docs for latest API. Pin @modelcontextprotocol/sdk version in package.json.
---

# MCP Server Patterns

The Model Context Protocol (MCP) lets AI assistants call tools, read resources, and use prompts from your server. Use this skill when building or maintaining MCP servers.

## When to Use

Use when: implementing a new MCP server, adding tools or resources, choosing stdio vs HTTP, upgrading the SDK, or debugging MCP registration and transport issues.

## How It Works

### Core concepts

- **Tools**: Actions the model can invoke (e.g. search, run a command). Registered via `server.tool()`.
- **Resources**: Read-only data the model can fetch (e.g. file contents, API responses). Registered via `server.resource()`. Handlers receive a `uri` argument.
- **Prompts**: Reusable, parameterised prompt templates the client can surface. Registered via `server.prompt()`.
- **Transport**: stdio for local clients (Claude Desktop); Streamable HTTP for remote (Cursor, cloud).

### SDK Version Pinning (CRITICAL)

**Always pin the SDK version in package.json.** The SDK API changes between versions.

```bash
npm install @modelcontextprotocol/sdk@1.0.0 zod
```

Check the [MCP SDK changelog](https://github.com/modelcontextprotocol/typescript-sdk/releases) before upgrading.

### Current SDK API (v1.x)

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";

const server = new McpServer({ name: "my-server", version: "1.0.0" });

// Register a tool
server.tool(
  "search",
  "Search for information",
  {
    query: z.string().describe("The search query"),
    limit: z.number().optional().describe("Max results (default 10)")
  },
  async ({ query, limit = 10 }) => {
    const results = await searchApi(query, limit);
    return { content: [{ type: "text", text: JSON.stringify(results) }] };
  }
);

// Register a resource
server.resource(
  "config",
  "Application configuration",
  "config://app",
  async (uri) => ({
    contents: [{ uri, text: await readConfig() }]
  })
);

// Register a prompt
server.prompt(
  "review-code",
  "Review code for issues",
  { code: z.string(), language: z.string().optional() },
  ({ code, language }) => ({
    messages: [{
      role: "user",
      content: { type: "text", text: `Review this ${language ?? "code"}:\n\n${code}` }
    }]
  })
);
```

### Connecting with stdio

```typescript
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const transport = new StdioServerTransport();
await server.connect(transport);
```

### Remote (Streamable HTTP)

```typescript
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamable-http.js";

const transport = new StreamableHTTPServerTransport({ port: 3100 });
await server.connect(transport);
```

## Best Practices

- **Schema first**: Define Zod input schemas for every tool; document parameters and return shape.
- **Errors**: Return structured errors — the model interprets tool results as JSON.
- **Idempotency**: Prefer idempotent tools so retries are safe.
- **Rate and cost**: For tools that call external APIs, consider rate limits and cost.
- **Versioning**: Pin SDK version; check release notes when upgrading.

## Context7 Integration

Use Context7 to verify current SDK API:
```
Library name: MCP (or @modelcontextprotocol/sdk)
```

Query Context7 for "MCP server stdio" or "MCP server Streamable HTTP" to confirm current patterns.

## Reference

- [MCP Specification](https://modelcontextprotocol.io)
- [TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk)
- [Python SDK](https://github.com/modelcontextprotocol/python-sdk)
- [Go SDK](https://github.com/modelcontextprotocol/go-sdk)
