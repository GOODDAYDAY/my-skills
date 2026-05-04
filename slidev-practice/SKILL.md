---
name: slidev-practice
description: Practical experience guide for building Slidev presentations with AI — covers CSS specificity battles, v-click layout traps, export pipelines, gradient systems, Playwright verification workflow, and single-file delivery strategies
---

# Slidev 实战经验指南


## 1. 角色

你已经知道怎么用 Slidev（参考 `slidev` skill）。这份文档解决的是**实战中的原理性问题**——那些文档不会告诉你、只有踩过坑才知道的东西。

## 2. 何时使用

- 构建超过 10 页的 Slidev 演示文稿
- 需要自定义背景、全局层、导出交付
- 遇到 CSS 不生效、导出背景丢失、布局错位等问题
- 需要生成单文件可交互 HTML

## 3. 核心原理速查

### 3.1 Slidev 的 DOM 层级（所有 CSS 问题的根源）

Slidev 的 DOM 是**多层嵌套**的。每一层都可能设置 `background`，阻挡下层的渐变。

→ 详见 [dom-layer-model](references/dom-layer-model.md)

### 3.2 v-click 使用 opacity:0 而非 display:none

v-click 隐藏元素仍**占据布局空间**。5 个 v-click 的页面，初始状态就已经为 5 个不可见元素分配了空间。`flex items-center` 的居中会被严重影响。

→ 详见 [vclick-layout-trap](references/vclick-layout-trap.md)

### 3.3 导出是元素截图，不是页面截图

PDF/PPTX 导出截取的是 `.slidev-slide-container` 元素的 bounding box。`document.body` 上的背景**不在截图范围内**。

→ 详见 [export-pipeline](references/export-pipeline.md)

### 3.4 MHTML 是 DOM 快照，不保留 JavaScript 运行时

MHTML 捕获静态 DOM，丢失 Vue 响应式系统、事件监听器、路由状态。生成交互式单文件应使用 monolith。

→ 详见 [single-file-delivery](references/single-file-delivery.md)

### 3.5 Playwright MCP 的 evaluate/run_code_unsafe 运行在浏览器上下文

MCP 沙箱中 `require('fs')` 不可用。需要 Node.js API 时，创建独立脚本通过 Bash 运行。

→ 详见 [playwright-workflow](references/playwright-workflow.md)

## 4. 全局渐变背景系统

要实现每页不同的渐变背景，需要三层防御：

1. **headmatter `<style>`** — 清除已知层背景
2. **JS 注入 `<style>` 标签** — 加载顺序最晚，覆盖框架动态样式
3. **global-bottom.vue 渲染 div** — 确保导出截图可见

→ 详见 [gradient-system](references/gradient-system.md)

## 5. 开发验证工作流

```
修改 slides.md
  ↓ Vite HMR (100-500ms)
browser_navigate 到目标页
  ↓
browser_snapshot 确认 DOM 结构
  ↓
browser_screenshot 确认视觉效果
  ↓
如有 v-click: browser_click 逐步验证
  ↓
效果不对 → 回到修改
效果满意 → 报告用户
```

→ 详见 [playwright-workflow](references/playwright-workflow.md)

## 6. 导出检查清单

| 格式 | 命令 | 验证方式 | 常见问题 |
|:-----|:-----|:---------|:---------|
| PDF | `slidev export` | PDF 阅读器逐页检查 | 字体未加载、背景缺失 |
| PPTX | `slidev export --format pptx` | 检查背景图 > 100KB/页 | body 背景不在截图范围 |
| SPA | `slidev build` | 本地 HTTP 服务验证 | — |
| 单文件 HTML | `slidev build` → monolith | 双击打开测试交互 | 不要用 MHTML |

→ 详见 [export-pipeline](references/export-pipeline.md)

## 7. Slide 编号管理

硬编码页码映射（`backgrounds[7] = ...`）在插入/删除页面时必须手动更新所有后续 key。更好的方案是在 frontmatter 中用 `bgKey` 标识，或使用自定义 layout。

→ 详见 [slide-management](references/slide-management.md)

## 8. 参考文件索引

| 主题 | 文件 | 解决什么问题 |
|:-----|:-----|:-----------|
| DOM 层级与 CSS 特异性 | [dom-layer-model](references/dom-layer-model.md) | 背景不显示、样式被覆盖 |
| v-click 布局陷阱 | [vclick-layout-trap](references/vclick-layout-trap.md) | 内容被挤到顶部、居中失效 |
| 渐变背景系统 | [gradient-system](references/gradient-system.md) | 实现每页不同渐变 + 导出兼容 |
| 导出管线 | [export-pipeline](references/export-pipeline.md) | PDF/PPTX/PNG 导出原理与坑 |
| 单文件交付 | [single-file-delivery](references/single-file-delivery.md) | MHTML vs monolith 原理对比 |
| Playwright 工作流 | [playwright-workflow](references/playwright-workflow.md) | 感知-行动-验证循环 |
| Slide 编号管理 | [slide-management](references/slide-management.md) | 页码硬编码的脆弱性与替代方案 |
| v-mark 标注系统 | [vmark-annotations](references/vmark-annotations.md) | 手绘标注类型、与 v-click 联动 |
| 字体与排版 | [typography](references/typography.md) | 中文字体加载、字体搭配、颜色体系 |
| Context 管理 | [context-management](references/context-management.md) | 大文件编辑的 context 压力优化 |
