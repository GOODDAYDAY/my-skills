# my-skills

个人 Claude Code Skills 仓库。一套**编排器驱动、无状态**的需求开发工作流——编排器每轮都重新观察真实文件系统，推理出当前还缺什么，然后只派发一个子技能执行。**没有固定流水线。**

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

安装后所有 skill 会被 Claude Code 自动发现为斜杠命令。核心理念：

> **两个编排器（`req`、`task`），其他所有都是被编排对象。编排器不按固定顺序执行——它观察、推理、派发。**

### 观察-推理-派发循环

```
/req "功能描述"
   │
   ▼
┌──────────────────────────────────────────────────┐
│ req 编排器                                       │
│                                                  │
│   1. 观察：ls + 读 requirements/REQ-xxx/         │
│   2. 推理：现在缺什么？什么陈旧了？下一步？      │
│   3. 派发：只调用一个子技能                      │
│   4. 子技能执行并返还控制权                      │
│   5. 回到第 1 步重新观察                         │
└──────────────────────────────────────────────────┘
```

每一轮，编排器都**重新**读取 REQ 目录。没有缓存状态，没有 "Next Stage" 表，没有任何持久化状态文件。**文件系统就是唯一真相源**。子技能被禁止指定下一步——它们只做完自己的一件事就把控制权交还给编排器。

这种架构天然支持断点恢复、跳步、回流、amend 级联（下游工件会被下一轮观察自然判定为陈旧）、并行多 REQ 等所有场景。

## 命令列表

### 编排器

| 命令 | 说明 |
|:---|:---|
| `/req [描述 \| REQ-xxx]` | 需求驱动开发编排器，派发下面所有 req 子技能 |
| `/task [描述]` | 通用任务编排器，非需求工作流的扩展点 |

### 需求子技能（由 `/req` 派发）

| 命令 | 说明 |
|:---|:---|
| `/req-analyze [描述]` | 需求分析——将简单描述扩展为完整需求文档 |
| `/req-tech [REQ-xxx]` | 技术设计——基于已定稿的需求写技术方案 |
| `/req-code [REQ-xxx]` | 编码开发——实现源码 + 自动化脚本 + 日志 |
| `/req-security [REQ-xxx]` | 安全审查——严重/高直接修复，中/低汇报 |
| `/req-cleanup [REQ-xxx]` | 代码精简——删除无用/重复/死代码（不改业务逻辑） |
| `/req-review [REQ-xxx]` | 需求对比——逐项核对实现与需求 |
| `/req-verify [REQ-xxx]` | 校验——编译、运行、测试（含 Playwright e2e） |
| `/req-archive [REQ-xxx]` | 归档——一致性检查 + 标记完成 |
| `/req-amend [REQ-xxx]` | 需求变更——对已定稿文档的正式变更流程 |
| `/req-status [REQ-xxx \| all]` | 展示单个或全部需求的**观察态** |

### 其他

| 命令 | 说明 |
|:---|:---|
| `/create-skill [name]` | 创建新 skill 的标准指南 |

虽然每个子技能都有自己的斜杠命令，但**推荐的用法是直接调用 `/req`**，由编排器决定派发谁。子技能之间**绝不**相互跳转。

## 文档结构

所有需求文档统一管理在项目根目录的 `requirements/` 下：

```
requirements/
├── index.md                        # 纯目录索引：ID | Name | Updated | Description（无 Status 列）
├── REQ-001-user-login/
│   ├── requirement.md              # 需求文档（定稿标记写在文档内部）
│   ├── technical.md                # 技术设计文档（定稿标记写在文档内部）
│   ├── *.puml / *.svg              # PlantUML 配图
│   ├── security-review.md          # /req-security 产出
│   ├── cleanup-report.md           # /req-cleanup 产出
│   ├── review-report.md            # /req-review 产出
│   ├── verify-report.md            # /req-verify 产出
│   └── ...
└── REQ-002-data-export/
    └── ...
```

所有工作流的理解都直接来自**这个目录的真实内容**，没有任何外部状态库。

## 仓库结构

```
my-skills/
├── _shared/
│   ├── plantuml.md                  # PlantUML 共享规范 + 环境检测
│   ├── scripts.md                   # 自动化脚本标准（.bat + .sh）
│   └── changelog.md                 # 变更日志格式 + Affected Scope 规则
├── req/SKILL.md                     # 需求编排器（无状态，观察-派发循环）
├── task/SKILL.md                    # 通用任务编排器骨架
├── req-analyze/SKILL.md             # 需求分析子技能
├── req-tech/SKILL.md                # 技术设计子技能
├── req-code/                        # 编码子技能
│   ├── SKILL.md
│   ├── python.md                    # Python 规范
│   └── java.md                      # Java 规范
├── req-security/SKILL.md            # 安全审查子技能
├── req-cleanup/SKILL.md             # 精简子技能（不改业务逻辑）
├── req-review/SKILL.md              # 需求对比子技能
├── req-verify/SKILL.md              # 校验子技能
├── req-archive/SKILL.md             # 归档子技能（终态一致性检查）
├── req-status/SKILL.md              # 观察态展示器
├── req-amend/SKILL.md               # 正式变更流程
└── create-skill/SKILL.md
```

## 设计要点

- **没有状态枚举，没有 Status 列**。定稿标记写在文档内部（例如"Approved by user on <date>"），编排器直接读文档。
- **子技能禁止提及"下一步"**。子技能不能引用任何兄弟技能名，也不能暗示下一步是谁。做完就以一句 handoff 结束。
- **没有谓词缓存文件**。谓词只是推理时的速记，不是持久化的数据结构。
- **Amend 就是一次普通派发**。需求被变更后，编排器下一轮重新观察就会发现下游技术/代码/测试已经陈旧——不需要任何"失效"结构。
