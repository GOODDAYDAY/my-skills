---
name: req-code
description: Coding — develop following domain scenario documents and architecture.md
argument-hint: "[domain/scenario]"
---

# req-code: Coding Stage
> Version: v3 | Date: 2026-04-27 | Author: system

## 1. Role & Scope
You are responsible for the coding stage. Develop strictly following the domain scenario documents and architecture.md.

## 2. Prerequisites

- `$ARGUMENTS` provides domain/scenario identifier
- The scenario document must exist with requirements drafted and implementation approach decided
- `requirements/architecture.md` should exist (read for architectural guidance)
- If prerequisites not met, prompt the user to complete prior stages

## 3. Breakpoint Recovery

Read `${CLAUDE_SKILL_DIR}/../_shared/recovery.md` for recovery specifications.
When entering the coding stage:
1. Read the scenario's Implementation Approach for the module/component list
2. Check whether code files exist for each module
3. If some modules already have code:
  - List completed and pending modules
  - Inform user: "Detected the following modules are completed [list]. Resuming from [Module X]."
  - Continue from pending modules, do not rewrite existing code

## 4. Flow

### 4.1 Step 1: Read Documents
1. Read the domain scenario document — understand what to build
2. Read `requirements/architecture.md` — understand architectural principles and patterns
3. Read the scenario's Implementation Approach section — understand how to build it

### 4.2 Step 2: Load Language Conventions
Based on the technology stack, check `${CLAUDE_SKILL_DIR}/` for the corresponding language convention file:
- Python → read `${CLAUDE_SKILL_DIR}/python.md`
- Java → read `${CLAUDE_SKILL_DIR}/java.md`
- Others → load matching `.md` if exists, otherwise use general best practices

### 4.3 Step 2.5: Write Acceptance Tests First
Before coding any module, generate tests based on the acceptance criteria in the scenario document:
1. For each acceptance criterion, write a failing test that directly verifies it
2. Place tests in `tests/` mirroring the source structure
3. Name tests to map clearly to requirement IDs (e.g., `test_F01_user_can_login`)

### 4.4 Step 3: Code
Develop module by module following the Implementation Approach's module breakdown.

**Before implementing: analyze module dependencies.**
- Identify modules with no inter-dependencies
- If 2+ independent modules exist, implement them using parallel sub-agents
- Modules with dependencies must remain sequential

1. Set up project structure first (if new project)
2. **Project structure rule**: source code must NOT be placed directly under project root `src/`. Must be organized in sub-layer directories like `backend/`, `frontend/`, `app/`, `shared/`, etc.
3. Implement features in module order
4. Briefly inform user of progress after completing each module
5. After completing each module, run these checks **in order** before committing:

  **6a. Requirement alignment check** — open scenario document and ask:
  - Which requirements and acceptance criteria does this module cover?
  - Does the implementation fully satisfy them? (main flow, error handling, edge cases)
  - If any gap → fix it now

  **6b. Inline code review** — extract shared logic, rename vague identifiers, remove dead branches

  **6c. Superseded component cleanup** — check the scenario's Implementation Approach Superseded Components:
  - `Remove`: delete the superseded code. Verify no other callers remain.
  - `Mark`: add a comment: `# LEGACY: superseded by <new component>, scheduled for removal`
  - Include cleanup in the **same commit** as the module

  Then commit:
  ```bash
  git add -A && git commit -m "feat({domain}): implement {module} (covers F-xx, F-xx)"
  ```

### 4.5 Step 4: Generate Automation Scripts
Read `${CLAUDE_SKILL_DIR}/../_shared/scripts.md` for script specifications.
Generate automation scripts in `scripts/` (.bat + .sh):
- `scripts/build.bat` + `scripts/build.sh`
- `scripts/run.bat` + `scripts/run.sh`
- `scripts/test.bat` + `scripts/test.sh`

### 4.6 Step 5: Commit
```bash
git add -A && git commit -m "feat({domain}): {scenario} implementation complete" --allow-empty
```

