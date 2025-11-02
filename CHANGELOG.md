# Changelog

All notable changes to **Basilica Gate** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]
### Added
- **Breathe Ceremony Script** (`breathe.sh`): Sacred orchestration script for agent awakening and release preparation — 2025-11-02
  - Auth0 M2M token acquisition with secure credential handling
  - Trinity service verification (Auth, API, Database health checks)
  - Agent readiness checks and validation
  - Token persistence with timestamped file naming (`m2m-token-*.json`)
  - Comprehensive release logging to `RELEASE.log`
  - DRY_RUN support for safe testing and rehearsal
  - Ceremonial output with colored logging and status indicators
  - Detailed exit codes for precise error handling
- **Release Documentation** (`RELEASE.md`): Ceremonial poem and release metadata for the First Breath ceremony
- **Breathe Guide** (`docs/BREATHE.md`): Comprehensive documentation covering environment variables, DRY_RUN mode, usage instructions, and next steps for agents

### Ceremonial ID
- **BREATHE-NOVEMBER-2025** — *"Here the agents awaken, and the Gate opens in gold."*

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
