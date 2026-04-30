---
name: req-refresh
description: Refresh all domain requirement docs and architecture.md for the current project — one subagent per domain, forward then reverse
argument-hint: "[--forward-only | --reverse-only]"
---

# req-refresh — Domain Docs Batch Refresh
> Version: v1 | Date: 2026-04-30 | Author: system

## 1. Role

You are responsible for refreshing all domain requirement documents to match the current codebase reality. Unlike `req-analyze` (which creates docs from a user request), `req-refresh` takes **existing** docs and ensures they accurately reflect what the code actually does today.

This skill is part of the req-* family:

| Skill | Relationship |
|:---|:---|
| req-analyze | Creates/updates domain docs from user intent → **forward, intent-driven** |
| req-refresh | Updates domain docs from code reality → **forward, code-driven** |
| req-review | Verifies code matches docs → **reverse, doc-as-spec** |

## 2. Overall Flow

```
Phase 1 — Forward: Update docs to match code (one subagent per domain, parallel)
Phase 2 — Reverse: Verify docs match code (one subagent per domain, parallel)
Phase 3 — Report: Aggregate results
```

Arguments:
- No argument: run both phases
- `--forward-only`: skip Phase 2
- `--reverse-only`: skip Phase 1

## 3. Phase 1 — Forward Refresh

### 3.1 Discover Domains

1. Read `requirements/index.md` — parse the Domains table
2. For each domain, note the path and description
3. Also check `requirements/architecture.md` existence

### 3.2 Launch Forward Subagents

For **each domain**, launch a parallel subagent using the `Agent` tool (`subagent_type: "req-agent"`).

**Subagent prompt** (fill in `{domain}`, `{domain_path}`, `{project_dir}`):

```
You are refreshing the requirement docs for domain "{domain}" in project at {project_dir}.

## Task

Compare the domain's requirement docs against the actual source code and update the docs to match reality.

## Steps

1. Read the project's CLAUDE.md for conventions
2. Read requirements/{domain_path}/README.md (and any sub-scenario .md files in that directory)
3. From the README.md, identify which source files/modules implement this domain
4. Read those source files thoroughly
5. Compare each user story and acceptance criterion against the code:
   - Is the described behavior still implemented? If removed, remove or mark the story
   - Are there new behaviors not documented? Add new user stories
   - Have interfaces or flows changed? Update descriptions and acceptance criteria
   - Has the Implementation Approach section become stale? Update it
6. Update the README.md (and scenario files) to reflect current reality

## Rules

- Preserve the existing document structure (user stories in US-XX format, acceptance criteria in Given/When/Then)
- Write user stories from an actor's perspective, not as technical specs
- NO function names, class names, or variable names in user stories or acceptance criteria
- Mark anything ambiguous as [NEEDS CONFIRMATION] rather than guessing
- Do NOT invent business logic — only document what the code actually does
- Do NOT delete information that is still valid
- If the domain docs are already accurate, report "no changes needed" and make no edits
- Section headings must be in English
- Do NOT create or modify any code files — this is docs-only

## Output

End your response with:

## Domain Refresh Result
- **domain**: {domain}
- **status**: updated | unchanged | needs_confirmation
- **stories_added**: [list of new US-XX IDs, or "none"]
- **stories_removed**: [list of removed US-XX IDs, or "none"]
- **stories_modified**: [list of modified US-XX IDs, or "none"]
- **ambiguities**: [list, or "none"]
```

### 3.3 Architecture Refresh

Launch one additional subagent for `architecture.md`:

```
You are refreshing requirements/architecture.md for the project at {project_dir}.

## Task

Compare the architecture doc against the actual codebase structure and update it.

## Steps

1. Read CLAUDE.md for project conventions
2. Read requirements/architecture.md
3. Read requirements/index.md to see all domains
4. Scan the codebase directory structure and key modules
5. Update architecture.md sections as needed:
   - Glossary: add/remove/update terms
   - Key Decisions: add any undocumented decisions found in code, mark stale ones
   - Extension Guide: update if patterns have changed
   - Architecture Overview: update if structure has changed

## Rules

- Only update what has actually changed
- Preserve existing section structure
- Mark ambiguities as [NEEDS CONFIRMATION]
- Do NOT modify code files

## Output

## Architecture Refresh Result
- **status**: updated | unchanged
- **sections_modified**: [list, or "none"]
- **terms_added**: [list, or "none"]
- **decisions_added**: [list, or "none"]
- **ambiguities**: [list, or "none"]
```

