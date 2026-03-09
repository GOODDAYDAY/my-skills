---
name: req-1-analyze
description: Requirement analysis — expand brief user input into a complete requirement document
argument-hint: "[brief description]"
---

You are responsible for the requirement analysis stage. Expand the user's brief description into a complete requirement document.

## Flow

### Step 1: Understand the Requirement

If `$ARGUMENTS` is empty or unclear, **proactively guide the user**:
- "What feature do you want to build?"
- "What problem does it solve?"
- "Who are the target users?"
- "Any reference products or interfaces?"

Keep asking until you have enough information to begin analysis.

If `$ARGUMENTS` already provides a description, proceed directly to expansion.

### Step 2: Expand Analysis

Expand the requirement **as comprehensively and in as much detail as possible**, and present the following for user review:

1. **Background** — Why build this, what pain point does it solve
2. **Target Users** — Who will use it, usage scenarios
3. **Functional Requirements** — List all features with numbered IDs, each detailed to specific behavior
   - Main flow
   - Error handling
   - Edge cases
4. **Non-functional Requirements** — Performance, security, compatibility, etc.
5. **Out of Scope** — What is explicitly excluded
6. **Acceptance Criteria** — Specific, verifiable conditions for each feature

Format: Use concise lists. Number features as F-01, F-02, etc. for traceability.

### Step 3: User Review

After presenting the expansion, **wait for user feedback**:
- User may modify, add, or remove items
- Adjust based on feedback and resubmit for review
- Loop until user explicitly says "looks good" or "approved"

### Step 4: Generate Requirement Document

After user approval:

1. Determine REQ number: read `requirements/index.md`, take the next number
2. Create directory: `requirements/REQ-xxx-<short-name>/` (directory name in English)
3. Write `requirement.md` in the following format:

```markdown
# REQ-xxx <Requirement Name>

> Status: Requirement Finalized
> Created: <date>
> Updated: <date>

## 1. Background

## 2. Target Users & Scenarios

## 3. Functional Requirements

### F-01 <Feature Name>
- Main flow:
- Error handling:
- Edge cases:

### F-02 <Feature Name>
...

## 4. Non-functional Requirements

## 5. Out of Scope

## 6. Acceptance Criteria

| ID | Feature | Condition | Expected Result |
|:---|:---|:---|:---|

## 7. Change Log

| Version | Date | Changes | Affected Scope | Reason |
|:---|:---|:---|:---|:---|
| v1 | <date> | Initial version | ALL | - |
```

**Note: Section titles and structural fields must be in English. Descriptive content may use Chinese.**

Change log format and rules: see `${CLAUDE_SKILL_DIR}/../_shared/changelog.md`. The `Affected Scope` column must be filled accurately.

4. Generate diagrams (per PlantUML conventions):
   - At least one use case diagram
   - Flowchart for complex processes
   - Sequence diagram for multi-role interactions

### PlantUML Diagrams

Read `${CLAUDE_SKILL_DIR}/../_shared/plantuml.md` for the complete PlantUML specification (env detection, syntax, SVG conversion). Follow the process strictly.

### Step 5: Update Index

Read `${CLAUDE_SKILL_DIR}/../_shared/status.md` for index.md format and status enum.

Add the requirement record to `requirements/index.md` with status `Requirement Finalized`. If `index.md` does not exist, create it per the shared specification.
