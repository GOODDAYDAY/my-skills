# Breakpoint Recovery Pattern
> Version: v1 | Date: 2026-04-02 | Author: system

## 1. Purpose

When resuming a previously interrupted requirement, follow this pattern to avoid redoing completed work.

```mermaid
flowchart LR
    A[Interrupted REQ] --> B[Check existing artifacts]
    B --> C{Complete?}
    C -- Yes --> D[Skip — advance stage]
    C -- No --> E[Resume from gap]
```
**Figure 1.1 — Core recovery principle: check before redoing**

## 2. General Flow

```mermaid
flowchart TD
    A[Resume interrupted REQ] --> B[Read requirements/index.md]
    B --> C[Map status to stage]
    C --> D[Enter stage]
    D --> E[Check existing artifacts]
    E --> F{All artifacts complete?}
    F -- Yes --> G[Advance to next stage]
    F -- No --> H[Resume from first incomplete artifact]
    H --> I[Inform user of resumption point]
```
**Figure 2.1 — Breakpoint recovery general flow**

1. Read `requirements/index.md` to get the current status of the REQ
2. Map status to the corresponding stage (see `_shared/status.md` for mapping)
3. Enter the stage and **check existing artifacts before starting work**
4. Resume from the first incomplete artifact, not from scratch
5. Inform user: "Detected REQ-xxx was interrupted at [Stage X - specific step]. Resuming from there."

## 3. Per-Stage Artifact Checks

### 3.1 req-tech (Technical Design)

- Check if `technical.md` exists
- If exists and status is `Technical Design` (not finalized): show existing content, ask user to continue or restart

### 3.2 req-code (Coding)

- Read module list from `technical.md`
- Check which modules have corresponding code files
- List completed vs pending modules
- Resume from the first pending module

### 3.3 req-verify (Verification)

- Check if `scripts/` directory and scripts exist
- Check if test files exist
- If scripts exist: run them to see current pass/fail status
- Only fix failing items, don't regenerate passing ones

```mermaid
flowchart LR
    A[req-tech] --> B{technical.md exists?}
    B -- No --> C[Create from scratch]
    B -- Yes --> D[Show content, ask user]
    E[req-code] --> F{Code files exist?}
    F -- No --> G[Start from first module]
    F -- Yes --> H[Resume from first pending module]
    I[req-verify] --> J{Scripts exist?}
    J -- No --> K[Generate all scripts]
    J -- Yes --> L[Run scripts, fix failures only]
```
**Figure 3.1 — Per-stage artifact check logic**

## 4. Key Principle

**Never redo completed work.** Always check first, then fill in the gaps.

```mermaid
flowchart LR
    A[Start recovery] --> B[Read existing artifacts]
    B --> C[Identify first incomplete step]
    C --> D[Resume from that step]
    D --> E[Inform user of resumption point]
```
**Figure 4.1 — Recovery execution principle**
