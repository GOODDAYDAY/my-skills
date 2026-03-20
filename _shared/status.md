# Requirement Status Enum

All statuses used in `requirements/index.md`, `requirement.md`, and `technical.md`.

| Status | Meaning | Next Stage |
|:---|:---|:---|
| `Requirement Draft` | Requirement analysis in progress | → req-1-analyze |
| `Requirement Finalized` | Requirement approved | → req-2-tech |
| `Technical Design` | Technical design in progress | → req-2-tech |
| `Technical Finalized` | Technical design approved | → req-3-code |
| `In Development` | Coding in progress | → req-3-code |
| `Development Done` | Coding completed | → req-4-security |
| `Security Reviewed` | Security review passed | → req-5-cleanup |
| `Code Cleaned` | Code cleanup completed | → req-6-review |
| `Reviewed` | Requirement review passed | → req-7-verify |
| `In Verification` | Verification in progress | → req-7-verify |
| `Completed` | All done | - |

## index.md Format

`index.md` **must be written entirely in English**, including requirement names and descriptions.

Template (create if not exists):

```markdown
# Requirement Index

| ID | Name | Status | Updated | Description |
|:---|:---|:---|:---|:---|
```

Adding a record:

```markdown
| REQ-xxx | <requirement name> | <status> | <date> | <brief description> |
```

## Updating Status

When updating `index.md`, only change the `Status` and `Updated` columns for the target REQ. Do not modify other rows.
