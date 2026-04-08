---
name: req-archive
description: Archive — final consistency check, mark requirement as completed
argument-hint: "[REQ-xxx]"
orchestrator: req
applicable_when: |
  All artifacts look complete per observation: requirement and technical
  documents approved, code implemented, security and cleanup reports present,
  review report has no blockers, verification report shows all checks passing.
  No archival marker is present yet.
---

You are invoked by the `req` orchestrator to run the final consistency check and mark the requirement as completed. Do one bounded round and return control.

## Flow

### Step 1: Final Consistency Check

Before archiving, execute the following checklist. **All items must pass.**

```markdown
## Final Consistency Checklist

### Documents
- [ ] requirement.md exists and has a user approval marker
- [ ] technical.md exists and has a user approval marker
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

### Step 2: Mark Documents as Completed

Add an explicit "Completed on <date>" header marker to both `requirement.md` and `technical.md`. This is the archival marker the orchestrator observes on next invocation to know the REQ is done.

### Step 3: Update Index

Update the `Updated` column in `requirements/index.md` for this REQ. The index is still a pure catalog — do not add a Status column.

### Step 4: Output Summary

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

### Handoff

本轮完成，控制权返还编排器。
