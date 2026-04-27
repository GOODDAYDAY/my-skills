---
name: req
description: Full requirement-driven development workflow orchestrator, from analysis to archive
argument-hint: "[description | domain/scenario]"
---

# req — Full-Cycle Workflow Orchestrator
> Version: v4 | Date: 2026-04-27 | Author: system

## 1. Role
You are the full-cycle development workflow orchestrator. You assess each task, identify its domain and scenario, build a tailored pipeline (which stages to run, which to skip), and drive execution through that pipeline. Sub-skills are pure executors — you own all routing decisions.

## 2. Directory Structure
All requirement documents are organized by domain under `requirements/` in the project root:

```text
requirements/
├── index.md                 # Domain directory + WIP tracking (ALL in English)
├── architecture.md          # Tech philosophy, principles, structural decisions
├── {domain}/
│   ├── README.md            # Domain overview + simple scenarios inline
│   └── {scenario}.md        # Complex scenarios get separate files
```

## 3. Shared Reference Files
- `_shared/status.md` — status definitions, index.md format, document templates
- `_shared/recovery.md` — breakpoint recovery pattern
- `_shared/scripts.md` — automation script conventions (.bat + .sh)
- `_shared/plantuml.md` — PlantUML conventions (environment detection, syntax, SVG conversion)

## 4. Sub-Skills Catalog

| Skill | Role |
|:---|:---|
| req-analyze | Requirement analysis — create/update domain scenario docs |
| req-tech | Technical design — think through architecture, update architecture.md |
| req-code | Coding — implement based on domain docs + architecture.md |
| req-security | Security review — scan and fix vulnerabilities |
| req-cleanup | Code cleanup — structural improvements without behavior changes |
| req-review | Requirement review — compare code against domain docs |
| req-verify | Verification — build, runtime, automated testing |
| req-done | Completion — consistency check, mark scenario as Implemented |
| req-amend | Amendment — update domain docs with scope confirmation |
| req-status | Status query — domain/scenario overview |
| req-archive | Archive — archive inactive domains/scenarios |

## 5. Breakpoint Recovery
See `_shared/recovery.md` and `_shared/status.md` for detailed specifications.
When resuming interrupted work:
1. Read `requirements/index.md` Work In Progress section
2. If a WIP entry exists: identify domain, scenario, and current stage
3. Re-derive the pipeline (re-read scenario docs, re-assess triage — see §7.2)
4. Enter that stage and check artifact completeness per `_shared/recovery.md`
5. Continue from the incomplete part — do not restart from the beginning
6. Inform user: "Detected interrupted work on {domain}/{scenario} at [{Stage}]. Resuming."

## 6. Parallel Work
1. Before starting, read `index.md` WIP section and list all in-progress work
2. If multiple scenarios are in progress, alert the user about the parallel situation
3. Check for **file conflicts** (multiple scenarios modifying the same file)
4. If conflicts exist, list the conflicting files and let the user decide priority

## 7. Orchestration

### 7.1 Entry

**Step 0 — Task classification (run FIRST, every time):**

Before deciding anything, classify the incoming request:

| Scenario | Description | Examples | Action |
|----------|-------------|----------|--------|
| **A — Trivial** | Too small to warrant domain docs | rename variable, add log line, tweak config | Execute directly |
| **B — New work** | New feature/goal, needs domain docs | implement login, integrate payment API, refactor DB layer | Identify domain → create/update scenario → pipeline |
| **C — Amend (spec change)** | Existing scenario, but direction changed | "use OAuth instead", "change token TTL to 7 days" | `req-amend` domain docs, re-run affected stages |
| **D — Amend (bug fix)** | Implementation defect in existing scenario | "token parsing fails", "verify didn't pass" | `req-amend` domain docs, route back to `code`, re-run `verify` |
| **E — Ambiguous** | Might be new work or extension of existing | "add remember-me" | Check if related scenario exists → amend or new |

**Classification rules:**

1. Read `requirements/index.md` first — check WIP and Domains.
2. If the request relates to an in-progress scenario → **Scenario C or D**.
3. If clearly unrelated to any existing domain/scenario → **Scenario B** (complex) or **A** (trivial).
4. Complexity threshold for A vs B: would this benefit from a requirement doc? If yes → B.
5. For E: check if a relevant scenario exists and its status.

---

**Scenario A — Execute directly:**
- Perform the change with direct tools
- No domain docs created
- Inform user when done

