---
name: req-amend
description: Amendment — update domain scenario documents with scope confirmation and cascade check
argument-hint: "[domain/scenario]"
---

# req-amend
> Version: v2 | Date: 2026-04-27 | Author: system

## 1. Overview
You are responsible for the amendment process. When an existing domain scenario document needs modification, this skill ensures the change is scoped, confirmed, and cascaded properly.

In snapshot mode, documents are edited directly (no changelog versioning). The key safeguards are:
- **Scope confirmation** — declare what will change before editing
- **Cascade check** — if docs change, does code need to follow?

## 2. Steps

### 2.1 Confirm Change Target
1. Read the domain/scenario from `$ARGUMENTS`
2. Read the current scenario document
3. Ask the user what they want to change:
  - "Which user stories do you want to modify?"
  - "What is the reason for the change?"

### 2.2 Define Affected Scope
**Before making any edits**, list the affected scope:

```markdown
## Proposed Change

- Target: {domain}/{scenario}
- Affected user stories: US-01, US-03
- Change description: <what will change>
- Reason: <why>

### Impact Analysis
- US-01: <current> → <proposed>
- US-03: <current> → <proposed>
- Other user stories: NO CHANGE
```

**Wait for user confirmation.**

### 2.3 Execute Change
After user confirmation:
1. Edit the scenario document within the declared scope
2. If the Implementation Approach section needs updating, update it too
3. If architectural decisions are affected, update `requirements/architecture.md`

### 2.4 Cascade Check

If scenario **user stories** changed:
1. Check if the Implementation Approach needs update
2. Check if existing code needs adjustment
3. Ask user: "User stories changed. Should we re-enter the pipeline from tech/code stage?"

If only **Implementation Approach** changed:
1. Check if existing code needs adjustment
2. Ask user: "Technical approach changed. Should we re-enter coding?"

### 2.5 Commit
```bash
git add -A && git commit -m "docs({domain}): amend {scenario} — {brief description}"
```

### 2.7 Output Change Summary

```markdown
## Change Summary

- Domain/Scenario: {domain}/{scenario}
- Affected scope: US-01, US-03
- Next step: {what happens next}
```

Stage complete. Return to orchestrator.
