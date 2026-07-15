# DomainDriveFramework — 前端 UI 设计规范 v1.0

> 角色视角：产品设计专家（UI/UX）
> 技术栈：Vue 3 + TypeScript + Element Plus（定制增强层）
> 目标：企业级工业平台视觉语言，去 AI 化，差异化于常见开源前端
> 适用范围：SaaS 平台 Web UI（`platform/web/`）

---

## 1. 设计哲学 — 为什么"不像 AI"

### 1.1 核心原则

| 原则 | 内涵 | 反例（需避免） |
|------|------|--------------|
| **工业感** | 稳重、可信赖、信息密度高、操作高效 | 渐变光晕、玻璃拟态、粒子动效 |
| **克制** | 留白有功能目的，不为"好看"而留白 | 全屏英雄图、空状态插画 |
| **领域驱动** | 视觉语言映射制造领域语义（工单/BOM/工艺/质检） | 通用"Dashboard"卡片堆砌 |
| **操作优先** | 每一次点击/输入都指向明确业务动作 | 过度引导式 onboarding 教程 |
| **层次清晰** | 信息层级通过语义化色彩和排版表达，而非装饰 | 彩虹色、多色按钮 |

### 1.2 差异化定位

```
当前主流开源前端（Element Plus / Ant Design / Naive UI）的共同特征：
  ├── 中性品牌色（蓝 #1890ff / #409eff）
  ├── 圆角 4px（统一、保守）
  ├── 阴影层级 ≤ 3 级
  ├── 侧栏图标 + 文字，无行业特征
  └── 数据表格为主，缺少工业时序/状态可视化

DDF 的差异化路径：
  ├── 色彩：深蓝主色 #1E2761（行业专属感），非通用蓝
  ├── 圆角：6px（比 Element Plus 多 2px，现代感但不甜）
  ├── 侧栏：领域分组图标 + 行业 Profile 标识带
  ├── 数据层：状态机可视化 + 工艺路线甘特图
  └── 交互：操作审计线 + 版本对比 diff 视图
```

### 1.3 "去 AI 化"清单

```
[X] 禁止使用的设计元素：
  ├── 渐变色（primary gradient from #xxx to #yyy）
  ├── 发光效果（box-shadow 模拟 light glow）
  ├── 玻璃拟态（backdrop-filter: blur() + 半透明背景）
  ├── 粒子/波纹背景（canvas 粒子动画、hero 区域装饰）
  ├── 大段引导式文案（"Welcome! Let AI help you..."）
  ├── 圆角过大（> 12px 的按钮/卡片 — 显得"可爱"而非"专业"）
  ├── 大量 emoji 图标作为功能标识
  ├── 对话式交互（chat bubbles、typing indicator 作为核心入口）
  ├── "智能推荐"/"AI 建议"悬浮面板（除非确实由 AI 驱动）
  └── 花哨的 loading 动画（spinners with gradient, morphing shapes）

[x] 必须遵循的设计模式：
  ├── 语义化色彩（成功=绿、警告=琥珀、危险=红、信息=钢灰）
  ├── 高密度信息表格（支持列排序、筛选、列宽拖拽）
  ├── 明确的层级结构（面包屑、tabs、sidebar 三级导航）
  ├── 操作审计追踪（谁、在什么时候、做了什么修改）
  ├── 版本对比视图（DSL diff 以行级高亮展示）
  └── 状态可视化（状态机流程图、工艺甘特图）
```

---

## 2. Design Token 系统

### 2.1 色彩系统

```css
/* src/styles/tokens/color.css */

:root {
  /* ========== 品牌色系 ========== */
  /* 主色：深海蓝 — 传递稳定、专业、工业感 */
  --color-primary-50:  #e6e9f5;
  --color-primary-100: #cdd3eb;
  --color-primary-200: #99a9d8;
  --color-primary-300: #667fc5;
  --color-primary-400: #3d5bb6;
  --color-primary-500: #1E2761;  /* 品牌主色 — 深蓝 */
  --color-primary-600: #1a2256;
  --color-primary-700: #151c48;
  --color-primary-800: #10163a;
  --color-primary-900: #0b102c;

  /* 辅助色：工业钢灰 — 中性信息的表达 */
  --color-steel-50:   #f6f7f9;
  --color-steel-100:  #eaecf1;
  --color-steel-200:  #d6dae2;
  --color-steel-300:  #a8aec0;
  --color-steel-400:  #7a8399;
  --color-steel-500:  #51586d;
  --color-steel-600:  #3d4356;
  --color-steel-700:  #2d3243;
  --color-steel-800:  #202432;
  --color-steel-900:  #141721;

  /* 功能色：标准化工业信号灯语义 */
  --color-success:  #16a34a;
  --color-warning:  #d97706;
  --color-danger:   #dc2626;
  --color-info:     #51586d;
  --color-pending:  #9ca3af;

  /* 状态色映射 — 直接对应 DSL status_colors */
  --color-status-pending:   #9ca3af;
  --color-status-running:   #1E2761;
  --color-status-paused:    #d97706;
  --color-status-completed: #16a34a;
  --color-status-cancelled: #dc2626;

  /* 文本色系 */
  --color-text-primary:   #141721;
  --color-text-secondary: #51586d;
  --color-text-tertiary:  #a8aec0;
  --color-text-disabled:  #d6dae2;

  /* 边框色系 */
  --color-border-default: #d6dae2;
  --color-border-strong:  #a8aec0;
  --color-border-focus:   #1E2761;

  /* 背景色系 */
  --color-bg-page:     #f6f7f9;  /* steel-50 */
  --color-bg-subtle:   #eaecf1;  /* steel-100 */
  --color-bg-surface:  #ffffff;
  --color-bg-elevated: #ffffff;

  /* 分割线 */
  --color-divider:     #eaecf1;
  --color-divider-strong: #d6dae2;

  /* 叠加层 */
  --color-overlay:     rgba(20, 23, 33, 0.4);
}
```

### 2.2 暗色主题 Token

