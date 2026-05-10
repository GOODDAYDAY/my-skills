# my-skills

个人 Claude Code Skills 仓库——一套让 AI 真正理解你项目的工作流体系。为独立开发者设计。

[English](./README.md)

## 我为什么要做这个

最开始，我用的是编号列表记需求。没过几天就过时了，改也懒得改，最后变成摆设。

后来进化到了 User Story + Given/When/Then 的格式。需求确实好读了，验收标准也可测了。但 AI 还是**不懂**我的项目。每次开新会话、每次跑 `/req`、每次改代码——AI 都是从零开始读文件，重新构建一个它已经构建过一百遍又丢弃了的心理模型。

问题不在怎么写需求。问题在于，**需求和 AI 的上下文之间，缺了一层持久化的、AI 可消费的项目知识。**

这就是这个项目要解决的问题。

## 核心思路：双层结构，始终同步

```
requirements/                              .claude/skills/project-description-skills/
├── index.md          (领域索引)            ├── SKILL.md          (入口)
├── architecture.md   (技术决策)            └── {domain}.md       (各领域知识)
└── {domain}/
    ├── README.md     (这个领域做什么)
    └── {scenario}.md  (具体用户故事)
    
    ↑  人写的源文档                          ↑  AI 读的桥梁，从源文档生成
```

**`requirements/`** 是给人看的。你在里面思考、规划、写清楚要做什么。这是唯一的事实来源。

**`project-description-skills/`** 是给 AI 看的。它是一个生成的技能，编码了你的项目结构、修改方式、代码模式、常见陷阱。加载后，AI 就有了持久的项目认知，不用每次都重读整个代码库。

两层共享同一套领域划分。改了一边，另一边可以全量或增量刷新。

## 自我增强的循环

```
/req "做一个登录系统"
  │
  ├─ 加载 project-description-skills ──→ AI 了解现有领域、模式、陷阱
  ├─ 读取 requirements/{auth}/ ────────→ 当前领域的需求文档
  ├─ analyze → tech → code → review → verify
  │
  └─ 流水线结束后：刷新 auth 领域的 project-description-skills
       └─ 下次 AI 再来，它已经"认识"登录系统了
```

每次跑完流水线，**项目都比之前更"聪明"了一点**。知识跨会话累积。AI 不再从零开始。

## 命令列表

| 命令 | 做什么 |
|:---|:---|
| `/req [描述]` | 全流程开发流水线——自动分类任务，跑相关阶段（analyze → tech → code → security → cleanup → review → verify → justify） |
| `/req-amend [domain/scenario]` | 修改已有需求——划定变更范围，分析级联影响 |
| `/req-refresh [--forward-only\|--reverse-only]` | 批量刷新领域文档以匹配当前代码（正向：代码→文档，反向：文档→代码验证） |
| `/req-catalog [force]` | 重新生成 `requirements/CATALOG.md`——包含完整架构的项目知识索引 |
| `/req-domain-skills-generate [--all\|domain\|--incremental]` | 生成/刷新 AI 知识桥梁——全量、单域、或根据 git diff 增量 |

## 设计原则

**单人可维护。** 所有东西都支持全量和增量。一个人维护项目不可能全职写文档——工具要替你分担这个成本。

**基于工件的断点恢复。** 如果会话中途崩溃，`/req` 会检查已有的文档、代码、测试来推断上次停在哪里，从断点继续。

**自适应深度。** 改个变量名？直接干，不走流程。加个功能？跑几个关键阶段。跨系统重构？完整流程。不为小事交仪式税。

**写一次，处处同步。** 需求是唯一事实来源。`project-description-skills` 是派生的，永远不手动编辑。代码跑偏了，`req-refresh` 负责校准。

## 文档结构

```
requirements/
├── index.md                        # 领域目录
├── architecture.md                 # 技术哲学、原则、架构决策
├── CATALOG.md                      # 自动生成的项目知识索引
└── {domain}/
    ├── README.md                   # 领域概述 + 简单场景内联
    └── {scenario}.md               # 复杂场景独立文件

.claude/skills/
└── project-description-skills/     # 由 req-domain-skills-generate 生成
    ├── SKILL.md                    # 入口——领域索引、架构概览、使用指南
    └── {domain}.md                 # 各领域：API、模式、陷阱、各阶段 hooks
```

## 仓库结构

```
my-skills/
├── _shared/                        # 共享规范（图表、markdown、git、脚本、恢复）
├── req/                            # 流水线编排器（全部 9 个阶段 + 语言编码规范）
├── req-amend/                      # 需求变更流程
├── req-catalog/                    # 目录生成
├── req-refresh/                    # 领域文档批量刷新（正向 + 反向 + 修复）
├── req-domain-skills-generate/     # AI 知识桥梁生成器
├── write-blog/                     # 中英双语 Hugo 博客生成
├── write-doc/                      # 结构化技术文档编写
├── slidev-practice/                # Slidev 演示文稿实战经验
└── create-skill/                   # 新技能创建指南
```

## 安装

```bash
# 添加到你的项目
git submodule add git@github.com:GOODDAYDAY/my-skills.git .claude/skills

# 克隆已包含此 submodule 的项目
git clone --recurse-submodules <你的项目仓库>

# 更新到最新版本
git submodule update --remote .claude/skills
```
