#!/usr/bin/env bash
set -euo pipefail

#############################################################################
# breathe.sh — Kypria LLC Basilica Gate Ceremonial Release Script
#
# Purpose:
#   Orchestrates the sacred ritual of agent awakening and release preparation:
#   1. Acquires Auth0 M2M token for service authentication
#   2. Verifies Trinity services (Auth, API, Database) are ready
#   3. Performs agent readiness checks
#   4. Persists authentication tokens for downstream processes
#   5. Logs ceremonial release metadata
#   6. Supports DRY_RUN mode for safe testing
#
# Usage:
#   ./breathe.sh [--dry-run]
#
# Environment Variables (Required):
#   AUTH0_DOMAIN       - Auth0 tenant domain (e.g., kypria.auth0.com)
#   AUTH0_CLIENT_ID    - M2M application client ID
#   AUTH0_CLIENT_SECRET - M2M application client secret
#   AUTH0_AUDIENCE     - API identifier/audience
#
# Environment Variables (Optional):
#   DRY_RUN            - Set to "true" for dry-run mode (default: false)
#   TRINITY_API_URL    - Trinity API endpoint (default: https://api.kypria.io)
#   TRINITY_AUTH_URL   - Trinity Auth endpoint (default: https://auth.kypria.io)
#   TRINITY_DB_URL     - Trinity DB health check URL (default: https://db.kypria.io/health)
#   TOKEN_FILE         - Path for token persistence (default: ./m2m-token-TIMESTAMP.json)
#   RELEASE_LOG        - Path for release log (default: ./RELEASE.log)
#
# Exit Codes:
#   0 - Success
#   1 - Missing required environment variables
#   2 - Auth0 token acquisition failed
#   3 - Trinity verification failed
#   4 - Agent readiness checks failed
#############################################################################

