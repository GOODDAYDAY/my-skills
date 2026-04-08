---
name: req-amend
description: Formal change process — safely amend finalized requirement or technical documents
argument-hint: "[REQ-xxx]"
orchestrator: req
applicable_when: |
  The user wants to modify an already-approved requirement.md or technical.md,
  or the requirement review report flagged mismods that must go through a
  formal change process.
---

You are invoked by the `req` orchestrator to run the formal change process. When approved requirement or technical documents need modification, **changes must go through this skill** — direct manual edits to documents are prohibited. Do one bounded round and return control.

## Why This Process Exists

Direct document edits easily lead to:
- Changing A and accidentally modifying B (mismod)
- Incomplete change log, making future reviews untrackable
- Missing `Affected Scope`, breaking mismod detection

## Flow

### Step 1: Confirm Change Target

1. Read the REQ number from `$ARGUMENTS`
2. Read current `requirement.md` and `technical.md`
3. Ask the user what they want to change:
   - "Which features do you want to modify? (e.g., F-01, F-03)"
   - "What is the reason for the change?"
   - "Is this a requirement change or technical design change?"

### Step 2: Define Affected Scope

Based on user description, **before making any modifications**, list the affected scope:

```markdown
## Proposed Change

- Target document: requirement.md / technical.md
- Affected scope: F-01, F-03
- Change description: <what will change>
- Reason: <why>

### Impact Analysis
- F-01: <current> → <proposed>
- F-03: <current> → <proposed>
- Other features: NO CHANGE
```

**Wait for user to confirm the affected scope before making any edits.**

### Step 3: Execute Changes

After user confirmation:

1. **Only modify content within the declared affected scope**
2. After modification, automatically diff the document changes:
   - Check if any content outside the affected scope was changed
   - If so, **revert that change** and report it
3. Update the change log with a new row:

```markdown
| v<N+1> | <date> | <change description> | <F-xx, F-xx> | <reason> |
```

### Step 4: Cascade Updates

If `requirement.md` was modified:
1. Check if `technical.md` needs a corresponding update
2. If yes, apply the change process to the technical document as well
3. Check if code needs adjustment, prompt user whether to re-enter coding stage

If `technical.md` was modified:
1. Check if code needs adjustment
2. Prompt user whether to re-enter coding stage

### Step 5: Update Index

Update the `Updated` column in `requirements/index.md` for this REQ. Do not encode any workflow position. The next orchestrator observation will naturally notice that the downstream artifacts (technical.md, code, tests) are now stale relative to the new change log entry and will dispatch the appropriate sub-skill next round.

### Step 6: Output Change Summary

```markdown
## Change Summary

- REQ: REQ-xxx
- Document: requirement.md
- Version: v1 → v2
- Affected Scope: F-01, F-03
- Undeclared changes: None ✓
```

### Handoff

本轮完成，控制权返还编排器。
