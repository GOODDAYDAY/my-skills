# Breakpoint Recovery Pattern

When resuming a previously interrupted requirement, follow this pattern to avoid redoing completed work.

## General Flow

1. Read `requirements/index.md` to get the current status of the REQ
2. Map status to the corresponding stage (see `_shared/status.md` for mapping)
3. Enter the stage and **check existing artifacts before starting work**
4. Resume from the first incomplete artifact, not from scratch
5. Inform user: "Detected REQ-xxx was interrupted at [Stage X - specific step]. Resuming from there."

## Per-Stage Artifact Checks

### req-2-tech (Technical Design)
- Check if `technical.md` exists
- If exists and status is `Technical Design` (not finalized): show existing content, ask user to continue or restart

### req-3-code (Coding)
- Read module list from `technical.md`
- Check which modules have corresponding code files
- List completed vs pending modules
- Resume from the first pending module

### req-6-verify (Verification)
- Check if `scripts/` directory and scripts exist
- Check if test files exist
- If scripts exist: run them to see current pass/fail status
- Only fix failing items, don't regenerate passing ones

## Key Principle

**Never redo completed work.** Always check first, then fill in the gaps.