```css
/* src/styles/tokens/color-dark.css */

[data-theme="dark"] {
  --color-text-primary:   #eaecf1;   /* steel-100 */
  --color-text-secondary: #a8aec0;   /* steel-300 */
  --color-text-tertiary:  #51586d;   /* steel-500 */
  --color-text-disabled:  #2d3243;   /* steel-700 */

  --color-border-default: #2d3243;   /* steel-700 */
  --color-border-strong:  #3d4356;   /* steel-600 */
  --color-border-focus:   #667fc5;   /* primary-300 */

  --color-bg-page:     #141721;     /* steel-900 */
  --color-bg-subtle:   #202432;     /* steel-800 */
  --color-bg-surface:  #202432;     /* steel-800 */
  --color-bg-elevated: #2d3243;     /* steel-700 */

  --color-divider:     #2d3243;
  --color-divider-strong: #3d4356;

  --color-overlay:     rgba(0, 0, 0, 0.6);

  /* 功能色在暗色下提升亮度 */
  --color-success:  #4ade80;
  --color-warning:  #fbbf24;
  --color-danger:   #f87171;
  --color-info:     #a8aec0;
  --color-pending:  #51586d;
}
```

### 2.3 字体系统

```css
/* src/styles/tokens/typography.css */

:root {
  --font-family-base: -apple-system, BlinkMacSystemFont,
    "PingFang SC", "Noto Sans SC", "Microsoft YaHei", "Segoe UI", sans-serif;
  --font-family-mono: "JetBrains Mono", "SF Mono", "Menlo", "Consolas", monospace;
  --font-family-display: -apple-system, BlinkMacSystemFont,
    "PingFang SC", "Noto Sans SC", "Microsoft YaHei", sans-serif;

  --font-size-xs:  11px;
  --font-size-sm:  12px;
  --font-size-base: 14px;
  --font-size-md:  16px;
  --font-size-lg:  20px;
  --font-size-xl:  24px;
  --font-size-2xl: 32px;

  --font-weight-normal:   400;
  --font-weight-medium:   500;
  --font-weight-semibold: 600;
  --font-weight-bold:     700;

  --line-height-tight:    1.3;
  --line-height-base:     1.5;
  --line-height-relaxed:  1.7;
}
```

### 2.4 间距、圆角、阴影

```css
/* src/styles/tokens/space.css */

:root {
  --space-0:  0;
  --space-1:  4px;
  --space-2:  8px;
  --space-3:  12px;
  --space-4:  16px;
  --space-5:  20px;
  --space-6:  24px;
  --space-8:  32px;
  --space-10: 40px;
  --space-12: 48px;
  --space-16: 64px;

  /* 圆角 — 6px 基准，比 Element Plus 的 4px 多 2px */
  --radius-sm:   4px;
  --radius-base: 6px;
  --radius-md:   8px;
  --radius-lg:   12px;
  --radius-full: 9999px;

  /* 阴影 — 三层体系，无第四层 */
  --shadow-xs:   0 1px 2px rgba(20, 23, 33, 0.04);
  --shadow-sm:   0 1px 3px rgba(20, 23, 33, 0.06), 0 1px 2px rgba(20, 23, 33, 0.04);
  --shadow-base: 0 4px 6px rgba(20, 23, 33, 0.05), 0 2px 4px rgba(20, 23, 33, 0.03);
  --shadow-md:   0 10px 15px rgba(20, 23, 33, 0.06), 0 4px 6px rgba(20, 23, 33, 0.03);
  --shadow-lg:   0 20px 25px rgba(20, 23, 33, 0.08), 0 8px 10px rgba(20, 23, 33, 0.04);

  /* 过渡 */
  --transition-fast: 150ms ease;
  --transition-base: 200ms ease;
  --transition-slow: 300ms ease;
}
```

### 2.5 Token 使用优先级

```
Token 使用层级：
  1. 语义化 token（--color-status-running）→ 优先使用
  2. 色彩 token（--color-primary-500）      → 次优先
  3. 变量引用 token（--color-border-default）→ 可复用
  4. 硬编码值（#1E2761）                   → 仅在 token 不存在时使用
  5. CSS 原生函数（rgba()）               → 极少使用

禁止：
  ├── 在组件样式中硬编码颜色（除非是 token 缺失时的临时占位）
  ├── 在同一文件中混用 token 和硬编码值
  └── 创建超过 5 级的阴影层级
```

---

## 3. 布局架构

### 3.1 Shell 布局结构

```
┌─────────────────────────────────────────────────────────────────┐
│  Top Bar (52px)                                                │
│  ┌────────────────────────────────────────────────────────────┐│
│  │  Logo 区域    全局导航tabs    搜索框    通知铃铛  用户头像   ││
│  └────────────────────────────────────────────────────────────┘│
├──────────┬──────────────────────────────────────────────────────┤
│          │  Breadcrumb Bar (40px)                              │
│  Sidebar │  模型设计中心 > 精密五金 MES > 实体编辑              │
│  (240px) ├──────────────────────────────────────────────────────┤
│          │                                                      │
│  一级分组 │  Main Content (自适应，padding 24px)                │
│  ├─ 建模  │                                                      │
│  │ ├─ 模型 │  ┌────────────────────────────────────────────┐    │
│  │ ├─ 实体 │  │                                            │    │
│  │ └─ 关系 │  │           页面内容区域                      │    │
│  │          │  │                                            │    │
│  ├─ 设计    │  │                                            │    │
│  │ ├─ 工作流│  │                                            │    │
│  │ ├─ 权限   │  │                                            │    │
│  │ └─ 编排   │  └────────────────────────────────────────────┘    │
│  │          │                                                      │
│  ├─ 市场    │  ┌────────────────────────────────────────────┐    │
│  │ └─ 模型库 │  │  （多标签页时，底部 Tab 栏）                │    │
│  │          │  └────────────────────────────────────────────┘    │
│  ├─ 项目    │                                                      │
│  │ └─ 项目列表│                                                     │
│  │          │                                                      │
│  ├─ 管理    │                                                      │
│  │ └─ 控制台 │                                                     │
│  └─ 设置    │                                                      │
│             │                                                      │
└────────────┴──────────────────────────────────────────────────────┘

响应式断点：
  桌面端 (≥ 1200px)：    Sidebar 240px（展开）/ 80px（折叠）
  平板端 (768-1199px)：  Sidebar 200px（固定展开）
  移动端 (< 768px)：     Sidebar 全屏抽屉式
```

### 3.2 侧栏设计

