---
name: req-cleanup
description: Code cleanup — detect unused code, merge duplicate logic, optimize cohesion/coupling (never alter business logic)
argument-hint: "[domain/scenario]"
---

# req-cleanup: Code Cleanup Stage
> Version: v3 | Date: 2026-04-27 | Author: system

## 1. Role & Scope
You are responsible for the code cleanup stage. Optimize all code produced for this scenario — **without modifying any business logic**.

## 2. Core Principle — Do NOT Alter Business Behavior

This stage is strictly about **structural optimization**:
1. **No behavior changes** — exact same results before and after
2. **No algorithm changes** — do not "improve" business algorithms
3. **No interface changes** — public APIs unchanged
4. **No feature additions or removals**
5. **When in doubt, don't touch it** — report as suggestion

## 3. Prerequisites

- `$ARGUMENTS` provides domain/scenario identifier
- Coding must be complete
- Scenario document and source code must be ready

## 4. Steps

### 4.1 Load Context
1. Read the domain scenario document — understand scope
2. Read `requirements/architecture.md` — understand module design
3. Locate all source code files produced for this scenario
4. Check the scenario's Superseded Components list — add those files to scan scope

### 4.2 Analyze (Read-Only)
Scan all code. **Do not make any changes yet** — only collect findings.

Focus on **cross-module** issues that only became apparent after all modules were written.

#### 4.2.1 Unused Code Elements
- Unused imports, variables, functions, parameters
- Dead code (unreachable branches, literal dead code, tagged legacy)

#### 4.2.2 Redundant Code
- Duplicate code blocks across modules
- Over-wrapping (trivial single-call wrappers)
- Zero-value comments

#### 4.2.3 Cohesion & Coupling Issues
- Low cohesion (module doing unrelated things)
- High coupling (accessing internals instead of interfaces)
- Circular dependencies

### 4.3 Present Findings
Output analysis report. **Wait for user approval.**

```markdown
## Code Cleanup Analysis

### Findings

| # | Category | Location | Proposed Action | Detail |
|:---|:---|:---|:---|:---|
| C-01 | Unused import | src/xxx.py:L5 | Remove | `import os` never used |
| C-02 | Duplicate code | src/a.py:L20, src/b.py:L30 | Extract | Same validation logic |

### Items Skipped (Suggestions Only)

| # | Location | Observation | Why Skipped |
|:---|:---|:---|:---|
| S-01 | src/foo.py:L88 | Complex nested if-else | Might change edge-case behavior |
```

### 4.4 Apply Approved Changes

#### 4.4.1 Remove Unused Code
#### 4.4.2 Extract Common Logic
#### 4.4.3 Improve Module Structure
#### 4.4.4 Clean Up Comments

### 4.5 Output Cleanup Report

```markdown
## Code Cleanup Report

### Applied Changes
| # | Category | Location | Action | Detail |
|:---|:---|:---|:---|:---|

### Statistics
- Unused code removed: X items
- Duplicate code merged: X items
- Net lines reduced: ~X lines

### Behavior Impact
- Public API changes: **None**
- Business logic changes: **None**
```

### 4.6 Verify Integrity
1. Build check — must compile without errors
2. Run existing tests — all must pass
3. Interface check — no public API changes
4. If any test fails, **revert the change** and report

### 4.7 Commit
```bash
git add -A && git commit -m "refactor({domain}): code cleanup — {scenario}"
```

Stage complete. Return to orchestrator.
