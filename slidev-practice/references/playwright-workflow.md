---
name: playwright-workflow
description: Playwright MCP 在 Slidev 开发中的使用模式——感知-行动-验证循环、工具选择、沙箱限制
---

# Playwright 工作流

## 1. 核心循环

```
修改文件 (Edit slides.md / global-bottom.vue)
  ↓ Vite HMR (100-500ms 自动更新)
browser_navigate 到目标页 (http://localhost:{port}/{page})
  ↓
browser_snapshot → 确认 DOM 结构和内容
  ↓
browser_screenshot → 确认视觉效果
  ↓
如有 v-click: browser_click 逐步触发
  ↓
效果不对 → 回到修改
效果满意 → 向用户报告
```

## 2. snapshot vs screenshot

| 维度 | browser_snapshot | browser_screenshot |
|:-----|:----------------|:------------------|
| 返回格式 | 文本（无障碍树） | 图片（PNG/JPEG） |
| 信息类型 | 结构、文字内容 | 视觉外观 |
| 大小 | 小 | 大 |
| 用途 | 确认内容/结构是否正确 | 确认样式/布局/颜色 |

**使用顺序**：先 snapshot 确认内容，再 screenshot 确认视觉。大多数情况 snapshot 就够了。

## 3. 工具使用场景

| 工具 | 场景 | 频率 |
|:-----|:-----|:-----|
| `browser_navigate` | 跳转到特定页码 | 每次验证 |
| `browser_snapshot` | 检查 DOM 和内容 | 高频 |
| `browser_take_screenshot` | 视觉效果验证 | 中频 |
| `browser_click` | 触发 v-click 步骤 | 中频 |
| `browser_press_key` | 键盘翻页 (ArrowRight/Left) | 低频 |
| `browser_evaluate` | 读取 computed style、调试 | 调试时 |
| `browser_console_messages` | 检查 JS 错误 | 调试时 |
| `browser_network_requests` | 检查字体/资源加载 | 偶尔 |

## 4. Playwright MCP 沙箱限制

`browser_evaluate` 和 `browser_run_code_unsafe` 的代码在**浏览器页面上下文**中执行（等同于 DevTools Console），不是 Node.js 进程。

| 能力 | 可用 | 说明 |
|:-----|:-----|:-----|
| DOM 操作 | 是 | `document.querySelector`, `element.click()` |
| `window` 对象 | 是 | `window.scrollTo`, `window.innerWidth` |
| `fetch` | 是 | 受同源策略限制 |
| `require()` | 否 | Node.js 模块系统不可用 |
| `import()` 动态导入 | 否 | ES module 加载器不可用 |
| `process` | 否 | Node.js 全局对象不可用 |
| 文件系统 | 否 | `fs.writeFile` 不可用 |
| CDP 会话 | 否 | 无法创建 CDPSession |

**需要 Node.js API 时**：创建独立脚本文件 (.mjs)，通过 Bash 工具运行。

## 5. HMR 状态注意事项

- Vite HMR 通常在文件保存后 100-500ms 完成
- 修改 headmatter（首页 YAML）可能不触发 HMR → 手动刷新
- 修改 `global-bottom.vue` 的 `<script setup>` 可能导致部分 HMR 失效
- 安装新依赖后 → 需要重启 dev server
- 导航到同一 URL 时，`browser_navigate` 会重新加载页面（获取最新内容）

## 6. 调试技巧

### 6.1 检查 computed style

```javascript
// 通过 browser_evaluate 执行
getComputedStyle(document.querySelector('.slidev-slide-container')).background
```

### 6.2 检查 v-click 状态

```javascript
// 获取当前页面的 click 计数
document.querySelector('.slidev-nav-total-clicks')?.textContent
```

### 6.3 检查字体加载状态

```javascript
document.fonts.ready.then(() => console.log('All fonts loaded'))
// 或检查具体字体
document.fonts.check('16px "Noto Sans SC"')
```

## 7. Dev Server 管理

**启动**：`pnpm run dev -- --port 3131`

指定端口避免与其他项目冲突。保持 dev server 在整个开发过程中持续运行。

**不要频繁启停**：
- 启动需要编译所有幻灯片（~3-10 秒）
- 停止后丢失 HMR 状态
- Playwright 需要重新导航
