---
name: create-skill
description: 创建新的 Claude Code skill，遵循当前最新规范
argument-hint: "[skill-name]"
---

根据用户需求创建新的 skill。严格遵循以下结构和规范。

## Skill 目录结构

```
<skill-name>/
├── SKILL.md           # 必需 - 入口文件，包含 frontmatter + 指令
├── reference.md       # 可选 - 补充参考文档
├── examples/          # 可选 - 示例输出
│   └── sample.md
└── scripts/           # 可选 - 可执行脚本
    └── run.sh
```

## SKILL.md 格式

```yaml
---
name: <skill-name>                # 可选，默认使用目录名
description: <一句话描述>          # 推荐，用于自动发现
argument-hint: "[参数提示]"        # 可选，自动补全提示
disable-model-invocation: true    # 可选，仅手动调用
user-invocable: false             # 可选，仅 Claude 自动调用
allowed-tools: [Read, Grep]       # 可选，限制可用工具
context: fork                     # 可选，在隔离子进程中运行
---

给 Claude 的 Markdown 指令内容。
```

## 命名规则

- 目录名：仅限小写字母、数字、连字符（最长 64 字符）
- 目录名即斜杠命令：`my-skill/` → `/my-skill`
- 插件 skill 使用命名空间：`plugin-name:skill-name`

## 可用变量

| 变量 | 说明 |
|:---|:---|
| `$ARGUMENTS` | 传入的所有参数 |
| `$ARGUMENTS[0]`、`$0` | 第一个参数 |
| `${CLAUDE_SESSION_ID}` | 当前会话 ID |
| `${CLAUDE_SKILL_DIR}` | skill 自身目录路径（即使工作目录变化也稳定） |

## Skill 存放位置

| 位置 | 路径 | 作用范围 |
|:---|:---|:---|
| 个人 | `~/.claude/skills/<name>/` | 你的所有项目 |
| 项目 | `.claude/skills/<name>/` | 仅当前项目 |
| 插件 | `<plugin>/skills/<name>/` | 启用该插件的项目 |

## 执行步骤

1. 如果 `$ARGUMENTS` 提供了 skill 名称，直接使用；否则询问用户。
2. 询问用户该 skill 的用途和行为。
3. 在当前 skills 根目录下创建对应目录。
4. 编写 `SKILL.md`，包含合适的 frontmatter 和简洁清晰的指令。
5. 仅在需要时添加辅助文件（参考文档、脚本、示例）。
6. 保持指令聚焦，避免过度设计。
