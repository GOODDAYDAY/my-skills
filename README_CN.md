# my-skills

个人 Claude Code Skills 仓库。一套完整的需求驱动开发工作流——从需求分析到验证交付。

> **注意：** 所有 SKILL.md 文件现已改为英文编写。本 README 保留中文版本供参考。

[English](./README.md)

## 安装

将本仓库作为 git submodule 添加到项目的 `.claude/skills` 目录：

```bash
git submodule add git@github.com:GOODDAYDAY/my-skills.git .claude/skills
```

克隆已包含此 submodule 的项目：

```bash
git clone --recurse-submodules <你的项目仓库>
```

更新 skills 到最新版本：

```bash
git submodule update --remote .claude/skills
```

## 使用方式

安装后，所有 skill 会被 Claude Code 自动发现为斜杠命令。

核心工作流是 `/req`，编排完整的开发周期：

```
/req "功能描述"
  │
  ├─ [bootstrap]  — 检查/生成 project-description-skills
  │                 （将项目知识内化为 AI 技能）
  ├─ analyze      — 需求分析 ──────→ 领域场景文档 + 配图
  │    ↓（需要用户确认）
  ├─ tech         — 技术设计 ──────→ 实现方案 + architecture.md
  │    ↓
  ├─ code         — 编码开发 ──────→ 源代码 + scripts/
  │    ↓                              （测试前置，按模块提交）
  ├─ security     — 安全审查 ──────→ 漏洞扫描 + 修复
  │    ↓
  ├─ cleanup      — 代码精简 ──────→ 结构优化（不改业务逻辑）
  │    ↓
  ├─ review       — 需求对比 ──────→ 合规检查报告
  │    ↓
  ├─ verify       — 校验测试 ──────→ 编译 / 运行 / 测试
  │    ↓
  ├─ justify      — 过程论证 ──────→ meta-review
  │    ↓
  └─ skills sync  — 刷新当前领域的 project-description-skills
```

编排器会对每个任务做分流，决定跳过哪些阶段。各阶段会加载 `project-description-skills` 获取领域知识。

支持**基于工件的断点恢复** — 如果中途中断，`/req` 会检查已有的文档、代码、测试来推断上次停在哪里，从断点继续。

## 命令列表

| 命令 | 说明 |
|:---|:---|
| `/req [描述]` | 全流程编排入口——分流并运行所有阶段（analyze → tech → code → security → cleanup → review → verify → justify） |
| `/req-amend [domain/scenario]` | 需求变更——变更领域文档，确认范围并级联检查 |
| `/req-catalog [force]` | 重新生成 requirements/CATALOG.md——项目知识索引 |
| `/req-refresh` | 批量刷新领域需求文档以匹配当前代码（正向 + 反向校验） |
| `/req-domain-skills-generate [--all \| domain-name]` | 生成/刷新 project-description-skills——按领域分区 + 主索引（默认全量；--incremental 按 git diff 增量） |

## 文档结构

所有需求文档统一管理在项目根目录的 `requirements/` 下。领域知识技能生成到 `.claude/skills/project-description-skills/`：

```
requirements/
├── index.md                        # 领域目录（全英文）
├── architecture.md                 # 技术哲学、原则、架构决策
├── CATALOG.md                      # 自动生成的项目知识索引
└── {domain}/
    ├── README.md                   # 领域概述 + 简单场景内联
    └── {scenario}.md               # 复杂场景独立文件

.claude/skills/
└── project-description-skills/     # 由 req-domain-skills-generate 生成
    ├── SKILL.md                    # 主入口——领域索引 + 架构概览
    └── {domain}.md                 # 各领域知识、模式、陷阱、hooks
```

## 仓库结构

```
my-skills/
├── _shared/
│   ├── plantuml.md                  # PlantUML 共享规范 + 环境检测
│   ├── git-commit.md                # Git 提交规范
│   ├── recovery.md                  # 断点恢复模式
│   ├── scripts.md                   # 自动化脚本规范
│   ├── markdown.md                  # Markdown 格式规范
│   └── diverge-converge.md          # 多子代理分析模式
├── create-skill/SKILL.md
├── req/
│   ├── SKILL.md                     # 工作流编排器（所有阶段集成）
│   └── conventions/
│       ├── python.md                # Python 编码规范
│       └── java.md                  # Java 编码规范
├── req-amend/SKILL.md               # 需求变更流程
├── req-catalog/SKILL.md             # 目录重新生成
├── req-refresh/SKILL.md             # 领域文档批量刷新
├── req-domain-skills-generate/SKILL.md  # 领域知识技能生成器
├── write-blog/SKILL.md              # 博客文章生成
└── write-doc/SKILL.md               # 技术文档编写
```
