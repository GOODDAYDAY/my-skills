---
name: context-management
description: 大文件 Slidev 项目中 AI context window 的压力管理——精确定位、减少冗余读取、验证策略
---

# Context 管理

## 1. 问题背景

Slidev 项目的 slides.md 通常有 500-1500+ 行。在长会话中，每次 Read + Edit 都消耗 context 空间：

| 操作 | 大约 token 消耗 |
|:-----|:--------------|
| Read 全文 (1300 行) | ~6000 tokens |
| Edit (old+new) | ~500 tokens |
| browser_screenshot | ~1000 tokens |
| browser_snapshot | ~300 tokens |

如果工作模式是"Read 全文 → 编辑 → Read 全文验证"，每个修改消耗 ~12000 tokens。10 次修改就是 120000 tokens。

## 2. 优化策略

### 2.1 精确定位读取

不要每次都 Read 整个 slides.md。先定位需要修改的区域：

```
# 方法 1: Grep 定位关键词
Grep "v-click" → 找到所有 v-click 的行号
Read slides.md offset=340 limit=50 → 只读需要修改的区域

# 方法 2: 记住上次编辑的行号范围
上次编辑了 slide 13 (约 430-470 行)
Read slides.md offset=425 limit=50
```

### 2.2 减少验证读取

修改后不需要重新 Read 文件来验证。用 Playwright 替代：

```
# 低效方式
Edit slides.md → Read slides.md 验证文本 → browser_screenshot 验证视觉

# 高效方式
Edit slides.md → browser_snapshot 验证内容 + 结构
# 只在必要时 browser_screenshot
```

### 2.3 批量修改合并

如果多个修改在同一区域，合并为一次 Read + 多次 Edit：

```
# 低效方式
Read → Edit 修改 1 → Read → Edit 修改 2 → Read → Edit 修改 3

# 高效方式
Read → Edit 修改 1 → Edit 修改 2 → Edit 修改 3 → browser_snapshot 验证
```

### 2.4 利用 Grep 替代 Read

当只需要确认某个内容是否存在或在哪个位置时，Grep 比 Read 高效得多：

```
# 低效：读取全文搜索
Read slides.md → 在 6000 tokens 中找 "transition: fade"

# 高效：直接搜索
Grep "transition: fade" slides.md → 返回行号和匹配行
```

## 3. global-bottom.vue 的 context 友好性

global-bottom.vue 通常只有 50-80 行，每次 Read 只消耗 ~300 tokens。可以随时 Read 而不用担心 context 压力。

相比之下 slides.md 的 Read 消耗是 global-bottom.vue 的 20 倍。**把稳定的配置放在 global-bottom.vue 中，把频繁变化的内容放在 slides.md 中**。

## 4. 长会话管理

### 4.1 context 压缩感知

Claude Code 会在接近 context 限制时自动压缩早期消息。压缩后：
- 早期 Read 的文件内容被总结
- 需要再次读取才能精确编辑
- 修改历史被浓缩

**策略**：不要依赖"之前读过"的内容。每次编辑前确认当前状态。

### 4.2 Agent 并行

对于独立的探索任务，使用 Agent 工具派出子代理。子代理有独立的 context，不占用主 context：

```
# 主 context 中
Agent("检查 dist/ 目录大小和结构")
Agent("用 python-pptx 分析 PPTX 背景")
# 两个子代理并行执行，结果摘要返回主 context
```

### 4.3 关键信息记录

在编辑过程中，主动记录关键信息（如行号范围、页码映射），避免后续重复读取：

```
已知信息：
- slide 13 在 slides.md 的 430-470 行
- backgrounds map 在 global-bottom.vue 的 11-32 行
- v-click 总计 23 处
```