# ANSI Colors for ceremonial output
readonly COLOR_RESET='\033[0m'
readonly COLOR_GOLD='\033[38;5;220m'
readonly COLOR_SILVER='\033[38;5;250m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_CYAN='\033[0;36m'

# Configuration
DRY_RUN="${DRY_RUN:-false}"
TRINITY_API_URL="${TRINITY_API_URL:-https://api.kypria.io}"
TRINITY_AUTH_URL="${TRINITY_AUTH_URL:-https://auth.kypria.io}"
TRINITY_DB_URL="${TRINITY_DB_URL:-https://db.kypria.io/health}"
TIMESTAMP="$(date -u +%Y%m%d-%H%M%S)"
TOKEN_FILE="${TOKEN_FILE:-./m2m-token-${TIMESTAMP}.json}"
RELEASE_LOG="${RELEASE_LOG:-./RELEASE.log}"

# Parse command line arguments
for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN="true"
            ;;
    esac
done

#############################################################################
# Helper Functions
#############################################################################

log_ceremonial() {
    local message="$1"
    echo -e "${COLOR_GOLD}⚜${COLOR_RESET} ${message}"
}

log_info() {
    local message="$1"
    echo -e "${COLOR_CYAN}ℹ${COLOR_RESET} ${message}"
}

log_success() {
    local message="$1"
    echo -e "${COLOR_GREEN}✓${COLOR_RESET} ${message}"
}

log_error() {
    local message="$1"
    echo -e "${COLOR_RED}✗${COLOR_RESET} ${message}" >&2
}

log_dry_run() {
    local message="$1"
    echo -e "${COLOR_SILVER}[DRY RUN]${COLOR_RESET} ${message}"
}

write_release_log() {
    local message="$1"
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $message" >> "$RELEASE_LOG"
}

#############################################################################
# Validation
#############################################################################

validate_environment() {
    log_ceremonial "Validating environment configuration..."
    
    local missing_vars=()
    
    [[ -z "${AUTH0_DOMAIN:-}" ]] && missing_vars+=("AUTH0_DOMAIN")
    [[ -z "${AUTH0_CLIENT_ID:-}" ]] && missing_vars+=("AUTH0_CLIENT_ID")
    [[ -z "${AUTH0_CLIENT_SECRET:-}" ]] && missing_vars+=("AUTH0_CLIENT_SECRET")
    [[ -z "${AUTH0_AUDIENCE:-}" ]] && missing_vars+=("AUTH0_AUDIENCE")
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        log_error "Missing required environment variables:"
        for var in "${missing_vars[@]}"; do
            log_error "  - $var"
        done
        return 1
    fi
    
    log_success "Environment validation complete"
    return 0
}

#############################################################################
# Auth0 M2M Token Acquisition
#############################################################################

acquire_m2m_token() {
    log_ceremonial "Acquiring Auth0 M2M token..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry_run "Would acquire token from: https://${AUTH0_DOMAIN}/oauth/token"
        log_dry_run "Would save token to: $TOKEN_FILE"
        # Create mock token for dry run
        echo '{"access_token":"dry_run_token","token_type":"Bearer","expires_in":86400}' > "$TOKEN_FILE"
        log_success "Dry run token created"
        return 0
    fi
    
    local token_response
    token_response=$(curl -s --max-time 30 -X POST "https://${AUTH0_DOMAIN}/oauth/token" \
        -H "Content-Type: application/json" \
        -d '{
            "client_id": "'"${AUTH0_CLIENT_ID}"'",
            "client_secret": "'"${AUTH0_CLIENT_SECRET}"'",
            "audience": "'"${AUTH0_AUDIENCE}"'",
            "grant_type": "client_credentials"
        }')
    
    if [[ -z "$token_response" ]] || ! echo "$token_response" | jq -e '.access_token' > /dev/null 2>&1; then
        log_error "Failed to acquire M2M token"
        # Log only error details, not the full response
        local error_msg
        error_msg=$(echo "$token_response" | jq -r '.error // empty')
        local error_desc
        error_desc=$(echo "$token_response" | jq -r '.error_description // empty')
        if [[ -n "$error_msg" ]] || [[ -n "$error_desc" ]]; then
            log_error "Auth0 error: ${error_msg} - ${error_desc}"
        else
            log_error "Auth0 token response did not contain error details."
        fi
        return 2
    fi
    
    # Persist token
    echo "$token_response" > "$TOKEN_FILE"
    chmod 600 "$TOKEN_FILE"
    
    local expires_in
    expires_in=$(echo "$token_response" | jq -r '.expires_in')
    
    log_success "M2M token acquired (expires in ${expires_in}s)"
    log_info "Token saved to: $TOKEN_FILE"
    write_release_log "M2M_TOKEN_ACQUIRED: $TOKEN_FILE"
    
    return 0
}

#############################################################################
# Trinity Verification
#############################################################################

verify_trinity_service() {
    local service_name="$1"
    local service_url="$2"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry_run "Would verify $service_name at: $service_url"
        return 0
    fi
    
    local response_code
    response_code=$(curl -s --max-time 10 -o /dev/null -w "%{http_code}" "$service_url" || echo "000")
    
    if [[ "$response_code" =~ ^(200|201|204)$ ]]; then
        log_success "$service_name is responsive (HTTP $response_code)"
        return 0
    else
        log_error "$service_name is not responsive (HTTP $response_code)"
        return 1
    fi
}

verify_trinity() {
    log_ceremonial "Verifying Trinity services..."
    
    local trinity_status=0
    
    verify_trinity_service "Trinity Auth" "$TRINITY_AUTH_URL" || trinity_status=1
    verify_trinity_service "Trinity API" "$TRINITY_API_URL" || trinity_status=1
    verify_trinity_service "Trinity Database" "$TRINITY_DB_URL" || trinity_status=1
    
    if [[ $trinity_status -eq 0 ]]; then
        log_success "Trinity verification complete"
        write_release_log "TRINITY_VERIFIED: All services operational"
        return 0
    else
        log_error "Trinity verification failed"
        write_release_log "TRINITY_VERIFICATION_FAILED"
        return 3
    fi
}

#############################################################################
# Agent Readiness Checks
#############################################################################

check_agent_readiness() {
    log_ceremonial "Performing agent readiness checks..."
    
    local checks_passed=0
    local checks_total=4
    
    # Check 1: Token file exists and is readable
    if [[ -r "$TOKEN_FILE" ]]; then
        log_success "Token persistence: verified"
        ((checks_passed++))
    else
        log_error "Token persistence: failed"
    fi
    
    # Check 2: Token contains required fields
    if [[ -r "$TOKEN_FILE" ]] && jq -e '.access_token' "$TOKEN_FILE" > /dev/null 2>&1; then
        log_success "Token structure: valid"
        ((checks_passed++))
    else
        log_error "Token structure: invalid"
    fi
    
    # Check 3: Release log is writable
    if touch "$RELEASE_LOG" 2>/dev/null; then
        log_success "Release logging: enabled"
        ((checks_passed++))
    else
        log_error "Release logging: failed"
    fi
    
    # Check 4: jq utility available for JSON processing
    if command -v jq > /dev/null 2>&1; then
        log_success "JSON processing: available"
        ((checks_passed++))
    else
        log_error "JSON processing: jq not found"
    fi
    
    log_info "Agent readiness: $checks_passed/$checks_total checks passed"
    
    if [[ $checks_passed -eq $checks_total ]]; then
        log_success "All agent readiness checks passed"
        write_release_log "AGENT_READINESS: $checks_passed/$checks_total PASSED"
        return 0
    else
        log_error "Some agent readiness checks failed"
        write_release_log "AGENT_READINESS: $checks_passed/$checks_total FAILED"
        return 4
    fi
}

#############################################################################
# Release Logging
#############################################################################

log_release_metadata() {
    log_ceremonial "Recording release metadata..."
    
    write_release_log "========================================="
    write_release_log "BREATHE CEREMONY INITIATED"
    write_release_log "========================================="
    write_release_log "Timestamp: $TIMESTAMP"
    write_release_log "Dry Run: $DRY_RUN"
    write_release_log "Trinity Auth: $TRINITY_AUTH_URL"
    write_release_log "Trinity API: $TRINITY_API_URL"
    write_release_log "Trinity DB: $TRINITY_DB_URL"
    write_release_log "Token File: $TOKEN_FILE"
    write_release_log "-----------------------------------------"
    
    log_success "Release metadata recorded to: $RELEASE_LOG"
}

finalize_release_log() {
    local exit_code="$1"
    
    write_release_log "-----------------------------------------"
    if [[ $exit_code -eq 0 ]]; then
        write_release_log "CEREMONY STATUS: SUCCESS"
    else
        write_release_log "CEREMONY STATUS: FAILED (exit code: $exit_code)"
    fi
    write_release_log "========================================="
    write_release_log ""
}

#############################################################################
# Main Ceremony
#############################################################################

main() {
    echo ""
    log_ceremonial "═══════════════════════════════════════════════════════════"
    log_ceremonial "  BASILICA GATE — BREATHE CEREMONY"
    log_ceremonial "  'Here the agents awaken, and the Gate opens in gold.'"
    log_ceremonial "═══════════════════════════════════════════════════════════"
    echo ""
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry_run "Running in DRY RUN mode - no actual changes will be made"
        echo ""
    fi
    
    # Log release metadata first
    log_release_metadata
    
    # Validation
    if ! validate_environment; then
        finalize_release_log 1
        exit 1
    fi
    echo ""
    
    # Acquire M2M Token
    if ! acquire_m2m_token; then
        finalize_release_log 2
        exit 2
    fi
    echo ""
    
    # Verify Trinity
    if ! verify_trinity; then
        finalize_release_log 3
        exit 3
    fi
    echo ""
    
    # Agent Readiness
    if ! check_agent_readiness; then
        finalize_release_log 4
        exit 4
    fi
    echo ""
    
    # Success
    log_ceremonial "═══════════════════════════════════════════════════════════"
    log_ceremonial "  ✨ BREATHE CEREMONY COMPLETE ✨"
    log_ceremonial "  The Gate stands open. Agents are ready."
    log_ceremonial "═══════════════════════════════════════════════════════════"
    echo ""
    
    finalize_release_log 0
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_dry_run "Dry run complete. Review $RELEASE_LOG for details."
    else
        log_info "Next steps:"
        log_info "  1. Review token at: $TOKEN_FILE"
        log_info "  2. Check release log at: $RELEASE_LOG"
        log_info "  3. Proceed with agent deployment"
    fi
    
    exit 0
}

# Execute main ceremony
#
# breathe.sh — Ceremonial Agent Awakening
# ========================================
# Acquires Auth0 M2M token, verifies via Trinity, ensures agent readiness,
# persists token, and logs the release ceremony.
#
# Environment Variables (required unless DRY_RUN=1):
#   AUTH0_DOMAIN         — Auth0 tenant domain (e.g., "example.auth0.com")
#   AUTH0_CLIENT_ID      — M2M client ID
#   AUTH0_CLIENT_SECRET  — M2M client secret
#   AUTH0_AUDIENCE       — API audience identifier
#   TRINITY_API          — Trinity API base URL (e.g., "https://trinity.example.com")
#
# Optional:
#   DRY_RUN              — Set to "1" to skip network calls and file writes
#
# Dependencies:
#   - curl (required)
#   - jq (recommended for JSON parsing; script degrades gracefully without it)
#

set -euo pipefail

# ============================================================================
# Configuration & Validation
# ============================================================================

DRY_RUN="${DRY_RUN:-0}"
MIN_AGENTS=3

log() {
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $*" >&2
}

error() {
  log "ERROR: $*"
  exit 1
}

check_dependencies() {
  if ! command -v curl &>/dev/null; then
    error "curl is required but not found in PATH"
  fi
  if ! command -v jq &>/dev/null; then
    log "WARNING: jq not found; JSON parsing will be limited"
  fi
}

validate_env() {
  if [[ "$DRY_RUN" == "1" ]]; then
    log "DRY_RUN mode enabled — skipping environment validation"
    return 0
  fi

  local missing=()
  [[ -z "${AUTH0_DOMAIN:-}" ]] && missing+=("AUTH0_DOMAIN")
  [[ -z "${AUTH0_CLIENT_ID:-}" ]] && missing+=("AUTH0_CLIENT_ID")
  [[ -z "${AUTH0_CLIENT_SECRET:-}" ]] && missing+=("AUTH0_CLIENT_SECRET")
  [[ -z "${AUTH0_AUDIENCE:-}" ]] && missing+=("AUTH0_AUDIENCE")
  [[ -z "${TRINITY_API:-}" ]] && missing+=("TRINITY_API")

  if [[ ${#missing[@]} -gt 0 ]]; then
    error "Missing required environment variables: ${missing[*]}"
  fi
}

# ============================================================================
# Auth0 M2M Token Acquisition
# ============================================================================

acquire_token() {
  if [[ "$DRY_RUN" == "1" ]]; then
    log "DRY_RUN: Skipping Auth0 token acquisition"
    echo "dry-run-token-placeholder"
    return 0
  fi

  log "Acquiring M2M token from Auth0..."

  local token_url="https://${AUTH0_DOMAIN}/oauth/token"
  local payload
  payload=$(cat <<EOF
{
  "client_id": "${AUTH0_CLIENT_ID}",
  "client_secret": "${AUTH0_CLIENT_SECRET}",
  "audience": "${AUTH0_AUDIENCE}",
  "grant_type": "client_credentials"
}
EOF
)

  local response
  response=$(curl -s -X POST "$token_url" \
    -H "Content-Type: application/json" \
    -d "$payload") || error "Failed to acquire token from Auth0"

  if command -v jq &>/dev/null; then
    local token
    token=$(echo "$response" | jq -r '.access_token // empty')
    if [[ -z "$token" || "$token" == "null" ]]; then
      log "Auth0 response: $response"
      error "No access_token in Auth0 response"
    fi
    echo "$token"
  else
    # Fallback: extract token with grep/sed
    local token
    token=$(echo "$response" | grep -o '"access_token":"[^"]*"' | sed 's/"access_token":"\(.*\)"/\1/')
    if [[ -z "$token" ]]; then
      log "Auth0 response: $response"
      error "No access_token in Auth0 response (jq not available)"
    fi
    echo "$token"
  fi
}

# ============================================================================
# Trinity Verification
# ============================================================================

verify_with_trinity() {
  local token="$1"

  if [[ "$DRY_RUN" == "1" ]]; then
    log "DRY_RUN: Skipping Trinity verification"
    # Return a mock response with 3 ready agents
    cat <<EOF
{
  "ok": true,
  "agents": [
    {"id": "agent-1", "ready": true},
    {"id": "agent-2", "ready": true},
    {"id": "agent-3", "ready": true}
  ]
}
EOF
    return 0
  fi

  log "Verifying token with Trinity..."

  local trinity_url="${TRINITY_API%/}/api/verify"
  local response
  response=$(curl -s -X POST "$trinity_url" \
    -H "Authorization: Bearer $token" \
    -H "Content-Type: application/json") || error "Failed to verify with Trinity"

  if command -v jq &>/dev/null; then
    local ok
    ok=$(echo "$response" | jq -r '.ok // false')
    if [[ "$ok" != "true" ]]; then
      log "Trinity response: $response"
      error "Trinity verification failed (ok != true)"
    fi
  else
    # Fallback: check for "ok":true pattern
    if ! echo "$response" | grep -q '"ok"[[:space:]]*:[[:space:]]*true'; then
      log "Trinity response: $response"
      error "Trinity verification failed (ok != true, jq not available)"
    fi
  fi

  echo "$response"
}

# ============================================================================
# Agent Readiness Checks
# ============================================================================

check_agent_readiness() {
  local trinity_response="$1"
  local token="$2"

  log "Checking agent readiness..."

  if [[ "$DRY_RUN" == "1" ]]; then
    log "DRY_RUN: Skipping agent readiness checks"
    return 0
  fi

  if ! command -v jq &>/dev/null; then
    log "WARNING: jq not available; skipping detailed agent readiness checks"
    return 0
  fi

  local agent_count
  agent_count=$(echo "$trinity_response" | jq '.agents | length')

  if [[ "$agent_count" -lt "$MIN_AGENTS" ]]; then
    error "Insufficient agents: expected at least $MIN_AGENTS, got $agent_count"
  fi

  log "Found $agent_count agents (minimum: $MIN_AGENTS)"

  local agents
  agents=$(echo "$trinity_response" | jq -c '.agents[]')

  local idx=0
  while IFS= read -r agent; do
    idx=$((idx + 1))
    local agent_id
    agent_id=$(echo "$agent" | jq -r '.id // "unknown"')
    local ready
    ready=$(echo "$agent" | jq -r '.ready // false')
    local ping_url
    ping_url=$(echo "$agent" | jq -r '.ping_url // empty')

    log "Agent $idx: $agent_id"

    if [[ "$ready" == "true" ]]; then
      log "  ✓ Ready flag: true"
    elif [[ -n "$ping_url" ]]; then
      log "  Pinging: $ping_url"
      local ping_response
      ping_response=$(curl -s -X GET "$ping_url" \
        -H "Authorization: Bearer $token" \
        -w "\n%{http_code}" || echo "000")
      local http_code
      http_code=$(echo "$ping_response" | tail -n1)
      if [[ "$http_code" =~ ^2[0-9]{2}$ ]]; then
        log "  ✓ Ping successful (HTTP $http_code)"
      else
        error "Agent $agent_id ping failed (HTTP $http_code)"
      fi
    else
      error "Agent $agent_id is not ready and has no ping_url"
    fi
  done <<< "$agents"

  log "All agents are ready"
}

# ============================================================================
# Token Persistence
# ============================================================================

persist_token() {
  local token="$1"

  if [[ "$DRY_RUN" == "1" ]]; then
    log "DRY_RUN: Skipping token persistence"
    echo "dry-run-token-file.txt"
    return 0
  fi

  local timestamp
  timestamp=$(date -u +%Y%m%d-%H%M%S)
  local token_file="m2m-token-${timestamp}.txt"

  log "Persisting token to $token_file..."

  echo "$token" > "$token_file" || error "Failed to write token file"
  chmod 600 "$token_file" || log "WARNING: Failed to set permissions on $token_file"

  log "Token saved to $token_file"
  echo "$token_file"
}

# ============================================================================
# Release Logging
# ============================================================================

log_release() {
  local token_file="$1"

  if [[ "$DRY_RUN" == "1" ]]; then
    log "DRY_RUN: Skipping release logging"
    return 0
  fi

  local release_log="RELEASE.log"
  local timestamp
  timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

  log "Logging release to $release_log..."

  cat >> "$release_log" <<EOF

Release: $timestamp
Token File: $token_file
EOF

  log "Release logged to $release_log"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
  log "═══════════════════════════════════════════════════════════════"
  log "  breathe.sh — Ceremonial Agent Awakening"
  log "═══════════════════════════════════════════════════════════════"

  if [[ "$DRY_RUN" == "1" ]]; then
    log "⚠️  DRY_RUN MODE ENABLED — No network calls or file writes"
  fi

  check_dependencies
  validate_env

  local token
  token=$(acquire_token)

  local trinity_response
  trinity_response=$(verify_with_trinity "$token")

  check_agent_readiness "$trinity_response" "$token"

  local token_file
  token_file=$(persist_token "$token")

  log_release "$token_file"

  log "═══════════════════════════════════════════════════════════════"
  log "  ✓ Ceremony complete. Agents awakened."
  log "═══════════════════════════════════════════════════════════════"
}

main "$@"
