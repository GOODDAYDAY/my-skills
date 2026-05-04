---
name: vmark-annotations
description: v-mark 手绘标注系统——标注类型、与 v-click 联动、颜色透明度选择
---

# v-mark 标注系统

## 1. 原理

v-mark 基于 rough-notation 库，使用 SVG 在文本周围绘制手绘风格的标注。

工作流程：
1. v-mark 指令注册在元素上
2. 触发时计算元素的 bounding box
3. 用 rough.js 算法生成手绘路径
4. SVG 动画从起点到终点绘制路径

## 2. 标注类型

| 修饰符 | 效果 | 适用场景 |
|:-------|:-----|:---------|
| `.underline` | 手绘下划线 | 强调关键词 |
| `.circle` | 手绘圆圈 | 圈出重点 |
| `.highlight` | 荧光笔高亮 | 背景色标记 |
| `.strike-through` | 手绘删除线 | 划掉旧内容 |
| `.box` | 方框 | 框选区域 |
| `.crossed-off` | 打叉 | 否定 |
| `.bracket` | 花括号 | 分组标注 |

## 3. 基本用法

```html
<!-- 自动触发（页面加载时） -->
<span v-mark.underline>重点词</span>

<!-- 带颜色 -->
<span v-mark.highlight="{color:'rgba(139,92,246,0.3)'}">高亮文字</span>

<!-- 与 v-click 联动 -->
<span v-mark.strike-through="{color:'rgba(239,68,68,0.6)', at:2}">被划掉的文字</span>
```

## 4. 与 v-click 联动

`at:N` 参数指定在第 N 次 v-click 触发时激活标注：

```html
<div v-click>                                                    <!-- click 1 -->
  <span v-mark.strike-through="{at:1}">旧方案 A</span>          <!-- at:1 → 第 1 次 click 时划线 -->
</div>
<div v-click>                                                    <!-- click 2 -->
  <span v-mark.strike-through="{at:2}">旧方案 B</span>          <!-- at:2 → 第 2 次 click 时划线 -->
</div>
<div v-click>                                                    <!-- click 3 -->
  <span v-mark.strike-through="{at:3}">旧方案 C</span>          <!-- at:3 → 第 3 次 click 时划线 -->
</div>
```

效果：每次点击时，一个方案出现并同时被划掉。

**注意**：`at` 的编号是全局的（在当前页面范围内），需要与 v-click 的自动编号对齐。

## 5. 颜色选择

推荐使用 RGBA 格式控制透明度：

| 效果 | 推荐透明度 | 示例 |
|:-----|:----------|:-----|
| 荧光笔高亮 | 0.2-0.3 | `rgba(139,92,246,0.3)` |
| 下划线 | 0.5-0.6 | `rgba(251,191,36,0.6)` |
| 删除线 | 0.5-0.7 | `rgba(239,68,68,0.6)` |
| 圆圈 | 0.4-0.6 | `rgba(59,130,246,0.5)` |

低透明度确保标注不完全遮挡文字。在暗色背景上，0.3-0.6 是最佳范围。

## 6. 常见配色方案

| 标注意图 | 颜色 | RGBA 示例 |
|:---------|:-----|:---------|
| 强调/重要 | 紫色 | `rgba(139,92,246,0.3)` |
| 警告/注意 | 琥珀色 | `rgba(251,191,36,0.6)` |
| 错误/删除 | 红色 | `rgba(239,68,68,0.6)` |
| 正确/确认 | 绿色 | `rgba(16,185,129,0.5)` |
| 信息/中性 | 蓝色 | `rgba(59,130,246,0.5)` |

## 7. 注意事项

- v-mark 在**每次进入页面时重新播放动画**（不是只播放一次）
- 标注的 SVG 覆盖在文字上方，可能影响文字的可选择性
- 对于长文本，`highlight` 效果最好；对于短词，`underline` 或 `circle` 更合适
- `strike-through` 在暗色背景上效果特别好——红色删除线非常醒目
