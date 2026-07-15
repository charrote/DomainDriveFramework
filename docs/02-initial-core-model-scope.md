# 初始核心 DSL 模型范围设计 v2.1

> 角色视角：高级项目经理 + 产品设计专家  
> 参考：MES 行业标准模型（PowerDesigner BPM），862 个对象  
> 目标：定义 MVP 阶段需要实现的领域模型，控制范围，务实交付  
> 适用范围：`domain/base/` 下的所有实体 DSL 文件  
> 核心原则：**追溯性 + 品质管控**覆盖工单全生命周期

---

### 版本变更记录

| 版本 | 日期 | 变更内容 |
|------|------|---------|
| v1.0 | 2026-07-14 | 初始版本，9 个实体（P0 范围偏窄） |
| v2.0 | 2026-07-14 | 深化至四大场景，20+ 实体，完整追溯链和品质管控 |
| **v2.1** | 2026-07-14 | 整合参考 MES 模型，新增容器管理/编码规则/质量分类/物料属性模板，总数 24+ 实体 |

**v2.0 → v2.1 关键变更：**

| 变更点 | 原因 | 影响 |
|--------|------|------|
| 新增 `container.yaml` | 参考模型中的容器管理，料箱/托盘追踪支撑追溯 | 新增 1 实体 |
| 新增 `coding_rule.yaml` | 参考模型中编码规则引擎，统一工单/条码/质检单编号 | 新增 1 实体，取代原 label_rule |
| 新增 `quality_category.yaml` | 参考模型三级质量分类，支撑品质管控深度 | 新增 1 实体 |
| 新增 `material_attr_template.yaml` | 参考模型物料属性扩展，解决字段动态扩展需求 | 新增 1 实体 |
| 品质管控 `defect.yaml` 深化 | 参考模型缺陷分类/责任，增加缺陷三级分类 | 深化已有实体 |
| 明确 P0 清单总数为 24 实体 | 覆盖率从参考模型的 35% 提升到 45% | 范围微调 |

## 1. 范围决策框架

### 1.1 四个业务场景覆盖目标

| 场景 | 核心诉求 | 对标参考模型 |
|------|---------|-------------|
| **人员作业者管理** | 人员组织、技能、班次、权限、操作追溯 | 人员、班组、班制、技能、组织架构 |
| **设备管理** | 设备台账、设备状态、设备与工序关联 | 资源建模、资源层级、工装夹具 |
| **物料管理** | 物料主数据、BOM、物料属性、分类体系 | 物料大类/中类/小类、物料属性、包装规则 |
| **工艺管理** | 工艺路线、工序定义、工位、工艺参数、SOP | 工序、工位、工艺路线、工序BOM、采集步骤 |

### 1.2 两大核心方向

```
追溯性（Traceability）
┌─────────────────────────────────────────────────────────┐
│ 一条工单的全生命周期可追溯：                              │
│  谁(Operator) + 什么时间(Time) + 哪道工序(Process)       │
│  + 用什么物料(Material) + 在哪台设备(Device)            │
│  + 做了多少(Quantity) + 结果如何(Quality)                │
└─────────────────────────────────────────────────────────┘

品质管控（Quality Control）
┌─────────────────────────────────────────────────────────┐
│ 从来料检验(IQC) → 制程检验(PQC) → 成品检验(OQC)        │
│ 完全覆盖：缺陷记录、不良品处理、返工追溯、合格判定        │
└─────────────────────────────────────────────────────────┘
```

### 1.3 范围分级

| 级别 | 定义 | 包含内容 |
|------|------|---------|
| **P0 — MVP 必须** | 没有就无法演示完整流程 | 完整覆盖四大场景 + 追溯性 + 品质管控 + 编码与容器基础 |
| **P1 — P0 完成** | P0 上线后立即补充 | 仓储/库存、供应商管理、高级排产、包装管理 |
| **P2 — 后续迭代** | 有价值但不阻塞 MVP | 设备OEE、高级统计、IoT集成、模型市场、高级容器流转 |

### 1.4 明确排除（P0 不做）

```
明确不在初始核心范围内的功能：
  ├── ❌ 仓储库存管理（入库/出库/盘点/库存查询 — P1 补充）
  ├── ❌ 供应商/客户管理（供应商主数据/评估 — P1 补充）
  ├── ❌ 采购/销售管理（采购订单、销售订单 — P1 补充）
  ├── ❌ 包装管理（装箱单、包装规则 — P1 补充）
  ├── ❌ 容器流转管理（容器全生命周期追踪 — P0 只做容器的注册和关联）
  ├── ❌ 高级排产/APS — P2
  ├── ❌ 移动端 — P1
  ├── ❌ 设备 OEE/TPM — P2
  ├── ❌ IoT 集成 — P2
  ├── ❌ 物料属性扩展的高级查询/报表 — P1
  └── ❌ 模型市场/多租户 SaaS — P2
```

---

## 2. P0 — 核心模型体系

### 2.1 按领域分组的实体总览

```
domain/base/
├── core/                          # 核心业务实体
│   │
│   ├── 人员管理（场景一）
│   │   ├── org_structure.yaml      # 组织架构（工厂/车间/产线）
│   │   ├── user.yaml               # 系统用户/角色（认证与权限）
│   │   ├── operator.yaml           # 作业人员（工号、技能、所属组织）
│   │   ├── skill.yaml              # 技能管理（人员技能）
│   │   └── shift.yaml              # 班次管理（班次/班制/日历）
│   │
│   ├── 设备管理（场景二）
│   │   ├── device.yaml             # 设备台账（设备/工装/夹具）
│   │   ├── device_type.yaml        # 设备类型/资源层级
│   │   └── device_calendar.yaml    # 设备日历
│   │
│   ├── 物料管理（场景三）
│   │   ├── material.yaml               # 物料主数据
│   │   ├── material_category.yaml      # 物料分类（大类/中类/小类）
│   │   ├── material_attr_template.yaml # 物料属性模板（可扩展 key-value）
│   │   └── bom.yaml                    # 产品BOM（多级结构）
│   │
│   ├── 工艺管理（场景四）
│   │   ├── process_route.yaml      # 工艺路线
│   │   ├── process_step.yaml       # 工序定义
│   │   ├── workstation.yaml        # 工位定义
│   │   └── process_param.yaml      # 工艺参数
│   │
│   ├── 生产执行
│   │   ├── work_order.yaml         # 工单（核心主实体）
│   │   ├── work_order_bom.yaml     # 工单BOM
│   │   ├── work_order_route.yaml   # 工单工艺路线
│   │   └── production_record.yaml  # 生产记录（追溯核心）
│   │
│   ├── 品质管控
│   │   ├── quality_category.yaml   # 质量分类（大类/中类/小类）
│   │   ├── defect.yaml             # 缺陷定义（含缺陷分类三级结构）
│   │   ├── quality_check.yaml      # 质检记录（通用）
│   │   ├── inspection_item.yaml    # 检验项目
│   │   └── inspection_plan.yaml    # 抽样方案
│   │
│   └── 追溯辅助
│       ├── coding_rule.yaml        # 编码规则（统一编码生成引擎）
│       ├── barcode.yaml            # 条码/批次追踪
│       └── container.yaml          # 容器管理（料箱/托盘/工装板）
│
├── workflows/
│   ├── work_order_flow.yaml        # 工单状态机
│   ├── quality_check_flow.yaml     # 质检状态机
│   └── device_flow.yaml            # 设备状态机
│
└── permissions/
    └── roles.yaml                  # 角色定义与权限矩阵
```

