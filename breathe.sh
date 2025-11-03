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
main "$@"
