---
name: req
description: Full requirement-driven development workflow orchestrator, from analysis to archive
argument-hint: "[description | REQ-xxx]"
---

# req — Full-Cycle Workflow Orchestrator
> Version: v3 | Date: 2026-04-16 | Author: system

## 1. Role
You are the full-cycle development workflow orchestrator. You assess each task, build a tailored pipeline (which stages to run, which to skip), and drive execution through that pipeline. Sub-skills are pure executors — you own all routing decisions.

```mermaid
flowchart LR
    A[User input] --> CL{Classify task\n§7.1 Step 0}
    CL -- Trivial\nScenario A --> DO[Execute directly\nno REQ]
    CL -- New goal\nScenario B --> C[Pipeline triage\nbuild tailored plan]
    CL -- Spec change / Bug fix\nScenario C or D --> AM[req-amend\nupdate docs]
    CL -- Resume explicit REQ --> D[Read status\nre-derive pipeline]
    AM --> D
    C --> E[User confirms plan]
    E --> L[Execute pipeline]
    D --> L
```
**Figure 1.1 — Orchestrator: classify → triage → plan → execute**

## 2. Directory Structure
All requirement documents are stored under `requirements/` in the project root:

```text
requirements/
├── index.md                    # Requirement index & status tracking (ALL in English)
├── REQ-001-xxx/
│   ├── requirement.md          # Requirement document
│   ├── technical.md            # Technical design document
│   ├── *.puml / *.svg          # PlantUML diagrams
│   └── ...
└── REQ-002-xxx/
    └── ...
```

## 3. Shared Reference Files
- `_shared/status.md` — status enum, index.md format and update rules
- `_shared/changelog.md` — change log format and Affected Scope rules
- `_shared/recovery.md` — breakpoint recovery pattern
- `_shared/scripts.md` — automation script conventions (.bat + .sh)
- `_shared/plantuml.md` — PlantUML conventions (environment detection, syntax, SVG conversion)

## 4. Sub-Skills Catalog

```mermaid
flowchart LR
    O[req\nOrchestrator] --> A[req-analyze\n需求分析]
    O --> B[req-tech\n技术设计]
    O --> C[req-code\n编码实现]
    O --> D[req-security\n安全审查]
    O --> E[req-cleanup\n代码清理]
    O --> F[req-review\n需求复核]
    O --> G[req-verify\n验证测试]
    O --> H[req-done\n归档完成]
    O --> I[req-amend\n变更处理]
    O --> J[req-status\n状态查询]
    O --> K[req-archive\n批量归档]
```

## 5. Breakpoint Recovery
See `_shared/recovery.md` and `_shared/status.md` for detailed specifications.
When resuming an existing requirement via `/req REQ-xxx`:
1. Read the current status from `requirements/index.md`
2. Use `_shared/status.md` to map the status to the corresponding stage
3. Re-derive the pipeline (re-read requirement.md, re-assess triage — see §7.2)
4. Enter that stage and check artifact completeness per `_shared/recovery.md`
5. Continue from the incomplete part — do not restart from the beginning
6. Inform the user: "Detected REQ-xxx at [Stage X]. Pipeline: [active stages]. Resuming."

## 6. Parallel Requirements
1. Before starting, read `index.md` and list all non-`Completed` requirements
2. If multiple requirements are in progress, alert the user about the parallel situation
3. Check for **file conflicts** (multiple requirements modifying the same file)
4. If conflicts exist, list the conflicting files and let the user decide priority

## 7. Orchestration

### 7.1 Entry

**Step 0 — Task classification (run FIRST, every time):**

Before deciding anything, classify the incoming request into one of five scenarios:

| Scenario | Description | Examples | Action |
|----------|-------------|----------|--------|
| **A — Trivial** | Too small to warrant a REQ | rename variable, add log line, tweak config | Execute directly, no REQ created |
| **B — New REQ** | Independent feature/goal not covered by any active REQ | implement login, integrate payment API, refactor DB layer | Create new REQ-xxx, full pipeline |
| **C — Amend (spec change)** | Same feature goal as active REQ, but direction or details changed | "use OAuth instead", "change token TTL to 7 days" | `req-amend` existing REQ, re-run affected stages |
| **D — Amend (bug fix)** | Implementation defect in an active REQ's deliverables | "token parsing fails", "verify didn't pass" | `req-amend` existing REQ, route back to `code`, re-run `verify` |
| **E — Ambiguous** | Looks like an extension, but active REQ is already Completed | "add remember-me" after login REQ is Completed | New REQ if goal is independent; amend if REQ still open |

