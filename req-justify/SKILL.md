---
name: req-justify
description: Justification — validate each pipeline stage for reasonableness, reliability, and efficiency
argument-hint: "[domain/scenario]"
---

# req-justify
> Version: v1 | Date: 2026-04-30 | Author: system

## 1. Overview
You are responsible for the justification stage — after all other stages complete, review each executed stage's decisions and outputs to validate they are reasonable, reliable, and efficient.

This is a **meta-review of the process itself**, not a review of code vs requirements (that's req-review) or build/test verification (that's req-verify).

## 2. Prerequisites

- `$ARGUMENTS` provides domain/scenario identifier
- All prior pipeline stages must have completed
- Scenario document, architecture.md, source code, and test artifacts must be available

## 3. Three Dimensions

Every executed stage is evaluated against three dimensions:

| Dimension | Question |
|-----------|----------|
| 合理性 (Reasonableness) | Was this stage's scope, direction, and decisions appropriate? Any omissions or overreach? |
| 可靠性 (Reliability) | Are the outputs complete, accurate, and trustworthy? Any logical gaps or unverified assumptions? |
| 高效性 (Efficiency) | Any redundant steps, over-engineering, or wasted effort? Could the same result be achieved more simply? |

## 4. Per-Stage Audit Checklist

### analyze
- **合理性**: Are user stories complete and correctly scoped? Any missed scenarios? Any over-splitting or under-splitting?
- **可靠性**: Are acceptance criteria testable and unambiguous? Do they fully reflect the user's intent?
- **高效性**: Is the requirement document concise? Any redundant stories or criteria that could be merged?

### tech
- **合理性**: Does the architecture match the requirement's complexity — not over-engineered for simple tasks, not under-designed for complex ones? Were alternatives considered? If this scenario introduces or modifies a cross-module boundary, is the Interface Contract documented in architecture.md? If a new reusable pattern was established, is it captured in Core Patterns?
- **可靠性**: Are the chosen technologies and patterns proven for this use case? Any risky assumptions about dependencies or integration? Are Interface Contracts complete and accurate (producer, consumer, wiring, contract, verified by)?
- **高效性**: Could a simpler architecture achieve the same goals? Any unnecessary abstraction layers or indirection?

### code
- **合理性**: Does the implementation faithfully follow the design? Any deviations creating hidden technical debt? Is module decomposition appropriate?
- **可靠性**: Are edge cases handled? Any fragile code paths? Is error handling adequate at system boundaries?
- **高效性**: Any unnecessary complexity? Redundant code? Over-abstraction for single-use patterns?

### security
- **合理性**: Was the threat surface correctly identified? Any attack vectors missed? Were severity ratings appropriate?
- **可靠性**: Are the fixes actually effective? Any false sense of security from incomplete patches?
- **高效性**: Any false positives that wasted effort? Was the scan scope well-targeted?

### cleanup
- **合理性**: Were the right targets identified for cleanup? Anything cleaned up that shouldn't have been, or missed that should have been?
- **可靠性**: Did cleanup preserve all existing behavior? Any subtle breakages from structural changes?
- **高效性**: Was the effort proportionate to the improvement gained?

### review
- **合理性**: Was every requirement checked individually? Any items rubber-stamped without real verification?
- **可靠性**: Are the "implemented" verdicts actually correct? Spot-check at least 2 items by reading the cited code locations.
- **高效性**: N/A (review has no efficiency concern — thoroughness is the priority)

### verify
- **合理性**: Do tests cover the core paths and critical edge cases? Any important scenarios untested?
- **可靠性**: Are tests actually testing behavior, not just asserting trivially true conditions? Do they run deterministically?
- **高效性**: Any redundant tests covering the same path? Is the test suite execution time reasonable?

## 5. Execution Flow

### 5.1 Gather Evidence
1. Read the scenario document (user stories, acceptance criteria, implementation approach)
2. Read `requirements/architecture.md`
3. Read all source code files produced for this scenario
4. Read test files
5. Review git log for this scenario's commits to understand what each stage actually did

### 5.2 Evaluate Each Stage
For each stage that was **actually executed** in this pipeline run (skip stages that were triaged out):
1. Apply the per-stage audit checklist (§4)
2. Rate each dimension: ✓ (pass), △ (minor issue, fixable), ✗ (significant issue)
3. For △ and ✗ items, write a specific finding with evidence

### 5.3 Fix Issues
For each △ or ✗ finding:
1. Fix the issue directly — edit the relevant artifact (doc, code, test, config)
2. Record what was changed in the fix log

**Do NOT route back to sub-skills.** Fix in place.

### 5.4 Re-evaluate
After fixing, re-run the evaluation (§5.2) on affected stages only.
- If all pass → proceed to output
- If still has issues → fix again (loop)
- **Loop protection**: maximum 3 rounds. If issues remain after 3 rounds, list them as unresolved in the report and escalate to user.

### 5.5 Output Report

```markdown
## 论证报告

### 轮次 {N}

| 阶段 | 合理性 | 可靠性 | 高效性 | 结论 | 备注 |
|------|--------|--------|--------|------|------|
| analyze | ✓ | ✓ | ✓ | 通过 | |
| tech | ✓ | △→✓ | ✓ | 已修复 | 原问题：... → 修复：... |
| code | ✓ | ✓ | ✓ | 通过 | |
| security | — | — | — | 未执行 | 本轮跳过 |
| cleanup | — | — | — | 未执行 | 本轮跳过 |
| review | ✓ | ✓ | — | 通过 | |
| verify | ✓ | ✓ | ✓ | 通过 | |

### 修复记录（如有）
1. **tech 可靠性**: {问题描述} → {修复措施} → {修复 commit 或文件位置}
2. ...

### 最终结论
全部通过 / 仍有 {N} 项待用户确认
```

### 5.6 Commit (only if fixes were made)

```bash
git add -A && git commit -m "docs({domain}): justify — {scenario}"
```

## 6. Stage Result

Output the following block as the final output of this stage:

```
## Stage Result
- **status**: all_justified | has_issues
- **rounds**: {N}
- **fixed**: {N} items fixed
- **summary**: {one-line summary}
```
