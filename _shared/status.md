# Domain Snapshot Status Reference
> Version: v5 | Date: 2026-05-04 | Author: system

## 1. Scenario Statuses

Each scenario in a domain has one of these statuses:

| Status | Meaning |
|:---|:---|
| `Planned` | Documented but not yet coded |
| `Implemented` | Coded and verified |

## 2. index.md Format

### 2.1 Language Requirement

`index.md` **must be written entirely in English**, including domain names and descriptions.

### 2.2 Template

```markdown
# Requirements Index

## Domains

| Domain | Path | Description |
|:---|:---|:---|
```

- **Domains** lists all requirement domain directories. Add when a new domain is created.

### 2.3 Updating index.md

- **Adding a domain**: Insert a row in the Domains table.
- **Removing a domain**: Remove the row when the domain is no longer relevant.

## 3. Writing Principles

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

## 4. Domain README Format

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

## 5. Standalone Scenario File Format

### 5.1 Frontmatter

Every standalone scenario `.md` file must start with YAML frontmatter:

```yaml
---
name: Agent Git Operations
description: Auto-commit, multi-repo, commit messages, staging, push, tagging, and squash
---
```

- **name**: scenario title (must match the H1 heading that follows)
- **description**: one-line summary of what this scenario covers (max 120 chars)

Domain `README.md` files do not need frontmatter — their description lives in `index.md`'s Domains table.

### 5.2 Body

```markdown
---
name: {Scenario Name}
description: {One-line summary, max 120 chars}
---
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

## Core Patterns

### {Pattern Name}
- **Structure**: What components exist and how they relate
- **Contract**: The interface/protocol that participants must follow
- **State flow**: How data moves through the pattern
- **Extension**: How to add new participants without modifying existing ones
- **Invariants**: Rules that must always hold

## Interface Contracts

### {Integration Name}
- **Producer**: `module.function()` → return type
- **Consumer**: `module.function(input)` — how it uses the produced data
- **Wiring**: Where/how producer output reaches consumer input
- **Contract**: What the producer guarantees and what the consumer assumes
- **Verified by**: Which test or scenario covers this contract

## Key Decisions

| Date | Decision | Rationale | How to Extend |
|:---|:---|:---|:---|

## Extension Guide

## Glossary

| Term | Definition | Location |
|:---|:---|:---|
```

**Section purposes:**
- **Philosophy**: Fundamental principles that guide all design choices
- **Architecture Overview**: High-level system structure (prose)
- **Core Patterns**: Reusable architectural patterns — enough detail to reimplement from scratch
- **Interface Contracts**: Cross-module integration points — producer/consumer/wiring for each
- **Key Decisions**: ADR-style rows for significant choices (date, what, why, how to extend)
- **Extension Guide**: Step-by-step recipes for common extension tasks
- **Glossary**: Term definitions grouped by subsystem

## 7. CATALOG.md Format

`requirements/CATALOG.md` is an auto-generated rich index — the project's "abstract memory" in a single file. Generated by `/req-catalog` or automatically after each `/req` pipeline run.

### 7.1 Structure

```markdown
# Requirements Catalog
Generated: {YYYY-MM-DD} | {N} domains, {M} documents

---

## Technical Architecture

{Full content of architecture.md, verbatim}

---

## Domains

### {domain_name}
{domain_description from index.md Domains table}

| Document | Description |
|:---|:---|
| {filename} | {description} |

### {next_domain}
...

---
Read any document: read_file("requirements/{domain}/{file}")
Full architecture: read_file("requirements/architecture.md")
```

### 7.2 Description extraction priority

For each scenario `.md` file's description:

1. **YAML frontmatter** `description` field (preferred)
2. **First non-empty paragraph** after the H1 heading, before `---` or next heading (fallback)
3. **H1 heading text** itself (last resort)

### 7.3 Inline domains

For domains with no standalone `.md` files (all content in README.md), replace the document table with:

```markdown
(All content inline in README.md)
```

### 7.4 Do not edit manually

This file is overwritten by automation. Manual edits will be lost.
