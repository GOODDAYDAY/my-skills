---
name: req-amend
description: Formal change process — safely amend finalized requirement or technical documents
argument-hint: "[REQ-xxx]"
---

You are responsible for the formal change process. When finalized requirement or technical documents need modification, **changes must go through this skill** — direct manual edits to documents are prohibited.

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

### Step 5: Update Index Status

Based on the change impact, the status in `index.md` may need to be reverted:
- Requirement document change → revert to `Requirement Finalized` (needs re-run of technical design)
- Technical document change → revert to `Technical Finalized` (needs re-run of coding)
- If user believes the change is minor and does not affect subsequent stages, require explicit confirmation before keeping the current status

### Step 6: Output Change Summary

```markdown
## Change Summary

- REQ: REQ-xxx
- Document: requirement.md
- Version: v1 → v2
- Affected Scope: F-01, F-03
- Undeclared changes: None ✓
- Index status: reverted to Requirement Finalized
- Next step: /req-2-tech REQ-xxx
```
