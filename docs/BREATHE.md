# 🌬️ BREATHE — Agent Awakening Ceremony

> *"The sacred ritual of agent awakening and release preparation."*

---

## Overview

**`breathe.sh`** is the ceremonial orchestration script for Basilica Gate that prepares the environment for agent deployment. It handles authentication, service verification, and readiness checks with mythic precision.

## Environment Variables

### Required Variables

Before invoking the Breathe ceremony, ensure these sacred seals are set:

| Variable | Description | Example |
|----------|-------------|---------|
| `AUTH0_DOMAIN` | Your Auth0 tenant domain | `kypria.auth0.com` |
| `AUTH0_CLIENT_ID` | M2M application client ID | `abc123xyz...` |
| `AUTH0_CLIENT_SECRET` | M2M application client secret | `secret_value` |
| `AUTH0_AUDIENCE` | API identifier/audience | `https://api.kypria.io` |

### Optional Variables

Customize the ceremony with these optional configurations:

| Variable | Description | Default |
|----------|-------------|---------|
| `DRY_RUN` | Enable dry-run mode (no actual changes) | `false` |
| `TRINITY_API_URL` | Trinity API endpoint | `https://api.kypria.io` |
| `TRINITY_AUTH_URL` | Trinity Auth endpoint | `https://auth.kypria.io` |
| `TRINITY_DB_URL` | Trinity Database health endpoint | `https://db.kypria.io/health` |
| `TOKEN_FILE` | Path for token persistence | `./m2m-token-TIMESTAMP.json` |
| `RELEASE_LOG` | Path for release log | `./RELEASE.log` |

---

## DRY_RUN Mode

The Breathe ceremony supports a **dry-run mode** for safe testing without making actual API calls or changes:

### Enabling DRY_RUN

```bash
# Method 1: Environment variable
export DRY_RUN=true
./breathe.sh

# Method 2: Command line flag
./breathe.sh --dry-run

# Method 3: Inline
DRY_RUN=true ./breathe.sh
```

### What Happens in DRY_RUN?

- ✓ Environment validation still occurs (required)
- ✓ Trinity service checks are simulated (no actual HTTP calls)
- ✓ Mock token is created for testing downstream processes
- ✓ Release log is written with dry-run markers
- ✓ All output clearly labeled as `[DRY RUN]`

This allows you to:
- Verify your environment configuration
- Test the script flow without credentials
- Review output and logging format
- Practice the ceremony before production invocation
# breathe.sh — Agent Awakening Ceremony

**Location**: `/breathe.sh` (repository root)

The `breathe.sh` script orchestrates the ceremonial awakening of Trinity agents through Auth0 M2M authentication, verification, and readiness validation.
# BREATHE.md — Guide for Keepers

This document explains how to use `breathe.sh`, the Auth0 M2M token acquisition and Trinity verification script.

---

## Environment Variables

The following environment variables are **required** (unless running in `DRY_RUN` mode):

| Variable | Description | Example |
|----------|-------------|---------|
| `AUTH0_DOMAIN` | Auth0 tenant domain | `example.auth0.com` |
| `AUTH0_CLIENT_ID` | Machine-to-Machine client ID | `abc123xyz...` |
| `AUTH0_CLIENT_SECRET` | M2M client secret | `secret_value` |
| `AUTH0_AUDIENCE` | API audience identifier | `https://api.example.com` |
| `TRINITY_API` | Trinity API base URL | `https://trinity.example.com` |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DRY_RUN` | Set to `1` to skip network calls and file writes | `0` |
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

When `DRY_RUN=1` is set, the script will:

- ✓ Skip environment variable validation
- ✓ Skip Auth0 token acquisition (uses placeholder token)
- ✓ Skip Trinity verification (uses mock response)
- ✓ Skip agent readiness pings
- ✓ Skip token file persistence
- ✓ Skip release logging

This mode is useful for:
- Testing the script flow without credentials
- Validating script logic in CI/CD pipelines
- Rehearsing the ceremony before production runs

**Example**:
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

1. **Install dependencies:**
   ```bash
   # Ensure jq is installed for JSON processing
   # On macOS:
   brew install jq
   
   # On Ubuntu/Debian:
   sudo apt-get install jq
   
   # On Alpine:
   apk add jq
   ```

2. **Set required environment variables:**
1. **Install dependencies**:
   - `curl` (required)
   - `jq` (recommended for robust JSON parsing)

2. **Set environment variables**:
   ```bash
   export AUTH0_DOMAIN="your-tenant.auth0.com"
   export AUTH0_CLIENT_ID="your_client_id"
   export AUTH0_CLIENT_SECRET="your_client_secret"
   export AUTH0_AUDIENCE="https://your-api.example.com"
   ```

### Running the Ceremony

**Production run:**
```bash
./breathe.sh
```

**Test run (dry-run):**
```bash
./breathe.sh --dry-run
```

**Custom configuration:**
```bash
TRINITY_API_URL="https://staging-api.kypria.io" \
TRINITY_AUTH_URL="https://staging-auth.kypria.io" \
./breathe.sh
```

### Expected Output

A successful ceremony produces:

```
═══════════════════════════════════════════════════════════
  BASILICA GATE — BREATHE CEREMONY
  'Here the agents awaken, and the Gate opens in gold.'