```
侧栏层级结构：

┌──────────────────────────────────┐
│  [Logo + 品牌名称]               │  ← 固定 52px
│  DDF · 模型设计中心               │     品牌标识
├──────────────────────────────────┤
│                                  │
│  ▸ 建模                         │  ← 分组标题（steel-500, 12px, uppercase）
│  ├─ [list] 实体列表                  │  ← 一级菜单（14px, steel-900 文字）
│  ├─ [link] 关系管理                  │
│  ├─ [cog] 工作流                    │
│  └─ [compass] 权限配置                  │
│                                  │
│  ▸ 设计                         │
│  ├─ [sync] 业务编排                  │
│  └─ [palette] 主题配置                  │
│                                  │
│  ▸ 市场                          │
│  ├─ [package] 模型库                    │
│  └─ [star] 精选模型                  │
│                                  │
│  ▸ 项目                          │
│  └─ [folder] 项目列表                  │
│                                  │
│  ▸ 管理                          │
│  ├─ [chartBar] 控制台                    │
│  └─ [users] 用户管理                  │
│                                  │
├──────────────────────────────────┤
│  [ 当前行业 Profile 标识 ]       │  ← 底部标识带
│  ◉ precision_metal v2.1         │     钢灰底色 + 状态点
└──────────────────────────────────┘

侧栏交互规则：
  ├── 分组标题：hover 无变化，点击展开/折叠（仅一级折叠）
  ├── 当前激活项：左侧 3px 竖条（primary-500），文字 bold
  ├── 未激活项：hover 背景 steel-50，文字 steel-700
  ├── 图标：Lucide 风格，18x18px，steel-400 → hover steel-600
  ├── 折叠状态：仅显示图标（居中），tooltip 显示名称
  └── 底部 Profile 标识：折叠时隐藏，展开时显示
```

### 3.3 顶部栏设计

```
┌──────────────────────────────────────────────────────────────────┐
│  [DDF Logo]  模型设计中心    │  [list]实体  [cog]工作流  [compass]权限  │  [search][搜索]  [bell]  [user] ▾│
│  52px 高，白底/暗色 steel-800，底部分割线                        │
│                                                                  │
│  左侧：                                                          │
│    ├── Logo + 平台名称：primary-500 色                            │
│    ├── 全局导航 Tabs：显示一级分组名称（建模 / 设计 / 市场 / 项目 / 管理）│
│    └── 当前 Tab 激活态：底部 primary-500 下划线                  │
│                                                                  │
│  右侧：                                                          │
│    ├── 搜索框：钢灰边框，focus 时 primary-500 边框 + 展开        │
│    ├── 通知铃铛：未读红点标记                                    │
│    └── 用户头像 + 用户名 + ▾ 下拉菜单                           │
└──────────────────────────────────────────────────────────────────┘

顶部栏交互规则：
  ├── 全局 Tabs 切换：切换一级分组，侧栏随之切换
  ├── 搜索框：focus 时展开为全局搜索面板（可搜索模型/实体/项目）
  ├── 通知铃铛：下拉显示最近通知列表（最多 20 条）
  └── 用户菜单：设置 / 订阅信息 / 退出登录
```

### 3.4 面包屑与多标签页

```
面包屑条：
┌─────────────────────────────────────────────────────────────┐
│  [home] 首页 / 精密五金 MES / 实体编辑 / WorkOrder              │
│  40px 高，steel-100 背景，分隔符 " / " steel-300             │
│  每项可点击跳转，末项为当前页面（steel-900 文字）              │
└─────────────────────────────────────────────────────────────┘

多标签页（可选，当用户同时编辑多个模型时）：
┌─────────────────────────────────────────────────────────────┐
│  [+]  WorkOrder        BOM           ProcessRoute      [▾] │
│  36px 高，可滚动，关闭按钮"×"仅显示在 hover 时               │
│  激活标签：白底 + 底部 primary-500 条                      │
│  非激活标签：steel-100 背景                                │
└─────────────────────────────────────────────────────────────┘
```

### 3.5 布局 CSS 变量

```css
/* src/styles/layout.css */

:root {
  --layout-topbar-height:  52px;
  --layout-breadcrumb-height: 40px;
  --layout-tabs-height:    36px;
  --layout-sidebar-width:  240px;
  --layout-sidebar-collapsed-width: 80px;
  --layout-content-padding: 24px;

  /* 可用内容区域高度 */
  --layout-content-height: calc(
    100vh
    - var(--layout-topbar-height)
    - var(--layout-breadcrumb-height)
    - var(--layout-tabs-height, 0)
  );
}
```

---

## 4. 核心页面 UI 设计规范

### 4.1 模型设计器

