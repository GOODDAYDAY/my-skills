# my-skills

Personal Claude Code skills repository. A complete requirement-driven development workflow — from requirement analysis to verification.

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

The core workflow is `/req`, which orchestrates a full development cycle:

```
/req "feature description"
  │
  ├─ analyze    — Requirement analysis ──→ domain scenario docs + diagrams
  │    ↓ (user approval required)
  ├─ tech       — Technical design ─────→ implementation approach + architecture.md
  │    ↓
  ├─ code       — Coding ──────────────→ source code + scripts/
  │    ↓                                  (acceptance tests first, commit per module)
  ├─ security   — Security review ─────→ vulnerability scan + fix
  │    ↓
  ├─ cleanup    — Code cleanup ────────→ structural optimization
  │    ↓
  ├─ review     — Requirement review ──→ compliance check report
  │    ↓
  └─ verify     — Verification ────────→ build / run / test
```

The orchestrator triages each task and decides which stages to include or skip. You can also run any stage independently.

Supports **artifact-based recovery** — if interrupted, `/req` checks existing docs, code, and tests to infer where you left off and resumes from there.

## Skills

| Command | Description |
|:---|:---|
| `/req [description]` | Full workflow orchestrator — triages and runs the appropriate stages |
| `/req-analyze [description]` | Requirement analysis — expand brief input into domain scenario docs |
| `/req-tech [domain/scenario]` | Technical design — architecture, modules, implementation approach |
| `/req-code [domain/scenario]` | Coding — acceptance tests first, parallel modules, per-module commits |
| `/req-security [domain/scenario]` | Security review — vulnerability scan, fix critical/high issues |
| `/req-cleanup [domain/scenario]` | Code cleanup — remove unused code, merge duplicates (no behavior changes) |
| `/req-review [domain/scenario]` | Requirement review — compare implementation against domain docs |
| `/req-verify [domain/scenario]` | Verification — build, run, and test |
| `/req-amend [domain/scenario]` | Amendment — update domain docs with scope confirmation and cascade check |
| `/create-skill [name]` | Guide for creating new skills |

## Document Structure

All requirement documents are managed under `requirements/` in your project root:

```
requirements/
├── index.md                        # Domain directory (English)
├── architecture.md                 # Tech philosophy, principles, structural decisions
├── {domain}/
│   ├── README.md                   # Domain overview + simple scenarios inline
│   └── {scenario}.md               # Complex scenarios get separate files
```

## Repository Structure

```
my-skills/
├── _shared/
│   ├── plantuml.md                  # Shared PlantUML conventions + env detection
│   ├── status.md                    # Document templates, writing principles
│   ├── recovery.md                  # Breakpoint recovery pattern
│   ├── scripts.md                   # Automation script standards
│   ├── git-commit.md                # Git commit conventions
│   ├── markdown.md                  # Markdown format specification
│   └── diverge-converge.md          # Multi-subagent analysis pattern
├── create-skill/SKILL.md
├── req/SKILL.md                     # Workflow orchestrator
├── req-analyze/SKILL.md             # Requirement analysis
├── req-tech/SKILL.md                # Technical design
├── req-code/                        # Coding
│   ├── SKILL.md
│   ├── python.md                    # Python conventions
│   └── java.md                      # Java conventions
├── req-security/SKILL.md            # Security review
├── req-cleanup/SKILL.md             # Code cleanup (no behavior changes)
├── req-review/SKILL.md              # Requirement review
├── req-verify/SKILL.md              # Verification & testing
└── req-amend/SKILL.md               # Amendment process
```
