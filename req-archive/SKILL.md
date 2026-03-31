---
name: req-archive
description: Batch archive completed requirements and generate a milestone summary
argument-hint: ""
---

Batch-archive all Completed requirements from the Active section of `requirements/index.md` and generate a milestone summary document.

## When to Run

Run when prompted by `/req-8-done` (archive threshold reached), or manually at any time.

## Flow

### Step 1: Load Active Completed Requirements

1. Read `requirements/index.md`
2. Collect all rows in the **Active** section with status `Completed`
3. If none found, inform user and exit

### Step 2: Generate Milestone Summary

For each completed requirement, read its `requirement.md` and `technical.md` to extract:
- One-line description of what was built
- New shared modules/utilities introduced (from technical.md § Shared Modules & Reuse Strategy)
- Key technical decisions established (from technical.md § Design Principles or Risks & Notes)

Create `requirements/archive/` directory if it does not exist. Write to `requirements/archive/milestone-<YYYY-MM-DD>.md`:

```markdown
# Milestone — <YYYY-MM-DD>

## Delivered Requirements

| ID | Name | Summary |
|:---|:---|:---|
| REQ-xxx | <name> | <one-line description> |

## New Shared Modules & Utilities

Shared modules/utilities introduced in this batch that future requirements can reuse:

- `<module/path>` — <what it does>

## Technical Decisions Established

Patterns, constraints, or architectural decisions confirmed across this batch:

- <decision>

## Stats

- Requirements archived: X
- Active requirements remaining: Y
```

### Step 3: Update index.md

Move all Completed rows from **Active** to **Archived** section:
- In the Archived section, replace the `Status` + `Updated` columns with a single `Completed` date column
- Keep all other row content intact
- Do not touch rows that are not Completed

### Step 4: Commit & Tag

```bash
git add -A && git commit -m "chore: archive milestone <YYYY-MM-DD>"
git tag milestone-<YYYY-MM-DD>
```

### Step 5: Output

Inform user:
- How many requirements were archived
- Milestone summary location: `requirements/archive/milestone-<date>.md`
- How many requirements remain active
- Git tag created: `milestone-<date>`