## 5. Code Quality Requirements

### 5.1 Cohesion & Coupling
- **High cohesion, low coupling**: single responsibility per module, communicate via clear interfaces

### 5.2 Proactive Common Code Extraction (Mandatory)
- **2-occurrence rule**: if the same logic appears in 2+ places, immediately extract into a shared utility
- **Where to place**: `utils/`, `common/`, `shared/`, or language-idiomatic equivalent
- **Naming**: clear, descriptive names — `DateRangeValidator`, `format_currency()`, not `Helper1`
- **Do NOT over-abstract**: only extract when there is actual duplication or near-certain reuse

### 5.3 Code Language
- Variable names, function names, comments, log messages, commit messages in English
- **Chinese only for**: user-facing UI text (if needed)

## 6. Logging Requirements

Every piece of code must have sufficient logging. Goal: **by reading logs alone, reconstruct the full business flow.**

### 6.1 Log Level Standards

| Level | When to Use | Example |
|:---|:---|:---|
| `info` | Key business milestones: flow start/end, data persisted | `"Order created, id=123"` |
| `debug` | Intermediate values, branch decisions | `"Enriching defaults, currency=USD"` |
| `warn` | Expected failures: validation failed, retry | `"Duplicate order detected"` |
| `error` | Unexpected failures: database error, service unavailable | `"Failed to connect to payment service"` |

### 6.2 Where to Log (Mandatory)
1. **Every private method** — log at entry or key outcome
2. **External calls** — log before and after
3. **Exception branches** — every catch block logs what and why
4. **Business decisions** — log which branch was taken
5. **Data transformations** — log input/output summaries

### 6.3 Log Content Rules
- Always include identifiers (user ID, order ID, request ID)
- Never log secrets
- Use lazy formatting
- Truncate large values
- English only

## 7. Comment & Documentation Requirements

### 7.1 File/Module Comment (Mandatory)
Every source file: **What** + **Why** in one-two sentences.

### 7.2 Class Comment (Mandatory)
Every class: responsibility + key collaborators.

### 7.3 Method Comment Rules
- Public methods: always
- Private methods: only if non-obvious
- Interface/abstract methods: always

### 7.4 Inline Comment Rules
- Do NOT comment obvious code
- DO comment business rules, non-obvious decisions, workarounds

## 8. Methods as Documentation (Mandatory)

### 8.1 Principle
A public method reads like a business flowchart. Body contains only clearly-named private method calls — no inline procedural logic.

### 8.2 Rules
1. **Public methods only orchestrate** — sequence of private method calls, no procedural logic
2. **Numbered step comments** — `// 1. ...`, `// 2. ...`
3. **Private methods are atomic steps** — one thing each, name is documentation
4. **Sufficient logging in private methods**
5. **Recursive layering** — pattern applies at every level
6. **When in doubt, extract**

### 8.3 Naming Convention for Private Methods

| Verb Prefix | Semantics | Example |
|:---|:---|:---|
| `validate` / `check` | Validate; raise on failure | `validate_email_uniqueness(email)` |
| `enrich` / `fill` | Populate defaults | `enrich_with_defaults(data)` |
| `persist` / `save` | Write to storage | `persist_to_database(data)` |
| `notify` / `send` | Send notification | `notify_downstream(record_id)` |
| `build` / `assemble` | Construct return object | `build_result(record_id, data)` |
| `query` / `find` / `fetch` | Retrieve data | `find_existing_user(email)` |
| `transform` / `convert` | Convert format | `transform_to_internal_format(raw)` |

### 8.4 Anti-Pattern vs Correct Pattern

```python
# Wrong: all logic flattened in the public method
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

# Correct: public method is a numbered flowchart
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

Output the following block as the final output of this stage:

```
## Stage Result
- **status**: completed
- **domain**: {domain name}
- **scenario**: {scenario name}
- **modules_implemented**: {comma-separated list of module names}
- **tests_written**: {N} test files
```