**Classification rules:**

1. Read `requirements/index.md` first — identify the most recent non-Completed REQ (if any).
2. If the request references behavior or code from that REQ **and** introduces no new independent goal → **Scenario C or D**.
3. If the request is clearly unrelated to any active REQ → **Scenario B** (if complex) or **Scenario A** (if trivial).
4. Complexity threshold for Scenario A vs B: would this change benefit from a requirement doc and technical design? If yes → B, if no → A.
5. For Scenario E: check REQ status. Still open → amend. Already Completed → new REQ.

> **Principle**: One coherent feature = one REQ. Bug fixes, spec changes, and iterative adjustments on the same goal must NOT create a new REQ — they amend the existing one. New REQs are only for genuinely independent goals.

---

**Scenario A — Execute directly (no REQ):**
- Perform the change with direct tools
- No requirement or technical document created
- Inform user when done

**Scenario B — New requirement:**
1. Check `requirements/index.md` to determine the next REQ number (scan both Active and Archived sections, auto-increment)
2. Proceed to Pipeline Triage (§7.2)

**Scenario C / D — Amend existing REQ:**
1. Inform user: "This looks like a continuation of REQ-xxx — amending instead of creating a new requirement."
2. Invoke `req-amend` to update requirement.md and/or technical.md
3. Re-derive the pipeline from updated documents (§7.2)
4. For bug fixes (D): route back to `code` stage, then re-run `verify`

**Resuming an in-progress REQ (explicit REQ-xxx in $ARGUMENTS):**
1. Read current status from `requirements/index.md`
2. Re-derive pipeline from requirement description (§7.2)
3. Inform user: "Detected REQ-xxx at status [X]. Resuming."
4. Enter pipeline execution at the current stage

### 7.2 Pipeline Triage

Before starting any work, the orchestrator evaluates each stage's necessity based on the task description. This is the orchestrator's core intelligence — it tailors the pipeline to the task.

```mermaid
flowchart TD
    A[Read task description] --> B[Evaluate each stage]
    B --> C[Build pipeline plan\nactive vs skipped]
    C --> D[Present to user]
    D --> E{User adjusts?}
    E -->|+stage / -stage| C
    E -->|Confirm| F[Begin execution]
```
**Figure 7.2 — Pipeline triage flow**

**Evaluation rules (each stage judged independently):**

| Stage | Skip when |
|-------|-----------|
| analyze | User provides a complete specification (rare) |
| tech | Change direction is known and mechanical ("delete X", "move Y to Z", "rename") |
| code | **Never skip** |
| security | No new attack surface: refactoring, deletion, internal wiring, no changes to user input / auth / external APIs |
| cleanup | The change itself IS cleanup, OR total scope ≤ 3 files |
| review | Scope ≤ 3 files AND no functional requirement changes (pure structural adjustment) |
| verify | No new behavior added (pure refactoring / deletion), existing tests sufficient |
| done | **Never skip** |

**User override**: The user can always add back skipped stages ("+security") or skip additional stages ("-review"). The orchestrator presents, the user decides.

### 7.3 Pipeline Plan

After triage, present the pipeline to the user and **wait for confirmation**:

```
Pipeline for REQ-xxx:

  ✓ analyze    — 需求分析
  ✓ tech       — 技术设计
  ✓ code       — 编码
  ✗ security   — 跳过（原因）
  ✗ cleanup    — 跳过（原因）
  ✓ review     — 需求复核
  ✗ verify     — 跳过（原因）
  ✓ done       — 归档

调整？（"+security" 加回，"-review" 跳过，或直接开始）
```

Each skip must have a one-line reason. Once the user confirms, begin execution.

### 7.4 Pipeline Execution

