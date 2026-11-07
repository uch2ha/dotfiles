---
name: typescript-patterns
description: Strict TypeScript conventions for the frontend. Use when writing or reviewing TS code.
---

# TypeScript patterns

- `strict: true`; no `any` (use `unknown` and narrow). Avoid `as` casts; validate API data at the boundary (e.g. zod) if the backend contract is not generated.
- Model states with discriminated unions (`{status:'loading'} | {status:'ok', data}`), not parallel booleans.
- `type` for shapes/unions, `interface` for extendable object contracts; export types next to their module.
- Money is a string (or decimal-library value) end to end; never `number` for amounts. Dates are ISO `string`s, converted at the edges.
- Prefer `readonly` and immutable updates; no mutation of props or state.
- Exhaustive `switch` with a `never` check on unions.
- Small modules with named exports; no barrel files that hide cycles.
- Async: `async/await`, always handle rejection at a boundary; type error cases.