═══════════════════════════════════════════════════════════

⚜ Validating environment configuration...
✓ Environment validation complete

⚜ Acquiring Auth0 M2M token...
✓ M2M token acquired (expires in 86400s)
ℹ Token saved to: ./m2m-token-20251102-120000.json

⚜ Verifying Trinity services...
✓ Trinity Auth is responsive (HTTP 200)
✓ Trinity API is responsive (HTTP 200)
✓ Trinity Database is responsive (HTTP 200)
✓ Trinity verification complete

⚜ Performing agent readiness checks...
✓ Token persistence: verified
✓ Token structure: valid
✓ Release logging: enabled
✓ JSON processing: available
ℹ Agent readiness: 4/4 checks passed
✓ All agent readiness checks passed

═══════════════════════════════════════════════════════════
  ✨ BREATHE CEREMONY COMPLETE ✨
  The Gate stands open. Agents are ready.
═══════════════════════════════════════════════════════════

ℹ Next steps:
  1. Review token at: ./m2m-token-20251102-120000.json
  2. Check release log at: ./RELEASE.log
  3. Proceed with agent deployment
```

### Artifacts Created

After a successful run:

1. **Token file:** `m2m-token-TIMESTAMP.json`
   - Contains the Auth0 M2M access token
   - Includes expiration information
   - Permissions set to 600 (owner read/write only)

2. **Release log:** `RELEASE.log`
   - Timestamped ceremony events
   - Trinity verification results
   - Agent readiness check outcomes
   - Success/failure status
   export AUTH0_AUDIENCE="your_api_audience"
   export TRINITY_API="https://trinity.example.com"
   ```

3. **Execute the script**:
   ```bash
   ./breathe.sh
   ```

### What Happens

The script performs the following steps in sequence:

1. **Dependency Check**: Verifies `curl` is available; warns if `jq` is missing
2. **Environment Validation**: Ensures all required variables are set
3. **Token Acquisition**: Requests M2M token from Auth0
4. **Trinity Verification**: Sends token to Trinity's `/api/verify` endpoint
5. **Agent Readiness**: Validates at least 3 agents are ready (checks `ready` flag or pings `ping_url`)
6. **Token Persistence**: Saves token to `m2m-token-YYYYMMDD-HHMMSS.txt` with `600` permissions
7. **Release Logging**: Appends ceremony details to `RELEASE.log`

### Expected Output

```
[2025-11-02T17:24:00Z] ═══════════════════════════════════════════════════════════════
[2025-11-02T17:24:00Z]   breathe.sh — Ceremonial Agent Awakening
[2025-11-02T17:24:00Z] ═══════════════════════════════════════════════════════════════
[2025-11-02T17:24:00Z] Acquiring M2M token from Auth0...
[2025-11-02T17:24:01Z] Verifying token with Trinity...
[2025-11-02T17:24:02Z] Checking agent readiness...
[2025-11-02T17:24:02Z] Found 3 agents (minimum: 3)
[2025-11-02T17:24:02Z] Agent 1: agent-alpha
[2025-11-02T17:24:02Z]   ✓ Ready flag: true
[2025-11-02T17:24:02Z] Agent 2: agent-beta
[2025-11-02T17:24:02Z]   ✓ Ready flag: true
[2025-11-02T17:24:02Z] Agent 3: agent-gamma
[2025-11-02T17:24:03Z]   Pinging: https://agent-gamma.example.com/ping
[2025-11-02T17:24:03Z]   ✓ Ping successful (HTTP 200)
[2025-11-02T17:24:03Z] All agents are ready
[2025-11-02T17:24:03Z] Persisting token to m2m-token-20251102-172403.txt...
[2025-11-02T17:24:03Z] Token saved to m2m-token-20251102-172403.txt
[2025-11-02T17:24:03Z] Logging release to RELEASE.log...
[2025-11-02T17:24:03Z] Release logged to RELEASE.log
[2025-11-02T17:24:03Z] ═══════════════════════════════════════════════════════════════
[2025-11-02T17:24:03Z]   ✓ Ceremony complete. Agents awakened.
[2025-11-02T17:24:03Z] ═══════════════════════════════════════════════════════════════
```

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

