---
name: req-verify
description: Verification — build check, runtime check, and automated testing
argument-hint: "[domain/scenario]"
---

# req-verify
> Version: v2 | Date: 2026-04-27 | Author: system

## 1. Overview
You are responsible for the verification stage — ensure the code can build, run, and pass tests.

## 2. Prerequisites

- `$ARGUMENTS` provides domain/scenario identifier
- Coding must be complete

## 3. Breakpoint Recovery

Read `${CLAUDE_SKILL_DIR}/../_shared/recovery.md` for recovery specifications.

If a previous verification was interrupted:
1. Check whether scripts already exist under `scripts/`
2. Check whether test files already exist
3. If they exist, run the existing scripts to see which pass/fail
4. Fix only the failing items — do not regenerate passing ones

## 4. Steps

### 4.1 Identify Project Type
Read the scenario's Implementation Approach or `requirements/architecture.md` to determine the technology stack.

### 4.2 Build Check

| Technology | Command |
|:---|:---|
| Python | `python -m py_compile <files>` or `mypy <package>` |
| Java (Maven) | `mvn compile` |
| Java (Gradle) | `gradle build` |
| TypeScript | `tsc --noEmit` |
| Go | `go build ./...` |

The build must pass. Fix errors and retry if any occur.

### 4.3 Runtime Check
Attempt to run the project entry point and confirm it starts correctly:
- CLI tools: execute `--help` or a simple command
- Web services: start up and check a health-check endpoint
- Libraries: attempt import/load

### 4.4 Automated Testing

1. Check whether test files already exist
2. If not, **generate test cases from the acceptance criteria in the scenario document**
3. **Web projects**: use Playwright for end-to-end tests, matching the project language:
  - TypeScript/Node.js → `tests/e2e/*.spec.ts`
  - Python → `tests/e2e/test_e2e_<feature>.py`
4. Unit/integration test commands:

| Technology | Command |
|:---|:---|
| Python | `pytest tests/ -v` |
| Java (Maven) | `mvn test` |
| Java (Gradle) | `gradle test` |
| TypeScript | `npm test` |
| Go | `go test ./...` |

5. All tests must pass

### 4.5 Generate / Update Automation Scripts
Read `${CLAUDE_SKILL_DIR}/../_shared/scripts.md` for script specifications.

At minimum:
- `scripts/build.bat` + `scripts/build.sh`
- `scripts/test.bat` + `scripts/test.sh`
- `scripts/test-e2e.bat` + `scripts/test-e2e.sh` (web projects)
- `scripts/run.bat` + `scripts/run.sh`

### 4.6 Output Report

```markdown
## Verification Report

- Build check: PASS / FAIL
- Runtime check: PASS / FAIL
- Unit/Integration tests: X/Y passed
- E2E tests: X/Y passed (web projects)

### Automation Scripts
- scripts/build.bat + build.sh
- scripts/test.bat + test.sh
- scripts/run.bat + run.sh

### Issues (if any)
1. ...
```

### 4.7 Commit

```bash
git add -A && git commit -m "test({domain}): verification — {scenario}"
```

Stage complete. Return to orchestrator.
