---
name: react-patterns
description: React + TypeScript component conventions, mobile-first. Use when writing or reviewing frontend components.
---

# React patterns

- Mobile-first: write base styles for a phone, add `min-width` breakpoints upward. Touch targets ≥ 44px. Check every screen at ~375px width.
- Function components and hooks only. Hooks at top level; effects are for syncing with outside systems, not for deriving state (derive during render).
- State lives at the lowest component that needs it; lift only when siblings share it. Server data uses one data-fetching approach (e.g. TanStack Query) rather than hand-rolled `useEffect` fetches.
- API layer: one `api/` module of typed functions; components never call `fetch` directly.
- Money arrives from the API as a string/decimal; format with `Intl.NumberFormat`; never do float arithmetic on it. Dates are ISO strings; parse/format in one util.
- Each list item has a stable `key` (id, not index). Memoise (`useMemo`/`memo`) only after measuring.
- Forms: controlled inputs, labels tied to inputs, validation messages next to fields.
- Wrap route-level areas in an error boundary; show loading and empty states explicitly.
