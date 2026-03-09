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

The core workflow is `/req`, which orchestrates a full development cycle in 6 stages:

```
/req "feature description"
  │
  ├─ Stage 1: Requirement Analysis ──→ requirement.md + diagrams
  │    ↓ (user approval required)
  ├─ Stage 2: Technical Design ──────→ technical.md + diagrams
  │    ↓ (user approval required)
  ├─ Stage 3: Coding ────────────────→ source code + scripts/
  │    ↓
  ├─ Stage 4: Requirement Review ────→ compliance check report
  │    ↓
  ├─ Stage 5: Verification ─────────→ build / run / test
  │    ↓
  └─ Stage 6: Archive ──────────────→ consistency check + mark completed
```

Each stage waits for user confirmation before proceeding. You can also run any stage independently.

Supports **checkpoint recovery** — if interrupted mid-stage, `/req REQ-xxx` detects where you left off and resumes from there.

## Skills

| Command | Description |
|:---|:---|
| `/req [description]` | Full workflow orchestrator — guides through all 6 stages |
| `/req-1-analyze [description]` | Requirement analysis — expand brief input into detailed requirement doc |
| `/req-2-tech [REQ-xxx]` | Technical design — architecture, modules, API, diagrams |
| `/req-3-code [REQ-xxx]` | Coding — develop with language-specific conventions |
| `/req-4-review [REQ-xxx]` | Requirement review — compare implementation against requirements |
| `/req-5-verify [REQ-xxx]` | Verification — build, run, and test (including Playwright e2e for web) |
| `/req-6-done [REQ-xxx]` | Archive — consistency check + mark as completed |
| `/req-status [REQ-xxx\|all]` | Quick status check — view one or all requirements |
| `/req-amend [REQ-xxx]` | Formal change process — safely amend finalized documents |
| `/create-skill [name]` | Guide for creating new skills |

## Document Structure

All requirement documents are managed under `requirements/` in your project root:

```
requirements/
├── index.md                        # Requirement index & status tracking (English)
├── REQ-001-user-login/
│   ├── requirement.md              # Requirement document
│   ├── technical.md                # Technical design document
│   ├── *.puml / *.svg              # PlantUML diagrams
│   └── ...
└── REQ-002-data-export/
    └── ...
```

## Repository Structure

```
my-skills/
├── _shared/plantuml.md              # Shared PlantUML conventions + env detection
├── create-skill/SKILL.md
├── req/SKILL.md                     # Workflow orchestrator
├── req-1-analyze/SKILL.md           # Requirement analysis
├── req-2-tech/SKILL.md              # Technical design
├── req-3-code/                      # Coding
│   ├── SKILL.md
│   ├── python.md                    # Python conventions
│   └── java.md                      # Java conventions
├── req-4-review/SKILL.md            # Requirement review
├── req-5-verify/SKILL.md            # Verification & testing
├── req-6-done/SKILL.md              # Archive + consistency check
├── req-status/SKILL.md              # Status query
└── req-amend/SKILL.md               # Formal change process
```
