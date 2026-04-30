---
name: req-review
description: Requirement review — compare implementation against domain scenario documents item by item
argument-hint: "[domain/scenario]"
---

# req-review
> Version: v3 | Date: 2026-04-27 | Author: system

## 1. Overview
You are responsible for the requirement review stage — verify item by item that the code implementation satisfies the domain scenario documents.

## 2. Prerequisites

- `$ARGUMENTS` provides domain/scenario identifier
- The scenario document and source code must be ready
- Coding must be complete

## 3. Overall Flow

1. Load scenario document + code
2. Item-by-item comparison
3. Superseded components check
4. Output conclusion

## 4. Steps

### 4.1 Load Documents
1. Read the domain scenario document (requirements, acceptance criteria)
2. Read `requirements/architecture.md` for architectural context
3. Locate all source code files produced for this scenario

### 4.2 Item-by-Item Comparison
For **every functional requirement** and **every acceptance criterion** in the scenario document:
1. Find the corresponding code implementation
2. Determine whether it is satisfied
3. Output the comparison result table:

```markdown
| Requirement | Status | Code Location | Notes |
|:---|:---|:---|:---|
| F-01 Feature 1 | Implemented | src/xxx.py:L20 | |
| F-02 Feature 2 | Partial | src/yyy.py:L45 | Missing edge case handling |
| F-03 Feature 3 | Not implemented | - | Needs development |
```

### 4.2b Superseded Components Check
Read the scenario's Implementation Approach Superseded Components section. For each entry, verify the declared Cleanup Action was applied:
- `Remove`: grep for the component — it must no longer exist in the codebase
- `Mark`: the `# LEGACY:` comment must be present on the superseded block

Add results as additional rows to the comparison table.

If the Superseded Components section is absent or says "None", skip this check.

### 4.3 Output Conclusion
- All items satisfied → output conclusion report
- Items not implemented or partially implemented → list pending items in the conclusion report

Output the following block as the final output of this stage:

```
## Stage Result
- **status**: all_satisfied | has_gaps
- **satisfied**: {N}/{M} items
- **gaps**: US-xx, US-xx (only if status is has_gaps; list requirement IDs with Partial or Not implemented status)
```
