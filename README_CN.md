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
  ├─ analyze    — 需求分析 ──────→ 领域场景文档 + 配图
  │    ↓（需要用户确认）
  ├─ tech       — 技术设计 ──────→ 实现方案 + architecture.md
  │    ↓
  ├─ code       — 编码开发 ──────→ 源代码 + scripts/
  │    ↓                            （测试前置，按模块提交）
  ├─ security   — 安全审查 ──────→ 漏洞扫描 + 修复
  │    ↓
  ├─ cleanup    — 代码精简 ──────→ 结构优化（不改业务逻辑）
  │    ↓
  ├─ review     — 需求对比 ──────→ 合规检查报告
  │    ↓
  └─ verify     — 校验测试 ──────→ 编译 / 运行 / 测试
```

编排器会对每个任务做分流，决定跳过哪些阶段。也可以单独运行任意阶段。

支持**基于工件的断点恢复** — 如果中途中断，`/req` 会检查已有的文档、代码、测试来推断上次停在哪里，从断点继续。

## 命令列表

| 命令 | 说明 |
|:---|:---|
| `/req [描述]` | 全流程编排入口，分流并运行合适的阶段 |
| `/req-analyze [描述]` | 需求分析——将简单描述扩展为领域场景文档 |
| `/req-tech [domain/scenario]` | 技术设计——架构、模块、实现方案 |
| `/req-code [domain/scenario]` | 编码开发——测试前置、模块并行、按模块提交 |
| `/req-security [domain/scenario]` | 安全审查——漏洞扫描，严重/高风险直接修复 |
| `/req-cleanup [domain/scenario]` | 代码精简——删除无用代码、合并重复逻辑（不改业务逻辑） |
| `/req-review [domain/scenario]` | 需求对比——逐项检查实现是否满足需求 |
| `/req-verify [domain/scenario]` | 校验测试——编译、运行、测试 |
| `/req-amend [domain/scenario]` | 需求变更——变更领域文档，确认范围并级联检查 |
| `/create-skill [name]` | 创建新 skill 的标准指南 |

## 文档结构

所有需求文档统一管理在项目根目录的 `requirements/` 下：

```
requirements/
├── index.md                        # 领域目录（全英文）
├── architecture.md                 # 技术哲学、原则、架构决策
├── {domain}/
│   ├── README.md                   # 领域概述 + 简单场景内联
│   └── {scenario}.md               # 复杂场景独立文件
```

## 仓库结构

```
my-skills/
├── _shared/
│   ├── plantuml.md                  # PlantUML 共享规范 + 环境检测
│   ├── status.md                    # 文档模板、编写原则
│   ├── recovery.md                  # 断点恢复模式
│   ├── scripts.md                   # 自动化脚本规范
│   ├── git-commit.md                # Git 提交规范
│   ├── markdown.md                  # Markdown 格式规范
│   └── diverge-converge.md          # 多子代理分析模式
├── create-skill/SKILL.md
├── req/SKILL.md                     # 全流程编排
├── req-analyze/SKILL.md             # 需求分析
├── req-tech/SKILL.md                # 技术设计
├── req-code/                        # 编码开发
│   ├── SKILL.md
│   ├── python.md                    # Python 开发规范
│   └── java.md                      # Java 开发规范
├── req-security/SKILL.md            # 安全审查
├── req-cleanup/SKILL.md             # 代码精简（不改业务逻辑）
├── req-review/SKILL.md              # 需求对比
├── req-verify/SKILL.md              # 校验测试
└── req-amend/SKILL.md               # 需求变更流程
```
