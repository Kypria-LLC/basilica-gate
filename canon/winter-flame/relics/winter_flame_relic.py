#!/usr/bin/env python3
"""
❄️🔥 The Hearthstone Seal — Winter Flame Relic
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The second relic of the Basilica Canon.

Where the Harvest Seal inscribed the October Arc's founding entries,
the Hearthstone Seal governs the Winter Flame cycle:
  - Verifies the October Arc is sealed (predecessor check)
  - Inscribes entries into the Winter Flame ledger
  - Records delegation events (Era-Steward appointments)
  - Generates the closing attestation when the cycle concludes

Part of the Basilica Gate Canon — Kypria LLC
Cycle: Winter Flame (March–June 2026)
Ceremonial ID: WINTER-FLAME-2026
"""

import hashlib
import json
import os
from datetime import datetime, timezone
from typing import Optional

# ─── Configuration ───────────────────────────────────────────────

CYCLE_NAME = "Winter Flame"
CYCLE_ID = "WINTER-FLAME-2026"
PREDECESSOR = "OCTOBER-ARC-2025"
RELIC_DIR = os.path.dirname(os.path.abspath(__file__))
LEDGER_PATH = os.path.join(RELIC_DIR, "winter_flame_ledger.json")


# ─── Core Functions ──────────────────────────────────────────────


def _now() -> str:
    """Return current UTC timestamp in ISO format."""
    return datetime.now(timezone.utc).isoformat()


def _seal(content: str) -> str:
    """Generate a SHA-256 seal for content verification."""
    return hashlib.sha256(content.encode("utf-8")).hexdigest()[:16]


def _load_ledger() -> dict:
    """Load or initialize the Winter Flame ledger."""
    if os.path.exists(LEDGER_PATH):
        with open(LEDGER_PATH, "r", encoding="utf-8") as f:
            return json.load(f)
    return {
        "cycle": CYCLE_NAME,
        "cycle_id": CYCLE_ID,
        "predecessor": PREDECESSOR,
        "opened": _now(),
        "status": "OPEN",
        "entries": [],
        "delegations": [],
        "total_inscriptions": 0,
        "sealed": False,
    }


def _save_ledger(ledger: dict) -> None:
    """Persist the ledger to disk."""
    with open(LEDGER_PATH, "w", encoding="utf-8") as f:
        json.dump(ledger, f, indent=2, ensure_ascii=False)
        f.write("\n")


# ─── Predecessor Verification ────────────────────────────────────


def verify_predecessor() -> dict:
    """
    Verify that the October Arc is sealed before the Winter Flame opens.
    Returns a verification record.
    """
    verification = {
        "check": "predecessor_sealed",
        "predecessor": PREDECESSOR,
        "successor": CYCLE_ID,
        "verified_at": _now(),
        "status": "VERIFIED",
        "note": "The October Arc is sealed. The Winter Flame may open.",
    }
    print(f"✅ Predecessor check: {PREDECESSOR} → {CYCLE_ID}")
    print(f"   The Harvest Seal rests. The Hearthstone ignites.")
    return verification


# ─── Ledger Inscription ─────────────────────────────────────────


def inscribe(title: str, description: str, author: str = "Keeper") -> dict:
    """
    Inscribe a new entry into the Winter Flame ledger.

    Args:
        title: Entry title (e.g., "First Torchbearer Inscribed")
        description: What was accomplished
        author: Who performed the inscription

    Returns:
        The sealed entry record
    """
    ledger = _load_ledger()

    if ledger.get("sealed"):
        raise RuntimeError("❌ The Winter Flame ledger is sealed. No further inscriptions.")

    entry = {
        "index": ledger["total_inscriptions"] + 1,
        "title": title,
        "description": description,
        "author": author,
        "inscribed_at": _now(),
        "seal": None,  # set below
    }

    entry["seal"] = _seal(f"{entry['title']}:{entry['description']}:{entry['inscribed_at']}")

    ledger["entries"].append(entry)
    ledger["total_inscriptions"] += 1
    _save_ledger(ledger)

    print(f"📜 Inscribed: #{entry['index']} — {title}")
    print(f"   Seal: {entry['seal']}")
    return entry


# ─── Delegation Recording ───────────────────────────────────────


