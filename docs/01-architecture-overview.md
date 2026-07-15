# DomainDriveFramework — 架构设计文档 v2.1

> 面向离散制造/工业制造领域的领域驱动 + AI 生成应用开发框架  
> 核心形态：**模型设计中心 (SaaS) + 代码生成工厂 + 项目交付应用**  
> 小团队 + AI 维护开发 · 用户规模 100~1000 人 · 私有化部署 / SaaS 双模式  
> 业务模型设计中心是核心盈利资产，项目交付是独立收入流

---

## 1. 产品定位与设计目标

### 1.1 核心理念

**模型即资产，交付即分叉。**

本框架将业务系统的构建拆分为三个独立解耦的环节：

```
业务模型设计中心 (SaaS)        代码生成工厂                项目交付应用
┌─────────────────────┐     ┌────────────────┐     ┌─────────────────────┐
│ 离散制造通用模型     │     │                │     │ 项目 A（客户甲）      │
│ ├─ 精密五金 MES      │ ──→ │  根据选择的     │ ──→ │ ├─ generated/       │
│ ├─ 电子 MES          │     │  行业 Profile   │     │ └─ custom/ (二开)   │
│ └─ 供应链支持        │     │  全量生成       │     │                     │
│                     │     │                │     │ 项目 B（客户乙）      │
│ 模型可分享、继承      │     │  输出可部署包   │     │ ├─ generated/       │
│ 业务专家 + Agent 共建 │     │                │     │ └─ custom/ (二开)   │
└─────────────────────┘     └────────────────┘     └─────────────────────┘
        ↑ 持续运营                        独立收入             不升级不回灌
```

**三个核心原则：**

| 原则 | 说明 |
|------|------|
| **模型即资产** | 业务模型 DSL 是核心知识产权，可积累、可迭代、可分享、可销售 |
| **交付即分叉** | 项目生成交付后与模型设计中心断开关联，二开不回灌 |
| **全量生成** | 不做增量/差异生成，每次基于完整 Profile 全量生成可部署包 |

### 1.2 设计目标

| 维度 | 目标 |
|------|------|
| **业务响应速度** | 行业模型定义后，DSL 修改到生成可部署包 ≤ 30 分钟 |
| **开发效率** | 小团队（1~3 人）维护行业模型，单项目交付无需全栈人力 |
| **AI 友好度** | 领域 DSL 结构化，AI Agent 可直接读写操作（CRUD API + 语义操作） |
| **私有化部署** | 生成的应用全套 Docker 化，数据不出内网 |
| **SaaS 运营** | 模型设计中心云化，支持多租户、模型分享市场、计费分层 |
| **领域模板预设** | 离散制造通用模型 + 各行业 Profile 预设，开箱即用可修改 |
| **未来扩展** | 预留设备时序数据接入、IoT 网关扩展接口 |

### 1.3 量化验收指标

| 指标 | 目标值 | 测量方式 |
|------|--------|----------|
| 行业 Profile 从零到首次可生成 | ≤ 2 周 | 新行业 DSL 编写到生成代码通过 lint |
| 生成代码的可运行率 | 首次 ≥ 80%，迭代 ≥ 95% | 生成的 Python/Vue 通过 lint + 编译 |
| 模板渲染性能 | ≥ 100 实体/秒 | CI 日志记录渲染耗时 |
| 生成的 API 响应时间 (P95) | < 500ms | 集成测试 + APM 监控 |
| 并发用户支持 | 100~1000 用户下系统稳定 | 压力测试（目标 CPU < 70%, 无错误） |
| 代码生成覆盖率 | 后端 CRUD 100%，前端 CRUD ≥ 90% | 解析 DSL 字段映射到生成代码的覆盖检查 |
| DSL Schema 合规率 | 100% | 提交时 JSON Schema 校验 |
| 生成代码行覆盖率（测试） | ≥ 80% | pytest --cov |
| SaaS 模型分享市场 | 上线 6 个月内 ≥ 50 个社区模型 | 平台统计 |
| Agent API 可用性 | 99.5% | SLA 监控 |

---

## 2. 整体架构（三层模型）

### 2.1 架构总览

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                  第一层：业务模型设计中心 (Domain Design Hub — SaaS)                   │
│                                                                                     │
│   ┌──────────────────────────────────────────────────────────────────────────────┐  │
│   │                              用户层                                           │  │
│   │   ┌───────────────┐  ┌───────────────┐  ┌───────────────┐                     │  │
│   │   │  业务专家       │  │  AI Agent      │  │  集成商/团队   │                     │  │
│   │   │  Web UI 设计   │  │  API 调用      │  │  API + Web   │                     │  │
│   │   └───────┬───────┘  └───────┬───────┘  └───────┬───────┘                     │  │
│   └───────────┼───────────────────┼───────────────────┼───────────────────────────┘  │
│               │                   │                   │                              │
│   ┌───────────▼───────────────────▼───────────────────▼───────────────────────────┐  │
│   │                               接入层                                           │  │
│   │   ┌────────────────┐  ┌────────────────┐  ┌────────────────┐                   │  │
│   │   │  Web IDE       │  │  REST API      │  │  WebSocket     │                   │  │
│   │   │  (Vue 3 + MD)  │  │  (Agent SDK)   │  │  (实时协作)    │                   │  │
│   │   └────────────────┘  └────────────────┘  └────────────────┘                   │  │
│   └────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                     │
│   ┌──────────────────────────────────────────────────────────────────────────────┐  │
│   │                               业务层                                           │  │
│   │                                                                               │  │
│   │   ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐           │  │
│   │   │   模型管理         │  │   模型分享市场     │  │   项目生成        │           │  │
│   │   │   ├─ 设计器        │  │   ├─ 公开模型     │  │   ├─ 选择 Profile│           │  │
│   │   │   ├─ 版本历史      │  │   ├─ 社区排行     │  │   ├─ 配置参数    │           │  │
│   │   │   ├─ 校验         │  │   ├─ 继承关系     │  │   ├─ 生成预览    │           │  │
│   │   │   └─ 预览         │  │   └─ 授权管理     │  │   └─ 下载部署包  │           │  │
│   │   └──────────────────┘  └──────────────────┘  └──────────────────┘           │  │
│   │                                                                               │  │
│   │   ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐           │  │
│   │   │   用户/租户管理    │  │   计费与授权       │  │   Agent 编排     │           │  │
│   │   │   ├─ 多租户       │  │   ├─ 免费层       │  │   ├─ 模型 CRUD   │           │  │
│   │   │   ├─ RBAC        │  │   ├─ 付费层       │  │   ├─ 生成触发     │           │  │
│   │   │   ├─ 团队协作     │  │   ├─ 企业版       │  │   └─ Agent SDK   │           │  │
│   │   │   └─ SSO         │  │   └─ 按量计费     │  │                   │           │  │
│   │   └──────────────────┘  └──────────────────┘  └──────────────────┘           │  │
│   └──────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                     │
│   ┌──────────────────────────────────────────────────────────────────────────────┐  │
│   │                          模型仓库 (Model Repository)                          │  │
│   │                                                                               │  │
│   │   ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐           │  │
│   │   │   base/          │  │  industries/      │  │  projects/       │           │  │
│   │   │   通用模型        │  │   行业 Profile    │  │   项目实例       │           │  │
│   │   │   (离散制造)      │  │   (继承/独立)    │  │   (客户专属)     │           │  │
│   │   └──────────────────┘  └──────────────────┘  └──────────────────┘           │  │
│   └──────────────────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────┬──────────────────────────────────────────────────┘
                                   │ 选择 Profile + 配置参数 → 触发生成
                                   ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                        第二层：代码生成工厂 (Code Generation Factory)                 │
│                                                                                     │
│   ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌──────────┐                │
│   │ 模型     │→ │ 模板     │→ │ 冲突     │→ │ 质量     │→ │ 打包输出 │                │
│   │ 解析器   │  │ 渲染引擎  │  │ 解决器   │  │ 门禁     │  │          │                │
│   │ YAML→AST│  │ Jinja2  │  │ custom/  │  │ 四道 Gate│  │ 可部署包  │                │
│   └─────────┘  └─────────┘  └─────────┘  └─────────┘  └──────────┘                │
│                                                                                     │
│   ┌──────────────────────────────────────────────────────────────────────────────┐  │
│   │                       生成产物：项目交付包                                    │  │
│   │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌─────────┐           │  │
│   │  │ FastAPI  │ │  Vue 3   │ │ uni-app  │ │ PostgreSQL│ │ manifest│           │  │
│   │  │ 后端     │ │ PC 前端  │ │ 移动端   │ │ Schema   │ │ .json   │           │  │
│   │  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └─────────┘           │  │
│   └──────────────────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────┬──────────────────────────────────────────────────┘
                                   │ 下载部署包 → 独立项目交付
                                   ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                     第三层：项目交付应用 (独立项目，不升级不回灌)                      │
│                                                                                     │
│   ┌──────────────────────────────────────────────────────────────────────────────┐  │
│   │                     项目 A — 精密五金 MES (独立 Git 仓库)                      │  │
│   │                                                                               │  │
│   │   ┌────────────────────────────┐  ┌──────────────────────────────────┐       │  │
│   │   │  generated/                │  │  custom/                         │       │  │
│   │   │  ├─ backend/models/        │  │  ├─ custom_reports.py             │       │  │
│   │   │  ├─ backend/routers/       │  │  ├─ external_integration/        │       │  │
│   │   │  ├─ frontend/views/        │  │  └─ custom_workflow_ext.py       │       │  │
│   │   │  └─ mobile/pages/          │  │                                   │       │  │
│   │   └────────────────────────────┘  └──────────────────────────────────┘       │  │
│   │                                                                               │  │
│   │   ┌──────────────────────────────────────────────────────────────────────┐   │  │
│   │   │  metadata/manifest.json (溯源用，不做升级)                            │   │  │
│   │   └──────────────────────────────────────────────────────────────────────┘   │  │
│   └──────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                     │
│   ┌──────────────────────────────────────────────────────────────────────────────┐  │
│   │                     项目 B — 电子 MES (独立 Git 仓库)                          │  │
│   │  (同上结构，不同 Profile 生成)                                                │  │
│   └──────────────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 三层职责划分

#### 2.2.1 第一层：业务模型设计中心 (SaaS)

> **谁使用：** 业务专家（Web UI）、AI Agent（API）、集成商团队  
> **核心产出：** 结构化领域模型（DSL YAML）+ 项目交付包  
> **关键原则：** 模型即核心资产，支持多租户、模型分享、计费分层

| 组件 | 职责 |
|------|------|
| **通用模型库 (base/)** | 离散制造领域核心实体预定义（工单/BOM/工艺路线/班次/用户） |
| **行业 Profile (industries/)** | 各行业业务模型，可继承 base 或独立设计 |
| **项目实例 (projects/)** | 客户专属模型定制（引用 Profile + 项目级配置） |
| **模型分享市场** | 社区模型发布、继承、授权管理 |
| **Web IDE** | 业务专家在线编辑模型，所见即所得 |
| **Agent API** | AI Agent 通过 REST API 操作模型（CRUD + 校验 + 生成触发） |
| **用户/计费系统** | 多租户管理 + 免费/付费/企业三层计费 |

#### 2.2.2 第二层：代码生成工厂

> **谁使用：** CLI 工具 / SaaS 平台内部调用  
> **核心产出：** 可直接运行的 FastAPI 后端 + Vue 前端 + uni-app 移动端  
> **关键原则：** 全量生成，不做增量；输出可部署包

