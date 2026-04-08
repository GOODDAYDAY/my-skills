---
name: req-review
description: Requirement review — compare implementation against requirement document item by item
argument-hint: "[REQ-xxx]"
orchestrator: req
applicable_when: |
  requirement.md, technical.md, and code all exist, cleanup has been done (or
  the user wants a review regardless), and no review report is present in the
  REQ directory yet, or change log entries indicate a re-review is needed.
---

You are invoked by the `req` orchestrator to check whether the code implementation satisfies the requirement document item by item. Do one bounded round and return control.

## Flow

### Step 1: Load Documents

1. Read `requirements/REQ-xxx-*/requirement.md`
2. Read `requirements/REQ-xxx-*/technical.md`
3. Read `${CLAUDE_SKILL_DIR}/../_shared/changelog.md` for change log specifications
4. Pay special attention to the Change Log — understand each version's changes and **Affected Scope**

### Step 2: Item-by-Item Comparison

For **every functional requirement** and **every acceptance criterion** in the requirement document:

1. Find the corresponding code implementation
2. Determine whether it is satisfied
3. Output comparison result table:

```markdown
| Requirement | Status | Code Location | Notes |
|:---|:---|:---|:---|
| F-01 Feature 1 | Implemented | src/xxx.py:L20 | |
| F-02 Feature 2 | Partial | src/yyy.py:L45 | Missing edge case handling |
| F-03 Feature 3 | Not implemented | - | Needs development |
```

### Step 3: Change Log Compliance Check

This is the **core rule** of this stage and must be strictly enforced.

#### Version Precedence Principle

When multiple versions exist in the change log, **the latest version (highest number) takes precedence**. For example:
- v1 defined feature A
- v2 added feature B
- v3 modified feature A's behavior

Code should implement v3's feature A description + v2's feature B.

#### Structured Mismod Detection

Use the **`Affected Scope`** column in the change log for precise detection:

1. Read change log version by version
2. Check the `Affected Scope` column for each version's declared scope (e.g., F-01, F-03)
3. Compare full document content between adjacent versions
4. **If a feature changed but is NOT in that version's `Affected Scope`, classify it as a mismod (undeclared change)**

Example:

```markdown
| Version | Date | Changes | Affected Scope | Reason |
|:---|:---|:---|:---|:---|
| v1 | 2024-01-01 | Initial version | ALL | - |
| v2 | 2024-01-15 | Add feature C | F-03 | New requirement |
```

If F-02's content in v2 differs from v1, but `Affected Scope` only declares F-03 → **mismod detected**.

When a mismod is found:
1. Clearly identify the mismod content and affected features
2. **Use the pre-mismod version as authoritative** (i.e., F-02 follows v1's description)
3. Report to user; the orchestrator will decide whether to dispatch the formal amend skill next round

#### Output Compliance Report

```markdown
## Change Log Compliance Report

| Version | Declared Scope | Actual Changes | Compliant | Notes |
|:---|:---|:---|:---|:---|
| v1 | ALL | - | Yes | |
| v2 | F-03 | F-02 modified, F-03 added | No | F-02 undeclared change |
```

### Step 4: Persist the Report

Write the review report as `review-report.md` in the REQ directory. Include the item-by-item comparison and the change log compliance report. Update `requirements/index.md`'s `Updated` column.

- If all items are satisfied and no mismods → the report itself is the evidence; the orchestrator will pick verification next round.
- If items are missing → the report lists what needs to be done; the orchestrator will re-dispatch coding next round.
- If mismods found → the report flags them; the orchestrator will pick the amend skill next round.

### Handoff

本轮完成，控制权返还编排器。
