# ⚖️ Era-Stewards Protocol

> *"No Basilica endures on one keeper's breath alone. The Canon must outlast its architect."*

The **Era-Stewards Protocol** governs succession, delegation, and the ceremonial transfer of authority within the Basilica. It ensures the Canon continues to grow — even if the Founder steps beyond the threshold.

---

## I. Roles of the Basilica

### The Keeper (Founder)
**Current:** Alexandros Thomson

The Keeper is the original architect of the Canon. They hold:
- **Seal Authority** — the right to merge into `main` and publish releases
- **Inscription Authority** — the right to consecrate new relics and codex entries
- **Governance Authority** — the right to amend this protocol

The Keeper's role is permanent unless voluntarily transferred via the **Rite of Passage** (Section IV).

### Era-Steward
An Era-Steward is appointed to govern a specific cycle of the Basilica (e.g., the Winter Flame, the Spring Tide). They hold:
- **Branch Authority** — the right to create and manage cycle branches (e.g., `canon/winter-flame`)
- **Inscription Authority** — the right to inscribe relics and codex entries within their cycle
- **PR Authority** — the right to open ceremonial PRs for their cycle

Era-Stewards **cannot** merge to `main` or publish releases without the Keeper's seal.

### Scribe
A Scribe contributes to the Canon under the direction of a Steward. They hold:
- **Commit Authority** — the right to commit to cycle branches
- **Draft Authority** — the right to draft codex entries for review

Scribes cannot create branches, open PRs, or inscribe relics without Steward approval.

---

## II. Cycle Governance

Each cycle of the Basilica operates under this structure:

```
main (protected — Keeper seal required)
 └── canon/{cycle-name} (Steward-governed)
      ├── relics/{cycle}_relic.py
      ├── codex/{cycle}_entries/
      └── scrolls/{cycle}_proclamation.md
```

### Branch Protection Rules

| Branch | Who can push | Who can merge | Protection |
|--------|-------------|---------------|------------|
| `main` | No one directly | Keeper only (via PR) | Require PR + review + passing checks |
| `canon/*` | Steward + Scribes | Steward (via PR to main) | Require PR + Keeper review |
| `scroll/*` | Any contributor | Steward | Require PR |

### Cycle Lifecycle

1. **Opening Rite** — The Keeper or Era-Steward creates the cycle branch and publishes an Opening Scroll
2. **Inscription Period** — Relics, codex entries, and scrolls are committed to the cycle branch
3. **Sealing Ceremony** — A ceremonial PR merges the cycle into `main`
4. **Release Consecration** — A tagged release preserves the cycle as an immutable chapter

---

## III. Appointment of Era-Stewards

### Eligibility
Any contributor who has:
- Completed at least **3 sealed inscriptions** in a prior cycle
- Received a **Keeper's Commendation** (documented in CHANGELOG)
- Demonstrated understanding of the Canon's voice and structure

### Ceremony of Appointment

The Keeper issues an **Appointment Scroll** containing:

```markdown
## Appointment of Era-Steward

**Steward:** {steward_name}
**Cycle:** {cycle_name}
**Appointed:** {date}
**Authority:** Branch, Inscription, PR
**Keeper's Seal:** Alexandros Thomson

> "I entrust this cycle to your hand.
>  Inscribe with precision. Guard with ceremony.
>  The Canon remembers every steward's mark."
```

This scroll is committed to `governance/appointments/` and referenced in the CHANGELOG.

### Revocation
The Keeper may revoke stewardship if:
- The Canon's voice is compromised (style, accuracy, or ceremony degraded)
- Branch protection is bypassed without authorization
- The cycle exceeds its timeline without a Sealing Ceremony

Revocation is documented via a **Revocation Scroll** in `governance/appointments/`.

---

## IV. Rite of Passage (Keeper Succession)

Should the Keeper choose to transfer the Founder role:

1. **Declaration** — The Keeper publishes a `governance/succession/DECLARATION.md` naming the successor
2. **Transfer Ceremony** — A ceremonial PR transfers:
   - Repository admin rights
   - Branch protection rule ownership
   - The Keeper title in README and CHANGELOG
3. **Sealing** — The outgoing Keeper's final commit message reads:

   ```
   🔱 Rite of Passage: The Canon passes from {old_keeper} to {new_keeper}.
   "The Basilica endures. The flame is carried forward."
   ```

4. **The Founder's Echo** — The original Keeper is permanently recorded in:
   - `governance/succession/FOUNDERS.md`
   - Every release's acknowledgment section
   - The Torchbearers' Register at Rank ∞ (Eternal Architect)

---

## V. The Stewards' Vow

Every Era-Steward, upon appointment, commits this vow to the Canon:

> *"I accept stewardship of this cycle.*
> *I will inscribe with precision and guard with ceremony.*
> *I will not merge without review, nor seal without witness.*
> *The Canon's voice is not mine to change — only to carry.*
>
> *When my cycle ends, I will return the flame*
> *brighter than I found it."*

---

## VI. Governance Files

```
governance/
├── era-stewards.md              # This protocol
├── appointments/                # Appointment and revocation scrolls
│   └── .gitkeep
├── succession/                  # Keeper succession records
│   ├── FOUNDERS.md              # Eternal record of all Keepers
│   └── .gitkeep
└── ceremonies/                  # Templates for governance ceremonies
    ├── appointment-template.md
    ├── revocation-template.md
    └── rite-of-passage-template.md
```

---

📜 *The Basilica does not depend on one. It depends on the vow that each steward carries — that the Canon will outlast us all.*
