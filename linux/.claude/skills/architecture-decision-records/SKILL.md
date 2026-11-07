---
name: architecture-decision-records
description: Record significant decisions as ADRs in docs/adr/. Use when a trade-off is chosen (library, data model, schedule rule design) or the user says "record this decision".
---

# ADRs

- Files: `docs/adr/NNNN-short-title.md`, numbered, never rewritten; a changed decision gets a new ADR that supersedes the old (set the old one's status to `Superseded by NNNN`).
- Template:
```
# NNNN. Title
Status: Proposed | Accepted | Superseded by NNNN
## Context  (forces, constraints, in 3-6 lines)
## Decision (what we chose, one paragraph)
## Alternatives (each with why not)
## Consequences (good and bad)
```
- Record only decisions that are hard to reverse or that a future reader would ask "why?" about. Skip the obvious.
- Check `docs/adr/` before proposing something an ADR already settled.
- Pair with the `domain-modeling` skill for terminology; ADRs are for decisions, `GLOSSARY.md` for terms.
