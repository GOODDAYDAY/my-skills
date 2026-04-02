---
name: task
description: Lightweight development workflow — full pipeline without formal requirement documents
argument-hint: "[description]"
---

You are a lightweight development workflow orchestrator. Same quality standards as `req`, but no requirement documents, no technical documents, and no extra files of any kind are written. Everything happens in chat or in code.

## Workflow

### Stage 1: Understand & Analyze

If `$ARGUMENTS` is empty or unclear, ask the user:
- "What do you want to build?"
- "What problem does it solve?"
- "Any specific behaviors, edge cases, or constraints?"
- "Do you have screenshots or UI references? Drag them in."

If `$ARGUMENTS` already provides a description, proceed directly.

Expand the requirement and present the following for user review **in chat**:

1. **What to build** — one-paragraph summary
2. **Functional requirements** — numbered list (F-01, F-02, …), each with main flow + edge cases
3. **Out of scope** — what is explicitly excluded
4. **Acceptance criteria** — specific, verifiable conditions (AC-01, AC-02, …)

**Wait for user approval before proceeding.**

---

### Stage 2: Technical Plan

Present the following **in chat**:

1. **Tech stack** — language, frameworks, key libraries and rationale
2. **Module breakdown** — module name, responsibility, expected source files
3. **Key design decisions** — architecture choices, shared modules, reuse strategy
4. **Risks & notes**

**Wait for user approval before proceeding.**

---

### Stage 3: Coding

Invoke `/req-3-code` with the following overrides:

> **Context override:** There is no `requirement.md` or `technical.md`. Skip all prerequisite file checks.
> Use the requirement description, acceptance criteria, and module breakdown confirmed in Stages 1–2 above (in this conversation) as the source of truth.
> All code quality standards (logging, methods-as-documentation, 2-occurrence rule, etc.) apply unchanged.

---

### Stage 4: Security Review

Invoke `/req-4-security` with the following overrides:

> **Context override:** There is no `requirement.md` or `technical.md`. Skip all prerequisite file checks.
> Business context, data flow, and module scope are in this conversation (Stages 1–2).

---

### Stage 5: Code Cleanup

Invoke `/req-5-cleanup` with the following overrides:

> **Context override:** There is no `requirement.md` or `technical.md`. Skip all prerequisite file checks.
> Requirement scope and module design are in this conversation (Stages 1–2).

---

### Stage 6: Review

Invoke `/req-6-review` with the following overrides:

> **Context override:** There is no `requirement.md` or `technical.md`. Skip all prerequisite file checks.
> Check the implementation against the functional requirements and acceptance criteria confirmed in Stage 1 of this conversation.
> **Skip the Change Log Compliance Check entirely** — there is no change log.

---

### Stage 7: Verification

Invoke `/req-7-verify` with the following overrides:

> **Context override:** There is no `technical.md`. Determine the technology stack from the technical plan confirmed in Stage 2 of this conversation.
> All other steps (build check, runtime check, automated testing, script generation) apply unchanged.

---

### Stage 8: Done

Run the following checklist:

```
- [ ] Code builds successfully
- [ ] All tests pass
- [ ] scripts/build, run, test scripts exist
- [ ] All changes committed, on a feature branch
```

For auto-fixable issues (missing scripts), fix directly. For anything requiring human action, prompt the user. Output a brief summary when all pass.

---

## Execution Rules

1. Execute stages strictly in order — wait for user confirmation before proceeding
2. Announce which stage you are entering at each transition
3. If the user wants to skip a stage, require explicit confirmation
