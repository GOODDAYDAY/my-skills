# my-skills

Personal Claude Code skills repository. An **orchestrator-driven**, **stateless** requirement workflow — the orchestrator observes the real filesystem every round, reasons about what is still missing, and dispatches exactly one sub-skill at a time. There is no fixed pipeline.

[中文版](./README_CN.md)

## Installation

Add this repository as a git submodule to your project's `.claude/skills` directory:

```bash
git submodule add git@github.com:GOODDAYDAY/my-skills.git .claude/skills
```

To clone a project that already includes this submodule:

```bash
git clone --recurse-submodules <your-project-repo>
```

To update the skills to the latest version:

```bash
git submodule update --remote .claude/skills
```

## How It Works

Once installed, every skill is auto-discovered by Claude Code as a slash command. The key architectural idea is:

> **Two orchestrators (`req`, `task`). Everything else is an orchestratable sub-skill. The orchestrator never follows a fixed order — it observes, reasons, dispatches.**

### The observe-reason-dispatch loop

```
/req "feature description"
   │
   ▼
┌──────────────────────────────────────────────────┐
│ req orchestrator                                 │
│                                                  │
│   1. Observe:  ls + read requirements/REQ-xxx/   │
│   2. Reason:   what's missing / stale / next?    │
│   3. Dispatch: invoke exactly ONE sub-skill      │
│   4. Sub-skill does its job and returns          │
│   5. Loop back to step 1 (re-observe fresh)      │
└──────────────────────────────────────────────────┘
```

Every round, the orchestrator re-reads the REQ directory from scratch. No cached status, no "Next Stage" table, no persisted state file. The filesystem is the single source of truth. Sub-skills are forbidden from naming the next step — they just do one bounded job and hand control back.

This naturally supports resuming interrupted work, jumping between steps, skipping steps, amending finalized documents (with downstream artifacts automatically reconsidered), and running multiple requirements in parallel.

## Skills

### Orchestrators

| Command | Description |
|:---|:---|
| `/req [description \| REQ-xxx]` | Requirement-driven development orchestrator. Dispatches all requirement sub-skills below. |
| `/task [description]` | Generic task orchestrator. Extension point for non-requirement workflows. |

### Requirement sub-skills (orchestrated by `/req`)

| Command | Description |
|:---|:---|
| `/req-analyze [description]` | Expand brief input into a full requirement document |
| `/req-tech [REQ-xxx]` | Write technical design from a finalized requirement |
| `/req-code [REQ-xxx]` | Implement source code + automation scripts + logging |
| `/req-security [REQ-xxx]` | Security review — fix critical/high, report medium/low |
| `/req-cleanup [REQ-xxx]` | Remove unused / duplicate / dead code (no behavior change) |
| `/req-review [REQ-xxx]` | Compare implementation against the requirement item by item |
| `/req-verify [REQ-xxx]` | Build, run, test (including Playwright e2e for web projects) |
| `/req-archive [REQ-xxx]` | Final consistency check + mark requirement completed |
| `/req-amend [REQ-xxx]` | Formal change process for approved requirement / technical docs |
| `/req-status [REQ-xxx \| all]` | Present the observed state of one or all requirements |

### Other

| Command | Description |
|:---|:---|
| `/create-skill [name]` | Guide for creating new skills |

Although each sub-skill has its own slash command for direct invocation, the intended usage is to call `/req` and let the orchestrator decide. Sub-skills never chain to each other.

## Document Structure

All requirement documents are managed under `requirements/` in your project root:

```
requirements/
├── index.md                        # Pure catalog: ID | Name | Updated | Description (no Status column)
├── REQ-001-user-login/
│   ├── requirement.md              # Requirement document (contains its own approval marker)
│   ├── technical.md                # Technical design document (contains its own approval marker)
│   ├── *.puml / *.svg              # PlantUML diagrams
│   ├── security-review.md          # Produced by /req-security
│   ├── cleanup-report.md           # Produced by /req-cleanup
│   ├── review-report.md            # Produced by /req-review
│   ├── verify-report.md            # Produced by /req-verify
│   └── ...
└── REQ-002-data-export/
    └── ...
```

All workflow understanding comes from **what is actually in this directory**. No external state store.

## Repository Structure

```
my-skills/
├── _shared/
│   ├── plantuml.md                  # PlantUML conventions + env detection
│   ├── scripts.md                   # Automation script standards (.bat + .sh)
│   └── changelog.md                 # Change log format + Affected Scope rules
├── req/SKILL.md                     # Requirement orchestrator (stateless, observe-dispatch loop)
├── task/SKILL.md                    # Generic task orchestrator skeleton
├── req-analyze/SKILL.md             # Requirement analysis sub-skill
├── req-tech/SKILL.md                # Technical design sub-skill
├── req-code/                        # Coding sub-skill
│   ├── SKILL.md
│   ├── python.md                    # Python conventions
│   └── java.md                      # Java conventions
├── req-security/SKILL.md            # Security review sub-skill
├── req-cleanup/SKILL.md             # Cleanup sub-skill (no behavior changes)
├── req-review/SKILL.md              # Requirement review sub-skill
├── req-verify/SKILL.md              # Verification sub-skill
├── req-archive/SKILL.md             # Archive sub-skill (final consistency check)
├── req-status/SKILL.md              # Observed-state presenter
├── req-amend/SKILL.md               # Formal change process
└── create-skill/SKILL.md
```

## Design Notes

- **No status enum, no Status column.** Finalization is recorded as a marker *inside* the document itself (e.g., "Approved by user on <date>"). The orchestrator reads the documents directly.
- **No "next step" in sub-skills.** Sub-skills may not reference sibling skill names or suggest what should happen next. They just do their job and end with a handoff line.
- **No predicate cache file.** Predicates are a shorthand for reasoning, not a persisted data structure.
- **Amend is just another dispatch.** When a requirement is amended, the orchestrator re-observes next round and naturally decides that technical / code / tests are stale — no invalidation logic is needed.
