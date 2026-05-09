---
name: req-catalog
description: Generate requirements/CATALOG.md — project knowledge index with full architecture and domain document descriptions. TRIGGER when: user asks to regenerate catalog, update project index, or sync documentation index (e.g. "重新生成 CATALOG", "更新目录")
argument-hint: "[force]"
---

# req-catalog — Requirements Catalog Generator

## 1. Role

You generate `requirements/CATALOG.md` — a single rich document that serves as the project's "abstract memory". It contains the full architecture and a description index of every requirement document, so any reader (human or AI) can understand what exists and decide what to read in depth.

## 2. Preconditions

- `requirements/index.md` must exist — if not, abort with: `"No requirements/index.md found. Run req (analyze stage) first."`
- `requirements/architecture.md` is optional — if missing, skip the architecture section

## 3. Algorithm

### 3.1 Collect metadata

1. **Read `requirements/index.md`** — parse the Domains table to get: Domain, Path, Description
2. **Read `requirements/architecture.md`** — store full content (if file exists)
3. **For each domain** (in table order):
   a. List all `.md` files in the domain directory
   b. Exclude: `README.md`, `CATALOG.md`, `index.md`
   c. For each remaining `.md` file, extract its description:
      - **Priority 1**: YAML frontmatter `description` field
      - **Priority 2**: First non-empty paragraph after the H1 heading, before `---` or next heading (`#` or `##`)
      - **Priority 3**: H1 heading text itself (strip `# ` prefix)
   d. If no standalone `.md` files exist in the domain directory (only README.md), mark as inline domain

### 3.2 Assemble CATALOG.md

Write `requirements/CATALOG.md` following this structure:

```markdown
# Requirements Catalog
Generated: {YYYY-MM-DD} | {N} domains, {M} documents

---

## Technical Architecture

{Full content of architecture.md, verbatim — include everything from the first
 line after the H1 title to the end of the file. Preserve all headings, tables,
 code blocks, and formatting exactly as-is.}

---

## Domains

### {domain_name}
{domain_description from index.md}

| Document | Description |
|:---|:---|
| {filename} | {description extracted per §3.1} |

{Repeat for each domain in index.md order}

---
Read any document: read_file("requirements/{domain}/{file}")
Full architecture: read_file("requirements/architecture.md")
```

**Rules:**
- Domain headers use `###` (h3)
- Document table entries: just the filename (not a link), pipe, description
- For inline domains (no standalone files), replace the table with: `(All content inline in README.md)`
- The `{M} documents` count = total standalone `.md` files across all domains (excluding READMEs)
- Architecture section includes the full file content, not a summary
- If architecture.md is missing, omit the entire "Technical Architecture" section and its surrounding `---` dividers

### 3.3 Write and commit

1. Write the assembled content to `requirements/CATALOG.md`
2. Git commit (if in a git repo):
   ```
   git add requirements/CATALOG.md
   git commit -m "docs: regenerate requirements catalog"
   ```
   If nothing changed (file identical), skip the commit.

### 3.4 YAML Frontmatter Spec (for extraction)

Standalone scenario files use this frontmatter format:

```yaml
---
name: {Scenario Name}
description: {One-line summary of what this scenario covers, max 120 chars}
---
```

When generating, read frontmatter from existing files. For the `force` argument, add frontmatter to files that lack it using H1 title and preamble.

## 4. Stage Result

```
## Stage Result
- **status**: generated | error
- **domains**: {N}
- **documents**: {M}
- **has_architecture**: yes | no
- **frontmatter_count**: {how many files had YAML frontmatter}
- **fallback_count**: {how many files used H1/preamble fallback}
```

## 5. Argument: `force`

When invoked with `force` argument: also add missing YAML frontmatter to scenario files that lack it.

For each file without frontmatter:
1. Read the H1 title and preamble description
2. Prepend frontmatter block:
   ```yaml
   ---
   name: {H1 title}
   description: {preamble, truncated to 120 chars}
   ---
   ```
3. Include these files in the git commit

This is a one-time migration convenience. After `force`, all files will have frontmatter and future catalog generations will use Priority 1 exclusively.
