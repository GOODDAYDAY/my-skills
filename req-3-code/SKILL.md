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
- **Proactive common code extraction (mandatory)**: during coding, you must actively identify and extract shared logic — do NOT wait for the cleanup stage. Rules:
  - **2-occurrence rule**: if the same logic appears (or is about to appear) in 2+ places, immediately extract it into a shared utility
  - **Where to place**: `utils/`, `common/`, `shared/`, or the language-idiomatic equivalent (Java: `{domain}-common` module; Python: `utils/` or `common/` package)
  - **What qualifies**: data format conversion, validation patterns, string/date manipulation, logging helpers, retry/backoff wrappers, config parsing, common business calculations
  - **Naming**: utility functions/classes must have clear, descriptive names — `DateRangeValidator`, `format_currency()`, not `Helper1` or `do_stuff()`
  - **Interface over implementation**: shared code should expose a clean function/method signature; callers should not need to know internal details
  - **Do NOT over-abstract**: only extract when there is actual duplication or near-certain reuse. One-time logic stays inline
- **Logging**: key operations, exception branches, external calls must have log output; log messages in English
- **Comments**: complex logic, business rules, non-obvious code must have comments explaining intent
- **Code language**: variable names, function names, comments, log messages, commit messages must all be in English
- **Chinese only for**: user-facing UI text (if needed)

### Methods as Documentation (Mandatory)

This is the **core coding philosophy** — it applies to every language, every layer, every module.

#### Principle

A public method should read like a business flowchart. Its body contains only a sequence of clearly-named private method calls — no inline procedural logic (no if/try/for blocks in the public method body). Each private method does exactly one thing, and its name describes that thing. **Reading the public method tells you *what* happens; clicking into a private method tells you *how*.**

#### Rules

1. **Public methods only orchestrate** — the body is a sequence of private/helper method calls and simple variable passing. No procedural logic (conditionals, loops, try-catch, long expressions) in the public method body
2. **Numbered step comments in public methods** — every line in the public method body must have a numbered comment (`// 1. ...`, `// 2. ...`) describing the business step. The public method is a numbered flowchart, not just code
3. **Private methods are atomic steps** — each does one thing; the method name is the documentation
4. **Sufficient logging in private methods** — every private method must log at entry or key outcome. Use `info` for key milestones, `debug` for intermediate values. The goal: by reading logs alone, you can reconstruct the full business flow without looking at code
5. **Recursive layering** — this pattern applies at every level: service calls service, each one's public method is a "table of contents", private methods are "chapters". Drill down layer by layer, each level is self-explanatory
6. **When in doubt, extract** — if a block of code needs a comment to explain what it does, extract it into a private method whose name replaces the comment

#### Naming Convention for Private Methods

| Verb Prefix | Semantics | Example |
|:---|:---|:---|
| `validate` / `check` | Validate; raise/throw on failure | `validate_email_uniqueness(email)` |
| `enrich` / `fill` | Populate defaults or derived fields | `enrich_with_defaults(data)` |
| `persist` / `save` | Write to storage | `persist_to_database(data)` |
| `notify` / `send` | Send notification or event | `notify_downstream(record_id)` |
| `build` / `assemble` | Construct return object | `build_result(record_id, data)` |
| `query` / `find` / `fetch` | Retrieve data | `find_existing_user(email)` |
| `transform` / `convert` | Convert data format | `transform_to_internal_format(raw)` |

#### Anti-Pattern

```
# ✗ Wrong: all logic flattened in the public method
def do_action(self, data):
    if not data.email:
        raise ValueError("missing email")
    existing = self.repo.find_by_email(data.email)
    if existing:
        raise ValueError("duplicate")
    data.created_at = datetime.now()
    record_id = self.repo.save(data)
    self.event_bus.publish("created", record_id)
    return {"id": record_id, "email": data.email}

# ✓ Correct: public method is a numbered flowchart
def do_action(self, data):
    # 1. Validate email format and presence
    self._validate_email(data.email)
    # 2. Check for duplicate records
    self._ensure_no_duplicate(data.email)
    # 3. Fill in default values and derived fields
    enriched = self._enrich_with_defaults(data)
    # 4. Persist to database
    record_id = self._persist_to_database(enriched)
    # 5. Publish creation event to downstream
    self._notify_created(record_id)
    # 6. Build and return result
    return self._build_result(record_id, enriched)
```

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
