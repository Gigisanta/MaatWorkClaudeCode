---
description: Deploy to dev, staging, prod, or preview environments with checklist and rollback
allowed-tools: [Read, Write, Bash, Grep, Glob, mcp__vercel__deploy_to_vercel, mcp__vercel__get_deployment, mcp__vercel__list_deployments, mcp__vercel__get_runtime_logs]
argument-hint: [dev] [staging] [prod] [preview]
---

# Deploy Command

Deploy applications to various environments with pre-deploy validation and post-deploy notifications.

## Supported Environments

| Environment | Description | Auto-Rollback |
|-------------|-------------|---------------|
| `dev` | Development environment | No |
| `staging` | Pre-production testing | Yes |
| `prod` | Production environment | Yes |
| `preview` | Preview deployments | No |

## Pre-Deploy Checklist

Complete before any deployment:

### 1. Build Verification

```bash
# Run build
npm run build

# Verify build output exists
ls -la dist/
```

### 2. Test Suite

```bash
# Run unit tests
npm test

# Run integration tests
npm run test:integration

# Check coverage (80% minimum)
npm run test:coverage
```

### 3. Code Review

- All CRITICAL/HIGH issues addressed
- Security scan passed
- No hardcoded secrets

### 4. Review Changes

- `git log` since last deploy
- Verify only intended changes included
- Check migration scripts if applicable

## Deployment Workflow

### Standard Deploy

1. **Confirm Environment:**
   ```
   /deploy staging
   ```

2. **Run Pre-Deploy Checklist:**
   - Verify build passes
   - Verify tests pass (80%+ coverage)
   - Verify no security issues

3. **Execute Deploy:**
   ```bash
   # For Vercel
   vercel deploy --env <environment>

   # For Docker
   docker-compose up -d
   ```

4. **Post-Deploy Verification:**
   - Health check endpoint
   - Basic smoke test
   - Verify logs

### Preview Deploy

1. Create preview URL for PR/branch
2. Run automated tests against preview
3. Notify team with preview link

### Rollback (Production/Staging)

If deployment fails or health checks fail:

1. **Automatic Rollback:**
   ```bash
   # Vercel handles this automatically
   vercel rollback <deployment-id>
   ```

2. **Manual Rollback:**
   ```bash
   # Revert to previous deployment
   vercel rollback

   # Or redeploy previous commit
   git revert HEAD
   git push
   ```

## Vercel MCP Integration

When `vercel` MCP is available, use:

```bash
# Deploy current project
vercel deploy

# Get deployment status
vercel get_deployment <id-or-url>

# List recent deployments
vercel list_deployments --project <project-id>

# Get runtime logs
vercel get_runtime_logs --project <project-id> --deployment <id>
```

## Post-Deploy Notifications

After successful deployment:

### Format

```
[DEPLOY] <environment> deployed successfully

Project: <project-name>
Environment: <environment>
URL: <deployment-url>
Commit: <commit-hash>
Deployed by: <user>

Changes:
- <change 1>
- <change 2>
```

### Notification Channels

- Slack webhook (if configured)
- Email to team (if critical)
- Dashboard update

## Rollback Procedure

If issues detected post-deploy:

1. **Immediate Rollback:**
   ```bash
   # Vercel
   vercel rollback

   # Docker
   docker-compose down
   docker-compose up -d <previous-version>
   ```

2. **Investigation:**
   - Check runtime logs
   - Review error traces
   - Identify root cause

3. **Fix and Re-Deploy:**
   - Apply fix
   - Run full checklist
   - Deploy to staging first
   - Deploy to production

## Usage

```
/deploy                      # Interactive: select environment and walk through checklist
/deploy dev                 # Deploy to development
/deploy staging             # Deploy to staging with rollback
/deploy prod                # Deploy to production with rollback
/deploy preview             # Create preview deployment for PR
```

## Example Session

```
Agent: # Pre-Deploy Checklist for Staging

1. Build Verification:
   > npm run build
   ✓ Build passed (45s)

2. Test Suite:
   > npm test
   ✓ All tests passed (23 tests)

   > npm run test:coverage
   ✓ Coverage: 87% (target: 80%)

3. Code Review:
   ✓ No CRITICAL/HIGH issues
   ✓ Security scan passed

4. Review Changes:
   > git log --oneline -5
   - abc1234 feat: add user dashboard
   - def5678 fix: resolve login timeout

   Ready to deploy to staging?

User: yes

Agent: # Deploying to Staging...

vercel deploy --environment staging

Deployment successful!
URL: https://myapp-staging.vercel.app

Running post-deploy smoke tests...
✓ Health check passed
✓ API endpoint responding

# Post-Deploy Notification

[DEPLOY] staging deployed successfully

Project: myapp
Environment: staging
URL: https://myapp-staging.vercel.app
Commit: abc1234
Deployed by: developer@company.com
```

## Integration

- Uses `vercel` MCP for Vercel deployments
- References `rules/common/git-workflow.md` for commit format
- Uses `rules/common/testing.md` for test requirements
- Integrates with `code-review` for pre-deploy review