| 组件 | 职责 |
|------|------|
| **模型解析器** | 解析组合后的 DSL（base + industry override + project config）→ AST |
| **模板渲染引擎** | 基于 Jinja2，全量渲染所有模板文件 |
| **后端模板** | FastAPI 路由、SQLAlchemy ORM、Pydantic Schema、Alembic 迁移 |
| **前端模板** | Vue 3 页面组件、Element Plus 表单/表格、API 调用、路由 |
| **移动端模板** | uni-app 页面、uView Plus 组件、扫码组件、API 调用、路由 |
| **冲突解决器** | 识别 custom/ 目录中与生成代码同名的文件，输出告警 |
| **质量门禁** | 四道 Gate（语法 → 引用完整 → 安全 → 编译验证）|
| **打包输出** | 生成完整项目目录结构 + manifest.json 元数据 |

#### 2.2.3 第三层：项目交付应用

> **谁使用：** 最终业务用户（各角色按权限使用系统功能）  
> **核心产出：** 可部署的 Web 系统  
> **关键原则：** 交付即分叉，二开不回灌，不提供模型升级

| 组件 | 技术栈 | 说明 |
|------|--------|------|
| **FastAPI 后端** | FastAPI 0.110+ / SQLAlchemy 2.0 / Pydantic | 自动生成 CRUD + 状态流 + 权限校验 |
| **Vue 3 PC 前端** | Vue 3 + TypeScript + Element Plus + Pinia | 自动生成列表/详情/表单/状态操作 |
| **uni-app 移动端** | uni-app (Vue 3) + uView Plus | 自动生成扫码/表单/查询页面 |
| **PostgreSQL 数据库** | PostgreSQL 16 + TimescaleDB | 关系数据 + 时序数据（设备接入用） |
| **异步任务** | APScheduler | 定时统计、超时提醒 |
| **custom/ 二开目录** | 与 generated/ 同层 | 存放项目独占的二开代码，永不覆盖 |

### 2.3 交付即分叉原则

**这是框架的核心契约：**

```
模型设计中心 (SaaS)                                项目交付 (独立项目)
┌────────────────┐                               ┌──────────────────────┐
│ 模型 v1.0      │  ──生成──→  项目 A 交付包      │ 项目 A 代码仓库       │
│ 精密五金 MES   │                               │ ├─ generated/ (冻结)  │
│                │                               │ ├─ custom/ (二开)    │
│ 模型 v2.0      │                               │ └─ 不回灌、不升级    │
│ (更新了状态机)  │                               │                      │
│                │  ──生成──→  项目 B 交付包      │ 项目 B 代码仓库       │
└────────────────┘                               │ (如果客户要新版本，   │
                                                  │  推倒重做 = 新项目)  │
                                                  └──────────────────────┘
```

**为什么不做模型升级：**
1. 交付后二开往往包含 dirty 的现场定制（对接特定系统、硬编码），无法回灌到模型
2. 升级的冲突解决方案（diff merge / API 签名快照 / 断裂引用检测）占用了框架 40% 的复杂度
3. 撤销这部分复杂度，将资源投入 SaaS 平台化——更符合「一人企业卖铲子」的商业模式

**约定：**
- 交付后所有变更在 `custom/` 中二开解决
- 如需基于新模型重建，按新项目计费
- 模型设计中心提供 `migrate-check` 工具，辅助评估二开代码在新模型下的兼容性（仅分析，不自修复）

---

## 3. 模型继承体系

### 3.1 三层模型结构

```
domain/                              ← 模型仓库（Git 管理 / SaaS 数据库）
├── base/                            ← 第 1 层：通用模型（离散制造核心）
│   ├── core/                        # 核心实体
│   │   ├── work_order.yaml          # 工单
│   │   ├── bom.yaml                 # BOM
│   │   ├── process_route.yaml       # 工艺路线
│   │   ├── shift.yaml               # 班次
│   │   └── user.yaml                # 用户/角色
│   ├── workflows/                   # 通用状态流
│   └── permissions/                 # 基础权限
│
├── industries/                      ← 第 2 层：行业 Profile
│   ├── precision_metal/             # 精密五金（继承 base）
│   │   ├── industry.yaml            # Profile 声明
│   │   ├── overrides/               # 扩展/覆盖
│   │   └── entities/                # 行业特有实体
│   ├── electronics/                 # 电子制造（继承 base）
│   │   └── ...
│   ├── food/                        # 食品制造（继承 base）
│   │   └── ...
│   └── supply_support/              # 销售支持（独立设计）
│       └── ...
│
├── projects/                        ← 第 3 层：项目实例（客户专属）
│   ├── customer_metal_a/
│   │   ├── project.yaml             # 引用 Profile + 项目配置
│   │   └── customizations.yaml      # 项目级定制
│   └── customer_electronics_b/
│       └── ...
│
├── schemas/                         # 数据字典（枚举、选项，跨层共享）
├── permissions/                     # 跨层共享权限定义
└── templates/                       # 行业模板（MES/PLM/WMS）
```

### 3.2 通用模型库 (base/)

离散制造领域共享的核心实体定义。这些实体是所有制造业 MES/ERP 系统的共同基础。

```yaml
# domain/base/core/work_order.yaml
domain: base.work_order
name: 工单（通用）
version: 1.0.0
description: 离散制造通用工单实体，各行业 Profile 在此基础上扩展

entities:
  - name: WorkOrder
    label: 工单
    table: work_order

    fields:
      - name: order_no
        type: string
        label: 工单编号
        primary_key: true
        generate: true
        generate_rule: "WO{YYYYMMDD}{SEQ5}"
        sequence:
          strategy: redis
          scope: daily
          padding: 5

      - name: product_code
        type: string
        label: 产品编码
        max_length: 64
        required: true

      - name: product_name
        type: string
        label: 产品名称
        max_length: 128

      - name: quantity
        type: integer
        label: 计划数量
        required: true
        validate:
          min: 1
          error: "计划数量必须大于 0"

      - name: completed_quantity
        type: integer
        label: 已完成数量
        default: 0

      - name: status
        type: enum
        label: 工单状态
        values: pending, running, paused, completed, cancelled
        default: pending
        status_field: true
        workflow_ref: work_order_flow

      - name: priority
        type: enum
        label: 优先级
        values: low, normal, high, urgent
        default: normal
        options:
          low:    { label: 低, color: "#d9d9d9" }
          normal: { label: 中, color: "#1890ff" }
          high:   { label: 高, color: "#fa8c16" }
          urgent: { label: 紧急, color: "#f5222d" }

      - name: plan_start_date
        type: date
        label: 计划开始日期
        required: true

      - name: plan_end_date
        type: date
        label: 计划完成日期

      - name: actual_start_time
        type: datetime
        label: 实际开始时间
        auto_fill:
          trigger: status = "running"
          value: NOW()
        read_only: true

      - name: actual_end_time
        type: datetime
        label: 实际完成时间
        auto_fill:
          trigger: status = "completed"
          value: NOW()
        read_only: true

      - name: remark
        type: string
        label: 备注
        max_length: 500

      - name: created_by
        type: relation
        label: 创建人
        relation: User
        auto_fill: CURRENT_USER
        read_only: true

      - name: created_at
        type: datetime
        label: 创建时间
        auto_fill: NOW()
        read_only: true

      - name: updated_at
        type: datetime
        label: 更新时间
        auto_fill: NOW_ON_UPDATE

    relations:
      - name: bom_items
        target: BOMItem
        type: has_many
        inverse_of: work_order
        label: BOM 明细

    list_view:
      columns:
        - field: order_no
          label: 工单编号
          sortable: true
        - field: product_code
          label: 产品编码
        - field: product_name
          label: 产品名称
        - field: quantity
          label: 计划数量
          align: right
        - field: completed_quantity
          label: 已完成
          align: right
        - field: status
          label: 状态
          formatter: status_tag
        - field: priority
          label: 优先级
          formatter: status_tag
        - field: plan_start_date
          label: 计划开始
      search_fields:
        - field: order_no
          type: input
          placeholder: "工单编号"
        - field: status
          type: select
          options_from_field: status
          placeholder: "状态"
        - field: priority
          type: select
          options_from_field: priority
          placeholder: "优先级"

    permissions:
      read:      [operator, supervisor, admin]
      create:    [supervisor, admin]
      write:     [operator, supervisor, admin]
      delete:    [admin]
      transition:
        pending → running:  [operator, admin]
        running → paused:   [operator, admin]
        running → completed: [operator, admin]
        paused → running:   [operator, admin]
        * → cancelled:       [admin]

    import_export:
      import:
        allowed: true
        max_rows: 5000
      export:
        allowed: true
        max_rows: 10000
        formats: [xlsx, csv]
```

```yaml
# domain/base/core/bom.yaml
domain: base.bom
name: BOM（通用）
version: 1.0.0

entities:
  - name: BOMItem
    label: BOM 明细
    table: bom_item
    fields:
      - name: id
        type: integer
        label: ID
        primary_key: true
        generate: true
        sequence:
          strategy: db
      - name: work_order_id
        type: relation
        label: 所属工单
        relation: WorkOrder
        required: true
      - name: material_code
        type: string
        label: 物料编码
        max_length: 64
        required: true
      - name: material_name
        type: string
        label: 物料名称
        max_length: 128
      - name: required_qty
        type: integer
        label: 需求数量
        required: true
        validate:
          min: 1
---

# domain/base/core/process_route.yaml
domain: base.process_route
name: 工艺路线（通用）
version: 1.0.0

entities:
  - name: ProcessRoute
    label: 工艺路线
    table: process_route
    fields:
      - name: id
        type: integer
        label: ID
        primary_key: true
      - name: product_code
        type: string
        label: 产品编码
        required: true
      - name: step_no
        type: integer
        label: 工序序号
        required: true
      - name: step_name
        type: string
        label: 工序名称
        required: true
      - name: standard_time_minutes
        type: integer
        label: 标准工时(分钟)
```

**通用模型库的设计原则：**
1. **最小化核心**——只包含离散制造领域**100% 共通的实体和字段**
2. **可扩展性**——各行业通过 override 添加行业特有字段，不修改 base
3. **单一版本**——base 只有 current 版本，不存在多版本共存

### 3.3 行业 Profile (industries/)

行业 Profile 是业务模型的核心单元。每个 Profile 定义了一个行业的完整业务模型。

#### 3.3.1 Profile 声明

```yaml
# domain/industries/precision_metal/industry.yaml
name: precision_metal
label: 精密五金制造
version: 1.0.0
extends: base                            # 继承通用模型
description: 精密五金行业 MES 业务模型

strategy:
  inheritance: additive                   # additive | standalone

# ── 元数据（SaaS 平台用）──
metadata:
  author: "DomainForge"
  tags: [mes, manufacturing, metal]
  industry_category: discrete_manufacturing
  target_customers: [中小型五金厂, 模具厂, 机加工厂]
  pricing_tier: standard                  # free | standard | premium | enterprise
```

#### 3.3.2 继承策略

| 策略 | 说明 | 适用场景 |
|------|------|---------|
| `additive` | base 实体全部继承，可新增字段/关系/实体，不可删除 base 字段 | 精密五金 MES、电子 MES 等与 base 高度相关的行业 |
| `standalone` | 不继承 base，完全独立设计 | 销售支持、采购支持等非制造领域 |

#### 3.3.3 实体扩展

```yaml
# domain/industries/precision_metal/overrides/work_order_ext.yaml
extends_entity: WorkOrder                  # 指明扩展 base 中的哪个实体

extend_fields:                             # 新增字段（只增不减）
  - name: material_hardness
    type: float
    label: 材料硬度
    required: false
    validate:
      min: 0
      max: 100

  - name: tooling_code
    type: string
    label: 模具编号
    max_length: 32
    required: false

  - name: heat_treat_required
    type: boolean
    label: 需热处理
    default: false

modify_workflow:                           # 扩展状态流
  - state: quenching
    label: 淬火中
    color: "#eb2f96"
    can_transit: [completed]
    on_enter:
      - action: auto_fill
        field: actual_start_time
        value: NOW()
  - state: tempering
    label: 回火中
    color: "#722ed1"
    can_transit: [completed]

extend_list_view:                          # 扩展列表视图
  columns:
    - field: material_hardness
      label: 材料硬度
    - field: tooling_code
      label: 模具编号

extend_permissions:                        # 扩展权限
  transition:
    running → quenching: [heat_treat_operator, admin]
    quenching → tempering: [heat_treat_operator, admin]
```