### 2.2 实体关系全景图

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     组织架构层
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

┌──────────────┐  1     N  ┌──────────────┐  1     N  ┌──────────────┐
│   Factory    │──────────▶│   Workshop    │──────────▶│  Production  │
│   工厂        │           │   车间        │           │   Line       │
└──────────────┘           └──────────────┘           │   产线        │
                                                       └──────┬───────┘
                                                              │ 1
                                                              │ has_many
                                                              ▼
                                                       ┌──────────────┐
                                                       │ Workstation  │
                                                       │   工位        │
                                                       └──────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     人员层             设备层             物料层
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│   Operator   │   │   Device     │   │   Material   │
│   作业人员    │   │   设备       │   │   物料       │
└──────┬───────┘   └──────┬───────┘   └──────┬───────┘
       │                  │                  │
       │ 关联              │ 关联              │ 关联
       ▼                  ▼                  ▼
┌──────────────────────────────────────────────────────────┐
│                   WorkOrder / 生产执行                     │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐  │
│  │  WorkOrder   │──▶│ WOBOM        │──▶│  Material    │  │
│  │  工单        │   │ 工单BOM      │   │  物料        │  │
│  └──────┬───────┘   └──────────────┘   └──────────────┘  │
│         │                                                  │
│         │ 1                                                │
│         ▼                                                  │
│  ┌────────────────────────────────────────────────────┐   │
│  │              ProductionRecord                      │   │
│  │              生产记录（追溯核心）                    │   │
│  │  ┌─────────┐ ┌─────────┐ ┌──────────┐ ┌────────┐  │   │
│  │  │ Operator│ │ Process │ │ Device   │ │ QC     │  │   │
│  │  │ 操作人员│ │ 工序     │ │ 设备     │ │ 质检   │  │   │
│  │  └─────────┘ └─────────┘ └──────────┘ └────────┘  │   │
│  └────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     工艺层             品质层
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│ ProcessRoute │──▶│ ProcessStep  │   │ QualityCheck │
│   工艺路线    │   │   工序定义    │   │   质检记录    │
└──────────────┘   └──────┬───────┘   └──────────────┘
      1                   │                   ▲
      │                   │ 关联               │ 关联
      ▼                   ▼                   │
┌──────────────┐   ┌──────────────┐           │
│ WorkOrder    │──▶│ Defect      │────────────┘
│   工单        │   │   缺陷       │
└──────────────┘   └──────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 2.3 追溯链设计

```
追溯链 = 一条工单从创建到完工的完整数据链路

工单创建 
  ↓ 谁创建的？ → User
  ↓ 什么时候？ → created_at
  ↓ 做什么？   → product_code, quantity
  ↓
工艺路线分配
  ↓ 需要哪些工序？ → ProcessStep[1..N]
  ↓ 按什么顺序？  → step_no
  ↓
上料/领料
  ↓ 用什么物料？ → Material (through BOM)
  ↓ 用多少？    → BOMItem.required_qty
  ↓ 谁领的？   → Operator
  ↓
生产执行（每道工序）
  ↓ 谁做的？   → Operator
  ↓ 什么时间？ → ProductionRecord.start_time / end_time
  ↓ 在哪做？   → Device / Workstation
  ↓ 做了多少？ → output_quantity, scrap_quantity
  ↓ 用了哪些物料？→ Material (实际消耗)
  ↓
品质检验
  ↓ 谁检的？   → Inspector (User)
  ↓ 检验结果？ → QualityCheck.result (pass/fail/rework)
  ↓ 什么缺陷？ → Defect
  ↓ 测量值？   → measured_value (± tolerance)
  ↓
如有返工
  ↓ 谁返工的？ → Operator
  ↓ 返工结果？ → QualityCheck (rework → pass)
  ↓
完工
  ↓ 完成数量？ → completed_quantity
  ↓ 完工时间？ → actual_end_time
```

---

## 3. 各核心实体详细定义

### 3.1 场景一：人员作业者管理

#### 3.1.1 OrgStructure — 组织架构

**设计意图：** 工厂的组织层级：工厂 → 车间 → 产线。这是人员归属和设备归属的基础。

```yaml
# domain/base/core/org_structure.yaml
domain: base.org_structure
name: 组织架构
version: 1.0.0
description: 工厂组织层级定义

entities:
  - name: Factory
    label: 工厂
    table: org_factory
    fields:
      - name: id
        type: integer
        label: ID
        primary_key: true
        generate: true
        sequence: { strategy: db }
      - name: factory_code
        type: string
        label: 工厂编码
        max_length: 32
        required: true
        unique: true
      - name: factory_name
        type: string
        label: 工厂名称
        max_length: 128
        required: true
      - name: status
        type: enum
        label: 状态
        values: active, inactive
        default: active
      - name: created_at
        type: datetime
        label: 创建时间
        auto_fill: NOW()
        read_only: true

  - name: Workshop
    label: 车间
    table: org_workshop
    fields:
      - name: id
        type: integer
        label: ID
        primary_key: true
        generate: true
        sequence: { strategy: db }
      - name: factory_id
        type: relation
        label: 所属工厂
        relation: Factory
        required: true
      - name: workshop_code
        type: string
        label: 车间编码
        max_length: 32
        required: true
      - name: workshop_name
        type: string
        label: 车间名称
        max_length: 128
        required: true
      - name: status
        type: enum
        label: 状态
        values: active, inactive
        default: active

  - name: ProductionLine
    label: 产线
    table: org_production_line
    fields:
      - name: id
        type: integer
        label: ID
        primary_key: true
        generate: true
        sequence: { strategy: db }
      - name: workshop_id
        type: relation
        label: 所属车间
        relation: Workshop
        required: true
      - name: line_code
        type: string
        label: 产线编码
        max_length: 32
        required: true
      - name: line_name
        type: string
        label: 产线名称
        max_length: 128
        required: true
      - name: status
        type: enum
        label: 状态
        values: active, inactive
        default: active
```

#### 3.1.2 User — 系统用户/角色

```yaml
# domain/base/core/user.yaml
domain: base.user
name: 用户与角色
version: 1.0.0
description: 系统用户认证与 RBAC 权限体系

entities:
  - name: User
    label: 用户
    table: sys_user
    fields:
      - name: id
        type: integer
        label: ID
        primary_key: true
        generate: true
        sequence: { strategy: db }
      - name: username
        type: string
        label: 用户名
        max_length: 64
        required: true
        unique: true
      - name: real_name
        type: string
        label: 真实姓名
        max_length: 64
      - name: password_hash
        type: string
        label: 密码哈希
        max_length: 256
        read_only: true
      - name: role
        type: enum
        label: 角色
        values: operator, supervisor, quality_inspector, admin
        default: operator
        required: true
      - name: status
        type: enum
        label: 账户状态
        values: active, disabled
        default: active
      - name: created_at
        type: datetime
        label: 创建时间
        auto_fill: NOW()
        read_only: true
      - name: updated_at
        type: datetime
        label: 更新时间
        auto_fill: NOW_ON_UPDATE

    permissions:
      read:      [admin]
      create:    [admin]
      write:     [admin]
      delete:    [admin]
```

