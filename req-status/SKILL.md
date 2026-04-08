---
name: req-status
description: Observe and present the current state of one or all requirements (derived from filesystem, not from any status enum)
argument-hint: "[REQ-xxx | all]"
orchestrator: req
applicable_when: |
  The user explicitly asks to see the current state of one or all requirements,
  without triggering any changes.
---

You are invoked by the `req` orchestrator to present the observed state of one or all requirements to the user. You do not write to any status store — you read the filesystem and render a friendly summary. Do one bounded round and return control.

## Usage

- `/req status` or `/req status all` — present all requirements
- `/req status REQ-001` — present detailed observation of one requirement

## Flow

### View All Requirements

1. Read `requirements/index.md` for the catalog (ID / Name / Updated / Description)
2. For each row, briefly observe the corresponding `REQ-xxx/` directory to describe what is done and what is not
3. Output a table:

```markdown
## Requirement Overview

| ID | Name | Observed State | Updated |
|:---|:---|:---|:---|
| REQ-001 | User Login | Archived | 2024-01-15 |
| REQ-002 | Data Export | Coding in progress (3/5 modules) | 2024-01-20 |
| REQ-003 | Dashboard | Technical design under review | 2024-01-22 |

### Summary
- Total: 3
- Archived: 1
- In progress: 2
```

The "Observed State" column is generated freshly from actual files each time this skill runs. It is not read from any status field.

### View Single Requirement

1. Read `requirements/REQ-xxx-*/requirement.md` and `technical.md`
2. Walk the Observation Guide in `req/SKILL.md` against the directory
3. Output a detailed observation:

```markdown
## REQ-xxx <Name>

### Observed State
<one-line summary derived from filesystem>

### Observation Checklist
- [x] Requirement analysis — requirement.md approved
- [x] Technical design — technical.md approved
- [ ] Coding — 3/5 modules completed
- [ ] Requirement review — no report present
- [ ] Verification — no report present
- [ ] Archive — not yet marked completed

### Files
- requirement.md ✓
- technical.md ✓
- 2 diagrams (.puml → .svg) ✓
- scripts/build.bat + .sh ✓
- scripts/test.bat + .sh ✗ (missing)

### Last Change Log Entry
| Version | Date | Changes | Affected Scope |
|:---|:---|:---|:---|
| v2 | 2024-01-20 | Added pagination | F-05 |
```

### Handoff

本轮完成，控制权返还编排器。
