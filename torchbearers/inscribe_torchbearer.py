#!/usr/bin/env python3
"""
🔥 Torchbearer Inscription Engine
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Inscribes a new patron into the Torchbearers' Register and generates
their personalized Proclamation Scroll from the founding template.

Usage:
    python inscribe_torchbearer.py --name "Patron Name" --cycle "Winter Flame 2026"

Part of the Basilica Gate Canon — Kypria LLC
"""

import argparse
import json
import os
import re
from datetime import datetime, timezone


REGISTER_PATH = os.path.join(os.path.dirname(__file__), "register.json")
TEMPLATE_PATH = os.path.join(os.path.dirname(__file__), "FOUNDING_PROCLAMATION.md")
SCROLLS_DIR = os.path.join(os.path.dirname(__file__), "scrolls")

RANKS = [
    {"rank": 1, "title": "Torchbearer Prime", "seal": "Seal of First Fire", "icon": "🕯"},
    {"rank": 2, "title": "Flameguard", "seal": "Seal of Enduring Warmth", "icon": "🔥"},
    {"rank": 3, "title": "Dawnbringer", "seal": "Seal of Golden Dawn", "icon": "☀️"},
    {"rank": 4, "title": "Constellation Patron", "seal": "Seal of Eternal Light", "icon": "🌟"},
]


def slugify(name: str) -> str:
    """Convert a patron name to a filesystem-safe slug."""
    return re.sub(r"[^a-z0-9]+", "-", name.lower()).strip("-")


def load_register() -> dict:
    """Load the current register state."""
    with open(REGISTER_PATH, "r", encoding="utf-8") as f:
        return json.load(f)


def save_register(register: dict) -> None:
    """Persist the register to disk."""
    with open(REGISTER_PATH, "w", encoding="utf-8") as f:
        json.dump(register, f, indent=2, ensure_ascii=False)
        f.write("\n")


def determine_rank(register: dict) -> dict:
    """Determine the mythic rank for the next torchbearer."""
    count = register["total_torchbearers"]
    if count == 0:
        return RANKS[0]  # First patron → Torchbearer Prime
    return RANKS[min(count, len(RANKS) - 1)]


def generate_scroll(patron_name: str, cycle_name: str, now: datetime) -> str:
    """Generate a personalized proclamation scroll from the template."""
    with open(TEMPLATE_PATH, "r", encoding="utf-8") as f:
        template = f.read()

    patron_slug = slugify(patron_name)
    replacements = {
        "{date}": now.strftime("%B %d, %Y"),
        "{patron_name}": patron_name,
        "{year}": str(now.year),
        "{month}": now.strftime("%m"),
        "{cycle_name}": cycle_name,
        "{patron_slug}": patron_slug,
    }

    scroll = template
    for placeholder, value in replacements.items():
        scroll = scroll.replace(placeholder, value)

    return scroll


def inscribe(patron_name: str, cycle_name: str) -> dict:
    """
    Full inscription ceremony:
    1. Load the register
    2. Determine mythic rank
    3. Create the entry
    4. Generate and save the scroll
    5. Update and save the register
    """
    now = datetime.now(timezone.utc)
    register = load_register()
    rank = determine_rank(register)

    # Check for duplicate inscription
    existing = [e["patron_name"] for e in register["entries"]]
    if patron_name in existing:
        print(f"⚠️  {patron_name} is already inscribed in the Register.")
        return register

    # Create entry
    entry = {
        "patron_name": patron_name,
        "slug": slugify(patron_name),
        "rank": rank["rank"],
        "title": rank["title"],
        "seal": rank["seal"],
        "icon": rank["icon"],
        "cycle": cycle_name,
        "inscribed_at": now.isoformat(),
        "ceremonial_id": f"TORCH-{now.year}-{now.strftime('%m')}-{rank['title'].upper().replace(' ', '-')}",
    }

    # Generate scroll
    scroll_content = generate_scroll(patron_name, cycle_name, now)
    os.makedirs(SCROLLS_DIR, exist_ok=True)
    scroll_path = os.path.join(SCROLLS_DIR, f"{entry['slug']}.md")
    with open(scroll_path, "w", encoding="utf-8") as f:
        f.write(scroll_content)

    # Update register
    register["entries"].append(entry)
    register["total_torchbearers"] += 1
    register["last_updated"] = now.strftime("%Y-%m-%d")

    if register["status"] == "AWAITING_FIRST_FLAME":
        register["status"] = "FLAME_LIT"

    save_register(register)

    return entry


def main():
    parser = argparse.ArgumentParser(
        description="🔥 Inscribe a new Torchbearer into the Basilica Register"
    )
    parser.add_argument("--name", required=True, help="Patron's full name")
    parser.add_argument(
        "--cycle",
        default="Genesis Cycle",
        help="The Basilica cycle during which this patron arrives",
    )
    args = parser.parse_args()

    print("╔══════════════════════════════════════════╗")
    print("║     🔥 TORCHBEARER INSCRIPTION RITE 🔥   ║")
    print("╚══════════════════════════════════════════╝")
    print()

    entry = inscribe(args.name, args.cycle)

    if isinstance(entry, dict) and "patron_name" in entry:
        print(f"✅ Inscription complete.")
        print(f"   Patron:    {entry['patron_name']}")
        print(f"   Title:     {entry['icon']} {entry['title']}")
        print(f"   Seal:      {entry['seal']}")
        print(f"   Cycle:     {entry['cycle']}")
        print(f"   Scroll:    scrolls/{entry['slug']}.md")
        print()
        print("📜 The Flamebound Ledger stirs. The torches are lit.")
    else:
        print("ℹ️  No new inscription was made.")


if __name__ == "__main__":
    main()