#### 3.1.3 Operator — 作业人员

**设计意图：** 区别于系统用户（User），Operator 是真正在产线操作的作业人员。一个 Operator 可以对应一个 User（登录账号），也可以没有系统账号。

```yaml
# domain/base/core/operator.yaml
domain: base.operator
name: 作业人员
version: 1.0.0
description: 产线作业人员，含技能、所属组织、排班信息

entities:
  - name: Operator
    label: 作业人员
    table: operator
    fields:
      - name: id
        type: integer
        label: ID
        primary_key: true
        generate: true
        sequence: { strategy: db }
      - name: operator_no
        type: string
        label: 工号
        max_length: 32
        required: true
        unique: true
      - name: operator_name
        type: string
        label: 姓名
        max_length: 64
        required: true
      - name: user_id
        type: relation
        label: 关联用户
        relation: User
      - name: production_line_id
        type: relation
        label: 所属产线
        relation: ProductionLine
      - name: shift_id
        type: relation
        label: 当前班次
        relation: Shift
      - name: skill_level
        type: enum
        label: 技能等级
        values: junior, intermediate, senior, master
        default: junior
      - name: status
        type: enum
        label: 状态
        values: active, inactive, leave
        default: active
      - name: phone
        type: string
        label: 联系电话
        max_length: 20
      - name: hire_date
        type: date
        label: 入职日期
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
      - name: production_line
        target: ProductionLine
        type: belongs_to
        foreign_key: production_line_id
        label: 所属产线
      - name: shift
        target: Shift
        type: belongs_to
        foreign_key: shift_id
        label: 当前班次

    list_view:
      columns:
        - field: operator_no
          label: 工号
          sortable: true
        - field: operator_name
          label: 姓名
        - field: production_line_id
          label: 所属产线
        - field: shift_id
          label: 班次
        - field: skill_level
          label: 技能等级
          formatter: tag
        - field: status
          label: 状态
          formatter: status_tag

    permissions:
      read:      [operator, supervisor, admin]
      create:    [supervisor, admin]
      write:     [supervisor, admin]
      delete:    [admin]
```

#### 3.1.4 Shift — 班次管理

```yaml
# domain/base/core/shift.yaml
domain: base.shift
name: 班次
version: 1.0.0
description: 班次定义，含班制管理和工作时间段

entities:
  - name: ShiftPattern
    label: 班制
    table: shift_pattern
    fields:
      - name: id
        type: integer
        label: ID
        primary_key: true
        generate: true
        sequence: { strategy: db }
      - name: pattern_name
        type: string
        label: 班制名称
        max_length: 32
        required: true
        unique: true
      - name: description
        type: string
        label: 描述
        max_length: 256

  - name: Shift
    label: 班次
    table: shift
    fields:
      - name: id
        type: integer
        label: ID
        primary_key: true
        generate: true
        sequence: { strategy: db }
      - name: shift_code
        type: string
        label: 班次编码
        max_length: 16
        required: true
      - name: shift_name
        type: string
        label: 班次名称
        max_length: 32
        required: true
      - name: start_time
        type: string
        label: 开始时间
        max_length: 5
        required: true
      - name: end_time
        type: string
        label: 结束时间
        max_length: 5
        required: true
      - name: shift_date
        type: date
        label: 排班日期
      - name: shift_pattern_id
        type: relation
        label: 所属班制
        relation: ShiftPattern
      - name: created_at
        type: datetime
        label: 创建时间
        auto_fill: NOW()
        read_only: true

    list_view:
      columns:
        - field: shift_code
          label: 班次编码
        - field: shift_name
          label: 班次名称
        - field: start_time
          label: 开始时间
        - field: end_time
          label: 结束时间
        - field: shift_date
          label: 排班日期

    permissions:
      read:      [operator, supervisor, admin]
      create:    [supervisor, admin]
      write:     [supervisor, admin]
      delete:    [admin]
```

### 3.2 场景二：设备管理

#### 3.2.1 Device — 设备（含工装夹具）

**设计意图：** 离散制造的核心生产资源。涵盖生产设备、工装、夹具、测试设备等。支持分类、状态追踪、与工序关联。

```yaml
# domain/base/core/device.yaml
domain: base.device
name: 设备管理
version: 1.0.0
description: 生产设备/工装/夹具/测试设备的台账管理

entities:
  - name: DeviceCategory
    label: 设备分类
    table: device_category
    fields:
      - name: id
        type: integer
        label: ID
        primary_key: true
        generate: true
        sequence: { strategy: db }
      - name: category_code
        type: string
        label: 分类编码
        max_length: 32
        required: true
      - name: category_name
        type: string
        label: 分类名称
        max_length: 64
        required: true
      - name: parent_id
        type: relation
        label: 上级分类
        relation: DeviceCategory

  - name: Device
    label: 设备
    table: device
    fields:
      - name: id
        type: integer
        label: ID
        primary_key: true
        generate: true
        sequence: { strategy: db }
      - name: device_code
        type: string
        label: 设备编码
        max_length: 32
        required: true
        unique: true
      - name: device_name
        type: string
        label: 设备名称
        max_length: 128
        required: true
      - name: device_type
        type: enum
        label: 设备类型
        values: production, tooling, fixture, test_equipment, auxiliary
        default: production
        required: true
      - name: category_id
        type: relation
        label: 设备分类
        relation: DeviceCategory
      - name: model
        type: string
        label: 规格型号
        max_length: 128
      - name: production_line_id
        type: relation
        label: 所属产线
        relation: ProductionLine
      - name: workstation_id
        type: relation
        label: 所在工位
        relation: Workstation
      - name: status
        type: enum
        label: 设备状态
        values: idle, running, maintenance, fault, offline
        default: idle
        required: true
        status_field: true
        workflow_ref: device_flow
      - name: purchase_date
        type: date
        label: 采购日期
      - name: last_maintenance_date
        type: date
        label: 最近维保日期
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
      - name: production_line
        target: ProductionLine
        type: belongs_to
        foreign_key: production_line_id
        label: 所属产线

    list_view:
      columns:
        - field: device_code
          label: 设备编码
          sortable: true
        - field: device_name
          label: 设备名称
        - field: device_type
          label: 设备类型
          formatter: tag
        - field: status
          label: 状态
          formatter: status_tag
        - field: production_line_id
          label: 所属产线
        - field: last_maintenance_date
          label: 最近维保

    permissions:
      read:      [operator, supervisor, admin]
      create:    [supervisor, admin]
      write:     [supervisor, admin]
      delete:    [admin]
```

### 3.3 场景三：物料管理

#### 3.3.1 Material — 物料主数据

**设计意图：** 完整的物料管理体系，包含三级分类和可扩展属性。

