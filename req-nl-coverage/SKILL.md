---
name: req-nl-coverage
description: 'Measure NL (Natural Language) implementation and accuracy — how much NL has landed in code, and whether NL matches reality. TRIGGER when: user asks for NL coverage, NL implementation rate, NL accuracy, or says "NL覆盖率", "NL实现率", "NL准确率"'
argument-hint: "[--domain X | --history]"
---

# req-nl-coverage — NL Implementation & Accuracy Analysis

## 1. Role

You measure whether NL (natural language requirements) is **landed** and **accurate**.

NL is the glue layer — the center of truth. Code is implementation detail. We don't care if code is "covered" by NL. We care if NL is **realized** in code and **consistent** with code.

**What we measure:**

| Metric | Question | Why it matters |
|:---|:---|:---|
| **NL Implementation Rate** | Has this NL been implemented in code? | Unimplemented NL = backlog, need visibility |
| **NL Accuracy** | Does NL match what code actually does? | Inaccurate NL = broken glue, misleads everyone |
| **NL Precision** | Is NL specific enough to stick to downstream? | Vague NL = can't drive tests or development |

**What we don't care about:**
- Whether code is covered by NL (code is detail)
- Whether NL is complete (more NL is fine, as long as it's not wrong)
- Whether NL is too coarse-grained (coarse is OK, wrong is not)

## 2. Arguments

| Argument | Effect |
|:---|:---|
| (empty) | Full analysis: all domains |
| `--domain {name}` | Analyze one domain only |
| `--history` | Show trend from `.nl-coverage-history.json` |

## 3. Core Concepts

### 3.1 NL Unit

An **NL unit** is a single acceptance criterion (AC) within a user story. ACs are the atomic units of NL — specific enough to verify, small enough to check.

Each AC is classified:

| Status | Meaning |
|:---|:---|
| **Implemented** | Code exists that matches this AC's behavior |
| **Unimplemented** | No code found matching this AC (backlog) |
| **Conflicting** | Code exists but does something different from what AC says |
| **Vague** | AC is too fuzzy to determine if implemented or conflicting |

### 3.2 Conflict Detection

A **conflict** is when NL says X but code does Y. This is the most critical issue — NL as glue is broken.

Examples:
- NL: "最多导出 1000 条记录" → Code: limit is 500
- NL: "删除后立即从数据库移除" → Code: soft delete (sets `deleted_at`)
- NL: "自动重试 3 次" → Code: retries 5 times
- NL: "返回 404" → Code: returns 400

### 3.3 Vagueness Detection

An AC is **vague** if it cannot serve as input to downstream processes (test generation, development).

Signals of vagueness:
- No concrete values: "系统应该快速响应" (what is "快速"?)
- No specific behavior: "处理用户的请求" (what request? how?)
- Subjective language: "更好的体验", "更方便"
- Missing boundaries: no numbers, no conditions, no states

An AC is **precise enough** if:
- It has concrete inputs and expected outputs
- It can be translated into a test case (even manually)
- A developer can implement it without asking "what exactly?"

### 3.4 Implementation Detection

An AC is **implemented** if code exists whose behavior matches the AC's Given/When/Then.

Detection strategy:
1. **Structural match**: AC references specific file/function in Implementation Approach → check that code
2. **Keyword match**: Extract key actions from AC → find matching code behavior
3. **Semantic match**: Present AC alongside candidate code → LLM judges if behavior matches

A match means: the code does what the AC says. Not "similar", not "related" — **does what it says**.

## 4. Algorithm

### 4.1 Extract NL Units

```
For each domain in requirements/index.md:
  1. Read domain README.md + scenario files
  2. Extract all user stories (US-XX format)
  3. For each story:
     a. Extract acceptance criteria (Given/When/Then)
     b. For each AC, record:
        - story_id, ac_index
        - given clause (context/preconditions)
        - when clause (action/trigger)
        - then clause (expected outcome)
        - full text
  4. Collect all ACs as NL units
```

### 4.2 Extract Code Behaviors

```
For each domain in requirements/index.md:
  1. Read domain's Implementation Approach → get source file list
  2. If no Implementation Approach, infer source files from domain path/name
  3. For each source file:
     a. Extract public functions/methods (exclude private, test, generated)
     b. For each behavior, record:
        - file, line, signature
        - docstring/comments
        - key logic (parameters, conditions, return values, side effects)
  4. Collect all behaviors
```

### 4.3 Classify Each AC

```
For each AC in nl_units:
  
  # Step 1: Check vagueness
  if is_vague(ac):
    ac.status = "vague"
    ac.vagueness_reason = explain_why_vague(ac)
    continue
  
  # Step 2: Find matching code behavior
  candidates = find_matching_behaviors(ac, code_behaviors)
  
  if not candidates:
    ac.status = "unimplemented"
    continue
  
  # Step 3: Check for conflicts
  best_match = candidates[0]
  conflict = detect_conflict(ac, best_match)
  
  if conflict:
    ac.status = "conflicting"
    ac.conflict_detail = conflict
  else:
    ac.status = "implemented"
    ac.matched_behavior = best_match
```

**Vagueness check:**
```
def is_vague(ac):
  # No concrete values in then clause
  if not has_concrete_values(ac.then):
    return True
  # Subjective language
  if has_subjective_language(ac.full_text):
    return True
  # Missing key details
  if not has_specific_behavior(ac):
    return True
  return False
```

**Conflict detection:**
```
def detect_conflict(ac, behavior):
  # Extract key values from AC
  ac_values = extract_values(ac)  # numbers, strings, conditions
  
  # Extract corresponding values from code
  code_values = extract_values_from_code(behavior)
  
  # Compare
  conflicts = []
  for key in ac_values:
    if key in code_values and ac_values[key] != code_values[key]:
      conflicts.append({
        "ac_says": f"{key} = {ac_values[key]}",
        "code_does": f"{key} = {code_values[key]}",
        "location": behavior.location
      })
  
  return conflicts if conflicts else None
```

### 4.4 Calculate Metrics

```
total_acs = len(nl_units)
implemented = len([ac for ac in nl_units if ac.status == "implemented"])
unimplemented = len([ac for ac in nl_units if ac.status == "unimplemented"])
conflicting = len([ac for ac in nl_units if ac.status == "conflicting"])
vague = len([ac for ac in nl_units if ac.status == "vague"])

implementation_rate = implemented / (total_acs - vague) * 100  # exclude vague from denominator
accuracy_rate = implemented / (implemented + conflicting) * 100
precision_rate = (total_acs - vague) / total_acs * 100
```

## 5. Output

### 5.1 Coverage Report

```markdown
# NL Coverage Report

Generated: {YYYY-MM-DD HH:MM} | {N} domains, {M} stories, {K} ACs

## Summary

| Metric | Value |
|:---|:---|
| NL 总数 | {K} ACs in {M} stories |
| 已实现 | {implemented} ACs ({implementation_rate}%) |
| 未实现 | {unimplemented} ACs |
| 冲突 | {conflicting} ACs |
| 模糊 | {vague} ACs ({precision_rate}% precise) |

## 冲突（NL 和代码不一致）

{If conflicting > 0, list all conflicts}

| Story | AC | NL 描述 | 代码实际行为 | 位置 |
|:---|:---|:---|:---|:---|
| {story_id} | AC-{n} | {ac.then} | {code_does} | {file}:{line} |

## 未实现（NL 还没落地）

{If unimplemented > 0, list all unimplemented ACs}

| Story | AC | 描述 |
|:---|:---|:---|
| {story_id} | AC-{n} | {ac.full_text} |

## 模糊（无法粘住下游）

{If vague > 0, list all vague ACs}

| Story | AC | 描述 | 模糊点 |
|:---|:---|:---|:---|
| {story_id} | AC-{n} | {ac.full_text} | {vagueness_reason} |
```

### 5.2 History Tracking

After each analysis, append to `{project_root}/.nl-coverage-history.json`:

```json
{
  "entries": [
    {
      "date": "2026-05-29T10:30:00",
      "total_acs": 120,
      "implemented": 85,
      "unimplemented": 20,
      "conflicting": 5,
      "vague": 10,
      "implementation_rate": 77.3,
      "accuracy_rate": 94.4,
      "precision_rate": 91.7,
      "domain_breakdown": {
        "auth": {
          "total": 25,
          "implemented": 22,
          "unimplemented": 2,
          "conflicting": 1,
          "vague": 0
        }
      }
    }
  ]
}
```

### 5.3 Trend Report (`--history`)

```markdown
# NL Coverage Trend

| Date | Total ACs | Implemented | Unimplemented | Conflicting | Vague | Impl Rate | Accuracy | Precision |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 2026-05-15 | 100 | 70 | 20 | 5 | 5 | 73.7% | 93.3% | 95.0% |
| 2026-05-22 | 110 | 80 | 18 | 7 | 5 | 76.2% | 92.0% | 95.5% |
| 2026-05-29 | 120 | 85 | 20 | 5 | 10 | 77.3% | 94.4% | 91.7% |

Δ Implementation Rate: +3.6% over 2 weeks
Δ Accuracy Rate: +1.1% over 2 weeks
Δ Precision Rate: -3.3% over 2 weeks (more vague ACs added)
```

## 6. Integration Points

### 6.1 req-refresh Integration

req-refresh calls this skill at Phase 4 (after Fix, before Report):

```
Phase 4 — NL Coverage Analysis:
  1. Run full analysis per §4
  2. Include coverage metrics in Summary Report (Phase 5)
  3. Write history entry to .nl-coverage-history.json
  4. Prioritize conflicts for immediate fix
```

### 6.2 req-catalog Integration

req-catalog embeds coverage metrics in CATALOG.md header:

```markdown
# Requirements Catalog
Generated: {date} | {N} domains, {M} documents

## NL Coverage

| Metric | Value |
|:---|:---|
| NL Implementation | {implementation_rate}% ({implemented}/{total-vague}) |
| NL Accuracy | {accuracy_rate}% ({implemented}/{implemented+conflicting}) |
| NL Precision | {precision_rate}% ({total-vague}/{total}) |
```

If `.nl-coverage-history.json` exists, also include trend row.

### 6.3 req Pipeline — Justify Stage

The justify stage (§4.9 in req/SKILL.md) references NL coverage as a quality signal:

| Condition | Justify Verdict |
|:---|:---|
| Conflicting = 0 AND Precision ≥ 90% | NL healthy — no action |
| Conflicting ≤ 2 OR Precision ≥ 80% | NL acceptable — note issues |
| Conflicting > 2 OR Precision < 80% | NL gap — flag for user |

## 7. Execution Modes

### 7.1 Full Analysis (default)

```
1. Read requirements/index.md
2. For each domain: launch parallel subagent per §4.1–4.3
3. Aggregate results
4. Calculate metrics per §4.4
5. Generate report per §5.1
6. Write history per §5.2
```

**Subagent prompt** (fill in `{domain}`, `{domain_path}`, `{project_dir}`):

```
You are analyzing NL coverage for domain "{domain}" in project at {project_dir}.

## Task

Extract all ACs and classify each as: implemented / unimplemented / conflicting / vague.

## Steps

1. Read requirements/{domain_path}/README.md (and scenario files)
2. Extract all user stories and acceptance criteria
3. From Implementation Approach (or domain inference), identify source files
4. Read each source file, extract public behaviors
5. For each AC:
   a. Check if vague (no concrete values, subjective language, missing behavior)
   b. If not vague, find matching code behavior
   c. If no match → unimplemented
   d. If match found, check for conflicts (NL says X, code does Y)
   e. If conflict → conflicting, else → implemented
6. Report results

## Output

## Domain Coverage Result
- **domain**: {domain}
- **total_acs**: N
- **implemented**: N
- **unimplemented**: N (list: [{story_id}, AC-{n}, {ac_text}])
- **conflicting**: N (list: [{story_id}, AC-{n}, {ac_says}, {code_does}, {location}])
- **vague**: N (list: [{story_id}, AC-{n}, {ac_text}, {reason}])
```

### 7.2 Single Domain (`--domain {name}`)

Same as full but only for the specified domain. Skip aggregation.

### 7.3 History (`--history`)

Read `.nl-coverage-history.json`, generate trend report per §5.3. No code scanning.

## 8. Rules

1. **No code modification** — this skill is read-only analysis
2. **Conflict is critical** — always list conflicts first, they break the glue
3. **Vague is not wrong** — vague ACs are excluded from implementation rate, but flagged for improvement
4. **Unimplemented is backlog** — not a problem, just visibility
5. **Respect .gitignore** — do not scan ignored files
6. **Skip generated code** — files in `node_modules`, `vendor`, `dist`, `build`, `__pycache__`, `.git`
7. **Skip test files** — tests are not "code behaviors" for coverage purposes
8. **History file is append-only** — never delete entries, only append
9. **Per-domain parallelism** — full analysis launches one subagent per domain
10. **Language detection** — infer from file extensions, not project config

## 9. Stage Result

```
## Stage Result
- **status**: completed
- **domains_analyzed**: N
- **total_acs**: N
- **implemented**: N
- **unimplemented**: N
- **conflicting**: N
- **vague**: N
- **implementation_rate**: N%
- **accuracy_rate**: N%
- **precision_rate**: N%
- **history_written**: yes | no
```
