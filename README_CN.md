# my-skills

个人 Claude Code Skills 仓库。一套完整的需求驱动开发工作流——从需求分析到最终交付。

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

核心工作流是 `/req`，编排完整的开发周期，共 8 个阶段：

```
/req "功能描述"
  │
  ├─ 阶段 1：需求分析 ──────→ requirement.md + 配图        [tag: REQ-xxx-analyzed]
  │    ↓（需要用户确认）
  ├─ 阶段 2：技术设计 ──────→ technical.md + 配图          [tag: REQ-xxx-designed]
  │    ↓（需要用户确认）
  ├─ 阶段 3：编码开发 ──────→ 源代码 + scripts/            [tag: REQ-xxx-coded]
  │    ↓                        （测试前置，按模块提交）
  ├─ 阶段 4：安全审查 ──────→ 漏洞扫描 + 修复              [tag: REQ-xxx-security]
  │    ↓
  ├─ 阶段 5：代码精简 ──────→ 结构优化（不改业务逻辑）     [tag: REQ-xxx-cleaned]
  │    ↓
  ├─ 阶段 6：需求对比 ──────→ 合规检查报告
  │    ↓
  ├─ 阶段 7：校验测试 ──────→ 编译 / 运行 / 测试           [tag: REQ-xxx-verified]
  │    ↓
  └─ 阶段 8：归档完成 ──────→ 一致性检查 + 标记完成
```

每个阶段等待用户确认后才进入下一阶段。也可以单独运行任意阶段。

支持**断点恢复** — 如果中途中断，`/req REQ-xxx` 会自动检测上次停在哪里，从断点继续。

已完成需求积累到一定数量后，`/req-archive` 会批量归档并生成里程碑摘要。

## 命令列表

| 命令 | 说明 |
|:---|:---|
| `/req [描述]` | 全流程编排入口，引导走完 8 个阶段 |
| `/req-1-analyze [描述]` | 需求分析——将简单描述扩展为完整需求文档 |
| `/req-2-tech [REQ-xxx]` | 技术设计——架构、模块、接口、配图 |
| `/req-3-code [REQ-xxx]` | 编码开发——测试前置、模块并行、按模块提交 |
| `/req-4-security [REQ-xxx]` | 安全审查——漏洞扫描，严重/高风险直接修复 |
| `/req-5-cleanup [REQ-xxx]` | 代码精简——删除无用代码、合并重复逻辑（不改业务逻辑） |
| `/req-6-review [REQ-xxx]` | 需求对比——逐项检查实现是否满足需求 |
| `/req-7-verify [REQ-xxx]` | 校验测试——编译、运行、测试（Playwright 端到端测试跟随项目语言） |
| `/req-8-done [REQ-xxx]` | 归档——一致性检查 + 标记完成，达到阈值时提示批量归档 |
| `/req-archive` | 批量归档已完成需求，生成里程碑摘要文档 |
| `/req-status [REQ-xxx\|archived]` | 状态查询——默认显示进行中需求，传 `archived` 查看历史 |
| `/req-amend [REQ-xxx]` | 需求变更——正式变更流程，避免误改 |
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

`index.md` 分为 **Active** 和 **Archived** 两个区域。`archive-threshold` 注释（默认 5）控制 `/req-8-done` 何时提示运行 `/req-archive`。

## 仓库结构

```
my-skills/
├── _shared/
│   ├── plantuml.md                  # PlantUML 共享规范 + 环境检测
│   ├── status.md                    # 状态枚举、index.md 格式（Active/Archived 分区）
│   ├── changelog.md                 # 变更日志格式与误改检测规则
│   ├── recovery.md                  # 断点恢复模式
│   └── scripts.md                   # 自动化脚本规范
├── create-skill/SKILL.md
├── req/SKILL.md                     # 全流程编排
├── req-1-analyze/SKILL.md           # 需求分析
├── req-2-tech/SKILL.md              # 技术设计
├── req-3-code/                      # 编码开发
│   ├── SKILL.md
│   ├── python.md                    # Python 开发规范
│   └── java.md                      # Java 开发规范
├── req-4-security/SKILL.md          # 安全审查
├── req-5-cleanup/SKILL.md           # 代码精简（不改业务逻辑）
├── req-6-review/SKILL.md            # 需求对比
├── req-7-verify/SKILL.md            # 校验测试
├── req-8-done/SKILL.md              # 归档 + 一致性检查 + 阈值提示
├── req-archive/SKILL.md             # 批量归档 + 里程碑摘要
├── req-status/SKILL.md              # 状态查询（默认显示进行中）
└── req-amend/SKILL.md               # 需求变更流程
```
