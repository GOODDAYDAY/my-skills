---
name: req-refresh
description: Refresh all domain requirement docs and architecture.md for the current project — one subagent per domain, forward then reverse
argument-hint: "[--forward-only | --reverse-only]"
---

# req-refresh — Domain Docs Batch Refresh
> Version: v2 | Date: 2026-04-30 | Author: system

## 1. Role

You are responsible for refreshing all domain requirement documents to match the current codebase reality. Unlike `req-analyze` (which creates docs from a user request), `req-refresh` takes **existing** docs and ensures they accurately reflect what the code actually does today.

**核心原则：Refresh = 保持最新一致。增加没有的，删除旧的，修正偏差的。Refresh 不是报告问题，而是修到完全一致。**

- **UNDER-DOC**（代码有、文档没有）→ 补充新的 user story 和 acceptance criteria
- **STALE**（文档引用已不存在的代码/特性）→ 删除或更新过时内容
- **OVER-SPEC**（文档描述与实现不符）→ 修正描述使之匹配代码

This skill is part of the req-* family:

| Skill | Relationship |
|:---|:---|
| req-analyze | Creates/updates domain docs from user intent → **forward, intent-driven** |
| req-refresh | Updates domain docs from code reality → **forward, code-driven, fix everything** |
| req-review | Verifies code matches docs → **reverse, doc-as-spec** |

## 2. Overall Flow

```
Phase 1 — Forward: Update docs to match code (one subagent per domain, parallel)
Phase 2 — Reverse: Verify docs match code (one subagent per domain, parallel)
Phase 3 — Fix: Fix ALL issues found in Phase 2 (one subagent per domain with issues, parallel)
Phase 4 — Report: Aggregate results
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

Launch one additional subagent for `architecture.md`. **Same standard as domain refresh: add missing, delete stale, correct drifted.**

```
You are refreshing requirements/architecture.md for the project at {project_dir}.

## Task

Compare the architecture doc against the actual codebase and make it match reality. Same rules as domain refresh: add what's missing, DELETE what's stale, correct what's drifted.

## Steps

1. Read CLAUDE.md for project conventions
2. Read requirements/architecture.md thoroughly — every section
3. Read requirements/index.md to see all domains
4. Scan the codebase directory structure and key modules
5. For EVERY section, compare against code:

   - **Core Patterns**: For each pattern, verify Structure/Contract/State flow/Extension/Invariants still match code. DELETE patterns for removed subsystems. ADD patterns for new reusable patterns (only patterns multiple components participate in — not single-module internals).
   - **Interface Contracts**: For each contract, verify Producer/Consumer/Wiring/Contract/Verified-by still match code. DELETE contracts where the boundary no longer exists. ADD contracts for new cross-module integration points.
   - **Glossary**: For each term, verify the module/component still exists and the description matches. DELETE terms for removed code. ADD terms for new significant modules.
   - **Key Decisions**: Verify each decision is still in effect. DELETE or mark superseded decisions. ADD undocumented decisions found in code.
   - **Extension Guide**: Verify step-by-step recipes still work. UPDATE if patterns have changed.
   - **Architecture Overview**: UPDATE if high-level structure has changed.
   - **Philosophy**: Rarely changes — only update if fundamental principles are revised.

## Rules

- **DELETE stale content** — do NOT leave glossary terms for removed modules, patterns for deleted subsystems, or contracts for boundaries that no longer exist. Clean removal, no commented-out remnants.
- Add what's genuinely missing — new patterns, new contracts, new glossary terms
- Correct descriptions that have drifted from code reality
- Preserve existing section structure
- Mark ambiguities as [NEEDS CONFIRMATION]
- Do NOT modify code files

## Output

## Architecture Refresh Result
- **status**: updated | unchanged
- **sections_modified**: [list, or "none"]
- **terms_added**: [list, or "none"]
- **terms_removed**: [list, or "none"]
- **patterns_added**: [list, or "none"]
- **patterns_removed**: [list, or "none"]
- **contracts_added**: [list, or "none"]
- **contracts_removed**: [list, or "none"]
- **decisions_added**: [list, or "none"]
- **decisions_removed**: [list, or "none"]
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

1. Read requirements/architecture.md — every section
2. For EVERY section, classify each item as PASS / STALE / UNDER-DOC / OVER-SPEC:

   - **Core Patterns**: For each pattern, verify Structure/Contract/State flow/Extension/Invariants still match code. Check for new reusable patterns not yet documented.
   - **Interface Contracts**: For each contract, verify Producer/Consumer/Wiring/Contract/Verified-by. Check for new cross-module boundaries not yet documented.
   - **Glossary**: For each term, verify the module still exists and description matches code. Check for significant modules missing from glossary.
   - **Key Decisions**: For each decision, verify it is still in effect. Check for undocumented architectural decisions in code.
   - **Extension Guide**: Verify recipes still work against current code.
   - **Architecture Overview**: Verify structure description matches current codebase layout.

