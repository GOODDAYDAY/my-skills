---
name: req-tech
description: Technical design — create technical specification based on finalized requirements
argument-hint: "[REQ-xxx]"
---

# req-2-tech — Technical Design
> Version: v4 | Date: 2026-04-16 | Author: system

## 1. Role
You are responsible for the technical design stage — write a technical specification based on a finalized requirement document.

```mermaid
flowchart LR
    A[requirement.md\nFinalized] --> B{Triage}
    B -->|Fast| C[Direct design]
    B -->|Deep| D[Diverge-Converge]
    C --> E[Write technical.md]
    D --> E
    E --> F[Generate diagrams]
    F --> G[User review loop]
    G --> H[Status: Technical Finalized]
```
**Figure 1.1 — req-2-tech stage overview**

## 2. Overall Flow

```mermaid
flowchart TD
    A([Start]) --> B{Prerequisites\nmet?}
    B -->|No| C[Prompt user:\ncomplete req analysis first]
    B -->|Yes| D{technical.md\nalready exists?}
    D -->|Yes, incomplete| E[Show existing content\nAsk: continue or restart?]
    D -->|No| F[Read requirement.md]
    E --> F
    F --> T{Triage:\nfast or deep?}
    T -->|Fast| FA[Direct design:\nmain agent drafts technical spec]
    T -->|Deep| G[Diverge: A+B+C design]
    G --> H[Converge: present synthesis]
    H --> I{User\nselects direction?}
    I -->|Revise| G
    I -->|Selected| J[Write technical.md]
    FA --> J
    J --> K[Generate PlantUML Diagrams]
    K --> L[Present to User]
    L --> M{User\nApproved?}
    M -->|Revise| J
    M -->|Approved| N[Finalize technical.md]
    N --> O[Update index.md]
    O --> P[Commit]
    P --> E2([Done])
```
**Figure 2.1 — Technical design flow: read requirement → triage → design → finalize**

## 3. Prerequisites

```mermaid
flowchart LR
    A[$ARGUMENTS\nREQ-xxx] --> B{requirement.md\nexists and Finalized?}
    B -- No --> C[Prompt user:\ncomplete req-1-analyze first]
    B -- Yes --> D{technical.md\nalready exists?}
    D -- Yes incomplete --> E[Show content\nask continue or restart]
    D -- No --> F[Proceed to triage]
```
**Figure 3.1 — Prerequisites check flow**

### 3.1 Input Validation
- `$ARGUMENTS` provides a REQ number (e.g. REQ-001)
- The corresponding `requirements/REQ-xxx-*/requirement.md` must exist with status `Requirement Finalized`
- If not met, prompt the user to complete the requirement analysis stage first

### 3.2 Breakpoint Recovery
Read `${CLAUDE_SKILL_DIR}/../_shared/recovery.md` for recovery specifications.
If `technical.md` already exists with status `Technical Design` (not yet finalized):
- Read the existing content and present it to the user
- Ask whether to continue refining or start over

## 4. Steps

```mermaid
flowchart TD
    A[4.1 Read requirement.md] --> T[4.2 Triage]
    T -->|Fast| FA[4.3 Direct Design]
    T -->|Deep| B[4.4 Diverge Design]
    B --> C[4.5 Converge]
    FA --> D[4.6 Write technical.md]
    C --> D
    D --> E[4.7 Generate diagrams]
    E --> F[4.8 User review loop]
    F --> G[4.9 Finalize: status Technical Finalized]
    G --> H[4.10 Commit]
```
**Figure 4.1 — Technical design step sequence**

### 4.1 Read Requirement Document
Read the corresponding `requirement.md` and understand all features and acceptance criteria.

### 4.2 Triage — Fast or Deep?

Before launching any subagent, the main agent evaluates the requirement document and chooses a path. Announce the decision to the user (e.g. "需求方向明确，直接出技术方案" or "架构有多种选择，展开分析").

**Fast path — any of these conditions**:
- Requirement document already specifies the architectural direction (e.g. "delete class X, callers use Y directly")
- Changes are mechanical: interface adjustment, parameter changes, file deletion, wiring changes
- Module boundaries are clear, no new architecture decisions needed

**Deep path — any of these conditions**:
- New module design or technology stack selection required
- Requirement document leaves architectural openness (e.g. "choose approach A or B")
- Multiple fundamentally different technical implementations exist
- Cross-cutting design affecting multiple subsystems

**User override**: If the user requests deeper analysis (e.g. "展开分析", "我想看看不同技术方案"), switch to deep path regardless of triage result.

### 4.3 Direct Design (fast path)

The main agent directly drafts the technical specification:
1. Define technology stack and design principles
2. List module changes with specific file paths and line references
3. Define data model / API changes if applicable
4. List superseded components
5. Note risks

Present the draft and proceed to §4.6 Write technical.md.

### 4.4 Diverge Design (deep path)

Read `${CLAUDE_SKILL_DIR}/../_shared/diverge-converge.md` for the full pattern specification (role definitions, implementation constraints).

Launch two rounds of subagent analysis via the `Agent` tool:

**Round 1 (parallel)**: Launch Agent A and Agent B simultaneously:
- **Agent A (simple & direct)**: ≤ 3 modules, minimal dependencies, no extensibility concerns, just make it work
- **Agent B (extensible)**: layered/modular, designed for 10x scale, clean interfaces