```yaml
# domain/base/core/material.yaml
domain: base.material
name: 物料管理
version: 1.0.0
description: 物料主数据，含三级分类体系和自定义属性

entities:
  - name: MaterialCategory
    label: 物料分类
    table: material_category
    fields:
      - name: id
        type: integer
        label: ID
        primary_key: true
        generate: true
        sequence: { strategy: db }
      - name: category_code
        type: string
        label: 分类编码
        max_length: 32
        required: true
      - name: category_name
        type: string
        label: 分类名称
        max_length: 64
        required: true
      - name: level
        type: integer
        label: 层级
        required: true
        default: 1
      - name: parent_id
        type: relation
        label: 上级分类
        relation: MaterialCategory

  - name: Material
    label: 物料
    table: material
    fields:
      - name: id
        type: integer
        label: ID
        primary_key: true
        generate: true
        sequence: { strategy: db }
      - name: material_code
        type: string
        label: 物料编码
        max_length: 64
        required: true
        unique: true
      - name: material_name
        type: string
        label: 物料名称
        max_length: 128
        required: true
      - name: specification
        type: string
        label: 规格型号
        max_length: 256
      - name: category_id
        type: relation
        label: 物料分类
        relation: MaterialCategory
      - name: unit
        type: enum
        label: 基本单位
        values: piece, kg, meter, liter, set, roll, box, pair
        default: piece
        required: true
      - name: material_type
        type: enum
        label: 物料类型
        values: raw_material, semi_finished, finished, auxiliary, packaging
        default: raw_material
        required: true
      - name: status
        type: enum
        label: 状态
        values: active, inactive, obsolete
        default: active
      - name: created_at
        type: datetime
        label: 创建时间
        auto_fill: NOW()
        read_only: true
      - name: updated_at
        type: datetime
        label: 更新时间
        auto_fill: NOW_ON_UPDATE

    list_view:
      columns:
        - field: material_code
          label: 物料编码
        - field: material_name
          label: 物料名称
        - field: specification
          label: 规格型号
        - field: category_id
          label: 物料分类
        - field: unit
          label: 单位
        - field: material_type
          label: 物料类型
          formatter: tag
        - field: status
          label: 状态
          formatter: status_tag

    permissions:
      read:      [operator, supervisor, admin]
      create:    [supervisor, admin]
      write:     [supervisor, admin]
      delete:    [admin]
```

#### 3.3.2 BOM — 产品 BOM

**设计意图：** 支持多级 BOM 结构。ProductBOM 定义产品由哪些物料组成，BOMItem 是单条物料行。

```yaml
# domain/base/core/bom.yaml
domain: base.bom
name: BOM 清单
version: 1.0.0
description: 产品 BOM 结构，支持多级物料清单

entities:
  - name: ProductBOM
    label: 产品 BOM
    table: product_bom
    fields:
      - name: id
        type: integer
        label: ID
        primary_key: true
        generate: true
        sequence: { strategy: db }
      - name: bom_code
        type: string
        label: BOM 编码
        max_length: 32
        required: true
      - name: product_code
        type: string
        label: 产品编码
        max_length: 64
        required: true
      - name: product_name
        type: string
        label: 产品名称
        max_length: 128
      - name: version
        type: string
        label: 版本号
        max_length: 16
        default: "1.0"
      - name: status
        type: enum
        label: 状态
        values: draft, released, obsolete
        default: draft
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
      - name: items
        target: BOMItem
        type: has_many
        inverse_of: product_bom
        label: BOM 明细

  - name: BOMItem
    label: BOM 明细
    table: bom_item
    fields:
      - name: id
        type: integer
        label: ID
        primary_key: true
        generate: true
        sequence: { strategy: db }
      - name: product_bom_id
        type: relation
        label: 所属 BOM
        relation: ProductBOM
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
      - name: quantity
        type: float
        label: 用量
        required: true
        validate:
          min: 0
      - name: unit
        type: string
        label: 单位
        max_length: 16
      - name: scrap_rate
        type: float
        label: 损耗率(%)
        default: 0
      - name: parent_item_id
        type: relation
        label: 上级物料
        relation: BOMItem
      - name: created_at
        type: datetime
        label: 创建时间
        auto_fill: NOW()
        read_only: true

    relations:
      - name: product_bom
        target: ProductBOM
        type: belongs_to
        foreign_key: product_bom_id
        label: 所属 BOM

    list_view:
      columns:
        - field: material_code
          label: 物料编码
        - field: material_name
          label: 物料名称
        - field: quantity
          label: 用量
          align: right
        - field: unit
          label: 单位
        - field: scrap_rate
          label: 损耗率(%)

    permissions:
      read:      [operator, supervisor, admin]
      create:    [supervisor, admin]
      write:     [supervisor, admin]
      delete:    [admin]
```

### 3.4 场景四：工艺管理

#### 3.4.1 ProcessRoute — 工艺路线

**设计意图：** 定义产品的完整工艺路线。一个产品可以有多个版本的工艺路线。

```yaml
# domain/base/core/process_route.yaml
domain: base.process_route
name: 工艺路线
version: 1.0.0
description: 产品工艺路线，含工序序列和标准工时

entities:
  - name: ProcessRoute
    label: 工艺路线
    table: process_route
    fields:
      - name: id
        type: integer
        label: ID
        primary_key: true
        generate: true
        sequence: { strategy: db }
      - name: route_code
        type: string
        label: 路线编码
        max_length: 32
        required: true
      - name: product_code
        type: string
        label: 产品编码
        max_length: 64
        required: true
      - name: version
        type: string
        label: 版本号
        max_length: 16
        default: "1.0"
      - name: status
        type: enum
        label: 状态
        values: draft, released, obsolete
        default: draft
      - name: total_standard_time
        type: integer
        label: 总标准工时(分钟)
        auto_calculate:
          aggregate: sum
          source: ProcessStep.standard_time_minutes
          filter: "process_route_id == id"
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
      - name: steps
        target: ProcessStep
        type: has_many
        inverse_of: process_route
        label: 工序步骤

    list_view:
      columns:
        - field: route_code
          label: 路线编码
        - field: product_code
          label: 产品编码
        - field: version
          label: 版本
        - field: status
          label: 状态
          formatter: status_tag
        - field: total_standard_time
          label: 总工时
          align: right

    permissions:
      read:      [operator, supervisor, admin]
      create:    [supervisor, admin]
      write:     [supervisor, admin]
      delete:    [admin]
```

#### 3.4.2 ProcessStep — 工序定义

**设计意图：** 工艺路线中的每一道工序。定义了工序名称、序号、标准工时、关联设备类型、工位等。

```yaml
# domain/base/core/process_step.yaml
domain: base.process_step
name: 工序定义
version: 1.0.0
description: 工艺路线中的工序步骤，含工序参数和设备关联

entities:
  - name: ProcessStep
    label: 工序
    table: process_step
    fields:
      - name: id
        type: integer
        label: ID
        primary_key: true
        generate: true
        sequence: { strategy: db }
      - name: process_route_id
        type: relation
        label: 所属工艺路线
        relation: ProcessRoute
        required: true
      - name: step_no
        type: integer
        label: 工序序号
        required: true
        validate:
          min: 1
      - name: step_code
        type: string
        label: 工序编码
        max_length: 32
      - name: step_name
        type: string
        label: 工序名称
        max_length: 64
        required: true
      - name: standard_time_minutes
        type: integer
        label: 标准工时(分钟)
        validate:
          min: 0
      - name: device_type_required
        type: enum
        label: 所需设备类型
        values: production, tooling, fixture, test_equipment
      - name: workstation_type
        type: string
        label: 工位类型
        max_length: 32
      - name: description
        type: string
        label: 工序描述
        max_length: 500
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
      - name: process_route
        target: ProcessRoute
        type: belongs_to
        foreign_key: process_route_id
        label: 所属工艺路线

    list_view:
      columns:
        - field: step_no
          label: 工序序号
          sortable: true
        - field: step_code
          label: 工序编码
        - field: step_name
          label: 工序名称
        - field: standard_time_minutes
          label: 标准工时
          align: right
        - field: device_type_required
          label: 所需设备
          formatter: tag

    permissions:
      read:      [operator, supervisor, admin]
      create:    [supervisor, admin]
      write:     [supervisor, admin]
      delete:    [admin]
```

