---
name: write-doc
description: Write a structured technical document following project markdown conventions
argument-hint: "[topic or description]"
---

Write a comprehensive technical document following the format specification in `${CLAUDE_SKILL_DIR}/../_shared/markdown.md`. Read that file before starting.

## Flow

### Step 1: Gather Requirements

If `$ARGUMENTS` is empty, ask:
- "What is the document topic?"
- "Who is the target audience?"
- "What scope should it cover? (overview / deep-dive / reference)"
- "Any existing content or sources to incorporate?"

If `$ARGUMENTS` provides a topic, proceed directly.

### Step 2: Research

If the topic requires current or external knowledge, use WebFetch to gather material before writing. Search multiple sources and synthesize.

### Step 3: Plan the Structure

Output a heading outline for user review:

```
# Title
## 1. Section
### 1.1 Sub-section
### 1.2 Sub-section
#### 1.2.1 Deep point
## 2. Section
...
```

Rules for the outline:
- Aim for at least 10 subsections (`###` or deeper) per `##` section
- Every concept, rule, pattern, or scenario gets its own heading
- Mark planned Mermaid diagrams: `[DIAGRAM: flowchart of X]`
- At least one diagram per `##` section

**Wait for user approval before writing.**

### Step 4: Internal Loop — Write → Review → Simplify

Run this loop (max 3 iterations) until the document is stable (no structural changes between iterations):

#### 4.1 Write / Revise

On the first iteration: write the full document.
On subsequent iterations: apply only the changes identified in the previous Review and Simplify steps — do not rewrite from scratch.

Writing rules (from `_shared/markdown.md`):
- `# Title` followed immediately by `> Version | Date` metadata line
- All headings numbered: `## 1.`, `### 1.1`, `#### 1.1.1`
- One blank line before each heading; no blank lines after a heading before its first content line
- No consecutive blank lines; no `---` / `***` / `___` dividers
- Mermaid diagrams placed immediately after the introducing content, with bold caption below: `**Figure X.X — description**`; all diagram text in English
- Each section must be substantive; include concrete examples and code snippets where relevant

#### 4.2 Format Review

Check every item — fix violations immediately before proceeding:
- [ ] All headings numbered correctly and sequentially
- [ ] No `---` dividers anywhere
- [ ] No consecutive blank lines
- [ ] Every `##` section has at least one Mermaid diagram
- [ ] All diagram text in English with bold captions
- [ ] Document starts with `# Title` and metadata blockquote

#### 4.3 Content Review

For each `##` section, verify:
- [ ] Coverage: does it address what the heading promises? No missing sub-topics
- [ ] Accuracy: are claims correct and not contradicted elsewhere?
- [ ] Depth: are there vague or shallow subsections that need expansion?
- [ ] Examples: does each significant concept have a concrete example or code snippet?

Record each gap as a numbered finding: `[CR-01] Section 3.2 — missing error handling example`.

#### 4.4 Simplify

**Goal: prevent the document from growing with each iteration.** For every section, actively look for content to cut or merge:

- **Remove duplicates**: if the same point is made in two places, keep the better one and delete the other
- **Merge thin headings**: if two adjacent `###` or `####` sections together form only 2–3 sentences, merge them under one heading
- **Trim verbose prose**: cut filler phrases, redundant transitions, and over-explained obvious points
- **Reduce example overload**: if a concept has 3 examples and 1 suffices, cut 2
- **Cut unearned headings**: a heading that contributes nothing beyond restating the parent section's content should be removed

Record each cut as: `[S-01] Merged 3.2.1 and 3.2.2 — both said the same thing`.

#### 4.5 Convergence Check

After completing 4.2–4.4, assess stability:
- If there are open `[CR-xx]` findings **or** structural changes from Simplify → loop back to 4.1
- If only minor wording fixes remain and no structural changes → exit the loop
- If iteration count reaches 3 → exit regardless, note remaining open findings

### Step 5: Deliver

Present the final document with a brief summary:
- Iterations run
- Key changes made in final round
- Any remaining open findings (if exited at max iterations)

Ask the user:
- "Any sections to expand or cut?"
- "Where should this be saved?"

Save to the specified path if provided.
