# my-skills

个人 Claude Code Skills 仓库。一套完整的需求驱动开发工作流——从需求分析到最终交付。

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

核心工作流是 `/req`，编排完整的开发周期，共 6 个阶段：

```
/req "功能描述"
  │
  ├─ 阶段 1：需求分析 ──────→ requirement.md + 配图
  │    ↓（需要用户确认）
  ├─ 阶段 2：技术设计 ──────→ technical.md + 配图
  │    ↓（需要用户确认）
  ├─ 阶段 3：编码开发 ──────→ 源代码 + scripts/
  │    ↓
  ├─ 阶段 4：需求对比 ──────→ 合规检查报告
  │    ↓
  ├─ 阶段 5：校验测试 ──────→ 编译 / 运行 / 测试
  │    ↓
  └─ 阶段 6：归档完成 ──────→ 一致性检查 + 标记完成
```

每个阶段等待用户确认后才进入下一阶段。也可以单独运行任意阶段。

支持**断点恢复** — 如果中途中断，`/req REQ-xxx` 会自动检测上次停在哪里，从断点继续。

## 命令列表

| 命令 | 说明 |
|:---|:---|
| `/req [描述]` | 全流程编排入口，引导走完 6 个阶段 |
| `/req-1-analyze [描述]` | 需求分析——将简单描述扩展为完整需求文档 |
| `/req-2-tech [REQ-xxx]` | 技术设计——架构、模块、接口、配图 |
| `/req-3-code [REQ-xxx]` | 编码开发——自动加载对应语言规范 |
| `/req-4-review [REQ-xxx]` | 需求对比——逐项检查实现是否满足需求 |
| `/req-5-verify [REQ-xxx]` | 校验测试——编译、运行、测试（Web 项目含 Playwright 端到端测试） |
| `/req-6-done [REQ-xxx]` | 归档——一致性检查 + 标记为已完成 |
| `/req-status [REQ-xxx\|all]` | 状态查询——快速查看单个或全部需求状态 |
| `/req-amend [REQ-xxx]` | 需求变更——正式变更流程，避免误改 |
| `/create-skill [name]` | 创建新 skill 的标准指南 |

## 文档结构

所有需求文档统一管理在项目根目录的 `requirements/` 下：

```
requirements/
├── index.md                        # 需求索引与状态跟踪（全英文）
├── REQ-001-user-login/
│   ├── requirement.md              # 需求文档
│   ├── technical.md                # 技术设计文档
│   ├── *.puml / *.svg              # PlantUML 配图
│   └── ...
└── REQ-002-data-export/
    └── ...
```

## 仓库结构

```
my-skills/
├── _shared/plantuml.md              # PlantUML 共享规范 + 环境检测
├── create-skill/SKILL.md
├── req/SKILL.md                     # 全流程编排
├── req-1-analyze/SKILL.md           # 需求分析
├── req-2-tech/SKILL.md              # 技术设计
├── req-3-code/                      # 编码开发
│   ├── SKILL.md
│   ├── python.md                    # Python 开发规范
│   └── java.md                      # Java 开发规范
├── req-4-review/SKILL.md            # 需求对比
├── req-5-verify/SKILL.md            # 校验测试
├── req-6-done/SKILL.md              # 归档 + 一致性检查
├── req-status/SKILL.md              # 状态查询
└── req-amend/SKILL.md               # 需求变更流程
```