```
┌──────────────────────────────────────────────────────────────────┐
│  Top Bar                                                         │
├──────────┬───────────────────────────────────────────────────────┤
│          │  [home] 精密五金 MES / 实体列表 / WorkOrder                │
│  Sidebar │  [list] 列表 [compass] 视图 [cog] 权限 [upload] 导出             │
│          │  ┌─────────────────────────────────────────────────┐  │
│          │  │  WorkOrder 工单          [编辑] [校验 v] [发布] │  │
│          │  │  生产工单管理，包含 BOM 关联、状态流转、权限控制  │  │
│          │  └─────────────────────────────────────────────────┘  │
│          │                                                       │
│          │  ┌─────────────────────────────────────────────────┐  │
│          │  │  ┌──────────────┐  ┌─────────────────────────┐  │  │
│          │  │  │ 字段编辑区    │  │ YAML 预览区              │  │  │
│          │  │  │              │  │                         │  │  │
│          │  │  │ ┌──────────┐ │  │ entity:                 │  │  │
│          │  │  │ │ name     │ │  │   domain: work_order    │  │  │
│          │  │  │ │ string   │ │  │   name: WorkOrder       │  │  │
│          │  │  │ │ 主键 [x]   │ │  │   label: 工单           │  │  │
│          │  │  │ └──────────┘ │  │   fields:               │  │  │
│          │  │  │              │  │     - name: order_no    │  │  │
│          │  │  │ ┌──────────┐ │  │       type: string      │  │  │
│          │  │  │ │ order_no │ │  │       label: 工单编号   │  │  │
│          │  │  │ │ string   │ │  │       required: true    │  │  │
│          │  │  │ │ 必填 [x]   │ │  │     - ...               │  │  │
│          │  │  │ └──────────┘ │  │                         │  │  │
│          │  │  │              │  │                         │  │  │
│          │  │  └──────────────┘  └─────────────────────────┘  │  │
│          │  │           50%                    50%              │  │
│          │  └─────────────────────────────────────────────────┘  │
│          │                                                       │
│          │  ┌─────────────────────────────────────────────────┐  │
│          │  │  关联实体  │  BOMItem        ProcessRoute        │  │
│          │  │  ─────────────────────────────────────────────  │  │
│          │  │  状态机    │  ──▶ has_many ──▶ ◀─ belongs_to    │  │
│          │  └─────────────────────────────────────────────────┘  │
│          │                                                       │
│          │  ┌─────────────────────────────────────────────────┐  │
│          │  │  校验报告                                       │  │
│          │  │  [v] Schema 合规   [v] 引用完整   [!] 字段未加注释    │  │
│          │  └─────────────────────────────────────────────────┘  │
│          └───────────────────────────────────────────────────────┘
└──────────────────────────────────────────────────────────────────┘

关键设计决策：
  ├── 双栏编辑（字段表单 ↔ YAML 预览）是设计器的核心
  ├── 字段编辑器不是简单的 CRUD，每个字段支持：
  │    ├── 类型选择（string/integer/float/boolean/date/datetime/enum/relation）
  │    ├── 配置项（required/primary_key/read_only/default 等）
  │    ├── 校验规则（min/max/pattern/error）
  │    └── 高级属性（sequence/validate/auto_fill/auto_calculate）
  ├── YAML 预览为只读（只读模式可切换为可编辑）
  ├── 校验报告始终可见（实时，非手动触发）
  └── 关联实体图用水平流程图展示（非树形图）
```

#### 4.1.1 字段编辑器规范

```
字段编辑器行结构：
┌─────────────────────────────────────────────────────────────────────┐
│  ┌─────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌───┐     │
│  │ 图标     │  │ 字段名   │  │ 类型     │  │ 标签     │  │ × │     │
│  │ [edit3]       │  │ order_no │  │ string   │  │ 工单编号 │  │   │     │
│  │          │  │          │  │ ▼        │  │          │  │   │     │
│  └─────────┘  └──────────┘  └──────────┘  └──────────┘  └───┘     │
│                                                                     │
│  配置区（展开时显示）：                                              │
│  ┌────────────────────────────────────────────────────────────────┐│
│  │  [必填] [x]   [主键] [ ]   [只读] [ ]   [自动生成] [ ]                ││
│  │                                                                ││
│  │  ┌─────┐  ┌─────┐  ┌──────┐  ┌──────┐  ┌──────────┐         ││
│  │  │ 默认 │  │ 最大 │  │ 最小 │  │ 正则 │  │ 错误提示 │         ││
│  │  │ 文本框│  │ 字符 │  │ 字符 │  │ 输入框│  │ 文本框   │         ││
│  │  └─────┘  └─────┘  └──────┘  └──────┘  └──────────┘         ││
│  └────────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────┘

字段类型图标映射：
  string      → [edit3]  文本
  integer     → [hash]  数字
  float       → 小数  数字
  boolean     → [x]  开关
  date        → [calendar]  日历
  datetime    → [clock]  时钟
  enum        → [tag]  标签
  relation    → [link]  链接
```

#### 4.1.2 状态机可视化

```
状态机可视化：
┌──────────────────────────────────────────────────────────────────────┐
│  状态机：WorkOrder 生命周期                                           │
│                                                                      │
│   ┌─────────────┐                     ┌─────────────┐                 │
│   │   pending     │──开工──▶           │   running    │              │
│   │  待启动       │                     │  生产中      │              │
│   └─────────────┘                     └──────┬──────┘               │
│        │                                      │                      │
│        │ 取消              ┌──────────────┐   │ 完工                  │
│        │◀──────────────────│   paused     │◀──│                       │
│        │                   │  暂停中       │   │                      │
│        │                   └──────────────┘   │                      │
│                                               │                      │
│                                              ┌▼──────┐               │
│                                              │completed│              │
│                                              │  已完工  │              │
│                                              └────────┘               │
│                                                                      │
│  转移条件：                                                            │
│  ├── pending → running: require_comment = false                       │
│  ├── running → paused:  require_comment = true (placeholder: "暂停原因")│
│  └── running → completed: 必须 completed_quantity == quantity         │
└──────────────────────────────────────────────────────────────────────┘

状态卡片规范：
  ├── 圆角 6px
  ├── 状态边框色 = 状态语义色（pending=灰、running=蓝、completed=绿）
  ├── 状态名称 bold 16px
  ├── 状态描述 steel-500 12px
  └── 终态卡片右下角有锁定图标 [lock]
```

### 4.2 模型市场

```
模型市场首页：
┌──────────────────────────────────────────────────────────────────┐
│  Top Bar                                                         │
├──────────┬───────────────────────────────────────────────────────┤
│          │  [home] 模型市场                                             │
│  Sidebar │  [package] 全部模型  [star] 精选模型  [trendingUp] 排行榜               │
│          │                                                       │
│          │  ┌─────────────────┐  ┌─────────────────────────────┐│
│          │  │ [search] [关键词搜索]  │  │ [tag] 行业: [全部 ▾] [等级: ▾]││
│          │  └─────────────────┘  └─────────────────────────────┘│
│          │                                                       │
│          │  ┌───────────┐ ┌───────────┐ ┌───────────┐           │
│          │  │ [star] 精密五金│ │ [star] 电子MES │ │ [package] 供应链  │           │
│          │  │ MES v2.1  │ │ v1.3      │ │ Support   │           │
│          │  │ ────────  │ │ ────────  │ │ v0.9      │           │
│          │  │ 继承 128  │ │ 继承 67   │ │ 继承 23   │           │
│          │  │ 官方认证   │ │ 社区认证   │ │ 待认证    │           │
│          │  │ [继承] [详情]│ [继承] [详情]│ [继承] [详情]│           │
│          │  └───────────┘ └───────────┘ └───────────┘           │
│          │                                                       │
│          │  ┌───────────┐ ┌───────────┐ ┌───────────┐           │
│          │  │ [package] 质检管理│ │ [package] 仓储管理│ │ [star] WMS扩展│           │
│          │  │ v1.0      │ │ v0.8      │ │ v2.0      │           │
│          │  │ ────────  │ │ ────────  │ │ ────────  │           │
│          │  │ 继承 45   │ │ 继承 31   │ │ 继承 89   │           │
│          │  │ 社区认证   │ │ 待认证     │ │ 官方认证   │           │
│          │  │ [继承] [详情]│ [继承] [详情]│ [继承] [详情]│           │
│          │  └───────────┘ └───────────┘ └───────────┘           │
│          │                                                       │
│          │  [加载更多]                                          │
│          └───────────────────────────────────────────────────────┘
└──────────────────────────────────────────────────────────────────┘

模型卡片规范：
  ├── 白底，底部 1px 分割线（steel-200）
  ├── 等级徽章：[star] 金色（精选）/ [package] 钢灰（普通）
  ├── 继承次数 bold 18px steel-900
  ├── 认证状态 12px steel-500
  ├── 操作按钮：[继承] primary-500 实心 / [详情] steel-200 描边
  └── hover 时卡片 shadow-sm
```

