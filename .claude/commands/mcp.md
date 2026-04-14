---
name: mcp
description: List and manage MCP (Model Context Protocol) servers
---

# MCP Server Management

List all configured MCP servers and their status.

## Usage

```
/mcp
/mcp list
/mcp add <name> <commandOrUrl> [args...]
/mcp remove <name>
/mcp health
```

## Available MCP Servers

These MCP servers are currently configured:

| Server | Type | Status |
|--------|------|--------|
| brave-search | stdio | ✓ Connected |
| context7 | HTTP | ✓ Connected |
| vercel | HTTP | ✓ Connected |
| chrome-devtools-mcp | stdio | ✓ Connected |

## Health Check

Run `/mcp` or `/mcp list` to see live health status of all servers.

## Adding Servers

```bash
# Add HTTP MCP server
/mcp add sentry --transport http https://mcp.sentry.dev/mcp

# Add stdio server with npx
/mcp add my-server -- npx -y my-mcp-server

# Add with environment variables
/mcp add -e API_KEY=xxx my-server -- npx -y my-mcp-server
```

## Removing Servers

```bash
/mcp remove <name>
```

## Configuration

MCP servers are configured in:
- Global: `~/.claude/settings.json` → `enabledMcpjsonServers`
- Project: `/.claude.json` → `projects.{path}.mcpServers`
