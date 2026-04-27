---
name: req-archive
description: Archive — archive inactive domains/scenarios and generate milestone summary
argument-hint: "[domain | scenario]"
---

# req-archive
> Version: v2 | Date: 2026-04-27 | Author: system

## 1. Overview
Archive domains or scenarios that are no longer active. Move them to `requirements/archive/` and generate a milestone summary.

## 2. When to Trigger
- User explicitly runs `/req-archive`
- User wants to clean up old domains/scenarios that are no longer relevant

## 3. Steps

### 3.1 Identify What to Archive
1. Read `requirements/index.md` Domains table
2. If `$ARGUMENTS` specifies a domain or scenario, target that
3. If no argument, ask the user which domain(s) or scenario(s) to archive
4. Confirm with the user before proceeding

### 3.2 Generate Milestone Summary
For each item being archived, extract:
- A one-line description of what was built
- Key technical decisions (from architecture.md if referenced)
- Shared modules/utilities introduced

Create `requirements/archive/` if it does not exist. Write `requirements/archive/milestone-<YYYY-MM-DD>.md`:

```markdown
# Milestone — <YYYY-MM-DD>

## Archived Items

| Domain | Scenario | Summary |
|:---|:---|:---|
| auth | login | User authentication with JWT |

## Shared Modules & Utilities
- `<module/path>` — <what it does>

## Technical Decisions Established
- <decision>

## Stats
- Items archived: X
- Active domains remaining: Y
```

### 3.3 Move to Archive
- If archiving an entire domain: move `requirements/{domain}/` to `requirements/archive/{domain}/`
- If archiving a scenario: move the scenario file to `requirements/archive/{domain}-{scenario}.md`
- Remove the domain from index.md Domains table (if entire domain archived)
- Update the domain README Scenarios table (if only a scenario archived)

### 3.4 Commit
```bash
git add -A && git commit -m "chore: archive {items}"
```

### 3.5 Output Result
Notify the user:
- What was archived
- Milestone summary location
- Remaining active domains

Archive complete.