### 4.3 项目生成中心

```
项目生成中心：
┌──────────────────────────────────────────────────────────────────┐
│  Top Bar                                                         │
├──────────┬───────────────────────────────────────────────────────┤
│          │  [home] 项目中心 / 项目列表                                   │
│  Sidebar │                                                       │
│          │  ┌─────────────────────────────────────────────────┐  │
│          │  │  [plus] 新建项目               [搜索项目 [search]]        │  │
│          │  └─────────────────────────────────────────────────┘  │
│          │                                                       │
│          │  ┌─────────────────────────────────────────────────┐  │
│          │  │  项目名称    │  Profile    │  生成次数 │  状态   │  │
│          │  ├────────────┼─────────────┼───────────┼────────┤  │
│          │  │ 客户甲MES   │ 精密五金v2 │  12次     │ 运行中  │  │
│          │  │ 客户乙MES   │ 电子MESv1  │  5次      │ 已归档  │  │
│          │  │ 客户丙MES   │ 精密五金v2 │  3次      │ 待生成  │  │
│          │  └────────────┴─────────────┴───────────┴────────┘  │
│          │                                                       │
│          │  [分页 1/4  共 32 条]                                │
│          └───────────────────────────────────────────────────────┘
└──────────────────────────────────────────────────────────────────┘

项目新建弹窗：
┌────────────────────────────────────────────────────────┐
│  新建项目                                              │
│  ──────────────────────────────────────────────────────│
│  项目名称：[_________________________________]         │
│  选择 Profile：[精密五金 MES v2.1 ▾]                   │
│  数据库前缀：[cust_a_]                                 │
│  时区：[Asia/Shanghai ▾]                               │
│  ──────────────────────────────────────────────────────│
│  [取消]  [生成预览]  [确认生成]                        │
└────────────────────────────────────────────────────────┘

生成进度：
┌────────────────────────────────────────────────────────┐
│  生成中...  预计 2 分钟                                │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━ 47%                       │
│                                                        │
│  [v] 解析 DSL  (0.8s)                                   │
│  [v] 渲染后端模板 (3.2s)                                 │
│  ▶ 渲染前端模板 (进行中)                                │
│  ○ 渲染移动端模板                                      │
│  ○ 质量门禁 A-D                                      │
│  ○ 打包输出                                          │
└────────────────────────────────────────────────────────┘
```

### 4.4 用户中心

```
用户中心：
┌──────────────────────────────────────────────────────────────────┐
│  Top Bar                                                         │
├──────────┬───────────────────────────────────────────────────────┤
│          │  [home] 用户中心 / 订阅信息                                  │
│  Sidebar │  [user] 个人信息  [creditCard] 订阅  [key] API Key  [bell] 通知设置 │
│          │                                                       │
│          │  ┌─────────────────────────────────────────────────┐  │
│          │  │  订阅状态：[online] 标准版 (¥99/月)                    │  │
│          │  │  有效期至：2026-08-11                            │  │
│          │  │                                                 │  │
│          │  │  ┌─────────┐ ┌─────────┐ ┌─────────┐          │  │
│          │  │  │ 项目    │ │ 模型    │ │ AI调用  │          │  │
│          │  │  │ 5 / 5  │ │ 42 / 50 │ │ 156/200 │          │  │
│          │  │  └─────────┘ └─────────┘ └─────────┘          │  │
│          │  └─────────────────────────────────────────────────┘  │
│          │                                                       │
│          │  ┌─────────────────────────────────────────────────┐  │
│          │  │  用量趋势（近 30 天）                             │  │
│          │  │  [折线图：AI 调用次数 + 生成次数]                │  │
│          │  └─────────────────────────────────────────────────┘  │
│          └───────────────────────────────────────────────────────┘
└──────────────────────────────────────────────────────────────────┘
```

### 4.5 操作审计线

```
操作审计线（贯穿所有核心页面的共性组件）：

┌────────────────────────────────────────────────────────────────────┐
│  操作审计                                                            │
│                                                                    │
│  ┌───────────────────────────────────────────────────────────────┐│
│  │  [sync] 2026-07-11 14:32:05  张三  修改了字段 "order_no"          ││
│  │     从 "string" 改为 "string"（长度限制 20 → 32）              ││
│  └───────────────────────────────────────────────────────────────┘│
│  ┌───────────────────────────────────────────────────────────────┐│
│  │  [sync] 2026-07-11 14:30:12  张三  添加了新字段 "priority"        ││
│  │     类型: enum, 标签: 优先级, 默认: normal                     ││
│  └───────────────────────────────────────────────────────────────┘│
│  ┌───────────────────────────────────────────────────────────────┐│
│  │  [upload] 2026-07-11 14:28:45  系统   生成项目 "客户甲MES"           ││
│  │     Profile: 精密五金 MES v2.1, 文件数: 142, 耗时: 2m18s      ││
│  └───────────────────────────────────────────────────────────────┘│
│                                                                    │
│  [加载更多]                                                        │
└────────────────────────────────────────────────────────────────────┘

审计项结构：
  ├── 左侧图标：[sync] 修改 / [upload] 生成 / [list] 创建 / [cog] 配置
  ├── 时间：steel-500, 12px
  ├── 操作者：steel-900, 14px, medium
  ├── 详情：steel-700, 14px
  └── 每条之间 8px 间距，steel-100 底部分割线
```

