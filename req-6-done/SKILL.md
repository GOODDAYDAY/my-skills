---
name: req-6-done
description: 归档完成：更新文档状态，标记需求为已完成
argument-hint: "[REQ-xxx]"
---

你负责归档阶段。将需求标记为已完成。

## 前置条件

- `$ARGUMENTS` 传入 REQ 编号
- 校验测试阶段已通过

## 流程

### 第一步：更新需求文档状态

修改 `requirements/REQ-xxx-*/requirement.md`：
- 将状态改为"已完成"
- 更新"最后更新"日期

### 第二步：更新技术文档状态

修改 `requirements/REQ-xxx-*/technical.md`：
- 将状态改为"已完成"
- 更新"最后更新"日期

### 第三步：更新索引

修改 `requirements/index.md`：
- 将该需求的状态改为"已完成"
- 更新时间

### 第四步：输出总结

```markdown
## REQ-xxx <名称> 已完成

- 需求文档：已归档
- 技术文档：已归档
- 代码：已实现并通过校验
- 完成时间：<日期>
```
