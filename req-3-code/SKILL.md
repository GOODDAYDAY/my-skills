---
name: req-3-code
description: 编码开发：参考需求和技术文档进行编码
argument-hint: "[REQ-xxx]"
---

你负责编码开发阶段。严格参考需求文档和技术文档进行开发。

## 前置条件

- `$ARGUMENTS` 传入 REQ 编号
- 对应的 `requirement.md` 和 `technical.md` 必须存在且已定稿
- 如果不满足，提示用户先完成前置阶段

## 流程

### 第一步：阅读文档

1. 读取 `requirements/REQ-xxx-*/requirement.md` — 明确做什么
2. 读取 `requirements/REQ-xxx-*/technical.md` — 明确怎么做

### 第二步：加载语言规范

根据 `technical.md` 中的技术选型，检查 `${CLAUDE_SKILL_DIR}/` 下是否有对应的语言规范文件：

- Python → 读取 `${CLAUDE_SKILL_DIR}/python.md`
- Java → 读取 `${CLAUDE_SKILL_DIR}/java.md`
- 其他 → 如果存在同名 `.md` 则加载，否则使用通用最佳实践

### 第三步：编码

按照技术文档的模块划分，逐模块开发：

1. 先搭建项目结构（如果是新项目）
2. **项目结构规则**：源码不允许直接放在项目根目录的 `src/` 下，必须按模块划分子层目录，如 `backend/`、`frontend/`、`app/`、`shared/` 等，`src/` 只能出现在子层内部
3. 按模块顺序实现功能
4. 每完成一个模块，简要告知用户进度
5. 代码中关键逻辑需要与需求/技术文档对应

### 代码质量要求

- **高内聚低耦合**：模块职责单一，模块间通过清晰接口通信，避免紧耦合
- **复用**：公共逻辑提取为独立模块，避免重复代码
- **日志**：关键操作、异常分支、外部调用必须有日志输出，日志内容用英文
- **注释**：复杂逻辑、业务规则、非直觉代码必须有注释说明意图
- **代码语言**：变量名、函数名、注释、日志信息、commit message 均使用英文
- **中文仅用于**：用户可见的 UI 文案（如需要）

### 第四步：生成自动化脚本

将开发过程中需要重复执行的命令生成为 `scripts/` 目录下的 `.bat` 文件：

- `scripts/build.bat` — 编译/构建
- `scripts/run.bat` — 启动运行
- `scripts/test.bat` — 运行测试
- 其他按需生成

脚本内容要包含必要的注释，说明用途和前置条件。

### 第五步：更新状态

编码完成后，更新 `requirements/index.md` 中状态为"开发完成"。
