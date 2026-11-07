---
name: react-testing
description: Frontend testing with Vitest, React Testing Library and MSW. Use when writing or fixing component, hook or page tests.
---

# React testing

- Runner: Vitest + React Testing Library + `@testing-library/user-event`. Run `npm test`; `npm run build` must also pass.
- Test what the user sees and does. Query by role/label/text (`getByRole`, `getByLabelText`), not by class or test id unless nothing else works.
- Use `await userEvent.click(...)`, and `findBy*`/`waitFor` for async; no arbitrary timeouts.
- Mock the network with MSW at the HTTP boundary, not by mocking our own modules.
- No snapshot tests for components; assert specific output.
- Money/date formatting: assert the rendered strings with invented amounts.
- Pure helpers (formatters, year-page calculations done client-side) get plain unit tests.
- Keep a11y in the tests: finding by role doubles as an accessibility check.
