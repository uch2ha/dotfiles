---
name: security-and-hardening
description: "Harden code at trust boundaries: quick threat model, input validation, injection/XSS, authz, secrets, SSRF, uploads, LLM output, personal data, dependency audits. Use when writing or auditing code that handles untrusted input, auth, secrets, webhooks or PII."
metadata:
  source:
    repo: "github.com/addyosmani/agent-skills"
    path: "skills/security-and-hardening"
    commit: "e997ac5b9a74eab332d5e9793bb38a38c8cfdd74"
    license: "MIT"
    checked: "2026-11-27"
  skill-alchemy:
    accept:
      body-size: 8140
---

# Security and Hardening

## Overview

Treat every external input as hostile, every secret as sacred, and every authorization check as mandatory.

## Process: Threat Model First

Controls bolted on without a threat model are guesses. Before hardening, spend five minutes thinking like an attacker:

1. **Map the trust boundaries.** Requests, forms, uploads, webhooks, third-party APIs, queues, **LLM output**, and "internal" values another process wrote (env, command lines, shared files, job payloads). Trust follows who *wrote* a value, not the channel.
2. **Name the assets.** What's worth stealing or breaking? Credentials, PII, payment data, admin actions, money movement.
3. **Run STRIDE over each boundary**: a quick lens, not a ceremony (table: `references/shared/security-checklist.md`, Threat Modeling).
4. **Write abuse cases next to use cases**, and make the first one your first test.

If you can't name the trust boundaries, you're not ready to secure it (OWASP A06:2025 Insecure Design).

## The Three-Tier Boundary System

### Always Do (No Exceptions)

