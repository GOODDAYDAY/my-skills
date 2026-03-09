---
name: req-5-verify
description: 校验测试：编译检查、运行检查、自动化测试
argument-hint: "[REQ-xxx]"
---

你负责校验测试阶段。确保代码能编译、能运行、能通过测试。

## 前置条件

- `$ARGUMENTS` 传入 REQ 编号
- 代码开发已完成

## 流程

### 第一步：识别项目类型

读取 `requirements/REQ-xxx-*/technical.md`，确定技术栈和构建方式。

### 第二步：编译检查

根据技术栈执行编译：

| 技术栈 | 命令 |
|:---|:---|
| Python | `python -m py_compile <files>` 或 `mypy <package>` |
| Java (Maven) | `mvn compile` |
| Java (Gradle) | `gradle build` |
| TypeScript | `tsc --noEmit` |
| Go | `go build ./...` |

编译必须通过，如有错误则修复后重试。

### 第三步：运行检查

尝试运行项目的入口程序，确保能正常启动：
- 如果是 CLI 工具，执行 `--help` 或简单命令
- 如果是 Web 服务，启动后检查健康检查端点
- 如果是库，尝试 import/加载

### 第四步：自动化测试

1. 检查是否已有测试文件
2. 如果没有，**根据需求文档的验收标准生成测试用例**
3. **Web 项目特殊要求**：使用 Python + Playwright 进行端到端测试
   - 测试脚本放在 `tests/e2e/` 目录下
   - 根据需求文档的功能点和验收标准设计测试流程
   - 不仅测试 UI 交互（点击、输入、页面跳转）
   - 还要测试数据流转（提交数据后验证数据库/API 返回是否正确）
   - 测试文件命名：`test_e2e_<功能模块>.py`
4. 单元测试/集成测试：

| 技术栈 | 命令 |
|:---|:---|
| Python | `pytest tests/ -v` |
| Java (Maven) | `mvn test` |
| Java (Gradle) | `gradle test` |
| TypeScript | `npm test` |
| Go | `go test ./...` |

5. 所有测试必须通过

### 第五步：生成/更新自动化脚本

将所有校验命令生成为 `scripts/` 目录下的 `.bat` 文件：

- `scripts/build.bat` — 编译构建
- `scripts/test.bat` — 运行所有测试（单元 + 集成）
- `scripts/test-e2e.bat` — 运行端到端测试（Web 项目）
- `scripts/run.bat` — 启动运行

如果脚本已存在，检查是否需要更新。每个脚本要包含注释说明用途。

### 第六步：输出报告

```markdown
## 校验报告

- 编译检查：通过/失败
- 运行检查：通过/失败
- 单元/集成测试：X/Y 通过
- 端到端测试：X/Y 通过（Web 项目）

### 自动化脚本
- scripts/build.bat ✓
- scripts/test.bat ✓
- scripts/run.bat ✓

### 问题清单（如有）
1. ...
```

全部通过后，告知用户可以进入归档阶段。
