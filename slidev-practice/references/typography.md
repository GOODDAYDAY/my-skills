---
name: typography
description: Slidev 演示文稿的字体加载策略、中文字体选择、字体搭配方案、颜色语义系统
---

# 字体与排版

## 1. 字体配置

### 1.1 Headmatter 配置

```yaml
fonts:
  sans: Noto Sans SC      # 正文
  serif: Noto Serif SC    # 标题
  mono: JetBrains Mono    # 代码
  provider: google        # 从 Google Fonts CDN 加载
```

### 1.2 中文字体推荐

| 字体 | 用途 | 特点 |
|:-----|:-----|:-----|
| Noto Sans SC | 正文 | 思源黑体，清晰易读 |
| Noto Serif SC | 标题 | 思源宋体，正式感 |
| JetBrains Mono | 代码 | 等宽，编程连字 |
| LXGW WenKai | 文艺风 | 霞鹜文楷，适合文学主题 |

### 1.3 字体搭配原则

| 场景 | 字体 | Tailwind class |
|:-----|:-----|:--------------|
| 大标题 (h1) | Serif | `font-serif` |
| 副标题/正文 | Sans | `font-sans` (默认) |
| 代码/技术标签 | Mono | `font-mono` |
| 元数据/时间戳 | Mono | `font-mono` + `text-xs` |

Serif 用于大标题增加文学气质和正式感。Sans 保证正文可读性。Mono 用于代码和技术术语增加技术感。

## 2. 中文字体加载原理

### 2.1 文件大小问题

- 英文字体：~200 字形 → 20-50 KB
- 中文字体：~20000+ 字形 → 1-5 MB（每个 weight）

### 2.2 Google Fonts 的 Unicode Range 分割

Google Fonts 将中文字体拆分为多个子集，每个子集只包含特定 Unicode 范围的字形。浏览器通过 `unicode-range` 描述符**只下载当前页面用到的字符范围**。

```css
/* Google Fonts 生成的 CSS (简化) */
@font-face {
  font-family: 'Noto Sans SC';
  src: url(noto-sans-sc-subset-1.woff2);
  unicode-range: U+4e00-4fff;  /* 常用汉字第一段 */
}
@font-face {
  font-family: 'Noto Sans SC';
  src: url(noto-sans-sc-subset-2.woff2);
  unicode-range: U+5000-5fff;  /* 常用汉字第二段 */
}
```

### 2.3 加载时间影响

```
DNS 解析 (fonts.googleapis.com)     ~50ms
CSS 下载 (字体声明)                 ~50ms
DNS 解析 (fonts.gstatic.com)        ~50ms
字体文件下载 (多个 woff2)            ~200-2000ms
字体解码和渲染                       ~50ms
```

首次加载可能出现 FOUT（Flash of Unstyled Text）——文字先用系统字体显示，字体加载完成后切换。

### 2.4 离线方案

如果演讲环境网络不稳定：

1. 下载字体文件到项目本地
2. 设置 `fonts.local: true`
3. 或使用 `fonts.provider: none` + 自定义 `@font-face`

## 3. 颜色语义系统

### 3.1 文字颜色

| 颜色 | 语义 | 示例 class |
|:-----|:-----|:----------|
| `text-white/90` | 标题/主要文字 | 最高优先级内容 |
| `text-gray-300` | 正文 | 普通内容 |
| `text-gray-400` | 辅助说明 | 次要信息 |
| `text-gray-500` | 提示/注脚 | 最低优先级 |
| `text-gray-600` | 极弱提示 | 几乎不可见的辅助 |
| `text-purple-400` | 主题强调 | 关键概念 |
| `text-cyan-300` | 技术/AI 相关 | 技术术语 |
| `text-amber-300` | 洞察/转折 | 重要发现 |
| `text-red-400` | 问题/错误 | 负面信息 |
| `text-emerald-300` | 成就/解决方案 | 正面信息 |

### 3.2 背景颜色

所有背景使用低透明度（`/20`、`/30`、`/40`），确保不过于刺眼：

```html
<!-- 卡片背景 -->
<div class="bg-purple-900/20 border border-purple-800/20">

<!-- 代码块背景 -->
<div class="bg-slate-900/60">

<!-- 强调区域 -->
<div class="bg-red-950/30 border border-red-900/30">
```

### 3.3 字号层级

| 层级 | class | 像素 | 用途 |
|:-----|:------|:-----|:-----|
| 巨标题 | `text-7xl` | 72px | 封面页 |
| 章节标题 | `text-6xl` | 60px | Era/章节分隔 |
| 大标题 | `text-5xl` | 48px | 核心观点 |
| 页标题 | `text-4xl` | 36px | 每页标题 |
| 子标题 | `text-3xl` | 30px | 每页子标题 |
| 副标题 | `text-2xl` | 24px | 段落标题 |
| 大正文 | `text-xl` | 20px | 引言/强调 |
| 正文 | `text-lg` | 18px | 主要正文 |
| 标准 | `text-base` | 16px | 普通文字 |
| 小字 | `text-sm` | 14px | 卡片内容 |
| 极小 | `text-xs` | 12px | 注脚/标签 |

### 3.4 行高搭配

| class | 值 | 适用 |
|:------|:---|:-----|
| `leading-tight` | 1.25 | 大标题（紧凑） |
| `leading-snug` | 1.375 | 标题（略紧） |
| `leading-normal` | 1.5 | 默认 |
| `leading-relaxed` | 1.625 | 正文（舒适） |

## 4. 字间距

```html
<!-- 用于小标签的宽字间距 -->
<div class="tracking-[0.2em] uppercase text-gray-500 font-mono">
  THE QUESTION
</div>

<!-- 更宽的字间距用于装饰性标签 -->
<div class="tracking-[0.3em] uppercase text-cyan-400/60 font-mono">
  ERA I
</div>
```

`tracking-wider` (0.05em) 用于普通场景，`tracking-[0.2em]` 或 `tracking-[0.3em]` 用于小号大写标签，创造视觉稀疏感。
