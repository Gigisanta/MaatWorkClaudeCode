---
description: Structured debugging workflow using Triage → Analysis → Solution → Prevention
allowed-tools: [Read, Bash, Grep, Glob, mcp__plugin_chrome-devtools-mcp_chrome-devtools__take_snapshot, mcp__plugin_chrome-devtools-mcp_chrome-devtools__list_network_requests, mcp__plugin_chrome-devtools-mcp_chrome-devtools__evaluate_script, mcp__plugin_chrome-devtools-mcp_chrome-devtools__get_console_message]
argument-hint: [crash] [logic-error] [performance] [network]
---

# Debug Command

Structured debugging workflow following the `systematic-debugging` skill methodology.

## Debugging Types Supported

| Type | Description | Tools |
|------|-------------|-------|
| `crash` | Application crashes, segfaults, panics | Logs, stack traces, chrome-devtools |
| `logic-error` | Wrong output, unexpected behavior | Code review, unit tests, breakpoints |
| `performance` | Slow execution, high memory/CPU | Profiling, chrome-devtools Lighthouse |
| `network` | API failures, timeout, connectivity | Network logs, fetch debugging |

## Workflow

### Phase 1: TRIAGE

**Goal:** Identify the problem type and scope

1. **Gather Initial Information:**
   - Error message or unexpected behavior?
   - When does it occur (user action, load, specific input)?
   - Can it be reproduced consistently?

2. **Check Error Logs:**
   ```bash
   # Application logs
   tail -100 logs/app.log | grep -i error

   # System logs
   dmesg | tail -50
   ```

3. **Identify Problem Type:**
   - Crash → Collect stack trace
   - Logic error → Find where behavior diverges
   - Performance → Measure baseline metrics
   - Network → Check request/response cycle

### Phase 2: ANALYSIS

**Goal:** Understand root cause

1. **Web/DOM Issues (chrome-devtools-mcp):**
   ```bash
   # Take page snapshot to see current state
   chrome-devtools take_snapshot

   # List network requests
   chrome-devtools list_network_requests

   # Check console messages
   chrome-devtools list_console_messages

   # Evaluate script to extract data
   chrome-devtools evaluate_script "() => performance.memory"
   ```

2. **Code Analysis:**
   - Read relevant source files
   - Trace data flow from input to output
   - Identify mutation points (should be immutable!)

3. **Hypothesis Formation:**
   - What is the most likely cause?
   - What evidence supports this?
   - What other possibilities exist?

### Phase 3: SOLUTION

**Goal:** Fix the root cause

1. **Implement Fix:**
   - Minimal change to address root cause
   - Do not mutate existing data structures
   - Add proper error handling

2. **Verify Fix:**
   ```bash
   # Run relevant tests
   npm test <test-file>

   # Replicate scenario
   <reproduction-steps>
   ```

3. **Regression Check:**
   - Ensure existing functionality still works
   - Run full test suite if available

### Phase 4: PREVENTION

**Goal:** Prevent future occurrences

1. **Add Test Case:**
   - Write test that reproduces the bug
   - Ensure test fails before fix
   - Ensure test passes after fix

2. **Document Learning:**
   - Update comments/code documentation
   - Note edge cases discovered
   - Add to project's debugging knowledge base

## Chrome DevTools Integration

For web debugging, use the chrome-devtools-mcp:

```bash
# Get current page snapshot
chrome-devtools take_snapshot

# Analyze network requests for failures
chrome-devtools list_network_requests

# Check JavaScript console for errors
chrome-devtools list_console_messages

# Evaluate custom script for debugging
chrome-devtools evaluate_script "() => { /* debug logic */ }"

# Get network request details
chrome-devtools get_network_request <reqid>
```

## Usage

```
/debug                          # Interactive: guide through phases
/debug crash                    # Focus on crash debugging
/debug logic-error             # Focus on logic/error debugging
/debug performance             # Focus on performance issues
/debug network                 # Focus on network/API issues
```

## Example Session: Logic Error

```
User: /debug logic-error

Agent: # Phase 1: TRIAGE

What is the unexpected behavior?
> Login returns success but user data is null

When does it occur?
> After OAuth login flow completes

Can you reproduce it?
> Yes, every time with Google OAuth

Agent: # Phase 2: ANALYSIS

Checking network requests...
chrome-devtools list_network_requests

Found: POST /api/auth/callback returned 200
Expected user data missing in response

Checking source code...
src/auth/oauth.ts - Line 45:
  user = parseUser(response)  // MUTATION! Should return new object
```

## Integration

- Uses `systematic-debugging` skill for methodology
- Uses `rules/common/patterns.md` for repository pattern
- Chrome DevTools MCP for web debugging
- Integrates with `tdd` command for regression tests