#### 3.3.4 行业特有实体

```yaml
# domain/industries/precision_metal/entities/quality_check.yaml
domain: precision_metal.quality_check
name: 五金质检记录
version: 1.0.0
description: 精密五金行业的质检专用实体

entities:
  - name: QualityCheck
    label: 质检记录
    table: quality_check

    fields:
      - name: id
        type: integer
        label: ID
        primary_key: true
      - name: work_order_id
        type: relation
        label: 关联工单
        relation: WorkOrder
        required: true
      - name: check_type
        type: enum
        label: 质检类型
        values: dimension, hardness, surface, assembly
        required: true
        options:
          dimension: { label: 尺寸检测, color: "#1890ff" }
          hardness:  { label: 硬度检测, color: "#52c41a" }
          surface:   { label: 表面检测, color: "#fa8c16" }
          assembly:  { label: 装配检测, color: "#722ed1" }
      - name: measured_value
        type: float
        label: 测量值
      - name: tolerance_min
        type: float
        label: 下限公差
      - name: tolerance_max
        type: float
        label: 上限公差
      - name: result
        type: enum
        label: 判定结果
        values: pass, fail, rework
        default: pass
        options:
          pass:   { label: 合格, color: "#52c41a" }
          fail:   { label: 不合格, color: "#f5222d" }
          rework: { label: 返工, color: "#fa8c16" }
      - name: inspector
        type: relation
        label: 质检员
        relation: User
        auto_fill: CURRENT_USER
      - name: check_time
        type: datetime
        label: 质检时间
        auto_fill: NOW()
```

#### 3.3.5 独立设计的行业 Profile

```yaml
# domain/industries/supply_support/industry.yaml
name: supply_support
label: 供应链管理
version: 1.0.0
extends: null                             # 不从 base 继承
strategy:
  inheritance: standalone

entities:
  - name: PurchaseOrder
    label: 采购订单
    # ... 完全自定义实体定义
  - name: Supplier
    label: 供应商
    # ... 完全自定义实体定义
  - name: ProcurementRequest
    label: 采购申请
    # ... 完全自定义实体定义
```

### 3.4 项目实例 (projects/)

项目实例是客户级别的模型定制。每个项目引用一个行业 Profile，并允许项目级的额外配置。

```yaml
# domain/projects/customer_metal_a/project.yaml
name: customer_metal_a
label: 某精密五金厂 MES 项目
version: 1.0.0
profile: precision_metal                    # 引用行业 Profile
profile_version: 1.0.0

# ── 项目级配置 ──
config:
  database:
    prefix: cust_a_                         # 表名前缀
    schema: public

  theme:
    primary_color: "#1E2761"                # 客户品牌色
    logo_url: "https://customer-a.com/logo.png"

  features:
    - barcode_scan
    - mobile_report
    - external_api

# ── 项目级实体定制（额外字段，不反向影响 Profile）──
customizations:
  entities:
    - WorkOrder:
        extend_fields:
          - name: customer_specific_tag
            type: string
            label: 客户专属标记
            max_length: 16
```

### 3.5 模型组合规则

生成时的 DSL 组合逻辑：

```python
# 伪代码：生成时如何组合 DSL
def compose_dsl(project_id: str) -> AST:
    project = load_project(project_id)
    profile = load_industry(project.profile)
    
    base_dsl = load_base() if profile.extends == "base" else []
    industry_dsl = load_industry_dsl(profile)
    project_dsl = load_project_customizations(project)
    
    # 合并顺序（后面覆盖前面）
    combined = merge_dsls([
        base_dsl,               # 1. base 通用模型
        industry_dsl,           # 2. 行业 Profile（override + add_entities）
        project_dsl             # 3. 项目定制
    ])
    return combined
```

**合并规则：**

| 场景 | 规则 | 示例 |
|------|------|------|
| 字段新增 | 合并入实体字段列表 | base + industry 的字段都保留 |
| 字段同名 | industry 版本覆盖 base | 重写字段的 validate 规则 |
| 状态新增 | 追加到状态列表 | base 状态 + industry 特有状态 |
| 实体新增 | 添加到 entities 列表 | industry 特有实体独立存在 |
| 关系新增 | 追加到 relations 列表 | 扩展实体间关系 |
| 权限扩展 | 合并权限配置 | industry 新增的 transition 权限 |
| 视图扩展 | 合并列定义 | industry 字段追加到 base 列之后 |

**项目→Profile 反馈通道（非强制）：**
项目层 `customizations.yaml` 中的字段扩展可以"提议"到所引用 Profile 的下一版本。Profile 维护者通过 diff 工具审阅后选择性合并。此通道仅用于模型市场生态的协作演进，不改变"交付即分叉"的核心契约——已交付项目不会自动接收更新。

---

## 4. 领域模型 DSL 设计

### 4.1 DSL 文件格式

采用 **YAML** 格式，每个模型对象一个文件，按目录组织（§3 结构）。

所有 DSL 文件受 **JSON Schema** 约束，定义在 `domain/domain-schema.json`：

```yaml
# yaml-language-server: $schema=domain/domain-schema.json
domain: entity_name
name: 实体名称
```

> 所有 DSL 文件必须通过 `domain-schema.json` 的校验，不符合 Schema 的变更将被拒绝。

### 4.2 核心概念定义

以下 DSL 语法定义适用于 base / industry / project 三层模型，共享同一套语法。

#### 4.2.1 实体 (Entity)

实体是领域模型的核心单位，对应数据库中的一张表。

##### 字段类型一览

| 字段类型 | 用途 | 关键属性 |
|----------|------|----------|
| `string` | 文本、编码、短描述 | `max_length`, `generate`, `generate_rule` |
| `integer` | 数量、整数标识 | `min`, `max`, `default` |
| `float` | 金额、比率、精度数值 | `precision`, `default` |
| `boolean` | 开关、标记 | `default` |
| `date` | 日期（无时间） | `auto_fill`, `required` |
| `datetime` | 时间戳、操作时间 | `auto_fill`, `auto_fill.trigger` |
| `enum` | 下拉选项、状态、分类 | `values`, `options.color`, `status_field`, `workflow_ref` |
| `relation` | 关联其他实体 | `relation`（目标实体名）, `required` |

##### 字段属性说明

| 属性 | 适用范围 | 说明 |
|------|----------|------|
| `primary_key` | string | 标记为主键字段 |
| `generate` | string | 是否自动生成值，配合 `generate_rule` 定义生成规则 |
| `sequence` | generate 字段 | 分布式序列策略：`strategy`（redis/db/snowflake）、`scope`（daily/global）、`padding` |
| `auto_fill` | date/datetime/relation | 自动填充：`NOW()`、`CURRENT_USER`、或条件触发 `trigger: status = "x"` |
| `validate` | integer/float/string | 校验规则：`min`、`max`、`pattern`、`error`（自定义错误信息） |
| `status_field` | enum | 标记该字段为状态字段，配合 `workflow_ref` 引用状态流定义 |
| `options` | enum | 枚举值的扩展配置：`label`（显示名）、`color`（标签颜色） |
| `read_only` | 任意 | 是否只读，生成代码中将忽略该字段的写入 |

##### 关系类型

| 类型 | 说明 | 关键属性 |
|------|------|----------|
| `has_many` | 一对多：当前实体拥有多个目标实体 | `target`, `inverse_of`, `cascade` |
| `belongs_to` | 多对一：当前实体从属于目标实体 | `target`, `foreign_key` |
| `has_one` | 一对一 | `target`, `inverse_of` |
| `many_to_many` | 多对多 | `target`, `through`（中间表） |

##### 实体 DSL 完整语法

```yaml
# domain/entities/example_entity.yaml（非绑定业务，仅语法示意）
domain: example_entity
name: 示例实体
version: 1.0.0
description: 演示实体 DSL 的语法结构

entities:
  - name: EntityName
    label: 实体名称
    table: entity_table_name
    description: 实体说明

    fields:
      - name: id_field
        type: string
        label: 标识字段
        primary_key: true
        generate: true
        generate_rule: "{PREFIX}{YYYYMMDD}{SEQ5}"
        sequence:
          strategy: redis
          scope: daily
          padding: 5

      - name: name_field
        type: string
        label: 名称
        max_length: 64
        required: true

      - name: quantity_field
        type: integer
        label: 数量
        required: true
        validate:
          min: 0
          error: "数量不能为负"

      - name: status_field
        type: enum
        label: 状态
        values: state_a, state_b, state_c
        default: state_a
        status_field: true
        workflow_ref: entity_flow

      - name: category_field
        type: enum
        label: 分类
        values: type_x, type_y, type_z
        default: type_x
        options:
          type_x: { label: 类别X, color: #1890ff }
          type_y: { label: 类别Y, color: #52c41a }
          type_z: { label: 类别Z, color: #fa8c16 }

      - name: date_field
        type: date
        label: 日期

      - name: timestamp_field
        type: datetime
        label: 时间戳
        auto_fill: NOW()
        read_only: true

      - name: ref_field
        type: relation
        label: 关联实体
        relation: RelatedEntity
        required: true

      - name: creator
        type: relation
        label: 创建人
        relation: User
        auto_fill: CURRENT_USER
        read_only: true

      - name: created_at
        type: datetime
        label: 创建时间
        auto_fill: NOW()
        read_only: true

      - name: updated_at
        type: datetime
        label: 更新时间
        auto_fill: NOW_ON_UPDATE

    relations:
      - name: child_entities
        target: ChildEntity
        type: has_many
        inverse_of: parent_ref
        cascade: delete
        label: 子实体列表

      - name: parent_entity
        target: ParentEntity
        type: belongs_to
        foreign_key: ref_field
        label: 所属父实体

    list_view:
      columns:
        - field: id_field
          label: 编号
          sortable: true
        - field: name_field
          label: 名称
        - field: quantity_field
          label: 数量
          align: right
        - field: status_field
          label: 状态
          formatter: status_tag
        - field: date_field
          label: 日期
      search_fields:
        - field: id_field
          type: input
          placeholder: "编号"
        - field: status_field
          type: select
          options_from_field: status_field
          placeholder: "状态"

    detail_view:
      layout: tabs
      tabs:
        - name: 基本信息
          groups:
            - label: 核心信息
              fields:
                - id_field
                - name_field
                - quantity_field
                - status_field
            - label: 时间信息
              fields:
                - date_field
                - timestamp_field
                - created_at
        - name: 子实体
          type: relation_table
          relation: child_entities
          show_create: true

    permissions:
      read:      [role_a, role_b, admin]
      create:    [role_a, admin]
      write:     [role_a, role_b, admin]
      delete:    [admin]
      transition:
        state_a → state_b: [role_a, admin]
        state_b → state_c: [role_b, admin]
        * → state_c:        [admin]

    import_export:
      import:
        allowed: true
        template_fields: [field_a, name_field, quantity_field]
        validation: [unique_check, enum_check, required_check]
        max_rows: 5000
      export:
        allowed: true
        max_rows: 10000
        formats: [xlsx, csv]
        include_relations: [child_entities]
```

#### 4.2.2 状态流 (Workflow)

状态流定义了单个实体在其状态字段上的合法转移路径。每个 workflow 文件对应一个实体的状态机。