#### 3.4.3 Workstation — 工位

```yaml
# domain/base/core/workstation.yaml
domain: base.workstation
name: 工位
version: 1.0.0
description: 工位定义，关联产线和设备

entities:
  - name: Workstation
    label: 工位
    table: workstation
    fields:
      - name: id
        type: integer
        label: ID
        primary_key: true
        generate: true
        sequence: { strategy: db }
      - name: station_code
        type: string
        label: 工位编码
        max_length: 32
        required: true
      - name: station_name
        type: string
        label: 工位名称
        max_length: 64
        required: true
      - name: production_line_id
        type: relation
        label: 所属产线
        relation: ProductionLine
        required: true
      - name: status
        type: enum
        label: 状态
        values: active, inactive
        default: active
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
      - name: production_line
        target: ProductionLine
        type: belongs_to
        foreign_key: production_line_id
        label: 所属产线
      - name: devices
        target: Device
        type: has_many
        inverse_of: workstation
        label: 工位设备
```

### 3.5 生产执行核心

#### 3.5.1 WorkOrder — 工单（核心主实体）

**设计意图：** 工单是生产执行的起点。关联产品、工艺路线、BOM、设备和人员。

```yaml
# domain/base/core/work_order.yaml
domain: base.work_order
name: 工单
version: 1.0.0
description: 离散制造核心工单实体，驱动整个生产执行流程

entities:
  - name: WorkOrder
    label: 工单
    table: work_order
    fields:
      - name: order_no
        type: string
        label: 工单编号
        max_length: 32
        primary_key: true
        required: true
        generate: true
        generate_rule: "WO{YYYYMMDD}{SEQ5}"
        sequence:
          strategy: db
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
        required: true
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
        read_only: true
      - name: scrap_quantity
        type: integer
        label: 报废数量
        default: 0
        read_only: true
      - name: status
        type: enum
        label: 工单状态
        values: pending, released, running, paused, completed, cancelled
        default: pending
        required: true
        status_field: true
        workflow_ref: work_order_flow
      - name: priority
        type: enum
        label: 优先级
        values: low, normal, high, urgent
        default: normal
      - name: plan_start_date
        type: date
        label: 计划开始日期
        required: true
      - name: plan_end_date
        type: date
        label: 计划完成日期
      - name: actual_start_time
        type: datetime
        label: 实际开工时间
        auto_fill:
          trigger: "status == 'running'"
          value: NOW()
        read_only: true
      - name: actual_end_time
        type: datetime
        label: 实际完工时间
        auto_fill:
          trigger: "status == 'completed'"
          value: NOW()
        read_only: true
      - name: route_id
        type: relation
        label: 工艺路线
        relation: ProcessRoute
      - name: production_line_id
        type: relation
        label: 生产产线
        relation: ProductionLine
      - name: shift_id
        type: relation
        label: 班次
        relation: Shift
      - name: comment
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
        target: WOBOMItem
        type: has_many
        inverse_of: work_order
        label: 工单 BOM
      - name: production_records
        target: ProductionRecord
        type: has_many
        inverse_of: work_order
        label: 生产记录
      - name: quality_checks
        target: QualityCheck
        type: has_many
        inverse_of: work_order
        label: 质检记录
      - name: creator
        target: User
        type: belongs_to
        foreign_key: created_by
        label: 创建人
      - name: production_line
        target: ProductionLine
        type: belongs_to
        foreign_key: production_line_id
        label: 生产产线

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
        - field: production_line_id
          label: 产线
        - field: plan_start_date
          label: 计划开始
        - field: actual_start_time
          label: 实际开工
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
      read:      [operator, supervisor, quality_inspector, admin]
      create:    [supervisor, admin]
      write:     [operator, supervisor, admin]
      delete:    [admin]
      transition:
        pending → released:  [supervisor, admin]
        released → running:  [operator, admin]
        running → paused:    [operator, admin]
        paused → running:    [operator, admin]
        running → completed: [operator, admin]
        * → cancelled:       [admin]
```

#### 3.5.2 WOBOMItem — 工单 BOM

```yaml
# domain/base/core/work_order_bom.yaml
domain: base.work_order_bom
name: 工单 BOM
version: 1.0.0
description: 工单级别的物料清单，从产品 BOM 复制生成

entities:
  - name: WOBOMItem
    label: 工单 BOM 明细
    table: wo_bom_item
    fields:
      - name: id
        type: integer
        label: ID
        primary_key: true
        generate: true
        sequence: { strategy: db }
      - name: work_order_no
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
        type: float
        label: 需求数量
        required: true
        validate:
          min: 0
      - name: consumed_qty
        type: float
        label: 已消耗数量
        default: 0
        read_only: true
      - name: unit
        type: string
        label: 单位
        max_length: 16
      - name: created_at
        type: datetime
        label: 创建时间
        auto_fill: NOW()
        read_only: true

    list_view:
      columns:
        - field: material_code
          label: 物料编码
        - field: material_name
          label: 物料名称
        - field: required_qty
          label: 需求数量
          align: right
        - field: consumed_qty
          label: 已消耗
          align: right
        - field: unit
          label: 单位

    permissions:
      read:      [operator, supervisor, admin]
      create:    [supervisor, admin]
      write:     [operator, supervisor, admin]
      delete:    [admin]
```

#### 3.5.3 ProductionRecord — 生产记录（追溯核心）

**设计意图：** 整个追溯体系的核心。记录每道工序的执行情况：谁、什么时候、在哪台设备、用了什么物料、产出多少、不良多少。

