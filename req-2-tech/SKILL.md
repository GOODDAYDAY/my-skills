---
name: req-2-tech
description: Technical design — create technical specification based on finalized requirements
argument-hint: "[REQ-xxx]"
---

# req-2-tech — 技术设计
> Version: v2 | Date: 2026-04-02 | Author: system

## 1. 角色定义
你负责技术设计阶段，基于已确认的需求文档编写技术规范。

```mermaid
flowchart LR
    A[requirement.md\nFinalized] --> B[Diverge: multi-agent design]
    B --> C[Converge: user selects direction]
    C --> D[Write technical.md]
    D --> E[Generate diagrams]
    E --> F[User review loop]
    F --> G[Status: Technical Finalized]
```
**Figure 1.1 — req-2-tech stage overview**

## 2. 总体流程

```mermaid
flowchart TD
    A([Start]) --> B{Prerequisites\nmet?}
    B -->|No| C[Prompt user:\ncomplete req analysis first]
    B -->|Yes| D{technical.md\nalready exists?}
    D -->|Yes, incomplete| E[Show existing content\nAsk: continue or restart?]
    D -->|No| F[Read requirement.md]
    E --> F
    F --> G[Diverge: A+B+C design]
    G --> H[Converge: present synthesis]
    H --> I{User\nselects direction?}
    I -->|Revise| G
    I -->|Selected| J[Write technical.md]
    J --> K[Generate PlantUML Diagrams]
    K --> L[Present to User]
    L --> M{User\nApproved?}
    M -->|Revise| J
    M -->|Approved| N[Finalize technical.md]
    N --> O[Update index.md]
    O --> P[Commit & Tag]
    P --> E2([Done])
```
**Figure 2.1 — Technical design flow: read requirement → diverge → converge → write → finalize**

## 3. 前置条件

```mermaid
flowchart LR
    A[$ARGUMENTS\nREQ-xxx] --> B{requirement.md\nexists and Finalized?}
    B -- No --> C[Prompt user:\ncomplete req-1-analyze first]
    B -- Yes --> D{technical.md\nalready exists?}
    D -- Yes incomplete --> E[Show content\nask continue or restart]
    D -- No --> F[Proceed to diverge analysis]
```
**Figure 3.1 — Prerequisites check flow**

### 3.1 输入验证
- `$ARGUMENTS` 提供 REQ 编号（如 REQ-001）
- 对应的 `requirements/REQ-xxx-*/requirement.md` 必须存在且状态为 `Requirement Finalized`
- 若不满足，提示用户先完成需求分析阶段

### 3.2 断点恢复
读取 `${CLAUDE_SKILL_DIR}/../_shared/recovery.md` 获取恢复规范。
若 `technical.md` 已存在且状态为 `Technical Design`（非已确认）：
- 读取现有内容并展示给用户
- 询问是否继续完善还是重新开始

## 4. 步骤详解

```mermaid
flowchart TD
    A[4.1 Read requirement.md] --> B[4.2 Diverge: A+B+C design]
    B --> C[4.3 Converge: user selects direction]
    C --> D[4.4 Write technical.md]
    D --> E[4.5 Generate diagrams]
    E --> F[4.6 User review loop]
    F --> G[4.7 Finalize: status Technical Finalized]
    G --> H[4.8 Commit and tag]
```
**Figure 4.1 — Technical design step sequence**

### 4.1 读取需求文档
读取对应的 `requirement.md`，理解所有功能和验收标准。

### 4.2 发散设计（Diverge）

读取 `${CLAUDE_SKILL_DIR}/../_shared/diverge-converge.md` 获取完整模式规范（角色定义、Round 3 消息传递模型、实现约束）。

通过 `Agent` tool 启动三轮 subagent 分析：

**Round 1（并行）**：同时启动 Agent A 和 Agent B：
- **Agent A（简单直接）**：模块数 ≤ 3，最少依赖，不考虑扩展，能跑就行
- **Agent B（可扩展）**：分层/模块化，考虑 10x 规模，接口清晰

**Round 2（顺序）**：启动 Agent C，读取 A+B 完整输出：
- **Agent C（核心矛盾）**：指出"两种架构在哪个关键决策上产生了分歧（如数据耦合 / 部署复杂度 / 团队能力匹配）"，给出判断，必须具体命名矛盾点

**Round 3（并行）**：同时启动 Agent A v2 和 Agent B v2（新实例），各自 prompt 按 `diverge-converge.md` 规范包含 Round 1 双方方案 + C 的质疑全文 + 回应任务。

