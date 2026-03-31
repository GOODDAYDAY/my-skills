# my-skills

Personal Claude Code skills repository. A complete requirement-driven development workflow — from requirement analysis to final delivery.

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

Once installed, all skills are auto-discovered by Claude Code as slash commands.

The core workflow is `/req`, which orchestrates a full development cycle in 8 stages:

```
/req "feature description"
  │
  ├─ Stage 1: Requirement Analysis ──→ requirement.md + diagrams        [tag: REQ-xxx-analyzed]
  │    ↓ (user approval required)
  ├─ Stage 2: Technical Design ──────→ technical.md + diagrams          [tag: REQ-xxx-designed]
  │    ↓ (user approval required)
  ├─ Stage 3: Coding ────────────────→ source code + scripts/           [tag: REQ-xxx-coded]
  │    ↓                                (acceptance tests first, commit per module)
  ├─ Stage 4: Security Review ──────→ vulnerability scan + fix          [tag: REQ-xxx-security]
  │    ↓
  ├─ Stage 5: Code Cleanup ─────────→ structural optimization           [tag: REQ-xxx-cleaned]
  │    ↓
  ├─ Stage 6: Requirement Review ────→ compliance check report
  │    ↓
  ├─ Stage 7: Verification ─────────→ build / run / test                [tag: REQ-xxx-verified]
  │    ↓
  └─ Stage 8: Archive ──────────────→ consistency check + mark completed
```

Each stage waits for user confirmation before proceeding. You can also run any stage independently.

Supports **checkpoint recovery** — if interrupted mid-stage, `/req REQ-xxx` detects where you left off and resumes from there.

When completed requirements accumulate, `/req-archive` batch-archives them and generates a milestone summary.

## Skills

| Command | Description |
|:---|:---|
| `/req [description]` | Full workflow orchestrator — guides through all 8 stages |
| `/req-1-analyze [description]` | Requirement analysis — expand brief input into detailed requirement doc |
| `/req-2-tech [REQ-xxx]` | Technical design — architecture, modules, API, diagrams |
| `/req-3-code [REQ-xxx]` | Coding — acceptance tests first, parallel modules, per-module commits |
| `/req-4-security [REQ-xxx]` | Security review — vulnerability scan, fix critical/high issues |
| `/req-5-cleanup [REQ-xxx]` | Code cleanup — remove unused code, merge duplicates (no behavior changes) |
| `/req-6-review [REQ-xxx]` | Requirement review — compare implementation against requirements |
| `/req-7-verify [REQ-xxx]` | Verification — build, run, and test (Playwright e2e in project language) |
| `/req-8-done [REQ-xxx]` | Archive — consistency check + mark as completed, prompts archive if threshold reached |
| `/req-archive` | Batch archive completed requirements + generate milestone summary |
| `/req-status [REQ-xxx\|archived]` | Status check — active requirements by default, pass `archived` for history |
| `/req-amend [REQ-xxx]` | Formal change process — safely amend finalized documents |
| `/create-skill [name]` | Guide for creating new skills |

## Document Structure

All requirement documents are managed under `requirements/` in your project root:

```
requirements/
├── index.md                        # Active requirements (English); archive-threshold config
├── REQ-001-user-login/             # Active requirement folders
│   ├── requirement.md
│   ├── technical.md
│   ├── *.puml / *.svg
│   └── ...
└── archive/
    ├── milestone-2026-03-31.md     # Milestone summary (what shipped, shared modules, decisions)
    └── REQ-001-user-login/         # Archived requirement folders (moved by /req-archive)
```

`index.md` is split into **Active** and **Archived** sections. An `archive-threshold` comment (default: 5) controls when `/req-8-done` prompts you to run `/req-archive`.

## Repository Structure

```
my-skills/
├── _shared/
│   ├── plantuml.md                  # Shared PlantUML conventions + env detection
│   ├── status.md                    # Status enum, index.md format (Active/Archived sections)
│   ├── changelog.md                 # Change log format and mismod detection rules
│   ├── recovery.md                  # Breakpoint recovery pattern
│   └── scripts.md                   # Automation script standards
├── create-skill/SKILL.md
├── req/SKILL.md                     # Workflow orchestrator
├── req-1-analyze/SKILL.md           # Requirement analysis
├── req-2-tech/SKILL.md              # Technical design
├── req-3-code/                      # Coding
│   ├── SKILL.md
│   ├── python.md                    # Python conventions
│   └── java.md                      # Java conventions
├── req-4-security/SKILL.md          # Security review
├── req-5-cleanup/SKILL.md           # Code cleanup (no behavior changes)
├── req-6-review/SKILL.md            # Requirement review
├── req-7-verify/SKILL.md            # Verification & testing
├── req-8-done/SKILL.md              # Archive + consistency check + threshold prompt
├── req-archive/SKILL.md             # Batch archive + milestone summary
├── req-status/SKILL.md              # Status query (active by default)
└── req-amend/SKILL.md               # Formal change process
```
