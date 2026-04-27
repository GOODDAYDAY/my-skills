---
name: req-status
description: Quick status check — view domain/scenario overview or detailed status
argument-hint: "[domain | all]"
---

# req-status
> Version: v2 | Date: 2026-04-27 | Author: system

## 1. Overview
Quickly view domain and scenario statuses without manual file reading.

## 2. Usage

- `/req-status` or `/req-status all` — view all domains + WIP
- `/req-status {domain}` — view a specific domain's scenarios in detail

## 3. Steps

### 3.1 View All Domains

1. Read `requirements/index.md`
2. Output WIP section and Domains table:

```markdown
## Status Overview

### Work In Progress

| Domain | Scenario | Stage | Updated |
|:---|:---|:---|:---|
| auth | login | In Development | 2026-04-27 |

### Domains

| Domain | Path | Description |
|:---|:---|:---|
| auth | requirements/auth/ | Authentication and session management |
| payment | requirements/payment/ | Payment processing |

### Summary
- Active domains: 2
- In-progress work: 1
```

### 3.2 View a Specific Domain

1. Read the domain's `README.md`
2. Read any separate scenario files in the domain directory
3. Check code and script existence
4. Output detailed status:

```markdown
## Domain: {domain}

> {description}

### Scenarios

| Scenario | Location | Status | Code | Tests |
|:---|:---|:---|:---|:---|
| User Login | inline | Implemented | ✓ | ✓ |
| OAuth | oauth.md | Planned | ✗ | ✗ |

### WIP (if any)

| Scenario | Stage | Updated |
|:---|:---|:---|
| OAuth | Design Decided | 2026-04-27 |

### Files
- README.md ✓
- oauth.md ✓
- tech-architecture.puml → .svg ✓
- scripts/build.bat + .sh ✓
- scripts/test.bat + .sh ✓
```

Done.
