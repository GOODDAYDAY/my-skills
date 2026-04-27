# Domain Snapshot Status Reference
> Version: v3 | Date: 2026-04-27 | Author: system

## 1. Scenario Statuses

Each scenario in a domain has one of these statuses:

| Status | Meaning |
|:---|:---|
| `Planned` | Documented but not yet coded |
| `Implemented` | Coded and verified |

## 2. Pipeline Stage Statuses

Used in `index.md` Work In Progress section to track ongoing work:

| Stage | Entry Status | Completion Status |
|:---|:---|:---|
| analyze | (new) | Requirement Drafted |
| tech | Requirement Drafted | Design Decided |
| code | Design Decided | Development Done |
| security | Development Done | Security Reviewed |
| cleanup | Security Reviewed | Code Cleaned |
| review | Code Cleaned | Reviewed |
| verify | Reviewed | Verified |
| done | Verified | (removed from WIP) |

## 3. index.md Format

### 3.1 Language Requirement

`index.md` **must be written entirely in English**, including domain names and descriptions.

### 3.2 Template

```markdown
# Requirements Index

## Work In Progress

| Domain | Scenario | Stage | Updated |
|:---|:---|:---|:---|

## Domains

| Domain | Path | Description |
|:---|:---|:---|
```

- **Work In Progress** tracks active pipeline work. Each row is one scenario being worked on.
- **Domains** lists all requirement domain directories. Add when a new domain is created; remove when archived.
- When a scenario completes the pipeline (`done` stage), remove its WIP row and update the scenario status to `Implemented` in the domain README.

### 3.3 Updating index.md

- **Adding WIP**: Insert a row with domain, scenario name, current stage, and today's date.
- **Advancing stage**: Update Stage and Updated columns for the target WIP row. Do not touch other rows.
- **Completing work**: Remove the WIP row. Update the scenario status in the domain README.
- **Adding a domain**: Insert a row in the Domains table.

## 4. Writing Principles

Requirements are written as **user stories** from the perspective of system actors. Each story describes **who** needs something, **what** they need, and **why** it matters.

**Format:**
```
## US-XX: As a {actor}, {situation/need}, so that {value}

{1-2 sentences elaborating what and why — pure business language}

### Acceptance Criteria
- Given {context}, when {action}, then {outcome}
```

**Actors** (choose the one whose concern the story addresses):
- **cycle** — a single iteration of the agent's work loop
- **agent** — the overall autonomous entity across cycles
- **evaluator** — the quality assessment system
- **operator** — the human who deploys and monitors
- **tool** — an individual capability the agent can invoke
- **CI pipeline** — the automated deployment system

**DO:**
- Write from the actor's perspective — "As a cycle, I need X so that Y"
- One story = one concern (fine-grained, not a story covering 5 things)
- Include "so that" rationale in every story — this is what code cannot tell you
- Write acceptance criteria as observable behaviors: "Given X, when Y, then Z"
- Group stories by concern area within each file

**DON'T:**
- Include function names, class names, variable names, or constant values
- Write stories that are just code comments in user story form
- Use acceptance criteria like "function X exists" or "field Y has default Z"
- Combine multiple unrelated concerns into a single story

**Test:** If a user story becomes false when you rename a function without changing behavior, it's a technical spec, not a user story. Rewrite it.

## 5. Domain README Format

```markdown
# {Domain Name}

> {One-line description}

## Scenarios

| Scenario | Location | Status |
|:---|:---|:---|
| Feature A | inline | Implemented |
| Feature B | feature-b.md | Planned |

# {Concern Area}

## US-01: As a {actor}, {situation/need}, so that {value}

{1-2 sentences: what this means and why it matters.}

### Acceptance Criteria
- Given {context}, when {action}, then {outcome}
- Given ...

## US-02: As a {actor}, {another need}, so that {value}

...
```

## 6. Standalone Scenario File Format

```markdown
# {Scenario Name}

# {Concern Area 1}

## US-01: As a {actor}, {situation/need}, so that {value}

{Description}

### Acceptance Criteria
- Given {context}, when {action}, then {outcome}

# {Concern Area 2}

## US-02: ...
```

## 6. architecture.md Format

```markdown
# Technical Architecture

## Philosophy

## Architecture Overview

## Key Decisions

| Date | Decision | Rationale | How to Extend |
|:---|:---|:---|:---|

## Extension Guide
```