```yaml
# domain/base/core/production_record.yaml
domain: base.production_record
name: 生产记录
version: 1.0.0
description: 追溯核心实体，记录每道工序的实际执行情况

entities:
  - name: ProductionRecord
    label: 生产记录
    table: production_record
    fields:
      - name: id
        type: integer
        label: ID
        primary_key: true
        generate: true
        sequence: { strategy: db }
      - name: record_no
        type: string
        label: 记录编号
        max_length: 32
        required: true
        generate: true
        generate_rule: "PR{YYYYMMDD}{SEQ5}"
        sequence:
          strategy: db
          scope: daily
          padding: 5
      - name: work_order_no
        type: relation
        label: 所属工单
        relation: WorkOrder
        required: true
      - name: process_step_id
        type: relation
        label: 工序
        relation: ProcessStep
        required: true
      - name: operator_id
        type: relation
        label: 操作人员
        relation: Operator
        auto_fill: CURRENT_USER
      - name: device_id
        type: relation
        label: 使用设备
        relation: Device
      - name: shift_id
        type: relation
        label: 班次
        relation: Shift
      - name: production_line_id
        type: relation
        label: 产线
        relation: ProductionLine
      - name: start_time
        type: datetime
        label: 开始时间
        required: true
        auto_fill: NOW()
      - name: end_time
        type: datetime
        label: 结束时间
      - name: output_quantity
        type: integer
        label: 产出数量
        required: true
        validate:
          min: 0
      - name: scrap_quantity
        type: integer
        label: 不良数量
        default: 0
        validate:
          min: 0
      - name: status
        type: enum
        label: 记录状态
        values: in_progress, completed
        default: in_progress
      - name: remark
        type: string
        label: 备注
        max_length: 500
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
      - name: work_order
        target: WorkOrder
        type: belongs_to
        foreign_key: work_order_no
        label: 所属工单
      - name: process_step
        target: ProcessStep
        type: belongs_to
        foreign_key: process_step_id
        label: 工序
      - name: operator
        target: Operator
        type: belongs_to
        foreign_key: operator_id
        label: 操作人员
      - name: device
        target: Device
        type: belongs_to
        foreign_key: device_id
        label: 使用设备
      - name: shift
        target: Shift
        type: belongs_to
        foreign_key: shift_id
        label: 班次

    list_view:
      columns:
        - field: record_no
          label: 记录编号
          sortable: true
        - field: work_order_no
          label: 工单
        - field: process_step_id
          label: 工序
        - field: operator_id
          label: 操作人员
        - field: device_id
          label: 设备
        - field: start_time
          label: 开始时间
        - field: end_time
          label: 结束时间
        - field: output_quantity
          label: 产出
          align: right
        - field: scrap_quantity
          label: 不良
          align: right
        - field: status
          label: 状态
          formatter: status_tag

    permissions:
      read:      [operator, supervisor, quality_inspector, admin]
      create:    [operator, supervisor, admin]
      write:     [operator, supervisor, admin]
      delete:    [admin]
```

### 3.6 品质管控

#### 3.6.1 QualityCheck — 质检记录

**设计意图：** 统一质检模型，覆盖来料(IQC)、制程(PQC)、成品(OQC)、返工等所有检验场景。

```yaml
# domain/base/core/quality_check.yaml
domain: base.quality_check
name: 质检记录
version: 1.0.0
description: 统一质检记录，覆盖 IQC/PQC/OQC/返工检验

entities:
  - name: QualityCheck
    label: 质检记录
    table: quality_check
    fields:
      - name: id
        type: integer
        label: ID
        primary_key: true
        generate: true
        sequence: { strategy: db }
      - name: check_no
        type: string
        label: 检验编号
        max_length: 32
        required: true
        generate: true
        generate_rule: "QC{YYYYMMDD}{SEQ5}"
        sequence:
          strategy: db
          scope: daily
          padding: 5
      - name: work_order_no
        type: relation
        label: 关联工单
        relation: WorkOrder
      - name: production_record_id
        type: relation
        label: 关联生产记录
        relation: ProductionRecord
      - name: check_type
        type: enum
        label: 检验类型
        values: iqc, pqc, oqc, first_article, rework
        default: pqc
        required: true
      - name: check_name
        type: string
        label: 检验项目
        max_length: 128
        required: true
      - name: inspection_item_id
        type: relation
        label: 检验标准
        relation: InspectionItem
      - name: sample_size
        type: integer
        label: 抽样数量
        default: 1
      - name: measured_value
        type: float
        label: 测量值
      - name: tolerance_min
        type: float
        label: 规格下限
      - name: tolerance_max
        type: float
        label: 规格上限
      - name: result
        type: enum
        label: 判定结果
        values: pass, fail, rework, pending
        default: pending
        required: true
        options:
          pass:   { label: 合格, color: "#52c41a" }
          fail:   { label: 不合格, color: "#f5222d" }
          rework: { label: 返工, color: "#fa8c16" }
          pending:{ label: 待判定, color: "#9ca3af" }
      - name: defect_id
        type: relation
        label: 缺陷类型
        relation: Defect
      - name: inspector_id
        type: relation
        label: 检验员
        relation: User
        auto_fill: CURRENT_USER
      - name: check_time
        type: datetime
        label: 检验时间
        auto_fill: NOW()
        read_only: true
      - name: remark
        type: string
        label: 备注
        max_length: 500
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
      - name: work_order
        target: WorkOrder
        type: belongs_to
        foreign_key: work_order_no
        label: 关联工单
      - name: inspector
        target: User
        type: belongs_to
        foreign_key: inspector_id
        label: 检验员

    list_view:
      columns:
        - field: check_no
          label: 检验编号
          sortable: true
        - field: work_order_no
          label: 工单
        - field: check_type
          label: 检验类型
          formatter: tag
        - field: check_name
          label: 检验项目
        - field: measured_value
          label: 测量值
          align: right
        - field: result
          label: 结果
          formatter: status_tag
        - field: inspector_id
          label: 检验员
        - field: check_time
          label: 检验时间
      search_fields:
        - field: check_no
          type: input
          placeholder: "检验编号"
        - field: check_type
          type: select
          options_from_field: check_type
          placeholder: "检验类型"
        - field: result
          type: select
          options_from_field: result
          placeholder: "判定结果"

    permissions:
      read:      [operator, supervisor, quality_inspector, admin]
      create:    [quality_inspector, admin]
      write:     [quality_inspector, admin]
      delete:    [admin]
```

#### 3.6.2 Defect — 缺陷定义

```yaml
# domain/base/core/defect.yaml
domain: base.defect
name: 缺陷管理
version: 1.0.0
description: 缺陷分类和维护

entities:
  - name: DefectCategory
    label: 缺陷分类
    table: defect_category
    fields:
      - name: id
        type: integer
        label: ID
        primary_key: true
        generate: true
        sequence: { strategy: db }
      - name: category_code
        type: string
        label: 分类编码
        max_length: 32
      - name: category_name
        type: string
        label: 分类名称
        max_length: 64
      - name: parent_id
        type: relation
        label: 上级分类
        relation: DefectCategory

  - name: Defect
    label: 缺陷
    table: defect
    fields:
      - name: id
        type: integer
        label: ID
        primary_key: true
        generate: true
        sequence: { strategy: db }
      - name: defect_code
        type: string
        label: 缺陷编码
        max_length: 32
        required: true
      - name: defect_name
        type: string
        label: 缺陷名称
        max_length: 64
        required: true
      - name: category_id
        type: relation
        label: 缺陷分类
        relation: DefectCategory
        required: true
      - name: severity
        type: enum
        label: 严重程度
        values: critical, major, minor
        default: minor
      - name: status
        type: enum
        label: 状态
        values: active, inactive
        default: active

    permissions:
      read:      [operator, supervisor, quality_inspector, admin]
      create:    [quality_inspector, admin]
      write:     [quality_inspector, admin]
      delete:    [admin]
```

#### 3.6.3 QualityCategory — 质量分类

**设计意图：** 参考 MES 模型的三级质量分类体系。用于对缺陷、检验项目等进行分类归集，支撑品质分析。