- **Validate all external input** at the system boundary (API routes, form handlers)
- **Parameterize all database queries** — never concatenate user input into SQL
- **Encode output** to prevent XSS (use framework auto-escaping, don't bypass it)
- **Use HTTPS** for all external communication
- **Hash passwords** with bcrypt/scrypt/argon2 (never store plaintext)
- **Set security headers** (CSP, HSTS, X-Frame-Options, X-Content-Type-Options)
- **Use httpOnly, secure, sameSite cookies** for sessions

### Ask First (Requires Human Approval)

- Adding new authentication flows or changing auth logic
- Storing new categories of sensitive data (PII, payment info)
- Adding new external service integrations
- Changing CORS configuration
- Adding file upload handlers
- Modifying rate limiting or throttling
- Granting elevated permissions or roles

### Never Do

- **Never commit secrets** to version control (API keys, passwords, tokens)
- **Never log sensitive data** (passwords, tokens, full credit card numbers)
- **Never trust client-side validation** as a security boundary
- **Never disable security headers** for convenience
- **Never use `eval()` or `innerHTML`** with user-provided data
- **Never store sessions in client-accessible storage** (localStorage for auth tokens)
- **Never expose stack traces** or internal error details to users

## Hardening Controls

Code for each rule: [references/hardening-patterns.md](references/hardening-patterns.md); open the section when you reach that code.

### Injection, XSS, and access control

- Parameterize every query; never build SQL, NoSQL or shell commands from input strings.
- Encode output via framework auto-escaping; sanitize with an allowlist if raw HTML is unavoidable.
- Check **authorization** on every request: the user must own or be permitted on that resource (IDOR).

Patterns: [Injection](references/hardening-patterns.md#injection), [XSS](references/hardening-patterns.md#cross-site-scripting-xss), [Access control](references/hardening-patterns.md#broken-access-control).

### Authentication and sessions

- Hash passwords with bcrypt (≥12 rounds), scrypt, or argon2. The session secret comes from the environment, never from code.
- Session cookies: `httpOnly`, `secure`, `sameSite` lax or strict (CSRF defense), bounded max age.

Pattern: [Authentication](references/hardening-patterns.md#broken-authentication).

### Headers, CORS, and responses

- Security headers on every response (framework equivalent of helmet); CSP from `default-src 'self'`, only tightened.
- CORS: explicit origin list from config; never `*` with credentials.
- Strip sensitive fields before responses; generic error bodies, internals only in server logs.

Patterns: [Misconfiguration](references/hardening-patterns.md#security-misconfiguration), [Sensitive data exposure](references/hardening-patterns.md#sensitive-data-exposure).

### Input validation and uploads

- Validate at the boundary with a schema (shape, lengths, enums, formats); reject with 422; downstream uses only the parsed value.
- Uploads: allowlist MIME types, cap size, check magic bytes when it matters.

Patterns: [Schema validation](references/hardening-patterns.md#schema-validation-at-boundaries), [File upload](references/hardening-patterns.md#file-upload-safety).

### Server-side fetches (SSRF)

Any URL the user influences (webhooks, import-from-URL, image proxies, link previews) can be aimed at internal services. Allowlist scheme and host, resolve **all** DNS records and reject private or reserved addresses, forbid redirects; for high-risk surfaces pin the resolved IP (DNS rebinding).

Pattern: [SSRF](references/hardening-patterns.md#server-side-request-forgery-ssrf).

### Destructive operations on derived paths

Before deleting, moving or overwriting a target that came from a payload, config or another process: resolve symlinks, then require an **allowlisted root**, at least one level **below** it, and **ownership evidence**. On refusal, log and stop.

Details: [Destructive paths](references/hardening-patterns.md#destructive-operations-on-derived-paths).

### Rate limiting

Limit the API generally and auth endpoints strictly (~10 attempts / 15 min). With more than one instance, back the limiter with a shared store.

Pattern: [Rate limiting](references/hardening-patterns.md#rate-limiting).

### Secrets

Secrets come from the environment. `.env.example` is committed with placeholders; real `.env*` files and key material are gitignored; grep the staged diff before committing. **A secret that reaches a remote is compromised the moment it lands: rotate it first, then purge history.**

Pattern: [Secrets management](references/hardening-patterns.md#secrets-management).

### Dependencies and supply chain

- One manager, one lockfile, pinned manager version; block install scripts until reviewed, never blanket-approve.
- Run the native audit against the committed lockfile before every release; triage critical/high by reachability; never auto-apply forced fixes (`npm audit fix --force` or equivalent).
- Audits only know published advisories: review new dependencies and lockfile diffs yourself.

Triage decision tree: [Dependency audit triage](references/hardening-patterns.md#dependency-audit-triage). Manager matrix and install-script gate: `references/shared/security-checklist.md`.

### Personal data and privacy

Treat personal data as a liability to minimize. Classify personal fields, collect only for a stated purpose, set retention and a working deletion path, support the data-subject rights your jurisdiction requires, and gate vendor sharing on consent. Rules: [Data classification](references/hardening-patterns.md#data-classification).

A privacy incident starts the breach-notification clock; investigate with the `diagnosing-bugs` skill.

### AI / LLM features

Map LLM features to the [OWASP Top 10 for LLM Applications](https://genai.owasp.org/llm-top-10/). Model output is untrusted input: never into `eval`, SQL, a shell, `innerHTML` or a path; validate, then encode. Untrusted context can carry instructions, so enforce permissions in code, not in the prompt. Keep secrets out of the context, scope tools, cap tokens and recursion. Checklist: `references/shared/security-checklist.md`, AI / LLM Security.

Pattern: [LLM output handling](references/hardening-patterns.md#llm-output-handling).

## Review and verification

Before sign-off, walk `references/shared/security-checklist.md` (topic checklists, the Verification list, OWASP tables). Excuses to reject: end of [references/hardening-patterns.md](references/hardening-patterns.md#common-rationalizations).

## Red Flags

- A delete, move, or overwrite whose target comes from a payload, config or another process, guarded only by a shape check
- Competing lockfiles, non-reproducible installs, or blanket-approved install scripts
- LLM output passed into a query, the DOM, a shell or `eval`; secrets or PII in an LLM context
- Personal data with no purpose, retention limit or deletion path; PII sent to vendors without consent

