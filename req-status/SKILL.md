---
name: req-status
description: Quick status check — view one or all requirement statuses
argument-hint: "[REQ-xxx | all]"
---

Quickly check requirement status without manually reading `index.md`.

## Usage

- `/req-status` or `/req-status all` — view all requirement statuses
- `/req-status REQ-001` — view detailed status of a specific requirement

## Flow

### View All Requirements

1. Read `requirements/index.md`
2. Output formatted status table
3. Include statistics:

```markdown
## Requirement Status Overview

| ID | Name | Status | Updated |
|:---|:---|:---|:---|
| REQ-001 | User Login | Completed | 2024-01-15 |
| REQ-002 | Data Export | In Development | 2024-01-20 |
| REQ-003 | Dashboard | Technical Design | 2024-01-22 |

### Summary
- Total: 3
- Completed: 1
- In Progress: 2
```

### View Single Requirement

1. Read `requirements/REQ-xxx-*/requirement.md` and `technical.md`
2. Check code and script existence
3. Output detailed status:

```markdown
## REQ-xxx <Name>

### Current Status: <status>

### Phase Checklist
- [x] Requirement analysis — requirement.md (finalized)
- [x] Technical design — technical.md (finalized)
- [ ] Coding — 3/5 modules completed
- [ ] Requirement review — not started
- [ ] Verification — not started
- [ ] Archive — not started

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
