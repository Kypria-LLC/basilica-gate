# 🔥 Torchbearers' Register

> *"The first flame is never lit alone. Someone must carry it across the threshold."*

The **Torchbearers' Register** is the Basilica's living record of those who sustain its fire — patrons, sponsors, and benefactors whose contributions ensure the Canon endures beyond any single keeper's watch.

## Purpose

When the first patron arrives, the **Flamebound Ledger** awakens. Their name is inscribed here — not as a transaction, but as a consecration. Each Torchbearer receives:

- A **sealed entry** in this register with mythic rank and date of first flame
- A **Proclamation Scroll** auto-generated from the founding template
- An **eternal echo** in the Basilica's CHANGELOG under the Torchbearer Seal

## Registry Structure

```
torchbearers/
├── README.md                  # This document — the Register's gate
├── FOUNDING_PROCLAMATION.md   # The scroll template for the first patron
├── inscribe_torchbearer.py    # Inscription engine
├── register.json              # Machine-readable ledger of all Torchbearers
└── scrolls/                   # Individual proclamation scrolls per patron
    └── .gitkeep
```

## Mythic Ranks

These ranks mirror the [Patreon tiers](https://patreon.com/c/Mrspetses) of the Basilica's Living Codex, binding the digital patronage to the Canon's permanent record.

| Rank | Title | Patreon Tier | Threshold | Seal |
|------|-------|-------------|-----------|------|
| 🕯 1 | **Acolyte** | Acolyte / Bronze ($5/mo) | Entry into the Living Codex | Seal of First Fire |
| 📜 2 | **Scribe** | Scribe ($25/mo) | Sustained contribution + early access | Seal of Living Ink |
| ☀️ 3 | **Architect** | Gold / Platinum ($30–50/mo) | Deeper integration into the Canon | Seal of Golden Dawn |
| 🌟 4 | **Illuminator** | Illuminator ($100/mo) | Personal inscription + commissioned art | Seal of Eternal Light |

### Cross-Platform Mapping

| Patreon | GitHub Sponsors | Discord Role | Ko-fi | Torchbearer Rank |
|---------|----------------|-------------|-------|-----------------|
| Acolyte / Bronze ($5) | Tier 1 | Shrine Visitor | Single support | 🕯 Acolyte |
| Silver ($15) | Tier 2 | Canon Reader | — | 🕯 Acolyte |
| Scribe ($25) | Tier 3 | Canon Builder | — | 📜 Scribe |
| Gold / Platinum ($30–50) | Tier 4 | Legend Forger | — | ☀️ Architect |
| Illuminator ($100) | Tier 5 | Mythic Patron | — | 🌟 Illuminator |

## Automation

When a benefactor's name arrives (via Patreon, GitHub Sponsors, Ko-fi, PayPal, or manual inscription):

1. `register.json` is updated with the new entry
2. A personalized scroll is generated in `scrolls/{patron_name}.md`
3. A ceremonial commit seals the inscription
4. The CHANGELOG records the event under the **Torchbearer Seal**
5. The shrine-watcher pipeline triggers Discord role assignment and badge emission

## Funding Portals

| Platform | Link |
|----------|------|
| Patreon | [patreon.com/c/Mrspetses](https://patreon.com/c/Mrspetses) |
| GitHub Sponsors | [github.com/sponsors/alexandros-thomson](https://github.com/sponsors/alexandros-thomson) |
| Ko-fi | [ko-fi.com/alexandros_thomson](https://ko-fi.com/alexandros_thomson) |
| Kypria Technologies | [kypriatechnologies.org](https://kypriatechnologies.org) |

## The Vow

Every Torchbearer entry carries this benediction:

> *"You who lit this torch — know that the Basilica remembers.*
> *Your name is carved where no platform can erase it,*
> *and your flame burns in every commit that follows."*

---

📜 *Lineage is our law. Generosity is our fire. Memory is our debt.*