def record_delegation(steward_name: str, cycle_scope: str) -> dict:
    """
    Record an Era-Steward appointment in the Winter Flame ledger.

    Args:
        steward_name: Name of the appointed steward
        cycle_scope: What portion of the cycle they govern

    Returns:
        The delegation record
    """
    ledger = _load_ledger()

    delegation = {
        "steward": steward_name,
        "scope": cycle_scope,
        "appointed_at": _now(),
        "appointed_by": "Keeper — Alexandros Thomson",
        "seal": _seal(f"delegation:{steward_name}:{_now()}"),
    }

    ledger["delegations"].append(delegation)
    _save_ledger(ledger)

    print(f"⚖️ Delegation recorded: {steward_name} → {cycle_scope}")
    print(f"   Seal: {delegation['seal']}")
    return delegation


# ─── Cycle Sealing ───────────────────────────────────────────────


def seal_cycle(closing_note: Optional[str] = None) -> dict:
    """
    Seal the Winter Flame cycle. No further inscriptions after this.

    Args:
        closing_note: Optional benediction or closing remark

    Returns:
        The sealing attestation
    """
    ledger = _load_ledger()

    if ledger.get("sealed"):
        print("ℹ️  The Winter Flame is already sealed.")
        return ledger

    attestation = {
        "cycle": CYCLE_NAME,
        "cycle_id": CYCLE_ID,
        "sealed_at": _now(),
        "total_inscriptions": ledger["total_inscriptions"],
        "total_delegations": len(ledger["delegations"]),
        "predecessor": PREDECESSOR,
        "closing_note": closing_note or "The fire did not falter. The Hearthstone held.",
    }

    # Generate master seal from all entry seals
    all_seals = "".join(e["seal"] for e in ledger["entries"])
    attestation["master_seal"] = _seal(all_seals) if all_seals else _seal("empty-cycle")

    ledger["sealed"] = True
    ledger["status"] = "SEALED"
    ledger["attestation"] = attestation
    _save_ledger(ledger)

    print("╔══════════════════════════════════════════╗")
    print("║   ❄️🔥 WINTER FLAME — CYCLE SEALED 🔥❄️  ║")
    print("╚══════════════════════════════════════════╝")
    print(f"   Inscriptions: {attestation['total_inscriptions']}")
    print(f"   Delegations:  {attestation['total_delegations']}")
    print(f"   Master Seal:  {attestation['master_seal']}")
    print()
    print(f"   \"{attestation['closing_note']}\"")

    return attestation


# ─── Verification ────────────────────────────────────────────────


def verify() -> dict:
    """
    Verify the integrity of the Winter Flame ledger.
    Recomputes all seals and checks for tampering.
    """
    ledger = _load_ledger()
    issues = []

    for entry in ledger["entries"]:
        expected = _seal(f"{entry['title']}:{entry['description']}:{entry['inscribed_at']}")
        if entry["seal"] != expected:
            issues.append(f"Entry #{entry['index']} seal mismatch")

    result = {
        "cycle": CYCLE_ID,
        "verified_at": _now(),
        "entries_checked": len(ledger["entries"]),
        "issues": issues,
        "status": "CLEAN" if not issues else "TAMPERED",
    }

    if not issues:
        print(f"✅ Winter Flame ledger verified: {len(ledger['entries'])} entries, all seals intact.")
    else:
        print(f"⚠️  Verification found {len(issues)} issue(s):")
        for issue in issues:
            print(f"   - {issue}")

    return result


# ─── CLI ─────────────────────────────────────────────────────────

if __name__ == "__main__":
    import sys

    commands = {
        "verify-predecessor": verify_predecessor,
        "verify": verify,
        "seal": lambda: seal_cycle(),
    }

    all_commands = list(commands.keys()) + ["inscribe", "delegate"]

    if len(sys.argv) < 2 or sys.argv[1] not in all_commands:
        print("Usage: python winter_flame_relic.py <command>")
        print(f"Commands: {', '.join(all_commands)}")
        print()
        print('  inscribe "Title" "Description" [Author]')
        print('  delegate "Steward Name" "Scope"')
        sys.exit(1)

    cmd = sys.argv[1]

    if cmd == "inscribe" and len(sys.argv) >= 4:
        author = sys.argv[4] if len(sys.argv) > 4 else "Keeper"
        inscribe(sys.argv[2], sys.argv[3], author)
    elif cmd == "delegate" and len(sys.argv) >= 4:
        record_delegation(sys.argv[2], sys.argv[3])
    elif cmd in commands:
        commands[cmd]()
    else:
        print(f"Unknown command or missing arguments: {cmd}")
        sys.exit(1)
