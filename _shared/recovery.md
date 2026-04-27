# Breakpoint Recovery Pattern
> Version: v2 | Date: 2026-04-27 | Author: system

## 1. Purpose

When resuming previously interrupted work, follow this pattern to avoid redoing completed work.

## 2. General Flow

1. Read `requirements/index.md` Work In Progress section
2. If a WIP entry exists: identify domain, scenario, and current stage
3. Enter that stage and **check existing artifacts before starting work**
4. Resume from the first incomplete artifact, not from scratch
5. Inform user: "Detected interrupted work on {domain}/{scenario} at [{Stage}]. Resuming from there."

If no WIP entry exists: this is fresh work — proceed normally.

## 3. Per-Stage Artifact Checks

### 3.1 tech (Technical Design)

- Check if the scenario's `Implementation Approach` section is populated
- Check if `architecture.md` was recently updated for this scenario
- If approach exists but incomplete: show content, ask user to continue or restart

### 3.2 code (Coding)

- Read the scenario's `Implementation Approach` for module/component list
- Check which modules have corresponding code files
- List completed vs pending modules
- Resume from the first pending module

### 3.3 verify (Verification)

- Check if `scripts/` directory and scripts exist
- Check if test files exist
- If scripts exist: run them to see current pass/fail status
- Only fix failing items, don't regenerate passing ones

## 4. Key Principle

**Never redo completed work.** Always check first, then fill in the gaps.
