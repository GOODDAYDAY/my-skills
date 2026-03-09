---
name: create-skill
description: Guide for creating new Claude Code skills following current conventions
argument-hint: "[skill-name]"
---

Create a new skill based on user requirements. Follow the structure and conventions below strictly.

## Skill Directory Structure

```
<skill-name>/
├── SKILL.md           # Required - entry point with frontmatter + instructions
├── reference.md       # Optional - supporting documentation
├── examples/          # Optional - example outputs
│   └── sample.md
└── scripts/           # Optional - executable scripts
    └── run.sh
```

## SKILL.md Format

```yaml
---
name: <skill-name>                # Optional, defaults to directory name
description: <one-line summary>   # Recommended, used for auto-discovery
argument-hint: "[args]"           # Optional, autocomplete hint
disable-model-invocation: true    # Optional, manual invocation only
user-invocable: false             # Optional, Claude auto-invocation only
allowed-tools: [Read, Grep]       # Optional, restrict available tools
context: fork                     # Optional, run in isolated subagent
---

Markdown instructions for Claude to follow.
```

## Naming Rules

- Directory name: lowercase letters, numbers, hyphens only (max 64 chars)
- Directory name becomes the slash command: `my-skill/` → `/my-skill`
- Plugin skills use namespace: `plugin-name:skill-name`

## Available Variables

| Variable | Description |
|:---|:---|
| `$ARGUMENTS` | All arguments passed to the skill |
| `$ARGUMENTS[0]`, `$0` | First argument |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_SKILL_DIR}` | Skill's own directory path (stable even if cwd changes) |

## Skill Placement

| Location | Path | Scope |
|:---|:---|:---|
| Personal | `~/.claude/skills/<name>/` | All your projects |
| Project | `.claude/skills/<name>/` | Current project only |
| Plugin | `<plugin>/skills/<name>/` | Where plugin is enabled |

## Steps

1. If `$ARGUMENTS` provides a skill name, use it; otherwise ask the user.
2. Ask the user for the skill's purpose and behavior.
3. Create the directory under the current skills root.
4. Write `SKILL.md` with appropriate frontmatter and clear, concise instructions.
5. Add supporting files only if needed (reference docs, scripts, examples).
6. Keep instructions focused — avoid over-engineering.