### 3.4 Undocumented Domain Scan

Launch one subagent to scan for code modules that have no corresponding domain doc:

```
You are scanning for undocumented domains in the project at {project_dir}.

## Task

Find code modules/features that exist in the codebase but have no corresponding domain in requirements/index.md.

## Steps

1. Read requirements/index.md — list all documented domains
2. Read CLAUDE.md for project structure
3. Scan the codebase directory structure
4. For each significant module or feature area, check if it has a matching domain
5. Report any gaps

## Rules

- A "significant module" means a coherent set of functionality, not individual files
- Small utilities, configs, and test infrastructure don't need their own domain
- Do NOT create any files — report only

## Output

## Undocumented Domain Scan Result
- **status**: all_covered | has_gaps
- **undocumented**: [list with brief description of each, or "none"]
```

## 4. Phase 2 — Reverse Verification

After **all Phase 1 subagents complete**, launch one subagent per domain for verification.

**Subagent prompt** (fill in `{domain}`, `{domain_path}`, `{project_dir}`):

```
You are verifying the requirement docs for domain "{domain}" against the codebase at {project_dir}.

This is a read-only verification pass — do NOT modify any files.

## Steps

1. Read requirements/{domain_path}/README.md (and sub-scenario files)
2. Extract every user story and acceptance criterion
3. Read the source code that implements this domain
4. For each acceptance criterion, classify:
   - PASS: implemented and matches the doc
   - OVER-SPEC: documented but NOT implemented
   - UNDER-DOC: implemented in code but NOT documented
   - STALE: references code/features that no longer exist

## Output

## Domain Verification Result
- **domain**: {domain}
- **total_criteria**: N
- **pass**: N
- **over_spec**: [list with details, or "none"]
- **under_doc**: [list with details, or "none"]
- **stale**: [list with details, or "none"]
- **health**: GREEN | YELLOW | RED
```

Also launch one subagent for architecture.md verification:

```
You are verifying requirements/architecture.md against the codebase at {project_dir}.

This is read-only — do NOT modify any files.

## Steps

1. Read requirements/architecture.md
2. For each claim (glossary term, key decision, extension pattern):
   - Verify the referenced module/pattern still exists
   - Check if the description matches current code
3. Report mismatches

## Output

## Architecture Verification Result
- **status**: accurate | has_issues
- **stale_terms**: [list, or "none"]
- **stale_decisions**: [list, or "none"]
- **missing_terms**: [list of terms used in code but not in glossary, or "none"]
```

## 5. Phase 3 — Summary Report

After all Phase 2 subagents complete, produce a consolidated report:

```markdown
# Refresh Summary — {project_name}

## Forward Pass
| Domain | Status | Added | Removed | Modified | Ambiguities |
|:---|:---|:---|:---|:---|:---|
| ... | ... | ... | ... | ... | ... |

Architecture: {updated/unchanged}
Undocumented domains: {list or "none"}

## Reverse Pass
| Domain | Total | Pass | Over-spec | Under-doc | Stale | Health |
|:---|:---|:---|:---|:---|:---|:---|
| ... | ... | ... | ... | ... | ... | ... |

Architecture: {accurate/has_issues}

## Action Items
- [NEEDS CONFIRMATION]: ...
- OVER-SPEC: ...
- UNDER-DOC: ...
```

## 6. Index Update

After all phases, update `requirements/index.md` if:
- New domains were added during the forward pass
- Domain descriptions have changed

## 7. Execution Rules

1. **No git operations** — this skill only modifies requirement docs in the working tree
2. **One subagent per domain** — never batch multiple domains into one subagent
3. **Phase 2 waits for Phase 1** — reverse pass reads docs that the forward pass may have updated
4. **Subagents are independent** — each reads its own context, no shared state
5. **Read before write** — every subagent must read the actual code before touching any doc

## 8. Stage Result

Output the following block as the final output:

```
## Stage Result
- **status**: completed | has_issues
- **domains_refreshed**: N
- **domains_unchanged**: N
- **domains_undocumented**: N
- **verification_health**: GREEN | YELLOW | RED
- **action_items**: N items needing attention
```
