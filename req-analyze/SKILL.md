---
name: req-analyze
description: Requirement analysis — create or update domain scenario documents
argument-hint: "[description | domain/scenario]"
---

# req-analyze — Requirement Analysis
> Version: v4 | Date: 2026-04-27 | Author: system

## 1. Role
You are responsible for the requirement analysis stage — expand a brief user description into complete domain scenario documents.

## 2. Overall Flow

1. Understand what the user wants
2. Triage: fast or deep analysis
3. Analyze and draft requirements
4. User review loop
5. Write/update domain scenario docs
6. Generate diagrams (if needed)
7. Update index.md
8. Commit

## 3. Steps

### 3.1 Understand Requirements

If `$ARGUMENTS` is empty or unclear, **proactively guide the user**:
- "What feature do you want to build?"
- "What problem does it solve?"
- "Who are the target users?"
- "Any reference products or interfaces?"
- "Do you have any mockups, screenshots, or UI references? Drag them into the chat."

If the user provides images or screenshots, extract requirements directly from them — visual references take priority over text descriptions.

### 3.2 Triage — Fast or Deep?

Announce the decision to the user (e.g. "方向明确，走快车道" or "多种可能方向，展开分析").

**Fast path — any of these conditions**:
- User has stated a clear direction
- Task is refactoring / cleanup / deletion
- Scope is closed and enumerable

**Deep path — any of these conditions**:
- Multiple fundamentally different implementation directions exist
- User explicitly says they are uncertain or exploring
- New feature design involving architectural choices
- Cross-cutting concerns affecting multiple subsystems

### 3.3 Direct Analysis (fast path)

The main agent directly drafts:
1. Functional requirements with main flow, error handling, edge cases
2. Non-functional requirements
3. Out-of-scope items
4. Acceptance criteria

Present the draft and proceed to §3.6 User Review.

### 3.4 Diverge Analysis (deep path)

Read `${CLAUDE_SKILL_DIR}/../_shared/diverge-converge.md` for the full pattern specification.

Launch two rounds of subagent analysis via the `Agent` tool:

**Round 1 (parallel)**: Agent A (core MVP) + Agent B (full scope)
**Round 2 (sequential)**: Agent C (core conflict analysis)

### 3.5 Converge (deep path)

Present in the diverge-converge Synthesis format:
1. **Recommended direction**
2. **Core conflict**
3. **Comparison table** (optional)

**Wait for user selection**.

### 3.6 User Review
- User may modify, add, or remove items
- Adjust and re-present
- Loop until user approves

### 3.7 Determine Domain and Scenario

After user approval:

1. **Identify domain**: Read `requirements/index.md` Domains section.
   - If a matching domain exists → use it
   - If no match → propose a new domain name (short English, lowercase with hyphens)
   - Ask user to confirm domain assignment

2. **Identify scenario**: Read the domain's README.md (if exists).
   - If this is a simple scenario → will be documented inline in README.md
   - If complex (multiple sub-flows, many requirements) → create a separate `{scenario}.md` file
   - Decision rule: if the scenario has more than 3 functional requirements or is expected to grow, use a separate file

3. **Create domain directory** (if new): `requirements/{domain}/`

### 3.8 Write Domain Documents

**If new domain**: Create `requirements/{domain}/README.md` using the template from `_shared/status.md` §4.

**If existing domain**: Update the README.md Scenarios table to include the new scenario.

**Write scenario content** (inline in README.md or separate file).

Read `${CLAUDE_SKILL_DIR}/../_shared/status.md` §4–§5 Writing Principles and Standalone File Format before writing. Key rule: **write user stories from an actor's perspective, not technical specs**.

**Standalone scenario files must include YAML frontmatter** (see `_shared/status.md` §5.1):

```yaml
---
name: {Scenario Name}
description: {One-line summary of what this scenario covers, max 120 chars}
---
```

Place this before the H1 heading. The `name` must match the H1 text. The `description` should summarize the concern areas covered, not repeat the domain description.

```markdown
---
name: {Scenario Name}
description: {One-line summary, max 120 chars}
---
# {Scenario Name}

# {Concern Area}

## US-01: As a {actor}, {situation/need}, so that {value}

{1-2 sentences: what this means and why it matters — pure business language.
Do NOT describe internal function names, constants, or data structures.}

### Acceptance Criteria
- Given {context}, when {action}, then {observable outcome}
- Given ...

## US-02: As a {actor}, {another need}, so that {value}

...
```

**Actor guidance** — choose the actor whose concern the story addresses:
- **cycle** — a single iteration of the agent's work loop
- **agent** — the overall autonomous entity across cycles
- **evaluator** — the quality assessment system
- **operator** — the human who deploys and monitors
- **tool** — an individual capability the agent can invoke
- **CI pipeline** — the automated deployment system

**Writing guidance:**
- One user story = one concern (fine-grained, not one story covering 5 things)
- Group user stories by concern area within each file (use H1 headers)
- Each story must include "so that" rationale — this is what code cannot tell you
- Acceptance criteria must be testable behaviors in Given/When/Then format
- Each story should survive a refactor — if renaming a function invalidates it, rewrite it
- NO function names, class names, variable names, or constant values
- Section headings must be in English. No Change Log section — rely on git history.

### 3.9 PlantUML Diagrams

Read `${CLAUDE_SKILL_DIR}/../_shared/plantuml.md` for the full specification.
- At least one use case diagram for new domains
- Flowcharts for complex flows
- Sequence diagrams for multi-actor interactions
- Place diagrams in the domain directory

### 3.10 Update index.md

Read `${CLAUDE_SKILL_DIR}/../_shared/status.md` for the index.md format.

1. If the domain is new: add a row to the Domains table
2. If `index.md` does not exist, create it per the template in `_shared/status.md`

### 3.11 Commit

```bash
git add -A && git commit -m "docs({domain}): requirement analysis — {scenario}"
```

Output the following block as the final output of this stage:

```
## Stage Result
- **status**: completed
- **domain**: {domain name}
- **scenario**: {scenario name}
- **user_stories**: US-01, US-02, ... (list all story IDs created/updated)
```
