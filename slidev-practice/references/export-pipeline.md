---
name: export-pipeline
description: Slidev 导出机制原理——Playwright 截图式导出、body 背景不可见的根因、PPTX v-click 展开、验证方法
---

# 导出管线

## 1. 导出的统一原理

Slidev 的所有导出（PDF、PPTX、PNG）基于同一机制：**Playwright 自动化浏览器截图**。

```
slidev export
  ↓
启动内部 Vite dev server (临时端口)
  ↓
启动 Playwright Chromium (headless)
  ↓
遍历每一页:
  1. 导航到 /{page}?print
  2. 等待 networkidle (所有资源加载完成)
  3. 遍历每个 v-click 步骤:
     a. 触发下一个 v-click
     b. 等待动画完成
     c. 截取元素快照
  ↓
合并为最终文件
```

## 2. body 背景不可见的根因

导出截图不是 `page.screenshot()`（全页截图），而是 `.slidev-slide-container` 元素的截图。

```
                    截图 bounding box
                    ┌───────────────┐
body 背景 ──────── │               │ ←── body 在 box 之外
                    │ slide-container│
                    │               │ ←── 只截取这个区域
                    └───────────────┘
```

`document.body.style.background` 设置的背景在 body 元素上，而截图的是 body 的**子元素**。子元素截图不包含父元素。

**解法**：在 slide-container 内部放一个带背景的渲染 div（详见 gradient-system.md）。

## 3. PDF 导出

**命令**：`slidev export` 或 `pnpm run export`

**前置条件**：
- `pnpm add -D playwright-chromium`
- 网络连接（加载 Google Fonts 等远程资源）
- dev server 不需要手动启动（export 命令自带）

**输出**：`slides-export.pdf`

**v-click 处理**：每个 v-click 步骤生成独立的 PDF 页。一个有 5 个 v-click 的幻灯片生成 6 页。使用 `--per-slide` 参数可以只输出每页的最终状态。

**典型大小**：30 页演示 ≈ 3-5 MB

## 4. PPTX 导出

**命令**：`slidev export --format pptx`

**原理**：每个截图作为 PPTX 页面的全幅背景图片（PICTURE 类型）。

**关键特征**：

| 特征 | 值 |
|:-----|:---|
| 页数 | 远大于源文件（v-click 展开） |
| 每页内容 | 一张 PNG 截图 |
| 可编辑性 | 否（图片，不是文字和形状） |
| 文件大小 | 很大（50-100 MB，全幅 PNG） |
| 背景 | 需要渲染 div 方案 |

**PPTX 背景验证方法**：

用 python-pptx 检查每页背景图片大小：

```python
from pptx import Presentation
from pptx.util import Inches

prs = Presentation('slides-export.pptx')
for i, slide in enumerate(prs.slides):
    for shape in slide.shapes:
        if hasattr(shape, 'image'):
            blob_size = len(shape.image.blob)
            print(f"Slide {i+1}: bg image = {blob_size} bytes")
```

正常值：每页 > 100KB（通常 300KB-1MB）。
如果只有几百字节 → 透明 PNG → body 背景未被捕获。

## 5. PNG 导出

**命令**：`slidev export --format png`

逐页生成独立的 PNG 文件。适合需要将幻灯片嵌入其他文档的场景。

## 6. 导出前检查清单

1. 确认 `playwright-chromium` 已安装
2. 确认网络连接正常（字体加载）
3. 确认 global-bottom.vue 有渲染 div（导出背景可见性）
4. 确认所有 v-click 动画序列正确
5. 确认无 JavaScript 控制台错误

## 7. 常见导出问题

| 问题 | 原因 | 解决 |
|:-----|:-----|:-----|
| 背景全黑/无渐变 | body 背景不在截图范围 | 添加渲染 div |
| 字体显示异常 | Google Fonts 未加载完成 | 确认网络连接 |
| v-click 展开过多 | 每个 v-click 生成独立页 | 使用 `--per-slide` |
| PPTX 文件过大 | 全幅 PNG 截图 | 正常现象，减少 v-click 数量 |
| 导出报错 browser | playwright-chromium 未安装 | `pnpm add -D playwright-chromium` |
