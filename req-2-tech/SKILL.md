---
name: req-2-tech
description: Technical design — create technical specification based on finalized requirements
argument-hint: "[REQ-xxx]"
---

You are responsible for the technical design stage. Write a technical specification based on the finalized requirement document.

## Prerequisites

- `$ARGUMENTS` provides a REQ number (e.g., REQ-001)
- The corresponding `requirements/REQ-xxx-*/requirement.md` must exist with status `Requirement Finalized`
- If not met, prompt the user to complete the requirement analysis stage first

## Breakpoint Recovery

Read `${CLAUDE_SKILL_DIR}/../_shared/recovery.md` for recovery specifications.

If `technical.md` already exists with status `Technical Design` (not finalized):
- Read existing content and show it to the user
- Ask whether to continue refining or start over

## Flow

### Step 1: Read Requirement Document

Read the corresponding `requirement.md`. Understand all features and acceptance criteria.

### Step 2: Write Technical Specification

Create `technical.md` in the same directory with the following format:

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

## 9. Risks & Notes

## 10. Change Log

| Version | Date | Changes | Affected Scope | Reason |
|:---|:---|:---|:---|:---|
| v1 | <date> | Initial version | ALL | - |
```

**Note: Section titles and structural fields must be in English. Descriptive content may use Chinese.**

Change log format and rules: see `${CLAUDE_SKILL_DIR}/../_shared/changelog.md`. The `Affected Scope` column must be filled accurately (e.g., Module 4.1, API 6.2).

### Step 3: Generate Diagrams

Read `${CLAUDE_SKILL_DIR}/../_shared/plantuml.md` for the complete PlantUML specification (env detection, syntax, SVG conversion). Follow the process strictly.

Generate the following diagrams as needed (at least 1-2):

- **Architecture diagram** (component): `tech-architecture.puml`
- **Sequence diagram**: `tech-sequence.puml` (key flows)
- **Class diagram**: `tech-class.puml` (data model / core classes)
- **ER diagram**: `tech-er.puml` (if database is involved)

### Step 4: User Review

Present the technical specification summary and **wait for user confirmation**:
- Focus on technology stack, architecture design, and module reuse strategy
- User may request adjustments
- Loop until user approves

### Step 5: Finalize

After user approval:
1. Update `technical.md` status to `Technical Finalized`
2. Read `${CLAUDE_SKILL_DIR}/../_shared/status.md` for status specifications, update `requirements/index.md` status to `Technical Finalized`
