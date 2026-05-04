---
name: vclick-layout-trap
description: v-click 使用 opacity:0 而非 display:none 导致的布局空间占用问题，以及解决方案
---

# v-click 布局陷阱

## 1. 核心原理

v-click 隐藏元素的 CSS：

```css
.slidev-vclick-target {
  transition: opacity 100ms ease;
}
.slidev-vclick-hidden {
  opacity: 0;
  pointer-events: none;
}
```

`opacity: 0` 让元素不可见，但元素**仍参与布局计算**——占据宽度、高度、影响 flex/grid 布局。

为什么不用 `display: none`：
- `display: none` → 元素从布局中移除 → 出现时会导致布局跳动
- `opacity: 0` → 元素占位但不可见 → 出现时只改变透明度，无布局变化

这是有意的设计决策，目的是实现平滑的渐入动画。

## 2. 问题场景

### 2.1 Flexbox 居中失效

```html
<div class="h-full flex flex-col items-center justify-center">
  <h2 class="text-4xl mb-8">标题</h2>           <!-- 高度 ~60px -->
  <div v-click class="p-4 mb-4">内容 1</div>     <!-- 高度 ~80px -->
  <div v-click class="p-4 mb-4">内容 2</div>     <!-- 高度 ~80px -->
  <div v-click class="p-4 mb-4">内容 3</div>     <!-- 高度 ~80px -->
  <div v-click class="p-4 mb-4">内容 4</div>     <!-- 高度 ~80px -->
  <div v-click class="p-4">总结</div>             <!-- 高度 ~60px -->
</div>
```

幻灯片高度（canvasWidth=980, 16:9）≈ 551px。
所有元素总高度 ≈ 60 + 80×4 + 60 + 间距 ≈ 520px。
`justify-center` 计算时包含所有 opacity:0 的元素。
剩余空间仅 ~31px，标题几乎贴在顶部。

### 2.2 Grid 布局异常

Grid 中的 v-click 元素即使不可见也占据 grid cell：

```html
<div class="grid grid-cols-3 gap-4">
  <div v-click>卡片 1</div>
  <div v-click>卡片 2</div>
  <div v-click>卡片 3</div>  <!-- 不可见但占据第三列 -->
</div>
```

初始状态看到一个空的 3 列网格（有 gap 但无内容）。

## 3. 解决方案

### 3.1 减小间距和字号（v-click ≤ 4 个时）

```html
<!-- 改前 -->
<div class="text-4xl mb-10">标题</div>
<div v-click class="p-5 space-y-3">...</div>

<!-- 改后 -->
<div class="text-3xl mb-6">标题</div>
<div v-click class="p-3 space-y-2">...</div>
```

让所有元素的总高度更小，给 `justify-center` 留出足够的剩余空间。

### 3.2 改用 flex-col + justify-start（通用方案）

```html
<!-- 改前：试图居中但失败 -->
<div class="h-full flex flex-col items-center justify-center">

<!-- 改后：从上方开始，手动设置顶部间距 -->
<div class="h-full flex flex-col justify-center px-16">
  <div class="max-w-3xl mx-auto">
```

去掉 `items-center` 的垂直居中约束，改用 `justify-center` 让 flex 容器自己决定垂直位置。内容少时自然居中，内容多时从顶部开始排列。

### 3.3 拆分页面（内容确实太多时）

经验法则：**一页超过 5 个 v-click 元素，应考虑拆分为两页**。

### 3.4 使用 v-switch 替代（互斥内容时）

如果 v-click 的内容是互斥的（一个出现时另一个消失），用 `v-switch`：

```html
<v-switch>
  <template #1>状态 A</template>
  <template #2>状态 B（替换 A）</template>
</v-switch>
```

v-switch 的元素是互斥显示的，不会同时占位。

### 3.5 Transform 缩放（应急方案）

```html
<Transform :scale="0.85">
  <!-- 整体缩小 15%，不改变内部布局 -->
</Transform>
```

## 4. 预判规则

设计带 v-click 的页面时，先计算：

```
幻灯片高度 ≈ canvasWidth / aspectRatio
           = 980 / (16/9) ≈ 551px

所有内容总高度 = Σ(每个元素高度 + margin)

剩余空间 = 551 - 总高度

如果 剩余空间 < 60px → 居中效果差，需要调整
如果 剩余空间 < 0 → 内容溢出，必须拆分或缩小
```
