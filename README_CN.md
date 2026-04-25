# my-skills

个人 Claude Code Skills 仓库。采用 **编排器驱动**、**无状态** 的需求工作流 — 编排器每轮读取真实文件系统状态，判断还缺少什么，然后调度恰好一个子 skill 去完成。没有固定的流水线。

[English](./README.md) · [演进历史](./docs/evolution.md)

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

核心工作流是 `/req`，它采用 **观察-推理-调度** 循环来驱动开发：

```mermaid
flowchart LR
    O[观察文件系统] --> R[推理当前状态]
    R --> D[调度一个子 skill]
    D --> O
```

**编排器循环：** 观察 → 推理 → 调度 → 观察

与硬编码的阶段序列不同，编排器读取 `requirements/`，检查缺少什么，然后调用恰好正确的子 skill 来填补缺口。每个子 skill 声明自己的 `applicable_when` 条件 — 编排器仅遵循契约。

可调度的子 skill：

| 子 skill | 触发条件 |
|:---|:---|
| `req-analyze` | 尚不存在 `requirement.md` |
| `req-tech` | `requirement.md` 存在但无 `technical.md` |
| `req-code` | 设计已批准但代码未编写 |
| `req-security` | 代码已存在但未做安全审查 |
| `req-cleanup` | 安全问题已修复，代码需要结构优化 |
| `req-review` | 实现完成，需要需求合规检查 |
| `req-verify` | 前面阶段完成，需要编译/运行/测试验证 |
| `req-done` | 全部验证通过，准备归档 |

这种设计使工作流对**中断具有弹性** — 如果中途停止，`/req REQ-xxx` 会自动从中断处继续。

## 命令列表

| 命令 | 说明 |
|:---|:---|
| `/req [描述]` | 全周期编排入口 — 观察状态并调度子 skill |
| `/req-analyze [描述]` | 需求分析——将简单描述扩展为完整需求文档 |
| `/req-tech [REQ-xxx]` | 技术设计——架构、模块、接口、配图 |
| `/req-code [REQ-xxx]` | 编码开发——测试前置、模块并行、按模块提交 |
| `/req-security [REQ-xxx]` | 安全审查——漏洞扫描，严重/高风险直接修复 |
| `/req-cleanup [REQ-xxx]` | 代码精简——删除无用代码、合并重复逻辑（不改业务逻辑） |
| `/req-review [REQ-xxx]` | 需求对比——逐项检查实现是否满足需求 |
| `/req-verify [REQ-xxx]` | 校验测试——编译、运行、测试 |
| `/req-done [REQ-xxx]` | 归档——一致性检查 + 标记完成 |
| `/req-archive` | 批量归档已完成需求，生成里程碑摘要文档 |
| `/req-status [REQ-xxx\|archived]` | 状态查询——默认显示进行中需求，传 `archived` 查看历史 |
| `/req-amend [REQ-xxx]` | 需求变更——正式变更流程，避免误改 |
| `/puml2svg <file.puml>` | 将 PlantUML 图档转换为 SVG |
| `/create-skill [name]` | 创建新 skill 的标准指南 |

## 文档结构

所有需求文档统一管理在项目根目录的 `requirements/` 下：

```
requirements/
├── index.md                        # 进行中需求（全英文）；含归档阈值配置
├── REQ-001-user-login/             # 进行中需求目录
│   ├── requirement.md              # 需求文档
│   ├── technical.md                # 技术设计文档
│   ├── *.puml / *.svg              # PlantUML 配图
│   └── ...
└── archive/
    ├── milestone-2026-03-31.md     # 里程碑摘要（交付内容、共用模块、技术决策）
    └── REQ-001-user-login/         # 已归档需求目录（由 /req-archive 迁移）
```

`index.md` 分为 **Active** 和 **Archived** 两个区域。`archive-threshold` 注释（默认 5）控制 `/req-done` 何时提示运行 `/req-archive`。

## 仓库结构

```
my-skills/
├── _shared/
│   ├── changelog.md                # 变更日志格式与误改检测规则
│   ├── diverge-converge.md         # 多智能体分析模式
│   ├── git-commit.md               # 提交信息规范
│   ├── markdown.md                 # Markdown 格式规范
│   ├── plantuml.md                 # PlantUML 共享规范 + 环境检测
│   ├── recovery.md                 # 断点恢复模式
│   ├── scripts.md                  # 自动化脚本规范
│   ├── scripts/
│   │   ├── install-puml2svg.bat    # PlantUML SVG 转换器安装脚本（Windows）
│   │   └── install-puml2svg.sh     # PlantUML SVG 转换器安装脚本（Unix）
│   └── status.md                   # 状态枚举和 index.md 格式
├── create-skill/SKILL.md
├── puml2svg/SKILL.md               # PlantUML → SVG 转换
├── req/SKILL.md                    # 编排器（观察-推理-调度）
├── req-analyze/SKILL.md            # 需求分析
├── req-tech/SKILL.md               # 技术设计
├── req-code/                       # 编码开发
│   ├── SKILL.md
│   ├── python.md                   # Python 开发规范
│   └── java.md                     # Java 开发规范
├── req-security/SKILL.md           # 安全审查
├── req-cleanup/SKILL.md            # 代码精简（不改业务逻辑）
├── req-review/SKILL.md             # 需求对比
├── req-verify/SKILL.md             # 校验测试
├── req-done/SKILL.md               # 归档 + 一致性检查
├── req-archive/SKILL.md            # 批量归档 + 里程碑摘要
├── req-status/SKILL.md             # 状态查询（默认显示进行中）
├── req-amend/SKILL.md              # 需求变更流程
├── task/SKILL.md                   # 通用编排器
└── write-doc/SKILL.md              # 文档生成 skill
```