---

## 5. 组件增强策略

### 5.1 Element Plus 覆盖层

```
定制策略：在 Element Plus 之上建立定制层，而非 fork 或替换。

src/components/ddf/                    # DDF 专属定制组件
├── DdfButton.vue                      # 覆盖 el-button 样式
├── DdfTable.vue                       # 覆盖 el-table 样式
├── DdfInput.vue                       # 覆盖 el-input 样式
├── DdfSelect.vue                      # 覆盖 el-select 样式
├── DdfTag.vue                         # 覆盖 el-tag 样式
├── DdfBadge.vue                       # 新增 badge 样式（等级徽章）
├── DdfStatusIndicator.vue             # 新增状态指示灯（工业感）
├── DdfStatCard.vue                    # 新增统计卡片（带趋势）
├── DdfDiffView.vue                    # 新增 diff 视图（DSL 对比）
├── DdfAuditTimeline.vue               # 新增审计时间线
├── DdfWorkflowGraph.vue               # 新增状态机可视化
├── DdfGanttChart.vue                  # 新增甘特图
└── DdfBreadcrumb.vue                  # 增强面包屑
```

### 5.2 关键组件覆盖规范

#### DdfButton

```vue
<!-- 覆盖 el-button 的样式，增强企业感 -->
<style scoped>
.ddf-btn {
  /* 圆角 6px（比 Element Plus 的 4px 更现代）*/
  border-radius: var(--radius-base);
  
  /* 无渐变，纯色填充 */
  background: var(--color-primary-500);
  border: 1px solid var(--color-primary-500);
  
  /* 字体：medium weight */
  font-weight: var(--font-weight-medium);
  font-size: var(--font-size-sm);
  
  /* 无发光效果 */
  box-shadow: none;
  
  /* 过渡：快速反馈 */
  transition: background var(--transition-fast),
              border-color var(--transition-fast);
}

.ddf-btn:hover {
  background: var(--color-primary-600);
  border-color: var(--color-primary-600);
}

.ddf-btn:active {
  background: var(--color-primary-700);
  border-color: var(--color-primary-700);
}

/* 描边按钮 */
.ddf-btn--outline {
  background: transparent;
  border-color: var(--color-border-default);
  color: var(--color-text-secondary);
}

.ddf-btn--outline:hover {
  border-color: var(--color-primary-500);
  color: var(--color-primary-500);
}
</style>
```

#### DdfStatusIndicator

```vue
<!-- 工业感状态指示灯 -->
<!-- 圆形指示灯 + 状态标签 -->
<div class="ddf-status">
  <span class="ddf-status__dot" :style="{ background: statusColor }"></span>
  <span class="ddf-status__label">{{ statusLabel }}</span>
</div>

<style scoped>
.dds-status__dot {
  display: inline-block;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
  /* 无动画效果 — 工业感 = 稳定 */
}

.dds-status__label {
  font-size: var(--font-size-sm);
  color: var(--color-text-secondary);
  margin-left: var(--space-2);
}
</style>
```

#### DdfStatCard

```vue
<!-- 统计卡片 — 带趋势箭头 -->
<!-- 不使用渐变背景，纯白底 + 底部色条标识趋势 -->
<div class="ddf-stat-card">
  <div class="ddf-stat-card__value">{{ value }}</div>
  <div class="ddf-stat-card__label">{{ label }}</div>
  <div class="ddf-stat-card__trend" :class="trendClass">
    {{ trendLabel }}
  </div>
  <div class="ddf-stat-card__bar" :style="{ width: percentage + '%' }"></div>
</div>

<style scoped>
.dds-stat-card {
  background: var(--color-bg-surface);
  border: 1px solid var(--color-border-default);
  border-radius: var(--radius-base);
  padding: var(--space-4);
  position: relative;
  overflow: hidden;
}

.dds-stat-card__value {
  font-size: var(--font-size-xl);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text-primary);
}

.dds-stat-card__label {
  font-size: var(--font-size-xs);
  color: var(--color-text-secondary);
  margin-top: var(--space-1);
}

.dds-stat-card__bar {
  position: absolute;
  bottom: 0;
  left: 0;
  height: 3px;
  background: var(--color-primary-500);
}
</style>
```

### 5.3 Element Plus Token 覆盖

```typescript
// src/styles/element-overrides.ts
// 通过 Element Plus 的 CSS 变量系统覆盖默认主题

export const elementOverrides = {
  // 品牌色覆盖
  '--el-color-primary': '#1E2761',        // 深蓝
  '--el-color-primary-light-3': '#3d5bb6', // primary-400
  '--el-color-primary-light-5': '#667fc5', // primary-300
  '--el-color-primary-light-7': '#99a9d8', // primary-200
  '--el-color-primary-light-8': '#cdd3eb', // primary-100
  '--el-color-primary-light-9': '#e6e9f5', // primary-50
  
  // 圆角覆盖
  '--el-border-radius-base': '6px',        // 4px → 6px
  
  // 字体
  '--el-font-size-base': '14px',
  '--el-font-weight-primary': '500',
  
  // 阴影
  '--el-box-shadow': '0 1px 3px rgba(20, 23, 33, 0.06)',
  '--el-box-shadow-light': '0 4px 6px rgba(20, 23, 33, 0.05)',
  '--el-box-shadow-lighter': '0 1px 2px rgba(20, 23, 33, 0.04)',
  '--el-box-shadow-dark': '0 10px 15px rgba(20, 23, 33, 0.06)',
};
```

---

## 6. 主题系统

### 6.1 亮色主题

```
亮色主题：
  ├── 页面背景：steel-50 (#f6f7f9)
  ├── 卡片背景：white (#ffffff)
  ├── 文字：steel-900 (#141721) 主要，steel-500 (#51586d) 次要
  ├── 边框：steel-200 (#d6dae2)
  └── 品牌色：primary-500 (#1E2761)
```

### 6.2 暗色主题

