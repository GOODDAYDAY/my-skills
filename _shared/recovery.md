# Breakpoint Recovery Pattern
> Version: v3 | Date: 2026-04-27 | Author: system

## 1. Purpose

When resuming previously interrupted work, follow this pattern to avoid redoing completed work.

## 2. General Flow

1. Read `requirements/index.md` Domains table to know which domains exist
2. If the user's request relates to an existing domain/scenario, read the scenario docs
3. Check what artifacts already exist to infer progress:
   - Scenario document exists → analysis was done
   - Implementation Approach section populated → tech design was done
   - Code files exist for modules → coding was done (partially or fully)
   - Test files exist → verification was done (partially or fully)
4. Resume from the first incomplete artifact, not from scratch
5. Inform user: "Detected prior work on {domain}/{scenario}. Resuming from {stage}."

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