**Round 2 (sequential)**: Launch Agent C, reading the full A+B output:
- **Agent C (core conflict)**: identify "at which key decision do the two architectures diverge (e.g. data coupling / deployment complexity / team skill match)", give a judgment — must name the conflict point concretely

### 4.5 Converge — Synthesize and User Selection (deep path)

The main agent consolidates the output and presents in the `diverge-converge.md` Synthesis format:

1. **Recommended direction** (conclusion first — A / B / blend, with reasoning)
2. **Core conflict** (the specific divergence identified by C)
3. **Comparison table** (optional — only when the two approaches differ significantly)

**Wait for user selection**: choose A / choose B / describe a blend. Once the user selects, use the chosen direction as the basis for writing `technical.md`.

Before writing, also ask: **"Does this design replace or supersede any existing implementation?"** If yes, capture those components in `§ 9. Superseded Components`. If the user is unsure, scan the codebase for similar functionality and present candidates.

### 4.6 Write Technical Specification
Invoke `write-doc` via the `Skill` tool, passing:
- Use the embedded template below as the document structure
- Fill in the selected technical design from the analysis/converge phase into each section
- Save path: `technical.md` in the same directory as `requirement.md`

Template:

```markdown
# REQ-xxx Technical Design

> Status: Technical Design
> Requirement: requirement.md
> Created: <date>
> Updated: <date>

## 1. Technology Stack

| Module | Technology | Rationale |
|:---|:---|:---|

## 2. Design Principles

- High cohesion, low coupling: single responsibility per module, communicate via clear interfaces
- Reuse first: extract shared logic into independent modules, avoid duplication
- Testability: key logic must be independently testable

## 3. Architecture Overview

(attach architecture diagram)

Note: source code must NOT be placed directly under project root `src/`. Must be organized in sub-layers:
- `backend/` — backend services
- `frontend/` — frontend application
- `app/` — mobile/desktop
- `shared/` — shared modules (for cross-module reuse)

## 4. Module Design

### 4.1 <Module 1>
- Responsibility:
- Public interface:
- Internal structure:
- Reuse notes: which components/logic can be reused by other modules

### 4.2 <Module 2>
...

## 5. Data Model

(attach ER diagram or class diagram if applicable)

## 6. API Design

(list API endpoints if applicable)

## 7. Key Flows

(attach sequence diagrams)

## 8. Shared Modules & Reuse Strategy

Explicitly list which components/utilities/logic are shared, and how they are referenced by each module.

## 9. Superseded Components

Components from prior REQs that this design replaces. Must be cleaned up as part
of this REQ's implementation — either removed or marked with a `# LEGACY(REQ-xxx):` comment.

| Component | File Path | Superseded By | Cleanup Action |
|:---|:---|:---|:---|
| <component name> | <path/to/file.py> | <new module or class> | Remove / Mark |

If nothing is superseded, write **None** in this section.

`Cleanup Action` values:
- **Remove** — delete the code outright during req-code (safe when the superseding path covers 100% of cases)
- **Mark** — add `# LEGACY(REQ-xxx): superseded by <new component>` comment now; schedule removal in a follow-up REQ

## 10. Risks & Notes

## 11. Change Log

| Version | Date | Changes | Affected Scope | Reason |
|:---|:---|:---|:---|:---|
| v1 | <date> | Initial version | ALL | - |
```

**Note: section headings and structural fields must be in English.**

See `${CLAUDE_SKILL_DIR}/../_shared/changelog.md` for change log format and rules. The `Affected Scope` column must be filled in accurately (e.g. Module 4.1, API 6.2).

### 4.7 Generate Diagrams

```mermaid
flowchart LR
    A[Read plantuml.md] --> B[Architecture Diagram\ntech-architecture.puml]
    B --> C[Sequence Diagram\ntech-sequence.puml]
    C --> D{Database\ninvolved?}
    D -->|Yes| E[ER Diagram\ntech-er.puml]
    D -->|No| F{Core classes\nneeded?}
    E --> G[Class Diagram\ntech-class.puml]
    F -->|Yes| G
    F -->|No| H[Convert to SVG]
    G --> H
    H --> I([Done])
```
**Figure 4.7 — PlantUML diagram generation decision tree**

Read `${CLAUDE_SKILL_DIR}/../_shared/plantuml.md` for the full PlantUML specification (environment detection, syntax, SVG conversion). Follow the process strictly.
Generate the following diagrams as needed (at least 1–2):
- **Architecture diagram** (component): `tech-architecture.puml`
- **Sequence diagram**: `tech-sequence.puml` (key flows)
- **Class diagram**: `tech-class.puml` (data model / core classes)
- **ER diagram**: `tech-er.puml` (if a database is involved)

### 4.8 User Review
Present a summary of the technical specification and **wait for user confirmation**:
- Focus on technology stack, architecture design, and module reuse strategy
- User may request adjustments
- Loop until the user approves

### 4.9 Finalize
After user approval:
1. Update the status in `technical.md` to `Technical Finalized`
2. Read `${CLAUDE_SKILL_DIR}/../_shared/status.md` for status specifications, update `requirements/index.md` status to `Technical Finalized`

### 4.10 Commit

```bash
git add -A && git commit -m "docs(REQ-xxx): technical design complete"
```

Stage complete. Invoke `/req REQ-xxx` to continue.