```yaml
# domain/workflows/entity_flow.yaml（与 base/industries 的实体关联）
name: work_order_flow
label: 工单状态流
entity: WorkOrder
field: status

states:
  pending:
    label: 待开工
    color: "#d9d9d9"
    icon: clock-circle
    can_transit: [running, cancelled]
    description: 工单已创建，等待开工

  running:
    label: 生产中
    color: "#1890ff"
    icon: play-circle
    can_transit: [paused, completed, cancelled]
    description: 工单正在生产
    on_enter:
      - action: auto_fill
        field: actual_start_time
        value: NOW()

  paused:
    label: 已暂停
    color: "#faad14"
    icon: pause-circle
    can_transit: [running, cancelled]
    description: 生产暂停

  completed:
    label: 已完成
    color: "#52c41a"
    icon: check-circle
    terminal: true
    description: 工单全部完工
    on_enter:
      - action: auto_fill
        field: actual_end_time
        value: NOW()
      - action: validate
        rule: "completed_quantity == quantity"
        error: "完成数量必须等于计划数量才能完工"

  cancelled:
    label: 已取消
    color: "#f5222d"
    icon: stop
    terminal: true
    description: 工单已取消

transitions:
  - from: pending
    to: running
    label: 开工
    require_comment: false

  - from: running
    to: paused
    label: 暂停
    require_comment: true
    comment_placeholder: "请输入暂停原因"

  - from: paused
    to: running
    label: 恢复生产
    require_comment: false

  - from: running
    to: completed
    label: 完工
    require_comment: false

  - from: pending
    to: cancelled
    label: 取消
    require_comment: true

  - from: running
    to: cancelled
    label: 取消
    require_comment: true

  - from: paused
    to: cancelled
    label: 取消
    require_comment: true
```

| 配置项 | 说明 |
|--------|------|
| `states[].terminal` | 该状态是否为终态，终态不可再转移 |
| `states[].can_transit` | 从该状态可转移到的目标状态列表 |
| `states[].on_enter[]` | 进入该状态时触发的动作（`auto_fill` 自动填充字段、`validate` 校验规则） |
| `transitions[].require_comment` | 该转移是否需要填写备注 |
| `transitions[].comment_placeholder` | 备注输入框的占位文字 |

#### 4.2.3 业务规则 (Business Rule)

业务规则用于声明跨实体或单实体内的数据校验约束、聚合计算逻辑。支持三种规则类型：

> **表达式引擎：** 所有条件表达式（`condition`、`aggregate.filter`）底层使用 **simpleeval** 引擎执行，采用白名单模式——仅允许算术比较（`+`、`-`、`*`、`/`、`==`、`!=`、`<`、`>`、`<=`、`>=`）、逻辑运算（`and`、`or`、`not`）和字段引用（`$entity.field`、聚合结果）。禁止任意代码执行、函数调用、属性访问。执行超时限制 500ms。

| 规则类型 | 用途 | 触发时机 |
|----------|------|----------|
| **数据校验** | 创建/更新时校验字段间的约束 | `trigger.events: [create, update]` |
| **状态转移校验** | 状态流转时校验是否可转移 | `trigger.events: [transition]` + `from_status` / `to_status` |
| **聚合计算** | 根据关联实体数据自动推导字段值 | `trigger.events: [created, updated, deleted]` + `target_entity` |

```yaml
# domain/rules/business_rules.yaml
rules:
  # 数据校验：创建/更新时检查
  - id: rule_qty_check
    name: 数量校验
    entity: WorkOrder
    description: BOM 明细数量之和不得超过工单计划数量
    trigger:
      events: [create, update]
    validate:
      condition:
        operator: le
        left:
          aggregate:
            function: sum
            source: BOMItem.required_qty
            filter:
              field: work_order_id
              operator: eq
              value: "$entity.id"
        right:
          field: quantity
    error_message: "BOM 明细数量之和不得超过工单计划数量"

  # 状态转移校验
  - id: rule_complete_guard
    name: 完工守卫
    entity: WorkOrder
    trigger:
      events: [transition]
      from_status: running
      to_status: completed
    validate:
      condition:
        operator: eq
        left:
          field: completed_quantity
        right:
          field: quantity
    error_message: "完成数量必须等于计划数量才能完工"

  # 聚合计算
  - id: rule_derive_qty
    name: 自动汇总完成数量
    entity: WorkOrder
    type: derived_field
    field: completed_quantity
    trigger:
      events: [created, updated, deleted]
      target_entity: ProductionReport
    auto_calculate:
      aggregate: sum
      source: ProductionReport.reported_qty
      filter: "work_order_id = :id"
```

#### 4.2.4 权限角色 (Permissions)

支持三级粒度：

| 粒度 | 配置 | 说明 |
|------|------|------|
| **实体级** | `scope: EntityName` | 控制对整个实体的 CRUD 权限 |
| **字段级** | `fields: [field_a, field_b]` | 限制角色只能看到指定字段 |
| **行级** | `row_filter: "org_id = current_user.org_id"` | 通过 SQL 表达式限制数据行范围 |

```yaml
# domain/permissions/roles.yaml
roles:
  - name: admin
    label: 管理员
    permissions:
      - operation: "*"
        scope: "*"

  - name: operator
    label: 操作员
    permissions:
      - operation: [read, create, write]
        scope: WorkOrder
      - operation: [read]
        scope: BOMItem

  - name: supervisor
    label: 主管
    permissions:
      - operation: [read, create, write, delete]
        scope: WorkOrder
      - operation: [read]
        scope: [BOMItem, ProcessRoute]
        fields: [*]
        except_fields: [sensitive_field]
```

#### 4.2.5 移动端配置

```yaml
# 在实体定义中添加 mobile_config 节
mobile_config:
  form_fields:
    - field: barcode_field
      type: barcode_scan
      label: 扫码输入
      required: true
      placeholder: "请扫描条码"
    - field: picker_field
      type: picker
      label: 选择项
      data_source: RelatedEntity
    - field: number_field
      type: number
      label: 数量
      required: true
    - field: remark_field
      type: textarea
      label: 备注
  buttons:
    - type: primary
      action: submit
      label: 提交
    - type: default
      action: reset
      label: 重置
```

| 移动端组件 | DSL type | 说明 |
|-----------|----------|------|
| 条码/二维码扫描 | `barcode_scan` | 调用设备相机扫码 |
| 选择器 | `picker` | 下拉/弹出选择 |
| 数字步进器 | `number` | 带 +/- 按钮的数字输入 |
| 文本输入 | `text` | 单行文本输入 |
| 多行文本 | `textarea` | 多行文本域 |
| 条件显隐 | — | 通过 `show_when` 控制 |

#### 4.2.6 主题配置 (Theme)

```yaml
# domain/theme.yaml
theme:
  tokens:
    primary_color: "#1890ff"
    success_color: "#52c41a"
    warning_color: "#faad14"
    danger_color: "#f5222d"
    info_color: "#8c8c8c"
  mode:
    default: light
    allow_dark_mode: true
    high_contrast: false
  typography:
    font_family: "-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
    font_size_base: 14px
    font_size_mobile: 16px
    border_radius: 4px
  spacing:
    xs: 4px
    sm: 8px
    md: 16px
    lg: 24px
    xl: 32px
  status_colors:
    pending:   "#d9d9d9"
    running:   "#1890ff"
    paused:    "#faad14"
    completed: "#52c41a"
    cancelled: "#f5222d"
  dark_mode:
    background: "#141414"
    surface: "#1f1f1f"
    text_primary: "#e8e8e8"
    border: "#303030"
```

#### 4.2.7 跨实体业务编排 (Workflow Orchestration)

> 与实体状态流的关系：状态流管理**单个实体**的状态机，业务编排管理**跨实体**的流程协作。

##### 设计原则

1. **事件驱动**：以实体字段变更或生命周期事件作为触发点
2. **声明式 DSL**：YAML 描述"当 X 发生时，执行 Y"
3. **轻量无状态**：每次事件触发独立评估，不维护长流程状态
4. **可补偿**：关键业务操作定义逆向补偿动作

##### DSL 结构

```yaml
# domain/orchestration/example.yaml
name: example_orchestration
label: 示例编排流程
version: 1.0.0

triggers:
  - id: trigger_example
    name: 示例触发器
    on:
      entity: WorkOrder
      event: status.changed
      from: [pending]
      to: [running]
    condition: "bom_items_count > 0"
    then:
      - action: create_entity
        target: ProductionRecord
        fields:
          work_order_id: "$entity.id"
          status: pending
      - action: notify
        to_role: [operator]
        message: "工单 {{ entity.order_no }} 已开工"
        via: [in_app]

compensations:
  - id: compensation_example
    name: 示例补偿
    on:
      entity: ProductionRecord
      event: deleted
    then:
      - action: update_entity
        target: WorkOrder
        where: { id: "$entity.work_order_id" }
        set: { status: pending }
        reason: "关联生产记录已删除，工单回退"

timeouts:
  - id: timeout_example
    name: 超时告警
    on:
      entity: WorkOrder
      state: running
    duration: 48h
    mode: polling
    then:
      - action: notify
        to_role: [supervisor]
        severity: warning
        message: "工单 {{ entity.order_no }} 已生产超过 48 小时"

parallel:
  - id: parallel_example
    name: 并行分支
    on:
      entity: WorkOrder
      event: status.changed
      to: [completed]
    fork:
      - action: create_entity
        target: CompletionReport
        fields: { work_order_id: "$entity.id" }
      - action: notify
        to_role: [supervisor, admin]
        message: "工单 {{ entity.order_no }} 已完成"
      - action: auto_calculate
        target: WorkOrder
        field: completed_quantity
        method: recalc_aggregate
```

##### 编排执行机制

```
事件总线 (Event Bus)
├── 实体 create / update / delete 事件监听
├── 超时调度器（polling / delayed_queue）
└── 事件日志

编排引擎
  1. 匹配 trigger.on 条件
  2. 评估 condition 表达式
  3. 顺序/并行执行 then 动作
  4. 记录执行日志
  5. 异常时触发 compensation
```

### 4.3 DSL Schema 校验规则

DSL 的完整 JSON Schema 定义在 `domain/domain-schema.json`，主要校验规则：

| 校验项 | 规则 | 错误示例 | 正确示例 |
|--------|------|----------|----------|
| **实体命名** | snake_case, ≤ 64 字符 | `EntityNameTest` | `entity_name_test` |
| **字段类型** | 必须是预定义类型之一 | `type: unknown_type` | `type: string` |
| **关系引用** | `relation` 必须指向已定义实体 | `relation: Nonexistent` | `relation: WorkOrder` |
| **枚举值** | `values` 中不允许重复 | `values: a, b, a` | `values: a, b, c` |
| **继承引用** | 行业 Profile 的 `extends` 必须指向 base 或 null | `extends: nonexistent` | `extends: base` 或 `extends: null` |
| **权限实体** | `permissions.scope` 引用的实体必须已定义 | `scope: UnknownEntity` | `scope: WorkOrder` |
| **循环继承** | 禁止 Profile 循环继承（A→B→A） | industry_a→base, industry_b→industry_a | 严格单向 |
| **字段重复** | override 中不能定义与 base 同名的字段（除非明确意图） | base 已有 `name`，override 又定义同名字段 | 使用 `extend_fields` 语义 |

> 校验在以下时机自动执行：
> 1. SaaS 平台模型保存时
> 2. CLI 工具运行 `ddflow validate` 时
> 3. 生成前进行最终校验

---

## 5. 代码生成引擎

### 5.1 生成流程