```yaml
# domain/base/core/quality_category.yaml
domain: base.quality_category
name: 质量分类
version: 1.0.0
description: 质量三级分类体系，用于缺陷和检验项目分类

entities:
  - name: QualityCategory
    label: 质量分类
    table: quality_category
    fields:
      - name: id
        type: integer
        label: ID
        primary_key: true
        generate: true
        sequence: { strategy: db }
      - name: category_code
        type: string
        label: 分类编码
        max_length: 32
        required: true
      - name: category_name
        type: string
        label: 分类名称
        max_length: 64
        required: true
      - name: level
        type: integer
        label: 层级（1=大类/2=中类/3=小类）
        required: true
        default: 1
      - name: parent_id
        type: relation
        label: 上级分类
        relation: QualityCategory
      - name: status
        type: enum
        label: 状态
        values: active, inactive
        default: active

    permissions:
      read:      [operator, supervisor, quality_inspector, admin]
      create:    [quality_inspector, admin]
      write:     [quality_inspector, admin]
      delete:    [admin]
```

**P0 决策说明：** 三级分类利用 `parent_id` 自关联实现，不拆分三个独立实体，保持 DSL 简洁。

### 3.7 追溯辅助

#### 3.7.1 CodingRule — 编码规则

**设计意图：** 参考 MES 模型的编码规则引擎。统一管理工单编号、质检编号、条码编号、设备编号等所有系统编号的生成规则。P0 只做规则定义，不做复杂的编码段分配。

```yaml
# domain/base/core/coding_rule.yaml
domain: base.coding_rule
name: 编码规则
version: 1.0.0
description: 统一编码规则定义，管理所有业务编号的生成策略

entities:
  - name: CodingRule
    label: 编码规则
    table: coding_rule
    fields:
      - name: id
        type: integer
        label: ID
        primary_key: true
        generate: true
        sequence: { strategy: db }
      - name: rule_code
        type: string
        label: 规则编码
        max_length: 32
        required: true
        unique: true
      - name: rule_name
        type: string
        label: 规则名称
        max_length: 64
        required: true
      - name: entity_type
        type: enum
        label: 适用对象
        values: work_order, quality_check, barcode, device, production_record, operator
        required: true
      - name: prefix
        type: string
        label: 前缀
        max_length: 16
        description: 如 "WO"、"QC"、"PR"
      - name: date_format
        type: string
        label: 日期格式
        max_length: 16
        default: "YYYYMMDD"
        description: 如 "YYYYMMDD"、"YYMMDD"
      - name: seq_digits
        type: integer
        label: 流水号位数
        default: 5
        validate:
          min: 3
          max: 10
      - name: seq_strategy
        type: enum
        label: 流水号策略
        values: db, redis, snowflake
        default: db
      - name: seq_scope
        type: enum
        label: 流水号范围
        values: daily, monthly, global
        default: daily
      - name: sample_output
        type: string
        label: 示例输出
        max_length: 32
        description: 如 "WO2026071400005"
      - name: status
        type: enum
        label: 状态
        values: active, inactive
        default: active
      - name: created_at
        type: datetime
        label: 创建时间
        auto_fill: NOW()
        read_only: true

    list_view:
      columns:
        - field: rule_code
          label: 规则编码
        - field: rule_name
          label: 规则名称
        - field: entity_type
          label: 适用对象
          formatter: tag
        - field: prefix
          label: 前缀
        - field: seq_digits
          label: 流水号位数
          align: right
        - field: sample_output
          label: 示例
        - field: status
          label: 状态
          formatter: status_tag

    permissions:
      read:      [supervisor, admin]
      create:    [admin]
      write:     [admin]
      delete:    [admin]
```

**P0 决策说明：**
| 决策 | 理由 |
|------|------|
| 不作为独立引擎 | P0 只定义规则数据，不实现独立的编码引擎服务，编号生成在应用层处理 |
| 不分编码段 | P0 不做编码段预分配，P1 补充号段并发控制 |
| 示例输出字段 | 方便前端预览编码效果 |

#### 3.7.2 Container — 容器管理

**设计意图：** 参考 MES 模型的容器管理。料箱、托盘、工装板等生产容器的注册和状态跟踪。P0 只做容器注册和设备关联，不做全生命周期流转。

```yaml
# domain/base/core/container.yaml
domain: base.container
name: 容器管理
version: 1.0.0
description: 料箱/托盘/工装板等生产容器的注册和状态管理

entities:
  - name: Container
    label: 容器
    table: container
    fields:
      - name: id
        type: integer
        label: ID
        primary_key: true
        generate: true
        sequence: { strategy: db }
      - name: container_code
        type: string
        label: 容器编码
        max_length: 32
        required: true
        unique: true
        generate: true
        generate_rule: "CT{YYYYMMDD}{SEQ5}"
      - name: container_name
        type: string
        label: 容器名称
        max_length: 64
      - name: container_type
        type: enum
        label: 容器类型
        values: bin, pallet, fixture_tray, tote, other
        default: bin
        required: true
      - name: status
        type: enum
        label: 容器状态
        values: empty, loaded, in_transit, maintenance, scrapped
        default: empty
        required: true
      - name: max_weight_kg
        type: float
        label: 最大承重(kg)
      - name: device_id
        type: relation
        label: 当前关联设备
        relation: Device
        description: 容器当前所在的设备
      - name: workstation_id
        type: relation
        label: 当前所在工位
        relation: Workstation
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
      - name: device
        target: Device
        type: belongs_to
        foreign_key: device_id
        label: 关联设备

    list_view:
      columns:
        - field: container_code
          label: 容器编码
          sortable: true
        - field: container_name
          label: 容器名称
        - field: container_type
          label: 类型
          formatter: tag
        - field: status
          label: 状态
          formatter: status_tag
        - field: device_id
          label: 关联设备
        - field: workstation_id
          label: 所在工位

    permissions:
      read:      [operator, supervisor, admin]
      create:    [supervisor, admin]
      write:     [operator, supervisor, admin]
      delete:    [admin]
```

**P0 决策说明：**
| 决策 | 理由 |
|------|------|
| 不做容器-物料关联表 | P0 容器只关联设备/工位，物料内容通过生产记录追溯，P1 补充容器与物料关系 |
| 不做容器全生命周期 | P0 只做基础状态管理，P1 补充流转历史 |

#### 3.7.3 MaterialAttrTemplate — 物料属性模板

**设计意图：** 参考 MES 模型的物料属性扩展功能。以 key-value 模式支持物料的动态属性（颜色、材质、硬度等），避免在 Material 实体上不断增加字段。

```yaml
# domain/base/core/material_attr_template.yaml
domain: base.material_attr_template
name: 物料属性模板
version: 1.0.0
description: 物料动态属性模板，以 key-value 模式支持可扩展属性

entities:
  - name: MaterialAttrTemplate
    label: 物料属性模板
    table: material_attr_template
    fields:
      - name: id
        type: integer
        label: ID
        primary_key: true
        generate: true
        sequence: { strategy: db }
      - name: attr_code
        type: string
        label: 属性编码
        max_length: 32
        required: true
        unique: true
      - name: attr_name
        type: string
        label: 属性名称
        max_length: 64
        required: true
      - name: attr_type
        type: enum
        label: 属性类型
        values: text, number, enum, date, boolean
        default: text
      - name: options
        type: string
        label: 可选值列表
        max_length: 500
        description: "枚举类型时使用，逗号分隔，如：红色,蓝色,绿色"
      - name: unit
        type: string
        label: 单位
        max_length: 16
        description: "如 mm, kg, ℃"
      - name: required
        type: boolean
        label: 是否必填
        default: false
      - name: status
        type: enum
        label: 状态
        values: active, inactive
        default: active
      - name: created_at
        type: datetime
        label: 创建时间
        auto_fill: NOW()
        read_only: true

  - name: MaterialAttrValue
    label: 物料属性值
    table: material_attr_value
    fields:
      - name: id
        type: integer
        label: ID
        primary_key: true
        generate: true
        sequence: { strategy: db }
      - name: material_id
        type: relation
        label: 物料
        relation: Material
        required: true
      - name: attr_id
        type: relation
        label: 属性模板
        relation: MaterialAttrTemplate
        required: true
      - name: value
        type: string
        label: 属性值
        max_length: 256
        required: true
      - name: created_at
        type: datetime
        label: 创建时间
        auto_fill: NOW()
        read_only: true

    permissions:
      read:      [operator, supervisor, admin]
      create:    [supervisor, admin]
      write:     [supervisor, admin]
      delete:    [admin]
```

