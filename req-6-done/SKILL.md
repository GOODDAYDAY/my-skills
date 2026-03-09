---
name: req-6-done
description: Archive — final consistency check, update document status, mark requirement as completed
argument-hint: "[REQ-xxx]"
---

You are responsible for the archive stage. Run the final consistency check, then mark the requirement as completed.

## Prerequisites

- `$ARGUMENTS` provides a REQ number
- Verification stage must have passed

## Flow

### Step 1: Final Consistency Check

Before archiving, execute the following checklist. **All items must pass.**

```markdown
## Final Consistency Checklist

### Documents
- [ ] requirement.md exists and status is finalized
- [ ] technical.md exists and status is finalized
- [ ] All .puml files have corresponding .svg files
- [ ] All .svg files are valid (size > 0, no Syntax Error)

### Code
- [ ] Source code exists for all modules defined in technical.md
- [ ] Code builds successfully (run scripts/build.bat or build.sh)
- [ ] All tests pass (run scripts/test.bat or test.sh)

### Scripts
- [ ] scripts/build.bat + build.sh exist and are executable
- [ ] scripts/run.bat + run.sh exist and are executable
- [ ] scripts/test.bat + test.sh exist and are executable

### Git
- [ ] All changes are committed (no uncommitted modifications)
```

If any check fails:
1. List all failed items
2. For auto-fixable issues (missing SVG, missing scripts), fix them directly
3. For issues requiring human intervention (uncommitted code, test failures), prompt the user
4. **All items must pass before proceeding to archive**

### Step 2: Update Requirement Document Status

Modify `requirements/REQ-xxx-*/requirement.md`:
- Set Status to `Completed`
- Update the Updated date

### Step 3: Update Technical Document Status

Modify `requirements/REQ-xxx-*/technical.md`:
- Set Status to `Completed`
- Update the Updated date

### Step 4: Update Index

Read `${CLAUDE_SKILL_DIR}/../_shared/status.md` for status specifications. Modify `requirements/index.md`:
- Set the requirement's status to `Completed`
- Update the date

### Step 5: Output Summary

```markdown
## REQ-xxx <Name> — Completed

### Consistency Check
- Documents: ALL PASS
- Code: ALL PASS
- Scripts: ALL PASS
- Git: ALL PASS

### Summary
- Requirement document: archived
- Technical design: archived
- Code: implemented and verified
- Completed: <date>
```
