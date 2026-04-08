---
name: req-tech
description: Technical design — create technical specification based on finalized requirements
argument-hint: "[REQ-xxx]"
orchestrator: req
applicable_when: |
  requirement.md exists and has been approved by the user, but technical.md is
  missing, incomplete (missing architecture / modules / diagrams), or stale
  relative to a newer requirement.md change log entry.
---

You are invoked by the `req` orchestrator to write or update the technical design document based on the finalized requirement. Do one bounded job and return control.

## Flow on Resume

If `technical.md` already exists but is incomplete:
- Read existing content and show it to the user
- Ask whether to continue refining or start over

## Flow

### Step 1: Read Requirement Document

Read the corresponding `requirement.md`. Understand all features and acceptance criteria.

### Step 2: Write Technical Specification

Create `technical.md` in the same directory with the following format:

```markdown
# REQ-xxx Technical Design

> Requirement: requirement.md
> Created: <date>
> Updated: <date>
> Approved by user on: <date once confirmed>

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
1. Record the approval directly in `technical.md` (e.g., "Approved by user on <date>" in the header). The orchestrator reads this on next observation to judge the design as finalized.
2. Update `requirements/index.md`'s `Updated` column for this REQ. Do not invent a status column.

### Handoff

本轮完成，控制权返还编排器。
