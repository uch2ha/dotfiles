---
name: frontend-a11y
description: Accessibility rules for the React UI: forms, keyboard, focus, semantics. Use when building forms, modals, menus or tabs.
---

# Frontend accessibility

- Semantic elements first: `button`, `a`, `label`, `nav`, `main`, headings in order. A clickable `div` is a bug.
- Every input has a visible `<label htmlFor>`; errors linked with `aria-describedby`, announced via `role="alert"` or `aria-live`.
- Everything works by keyboard: logical tab order, visible focus ring, Escape closes dialogs.
- Modals: move focus in, trap it, restore it on close; use `<dialog>` or a tested library.
- Icon-only buttons need `aria-label`; images need `alt` (empty if decorative).
- Contrast ≥ 4.5:1 for text; do not convey meaning by colour alone (e.g. negative amounts also get a sign).
- Respect `prefers-reduced-motion`.
- Touch targets ≥ 44px; no horizontal page scroll at phone width.
- Prefer ARIA only when native HTML cannot do it.