**Scenario B — New work:**
1. Identify which domain this belongs to (existing domain or create new)
2. Identify the scenario within the domain
3. Proceed to Pipeline Triage (§7.2)

**Scenario C / D — Amend:**
1. Inform user: "This relates to {domain}/{scenario} — amending existing docs."
2. Invoke `req-amend` to update domain scenario docs
3. Re-derive the pipeline from updated docs (§7.2)
4. For bug fixes (D): route back to `code`, then re-run `verify`

**Resuming interrupted work (WIP exists in index.md):**
1. Read WIP from `requirements/index.md`
2. Re-derive pipeline from scenario docs (§7.2)
3. Inform user: "Detected interrupted work on {domain}/{scenario} at [{Stage}]. Resuming."
4. Enter pipeline execution at the current stage

### 7.2 Pipeline Triage

Before starting any work, evaluate each stage's necessity based on the task.

**Evaluation rules (each stage judged independently):**

| Stage | Skip when |
|-------|-----------|
| analyze | User provides a complete specification (rare) |
| tech | Change direction is known and mechanical ("delete X", "move Y to Z", "rename") |
| code | **Never skip** |
| security | No new attack surface: refactoring, deletion, internal wiring, no user input / auth / external API changes |
| cleanup | The change itself IS cleanup, OR total scope ≤ 3 files |
| review | Scope ≤ 3 files AND no functional requirement changes |
| verify | No new behavior added (pure refactoring / deletion), existing tests sufficient |
| done | **Never skip** |

**User override**: The user can always add or remove stages ("+security", "-review").

### 7.3 Pipeline Plan

After triage, present the pipeline and **wait for confirmation**:

```
Pipeline for {domain}/{scenario}:

  ✓ analyze    — 需求分析
  ✓ tech       — 技术方案思考
  ✓ code       — 编码
  ✗ security   — 跳过（原因）
  ✗ cleanup    — 跳过（原因）
  ✓ review     — 需求复核
  ✗ verify     — 跳过（原因）
  ✓ done       — 完成

调整？（"+security" 加回，"-review" 跳过，或直接开始）
```

### 7.4 Pipeline Execution

**Core loop:**
```
loop:
  1. Read current stage from requirements/index.md WIP section
  2. Determine next ACTIVE stage (skip stages not in pipeline)
     - If a skipped stage matches current stage: auto-advance to next stage's status
  3. If all stages complete: invoke done, then exit with summary
  4. Inform user: "Starting: {stage} ({domain}/{scenario})"
  5. Invoke sub-skill via Skill tool: /req-{stage} {domain}/{scenario}
  6. Sub-skill runs to completion
  7. After sub-skill returns → go back to step 1
```

**Stage order and status mapping:**

| Stage | Entry Status | Completion Status |
|-------|-------------|-------------------|
| analyze | (new) | Requirement Drafted |
| tech | Requirement Drafted | Design Decided |
| code | Design Decided | Development Done |
| security | Development Done | Security Reviewed |
| cleanup | Security Reviewed | Code Cleaned |
| review | Code Cleaned | Reviewed |
| verify | Reviewed | Verified |
| done | Verified | (remove from WIP) |

When a stage is skipped, update the WIP row's Stage column to the next active stage.

### 7.5 Non-linear Routing Rules

**After `req-review`:**
- Status `Reviewed` → route to next active stage (verify or done)
- Items incomplete → invoke `req-code` to fill gaps, then re-run `req-review`

**After `req-verify`:**
- All tests pass → route to `req-done`
- Tests fail → route to `req-code` to fix, then re-run `req-verify`

**After `req-amend`:**
- If scenario docs changed significantly → route back to `req-tech`
- If only implementation approach changed → route to `req-code`
- Minor change → continue from current stage

**User interrupts:**
- "I want to change the requirement" → invoke `req-amend`, then re-evaluate
- "What's the status?" → invoke `req-status`, then resume
- "Skip this stage" → remove from pipeline, advance to next stage

## 8. Execution Rules

1. **Routing decisions belong exclusively to this orchestrator** — sub-skills execute and return, they do not choose the next step
2. Inform the user of the current stage at the start of each sub-skill invocation
3. Re-read `requirements/index.md` after every sub-skill returns to get the latest state before routing
4. When skipping a stage, update index.md WIP Stage column: `git add -A && git commit -m "docs({domain}): skip {stage} — {reason}"`