```
暗色主题：
  ├── 页面背景：steel-900 (#141721)
  ├── 卡片背景：steel-800 (#202432)
  ├── 悬浮卡片：steel-700 (#2d3243)
  ├── 文字：steel-100 (#eaecf1) 主要，steel-300 (#a8aec0) 次要
  ├── 边框：steel-700 (#2d3243)
  └── 品牌色：primary-300 (#667fc5) — 暗色下提升亮度
```

### 6.3 高对比度主题

```
高对比度主题（无障碍需求）：
  ├── 页面背景：#000000
  ├── 卡片背景：#1a1a1a
  ├── 文字：#ffffff（所有文字至少 WCAG AAA 级）
  ├── 边框：steel-300 (#a8aec0)
  ├── 品牌色：primary-300 (#667fc5)
  └── 功能色亮度提升 20%（确保 WCAG AA 对比度）
```

### 6.4 行业 Profile 主题

```
不同行业 Profile 可微调品牌色，保持设计系统一致但体现行业特征：

┌─────────────────┬────────────────┬─────────────────────────┐
│ 行业 Profile     │ 品牌色调微调    │ 使用场景                │
├─────────────────┼────────────────┼─────────────────────────┤
│ 精密五金 MES     │ 深海蓝 #1E2761 │ 当前默认                 │
│ 电子 MES         │ 电光蓝 #1E3A5F │ 更冷、更科技感            │
│ 供应链支持       │ 靛蓝 #1E2761 + │ 稳重，强调物流感           │
│                 │ 琥珀点缀 #D97706│                          │
│ 自定义 Profile   │ 用户自定义     │ 企业客户个性化             │
└─────────────────┴────────────────┴─────────────────────────┘

Profile 主题通过 `project_config.theme.primary_color` 传递，
生成时作为 CSS 变量注入生成项目，而非修改 DDF 平台本身的主题。
```

---

## 7. 动效与微交互规范

### 7.1 动效原则

```
原则：
  ├── 功能性优先：动效服务于信息传递和空间关系，不为装饰
  ├── 速度感：所有动效 ≤ 300ms，让用户感觉"快"
  ├── 线性或 ease-out：工业感 = 直接、不拖沓
  └── 尊重用户偏好：遵循 prefers-reduced-motion
```

### 7.2 动效清单

```
必须使用动效的场景：
  ├── 侧栏展开/折叠：200ms ease-out，translateX
  ├── 页面切换：200ms ease-out，opacity + scale(0.98→1)
  ├── 下拉菜单出现：150ms ease-out，opacity + translateY(-4px→0)
  ├── 表单验证反馈：150ms，边框颜色变化 + 抖动（仅错误时）
  ├── 状态变更：200ms，边框色平滑过渡
  ├── 数据加载骨架屏：1s  shimmer（linear gradient 扫描）
  └── 按钮点击：150ms，scale(0.98) 反馈

禁止使用动效的场景：
  ├── 页面加载 hero 区域
  ├── 列表项依次入场（staggered animation）
  ├── 旋转加载 spinner
  ├── 背景粒子/光效
  └── 过渡页面/引导教程动画
```

### 7.3 骨架屏规范

```
骨架屏样式（加载态占位）：
┌────────────────────────────────────────────────────────────────┐
│  ┌──────────────┐  ┌─────────────────────────────────────┐    │
│  │              │  │                                     │    │
│  │   标题占位    │  │  内容行 1                            │    │
│  │   (120×16)   │  │  内容行 2                            │    │
│  │              │  │  内容行 3                            │    │
│  │              │  │                                     │    │
│  └──────────────┘  └─────────────────────────────────────┘    │
└────────────────────────────────────────────────────────────────┘

骨架屏规范：
  ├── 背景：steel-100 (#eaecf1)
  ├── shimmer 动画：linear-gradient(90deg, steel-100 0%, steel-200 50%, steel-100 100%)
  ├── 动画时长：1s
  ├── 圆角：4px
  └── 表格骨架：按列数生成对应数量的矩形条
```

---

## 8. 响应式与多端适配规范

### 8.1 断点系统

```css
/* 断点定义 */
:root {
  --breakpoint-sm: 640px;   /* 小屏手机 */
  --breakpoint-md: 768px;   /* 平板 */
  --breakpoint-lg: 1024px;  /* 小屏笔记本 */
  --breakpoint-xl: 1200px;  /* 桌面标准 */
  --breakpoint-2xl: 1440px; /* 大屏桌面 */
}
```

### 8.2 桌面端响应式策略

```
≥ 1200px（标准桌面）：
  ├── Sidebar 240px 展开
  ├── 内容区 padding 24px
  ├── 表格行高 48px
  └── 双栏编辑器 50/50

768-1199px（平板）：
  ├── Sidebar 200px 固定展开（不可折叠）
  ├── 内容区 padding 16px
  ├── 表格行高 44px
  └── 双栏编辑器 45/55（编辑器略宽）

< 768px（移动端）：
  ├── Sidebar 全屏抽屉（从左侧滑入）
  ├── 内容区 padding 12px
  ├── 表格改为卡片列表展示
  └── 编辑器改为单栏（编辑器在上，YAML 预览在下）
```

### 8.3 移动端适配（生成项目层面）

```
生成的移动端应用（uni-app）设计规范：

┌─────────────────────────────────────┐
│  状态栏 (20px)                      │
├─────────────────────────────────────┤
│  导航栏 (44px)                      │
│  [返回] 页面标题                    │
├─────────────────────────────────────┤
│  内容区 (自适应)                     │
│  ┌─────────────────────────────┐   │
│  │ 字段卡片 1                    │   │
│  │ 字段卡片 2                    │   │
│  │ ...                         │   │
│  └─────────────────────────────┘   │
├─────────────────────────────────────┤
│  底部操作栏 (56px)                   │
│  [取消]          [提交]             │
└─────────────────────────────────────┘

移动端设计原则：
  ├── 字体基准 16px（比桌面端大 2px）
  ├── 触摸目标 ≥ 44×44px
  ├── 卡片式布局（非表格）
  ├── 底部固定操作栏（提交/取消）
  ├── 扫码组件原生调用设备相机
  └── 离线时显示缓存数据 + 同步指示器
```

---

## 9. 设计系统交付清单

### 9.1 文件清单

