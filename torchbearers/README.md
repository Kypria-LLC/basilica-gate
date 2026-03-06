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
├── register.json              # Machine-readable ledger of all Torchbearers
└── scrolls/                   # Individual proclamation scrolls per patron
    └── .gitkeep
```

## Mythic Ranks

| Rank | Title | Threshold | Seal |
|------|-------|-----------|------|
| 🕯 1 | **Torchbearer Prime** | First patron to light the flame | Seal of First Fire |
| 🔥 2 | **Flameguard** | Sustained contribution across two cycles | Seal of Enduring Warmth |
| ☀️ 3 | **Dawnbringer** | Contribution that enables a new Era or system | Seal of Golden Dawn |
| 🌟 4 | **Constellation Patron** | Ongoing stewardship of the Basilica's growth | Seal of Eternal Light |

## Automation

When a benefactor's name arrives (via GitHub Sponsors, Stripe webhook, or manual inscription):

1. `register.json` is updated with the new entry
2. A personalized scroll is generated in `scrolls/{patron_name}.md`
3. A ceremonial commit seals the inscription
4. The CHANGELOG records the event under the **Torchbearer Seal**

## The Vow

Every Torchbearer entry carries this benediction:

> *"You who lit this torch — know that the Basilica remembers.*
> *Your name is carved where no platform can erase it,*
> *and your flame burns in every commit that follows."*

---

📜 *Lineage is our law. Generosity is our fire. Memory is our debt.*
