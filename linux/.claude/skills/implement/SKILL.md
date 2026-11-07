---
name: implement
description: "Implement a piece of work from a spec in docs/specs/, a requirements doc section, or the user's description."
disable-model-invocation: true
---

Implement the work described by the user. The source is a spec file in `docs/specs/`, a section of `REQUIREMENTS.md`, or the conversation. State which one you are using before starting; if ambiguous, ask.

Call the Skill tool with "tdd" where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full suite once at the end:
- Use the test/build commands from the repo AGENTS.md (e.g. `./mvnw test`, `npm test`)

Once done, call the Skill tool with "code-review" to review the work.

Do not commit or push unless the user asks.
