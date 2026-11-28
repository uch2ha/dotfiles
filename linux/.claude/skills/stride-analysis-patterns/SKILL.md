---
name: stride-analysis-patterns
description: "Threat-model a system or feature with STRIDE: data-flow diagram, trust boundaries, threats per element, risk scoring and a mitigation roadmap. Use when asked for a threat model, STRIDE analysis, or a security architecture review."
metadata:
  source:
    repo: "github.com/wshobson/agents"
    path: "plugins/security-scanning/skills/stride-analysis-patterns"
    commit: "c96b5f6552dba32e4492307493ee613581430715"
    license: "MIT"
    checked: "2026-11-27"
---

# STRIDE Analysis Patterns

Systematic threat identification using the STRIDE methodology.

## When to Use This Skill

- Starting new threat modeling sessions
- Analyzing existing system architecture
- Reviewing security design decisions
- Creating threat documentation
- Training teams on threat identification
- Compliance and audit preparation

## Core Concepts

### 1. STRIDE Categories

```
S - Spoofing       → Authentication threats
T - Tampering      → Integrity threats
R - Repudiation    → Non-repudiation threats
I - Information    → Confidentiality threats
    Disclosure
D - Denial of      → Availability threats
    Service
E - Elevation of   → Authorization threats
    Privilege
```

### 2. Threat Analysis Matrix

| Category            | Question                                  | Control Family |
| ------------------- | ----------------------------------------- | -------------- |
| **Spoofing**        | Can attacker pretend to be someone else?  | Authentication |
| **Tampering**       | Can attacker modify data in transit/rest? | Integrity      |
| **Repudiation**     | Can attacker deny actions?                | Logging/Audit  |
| **Info Disclosure** | Can attacker access unauthorized data?    | Encryption     |
| **DoS**             | Can attacker disrupt availability?        | Rate limiting  |
| **Elevation**       | Can attacker gain higher privileges?      | Authorization  |

## Templates and detailed worked examples

Full template library lives in `references/details.md`. Read that file when you need concrete templates for this skill.

## Best Practices

### Do's

- **Involve stakeholders** - Security, dev, and ops perspectives
- **Be systematic** - Cover all STRIDE categories
- **Prioritize realistically** - Focus on high-impact threats
- **Update regularly** - Threat models are living documents
- **Use visual aids** - DFDs help communication

### Don'ts

- **Don't skip categories** - Each reveals different threats
- **Don't assume security** - Question every component
- **Don't work in isolation** - Collaborative modeling is better
- **Don't ignore low-probability** - High-impact threats matter
- **Don't stop at identification** - Follow through with mitigations
