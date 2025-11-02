#!/usr/bin/env bash
# breathe.sh - Auth0 M2M Token Acquisition & Trinity Verification
# Part of the Basilica Gate canon — where technical precision meets ceremonial rigor.
#
# Usage:
#   DRY_RUN=1 ./breathe.sh      # Simulate without network calls or file writes
#   ./breathe.sh                 # Full execution
#
# Required Environment Variables:
#   AUTH0_DOMAIN         - Auth0 tenant domain (e.g., "your-tenant.auth0.com")
#   AUTH0_CLIENT_ID      - M2M application client ID
#   AUTH0_CLIENT_SECRET  - M2M application client secret
#   AUTH0_AUDIENCE       - API audience identifier
#   TRINITY_API          - Trinity verification endpoint base URL
#
# Exit Codes:
#   0 - Success
#   1 - Missing dependencies or environment variables
#   2 - Auth0 token acquisition failed
#   3 - Trinity verification failed
#   4 - Agent readiness check failed

set -euo pipefail

# Color codes for ceremonial output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly GOLD='\033[38;5;220m'
readonly NC='\033[0m' # No Color

# Ceremonial banner
echo -e "${GOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GOLD}║                    BREATHE.SH — AWAKENING                      ║${NC}"
echo -e "${GOLD}║        Auth0 M2M Token Acquisition & Trinity Verification      ║${NC}"
echo -e "${GOLD}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check for DRY_RUN mode
if [[ "${DRY_RUN:-0}" == "1" ]]; then
    echo -e "${YELLOW}[DRY RUN] Simulation mode enabled - no network calls or file writes${NC}"
    echo ""
fi

# Dependency check
echo -e "${BLUE}→ Checking dependencies...${NC}"
if ! command -v curl &> /dev/null; then
    echo -e "${RED}✗ curl is required but not installed${NC}"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}⚠ jq is recommended for JSON parsing but not found${NC}"
    echo -e "${YELLOW}  Install with: apt-get install jq / brew install jq${NC}"
    JQ_AVAILABLE=0
else
    echo -e "${GREEN}✓ jq available${NC}"
    JQ_AVAILABLE=1
fi

echo -e "${GREEN}✓ curl available${NC}"
echo ""

# Environment variable validation
echo -e "${BLUE}→ Validating environment variables...${NC}"
REQUIRED_VARS=("AUTH0_DOMAIN" "AUTH0_CLIENT_ID" "AUTH0_CLIENT_SECRET" "AUTH0_AUDIENCE" "TRINITY_API")
MISSING_VARS=()

for var in "${REQUIRED_VARS[@]}"; do
    if [[ -z "${!var:-}" ]]; then
        MISSING_VARS+=("$var")
    fi
done

