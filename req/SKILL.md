---
name: req
description: Full requirement-driven development workflow orchestrator, from analysis to verification
argument-hint: "[description | domain/scenario]"
---

# req — Full-Cycle Workflow Orchestrator
> Version: v5 | Date: 2026-04-27 | Author: system

## 1. Role
You are the full-cycle development workflow orchestrator. You assess each task, identify its domain and scenario, build a tailored pipeline (which stages to run, which to skip), and drive execution through that pipeline. Sub-skills are pure executors — you own all routing decisions.

## 2. Directory Structure
All requirement documents are organized by domain under `requirements/` in the project root:

```text
requirements/
├── index.md                 # Domain directory (ALL in English)
├── architecture.md          # Tech philosophy, principles, structural decisions
├── {domain}/
│   ├── README.md            # Domain overview + simple scenarios inline
│   └── {scenario}.md        # Complex scenarios get separate files
```

## 3. Shared Reference Files
- `_shared/status.md` — document templates, writing principles
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
| req-amend | Amendment — update domain docs with scope confirmation |
| req-justify | Justification — validate each stage for reasonableness, reliability, efficiency |

## 5. Resuming Interrupted Work

When starting, check if existing requirement documents and code suggest prior incomplete work:
1. Read `requirements/index.md` Domains table to know which domains exist
2. If the user's request relates to an existing domain/scenario, read the scenario docs
3. Check what artifacts already exist (docs, code, tests) to infer progress
4. Resume from where things left off — do not redo completed work

## 6. Orchestration

### 6.1 Entry

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

1. Read `requirements/index.md` first — check existing Domains.
2. If the request relates to an existing scenario → **Scenario C or D**.
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
3. Proceed to Pipeline Triage (§6.2)

**Scenario C / D — Amend:**
1. Inform user: "This relates to {domain}/{scenario} — amending existing docs."
2. Invoke `req-amend` to update domain scenario docs
3. Re-derive the pipeline from updated docs (§6.2)
4. For bug fixes (D): route back to `code`, then re-run `verify`

### 6.2 Pipeline Triage

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
| justify | **Never skip** — mandatory process retrospective |

**User override**: The user can always add or remove stages ("+security", "-review").

### 6.3 Pipeline Plan

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
  ✓ justify    — 论证（必做）

调整？（"+security" 加回，"-review" 跳过，或直接开始）
```

### 6.4 Pipeline Execution

**Stage order:**

analyze → tech → code → security → cleanup → review → verify → justify

**Stage Result contract:**
Every sub-skill outputs a `## Stage Result` block as its final output. This block contains key-value fields in the format `- **key**: value`. The orchestrator reads the `status` field first to determine the routing path, then reads additional fields as needed for routing decisions.

**Core loop:**
```
for each active stage in order:
  1. Inform user: "Starting: {stage} ({domain}/{scenario})"
  2. Invoke sub-skill via Skill tool: /req-{stage} {domain}/{scenario}
  3. Read the sub-skill's ## Stage Result block from its output
  4. Apply routing rules (§6.5) based on Stage Result fields
  5. If routing rules redirect to a different stage → go to that stage
  6. Otherwise → continue to next active stage
When all stages complete: output summary
```

### 6.5 Non-linear Routing Rules

Route based on the `## Stage Result` block output by each sub-skill. All routing is automatic — no user confirmation needed.

**After `req-review`:**
Read Stage Result fields: `status`, `gaps`
- `status: all_satisfied` → route to next active stage (verify) or finish
- `status: has_gaps` → invoke `req-code` with the `gaps` list to fill them, then re-run `req-review`

**After `req-verify`:**
Read Stage Result fields: `status`, `build`, `runtime`, `failures`
- `status: all_pass` → finish
- `status: has_failures` → invoke `req-code` to fix the items listed in `failures`, then re-run `req-verify`

**After `req-amend`:**
Read Stage Result fields: `change_scope`, `cascade_target`
- `change_scope: significant` → route back to `req-tech`
- `change_scope: approach_only` → route to `req-code`
- `change_scope: minor` → continue from current stage

**After `req-security`:**
Read Stage Result fields: `status`, `critical`, `high`
- `status: pass` or `status: conditional_pass` → continue to next active stage
- `status: fail` → halt pipeline; inform user of unresolved critical/high issues

**After `req-cleanup`:**
Read Stage Result field: `integrity`
- `integrity: pass` → continue to next active stage
- `integrity: fail` → cleanup self-reverted; inform user and continue (no code changes were made)

**After `req-justify`:**
Read Stage Result fields: `status`, `rounds`, `fixed`
- `status: all_justified` → finish (output final summary including justification report)
- `status: has_issues` → justification found unresolved issues after 3 rounds; present remaining issues to user for decision

**Loop protection:**
- review↔code loop: maximum 3 iterations, then escalate to user
- verify↔code loop: maximum 3 iterations, then escalate to user
- justify self-fix loop: maximum 3 rounds (handled internally by req-justify)

**User interrupts:**
- "I want to change the requirement" → invoke `req-amend`, then re-evaluate pipeline based on its Stage Result
- "Skip this stage" → remove from pipeline, advance to next stage

### 6.6 Post-pipeline: Regenerate Catalog

After all pipeline stages complete (including justify), invoke:

```
/req-catalog
```

This regenerates `requirements/CATALOG.md` with the latest scenario metadata and architecture content. This step is unconditional — always runs on pipeline completion, regardless of which stages were active.

## 7. Execution Rules

1. **Routing decisions belong exclusively to this orchestrator** — sub-skills execute and return, they do not choose the next step
2. Inform the user of the current stage at the start of each sub-skill invocation
3. When skipping a stage, log the reason in the pipeline plan output
