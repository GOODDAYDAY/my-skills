---
name: single-file-delivery
description: 单文件交付方案对比——MHTML 的序列化边界、monolith 的资源内联原理、SPA 打包流程
---

# 单文件交付

## 1. 需求场景

将 Slidev 演示文稿打包为单个文件，可离线分享，双击即可打开并交互。

## 2. MHTML 方案（不可交互，不推荐）

### 2.1 原理

MHTML 通过 CDP（Chrome DevTools Protocol）的 `Page.captureSnapshot` 捕获当前 DOM 的静态快照。

### 2.2 生成方法

```javascript
// capture-mhtml.mjs
import { chromium } from 'playwright-chromium';
import { writeFileSync } from 'fs';

const browser = await chromium.launch();
const page = await browser.newPage();
await page.goto('http://localhost:3131/1', { waitUntil: 'networkidle' });
await page.waitForTimeout(2000);

const cdp = await page.context().newCDPSession(page);
const { data } = await cdp.send('Page.captureSnapshot', { format: 'mhtml' });
writeFileSync('slides.mhtml', data);
await browser.close();
```

注意：**不能**通过 Playwright MCP 的 `browser_run_code_unsafe` 执行此脚本。MCP 沙箱不支持 `import`/`require`/`fs`。必须创建独立脚本通过 Bash 运行。

### 2.3 为什么 MHTML 不保留交互性

Web 应用的运行状态分三层：

| 层次 | 内容 | MHTML 是否保留 |
|:-----|:-----|:-------------|
| Layer 1 | HTML 结构 + CSS 样式 | 是 |
| Layer 2 | 表单值、Canvas 像素 | 部分 |
| Layer 3 | JS 闭包、事件监听器、Vue Proxy、路由状态 | 否 |

Slidev/Vue 的所有交互依赖 Layer 3（响应式系统、事件监听器、虚拟 DOM）。MHTML 无法序列化 JavaScript 运行时状态。

## 3. monolith 方案（可交互，推荐）

### 3.1 原理

monolith 将 SPA 的所有**外部资源内联**到 HTML 文件中：

```
<script src="app.js">        → <script>/*完整JS代码*/</script>
<link href="style.css">      → <style>/*完整CSS代码*/</style>
url('font.woff2')            → url(data:font/woff2;base64,...)
<img src="logo.png">         → <img src="data:image/png;base64,...">
```

关键区别：monolith 保留的是**源代码**，不是执行后的状态。打开时浏览器重新执行所有 JavaScript，从零建立运行时。

### 3.2 完整流程

```bash
# 1. 构建 SPA
pnpm run build

# 2. 启动本地 HTTP 服务器（monolith 需要 HTTP 协议访问）
python3 -m http.server 8899 --directory dist/ &

# 3. 用 monolith 打包
# macOS: brew install monolith
monolith http://localhost:8899/ -o slides-standalone.html

# 4. 关闭 HTTP 服务器
kill %1
```

### 3.3 为什么 monolith 保留了交互性

1. JavaScript 代码被**完整内联**（不是执行后的快照）
2. 打开 HTML 时浏览器**从头执行**所有 JS
3. Vue 正常初始化：创建响应式代理、注册事件监听器、建立虚拟 DOM
4. Slidev 路由器正常工作：键盘翻页、v-click、动画

### 3.4 前提条件

| 条件 | 说明 |
|:-----|:-----|
| 必须先 `slidev build` | monolith 打包的是构建产物，不是 dev server |
| 必须通过 HTTP 访问 | monolith 不能直接读取本地文件系统 |
| 无 CORS 限制 | SPA 的所有 JS/CSS 必须可下载 |
| 安装 monolith | macOS: `brew install monolith` |

### 3.5 输出特征

| 指标 | 典型值 |
|:-----|:-------|
| 文件大小 | 50-60 MB |
| 交互性 | 完整保留 |
| 离线可用 | 是 |
| 浏览器兼容 | 所有现代浏览器 |
| 首次加载速度 | 略慢（需解析大量内联资源） |

## 4. 方案对比总结

| 维度 | MHTML | monolith | PDF |
|:-----|:------|:---------|:----|
| 交互性 | 无 | 完整 | 无 |
| 文件大小 | 小 | 大 (50MB+) | 中 (3-5MB) |
| 动画 | 无 | 完整 | 无 |
| 浏览器兼容 | Chrome | 所有 | 所有 PDF 阅读器 |
| 生成复杂度 | 需要 CDP | 需要 build + serve | 一条命令 |
| 推荐场景 | 不推荐 | 需要交互的分享 | 归档和打印 |

## 5. 决策树

```
需要单文件？
  ├── 不需要交互 → PDF (slidev export)
  └── 需要交互 → monolith
                   1. slidev build
                   2. python3 -m http.server
                   3. monolith http://... -o output.html
```