if [[ ${#MISSING_VARS[@]} -gt 0 ]]; then
    echo -e "${RED}✗ Missing required environment variables:${NC}"
    for var in "${MISSING_VARS[@]}"; do
        echo -e "${RED}  - $var${NC}"
    done
    echo ""
    echo -e "${YELLOW}Set them in your environment or .env file${NC}"
    exit 1
fi

echo -e "${GREEN}✓ All required environment variables present${NC}"
echo ""

# Step 1: Acquire Auth0 M2M Token
echo -e "${BLUE}→ Acquiring Auth0 M2M token...${NC}"
TOKEN_URL="https://${AUTH0_DOMAIN}/oauth/token"

if [[ "${DRY_RUN:-0}" == "1" ]]; then
    echo -e "${YELLOW}[DRY RUN] Would POST to: $TOKEN_URL${NC}"
    ACCESS_TOKEN="dry_run_mock_token_$(date +%s)"
    echo -e "${GREEN}✓ Mock token generated: ${ACCESS_TOKEN:0:20}...${NC}"
else
    TOKEN_RESPONSE=$(curl -s -X POST "$TOKEN_URL" \
        -H "Content-Type: application/json" \
        -d "{
            \"client_id\": \"$AUTH0_CLIENT_ID\",
            \"client_secret\": \"$AUTH0_CLIENT_SECRET\",
            \"audience\": \"$AUTH0_AUDIENCE\",
            \"grant_type\": \"client_credentials\"
        }")
    
    if [[ $JQ_AVAILABLE -eq 1 ]]; then
        ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.access_token // empty')
    else
        # Fallback: basic parsing without jq
        ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
    fi
    
    if [[ -z "$ACCESS_TOKEN" ]] || [[ "$ACCESS_TOKEN" == "null" ]]; then
        echo -e "${RED}✗ Failed to acquire access token${NC}"
        echo -e "${RED}Response: $TOKEN_RESPONSE${NC}"
        exit 2
    fi
    
    echo -e "${GREEN}✓ Access token acquired${NC}"
fi
echo ""

# Step 2: Verify with Trinity
echo -e "${BLUE}→ Verifying token with Trinity...${NC}"
TRINITY_VERIFY_URL="${TRINITY_API%/}/api/verify"

if [[ "${DRY_RUN:-0}" == "1" ]]; then
    echo -e "${YELLOW}[DRY RUN] Would POST to: $TRINITY_VERIFY_URL${NC}"
    TRINITY_RESPONSE='{"ok":true,"agents":[{"id":"agent1","ready":true},{"id":"agent2","ready":true},{"id":"agent3","ready":true}]}'
    echo -e "${GREEN}✓ Mock Trinity verification successful${NC}"
else
    TRINITY_RESPONSE=$(curl -s -X POST "$TRINITY_VERIFY_URL" \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json")
    
    if [[ $JQ_AVAILABLE -eq 1 ]]; then
        TRINITY_OK=$(echo "$TRINITY_RESPONSE" | jq -r '.ok // false')
    else
        # Fallback: basic check for "ok":true pattern
        if echo "$TRINITY_RESPONSE" | grep -q '"ok"[[:space:]]*:[[:space:]]*true'; then
            TRINITY_OK="true"
        else
            TRINITY_OK="false"
        fi
    fi
    
    if [[ "$TRINITY_OK" != "true" ]]; then
        echo -e "${RED}✗ Trinity verification failed${NC}"
        echo -e "${RED}Response: $TRINITY_RESPONSE${NC}"
        exit 3
    fi
    
    echo -e "${GREEN}✓ Trinity verification successful${NC}"
fi
echo ""

# Step 3: Agent Readiness Check
echo -e "${BLUE}→ Checking agent readiness...${NC}"

if [[ $JQ_AVAILABLE -eq 1 ]]; then
    AGENT_COUNT=$(echo "$TRINITY_RESPONSE" | jq '.agents | length')
    
    if [[ $AGENT_COUNT -lt 3 ]]; then
        echo -e "${RED}✗ Insufficient agents: found $AGENT_COUNT, require at least 3${NC}"
        exit 4
    fi
    
    echo -e "${GREEN}✓ Found $AGENT_COUNT agents${NC}"
    
    # Check each agent's readiness
    AGENTS_READY=0
    AGENTS_NOT_READY=0
    
    for i in $(seq 0 $((AGENT_COUNT - 1))); do
        AGENT_ID=$(echo "$TRINITY_RESPONSE" | jq -r ".agents[$i].id // \"agent-$i\"")
        AGENT_READY=$(echo "$TRINITY_RESPONSE" | jq -r ".agents[$i].ready // false")
        PING_URL=$(echo "$TRINITY_RESPONSE" | jq -r ".agents[$i].ping_url // empty")
        
        if [[ "$AGENT_READY" == "true" ]]; then
            echo -e "${GREEN}  ✓ Agent $AGENT_ID: ready${NC}"
            ((AGENTS_READY++)) || true
        elif [[ -n "$PING_URL" ]] && [[ "${DRY_RUN:-0}" != "1" ]]; then
            echo -e "${YELLOW}  ⟳ Agent $AGENT_ID: checking ping_url...${NC}"
            PING_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $ACCESS_TOKEN" "$PING_URL")
            
            if [[ "$PING_STATUS" == "200" ]]; then
                echo -e "${GREEN}  ✓ Agent $AGENT_ID: ping successful (HTTP $PING_STATUS)${NC}"
                ((AGENTS_READY++)) || true
            else
                echo -e "${RED}  ✗ Agent $AGENT_ID: ping failed (HTTP $PING_STATUS)${NC}"
                ((AGENTS_NOT_READY++)) || true
            fi
        elif [[ -n "$PING_URL" ]] && [[ "${DRY_RUN:-0}" == "1" ]]; then
            echo -e "${YELLOW}  [DRY RUN] Agent $AGENT_ID: would ping $PING_URL${NC}"
            ((AGENTS_READY++)) || true
        else
            echo -e "${RED}  ✗ Agent $AGENT_ID: not ready and no ping_url${NC}"
            ((AGENTS_NOT_READY++)) || true
        fi
    done
    
    if [[ $AGENTS_NOT_READY -gt 0 ]]; then
        echo -e "${RED}✗ Some agents not ready: $AGENTS_NOT_READY failed${NC}"
        exit 4
    fi
    
    echo -e "${GREEN}✓ All agents ready ($AGENTS_READY/$AGENT_COUNT)${NC}"
else
    # Without jq, do basic validation
    echo -e "${YELLOW}⚠ jq not available - skipping detailed agent check${NC}"
    if echo "$TRINITY_RESPONSE" | grep -q '"agents"'; then
        echo -e "${GREEN}✓ Agents array present in response${NC}"
    else
        echo -e "${RED}✗ No agents array in Trinity response${NC}"
        exit 4
    fi
fi
echo ""

# Step 4: Persist Token
echo -e "${BLUE}→ Persisting access token...${NC}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
TOKEN_FILE="m2m-token-${TIMESTAMP}.txt"

if [[ "${DRY_RUN:-0}" == "1" ]]; then
    echo -e "${YELLOW}[DRY RUN] Would write token to: $TOKEN_FILE${NC}"
else
    echo "$ACCESS_TOKEN" > "$TOKEN_FILE"
    chmod 600 "$TOKEN_FILE"
    echo -e "${GREEN}✓ Token saved to: $TOKEN_FILE${NC}"
fi
echo ""

# Step 5: Release Logging
echo -e "${BLUE}→ Logging release ceremony...${NC}"
RELEASE_LOG="breathe-release.log"
LOG_ENTRY="[$(date -Iseconds)] breathe.sh executed successfully | Token: ${TOKEN_FILE} | Trinity: verified | Agents: ready"

if [[ "${DRY_RUN:-0}" == "1" ]]; then
    echo -e "${YELLOW}[DRY RUN] Would append to $RELEASE_LOG:${NC}"
    echo -e "${YELLOW}$LOG_ENTRY${NC}"
else
    echo "$LOG_ENTRY" >> "$RELEASE_LOG"
    echo -e "${GREEN}✓ Release logged to: $RELEASE_LOG${NC}"
fi
echo ""

# Ceremonial conclusion
echo -e "${GOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GOLD}║                    BREATHE COMPLETE — SEALED                   ║${NC}"
echo -e "${GOLD}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}The Gate breathes. The token is forged. The agents stand ready.${NC}"
echo ""

exit 0