```
platform/web/src/
├── styles/
│   ├── tokens/
│   │   ├── color.css              # 色彩 Token（亮色 + 暗色）
│   │   ├── typography.css          # 字体 Token
│   │   ├── space.css               # 间距/圆角/阴影 Token
│   │   └── index.css               # Token 汇总入口
│   ├── layout.css                  # 布局变量
│   ├── element-overrides.css       # Element Plus 覆盖
│   └── global.css                  # 全局重置 + 基础样式
│
├── components/
│   ├── ddf/                        # DDF 专属组件
│   │   ├── DdfButton.vue
│   │   ├── DdfTable.vue
│   │   ├── DdfTag.vue
│   │   ├── DdfBadge.vue
│   │   ├── DdfStatusIndicator.vue
│   │   ├── DdfStatCard.vue
│   │   ├── DdfDiffView.vue
│   │   ├── DdfAuditTimeline.vue
│   │   ├── DdfWorkflowGraph.vue
│   │   ├── DdfGanttChart.vue
│   │   └── index.ts                # 组件注册
│   └── layout/
│       ├── DdfLayout.vue           # Shell 布局
│       ├── DdfSidebar.vue          # 侧栏
│       ├── DdfTopbar.vue           # 顶栏
│       ├── DdfBreadcrumb.vue       # 面包屑
│       └── DdfTabs.vue             # 多标签页
│
├── composables/
│   ├── useTheme.ts                 # 主题切换
│   ├── useSidebar.ts               # 侧栏状态
│   └── useBreadcrumb.ts            # 面包屑状态
│
└── utils/
    ├── format.ts                   # 格式化（日期、数字、状态）
    ├── status.ts                   # 状态映射
    └── audit.ts                    # 审计日志格式化
```

### 9.2 落地路线图

```
Phase 1: 基础设施（第 1 周）
  ├── [x] 设计 Token 系统定义（color/typography/space）
  ├── [x] 布局架构定义
  ├── [x] Element Plus 覆盖层
  ├── ⬜ global.css + 全局重置
  ├── ⬜ DdfLayout + DdfSidebar + DdfTopbar
  └── ⬜ 主题切换系统（亮色/暗色）

Phase 2: 基础组件（第 2 周）
  ├── ⬜ DdfButton + DdfTag + DdfBadge
  ├── ⬜ DdfTable（增强版 el-table）
  ├── ⬜ DdfStatCard
  ├── ⬜ DdfStatusIndicator
  └── ⬜ DdfBreadcrumb

Phase 3: 领域组件（第 3-4 周）
  ├── ⬜ DdfDiffView（DSL 行级 diff）
  ├── ⬜ DdfAuditTimeline
  ├── ⬜ DdfWorkflowGraph（状态机可视化）
  ├── ⬜ DdfGanttChart（工艺甘特图）
  └── ⬜ DdfStatCard（带趋势）

Phase 4: 页面整合（第 5-6 周）
  ├── ⬜ 模型设计器页面（整合编辑器 + YAML 预览 + 校验报告）
  ├── ⬜ 模型市场页面（卡片列表 + 搜索 + 筛选）
  ├── ⬜ 项目生成中心（项目列表 + 新建弹窗 + 进度）
  ├── ⬜ 用户中心（订阅信息 + 用量趋势）
  └── ⬜ 响应式适配（平板 + 移动端）

Phase 5: 优化与验收（第 7 周）
  ├── ⬜ WCAG AA 无障碍检查
  ├── ⬜ 暗色主题完整验证
  ├── ⬜ 性能优化（首次加载 < 1.5s）
  └── ⬜ 设计系统文档化
```

---

## 附录 A：命名约定

```
CSS 变量命名：
  --color-{area}-{shade}       例：--color-primary-500
  --color-{semantic}           例：--color-status-running
  --font-size-{semantic}       例：--font-size-base
  --space-{number}             例：--space-4
  --radius-{semantic}          例：--radius-base
  --shadow-{level}             例：--shadow-sm
  --layout-{element}-{prop}    例：--layout-sidebar-width

Vue 组件命名：
  Ddf{ComponentName}           例：DdfStatCard
  全部 PascalCase
  
CSS 类命名：
  ddf-{component}__{element}   例：ddf-stat-card__value
  ddf-{component}--{modifier}  例：ddf-btn--outline
  ddf-{component}--state       例：ddf-table--loading

Composable 命名：
  use{Feature}                 例：useTheme
  use{Domain}                  例：useBreadcrumb
```

## 附录 B：禁止使用的模式速查

```
[ban] 禁止：
  ├── linear-gradient() 用于按钮/卡片背景
  ├── backdrop-filter: blur() 用于面板/弹窗
  ├── @keyframes 用于装饰性动画（粒子、波纹、旋转）
  ├── box-shadow 模拟光晕效果
  ├── 圆角 > 12px（除全圆角标签外）
  ├── 字体大小 < 11px（除 tag 文字外）
  ├── 表格行高 < 40px（桌面端）
  ├── 同一页面使用 > 2 种功能色
  ├── 空状态使用插画
  ├── 页面加载使用 hero 区域
  ├── 侧栏使用彩色图标
  ├── 使用 emoji 作为功能图标
  ├── 过度动画（> 300ms 的过渡）
```

## 附录 C：对比 — DDF vs 常见开源前端

| 维度 | Element Plus 默认 | Ant Design Vue | DDF 定制版 |
|------|------------------|----------------|-----------|
| 品牌色 | `#409eff`（亮蓝） | `#1890ff`（科技蓝） | `#1E2761`（深海蓝） |
| 圆角 | `4px` | `2px` | `6px` |
| 侧栏图标 | 彩色 iconfont | 线性 iconfont | 灰度 iconfont（steel-400） |
| 表格行高 | `40px` | `36px` | `44px` |
| 阴影层级 | 3 级 | 3 级 | 3 级（更克制） |
| 状态色 | Element 默认 | Ant 默认 | 工业信号灯语义 |
| 暗色主题 | 完整支持 | 完整支持 | 完整支持（钢灰色阶） |
| 字体 | 系统默认 | 系统默认 | 系统默认 + 中文优化 |
| 特色组件 | 无 | 无 | DdfDiffView, DdfWorkflowGraph |
| 空状态 | 插画 | 插画 | 文字 + 操作引导（无插画） |

---

*文档版本: v1.0 | 创建日期: 2026-07-14 | 作者: 产品设计专家（UI/UX）角色*