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

Rules:
- At least 10 subsections (`###` or deeper) per `##` section
- Every concept, rule, pattern, or scenario gets its own heading
- Mark planned Mermaid diagrams inline: `[DIAGRAM: flowchart of X]`
- At least one diagram per `##` section

**Wait for user approval before writing.**

### Step 4: Internal Loop — max 3 iterations

Repeat until stable (no structural changes between iterations), then exit.

#### 4.1 Write / Revise

First iteration: write the full document.
Subsequent iterations: apply only the fixes identified in the previous iteration's review steps — do not rewrite from scratch.

Writing rules (from `_shared/markdown.md`):
- `# Title` then immediately `> Version | Date` metadata
- All headings numbered: `## 1.`, `### 1.1`, `#### 1.1.1`
- One blank line before each heading; no blank line between a heading and its first content
- No consecutive blank lines; no `---` / `***` / `___` dividers
- Mermaid diagrams placed right after the introducing content, bold caption below: `**Figure X.X — description**`; all diagram text in English
- Every section substantive; include concrete examples and code snippets where relevant

#### 4.2 Format Review

Fix any violation immediately:
- [ ] All headings numbered correctly and sequentially
- [ ] No `---` dividers anywhere
- [ ] No consecutive blank lines
- [ ] No blank line between a heading and its first line of content
- [ ] Every `##` section has at least one Mermaid diagram
- [ ] All diagram text in English with bold captions
- [ ] Document starts with `# Title` and metadata blockquote

#### 4.3 Content Review

For each `##` section, check and fix directly:
- **Coverage**: does the content deliver exactly what the heading promises? If a heading says "最佳实践", there must be concrete actionable practices — not just description
- **Depth**: are there vague or shallow subsections that need expansion?
- **Examples**: does each significant concept have a concrete example or code snippet?
- **Knowledge continuity**: reading as the target audience, are there concept jumps where a term or idea appears without prior introduction? Fill any gaps

#### 4.4 Simplify

Actively look for content to cut or merge — fix directly:
- **Remove duplicates**: same point made in two places → keep the better one, delete the other
- **Merge thin headings**: two adjacent `###`/`####` sections that together form only 2–3 sentences → merge under one heading
- **Trim verbose prose**: cut filler phrases, redundant transitions, over-explained obvious points
- **Reduce example overload**: if a concept has 3 examples and 1 suffices, cut 2
- **Cut unearned headings**: a heading whose content merely restates the parent section → remove
- **Diagram value**: for each diagram, ask "does this show something the surrounding text cannot convey as clearly?" If not, remove the diagram and strengthen the text instead

#### 4.5 Terminology Consistency

Scan the full document and fix inconsistencies:
- Same concept named differently across sections (e.g., "Agent" vs "agent", "工作流" vs "Workflow" vs "工作流程")
- Capitalization inconsistencies for proper nouns and technical terms
- Language mixing: decide per term whether to use Chinese or English, then apply uniformly
- Abbreviations: each abbreviation introduced once on first use, then used consistently

#### 4.6 Convergence Check

- Structural changes were made in 4.2–4.5 → loop back to 4.1
- Only minor wording fixes, no structural changes → exit loop
- Iteration count reached 3 → exit regardless

### Step 5: Deliver

Present the final document with a brief summary of what changed across iterations.

Ask the user:
- "Any sections to expand or cut?"
- "Where should this be saved?"

Save to the specified path if provided.
