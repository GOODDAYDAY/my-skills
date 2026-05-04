---
name: dom-layer-model
description: Slidev 的 DOM 层级结构、CSS 特异性战斗策略、暗色主题覆盖方法
---

# DOM 层级模型与 CSS 特异性

## 1. Slidev 的 DOM 嵌套结构

Slidev 渲染后的 DOM 是多层嵌套的。每一层都可能有自己的 `background` 属性：

```
<html class="dark">                          ← colorSchema: dark 时添加
  <body>                                     ← 可设置背景，但导出截图捕获不到
    <div id="app">                           ← Vue app 挂载点
      <div id="page-root">
        <div id="slide-container">
          <div class="slidev-slide-container"> ← 主题可能设置 background
            <div class="slidev-slide-content">
              <GlobalBottom />               ← global-bottom.vue 渲染位置
              <div class="bg-main">          ← 可能有 background
                <div class="slidev-layout">  ← 可能有 padding
                  <!-- 幻灯片内容 -->
                </div>
              </div>
              <GlobalTop />                  ← global-top.vue 渲染位置
            </div>
          </div>
        </div>
      </div>
    </div>
  </body>
</html>
```

## 2. 暗色主题的样式注入

Slidev 暗色主题通过 `html.dark` 前缀的选择器设置背景：

```css
/* Slidev 内部 CSS (来自主题包) */
html.dark .slidev-slide-container {
  background: var(--slidev-slide-container-background, #121212);
}
html.dark .bg-main {
  background: #121212;
}
```

这些选择器的特异性是 `0-2-0`（两个 class 选择器）。你的覆盖必须达到同等或更高特异性。

## 3. 三层覆盖策略

### 3.1 第一层：headmatter `<style>` 块

在 slides.md 顶部 headmatter 之后紧跟 `<style>` 块：

```html
<style>
:root {
  --slidev-theme-primary: #8b5cf6;
}
#app, #app > div,
.slidev-slide-container, .slidev-slide-content {
  background: transparent !important;
}
.slidev-layout {
  padding: 0 !important;
  margin: 0 !important;
}
.slidev-page > div {
  padding: 0 !important;
}
</style>
```

这层解决大部分静态 CSS。但 Slidev 的某些动态样式在 Vite 编译时注入，可能在这之后加载。

### 3.2 第二层：JavaScript 动态注入

在 `global-bottom.vue` 的 `<script setup>` 中创建并注入 `<style>` 标签：

```javascript
const style = document.createElement('style')
style.id = 'slidev-transparent-layers'
style.textContent = `
  html.dark body,
  html.dark #app,
  html.dark #page-root,
  html.dark #slide-container,
  html.dark #slide-content,
  html.dark .slidev-slide-container,
  html.dark .slidev-slide-content,
  html.dark .bg-main {
    background: transparent !important;
    --slidev-slide-container-background: transparent !important;
  }
`
if (!document.getElementById('slidev-transparent-layers')) {
  document.head.appendChild(style)
}
```

为什么这层有效：
- JS 执行在所有静态 CSS 加载之后
- `document.head.appendChild(style)` 将标签添加到 `<head>` 末尾
- CSS 同等特异性下，后出现的规则覆盖先出现的
- `html.dark` 前缀匹配了 Slidev 暗色主题的选择器特异性
- 同时覆盖了 CSS 变量 `--slidev-slide-container-background`
- `id` 检查防止 Vite HMR 热更新时重复注入

### 3.3 第三层：渲染 div 兜底

body 的透明只解决了"看到背景"的问题。但导出时背景仍然不可见（见 export-pipeline.md）。必须在 `<template>` 中放一个实际渲染的 div。

## 4. CSS 变量陷阱

Slidev 内部使用 CSS 自定义属性（CSS variables）控制背景。仅覆盖 `background` 属性可能不够：

```css
/* 这可能不够 */
.slidev-slide-container {
  background: transparent !important;
}

/* 因为 Slidev 内部可能这样做 */
.slidev-slide-container {
  background: var(--slidev-slide-container-background) !important;
}
```

变量的值在声明时确定，覆盖 `background` 属性时如果变量仍有值，可能在某些时机被重新应用。安全做法是**同时覆盖属性和变量**。

## 5. UnoCSS（Tailwind 兼容）的即时生成

Slidev 使用 UnoCSS 而非原生 Tailwind。UnoCSS 扫描源文件生成 CSS：

```html
<!-- 这个 class 会被检测并生成 CSS -->
<div class="bg-indigo-900/40">

<!-- 这个动态拼接的 class 不会被检测 -->
<div :class="`bg-${color}-900/40`">
```

解决方案：
- 避免动态拼接 Tailwind class 名
- 在 UnoCSS 配置中添加 safelist
- 使用内联 `style` 代替动态 class

## 6. 调试方法

当样式不生效时的排查步骤：

1. **Playwright snapshot** — 确认 DOM 结构（元素是否存在、class 是否正确）
2. **Playwright evaluate** — 读取 computed style：
   ```javascript
   getComputedStyle(document.querySelector('.slidev-slide-container')).background
   ```
3. **检查 DevTools Elements 面板** — 查看哪个规则最终胜出
4. **检查加载顺序** — Slidev 的主题 CSS 是否在你的样式之后加载