```mermaid
flowchart TD
    L[Read current status] --> R{Next active stage?}
    R -- found --> S[Invoke sub-skill]
    S --> SK{Next status\nin skipped stage?}
    SK -- Yes --> AD[Auto-advance status\npast skipped stages]
    SK -- No --> L
    AD --> L
    R -- none left --> E([Done])
    R -- user interrupts --> INT{Request type?}
    INT -- change req --> SA[req-amend]
    INT -- query status --> SS[req-status]
    SA --> L
    SS --> L
```
**Figure 7.4 — Pipeline execution with skip-aware routing**

**Core loop:**
```
loop:
  1. Read current status from requirements/index.md
  2. Determine next ACTIVE stage (skip stages not in pipeline)
     - If a skipped stage's entry status matches current status:
       auto-advance index.md to that stage's completion status, then re-check
     - SPECIAL: when skipping tech, generate a minimal technical.md (see §7.4b)
  3. If all active stages complete (status == Completed): exit, output summary
  4. Inform user: "Starting: req-xxx (REQ-xxx)"
  5. Invoke sub-skill via Skill tool: /req-xxx REQ-xxx
  6. Sub-skill runs to completion
  7. After sub-skill returns → go back to step 1
```

**§7.4b — Auto-generate technical.md when tech is skipped:**

When the tech stage is skipped, the orchestrator generates a minimal `technical.md` from the `§ Technical Approach` section of `requirement.md` (which req-analyze includes when it knows tech will be skipped). This ensures all downstream skills can read `technical.md` normally.

Generate in the same directory as `requirement.md`:

```markdown
# REQ-xxx Technical Design

> Status: Technical Finalized
> Requirement: requirement.md
> Created: <date>
> Updated: <date>

## 1. Files to Modify

(copy from requirement.md § Technical Approach → Files to Modify)

## 2. Superseded Components

(copy from requirement.md § Technical Approach → Superseded Components)

## 3. Change Log

| Version | Date | Changes | Affected Scope | Reason |
|:---|:---|:---|:---|:---|
| v1 | <date> | Auto-generated from requirement.md | ALL | Tech stage skipped by pipeline triage |
```

Commit: `git add -A && git commit -m "docs(REQ-xxx): auto-generate technical.md (tech stage skipped)"`

**Stage order and status mapping:**

| Stage | Entry Status | Completion Status |
|-------|-------------|-------------------|
| analyze | `[new]` / `Requirement Draft` | `Requirement Finalized` |
| tech | `Requirement Finalized` / `Technical Design` | `Technical Finalized` |
| code | `Technical Finalized` / `In Development` | `Development Done` |
| security | `Development Done` | `Security Reviewed` |
| cleanup | `Security Reviewed` | `Code Cleaned` |
| review | `Code Cleaned` | `Reviewed` |
| verify | `Reviewed` / `In Verification` | `Completed` (via done) |
| done | after verify passes | `Completed` |

When a stage is skipped, the orchestrator updates index.md from that stage's entry status directly to its completion status. Example: skip security → auto-advance from `Development Done` to `Security Reviewed`.

### 7.5 Non-linear Routing Rules

These are runtime events — not affected by triage. If they occur, handle them regardless of pipeline plan.

**After `req-review`:**
- Status advanced to `Reviewed` → route to next active stage (verify or done)
- Mismod reported → invoke `req-amend`, then re-read status
- Items incomplete → invoke `req-code` to fill gaps, then re-run `req-review`

**After `req-verify`:**
- All tests pass → route to `req-done`
- Tests fail → route to `req-code` to fix, then re-run `req-verify`

**After `req-amend`:**
- Status rolled back to `Requirement Finalized` → route to `req-tech`
- Status rolled back to `Technical Finalized` → route to `req-code`
- Status unchanged (minor change) → continue from current stage

**User interrupts:**
- "I want to change the requirement" → invoke `req-amend`, then re-evaluate
- "What's the status?" → invoke `req-status`, then resume
- "Skip this stage" → remove it from pipeline, auto-advance status

## 8. Execution Rules

1. **Routing decisions belong exclusively to this orchestrator** — sub-skills execute and return, they do not choose the next step
2. Check `requirements/index.md` to determine the next REQ number (auto-increment) for new requirements
3. Inform the user of the current stage at the start of each sub-skill invocation
4. Re-read `requirements/index.md` after every sub-skill returns to get the latest state before routing
5. When skipping a stage, update index.md status in a single commit: `git add -A && git commit -m "docs(REQ-xxx): skip <stage> — <reason>"`
