---
name: req-6-verify
description: Verification — build check, runtime check, and automated testing
argument-hint: "[REQ-xxx]"
---

You are responsible for the verification stage. Ensure the code builds, runs, and passes tests.

## Prerequisites

- `$ARGUMENTS` provides a REQ number
- Coding must be completed

## Breakpoint Recovery

Read `${CLAUDE_SKILL_DIR}/../_shared/recovery.md` for recovery specifications.

If a previous verification was interrupted:
1. Check if scripts already exist under `scripts/`
2. Check if test files already exist
3. If they exist, run existing scripts to see which pass/fail
4. Only fix failing items, do not regenerate passing ones

## Flow

### Step 1: Identify Project Type

Read `requirements/REQ-xxx-*/technical.md` to determine the technology stack and build method.

### Step 2: Build Check

Execute build based on technology stack:

| Technology | Command |
|:---|:---|
| Python | `python -m py_compile <files>` or `mypy <package>` |
| Java (Maven) | `mvn compile` |
| Java (Gradle) | `gradle build` |
| TypeScript | `tsc --noEmit` |
| Go | `go build ./...` |

Build must pass. If errors occur, fix and retry.

### Step 3: Runtime Check

Attempt to run the project's entry point to ensure it starts correctly:
- CLI tool: execute `--help` or a simple command
- Web service: start and check health endpoint
- Library: attempt import/load

### Step 4: Automated Testing

1. Check if test files already exist
2. If not, **generate test cases based on the requirement document's acceptance criteria**
3. **Web project special requirement**: use Python + Playwright for end-to-end testing
   - Place test scripts in `tests/e2e/`
   - Design test flows based on requirement features and acceptance criteria
   - Test not only UI interactions (click, input, navigation)
   - Also test data flow (submit data, verify database/API response is correct)
   - Test file naming: `test_e2e_<feature>.py`
4. Unit/integration tests:

| Technology | Command |
|:---|:---|
| Python | `pytest tests/ -v` |
| Java (Maven) | `mvn test` |
| Java (Gradle) | `gradle test` |
| TypeScript | `npm test` |
| Go | `go test ./...` |

5. All tests must pass

### Step 5: Generate/Update Automation Scripts

Read `${CLAUDE_SKILL_DIR}/../_shared/scripts.md` for script specifications.

Generate verification scripts in `scripts/` (.bat + .sh), strictly following the shared script specifications.

At minimum:
- `scripts/build.bat` + `scripts/build.sh` — build/compile
- `scripts/test.bat` + `scripts/test.sh` — run all tests (unit + integration)
- `scripts/test-e2e.bat` + `scripts/test-e2e.sh` — run e2e tests (web projects)
- `scripts/run.bat` + `scripts/run.sh` — start/run

If scripts already exist, check if they need updating.

### Step 6: Output Report

```markdown
## Verification Report

- Build check: PASS / FAIL
- Runtime check: PASS / FAIL
- Unit/Integration tests: X/Y passed
- E2E tests: X/Y passed (web projects)

### Automation Scripts
- scripts/build.bat + build.sh ✓
- scripts/test.bat + test.sh ✓
- scripts/run.bat + run.sh ✓

### Issues (if any)
1. ...
```

When all checks pass, inform user they can proceed to the archive stage.
