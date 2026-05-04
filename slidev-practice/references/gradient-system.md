---
name: gradient-system
description: 实现每页不同渐变背景的完整方案：global-bottom.vue 架构、配色策略、开发与导出双兼容
---

# 渐变背景系统

## 1. 完整实现

### 1.1 global-bottom.vue

```vue
<script setup>
import { ref, watch } from 'vue'
import { useNav } from '@slidev/client'

const { currentPage } = useNav()
const currentBg = ref('#020617')

// 页码 → 渐变映射
const backgrounds = {
  1:  'linear-gradient(135deg, #020617, #1e1b4b, #0f172a)',
  2:  'linear-gradient(135deg, #020617, #0f0a2e, #0f172a)',
  // ... 按需添加
}

// 注入透明层覆盖 CSS
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

// 响应页面切换
watch(currentPage, (page) => {
  const bg = backgrounds[page] || '#020617'
  currentBg.value = bg
  // Body 背景用于开发模式平滑过渡
  document.body.style.setProperty('background', bg, 'important')
  document.body.style.setProperty('transition', 'background 0.6s ease')
}, { immediate: true })
</script>

<template>
  <!-- 渲染 div 用于导出截图可见性 -->
  <div
    class="absolute inset-0"
    style="z-index: -100; pointer-events: none;"
    :style="{ background: currentBg }"
  />
</template>
```

### 1.2 slides.md headmatter 配套样式

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

## 2. 双重背景源的原理

| 背景源 | 作用 | 在哪可见 |
|:-------|:-----|:---------|
| `document.body.style.background` | 开发模式的平滑过渡 | 浏览器 viewport |
| `<div :style="{ background }">` | 导出截图的可见性 | Playwright 元素截图 |

两者同时存在不冲突。body 背景覆盖整个 viewport，渲染 div 覆盖幻灯片区域。

为什么需要两个：
- body 背景提供页间切换时的平滑 CSS transition
- 渲染 div 在导出截图的元素 bounding box 内可见

## 3. 配色策略

### 3.1 三色渐变公式

```css
linear-gradient(135deg, 主调, 过渡, 底色)
```

| 位置 | 角色 | 选择原则 |
|:-----|:-----|:---------|
| 主调（左上） | 章节/情绪的标识色 | Tailwind 同色系 950 级 |
| 过渡（中间） | 缓冲/粘合 | 通常固定为 `#0f172a` (slate-900) |
| 底色（右下） | 深度/收束 | 与主调同色系或邻近色系 950 级 |

### 3.2 Tailwind 950 色值速查

| 色系 | 950 值 | 适合情绪 |
|:-----|:-------|:---------|
| slate | `#020617` | 中性、默认 |
| indigo | `#1e1b4b` | 探索、起步 |
| violet | `#2e1065` | 紫色系变体 |
| purple | `#3b0764` | 复杂、扩张 |
| cyan | `#083344` | 清晰、技术 |
| teal | `#042f2e` | 自然、平衡 |
| emerald | `#022c22` | 完成、成就 |
| amber | `#451a03` | 成熟、温暖 |
| orange | `#431407` | 警示、强调 |
| red | `#450a0a` | 危险、错误 |

### 3.3 配色原则

- 所有色值取 950 级（最深色），确保暗色主题下白色文字对比度 > 15:1
- 中间过渡色几乎总是 `#0f172a` 或 `#020617` — 万能粘合剂
- 主调和底色色相差控制在 60 度以内（色环距离），避免突兀
- 未映射页面 fallback 到 `#020617`（slate-950 纯色）

## 4. 渐变过渡动画原理

CSS 规范允许两个 `linear-gradient` 之间插值过渡，条件是方向和色值数量相同。

`transition: background 0.6s ease` 效果：
- 每个对应位置的颜色在 RGB 空间线性插值
- 0.6 秒平衡了"感知到变化"和"不拖慢翻页"
- `ease` 缓动函数让变化在开头和结尾减速，视觉上更自然

## 5. GlobalBottom 的生命周期

- GlobalBottom 组件在整个演示过程中**不会销毁重建**
- `onMounted` 只触发一次（首次加载时）
- `watch(currentPage, ...)` 在每次翻页时触发
- `{ immediate: true }` 确保首次加载时也执行
- HMR 时组件可能重新执行 setup，因此用 `getElementById` 防止重复注入
