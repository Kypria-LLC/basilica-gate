#!/usr/bin/env bash
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
  agent_count=$(echo "$trinity_response" | jq '.agents | length // 0')

  if [[ "$agent_count" -lt "$MIN_AGENTS" ]]; then
    error "Insufficient agents: expected at least $MIN_AGENTS, got $agent_count"
  fi

  log "Found $agent_count agents (minimum: $MIN_AGENTS)"

  local agents
  agents=$(echo "$trinity_response" | jq -c '.agents[]')

  # Check if agents is empty
  if [[ -z "$agents" ]]; then
    error "No agents found in response"
  fi
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
        -w "\n%{http_code}")
      local curl_exit_code=$?
      local http_code
      http_code=$(echo "$ping_response" | tail -n1)
      if [[ "$curl_exit_code" -ne 0 ]]; then
        error "Agent $agent_id ping failed: curl network error (exit code $curl_exit_code)"
      elif [[ "$http_code" =~ ^2[0-9]{2}$ ]]; then
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
    return 0
  fi

  local timestamp
  timestamp=$(date -u +%Y%m%d-%H%M%S)
  local token_file="m2m-token-${timestamp}.txt"

  log "Persisting token to $token_file..."

  echo "$token" > "$token_file" || error "Failed to write token file"
  chmod 600 "$token_file" || error "Failed to set permissions on $token_file"

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

