# breathe.sh — Agent Awakening Ceremony

**Location**: `/breathe.sh` (repository root)

The `breathe.sh` script orchestrates the ceremonial awakening of Trinity agents through Auth0 M2M authentication, verification, and readiness validation.

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
```bash
DRY_RUN=1 ./breathe.sh
```

---

## How to Run

### Prerequisites

1. **Install dependencies**:
   - `curl` (required)
   - `jq` (recommended for robust JSON parsing)

2. **Set environment variables**:
   ```bash
   export AUTH0_DOMAIN="your-tenant.auth0.com"
   export AUTH0_CLIENT_ID="your_client_id"
   export AUTH0_CLIENT_SECRET="your_client_secret"
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

---

## Next Steps for Agents

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
