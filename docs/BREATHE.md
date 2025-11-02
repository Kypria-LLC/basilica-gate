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