3. Report all mismatches using the same STALE/UNDER-DOC/OVER-SPEC classification as domain verification.

## Output

## Architecture Verification Result
- **status**: accurate | has_issues
- **stale_patterns**: [list, or "none"]
- **stale_contracts**: [list, or "none"]
- **stale_terms**: [list, or "none"]
- **stale_decisions**: [list, or "none"]
- **missing_patterns**: [list, or "none"]
- **missing_contracts**: [list, or "none"]
- **missing_terms**: [list, or "none"]
- **over_spec**: [list with details, or "none"]
```

## 5. Phase 3 — Fix All Issues

After all Phase 2 subagents complete, collect every domain that has STALE, UNDER-DOC, or OVER-SPEC items. For each such domain, launch a parallel fix subagent.

**This is the core of refresh — Phase 1 does the bulk update, Phase 2 finds gaps, Phase 3 closes every gap.**

**Subagent prompt** (fill in `{domain}`, `{domain_path}`, `{project_dir}`, `{issues_summary}`):

```
You are fixing the requirement docs for domain "{domain}" in the project at {project_dir}.

## Known issues from verification

{issues_summary}

## Task

Read the domain docs and source code, then fix ALL issues:
- STALE: remove or update acceptance criteria/descriptions that reference removed/changed code
- UNDER-DOC: add new user stories or acceptance criteria for implemented but undocumented behaviors
- OVER-SPEC: correct descriptions to match what the code actually does

## Steps

1. Read CLAUDE.md for conventions
2. Read requirements/{domain_path}/README.md (and sub-scenario files)
3. Read the source files that implement this domain
4. For each issue, verify it by reading the code, then fix the doc

## Rules

- Preserve existing document structure (US-XX format, Given/When/Then)
- Write user stories from an actor's perspective
- NO function names, class names, or variable names in user stories or acceptance criteria
- Do NOT invent business logic — only document what the code actually does
- REMOVE stale content cleanly — no commented-out remnants
- Section headings must be in English
- Do NOT create or modify any code files — docs only

## Output

## Domain Fix Result
- **domain**: {domain}
- **stale_fixed**: N
- **under_doc_fixed**: N
- **over_spec_fixed**: N
- **changes**: [brief list of what was changed]
```

Also launch a fix subagent for architecture.md if it had issues:

```
You are fixing requirements/architecture.md for the project at {project_dir}.

## Known issues

{arch_issues_summary}

## Task

Read the architecture doc and source code, then fix ALL issues — same standard as domain fixes:
- STALE: **DELETE** glossary terms for removed modules, patterns for deleted subsystems, contracts for boundaries that no longer exist, decisions that were superseded. Clean removal, no commented-out remnants.
- UNDER-DOC: ADD missing glossary terms, patterns, contracts, decisions
- OVER-SPEC: CORRECT descriptions that have drifted from code reality

## Rules

- REMOVE stale content cleanly — no commented-out remnants
- Do NOT invent architecture — only document what the code actually does
- Preserve existing section structure
- Do NOT modify any code files

## Output

## Architecture Fix Result
- **stale_fixed**: N (patterns, contracts, terms, decisions removed or corrected)
- **under_doc_fixed**: N (patterns, contracts, terms, decisions added)
- **over_spec_fixed**: N (descriptions corrected)
- **changes**: [brief list of what was changed]
```

## 6. Phase 4 — Summary Report

After all Phase 3 fix subagents complete, produce a consolidated report:

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

## 7. Index Update

After all phases, update `requirements/index.md` if:
- New domains were added during the forward pass
- Domain descriptions have changed

## 8. Execution Rules

1. **No git operations** — this skill only modifies requirement docs in the working tree
2. **One subagent per domain** — never batch multiple domains into one subagent
3. **Phase 2 waits for Phase 1** — reverse pass reads docs that the forward pass may have updated
4. **Phase 3 waits for Phase 2** — fix pass uses verification results to know what to fix
5. **Subagents are independent** — each reads its own context, no shared state
6. **Read before write** — every subagent must read the actual code before touching any doc
7. **Fix everything** — do NOT just report issues. The point of refresh is to make docs match code. Every STALE item must be removed/updated, every UNDER-DOC item must be documented, every OVER-SPEC item must be corrected. If Phase 2 finds issues, Phase 3 MUST run.

## 9. Stage Result

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