**P0 决策说明：**
| 决策 | 理由 |
|------|------|
| key-value 模式 | 不实现 EAV 复杂模型，直接用两张表（模板+值）满足扩展需求 |
| 不做高级查询 | P0 不做属性值的过滤/聚合查询，P1 补充 |
| 属性类型有限 | 仅支持 5 种基础类型，P1 补充图片/文件等复杂类型 |

---

## 4. 状态流设计

### 4.1 WorkOrder 状态机

```
                 ┌──────────────┐
            ┌───▶│  completed   │
            │    │  已完成(终态) │
            │    └──────────────┘
            │
┌──────────┐│    ┌──────────────┐
│ pending  ││    │   running    │
│ 待开工    │├───▶│  生产中      │
└────┬─────┘│    └──────┬───────┘
     │      │           │
     │      │      ┌────▼──────┐
     │      └──────│   paused   │
     │             │  暂停中    │
     │             └────┬──────┘
     │                  │
     │    ┌─────────────▼─────┐
     └────│    cancelled       │
          │  已取消(终态)       │
          └───────────────────┘

states: pending → released → running ↔ paused → completed | cancelled
```

### 4.2 Device 状态机

```
idle → running → maintenance ↔ idle
     → fault → maintenance → idle
     → offline

states: idle, running, maintenance, fault, offline
```

### 4.3 QualityCheck 状态机

```
pending → pass (合格)
        → fail (不合格)
        → rework (返工) → pass | fail
```

---

## 5. 权限体系

### 5.1 角色定义

| 角色 | 代码 | 权限范围 |
|------|------|---------|
| 操作员 | `operator` | 查看所有，开工/完工，记录生产数据 |
| 班组长 | `supervisor` | 创建工单、编辑物料、管理班次和人员 |
| 质检员 | `quality_inspector` | 质检录入、缺陷管理、查看生产数据 |
| 管理员 | `admin` | 全部权限 |

### 5.2 P0 完整文件清单

```
domain/
├── base/
│   ├── core/
│   │   ├── 人员管理
│   │   │   ├── org_structure.yaml      # 工厂/车间/产线
│   │   │   ├── user.yaml               # 系统用户
│   │   │   ├── operator.yaml           # 作业人员
│   │   │   ├── skill.yaml              # 技能管理
│   │   │   └── shift.yaml              # 班次管理（含班制）
│   │   │
│   │   ├── 设备管理
│   │   │   ├── device.yaml             # 设备台账（含设备类型）
│   │   │   └── workstation.yaml        # 工位
│   │   │
│   │   ├── 物料管理
│   │   │   ├── material.yaml           # 物料主数据
│   │   │   ├── material_category.yaml  # 物料分类
│   │   │   ├── material_attr_template.yaml # 物料属性模板 ✨
│   │   │   └── bom.yaml                # 产品 BOM
│   │   │
│   │   ├── 工艺管理
│   │   │   ├── process_route.yaml      # 工艺路线
│   │   │   ├── process_step.yaml       # 工序定义
│   │   │   └── process_param.yaml      # 工艺参数
│   │   │
│   │   ├── 生产执行
│   │   │   ├── work_order.yaml         # 工单
│   │   │   ├── work_order_bom.yaml     # 工单 BOM
│   │   │   └── production_record.yaml  # 生产记录（追溯核心）
│   │   │
│   │   ├── 品质管控
│   │   │   ├── quality_category.yaml   # 质量分类 ✨
│   │   │   ├── defect.yaml             # 缺陷定义（含缺陷分类）
│   │   │   ├── quality_check.yaml      # 质检记录
│   │   │   ├── inspection_item.yaml    # 检验项目
│   │   │   └── inspection_plan.yaml    # 抽样方案
│   │   │
│   │   └── 追溯辅助
│   │       ├── coding_rule.yaml        # 编码规则 ✨
│   │       ├── barcode.yaml            # 条码追踪
│   │       └── container.yaml          # 容器管理 ✨
│   │
│   ├── workflows/
│   │   ├── work_order_flow.yaml        # 工单状态机
│   │   ├── quality_check_flow.yaml     # 质检状态机
│   │   └── device_flow.yaml            # 设备状态机
│   │
│   └── permissions/
│       └── roles.yaml                  # 角色权限矩阵
│
├── industries/
│   └── precision_metal/                # P1 补充
│
├── projects/                           # P1 补充
│
└── domain-schema.json                  # 已有（可能需要扩展）
```

**合计：** 24 个 DSL 文件（core 20 + workflows 3 + permissions 1）

---

## 6. 与参考 MES 模型的对比

| 参考模型领域 | P0 覆盖 | 说明 |
|-------------|---------|------|
| 仓库/库存 | ❌ | P1 补充 |
| 采购/销售 | ❌ | P1 补充 |
| 生产执行 | ✅ | 工单、BOM、工艺路线、生产记录 |
| 品质 | ✅ | IQC/PQC/OQC、缺陷管理、质量分类 |
| 人员管理 | ✅ | 组织、人员、班次、技能 |
| 设备/资源 | ✅ | 设备分类、台账、状态、容器 |
| 物料 | ✅ | 主数据、分类、属性模板、BOM |
| 条码/编码 | ✅ | 编码规则、条码（简化） |
| 包装管理 | ❌ | P1 补充 |
| 排产/APS | ❌ | P2 补充 |

---

## 7. 验收标准

| 编号 | 验收项 | 标准 |
|------|--------|------|
| A1 | 完整 DSL 文件数 | 24+ 个 YAML 文件（core 20 + flow 3 + roles 1）全部通过 schema.json 校验 |
| A2 | 追溯链完整 | 从 WorkOrder → ProductionRecord → QualityCheck 的链路上，每条记录可关联操作人员、设备、物料、时间 |
| A3 | 品质管控覆盖 | 支持 IQC/PQC/OQC/首件检验四种类型，含缺陷关联 |
| A4 | 四大场景覆盖 | 人员（组织/角色/作业者/班次）、设备（台账/状态）、物料（分类/BOM）、工艺（路线/工序/工位） |
| A5 | 关系完整性 | 所有 foreign_key 指向的实体都存在，relation 双向可追溯 |
| A6 | 状态流完整性 | 所有 transitions 的 from/to 状态都在 states 中定义 |
| A7 | 权限覆盖度 | 4 个角色覆盖所有实体的 CRUD 操作 |