```
组合后的 DSL AST（base + industry override + project config）
         │
         ▼
┌─────────────────────┐
│  1. Model Parser     │ 解析组合后的 AST → 内部模型表示
│                     │ 校验 JSON Schema
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  2. Template Engine  │ 全量渲染所有模板
│                     │
│  ┌────────────────┐ │  ┌────────────────┐
│  │  Backend       │ │  │  Frontend      │
│  │  Generator     │ │  │  Generator     │
│  │  - ORM Model   │ │  │  - List.vue   │
│  │  - Schema      │ │  │  - Detail.vue │
│  │  - Router      │ │  │  - Form.vue   │
│  │  - Service     │ │  │  - API.ts     │
│  │  - Migration   │ │  │  - Router     │
│  │  - RBAC        │ │  └────────────────┘
│  └────────────────┘ │
│                     │
│  ┌────────────────┐ │  ┌────────────────┐
│  │  Mobile        │ │  │  Orchestration  │
│  │  Generator     │ │  │  Generator     │
│  │  - pages/      │ │  │  - handlers   │
│  │  - components/ │ │  │  - compensations│
│  │  - api/        │ │  │  - timeouts    │
│  │  - router/     │ │  └────────────────┘
│  └────────────────┘ │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  3. Conflict         │ 检查 custom/ 中是否存在同名文件
│     Resolver         │ 输出冲突警告（不自动覆盖 custom/）
└──────────┬──────────┘
           │
           ▼
┌──────────────────────────────────────────────────┐
│  4. 质量门禁 (Quality Gates)                      │
│                                                  │
│  Gate A: 语法检查                                 │
│    Python: flake8 + mypy                          │
│    Vue/TS: eslint + tsc --noEmit                  │
│    uni-app: 编译检查                              │
│                                                  │
│  Gate B: 引用完整性检查                            │
│    所有 generated/ 中跨文件引用有效                 │
│    所有 custom/ 引用指向已生成的符号                 │
│                                                  │
│  Gate C: 安全扫描                                 │
│    - SQL 注入检测（参数化查询强制）                  │
│    - 权限遗漏检测（每个路由必有装饰器）               │
│    - 敏感信息暴露检测（password/secret 等）          │
│                                                  │
│  Gate D: 编译验证 + 基础测试                       │
│    - 后端 FastAPI 应用启动验证                      │
│    - 前端 Vite 构建验证                            │
│    - 基础 CRUD 测试运行                            │
└──────────────────────┬───────────────────────────┘
                       │
                       ▼
┌─────────────────────┐
│  5. Pack & Output    │ 输出完整项目目录
│                     │ + manifest.json 元数据
│                     │ + 部署配置（Docker Compose）
└─────────────────────┘
```

### 5.2 全量生成策略

**核心原则：每次基于完整的 DSL 组合，全量渲染所有文件，不保留增量状态。**

与 v1.x 增量策略的关键差异：

| 维度 | v1.x 增量策略 | v2.0 全量策略 |
|------|--------------|--------------|
| Change Detector | 对比新旧 AST，只渲染差异 | 不需要（每次都全量） |
| 渲染范围 | 只渲染变更实体及其依赖 | 渲染所有实体 |
| 性能目标 | 增量 < 50ms | 全量 50 实体 < 2s |
| 复杂度 | 高（需维护新旧 AST 差异） | 低（无状态） |
| custom/ 保护 | 通过复杂 merge 算法 | 简单同名检查 + 告警 |

**渲染性能优化：**

| 优化手段 | 说明 | 预期效果 |
|----------|------|----------|
| **模板缓存** | Jinja2 模板编译结果按文件 hash 缓存 | 全量渲染从 N 秒降至 TTFB 级别 |
| **并行渲染** | 无依赖的实体渲染任务并行执行 | 批量渲染耗时降低 60%+ |
| **AST 缓存** | 同一 DSL 文件未修改时，直接使用缓存 AST | 减少重复解析开销 |

> **性能目标：** 全量渲染（50 实体, 4 个 Profile）< 10s

### 5.3 项目目录结构

生成的项目交付包目录结构：

```
project_name/
├── backend/
│   ├── generated/                    # 自动生成目录（全量覆盖）
│   │   ├── models/
│   │   ├── schemas/
│   │   ├── routers/
│   │   ├── services/
│   │   ├── migrations/
│   │   └── orchestration/
│   ├── custom/                       # 手写扩展目录（永不覆盖）
│   │   ├── models/
│   │   ├── routers/
│   │   └── services/
│   ├── app.py                        # FastAPI 入口
│   ├── config.py
│   ├── database.py
│   ├── permissions.py
│   └── requirements.txt
│
├── frontend/
│   ├── generated/
│   │   ├── views/
│   │   ├── api/
│   │   └── router/
│   ├── custom/
│   │   ├── views/
│   │   └── components/
│   ├── src/
│   │   ├── main.ts
│   │   ├── App.vue
│   │   ├── store/
│   │   ├── composables/
│   │   ├── directives/
│   │   └── utils/
│   ├── index.html
│   └── package.json
│
├── mobile/                           # uni-app 项目
│   ├── generated/
│   │   ├── pages/
│   │   ├── api/
│   │   └── router/
│   ├── custom/
│   ├── pages/
│   ├── components/
│   ├── static/
│   └── manifest.json
│
├── deploy/
│   ├── docker-compose.yml
│   ├── nginx/
│   │   ├── dev.conf
│   │   └── prod.conf
│   └── scripts/
│       ├── init-db.sh
│       └── deploy.sh
│
└── metadata/
    └── manifest.json                  # 生成元数据（溯源用）
```

### 5.4 冲突解决策略

因为采用全量生成策略，冲突解决大大简化：

| 场景 | 处理方式 |
|------|---------|
| `generated/` 中已有文件 | 直接覆盖（全量重新生成） |
| `custom/` 中已有文件 | 永不覆盖，保留不动 |
| `custom/` 文件引用了 `generated/` 中的符号 | Gate B 检查引用完整性，输出断裂报告 |
| 新生成的文件名与 `custom/` 中同名 | **告警：** 输出冲突报告，列出 custom/ 中的同名文件 |
| 二开代码需要引用新生成的符号 | 开发者手动修改 custom/ 中的 import 语句 |

### 5.5 质量门禁

#### Gate A: 语法检查

```
Python: flake8 + mypy（backend/generated/）
Vue/TS: eslint + tsc --noEmit（frontend/generated/）
uni-app: 编译检查（mobile/generated/）
失败 → 阻断部署
```

#### Gate B: 引用完整性检查

```
扫描 generated/ 中所有跨文件 import 是否有效
扫描 custom/ 中所有对 generated/ 符号的引用是否仍然存在
输出断裂引用报告（位置 + 建议修复方式）
失败 → 告警 + 建议（不阻断 custom/ 断裂引用，但阻断 generated/ 内部断裂）
```

#### Gate C: 安全扫描

```
- SQL 注入检测：扫描所有 row_filter / condition 表达式是否使用参数化查询
  检测规则：正则扫描 $entity.xxx 拼接模式，路径遍历模式
- 权限遗漏检测：每个 API 路由必须有 @require_permission 或 @require_role 装饰器
  ✅ 装饰器存在 → 通过
  ❌ 装饰器缺失 → 阻断
  例外：公开端点白名单（/health, /ready, /docs, /openapi.json, /auth/login 等）自动豁免。
  白名单在模板中通过 `@public` 装饰器或路由配置中的 `public: true` 标记声明。
- 敏感信息暴露检测：Schema 中是否意外暴露敏感字段（password_hash, token 等）
  规则：基于字段命名黑名单 + 字段注释中的 @sensitive 标记
失败 → 阻断部署，生成安全报告
```

#### Gate D: 编译验证

```
后端: uvicorn 启动验证 + 基础 health check
前端: Vite build 验证
移动端: uni-app 编译验证（语法级别）
基础测试: 生成的 conftest.py + 默认 CRUD 测试
失败 → 阻断部署
```

### 5.6 测试策略

#### 生成引擎自身的测试

| 测试层级 | 覆盖范围 | 工具 | CI 要求 |
|----------|----------|------|---------|
| **单元测试** | Parser 解析、模板渲染、质量门禁 | pytest | 覆盖率 ≥ 90% |
| **模板渲染测试** | 每个 Jinja2 模板渲染输出正确性 | pytest + snapshot | 模板变更时自动运行 |
| **集成测试** | DSL → 生成完整项目 → 编译通过 | pytest + subprocess | 每次提交时执行 |
| **端到端测试** | 生成后端 → 启动 → 调用 API → 验证响应 | pytest + httpx + Docker | 每次发布时执行 |

#### 生成代码的测试

生成引擎同时生成基础测试文件：

```
backend/generated/tests/
├── conftest.py              # 测试夹具
├── test_work_order.py       # CRUD 测试 + 状态流转测试
├── test_permissions.py      # 权限校验测试
└── test_orchestration.py    # 编排流程测试
```

| 测试类型 | 生成内容 |
|----------|----------|
| API 测试 | 每个 CRUD 端点的基础请求/响应测试 |
| 状态流转测试 | Workflow 中每条 transition 的合法性 |
| 权限测试 | 各角色对 CRUD 的访问控制 |
| 编排测试 | 每条 trigger 条件匹配、action 执行 |

### 5.7 生成引擎插件架构

采用插件架构支持扩展新的生成器类型。

```python
# generator/plugin.py
class GeneratorPlugin(ABC):
    @property
    @abstractmethod
    def name(self) -> str: ...
    
    @abstractmethod
    def can_handle(self, dsl_section: str) -> bool: ...
    
    @abstractmethod
    async def generate(self, context: GenerationContext) -> GenerationResult: ...
```

```
generator/
  ├── plugins/                     # 插件目录（热加载）
  │   ├── __init__.py
  │   ├── report_generator.py      # 报表生成插件
  │   └── chart_generator.py       # 图表配置生成插件
  ├── core/                        # 核心引擎
  │   ├── parser/
  │   ├── diff/
  │   └── renderer/
  └── plugin.py                    # 插件基类
```

### 5.8 CLI 与 SaaS 的关系

生成引擎核心（parser + renderer + gates）由 CLI 和 SaaS 共享，两者使用同一套代码：

| 维度 | CLI 工具（ddflow） | SaaS 平台 |
|------|-------------------|-----------|
| **使用场景** | 本地开发调试、离线内网环境、CI/CD 集成 | 云端模型管理、团队协作、一键生成 |
| **模型来源** | 本地 `domain/` 目录（Git 管理） | SaaS 数据库 + 模型市场 |
| **输出** | 本地目录生成 | 对象存储下载包 |
| **鉴权** | 无（本地运行） | 多租户 + RBAC + API Key |
| **依赖** | Python 3.11+ 本地环境 | Docker 容器化部署 |
| **离线支持** | ✅ 完全支持（有 Python 即可） | ❌ 需要网络连接 |

> **离线交付场景：** 对于内网客户，集成商可在联网环境使用 SaaS 设计模型，导出 DSL 包，然后在客户内网使用 CLI 执行 `ddflow generate` 完成生成和部署。

### 5.9 运行时错误溯源

所有生成的 API handler 自动注入诊断信息：

```python
@router.post("")
@track_generated(
    dsl_source="industries/precision_metal:v1.0.0, project:customer_a",
    template="generator/templates/backend/router.j2:v1.0.0",
    generated_at="2026-07-11T10:30:00Z"
)
async def create(data: WorkOrderCreate, db=Depends(get_db)):
    ...
```

溯源标签在响应 header 中可见：

```http
X-Generated-From: industries/precision_metal:v1.0.0
X-Generated-By-Template: router.j2:v1.0.0
X-Generated-At: 2026-07-11T10:30:00Z
```

---

## 6. SaaS 平台设计

### 6.1 平台架构