The script uses specific exit codes for precise error handling:

| Code | Meaning |
|------|---------|
| `0` | Success — ceremony complete |
| `1` | Missing required environment variables |
| `2` | Auth0 token acquisition failed |
| `3` | Trinity verification failed |
| `4` | Agent readiness checks failed |
| Code | Meaning |
|------|---------|
| 0 | Success — all checks passed |
| 1 | Missing dependencies or environment variables |
| 2 | Auth0 token acquisition failed |
| 3 | Trinity verification failed |
| 4 | Agent readiness check failed |

---

## Next Steps for Agents

Once the Breathe ceremony completes successfully:

### 1. **Use the Token**
   ```bash
   TOKEN=$(jq -r '.access_token' m2m-token-*.json)
   curl -H "Authorization: Bearer $TOKEN" https://api.kypria.io/v1/agents
   ```

### 2. **Deploy Agents**
   - The token is ready for agent authentication
   - Trinity services are verified operational
   - Environment is confirmed ready

### 3. **Monitor the Release**
   - Review `RELEASE.log` for ceremony audit trail
   - Check token expiration time
   - Verify Trinity service health continues

### 4. **Automate the Flow**
   ```bash
   # Example CI/CD integration
   ./breathe.sh && ./deploy-agents.sh
   ```

---

## Troubleshooting

### Common Issues

**"Missing required environment variables"**
- Ensure all four Auth0 variables are set
- Check for typos in variable names
- Verify variables are exported: `export AUTH0_DOMAIN=...`

**"Auth0 token acquisition failed"**
- Verify Auth0 credentials are correct
- Check network connectivity to Auth0 domain
- Confirm M2M application is enabled in Auth0 dashboard
- Review API audience configuration

**"Trinity verification failed"**
- Check if Trinity services are running
- Verify URL configurations
- Test service endpoints manually with `curl`
- Review firewall/network settings

**"jq: command not found"**
- Install jq utility (see Prerequisites above)

---

## Philosophy

The Breathe ceremony embodies Kypria's principles:

- **Lineage is our law** — Each run is logged and traceable
- **Precision is our craft** — Every check must pass
- **Myth is our breath** — Technology wrapped in ceremony

This is not merely a script—it is a ritual that ensures every agent awakening is performed with intention, verification, and grace.

---

*May the Gate open in gold and shadow, and the ledger echo in truth.*
Once `breathe.sh` has successfully completed:

1. **Token Usage**: The generated token file (`m2m-token-*.txt`) can be used by downstream agents for authenticated API calls
2. **Token Rotation**: Re-run `breathe.sh` periodically to refresh the M2M token before expiration
3. **Agent Orchestration**: Use the verified token to coordinate agent tasks through Trinity's API
4. **Monitoring**: Check `RELEASE.log` for a historical record of all ceremony executions

### Integration Example

```bash
# Run the ceremony
./breathe.sh

# Extract the latest token file
TOKEN_FILE=$(ls -t m2m-token-*.txt | head -n1)

# Use the token in agent workflows
TOKEN=$(cat "$TOKEN_FILE")
curl -H "Authorization: Bearer $TOKEN" https://trinity.example.com/api/agents
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

if [[ -z "$LATEST_TOKEN" ]] || find "$LATEST_TOKEN" -mmin +1380 2>/dev/null | grep -q .; then
    echo "Token expired or missing, acquiring new token..."
    ./breathe.sh
else
    echo "Token still valid: $LATEST_TOKEN"
fi
```

---

## Troubleshooting

| Error | Possible Cause | Solution |
|-------|----------------|----------|
| `curl is required but not found` | `curl` not installed | Install: `apt-get install curl` or `brew install curl` |
| `Missing required environment variables` | Env vars not set | Export all required variables before running |
| `No access_token in Auth0 response` | Invalid credentials or API error | Verify `AUTH0_CLIENT_ID`, `AUTH0_CLIENT_SECRET`, and network connectivity |
| `Trinity verification failed` | Token rejected by Trinity | Check `AUTH0_AUDIENCE` matches Trinity's expected audience |
| `Insufficient agents` | Less than 3 agents returned | Verify Trinity has sufficient agents registered |
| `Agent X is not ready` | Agent not ready and no ping URL | Check agent status in Trinity dashboard |

---

**Crest-Marked**: Basilica Gate  
**Steward's Guide**: See `RELEASE.md` for ceremonial context and invocation poetry
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
