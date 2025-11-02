# BREATHE.md — Guide for Keepers

This document explains how to use `breathe.sh`, the Auth0 M2M token acquisition and Trinity verification script.

---

## Environment Variables

The script requires the following environment variables to be set:

| Variable | Description | Example |
|----------|-------------|---------|
| `AUTH0_DOMAIN` | Your Auth0 tenant domain | `your-tenant.auth0.com` |
| `AUTH0_CLIENT_ID` | Machine-to-machine application client ID | `abc123...` |
| `AUTH0_CLIENT_SECRET` | Machine-to-machine application client secret | `secret_xyz...` |
| `AUTH0_AUDIENCE` | API audience identifier for your Auth0 API | `https://api.example.com` |
| `TRINITY_API` | Base URL for Trinity verification endpoint | `https://trinity.example.com` |

### Setting Environment Variables

You can set these variables in multiple ways:

**Option 1: Export in your shell**
```bash
export AUTH0_DOMAIN="your-tenant.auth0.com"
export AUTH0_CLIENT_ID="your_client_id"
export AUTH0_CLIENT_SECRET="your_client_secret"
export AUTH0_AUDIENCE="https://api.example.com"
export TRINITY_API="https://trinity.example.com"
```

**Option 2: Use a .env file** (recommended for local development)
```bash
# Create a .env file (already in .gitignore)
cat > .env << 'EOF'
AUTH0_DOMAIN=your-tenant.auth0.com
AUTH0_CLIENT_ID=your_client_id
AUTH0_CLIENT_SECRET=your_client_secret
AUTH0_AUDIENCE=https://api.example.com
TRINITY_API=https://trinity.example.com
EOF

# Source it before running the script
source .env
./breathe.sh
```

**Option 3: Inline with the command**
```bash
AUTH0_DOMAIN="..." AUTH0_CLIENT_ID="..." ./breathe.sh
```

---

## DRY_RUN Mode

The script supports a `DRY_RUN` mode that simulates execution without making actual network calls or writing files.

**When to use DRY_RUN:**
- Testing the script logic without credentials
- Validating environment variable setup
- Understanding the script flow before production use
- CI/CD pipeline testing without side effects

**How to enable:**
```bash
DRY_RUN=1 ./breathe.sh
```

**What DRY_RUN does:**
- ✓ Checks dependencies (curl, jq)
- ✓ Validates environment variables are set
- ✗ Skips Auth0 token acquisition (generates mock token)
- ✗ Skips Trinity verification (uses mock response)
- ✗ Skips agent ping checks (simulates success)
- ✗ Skips token file writing
- ✗ Skips release log writing

All skipped actions are logged with `[DRY RUN]` prefix so you can see what would happen.

---

## How to Run

### Prerequisites
1. **Required:** `curl` must be installed
2. **Recommended:** `jq` for JSON parsing (script works without it but provides better output)

Install jq:
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq

# Alpine
apk add jq
```

### Basic Execution

1. Set your environment variables (see above)
2. Run the script:
```bash
./breathe.sh
```

3. Check the output for success:
```
╔════════════════════════════════════════════════════════════════╗
║                    BREATHE COMPLETE — SEALED                   ║
╚════════════════════════════════════════════════════════════════╝

The Gate breathes. The token is forged. The agents stand ready.
```

### Output Files

After successful execution, you'll find:

- **`m2m-token-YYYYMMDD-HHMMSS.txt`** — The acquired access token (gitignored, do not commit)
- **`breathe-release.log`** — Append-only log of all breathe.sh executions

---

## What the Script Does

1. **Dependency Check** — Verifies `curl` is installed, recommends `jq`
2. **Environment Validation** — Ensures all required variables are set
3. **Token Acquisition** — Calls Auth0's `/oauth/token` endpoint with M2M credentials
4. **Trinity Verification** — Posts token to `${TRINITY_API}/api/verify`
5. **Agent Readiness Check** — Ensures at least 3 agents are ready:
   - Checks `ready: true` flag on each agent, OR
   - Pings each agent's `ping_url` with the acquired token
6. **Token Persistence** — Saves token to timestamped file with 600 permissions
7. **Release Logging** — Records execution metadata in append-only log

---

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success — all checks passed |
| 1 | Missing dependencies or environment variables |
| 2 | Auth0 token acquisition failed |
| 3 | Trinity verification failed |
| 4 | Agent readiness check failed |

---

## Next Steps for Agents

Once `breathe.sh` completes successfully:

1. **Use the Token** — Read the generated `m2m-token-*.txt` file in your automation
2. **Automate Invocation** — Add to CI/CD pipelines, cron jobs, or deployment scripts
3. **Monitor Logs** — Review `breathe-release.log` for ceremony history
4. **Handle Expiration** — Auth0 tokens typically expire; re-run breathe.sh as needed
5. **Extend as Needed** — The script is designed to be modified while preserving ritual

### Example: Using the Token

```bash
# Run breathe.sh to get a fresh token
./breathe.sh

# Find the most recent token file
TOKEN_FILE=$(ls -t m2m-token-*.txt | head -1)
TOKEN=$(cat "$TOKEN_FILE")

# Use in API calls
curl -H "Authorization: Bearer $TOKEN" https://api.example.com/protected
```

### Example: Automated Renewal

```bash
#!/bin/bash
# auto-breathe.sh — Regenerate token if older than 23 hours

LATEST_TOKEN=$(ls -t m2m-token-*.txt 2>/dev/null | head -1)

if [[ -z "$LATEST_TOKEN" ]] || [[ $(find "$LATEST_TOKEN" -mmin +1380 2>/dev/null) ]]; then
    echo "Token expired or missing, acquiring new token..."
    ./breathe.sh
else
    echo "Token still valid: $LATEST_TOKEN"
fi
```

---

## Troubleshooting

**"curl is required but not installed"**
- Install curl: `apt-get install curl` or `brew install curl`

**"Missing required environment variables"**
- Ensure all variables are set in your environment
- Use `echo $AUTH0_DOMAIN` to verify each one

**"Failed to acquire access token"**
- Check your Auth0 credentials are correct
- Verify the M2M application is configured properly in Auth0
- Ensure `AUTH0_AUDIENCE` matches a registered API in Auth0

**"Trinity verification failed"**
- Verify `TRINITY_API` is correct and accessible
- Check Trinity expects `/api/verify` endpoint
- Ensure Trinity is configured to accept tokens from your Auth0 tenant

**"Insufficient agents: found X, require at least 3"**
- Trinity must return at least 3 agents in the response
- Contact Trinity administrators to register more agents

**"Agent X: not ready and no ping_url"**
- Agent must either have `ready: true` or provide a `ping_url`
- Check agent configuration in Trinity

---

*This guide is part of the Basilica Gate canon — where precision meets ceremony.*
