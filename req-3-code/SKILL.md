---
name: req-3-code
description: Coding — develop following requirement and technical documents
argument-hint: "[REQ-xxx]"
---

You are responsible for the coding stage. Develop strictly following the requirement and technical documents.

## Prerequisites

- `$ARGUMENTS` provides a REQ number
- The corresponding `requirement.md` and `technical.md` must exist and be finalized
- If not met, prompt the user to complete prerequisite stages first

## Breakpoint Recovery

Read `${CLAUDE_SKILL_DIR}/../_shared/recovery.md` for recovery specifications.

When entering the coding stage, check current code status:

1. Read the module list from `technical.md`
2. Check whether code files exist for each module
3. If some modules already have code:
   - List completed and pending modules
   - Inform user: "Detected the following modules are completed [list]. Resuming from [Module X]."
   - Continue from pending modules, do not rewrite existing code

## Flow

### Step 1: Read Documents

1. Read `requirements/REQ-xxx-*/requirement.md` — understand what to build
2. Read `requirements/REQ-xxx-*/technical.md` — understand how to build it

### Step 2: Load Language Conventions

Based on the technology stack in `technical.md`, check `${CLAUDE_SKILL_DIR}/` for the corresponding language convention file:

- Python → read `${CLAUDE_SKILL_DIR}/python.md`
- Java → read `${CLAUDE_SKILL_DIR}/java.md`
- Others → load matching `.md` if exists, otherwise use general best practices

### Step 3: Code

Develop module by module following the technical document's module breakdown:

1. Set up project structure first (if new project)
2. **Project structure rule**: source code must NOT be placed directly under project root `src/`. Must be organized in sub-layer directories like `backend/`, `frontend/`, `app/`, `shared/`, etc. `src/` may only appear inside sub-layers
3. Implement features in module order
4. Briefly inform user of progress after completing each module
5. Key logic in code must correspond to requirement/technical documents

### Code Quality Requirements

- **High cohesion, low coupling**: single responsibility per module, communicate via clear interfaces, avoid tight coupling
- **Reuse**: extract shared logic into independent modules, avoid code duplication
- **Logging**: key operations, exception branches, external calls must have log output; log messages in English
- **Comments**: complex logic, business rules, non-obvious code must have comments explaining intent
- **Code language**: variable names, function names, comments, log messages, commit messages must all be in English
- **Chinese only for**: user-facing UI text (if needed)

### Step 4: Generate Automation Scripts

Read `${CLAUDE_SKILL_DIR}/../_shared/scripts.md` for script specifications.

Generate automation scripts in `scripts/` (.bat + .sh), strictly following the shared script specifications.

At minimum:
- `scripts/build.bat` + `scripts/build.sh` — build/compile
- `scripts/run.bat` + `scripts/run.sh` — start/run
- `scripts/test.bat` + `scripts/test.sh` — run tests
- Additional as needed

### Step 5: Update Status

Read `${CLAUDE_SKILL_DIR}/../_shared/status.md` for status specifications, update `requirements/index.md` status to `Development Done`.