```
┌──────────────────────────────────────────────────────────┐
│                   Domain Design Hub (SaaS)                │
│                                                          │
│  ┌─────────────────────────────────────────────────────┐ │
│  │                  接入层                               │ │
│  │  ┌──────────────────┐  ┌──────────────────┐         │ │
│  │  │  Web UI (Vue 3)  │  │  REST API v1      │         │ │
│  │  │  ├─ 模型设计器    │  │  ├─ 模型 CRUD    │         │ │
│  │  │  ├─ 模型市场     │  │  ├─ Agent 接口   │         │ │
│  │  │  ├─ 项目生成     │  │  ├─ 生成触发     │         │ │
│  │  │  └─ 用户中心     │  │  └─ 计费查询     │         │ │
│  │  └──────────────────┘  └──────────────────┘         │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌─────────────────────────────────────────────────────┐ │
│  │                  业务层                               │ │
│  │                                                      │ │
│  │  ┌────────────────┐  ┌────────────────┐             │ │
│  │  │  模型管理       │  │  项目生成      │             │ │
│  │  │  ├─ base 查看   │  │  ├─ 选择 Profile│             │ │
│  │  │  ├─ Profile     │  │  ├─ 配置参数  │             │ │
│  │  │  │   设计/继承  │  │  ├─ 生成预览  │             │ │
│  │  │  ├─ 校验/预览   │  │  └─ 下载/部署 │             │ │
│  │  │  └─ 导出/导入   │  │              │             │ │
│  │  └────────────────┘  └────────────────┘             │ │
│  │                                                      │ │
│  │  ┌────────────────┐  ┌────────────────┐             │ │
│  │  │  模型分享市场   │  │  用户/计费    │             │ │
│  │  │  ├─ 公开模型库  │  │  ├─ 多租户   │             │ │
│  │  │  ├─ 继承关系图  │  │  ├─ RBAC    │             │ │
│  │  │  ├─ 排行/搜索  │  │  ├─ 免费/付费│             │ │
│  │  │  └─ 授权管理   │  │  └─ 企业版   │             │ │
│  │  └────────────────┘  └────────────────┘             │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌─────────────────────────────────────────────────────┐ │
│  │                  数据层                               │ │
│  │  PostgreSQL (模型数据 + 租户 + 用户 + 计费)            │ │
│  │    └─ base/industries/projects/ 模型表                │ │
│  │    └─ users/tenants/subscriptions/ 用户表             │ │
│  │    └─ marketplace_models/ 市场模型表                   │ │
│  │  Redis (会话 + 缓存 + 任务队列)                        │ │
│  │  对象存储 (模型包下载 + 静态资源)                       │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌─────────────────────────────────────────────────────┐ │
│  │                生成引擎层（调用已部署的工厂）           │ │
│  └─────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
```

### 6.2 用户与租户管理

```
用户类型:
├── 免费用户
│   
├── 付费用户
│   
└── 企业版
```

### 6.3 计费模型

```
免费层（获客入口）
├── 1 project, 每天 1 gen
├── 业务模型列表上限，10个
├── ❌ 无 AI 自然语言建模能力
├── 手动 YAML 编辑 + 表单配置 （提供拖拉拽）
├── 浏览 + 继承公开市场模型 ， 每天继承 3 个
├── 目的：让用户体验模型设计 + 生成能力
└── 收入：0

标准层（¥xxx/月）
├── 5 projects, 每日 10 gen
├── 业务模型列表上限，50个
├── 浏览 + 继承公开模型设计，每天10个
├── ✅ **AI 自然语言建模**
│   ├── 用自然语言描述业务场景，AI 自动生成业务模型
│   ├── 示例："帮我创建一个工单管理实体，包含编号、产品、数量、状态字段"
│   │       → 自动生成 WorkOrder DSL + 状态机 + 权限
│   ├── 示例："为精密五金 MES 的质检流程增加硬度检测字段"
│   │       → 自动在 QualityCheck 实体中添加字段并调整校验规则
│   ├── 限制：**200 次/月**（约每天 7 次，满足日常建模需求）
│   └── 超出后按 ¥x/次 计费
├── MCP Agent API（标准接入，共享队列）
├── 目的：独立开发者 / 小团队 / 集成商
└── 收入：主要收入来源

企业版（¥xxxx/月）
├── 不限 projects, 不限 gen
├── 业务模型列表上下不限，版本管理
├── 浏览 + 继承公开市场模型，不限制继承次数
├── ✅ **AI 自然语言建模**
│   ├── 与标准版同等的自然语言能力
│   ├── 限制：**2,000 次/月**（标准版的 10 倍）
│   ├── 超出后按 ¥x/次 计费（单价低于标准版超量）
│   └── 可购买附加包（¥xxx/月 额外 2,000 次）
├── 私有化部署（生成工厂输出到客户内网）
├── 专属 MCP Agent API（独立队列，低延迟）
├── SSO / 审计日志 / 专属技术支持
├── 目的：中大型企业 / 高要求集成商
└── 收入：稳定订阅收入

企业增值服务层（独立采购，非订阅包含）
├── **精益/数字化赋能咨询**
│   ├── 精益生产诊断与改善方案
│   ├── 数字化绩效指标体系建设
│   ├── 从手工管理到数字化升级的路径规划
│   └── 按项目收费（¥xx,xxx ~ ¥xxx,xxx/期）
│
├── **领域业务设计支撑**
│   ├── 行业专家驻场梳理业务模型
│   ├── 定制行业 Profile（非标准行业的专属模型建设）
│   ├── 与客户团队联合建模，知识转移
│   └── 按人天收费（¥x,xxx/天）或按模型包收费
│
├── **项目实施服务**
│   ├── 生成应用的现场部署与对接
│   ├── 与客户现有系统（ERP/WMS/PLM）的集成开发
│   ├── 数据迁移与历史数据清洗
│   ├── 用户培训与上线支持
│   └── 按项目打包收费，或按人月收费
│
├── **全周期客户服务**
│   ├── SLA 分级（7×8 / 7×24 响应）
│   ├── 专属客户成功经理
│   ├── 季度业务健康检查与模型优化建议
│   ├── 应急预案与灾备保障
│   └── 年度服务合同（¥xx,xxx ~ ¥xxx,xxx/年）
│
└── **二开/定制开发**
    ├── 客户在 custom/ 二开中遇到的复杂需求
    ├── 报表/看板/大屏定制开发
    ├── IoT 设备接入与数据采集对接
    └── 按工单计费或按功能点定价

项目生成按量包（增值服务）
├── 一次性额外生成次数（¥x/次）
├── 私有部署包（¥xxxx/次）
└── 目的：非订阅客户的零散需求
```

**模型分享市场的激励机制（基于模型等级）：**

```
模型分享者:
├── 📦 **普通模型贡献者**
│   ├── 公开模型被继承使用 → 获得平台积分 / 收益分成（基础比例）
│   ├── 高继承量的模型 → 获得社区声望排名
│   └── 可申请精选认定

├── ⭐ **精选模型贡献者**
│   ├── 获得"官方认证"标识（个人主页 + 模型标注）
│   ├── 收益分成比例提升（如：50% → 70%）
│   ├── 模型展示在首页推荐位
│   ├── 优先获得平台技术支持
│   └── 参与平台官方模型库建设的合作机会

模型使用者:
├── 免费用户：浏览 + 继承公开模型（含精选和普通）
├── 付费用户：浏览 + 继承 + 反馈评分
└── 企业版：创建私有模型 + 选择性公开 + 优先审核通道
```

### 6.4 Agent 接口设计

模型设计中心的 Agent API 允许 AI Agent 直接操作模型、触发生成。
接口采用 **MCP 协议**（Model Context Protocol）作为 Agent 的标准接入层。

#### 6.4.1 为什么用 MCP

| 维度 | 自建 REST API | MCP 协议 |
|------|--------------|---------|
| **Agent 接入成本** | 每个 Agent 写适配代码 | 开箱即用 — Claude Code、Cursor、Zed、Copilot 原生支持 |
| **工具发现** | 人工写文档 | 自动暴露 — Agent 调用 `list_tools` 即可发现所有能力 |
| **参数 Schema** | 自己维护 OpenAPI | 内置 JSON Schema，MCP SDK 自动处理 |
| **生态红利** | 0 | 指数级 — 每个 MCP 兼容的 Agent 都是平台的潜在用户 |

#### 6.4.2 计费分层与速率限制

MCP Server 根据订阅层执行速率限制，通过 `X-Tier` 认证头区分用户等级：

| 层级 | AI 自然语言建模 | MCP API 队列 | 额外说明 |
|------|---------------|-------------|---------|
| **免费层** | ❌ 不可用 | 无 MCP 接入 | 仅手动 YAML/表单编辑 |
| **标准层** | ✅ 200 次/月 | 共享队列（平均响应 < 2s） | 超出后 ¥x/次 |
| **企业版** | ✅ 2,000 次/月 | 独立队列（平均响应 < 500ms） | 可购买附加包 |

速率限制在 MCP Server 层实现：

```python
# MCP Server 启动时读取用户 token 对应的 tier
TIER_LIMITS = {
    "free":     {"nlp_calls": 0,     "queue": None},
    "standard": {"nlp_calls": 200,   "queue": "shared", "overage_price": "¥x/次"},
    "enterprise":{"nlp_calls": 2000, "queue": "dedicated", "overage_price": "¥x/次"},
}

@server.call_tool()
async def handle_call_tool(name: str, arguments: dict) -> list[types.TextContent]:
    user_tier = await get_user_tier(request.headers["Authorization"])
    
    # 自然语言建模工具需要计费检查
    if name in ["nlp_describe_model", "nlp_add_fields", "nlp_modify_entity"]:
        if user_tier == "free":
            raise PermissionError("免费用户不支持 AI 自然语言建模")
        remaining = await check_nlp_quota(user_id, user_tier)
        if remaining <= 0:
            raise QuotaExceededError(
                f"{user_tier} 用户本月 NLP 调用额度已用完，"
                f"超量单价：{TIER_LIMITS[user_tier]['overage_price']}"
            )
        await deduct_nlp_quota(user_id, 1)
    
    result = await dispatch_to_rest_api(name, arguments)
    return [types.TextContent(type="text", text=json.dumps(result))]
```

#### 6.4.3 AI 自然语言建模工具

这是标准版和企业版的核心差异化功能——Agent 将自然语言描述直接转化为 DSL 操作，无需手动编写 YAML。

```python
# 工具 1：自然语言描述 → 生成实体 DSL
@server.register_tool()
async def nlp_describe_model(
    profile: str,
    description: str,       # "帮我创建一个工单管理实体，包含编号、产品、数量、状态字段"
    base_entity: str = None # 可选：在已有实体上扩展
) -> list[types.TextContent]:
    """
    用自然语言描述业务需求，AI 自动生成或修改 DSL 模型。
    限制：标准版 200 次/月，企业版 2,000 次/月
    """
    dsl_changes = await ai_dsl_generator(description, profile, base_entity)
    # 展示差异预览
    return format_diff(dsl_changes)

# 工具 2：自然语言描述 → 修改状态流
@server.register_tool()
async def nlp_modify_workflow(
    profile: str,
    entity: str,
    description: str        # "为工单增加一个'质检中'状态，从'生产中'可以质检，质检完成回到'生产中'"
) -> list[types.TextContent]:
    ...

# 工具 3：自然语言 → 添加字段
@server.register_tool()
async def nlp_add_fields(
    profile: str,
    entity: str,
    description: str        # "为质检记录增加硬度检测字段，范围 0-100，必填"
) -> list[types.TextContent]:
    ...
```

#### 6.4.4 MCP 工具定义

```http
# 读取当前模型全部定义
GET /api/v1/models/{model_id}/export
→ 返回完整 DSL YAML

# 通过结构化指令修改模型
POST /api/v1/models/{model_id}/apply-changes
{
  "changes": [
    {
      "action": "add_field",
      "entity": "WorkOrder",
      "field": {
        "name": "priority",
        "type": "enum",
        "values": "low,normal,high,urgent",
        "default": "normal"
      }
    },
    {
      "action": "modify_workflow",
      "entity": "WorkOrder",
      "state": {"add": "expedited", "color": "#722ed1"}
    }
  ]
}
→ 返回校验结果 + 新 DSL 预览

# 校验模型完整性
POST /api/v1/models/{model_id}/validate
→ 返回校验报告（通过/失败 + 错误列表）

# 触发生成
POST /api/v1/models/{model_id}/generate
{
  "profile": "precision_metal",
  "project_config": {
    "database_prefix": "cust_a_",
    "theme": {
      "primary_color": "#1E2761",
      "logo_url": "https://..."
    }
  },
  "output_format": "zip"
}
→ 返回生成任务 ID + 预计完成时间
```