### 4.3 汇总与用户选择（Converge）

主 agent 整理三轮输出，按 `diverge-converge.md` Synthesis 格式呈现：

1. **三方立场速览**（各一句话）
2. **核心矛盾点**（C 指出的具体分歧）
3. **对比表**

| 维度 | Agent A（简单直接）| Agent B（可扩展）|
|:---|:---|:---|
| 模块数 | | |
| 复杂度 | | |
| 可维护性 | | |
| 适用场景 | | |
| 安全设计 | | |
| 可测试性 | | |
| 代码整洁度 | | |

4. **推荐方向**（基于上下文判断）

**等待用户选择**：选 A / 选 B / 描述融合方式。用户选定后，以所选方向作为编写 technical.md 的基础。

### 4.4 编写技术规范
通过 `Skill` tool 调用 `write-doc`，传入以下信息：
- 使用下方嵌入模板作为文档结构
- 将 diverge/converge 阶段选定的技术方案填入各章节
- 保存路径：与 `requirement.md` 同目录下的 `technical.md`

模板：

```markdown
# REQ-xxx Technical Design

> Status: Technical Design
> Requirement: requirement.md
> Created: <date>
> Updated: <date>

## 1. Technology Stack

| Module | Technology | Rationale |
|:---|:---|:---|

## 2. Design Principles

- High cohesion, low coupling: single responsibility per module, communicate via clear interfaces
- Reuse first: extract shared logic into independent modules, avoid duplication
- Testability: key logic must be independently testable

## 3. Architecture Overview

(attach architecture diagram)

Note: source code must NOT be placed directly under project root `src/`. Must be organized in sub-layers:
- `backend/` — backend services
- `frontend/` — frontend application
- `app/` — mobile/desktop
- `shared/` — shared modules (for cross-module reuse)

## 4. Module Design

### 4.1 <Module 1>
- Responsibility:
- Public interface:
- Internal structure:
- Reuse notes: which components/logic can be reused by other modules

### 4.2 <Module 2>
...

## 5. Data Model

(attach ER diagram or class diagram if applicable)

## 6. API Design

(list API endpoints if applicable)

## 7. Key Flows

(attach sequence diagrams)

## 8. Shared Modules & Reuse Strategy

Explicitly list which components/utilities/logic are shared, and how they are referenced by each module.

## 9. Risks & Notes

## 10. Change Log

| Version | Date | Changes | Affected Scope | Reason |
|:---|:---|:---|:---|:---|
| v1 | <date> | Initial version | ALL | - |
```

**注意：章节标题和结构性字段必须使用英文。描述性内容可使用中文。**

变更日志格式与规则见 `${CLAUDE_SKILL_DIR}/../_shared/changelog.md`。`Affected Scope` 列必须准确填写（如 Module 4.1、API 6.2）。

### 4.5 生成图表

```mermaid
flowchart LR
    A[Read plantuml.md] --> B[Architecture Diagram\ntech-architecture.puml]
    B --> C[Sequence Diagram\ntech-sequence.puml]
    C --> D{Database\ninvolved?}
    D -->|Yes| E[ER Diagram\ntech-er.puml]
    D -->|No| F{Core classes\nneeded?}
    E --> G[Class Diagram\ntech-class.puml]
    F -->|Yes| G
    F -->|No| H[Convert to SVG]
    G --> H
    H --> I([Done])
```
**Figure 4.5 — PlantUML diagram generation decision tree**

读取 `${CLAUDE_SKILL_DIR}/../_shared/plantuml.md` 获取完整 PlantUML 规范（环境检测、语法、SVG 转换）。严格遵循该流程。
按需生成以下图表（至少 1-2 张）：
- **架构图**（组件）：`tech-architecture.puml`
- **时序图**：`tech-sequence.puml`（关键流程）
- **类图**：`tech-class.puml`（数据模型/核心类）
- **ER 图**：`tech-er.puml`（若涉及数据库）

### 4.6 用户审查
展示技术规范摘要并**等待用户确认**：
- 重点关注技术栈、架构设计和模块复用策略
- 用户可要求调整
- 循环直到用户批准

### 4.7 最终确认
用户批准后：
1. 将 `technical.md` 状态更新为 `Technical Finalized`
2. 读取 `${CLAUDE_SKILL_DIR}/../_shared/status.md` 获取状态规范，将 `requirements/index.md` 状态更新为 `Technical Finalized`

### 4.8 提交与标签

```bash
git add -A && git commit -m "docs(REQ-xxx): technical design complete"
git tag REQ-xxx-designed
```
