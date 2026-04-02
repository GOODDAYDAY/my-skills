---
name: create-skill
description: Guide for creating new Claude Code skills following current conventions
argument-hint: "[skill-name]"
---

# create-skill
> Version: v1 | Date: 2026-04-02 | Author: system

## 1. 概述
根据用户需求创建新 skill，严格遵守以下结构和规范。

```mermaid
flowchart LR
    A[User request] --> B[Create skill directory]
    B --> C[Write SKILL.md\nwith frontmatter]
    C --> D{Extra files\nneeded?}
    D -- Yes --> E[Add reference.md\nscripts/ examples/]
    D -- No --> F[Done]
    E --> F
```
**Figure 1.1 — Skill creation overview**

## 2. Skill 目录结构

```mermaid
flowchart TD
    A[skill-name/] --> B[SKILL.md\nRequired: entry point]
    A --> C[reference.md\nOptional: docs]
    A --> D[examples/\nOptional: sample outputs]
    A --> E[scripts/\nOptional: run.sh etc.]
```
**Figure 2.1 — Skill directory layout**

```text
<skill-name>/
├── SKILL.md           # Required - entry point with frontmatter + instructions
├── reference.md       # Optional - supporting documentation
├── examples/          # Optional - example outputs
│   └── sample.md
└── scripts/           # Optional - executable scripts
    └── run.sh
```

## 3. 创建流程

```mermaid
flowchart TD
    A[Get skill name from ARGUMENTS or ask user] --> B[Ask for purpose and behavior]
    B --> C[Create directory under skills root]
    C --> D[Write SKILL.md with frontmatter and instructions]
    D --> E{Supporting files needed?}
    E -- Yes --> F[Add reference.md / scripts / examples]
    E -- No --> G[Done]
    F --> G
```
**Figure 3.1 — New skill creation steps**

## 4. SKILL.md 格式规范

```mermaid
flowchart LR
    A[SKILL.md] --> B[frontmatter\n--- name description ---]
    B --> C[Markdown body\nClaude instructions]
    C --> D{Optional frontmatter\nfields?}
    D --> E[allowed-tools\ncontext: fork\nuser-invocable]
```
**Figure 4.1 — SKILL.md structure**

### 4.1 Frontmatter 字段

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

### 4.2 命名规则
- 目录名：仅限小写字母、数字、连字符（最多 64 个字符）
- 目录名即斜杠命令：`my-skill/` → `/my-skill`
- 插件 skill 使用命名空间：`plugin-name:skill-name`

## 5. 可用变量

```mermaid
flowchart LR
    A[Skill invoked] --> B[$ARGUMENTS\nAll passed arguments]
    A --> C[$ARGUMENTS[0] / $0\nFirst argument]
    A --> D[${CLAUDE_SKILL_DIR}\nSkill directory path]
    A --> E[${CLAUDE_SESSION_ID}\nCurrent session ID]
```
**Figure 5.1 — Available runtime variables**

| Variable | Description |
|:---|:---|
| `$ARGUMENTS` | All arguments passed to the skill |
| `$ARGUMENTS[0]`, `$0` | First argument |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_SKILL_DIR}` | Skill's own directory path (stable even if cwd changes) |

## 6. Skill 存放位置

```mermaid
flowchart TD
    A[Skill location] --> B[Personal\n~/.claude/skills/name/\nAll your projects]
    A --> C[Project\n.claude/skills/name/\nCurrent project only]
    A --> D[Plugin\nplugin/skills/name/\nWhere plugin is enabled]
```
**Figure 6.1 — Skill location scopes**

| Location | Path | Scope |
|:---|:---|:---|
| Personal | `~/.claude/skills/<name>/` | All your projects |
| Project | `.claude/skills/<name>/` | Current project only |
| Plugin | `<plugin>/skills/<name>/` | Where plugin is enabled |

## 7. 执行步骤

```mermaid
flowchart TD
    A[Get skill name] --> B[Ask purpose\nand behavior]
    B --> C[Create directory\nunder skills root]
    C --> D[Write SKILL.md\nwith frontmatter]
    D --> E{Supporting files?}
    E -- Yes --> F[Add reference.md\nscripts/ examples/]
    E -- No --> G[Done — focused instructions]
    F --> G
```
**Figure 7.1 — Execution steps**

1. 若 `$ARGUMENTS` 提供了 skill 名称则使用，否则询问用户
2. 询问用户 skill 的用途和行为
3. 在当前 skills 根目录下创建目录
4. 编写 `SKILL.md`，包含合适的 frontmatter 和清晰简洁的指令
5. 仅在需要时添加支持文件（参考文档、脚本、示例）
6. 保持指令聚焦——避免过度设计