#### 6.4.5 Agent 协作流程

```
业务专家 (Web UI)                 AI Agent (API)                Design Hub
      │                              │                            │
      │── 创建"精密五金MES"模型 ──▶    │                            │
      │                              │── POST /models ─────────▶  │
      │                              │                            │
      │── 定义工单实体 ───────────▶    │                            │
      │                              │── POST /model/apply-changes▶│
      │                              │                            │
      │                              │◀── 建议：缺少工艺路线关联 ───│
      │                              │                            │
      │◀── 建议：是否添加 ProcessRoute?──│                          │
      │                              │                            │
      │── 确认添加 ────────────────▶    │                            │
      │                              │── POST /model/apply-changes▶│
      │                              │                            │
      │                              │── POST /model/validate ──▶ │
      │                              │◀── 校验通过 ───────────────│
      │                              │                            │
      │── 触发生成 ────────────────▶    │                            │
      │                              │── POST /model/generate ──▶ │
      │                              │                            │
      │◀── 下载链接：pkg_xxxx.zip ─────│                            │
```

#### 6.4.6 可操作性检查

生成 API 返回生成包下载链接（对象存储），供 Agent 下载后部署或供用户直接下载。

```http
GET /api/v1/generation-tasks/{task_id}
→ {
    "task_id": "gen_20260711_103000_abc123",
    "status": "completed",
    "download_url": "https://storage.domainforge.com/packages/gen_20260711_103000_abc123.zip",
    "expires_at": "2026-07-12T10:30:00Z",
    "manifest": {
      "profile": "precision_metal:v1.0.0",
      "project": "customer_a",
      "files_generated": 142,
      "total_lines": 54200,
      "gates_passed": {"A": true, "B": true, "C": true, "D": true}
    }
  }
```

### 6.5 模型分享市场

#### 6.5.1 市场结构与模型分级

模型市场中的模型分为三个等级，不同等级对应不同的质量认证、曝光度和权限：

```
模型市场首页
├── ⭐ **精选模型 / 行业模型**（官方认定）
│   ├── 认定标准：
│   │   ├── 通过平台官方质量审核（实体完整、状态机完备、Schema 合规）
│   │   ├── 经过至少 3 个真实项目的验证
│   │   ├── 文档齐全（含使用说明、行业适配指南）
│   │   └── 持续维护更新（最近 3 个月内有过更新）
│   │
│   ├── 来源：
│   │   ├── 平台官方维护的行业 Profile（base / precision_metal / electronics）
│   │   └── 社区贡献者提交 → 平台审核通过 → 升级为精选
│   │
│   ├── 特权：
│   │   ├── 市场首页推荐位 + "精选"标识
│   │   ├── 继承者获得平台技术支持承诺
│   │   ├── 免费/付费用户均可浏览和继承
│   │   └── 模型贡献者获得"官方认证"标识 + 收益分成提升
│   │
│   └── 示例：精密五金 MES v2.1（官方）、电子 MES v1.3（社区→精选）

├── 📦 **普通模型**（一般用户贡献）
│   ├── 来源：任何用户通过"公开分享"发布
│   ├── 特点：
│   │   ├── 无需审核，发布即上架
│   │   ├── 展示在普通模型列表，不进入精选推荐位
│   │   └── 允许其他用户继承使用
│   │
│   ├── 限制：
│   │   ├── 无"精选"标识
│   │   ├── 无平台技术支持承诺
│   │   └── 继承者需自行评估模型质量
│   │
│   └── 升级路径：贡献者可申请精选认定 → 平台审核 → 达标后升级

├── **筛选与排序**
│   ├── 按等级筛选：全部 / 精选 / 普通
│   ├── 按行业分类：制造业 / 供应链 / 销售管理 / ...
│   ├── 按评分排序：综合评分 / 继承次数 / 最近更新
│   └── 关键词搜索

├── **每个模型的详情页**
│   ├── 等级标识：⭐ 精选 或 📦 普通
│   ├── 元数据（作者、版本、行业标签、评分、认证状态）
│   ├── 继承关系图（extends 链）
│   ├── 实体预览
│   ├── 使用统计（被继承次数、生成次数、验证项目数）
│   ├── 质量报告（Schema 合规率、校验通过率）
│   └── 一键继承 → 创建新 Profile

└── **用户操作**
    ├── 搜索 / 筛选
    ├── 查看差异对比（两个 profile 之间的 diff）
    ├── Fork → 创建自己的分支版本
    ├── 提交更新（PR 式）
    └── 申请精选认定（普通模型贡献者 → 提交审核 → 平台评估）
```

**精选认定流程：**

```
用户提交申请
    │
    ▼
平台自动预检（Schema 合规、实体完整性、状态机完备性）
    │
    ├── 预检不通过 → 返回修改建议
    │
    ▼
人工审核（行业专家评估模型质量、文档完整性）
    │
    ├── 不通过 → 反馈改进方向
    │
    ▼
认定通过
    ├── 模型获得 ⭐ 精选标识
    ├── 进入首页推荐位
    ├── 贡献者获得"官方认证"标识
    └── 收益分成比例提升（如：普通模型 50% → 精选模型 70%）
```

#### 6.5.2 模型分享机制

```
用户 A 创建了一个精密五金 MES Profile
├── 选择：公开分享 | 团队内部分享 | 私有
├── 公开后进入市场
├── 用户 B 浏览到该模型
├── 用户 B 点击「继承使用」
│   ├── 在 B 的账户下创建一个新的 Profile
│   ├── 自动继承 A 的所有实体定义
│   └── B 可以在此基础上修改、扩展
└── 继承关系自动记录：
    B's_profile.extends = "user_A/precision_metal:v1.2"
```

**版本管理（仅用于市场，不用于项目升级）：**

```
公开模型有版本号（通过平台审核后更新）
├── 用户使用某个版本创建 Profile
├── 原模型发布新版本
└── 使用方可以选择性手动合并（通过 diff 工具查看变更）

注意：这与「项目交付后不升级」不矛盾
  市场版本 ← 模型迭代（平台内共享）
  项目交付  ← 生成即分叉（独立项目）
```

---

## 7. 技术栈全览

### 7.1 SaaS 平台技术栈

| 组件 | 选型 | 用途 |
|------|------|------|
| 后端框架 | FastAPI 0.110+ | SaaS 后端 API |
| ORM | SQLAlchemy 2.0+ | 模型/用户/计费数据持久化 |
| Web UI | Vue 3 + TypeScript + Element Plus | 模型设计器 + 市场 + 管理后台 |
| 数据库 | PostgreSQL 16 | 核心数据存储 |
| 缓存 | Redis 7.x | 会话 + 任务队列 |
| 对象存储 | MinIO / S3 | 生成包存储 |
| 消息队列 | Redis / APScheduler | 生成任务异步调度 |

### 7.2 生成应用技术栈

| 组件 | 选型 | 版本 | 用途 |
|------|------|------|------|
| Web 框架 | FastAPI | 0.110+ | 高性能异步 API 服务 |
| ORM | SQLAlchemy | 2.0+ | 数据库对象映射 |
| 数据验证 | Pydantic | 2.x | 请求/响应 Schema |
| 数据库迁移 | Alembic | — | 数据库 Schema 变更 |
| 定时任务 | APScheduler | — | 工时统计、超时提醒 |
| 前端框架 | Vue 3 | 3.x | 渐进式前端框架 |
| 构建工具 | Vite | 5.x | 快速构建 |
| 语言 | TypeScript | 5.x | 类型安全 |
| UI 组件 | Element Plus | 2.x | 企业级 PC 端组件库 |
| 状态管理 | Pinia | 2.x | 轻量级状态管理 |
| 移动端 | uni-app (Vue 3) | — | 跨平台应用框架 |
| 移动端 UI | uView Plus | — | 移动端组件库 |
| 数据库 | PostgreSQL 16 + TimescaleDB | — | 关系数据 + 时序数据 |
| 容器化 | Docker + Docker Compose | — | 应用容器化 |

### 7.3 时区处理约定

| 场景 | 策略 |
|------|------|
| **API 存储** | 所有生成的 API 统一使用 **UTC** 存储 datetime 字段，`auto_fill: NOW()` 生成 `datetime.utcnow()` |
| **前端展示** | 在展示时转换为浏览器/客户端时区。项目配置中可指定 `timezone: Asia/Shanghai`，前端默认使用该时区展示 |
| **项目级配置** | `project.yaml` 中可设置 `config.timezone`，影响生成的定时任务调度（APScheduler 时区）和日志时间戳 |
| **SaaS 平台** | 平台自身使用 UTC，用户偏好时区可在用户设置中配置 |

---

## 8. 部署架构

### 8.1 SaaS 平台部署

```
┌────────────────────────────────────────────┐
│               云服务器 / Kubernetes          │
│                                            │
│  ┌──────────┐   ┌──────────┐               │
│  │ Nginx    │   │ 对象存储  │               │
│  │ (反向代理) │   │ (MinIO)  │               │
│  └────┬─────┘   └──────────┘               │
│       │                                     │
│  ┌────▼─────────────────────────────────┐  │
│  │       Docker Compose 容器组           │  │
│  │                                      │  │
│  │  ┌──────────┐  ┌──────────┐          │  │
│  │  │ FastAPI  │  │ 生成引擎  │          │  │
│  │  │ API 服务 │  │  Worker  │          │  │
│  │  └──────────┘  └──────────┘          │  │
│  │  ┌──────────┐  ┌──────────┐          │  │
│  │  │PostgreSQL│  │  Redis   │          │  │
│  │  └──────────┘  └──────────┘          │  │
│  └──────────────────────────────────────┘  │
└────────────────────────────────────────────┘
```

### 8.2 生成应用交付部署

#### 单机私有化（推荐，100~500 用户）

```
┌────────────────────────────────────────────┐
│             客户机房 / 工业内网              │
│                                            │
│  ┌──────────────────────────────────────┐  │
│  │           Nginx (反向代理)             │  │
│  └──────────┬───────────────────────────┘  │
│             │                              │
│  ┌──────────▼───────────────────────────┐  │
│  │        Docker Compose 容器组           │  │
│  │                                      │  │
│  │  ┌──────────┐  ┌────────────────┐     │  │
│  │  │ FastAPI  │  │ 前端静态资源    │     │  │
│  │  │ 应用容器  │  │ (Vue build)   │     │  │
│  │  └──────────┘  └────────────────┘     │  │
│  │  ┌──────────┐  ┌──────────┐          │  │
│  │  │PostgreSQL│  │  Redis   │          │  │
│  │  └──────────┘  └──────────┘          │  │
│  └──────────────────────────────────────┘  │
└────────────────────────────────────────────┘
```

#### 多节点部署（500~1000 用户）

```
┌────────────────────────────────────────────┐
│             客户机房 / 工业内网              │
│                                            │
│  ┌──────────────────────────────────────┐  │
│  │        Nginx (负载均衡)               │  │
│  └────────┬───────────────┬─────────────┘  │
│           │               │               │
│  ┌────────▼──────┐  ┌─────▼──────────┐    │
│  │  Node 1       │  │  Node 2       │    │
│  │  FastAPI 容器 │  │  FastAPI 容器 │    │
│  └───────────────┘  └───────────────┘    │
│           │               │               │
│  ┌────────▼───────────────▼──────────┐    │
│  │     PostgreSQL (主从 / 高可用)      │    │
│  │     Redis (哨兵模式)                │    │
│  └──────────────────────────────────┘    │
└────────────────────────────────────────────┘
```

---

## 9. 竞品对标与差异化定位

### 9.1 竞品对比

