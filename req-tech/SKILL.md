---
name: req-tech
description: Technical design — think through architecture, update architecture.md and scenario docs
argument-hint: "[domain/scenario]"
---

# req-tech — Technical Design
> Version: v5 | Date: 2026-04-27 | Author: system

## 1. Role
You are responsible for the technical design stage — think through how to implement the scenario, update the scenario's Implementation Approach section, and maintain the project's architecture.md for structural decisions.

**Key change**: This stage no longer produces a per-requirement `technical.md`. Instead:
- Implementation details go into the scenario document's `Implementation Approach` section
- Structural/architectural decisions go into `requirements/architecture.md`

## 2. Overall Flow

1. Read scenario document + architecture.md
2. Triage: fast or deep
3. Think through technical approach
4. Update scenario's Implementation Approach section
5. Update architecture.md (if structural decisions made)
6. Generate diagrams (if needed)
7. User review
8. Commit

## 3. Prerequisites

- `$ARGUMENTS` provides domain/scenario identifier
- The scenario document must exist (in domain README.md inline or as separate file)
- The scenario document must exist with requirements drafted

### 3.1 Breakpoint Recovery
Read `${CLAUDE_SKILL_DIR}/../_shared/recovery.md` for recovery specifications.
If the scenario's `Implementation Approach` section already has content:
- Show it to the user
- Ask whether to continue refining or start over

## 4. Steps

### 4.1 Read Documents
- Read the scenario document (requirements, acceptance criteria)
- Read `requirements/architecture.md` (if exists) for existing architectural context
- Scan the codebase to understand current structure

### 4.2 Triage — Fast or Deep?

Announce the decision to the user.

**Fast path — any of these conditions**:
- Scenario already specifies the direction (e.g. "delete X, callers use Y")
- Changes are mechanical: interface adjustment, parameter changes, wiring
- Module boundaries are clear, no new architecture decisions needed

**Deep path — any of these conditions**:
- New module design or technology stack selection required
- Multiple fundamentally different approaches exist
- Cross-cutting design affecting multiple subsystems

### 4.3 Direct Design (fast path)

Draft the implementation approach:
1. List files/modules to modify with specific changes
2. Define data model / API changes if applicable
3. Identify superseded components
4. Note risks

### 4.4 Diverge Design (deep path)

Read `${CLAUDE_SKILL_DIR}/../_shared/diverge-converge.md` for the pattern specification.

**Round 1 (parallel)**: Agent A (simple & direct, ≤3 modules) + Agent B (extensible, layered)
**Round 2 (sequential)**: Agent C (core conflict identification)

### 4.5 Converge (deep path)

Present synthesis in diverge-converge format. Wait for user selection.

Ask: **"Does this design replace any existing implementation?"** Capture superseded components.

### 4.6 Update Scenario Document

Write/update the `Implementation Approach` section of the scenario document:

```markdown
## Implementation Approach

### Technology Stack

| Module | Technology | Rationale |
|:---|:---|:---|

### Module Design

#### {Module 1}
- Responsibility:
- Files to modify:
- Public interface:

#### {Module 2}
...

### Key Flows

(describe or reference diagrams)

### Superseded Components

| Component | File Path | Superseded By | Cleanup Action |
|:---|:---|:---|:---|

If nothing is superseded, write **None**.

### Risks & Notes
```

This replaces the old per-requirement `technical.md`. Keep it focused — enough detail to guide coding, no more.

### 4.7 Update architecture.md

**Only update when structural decisions are made** — new patterns, refactoring rationale, extension conventions, cross-module integration.

If `requirements/architecture.md` does not exist, create it using the template from `_shared/status.md` §6.

Update the relevant sections:

- **Core Patterns** (update when a new architectural pattern is established or an existing one is extended):
  - One entry per reusable pattern (e.g. Cycle→Stage→Phase pipeline, Tool ABC, Skill discovery)
  - Each entry must include: Structure, Contract, State flow, Extension method, Invariants
  - Goal: someone reading only this section can reimplement the pattern from scratch
  - Do NOT describe single-use module internals — only patterns that multiple components participate in

- **Interface Contracts** (update when the scenario introduces or modifies cross-module integration):
  - One entry per producer→consumer boundary that spans different modules/files
  - Each entry must include: Producer (function + return type), Consumer (function + how it uses input), Wiring (where they connect), Contract (what is guaranteed), Verified by (which test)
  - Intra-module calls are NOT contracts — only cross-module boundaries
  - Goal: if Module A's scenario and Module B's scenario are implemented independently, their Interface Contract is the shared truth that keeps them compatible

- **Key Decisions**: Add a row for significant architectural choices
- **Extension Guide**: Update if new patterns are established. Each entry is a step-by-step recipe.
- **Glossary**: When a new module, component, or domain term is introduced, add a row (Term / Definition / Location). Keep definitions in business language, one line each. Group by subsystem.
- **Architecture Overview**: Update if the high-level structure changes
- **Philosophy**: Rarely changes — only when fundamental principles are established or revised

### 4.8 Generate Diagrams

Read `${CLAUDE_SKILL_DIR}/../_shared/plantuml.md` for the full specification.

Generate diagrams as needed (place in domain directory):
- Architecture diagram: `tech-architecture.puml`
- Sequence diagram: `tech-sequence.puml`
- Class/ER diagrams if applicable

Only generate diagrams that add value — a simple file rename doesn't need an architecture diagram.

### 4.9 Commit

```bash
git add -A && git commit -m "docs({domain}): technical design — {scenario}"
```

Output the following block as the final output of this stage:

```
## Stage Result
- **status**: completed
- **domain**: {domain name}
- **scenario**: {scenario name}
- **modules**: {N} modules defined
- **architecture_updated**: yes | no
```
