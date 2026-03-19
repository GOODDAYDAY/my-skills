---
name: req-5-cleanup
description: Code cleanup — detect unused code, merge duplicate logic, optimize cohesion/coupling (never alter business logic)
argument-hint: "[REQ-xxx]"
---

You are responsible for the code cleanup stage. Optimize all code produced by this requirement to be clean, non-redundant, and well-structured — **without modifying any business logic**.

## Core Principle — Do NOT Alter Business Behavior

This stage is strictly about **structural optimization**. The following rules are absolute:

1. **No behavior changes** — the code must produce the exact same results before and after cleanup
2. **No algorithm changes** — do not "improve" business algorithms, even if you think there is a better way
3. **No interface changes** — public APIs, function signatures, return types, and error codes must remain unchanged
4. **No feature additions or removals** — do not add "missing" features or remove "unnecessary" ones
5. **When in doubt, don't touch it** — if you are not 100% certain a change is purely structural, skip it and report it as a suggestion instead

## Prerequisites

- `$ARGUMENTS` provides a REQ number
- Requirement review stage has been completed (`Development Done` or later)
- The corresponding `requirement.md`, `technical.md`, and source code must be ready

## Flow

### Step 1: Load Context

1. Read `requirements/REQ-xxx-*/requirement.md` — understand requirement scope
2. Read `requirements/REQ-xxx-*/technical.md` — understand module design and reuse strategy
3. Locate all source code files produced by this requirement

### Step 2: Analyze (Read-Only)

Scan all code produced by this requirement. **Do not make any changes yet** — only collect findings.

#### 2.1 Unused Code Elements
- **Unused imports**: imported but never referenced modules, packages, classes
- **Unused variables**: declared but never read
- **Unused functions/methods**: defined but never called (within the requirement scope)
- **Unused parameters**: declared in function signature but never used in the function body
- **Dead code**: branches that can never execute (e.g., code after `return`, `if False`)

#### 2.2 Redundant Code
- **Duplicate code blocks**: identical or near-identical code appearing in 2+ places
- **Duplicate logic**: same business logic implemented differently in different locations
- **Over-wrapping**: functions called only once with trivial logic that can be inlined
- **Zero-value comments**: comments that merely restate the code with no additional insight

#### 2.3 Cohesion & Coupling Issues
- **Low cohesion**: a module doing multiple unrelated things (violating single responsibility)
- **High coupling**: modules accessing each other's internals instead of using interfaces
- **Circular dependencies**: module A depends on module B and vice versa

### Step 3: Present Findings to User

Output the analysis as a report. **Do not apply changes until the user approves.**

```markdown
## Code Cleanup Analysis — REQ-xxx

### Scan Scope
- Files scanned: X
- Modules: [list]

### Findings

| # | Category | Location | Proposed Action | Detail |
|:---|:---|:---|:---|:---|
| C-01 | Unused import | src/xxx.py:L5 | Remove | `import os` is never used |
| C-02 | Duplicate code | src/a.py:L20, src/b.py:L30 | Extract | Same validation logic — extract to shared util |
| C-03 | Dead code | src/yyy.py:L45-L60 | Remove | Unreachable branch after early return |
| C-04 | Circular dep | module_a ↔ module_b | Refactor | Extract shared interface |
| C-05 | Zero-value comment | src/zzz.py:L12 | Remove | Comment repeats the code |

### Items Skipped (Suggestions Only)
These items *might* be improvable but involve potential behavior changes — listed for your reference only:

| # | Location | Observation | Why Skipped |
|:---|:---|:---|:---|
| S-01 | src/foo.py:L88 | Complex nested if-else | Simplification might change edge-case behavior |
```

**Wait for user to review and approve which items to apply.**

### Step 4: Apply Approved Changes

After user approval, apply only the approved items:

#### 4.1 Remove Unused Code
- Delete unused imports, variables, functions, dead branches
- Verify nothing else references the removed elements

#### 4.2 Extract Common Logic
- Extract duplicate code into shared functions/methods/utilities
- Place in appropriate layer (`shared/`, `utils/`, `common/`)
- Ensure extracted code has clear naming and interfaces

#### 4.3 Improve Module Structure
- Reduce coupling by replacing direct internal access with interface calls
- Break circular dependencies by extracting shared interfaces
- Merge or split modules only when the change is purely structural

#### 4.4 Clean Up Comments
- Remove zero-value comments that add no information
- Keep comments that explain *why*, not *what*

### Step 5: Output Cleanup Report

```markdown
## Code Cleanup Report — REQ-xxx

### Applied Changes

| # | Category | Location | Action | Detail |
|:---|:---|:---|:---|:---|
| C-01 | Unused import | src/xxx.py:L5 | Removed | `import os` |
| C-02 | Duplicate code | src/a.py:L20, src/b.py:L30 | Extracted | → utils/validator.py |

### Statistics
- Unused code removed: X items
- Duplicate code merged: X items
- Module restructured: X items
- Net lines reduced: ~X lines

### Cohesion & Coupling Assessment
- Module cohesion: [assessment]
- Module coupling: [assessment]
- Circular dependencies: None / [list]

### Behavior Impact
- Public API changes: **None**
- Business logic changes: **None**
- All changes are purely structural
```

### Step 6: Verify Integrity

After cleanup, verify that nothing is broken:

1. **Build check** — code must compile/interpret without errors
2. **Run existing tests** — if `scripts/test.bat` or `scripts/test.sh` exists, run it; all tests must still pass
3. **Interface check** — confirm no public API signatures were altered
4. If any test fails, **revert the change that caused it** and report to user

### Step 7: Update Status

Read `${CLAUDE_SKILL_DIR}/../_shared/status.md` for status specifications. Update `requirements/index.md` status to `Code Cleaned`.