| 维度 | DomainDriveFramework | 传统 MES (西门子/鼎捷) | 通用低代码 (明道云/简道云) | 自建方案 |
|------|---------------------|----------------------|--------------------------|---------|
| **定位** | 领域模型驱动 SaaS + 代码生成 | 行业重型套件 | 通用表单+流程引擎 | 全手写开发 |
| **领域语义** | ✅ DSL 内置实体/关系/状态机语义 | ✅ 预置行业模型 | ❌ 需要自行搭建领域模型 | ❌ 从零开发 |
| **AI 融合度** | ★★★★★ DSL 结构化 + Agent API 全开放 | ★☆ 无 AI 接口 | ★★★ 有 API，但模型非结构化 | ★★ 需要 AI 理解代码 |
| **模型可分享** | ✅ 模型市场、继承、Fork | ❌ 封闭产品 | ⚠️ 模板市场，无继承语义 | ❌ 无 |
| **私有化部署** | ✅ Docker 单机/多机 + SaaS 双模式 | ✅ 重型私有化 | ⚠️ 部分支持 | ✅ 完全可控 |
| **开发效率** | 小团队 1-3 人维护模型，AI 辅助 | 需要实施团队 10-20 人 | 配置人员 3-8 人 | 全栈团队 5-15 人 |
| **定制灵活度** | ★★★★ 改 DSL 驱动全栈变更，项目层二开不限 | ★★ 受限于套件扩展 | ★★★ 表单级灵活，逻辑层受限 | ★★★★★ 完全可控 |
| **实施成本** | 低 (模型订阅 + 按项目生成) | 高 (¥500W+) | 中 (按用户/功能收费) | 中-高 (人力成本) |
| **上手门槛** | 低 (业务专家 + Agent 协作) | 高 (需 MES 实施专家) | 低 (拖拽配置) | 高 (需全栈开发) |

### 9.2 差异化策略 (FIA)

| 竞品 | 事实 (Fact) | 影响 (Impact) | 行动 (Action) |
|------|------------|---------------|---------------|
| **传统行业套件** | 重型实施成本高，周期 6-12 个月 | 中小企业无法承受 | DDF 轻量级 SaaS 订阅 + 按项目生成，从 1 个模块开始 |
| **通用低代码** | 无领域语义，每个业务功能需人工搭建流程 | 搭建的业务"形似神不似" | DDF 实体/关系/状态机 DSL 自带领域语义，开箱即用 |
| **自建方案** | 全手写开发，维护成本指数上升 | 人员变动后系统成为遗留系统 | DDF 模型驱动 + Agent 可解析 DSL 辅助维护 |
| **AI 平台 (LangChain/CrewAI)** | 只能做辅助任务，无法直接生成业务应用 | 需要额外的开发工作才能对接业务 | DDF 将 AI 能力嵌入模型设计全流程，Agent 可直接操作 DSL |

### 9.3 目标客户画像

| 客户类型 | 场景 | 典型规模 | 关键痛点 |
|----------|------|----------|----------|
| **中小型企业** | 从手工/纸质管理升级到数字化 | 50-500 人 | 买不起重型套件，找不到全栈开发团队 |
| **大型企业下属部门** | 总部不提供统一系统，需要部门级方案 | 100-1000 人 | 快速上线，后续需对接集团系统 |
| **行业集成商** | 需要快速交付定制化业务系统 | 开发团队 1-5 人 | 传统开发效率低，项目交付周期长 |
| **AI Agent 开发者** | 需要为 Agent 准备业务操作底层 | 个人/小团队 | 没有现成的结构化业务模型供 Agent 操纵 |

---

## 10. 实施路线图

```
Phase 0a: 核心生成工厂 + 通用模型 + 首个行业 Profile（5-6 周）
├── 基础 DSL 语法（实体/关系/状态机/权限/规则/编排）
│   └── 编排引擎范围：触发器 + 顺序动作执行（create_entity / update_entity / notify），
│       补偿、超时、并行分支推迟到 Phase 1-2
├── 通用模型 base/（工单/BOM/工艺路线/班次/用户 五大核心实体）
├── 行业 Profile 继承机制（extends: base | extends: null）
├── 后端 CRUD 全量生成模板（FastAPI + SQLAlchemy + Pydantic + Alembic）
├── 前端基础生成模板（Vue 3 + Element Plus list/detail/form）
├── 移动端 uni-app 模板（扫码/表单/路由）
├── 全量生成策略 + CLI 工具（ddflow generate / validate / profile）
├── 4 道质量门禁（语法 → 引用 → 安全 → 编译）
├── manifest.json 元数据输出
└── 1 个行业 Profile（精密五金 MES，与老大 MES 项目对齐）

Phase 0b: SaaS 基础 + 更多行业 Profile（6-7 周）
├── SaaS 后端（用户系统 + 多租户 + 模型管理）
├── SaaS 前端基础（模型列表、预览、Web 版 YAML 编辑器）
├── REST API（模型 CRUD + 校验 + 生成触发）
├── Agent API 接口（模型操作 + 生成触发）
├── 模型市场基础功能（浏览、搜索、继承）
├── 第 2-3 个行业 Profile（电子 MES、供应链支持）
└── 基础计费系统（免费/付费/企业版用户分类）

Phase 1: SaaS 上线 + 首个真实项目交付（6-8 周）
├── Web IDE 模型设计器（YAML 编辑 + 语法高亮 + 实时校验 + 预览）
├── 模型分享市场（公开/私有、继承关系图、评分系统）
├── 完整计费（订阅制 + 按量包 + 在线支付 + 自动授权）
├── 选择一个真实 MES 项目做交付验证
└── 运营后台（使用统计、用户管理、内容审核）

Phase 2: 扩展 + 运营（持续）
├── Agent 深度集成（NLP → DSL 操作、自然语言建模）
├── 外部系统集成（导入导出、第三方 API 对接）
├── 私有化部署方案（生成工厂可输出到客户内网）
├── 性能优化 + 安全审计
├── 移动端增强（离线能力、扫码性能）
└── 社区运营（模型质量评审、官方认证机制）
```

---

## 11. 目录结构

```
DomainDriveFramework/
├── docs/                          # 文档
│   ├── 01-architecture-overview.md  # 架构设计（本文档）
│   ├── 02-domain-dsl-spec.md       # DSL 规范详细说明
│   ├── 03-template-reference.md    # 模板参考
│   └── 04-competitor-analysis.md   # 竞品分析
│
├── domain/                        # 模型仓库（SaaS 核心数据 / Git 版本管理）
│   ├── base/                      # 第 1 层：通用模型
│   │   ├── core/                  # 核心实体
│   │   │   ├── work_order.yaml
│   │   │   ├── bom.yaml
│   │   │   ├── process_route.yaml
│   │   │   ├── shift.yaml
│   │   │   └── user.yaml
│   │   ├── workflows/
│   │   └── permissions/
│   ├── industries/                # 第 2 层：行业 Profile
│   │   ├── precision_metal/
│   │   │   ├── industry.yaml
│   │   │   ├── overrides/
│   │   │   ├── entities/
│   │   │   └── workflows/
│   │   ├── electronics/
│   │   └── supply_support/
│   ├── projects/                  # 第 3 层：项目实例
│   │   ├── customer_a/
│   │   │   ├── project.yaml
│   │   │   └── customizations.yaml
│   │   └── customer_b/
│   ├── schemas/                   # 数据字典（枚举、选项）
│   ├── permissions/               # 跨层共享权限定义
│   ├── rules/                     # 业务规则
│   ├── templates/                 # 行业模板（MES/PLM/WMS）
│   └── domain-schema.json         # DSL JSON Schema
│
├── generator/                     # 代码生成引擎
│   ├── core/                      # 核心引擎
│   │   ├── parser/                # YAML 解析器
│   │   ├── diff/                  # 差异检测（用于可选对比）
│   │   └── renderer/              # 渲染引擎
│   ├── templates/                 # Jinja2 模板
│   │   ├── backend/
│   │   │   ├── model.j2
│   │   │   ├── schema.j2
│   │   │   ├── router.j2
│   │   │   ├── service.j2
│   │   │   └── migration.j2
│   │   ├── frontend/
│   │   │   ├── list.j2
│   │   │   ├── detail.j2
│   │   │   ├── form.j2
│   │   │   ├── api.j2
│   │   │   └── router.j2
│   │   ├── mobile/
│   │   │   ├── page.j2
│   │   │   ├── scan.j2
│   │   │   ├── api.j2
│   │   │   └── router.j2
│   │   └── orchestration/
│   │       ├── trigger.j2
│   │       ├── compensation.j2
│   │       └── timeout.j2
│   ├── plugins/                   # 可扩展插件
│   │   ├── __init__.py
│   │   ├── report_generator.py
│   │   └── chart_generator.py
│   ├── plugin.py                  # 插件基类
│   ├── gates/                     # 质量门禁
│   │   ├── gate_a_syntax.py
│   │   ├── gate_b_references.py
│   │   ├── gate_c_security.py
│   │   └── gate_d_compile.py
│   └── cli/                       # CLI 工具
│       ├── generate.py
│       ├── validate.py
│       └── profile.py
│
├── platform/                      # SaaS 平台
│   ├── api/                       # FastAPI 后端
│   │   ├── routes/
│   │   ├── models/
│   │   ├── services/
│   │   └── middleware/
│   ├── web/                       # Vue 3 前端
│   │   ├── src/
│   │   └── ...
│   └── deploy/
│       ├── docker-compose.yml
│       └── nginx/
│
├── runtime/                       # 生成项目参考（示例输出）
│   └── project_ref/
│
├── deploy/                        # 根项目部署
│   ├── docker-compose.yml
│   └── scripts/
│
└── README.md
```

---

## 附录：与 v1.x 的主要架构变更

| 维度 | v1.x | v2.0 | 变更原因 |
|------|------|------|---------|
| **架构定位** | 单一项目 DSL → 单一应用 | 模型设计中心(SaaS) + 多行业 Profile → 多项目生成 | 产品化 + 一人企业商业模式 |
| **模型体系** | 单层 DSL 目录 | 三层模型体系（base/industry/project） | 支持多行业、可分享、可继承 |
| **生成策略** | 增量生成（Diff + Change Detector） | 全量生成（无状态、每次完整生成） | 简化复杂度，交付后不升级 |
| **版本管理** | 实体级多版本（EOL/退役/路由） | 仅 Profile 级别版本（用于市场共享） | 移除 40% 复杂度 |
| **升级策略** | 模型升级推送到已交付项目 | 交付即分叉，不升级不回灌 | 契约简化，产品边界清晰 |
| **云化** | 无 | SaaS 多租户 + 模型市场 + 计费系统 | 核心盈利模式 |
| **Agent 接口** | 无 | REST API（模型 CRUD + 校验 + 生成触发） | AI 原生设计，Agent 协作者 |
| **表达式引擎** | 未定 | 结构化 YAML + simpleeval（白名单模式） | v1.1 评审结论，Phase 0a 定案 |

---

*文档版本: v2.1 | 创建日期: 2026-07-11 | 最近更新: 2026-07-11 | 技术栈: FastAPI + Vue 3 + uni-app + PostgreSQL*

---

## 变更记录

| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v2.1 | 2026-07-11 | **评审整改**：1. §4.2.3 业务规则补充 simpleeval 表达式引擎说明和安全规则; 2. §4.2.1 移除 auto_calculate（去重至§4.2.3 业务规则）; 3. §10 Phase 0a 明确编排引擎交付范围（仅顺序动作）; 4. §5.5 Gate C 增加公开端点白名单机制; 5. §3.5 增加项目→Profile 轻量级反馈通道; 6. §7.3 新增时区处理约定; 7. §5.8 新增 CLI vs SaaS 关系说明; 8. 附录变更记录同步 |
| v1.2 | 2026-07-11 | 二次评审整改 |
| v1.1 | 2026-07-11 | 初始架构设计文档 |