# Change Log Format

All `requirement.md` and `technical.md` files must include a Change Log section using this exact format.

## Template

```markdown
## Change Log

| Version | Date | Changes | Affected Scope | Reason |
|:---|:---|:---|:---|:---|
| v1 | <date> | Initial version | ALL | - |
```

## Rules

### Affected Scope Column

**This column is mandatory and must be filled accurately.** It is the basis for automated mismod detection in the review stage (`req-6-review`).

- For `requirement.md`: fill in affected feature IDs, e.g. `F-01, F-03`
- For `technical.md`: fill in affected section/module IDs, e.g. `Module 4.1, API 6.2`
- Use `ALL` only for initial version or full rewrites
- **Never leave this column empty**

### Version Numbering

- Increment sequentially: v1, v2, v3...
- Each change must add a new row — never modify existing rows

### Mismod Detection Principle

A version's changes must **only affect the scope declared in Affected Scope**. If undeclared content changes between versions, it is classified as a mismod (undeclared change) and must be reported during review.

Example of a mismod:

```markdown
| v1 | 2024-01-01 | Initial version | ALL | - |
| v2 | 2024-01-15 | Add feature C | F-03 | New requirement |
```

If v2 also changed F-02 content but `Affected Scope` only says `F-03` → **mismod detected**.
