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

Before writing, output a heading outline for user review:

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
- Aim for at least 10 top-level subsections (at `###` level or deeper) per `##` section
- Every concept, rule, pattern, or scenario gets its own heading
- Include planned Mermaid diagrams in the outline: `[DIAGRAM: flowchart of X]`
- At least one diagram per major section (`##`)

**Wait for user approval before writing.**

### Step 4: Write the Document

Write the full document following these rules strictly (from `_shared/markdown.md`):

**Structure:**
- `# Title` followed immediately by `> Version: v1 | Date: <date>` metadata line
- All headings numbered: `## 1.`, `### 1.1`, `#### 1.1.1`, etc.
- As many headings as possible — split every logical unit into its own heading

**Blank lines:**
- One blank line before each heading
- No blank lines after a heading before content
- No consecutive blank lines anywhere

**No dividers:** `---` / `***` / `___` are prohibited

**Diagrams:**
- Use Mermaid for all diagrams
- Place immediately after the introducing heading/paragraph
- Add bold caption below: `**Figure X.X — description**`
- All diagram text in English

**Quality:**
- Each section must be substantive — no one-liner sections without depth
- Include concrete examples, code snippets, and comparisons where relevant
- Best practices sections must list at least 3 specific, actionable items

### Step 5: Self-Review

After writing, check:
- [ ] All headings numbered correctly and sequentially
- [ ] No `---` dividers present
- [ ] No consecutive blank lines
- [ ] Every `##` section has at least one Mermaid diagram
- [ ] Diagrams have English-only text and bold captions
- [ ] Document starts with `# Title` and metadata blockquote

Fix any violations before presenting to user.

### Step 6: Deliver

Present the document. Ask the user:
- "Any sections you want expanded?"
- "Any diagrams to add or change?"
- "Where should this be saved?"

Save to the specified path if provided.
