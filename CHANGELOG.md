# Changelog

All notable changes to **Basilica Gate** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]
### Added — 2025‑11‑02
- **Ceremonial Agent Awakening Script**: `breathe.sh` — orchestrates Auth0 M2M token acquisition, Trinity verification, agent readiness checks, token persistence, and release logging
  - Supports `DRY_RUN` mode for testing without network calls or file writes
  - Requires environment variables: `AUTH0_DOMAIN`, `AUTH0_CLIENT_ID`, `AUTH0_CLIENT_SECRET`, `AUTH0_AUDIENCE`, `TRINITY_API`
  - Validates at least 3 ready agents via Trinity API
  - Persists tokens to timestamped files (`m2m-token-*.txt`) with secure permissions
  - Logs ceremonies to `RELEASE.log`
- **Release Ceremony Documentation**: `RELEASE.md` — ceremonial poem and metadata for the agent awakening process
- **Technical Guide**: `docs/BREATHE.md` — comprehensive documentation covering environment variables, DRY_RUN mode, usage instructions, troubleshooting, and integration examples

---

## [1.3.0] — 2025‑08‑24
### Added
- **Unified Crest‑QR Ritual Seal**: Introduced a single, scannable, animated emblem combining:
  - The animated ritual seal (sigil cycle, blessing stanza, gold‑foil ceremonial ID shimmer).
  - Crest‑shaped QR code glowing within the seal itself.
  - Encodes `PUBLIC_SIGILS_URL` for direct access to the Public Sigil Vault.
- New script: `scripts/generate-unified-seal.js` to automate creation of the unified seal artifact.
- Updated `package.json` with `generate-unified-seal` script and integration into `full-cycle`.

### Artifact Provenance
- **File:** [`artifacts/ritual-seal-unified-2025-08-24.gif`](artifacts/ritual-seal-unified-2025-08-24.gif)
- **Ceremonial ID:** `AUGUST-CREST-2025`
- **Blessing:** *May the Gate open in gold and shadow, and the ledger echo in truth.*

---

## [1.2.0] — 2025‑08‑??  
*(Previous release notes here)*

---

## [1.1.0] — 2025‑??‑??  
*(Previous release notes here)*

---

*Basilica Gate stands as both archive and altar —  
every file a vow, every merge a sealing.*
