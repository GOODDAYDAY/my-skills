---
name: slide-management
description: Slide 编号管理的脆弱性分析——硬编码页码问题、插入页面时的连锁更新、更好的替代方案
---

# Slide 编号管理

## 1. 硬编码页码的问题

global-bottom.vue 中典型的背景映射：

```javascript
const backgrounds = {
  1:  'linear-gradient(...)',   // cover
  7:  'linear-gradient(...)',   // 某个标题页
  11: 'linear-gradient(...)',   // 另一个标题页
  15: 'linear-gradient(...)',   // 又一个标题页
}
```

key 是页码（位置），不是身份标识。**插入一页 → 后续所有 key 需要 +1**。

### 1.1 连锁更新的代价

在 slide 6 和 slide 7 之间插入新页面后：
- slide 7 的 key 变成 8
- slide 11 变成 12
- slide 15 变成 16
- ……所有后续 key 都要更新
- 注释标签也要更新
- 如果有其他代码引用页码（如 presenter notes 中的"见第 X 页"），也要更新

### 1.2 实际发生的频率

一个 30+ 页的演示文稿，在打磨阶段经常需要：
- 插入过渡页
- 拆分信息密集的页面
- 调整章节顺序

每次操作都触发一次全量 key 更新。

## 2. 更好的替代方案

### 2.1 方案一：Frontmatter bgKey

在每页 frontmatter 中声明背景标识：

```yaml
---
bgKey: era-1-title
---
```

global-bottom.vue 中按 bgKey 映射：

```javascript
const bgByKey = {
  'era-1-title': 'linear-gradient(...)',
  'era-2-title': 'linear-gradient(...)',
}
```

获取当前页的 bgKey 需要访问 Slidev 的 slide metadata API（可能需要查阅 Slidev 源码确认可用性）。

### 2.2 方案二：自定义 Layout

创建带渐变的 layout 组件：

```vue
<!-- layouts/gradient.vue -->
<script setup>
defineProps({
  gradient: { type: String, default: '#020617' }
})
</script>

<template>
  <div class="h-full w-full relative">
    <div
      class="absolute inset-0"
      style="z-index: -100; pointer-events: none;"
      :style="{ background: gradient }"
    />
    <slot />
  </div>
</template>
```

使用时：

```yaml
---
layout: gradient
gradient: "linear-gradient(135deg, #1e1b4b, #0f172a, #020617)"
---
```

优点：
- 每页自描述，不依赖全局映射
- 插入/删除页面无需更新其他页
- 渲染 div 在 layout 内部，导出兼容

缺点：
- 每页都需要手写 gradient 值（可以用 CSS 变量简化）
- 失去了 body 级别的平滑过渡效果

### 2.3 方案三：data attribute 匹配

在 frontmatter 中设置 class 或 data 属性：

```yaml
---
class: era-1
---
```

在 global-bottom.vue 中通过 DOM 查询获取：

```javascript
watch(currentPage, () => {
  const slideEl = document.querySelector('.slidev-page.active')
  const era = slideEl?.dataset?.era
  // 根据 era 设置背景
})
```

## 3. 当前方案的维护技巧

如果坚持使用硬编码页码（项目规模小、改动不频繁时仍可接受）：

1. **注释每个 key 的内容标识**：
   ```javascript
   7:  'linear-gradient(...)',   // Era I title
   ```
   当页码变化时，注释帮助确认映射是否正确。

2. **批量更新时用搜索替换**：
   在 slide N 后插入一页时，从最后一个 key 开始倒序 +1，避免覆盖。

3. **修改后立即用 Playwright 验证**：
   遍历所有有背景的页面截图确认。

## 4. slides.md 拆分策略

当 slides.md 超过 1500 行时，考虑用 `src:` 导入拆分：

```yaml
# slides.md
---
src: ./slides/era1.md
---

---
src: ./slides/era2.md
---
```

拆分后每个文件独立管理，但注意：
- 全局编号仍由 Slidev 自动分配（拆分不影响最终页码）
- global-bottom.vue 仍然使用全局页码
- 拆分的好处主要是编辑时的文件大小和定位效率
