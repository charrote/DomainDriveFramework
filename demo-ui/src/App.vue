<template>
  <div class="ddf-app" :data-theme="theme">
    <!-- Top Bar -->
    <header class="topbar">
      <div class="topbar__brand">
        <svg class="topbar__logo" viewBox="0 0 32 32" fill="none">
          <rect width="32" height="32" rx="6" fill="#1E2761"/>
          <path d="M8 10h6v12H8zM18 10h6v6h-6zM18 18h6v4h-6z" fill="#fff" opacity="0.9"/>
        </svg>
        <span class="topbar__title">DDF</span>
        <span class="topbar__subtitle">模型设计中心</span>
      </div>
      <nav class="topbar__nav">
        <button
          v-for="tab in sectionTabs"
          :key="tab.key"
          class="topbar__nav-item"
          :class="{ active: currentSection === tab.key }"
          @click="currentSection = tab.key"
        >{{ tab.label }}</button>
      </nav>
      <div class="topbar__actions">
        <button class="topbar__action-btn" @click="toggleTheme" :title="'切换主题 (' + theme + ')'">
          <Icon :name="themeIcon" :size="16" />
        </button>
      </div>
    </header>

    <div class="main-container">
      <!-- Sidebar -->
      <aside class="sidebar">
        <nav class="sidebar__nav">
          <div class="sidebar__group">
            <div class="sidebar__group-title">建模</div>
            <a class="sidebar__item" @click="currentSection = 'overview'">
              <Icon name="list" />
              <span>实体列表</span>
            </a>
            <a class="sidebar__item" @click="currentSection = 'overview'">
              <Icon name="link" />
              <span>关系管理</span>
            </a>
            <a class="sidebar__item" @click="currentSection = 'overview'">
              <Icon name="settings" />
              <span>工作流</span>
            </a>
            <a class="sidebar__item" @click="currentSection = 'overview'">
              <Icon name="ruler" />
              <span>权限配置</span>
            </a>
          </div>
          <div class="sidebar__group">
            <div class="sidebar__group-title">市场</div>
            <a class="sidebar__item" @click="currentSection = 'market'">
              <Icon name="box" />
              <span>模型库</span>
            </a>
            <a class="sidebar__item" @click="currentSection = 'market'">
              <Icon name="star" />
              <span>精选模型</span>
            </a>
          </div>
          <div class="sidebar__group">
            <div class="sidebar__group-title">项目</div>
            <a class="sidebar__item" @click="currentSection = 'overview'">
              <Icon name="folder" />
              <span>项目列表</span>
            </a>
          </div>
          <div class="sidebar__group">
            <div class="sidebar__group-title">管理</div>
            <a class="sidebar__item" @click="currentSection = 'overview'">
              <Icon name="barChart" />
              <span>控制台</span>
            </a>
          </div>
        </nav>
        <div class="sidebar__profile">
          <span class="sidebar__profile-dot active"></span>
          <span class="sidebar__profile-text">precision_metal v2.1</span>
        </div>
      </aside>

      <main class="content">
        <DdfBreadcrumb
          :items="[
            { label: '精密五金 MES' },
            { label: sectionLabel },
          ]"
        />

        <template v-if="currentSection === 'overview'">
          <div class="section-header">
            <h1 class="section-header__title">总览</h1>
            <p class="section-header__desc">精密五金 MES v2.1 · 5 实体 · 3 工作流 · 4 角色</p>
          </div>
          <div class="stats-row">
            <div class="stat-card">
              <div class="stat-card__value">5</div>
              <div class="stat-card__label">实体</div>
              <div class="stat-card__bar" style="width: 100%"></div>
            </div>
            <div class="stat-card">
              <div class="stat-card__value">42</div>
              <div class="stat-card__label">字段</div>
              <div class="stat-card__bar" style="width: 78%"></div>
            </div>
            <div class="stat-card">
              <div class="stat-card__value">3</div>
              <div class="stat-card__label">工作流</div>
              <div class="stat-card__bar" style="width: 60%"></div>
            </div>
            <div class="stat-card">
              <div class="stat-card__value">142</div>
              <div class="stat-card__label">生成文件</div>
              <div class="stat-card__bar" style="width: 92%"></div>
            </div>
          </div>
          <div class="section-card">
            <h3 class="section-card__title">模型状态</h3>
            <div class="status-row">
              <div class="status-item">
                <DdfStatusIndicator :color="'--color-status-running'" />
                <span>精密五金 MES</span>
                <span class="status-item__meta">v2.1 · 运行中</span>
              </div>
              <div class="status-item">
                <DdfStatusIndicator :color="'--color-status-completed'" />
                <span>电子 MES</span>
                <span class="status-item__meta">v1.3 · 已归档</span>
              </div>
              <div class="status-item">
                <DdfStatusIndicator :color="'--color-status-paused'" />
                <span>供应链支持</span>
                <span class="status-item__meta">v0.9 · 暂停</span>
              </div>
              <div class="status-item">
                <DdfStatusIndicator :color="'--color-status-pending'" />
                <span>质检管理</span>
                <span class="status-item__meta">v1.0 · 待启动</span>
              </div>
            </div>
          </div>
          <div class="section-card">
            <h3 class="section-card__title">实体概览</h3>
            <table class="ddf-table">
              <thead>
                <tr>
                  <th>实体名称</th>
                  <th>字段数</th>
                  <th>关系数</th>
                  <th>状态</th>
                  <th>操作</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td><strong>WorkOrder</strong></td>
                  <td>12</td>
                  <td>3</td>
                  <td><DdfTag :color="'success'" size="sm">已发布</DdfTag></td>
                  <td><DdfLink>编辑</DdfLink></td>
                </tr>
                <tr>
                  <td><strong>BOMItem</strong></td>
                  <td>8</td>
                  <td>2</td>
                  <td><DdfTag :color="'success'" size="sm">已发布</DdfTag></td>
                  <td><DdfLink>编辑</DdfLink></td>
                </tr>
                <tr>
                  <td><strong>ProcessRoute</strong></td>
                  <td>6</td>
                  <td>1</td>
                  <td><DdfTag :color="'warning'" size="sm">草稿</DdfTag></td>
                  <td><DdfLink>编辑</DdfLink></td>
                </tr>
                <tr>
                  <td><strong>QualityCheck</strong></td>
                  <td>10</td>
                  <td>2</td>
                  <td><DdfTag :color="'info'" size="sm">审核中</DdfTag></td>
                  <td><DdfLink>编辑</DdfLink></td>
                </tr>
                <tr>
                  <td><strong>ProductionReport</strong></td>
                  <td>9</td>
                  <td>1</td>
                  <td><DdfTag :color="'success'" size="sm">已发布</DdfTag></td>
                  <td><DdfLink>编辑</DdfLink></td>
                </tr>
              </tbody>
            </table>
          </div>
          <div class="section-card">
            <h3 class="section-card__title">色彩系统</h3>
            <div class="color-grid">
              <div class="color-swatch" :style="{ background: 'var(--color-primary-500)' }">
                <span>primary-500<br/><small>#1E2761</small></span>
              </div>
              <div class="color-swatch" :style="{ background: 'var(--color-primary-400)' }">
                <span>primary-400<br/><small>#3d5bb6</small></span>
              </div>
              <div class="color-swatch" :style="{ background: 'var(--color-steel-900)' }">
                <span>steel-900<br/><small>#141721</small></span>
              </div>
              <div class="color-swatch" :style="{ background: 'var(--color-steel-500)' }">
                <span>steel-500<br/><small>#51586d</small></span>
              </div>
              <div class="color-swatch" :style="{ background: 'var(--color-steel-200)' }">
                <span>steel-200<br/><small>#d6dae2</small></span>
              </div>
              <div class="color-swatch" :style="{ background: 'var(--color-success)' }">
                <span>success<br/><small>#16a34a</small></span>
              </div>
              <div class="color-swatch" :style="{ background: 'var(--color-warning)' }">
                <span>warning<br/><small>#d97706</small></span>
              </div>
              <div class="color-swatch" :style="{ background: 'var(--color-danger)' }">
                <span>danger<br/><small>#dc2626</small></span>
              </div>
            </div>
          </div>
          <div class="section-card">
            <h3 class="section-card__title">排版系统</h3>
            <div class="typo-grid">
              <div>
                <p class="typo-grid__label">2xl</p>
                <h2 style="font-size: var(--font-size-2xl)">页面标题</h2>
              </div>
              <div>
                <p class="typo-grid__label">xl</p>
                <h3 style="font-size: var(--font-size-xl)">章节标题</h3>
              </div>
              <div>
                <p class="typo-grid__label">lg</p>
                <h4 style="font-size: var(--font-size-lg)">段落标题</h4>
              </div>
              <div>
                <p class="typo-grid__label">base (14px)</p>
                <p>正文文本 — 工业平台信息密度高，14px 是阅读舒适度的平衡点</p>
              </div>
              <div>
                <p class="typo-grid__label">sm (12px)</p>
                <p>辅助文本 — 标签、说明文字、时间戳</p>
              </div>
              <div>
                <p class="typo-grid__label">mono</p>
                <code class="mono-text">order_no: string / required: true</code>
              </div>
            </div>
          </div>
          <div class="section-card">
            <h3 class="section-card__title">按钮样式</h3>
            <div class="button-row">
              <DdfButton variant="primary">主要操作</DdfButton>
              <DdfButton variant="primary" size="sm">小按钮</DdfButton>
              <DdfButton variant="outline">次要操作</DdfButton>
              <DdfButton variant="text">文字按钮</DdfButton>
              <DdfButton variant="ghost" disabled>禁用态</DdfButton>
            </div>
          </div>
          <div class="section-card">
            <h3 class="section-card__title">圆角 &amp; 阴影</h3>
            <div class="radius-row">
              <div class="radius-demo" style="border-radius: var(--radius-sm)">4px<br/><small>sm</small></div>
              <div class="radius-demo shadow-sm" style="border-radius: var(--radius-base)">6px<br/><small>base</small></div>
              <div class="radius-demo shadow-base" style="border-radius: var(--radius-md)">8px<br/><small>md</small></div>
              <div class="radius-demo shadow-md" style="border-radius: var(--radius-lg)">12px<br/><small>lg</small></div>
              <div class="radius-demo shadow-lg" style="border-radius: var(--radius-full)">○<br/><small>full</small></div>
            </div>
          </div>
        </template>

        <template v-if="currentSection === 'market'">
          <div class="section-header">
            <h1 class="section-header__title">模型市场</h1>
            <p class="section-header__desc">浏览、继承、分享行业模型</p>
          </div>
          <div class="market-filters">
            <input type="text" class="input input--search" placeholder="搜索模型名称..." />
            <div class="filter-pills">
              <span class="filter-pill active">全部</span>
              <span class="filter-pill">精选模型</span>
              <span class="filter-pill">普通模型</span>
            </div>
          </div>
          <div class="market-grid">
            <div class="market-card">
              <div class="market-card__header">
                <DdfBadge variant="featured">精选</DdfBadge>
                <span class="market-card__name">精密五金 MES</span>
              </div>
              <div class="market-card__body">
                <div class="market-card__stat">
                  <span class="market-card__stat-value">128</span>
                  <span class="market-card__stat-label">继承次数</span>
                </div>
                <div class="market-card__stat">
                  <span class="market-card__stat-value">4.8</span>
                  <span class="market-card__stat-label">评分</span>
                </div>
              </div>
              <div class="market-card__footer">
                <DdfButton variant="primary" size="sm">继承</DdfButton>
                <DdfButton variant="outline" size="sm">详情</DdfButton>
              </div>
            </div>
            <div class="market-card">
              <div class="market-card__header">
                <DdfBadge variant="featured">精选</DdfBadge>
                <span class="market-card__name">电子 MES</span>
              </div>
              <div class="market-card__body">
                <div class="market-card__stat">
                  <span class="market-card__stat-value">67</span>
                  <span class="market-card__stat-label">继承次数</span>
                </div>
                <div class="market-card__stat">
                  <span class="market-card__stat-value">4.6</span>
                  <span class="market-card__stat-label">评分</span>
                </div>
              </div>
              <div class="market-card__footer">
                <DdfButton variant="primary" size="sm">继承</DdfButton>
                <DdfButton variant="outline" size="sm">详情</DdfButton>
              </div>
            </div>
            <div class="market-card">
              <div class="market-card__header">
                <DdfBadge variant="normal">普通</DdfBadge>
                <span class="market-card__name">供应链支持</span>
              </div>
              <div class="market-card__body">
                <div class="market-card__stat">
                  <span class="market-card__stat-value">23</span>
                  <span class="market-card__stat-label">继承次数</span>
                </div>
                <div class="market-card__stat">
                  <span class="market-card__stat-value">4.2</span>
                  <span class="market-card__stat-label">评分</span>
                </div>
              </div>
              <div class="market-card__footer">
                <DdfButton variant="primary" size="sm">继承</DdfButton>
                <DdfButton variant="outline" size="sm">详情</DdfButton>
              </div>
            </div>
            <div class="market-card">
              <div class="market-card__header">
                <DdfBadge variant="featured">精选</DdfBadge>
                <span class="market-card__name">WMS 扩展</span>
              </div>
              <div class="market-card__body">
                <div class="market-card__stat">
                  <span class="market-card__stat-value">89</span>
                  <span class="market-card__stat-label">继承次数</span>
                </div>
                <div class="market-card__stat">
                  <span class="market-card__stat-value">4.9</span>
                  <span class="market-card__stat-label">评分</span>
                </div>
              </div>
              <div class="market-card__footer">
                <DdfButton variant="primary" size="sm">继承</DdfButton>
                <DdfButton variant="outline" size="sm">详情</DdfButton>
              </div>
            </div>
          </div>
        </template>

        <template v-if="currentSection === 'designer'">
          <div class="section-header">
            <h1 class="section-header__title">模型设计器</h1>
            <p class="section-header__desc">WorkOrder 工单 — 双栏编辑模式</p>
          </div>
          <div class="designer-layout">
            <div class="designer__editor">
              <div class="designer__field">
                <div class="field-header">
                  <Icon name="type" :size="14" />
                  <span class="field-name">order_no</span>
                  <DdfTag color="steel" size="sm">string</DdfTag>
                  <DdfTag color="success" size="sm">必填</DdfTag>
                </div>
                <div class="field-config">
                  <label>最大长度</label>
                  <input type="number" class="input input--sm" value="32" />
                  <label>默认值</label>
                  <input type="text" class="input input--sm" placeholder="自动生成" />
                </div>
              </div>
              <div class="designer__field">
                <div class="field-header">
                  <Icon name="link" :size="14" />
                  <span class="field-name">product_id</span>
                  <DdfTag color="steel" size="sm">relation</DdfTag>
                  <DdfTag color="success" size="sm">必填</DdfTag>
                </div>
                <div class="field-config">
                  <label>关联实体</label>
                  <input type="text" class="input input--sm" value="Product" disabled />
                  <label>外键</label>
                  <input type="text" class="input input--sm" value="product_id" disabled />
                </div>
              </div>
              <div class="designer__field">
                <div class="field-header">
                  <Icon name="hash" :size="14" />
                  <span class="field-name">quantity</span>
                  <DdfTag color="steel" size="sm">integer</DdfTag>
                  <DdfTag color="success" size="sm">必填</DdfTag>
                </div>
                <div class="field-config">
                  <label>最小值</label>
                  <input type="number" class="input input--sm" value="1" />
                  <label>最大值</label>
                  <input type="number" class="input input--sm" value="999999" />
                </div>
              </div>
              <div class="designer__field">
                <div class="field-header">
                  <Icon name="tag" :size="14" />
                  <span class="field-name">priority</span>
                  <DdfTag color="steel" size="sm">enum</DdfTag>
                  <DdfTag color="warning" size="sm">默认: normal</DdfTag>
                </div>
                <div class="field-config">
                  <div class="enum-tags">
                    <span class="enum-tag">low</span>
                    <span class="enum-tag enum-tag--default">normal</span>
                    <span class="enum-tag">high</span>
                    <span class="enum-tag">urgent</span>
                  </div>
                </div>
              </div>
              <div class="designer__field">
                <div class="field-header">
                  <Icon name="calendar" :size="14" />
                  <span class="field-name">created_at</span>
                  <DdfTag color="steel" size="sm">datetime</DdfTag>
                  <DdfTag color="info" size="sm">只读</DdfTag>
                </div>
                <div class="field-config">
                  <label>自动生成</label>
                  <div class="switch-group">
                    <span class="switch active"></span>
                    <span class="switch-label">NOW()</span>
                  </div>
                </div>
              </div>
            </div>
            <div class="designer__yaml">
              <div class="yaml-header">YAML 预览</div>
              <pre class="yaml-content"><span class="yaml-key">entity</span>:
  <span class="yaml-key">domain</span>: <span class="yaml-val">work_order</span>
  <span class="yaml-key">name</span>: <span class="yaml-val">WorkOrder</span>
  <span class="yaml-key">label</span>: <span class="yaml-val">工单</span>
  <span class="yaml-key">table</span>: <span class="yaml-val">work_order</span>
  <span class="yaml-key">fields</span>:
    - <span class="yaml-key">name</span>: <span class="yaml-val">order_no</span>
      <span class="yaml-key">type</span>: <span class="yaml-val">string</span>
      <span class="yaml-key">required</span>: <span class="yaml-val">true</span>
      <span class="yaml-key">max_length</span>: <span class="yaml-val">32</span>
    - <span class="yaml-key">name</span>: <span class="yaml-val">quantity</span>
      <span class="yaml-key">type</span>: <span class="yaml-val">integer</span>
      <span class="yaml-key">required</span>: <span class="yaml-val">true</span>
    - <span class="yaml-key">name</span>: <span class="yaml-val">priority</span>
      <span class="yaml-key">type</span>: <span class="yaml-val">enum</span>
      <span class="yaml-key">default</span>: <span class="yaml-val">normal</span></pre>
            </div>
          </div>
          <div class="section-card mt-4">
            <h3 class="section-card__title">校验报告</h3>
            <div class="validation-list">
              <div class="validation-item valid">
                <DdfStatusIndicator color="#16a34a" />
                <span>Schema 合规 — 所有字段符合 JSON Schema 定义</span>
              </div>
              <div class="validation-item valid">
                <DdfStatusIndicator color="#16a34a" />
                <span>引用完整 — 关系字段指向已定义实体</span>
              </div>
              <div class="validation-item warning">
                <DdfStatusIndicator color="#d97706" />
                <span>字段 "product_id" 缺少注释说明</span>
              </div>
            </div>
          </div>
        </template>

        <template v-if="currentSection === 'workflow'">
          <div class="section-header">
            <h1 class="section-header__title">状态机可视化</h1>
            <p class="section-header__desc">WorkOrder 生命周期管理</p>
          </div>
          <div class="workflow-graph">
            <div class="wf-node wf-node--pending">
              <div class="wf-node__label">pending</div>
              <div class="wf-node__desc">待启动</div>
            </div>
            <div class="wf-arrow">
              <span class="wf-arrow__label">开工</span>
              <svg class="wf-arrow__svg" viewBox="0 0 60 20">
                <line x1="0" y1="10" x2="50" y2="10" stroke="var(--color-steel-300)" stroke-width="2"/>
                <polyline points="45,5 50,10 45,15" fill="none" stroke="var(--color-steel-300)" stroke-width="2"/>
              </svg>
            </div>
            <div class="wf-node wf-node--running">
              <div class="wf-node__label">running</div>
              <div class="wf-node__desc">生产中</div>
            </div>
            <div class="wf-arrow wf-arrow--down">
              <span class="wf-arrow__label">完工</span>
              <svg class="wf-arrow__svg" viewBox="0 0 20 60">
                <line x1="10" y1="0" x2="10" y2="50" stroke="var(--color-steel-300)" stroke-width="2"/>
                <polyline points="5,45 10,50 15,45" fill="none" stroke="var(--color-steel-300)" stroke-width="2"/>
              </svg>
            </div>
            <div class="wf-node wf-node--completed">
              <div class="wf-node__label">completed</div>
              <div class="wf-node__desc">已完工</div>
            </div>
            <div class="wf-arrow wf-arrow--back">
              <span class="wf-arrow__label">暂停</span>
              <svg class="wf-arrow__svg" viewBox="0 0 60 20">
                <path d="M10,10 Q30,-10 50,10" fill="none" stroke="var(--color-steel-300)" stroke-width="2" stroke-dasharray="4,2"/>
                <polyline points="45,5 50,10 45,15" fill="none" stroke="var(--color-steel-300)" stroke-width="2"/>
              </svg>
            </div>
            <div class="wf-node wf-node--paused">
              <div class="wf-node__label">paused</div>
              <div class="wf-node__desc">暂停中</div>
            </div>
          </div>
          <div class="section-card mt-4">
            <h3 class="section-card__title">转移规则</h3>
            <table class="ddf-table">
              <thead>
                <tr>
                  <th>From</th>
                  <th>To</th>
                  <th>标签</th>
                  <th>需备注</th>
                  <th>校验条件</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td><DdfTag color="pending" size="xs">pending</DdfTag></td>
                  <td><DdfTag color="running" size="xs">running</DdfTag></td>
                  <td>开工</td>
                  <td>否</td>
                  <td>—</td>
                </tr>
                <tr>
                  <td><DdfTag color="running" size="xs">running</DdfTag></td>
                  <td><DdfTag color="paused" size="xs">paused</DdfTag></td>
                  <td>暂停</td>
                  <td>是</td>
                  <td><code class="mono-text">require_comment</code></td>
                </tr>
                <tr>
                  <td><DdfTag color="running" size="xs">running</DdfTag></td>
                  <td><DdfTag color="completed" size="xs">completed</DdfTag></td>
                  <td>完工</td>
                  <td>否</td>
                  <td><code class="mono-text">completed_qty == quantity</code></td>
                </tr>
                <tr>
                  <td>任意</td>
                  <td><DdfTag color="cancelled" size="xs">cancelled</DdfTag></td>
                  <td>取消</td>
                  <td>是</td>
                  <td><code class="mono-text">require_comment</code></td>
                </tr>
              </tbody>
            </table>
          </div>
        </template>

        <template v-if="currentSection === 'audit'">
          <div class="section-header">
            <h1 class="section-header__title">操作审计线</h1>
            <p class="section-header__desc">模型修改追溯 — 精密五金 MES / WorkOrder</p>
          </div>
          <div class="audit-timeline">
            <div class="audit-item">
              <div class="audit-item__dot audit-item__dot--edit"></div>
              <div class="audit-item__content">
                <div class="audit-item__header">
                  <span class="audit-item__user">张三</span>
                  <span class="audit-item__time">2026-07-11 14:32:05</span>
                </div>
                <div class="audit-item__action">修改了字段 <strong>order_no</strong></div>
                <div class="audit-item__detail">从 "string" 改为 "string"（长度限制 20 → 32）</div>
              </div>
            </div>
            <div class="audit-item">
              <div class="audit-item__dot audit-item__dot--add"></div>
              <div class="audit-item__content">
                <div class="audit-item__header">
                  <span class="audit-item__user">张三</span>
                  <span class="audit-item__time">2026-07-11 14:30:12</span>
                </div>
                <div class="audit-item__action">添加了新字段 <strong>priority</strong></div>
                <div class="audit-item__detail">类型: enum, 标签: 优先级, 默认: normal</div>
              </div>
            </div>
            <div class="audit-item">
              <div class="audit-item__dot audit-item__dot--gen"></div>
              <div class="audit-item__content">
                <div class="audit-item__header">
                  <span class="audit-item__user">系统</span>
                  <span class="audit-item__time">2026-07-11 14:28:45</span>
                </div>
                <div class="audit-item__action">生成项目 <strong>客户甲MES</strong></div>
                <div class="audit-item__detail">Profile: 精密五金 MES v2.1, 文件数: 142, 耗时: 2m18s</div>
              </div>
            </div>
            <div class="audit-item">
              <div class="audit-item__dot audit-item__dot--edit"></div>
              <div class="audit-item__content">
                <div class="audit-item__header">
                  <span class="audit-item__user">李四</span>
                  <span class="audit-item__time">2026-07-11 14:25:33</span>
                </div>
                <div class="audit-item__action">修改了工作流 <strong>WorkOrder 状态机</strong></div>
                <div class="audit-item__detail">新增转移: paused → running（恢复生产，无需备注）</div>
              </div>
            </div>
            <div class="audit-item">
              <div class="audit-item__dot audit-item__dot--create"></div>
              <div class="audit-item__content">
                <div class="audit-item__header">
                  <span class="audit-item__user">张三</span>
                  <span class="audit-item__time">2026-07-11 10:00:00</span>
                </div>
                <div class="audit-item__action">创建了实体 <strong>WorkOrder</strong></div>
                <div class="audit-item__detail">初始版本 — 7 个字段，3 个关系，1 个工作流</div>
              </div>
            </div>
          </div>
        </template>

        <template v-if="currentSection === 'diff'">
          <div class="section-header">
            <h1 class="section-header__title">DSL Diff 视图</h1>
            <p class="section-header__desc">v2.0 vs v2.1 — WorkOrder 实体变更对比</p>
          </div>
          <div class="diff-view">
            <div class="diff-header">
              <div class="diff-header__label">v2.0</div>
              <div class="diff-header__label">v2.1</div>
            </div>
            <div class="diff-body">
              <div class="diff-row diff-row--added">
                <div class="diff-line-num">+15</div>
                <div class="diff-content"><span class="diff-key">  </span><span class="diff-key">name</span>: <span class="diff-val">priority</span></div>
                <div class="diff-content"><span class="diff-key">    </span><span class="diff-key">type</span>: <span class="diff-val">enum</span></div>
                <div class="diff-content"><span class="diff-key">    </span><span class="diff-key">label</span>: <span class="diff-val">优先级</span></div>
                <div class="diff-content"><span class="diff-key">    </span><span class="diff-key">default</span>: <span class="diff-val">normal</span></div>
                <div class="diff-content"><span class="diff-key">    </span><span class="diff-key">values</span>: <span class="diff-val">low,normal,high,urgent</span></div>
              </div>
              <div class="diff-row diff-row--removed">
                <div class="diff-line-num">-3</div>
                <div class="diff-content"><span class="diff-key">  </span><span class="diff-key">name</span>: <span class="diff-val">description</span></div>
                <div class="diff-content"><span class="diff-key">    </span><span class="diff-key">type</span>: <span class="diff-val">string</span></div>
                <div class="diff-content"><span class="diff-key">    </span><span class="diff-key">max_length</span>: <span class="diff-val">500</span></div>
              </div>
              <div class="diff-row diff-row--modified">
                <div class="diff-line-num">~2</div>
                <div class="diff-content"><span class="diff-key">  </span><span class="diff-key">name</span>: <span class="diff-val">order_no</span></div>
                <div class="diff-content">      <span class="diff-key">max_length</span>: <span class="diff-modified">20</span><span class="diff-add">→ <strong>32</strong></span></div>
              </div>
            </div>
          </div>
        </template>
      </main>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import Icon from './components/Icon.vue'
import DdfTag from './components/DdfTag.vue'
import DdfBadge from './components/DdfBadge.vue'
import DdfBreadcrumb from './components/DdfBreadcrumb.vue'
import DdfStatusIndicator from './components/DdfStatusIndicator.vue'
import DdfLink from './components/DdfLink.vue'
import DdfButton from './components/DdfButton.vue'

const currentSection = ref('overview')

const sectionTabs = [
  { key: 'overview', label: '总览' },
  { key: 'market', label: '模型市场' },
  { key: 'designer', label: '模型设计器' },
  { key: 'workflow', label: '状态机' },
  { key: 'audit', label: '审计线' },
  { key: 'diff', label: 'Diff 视图' },
]

const sectionLabel = computed(() => {
  const labels = {
    overview: '总览',
    market: '模型市场',
    designer: '模型设计器',
    workflow: '状态机',
    audit: '审计线',
    diff: 'Diff 视图',
  }
  return labels[currentSection.value] || '总览'
})

const theme = ref('light')

function toggleTheme() {
  const order = ['light', 'dark', 'hc']
  const idx = order.indexOf(theme.value)
  theme.value = order[(idx + 1) % order.length]
  document.documentElement.setAttribute('data-theme', theme.value)
}

const themeIcon = computed(() => {
  return { light: 'moon', dark: 'sun', hc: 'sun' }[theme.value]
})
</script>

<style scoped>
.ddf-app {
  font-family: var(--font-family-base);
  font-size: var(--font-size-base);
  color: var(--color-text-primary);
  background: var(--color-bg-page);
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}
.topbar {
  height: 52px;
  background: var(--color-bg-surface);
  border-bottom: 1px solid var(--color-divider);
  display: flex;
  align-items: center;
  padding: 0 var(--space-4);
  position: sticky;
  top: 0;
  z-index: 200;
}
.topbar__brand {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-right: 32px;
  flex-shrink: 0;
}
.topbar__logo {
  width: 28px;
  height: 28px;
}
.topbar__title {
  font-size: var(--font-size-md);
  font-weight: var(--font-weight-semibold);
  color: var(--color-primary-500);
}
.topbar__subtitle {
  font-size: var(--font-size-xs);
  color: var(--color-text-secondary);
}
.topbar__nav {
  display: flex;
  gap: 2px;
  flex: 1;
}
.topbar__nav-item {
  padding: 6px 14px;
  font-size: var(--font-size-sm);
  color: var(--color-text-secondary);
  background: none;
  border: none;
  border-radius: var(--radius-sm);
  cursor: pointer;
  transition: all var(--transition-fast);
  text-decoration: none;
}
.topbar__nav-item:hover {
  background: var(--color-bg-subtle);
  color: var(--color-text-primary);
}
.topbar__nav-item.active {
  color: var(--color-primary-500);
  background: var(--color-primary-50);
  font-weight: var(--font-weight-medium);
}
[data-theme="dark"] .topbar__nav-item.active {
  background: rgba(102, 127, 197, 0.15);
}
.topbar__actions {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-shrink: 0;
}
.topbar__action-btn {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: none;
  border: 1px solid var(--color-border-default);
  border-radius: var(--radius-sm);
  cursor: pointer;
  transition: all var(--transition-fast);
}
.topbar__action-btn:hover {
  border-color: var(--color-steel-300);
  background: var(--color-bg-subtle);
}
.topbar__action-btn--text {
  width: auto;
  padding: 0 10px;
  font-size: var(--font-size-sm);
  text-decoration: none;
  color: var(--color-text-secondary);
}
.avatar-circle {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: var(--color-primary-500);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
}
.main-container {
  display: flex;
  flex: 1;
  overflow: hidden;
}
.sidebar {
  width: 240px;
  background: var(--color-bg-surface);
  border-right: 1px solid var(--color-divider);
  display: flex;
  flex-direction: column;
  overflow-y: auto;
  flex-shrink: 0;
}
.sidebar__nav {
  padding: var(--space-3) 0;
  flex: 1;
}
.sidebar__group {
  margin-bottom: var(--space-4);
}
.sidebar__group-title {
  padding: var(--space-2) var(--space-4);
  font-size: var(--font-size-xs);
  font-weight: var(--font-weight-medium);
  color: var(--color-text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}
.sidebar__item {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  padding: 8px var(--space-4);
  font-size: var(--font-size-sm);
  color: var(--color-text-secondary);
  cursor: pointer;
  transition: all var(--transition-fast);
  position: relative;
  text-decoration: none;
}
.sidebar__item:hover {
  background: var(--color-bg-subtle);
  color: var(--color-text-primary);
}
.sidebar__profile {
  padding: var(--space-3) var(--space-4);
  border-top: 1px solid var(--color-divider);
  display: flex;
  align-items: center;
  gap: var(--space-2);
  font-size: var(--font-size-xs);
  color: var(--color-text-secondary);
  background: var(--color-bg-subtle);
}
.sidebar__profile-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--color-success);
}
.sidebar__profile-dot.paused {
  background: var(--color-warning);
}
.content {
  flex: 1;
  overflow-y: auto;
  padding: var(--space-4);
  max-width: 1200px;
}
@media (max-width: 768px) {
  .topbar__nav {
    display: none;
  }
}
.section-header {
  margin-bottom: var(--space-4);
}
.section-header__title {
  font-size: var(--font-size-xl);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text-primary);
  margin: 0 0 var(--space-1);
}
.section-header__desc {
  font-size: var(--font-size-sm);
  color: var(--color-text-secondary);
  margin: 0;
}
.stats-row {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: var(--space-4);
  margin-bottom: var(--space-4);
}
.stat-card {
  background: var(--color-bg-surface);
  border: 1px solid var(--color-border-default);
  border-radius: var(--radius-base);
  padding: var(--space-4);
  position: relative;
  overflow: hidden;
}
.stat-card__value {
  font-size: var(--font-size-xl);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text-primary);
}
.stat-card__label {
  font-size: var(--font-size-xs);
  color: var(--color-text-secondary);
  margin-top: var(--space-1);
}
.stat-card__bar {
  position: absolute;
  bottom: 0;
  left: 0;
  height: 3px;
  background: var(--color-primary-500);
  border-radius: 0 0 var(--radius-base) var(--radius-base);
}
.section-card {
  background: var(--color-bg-surface);
  border: 1px solid var(--color-border-default);
  border-radius: var(--radius-base);
  padding: var(--space-4);
  margin-bottom: var(--space-4);
}
.section-card__title {
  font-size: var(--font-size-md);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text-primary);
  margin: 0 0 var(--space-3);
}
.mt-4 {
  margin-top: var(--space-4);
}
.status-row {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}
.status-item {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  padding: var(--space-2) var(--space-3);
  background: var(--color-bg-subtle);
  border-radius: var(--radius-sm);
}
.status-item__meta {
  margin-left: auto;
  font-size: var(--font-size-xs);
  color: var(--color-text-secondary);
}
.ddf-table {
  width: 100%;
  border-collapse: collapse;
}
.ddf-table th {
  text-align: left;
  padding: var(--space-2) var(--space-3);
  font-size: var(--font-size-xs);
  font-weight: var(--font-weight-medium);
  color: var(--color-text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.03em;
  border-bottom: 1px solid var(--color-border-default);
  background: var(--color-bg-subtle);
}
.ddf-table td {
  padding: var(--space-2) var(--space-3);
  font-size: var(--font-size-sm);
  color: var(--color-text-primary);
  border-bottom: 1px solid var(--color-divider);
}
.ddf-table tbody tr:hover {
  background: var(--color-bg-subtle);
}
.color-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: var(--space-3);
}
.color-swatch {
  height: 80px;
  border-radius: var(--radius-sm);
  display: flex;
  align-items: flex-end;
  justify-content: center;
  padding: var(--space-2);
  font-size: var(--font-size-xs);
  color: white;
  text-shadow: 0 1px 2px rgba(0,0,0,0.3);
}
.color-swatch small {
  opacity: 0.8;
  font-family: var(--font-family-mono);
}
.typo-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-4);
}
.typo-grid__label {
  font-size: var(--font-size-xs);
  color: var(--color-text-secondary);
  margin: 0 0 var(--space-2);
}
.mono-text {
  font-family: var(--font-family-mono);
  font-size: var(--font-size-sm);
  background: var(--color-bg-subtle);
  padding: var(--space-1) var(--space-2);
  border-radius: var(--radius-sm);
}
.button-row {
  display: flex;
  gap: var(--space-3);
  flex-wrap: wrap;
}
.radius-row {
  display: flex;
  gap: var(--space-4);
  align-items: flex-end;
}
.radius-demo {
  width: 64px;
  height: 48px;
  background: var(--color-primary-500);
  color: white;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  font-size: var(--font-size-xs);
  text-align: center;
  line-height: 1.3;
}
.shadow-sm { box-shadow: var(--shadow-sm); }
.shadow-base { box-shadow: var(--shadow-base); }
.shadow-md { box-shadow: var(--shadow-base); }
.shadow-lg { box-shadow: var(--shadow-md); }
.market-filters {
  display: flex;
  gap: var(--space-3);
  margin-bottom: var(--space-4);
  align-items: center;
}
.input {
  padding: 8px 12px;
  font-size: var(--font-size-sm);
  border: 1px solid var(--color-border-default);
  border-radius: var(--radius-sm);
  background: var(--color-bg-surface);
  color: var(--color-text-primary);
  transition: border-color var(--transition-fast);
}
.input:focus {
  outline: none;
  border-color: var(--color-border-focus);
}
.input--sm {
  padding: 5px 8px;
  font-size: var(--font-size-xs);
}
.input--search {
  flex: 1;
  min-width: 200px;
}
.filter-pills {
  display: flex;
  gap: var(--space-2);
}
.filter-pill {
  padding: 4px 12px;
  font-size: var(--font-size-xs);
  border-radius: var(--radius-full);
  border: 1px solid var(--color-border-default);
  cursor: pointer;
  transition: all var(--transition-fast);
  color: var(--color-text-secondary);
}
.filter-pill:hover {
  border-color: var(--color-primary-500);
  color: var(--color-primary-500);
}
.filter-pill.active {
  background: var(--color-primary-500);
  border-color: var(--color-primary-500);
  color: white;
}
.market-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: var(--space-4);
}
.market-card {
  background: var(--color-bg-surface);
  border: 1px solid var(--color-border-default);
  border-radius: var(--radius-base);
  padding: var(--space-4);
  transition: box-shadow var(--transition-fast);
}
.market-card:hover {
  box-shadow: var(--shadow-sm);
}
.market-card__header {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  margin-bottom: var(--space-3);
}
.market-card__name {
  font-size: var(--font-size-md);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text-primary);
}
.market-card__body {
  display: flex;
  gap: var(--space-4);
  margin-bottom: var(--space-3);
}
.market-card__stat {
  text-align: center;
}
.market-card__stat-value {
  display: block;
  font-size: var(--font-size-lg);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text-primary);
}
.market-card__stat-label {
  font-size: var(--font-size-xs);
  color: var(--color-text-secondary);
}
.market-card__footer {
  display: flex;
  gap: var(--space-2);
}
.designer-layout {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-4);
}
.designer__editor {
  background: var(--color-bg-surface);
  border: 1px solid var(--color-border-default);
  border-radius: var(--radius-base);
  padding: var(--space-4);
}
.designer__yaml {
  background: var(--color-bg-surface);
  border: 1px solid var(--color-border-default);
  border-radius: var(--radius-base);
  overflow: hidden;
}
.yaml-header {
  padding: var(--space-2) var(--space-3);
  background: var(--color-bg-subtle);
  font-size: var(--font-size-xs);
  font-weight: var(--font-weight-medium);
  color: var(--color-text-secondary);
  border-bottom: 1px solid var(--color-border-default);
}
.yaml-content {
  padding: var(--space-3);
  font-family: var(--font-family-mono);
  font-size: var(--font-size-xs);
  line-height: 1.6;
  color: var(--color-text-secondary);
  overflow-x: auto;
}
.yaml-key {
  color: var(--color-primary-400);
}
.yaml-val {
  color: var(--color-success);
}
.designer__field {
  padding: var(--space-3) 0;
  border-bottom: 1px solid var(--color-divider);
}
.designer__field:last-child {
  border-bottom: none;
}
.field-header {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  margin-bottom: var(--space-2);
}
.field-name {
  font-family: var(--font-family-mono);
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  color: var(--color-text-primary);
}
.field-config {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--space-2);
}
.field-config label {
  font-size: var(--font-size-xs);
  color: var(--color-text-secondary);
}
.enum-tags {
  display: flex;
  gap: var(--space-1);
  flex-wrap: wrap;
}
.enum-tag {
  padding: 2px 8px;
  font-size: var(--font-size-xs);
  background: var(--color-bg-subtle);
  border: 1px solid var(--color-border-default);
  border-radius: var(--radius-full);
  color: var(--color-text-secondary);
}
.enum-tag--default {
  border-color: var(--color-primary-500);
  color: var(--color-primary-500);
}
.switch-group {
  display: flex;
  align-items: center;
  gap: var(--space-2);
}
.switch {
  width: 32px;
  height: 18px;
  background: var(--color-steel-300);
  border-radius: 9px;
  position: relative;
  transition: background var(--transition-fast);
}
.switch.active {
  background: var(--color-primary-500);
}
.switch::after {
  content: '';
  position: absolute;
  top: 2px;
  left: 2px;
  width: 14px;
  height: 14px;
  background: white;
  border-radius: 50%;
  transition: transform var(--transition-fast);
}
.switch.active::after {
  transform: translateX(14px);
}
.switch-label {
  font-size: var(--font-size-xs);
  font-family: var(--font-family-mono);
  color: var(--color-text-secondary);
}
.validation-list {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}
.validation-item {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  padding: var(--space-2) var(--space-3);
  border-radius: var(--radius-sm);
  font-size: var(--font-size-sm);
}
.validation-item.valid {
  background: rgba(22, 163, 74, 0.08);
  color: var(--color-success);
}
.validation-item.warning {
  background: rgba(217, 119, 6, 0.08);
  color: var(--color-warning);
}
.workflow-graph {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  padding: var(--space-4);
  background: var(--color-bg-surface);
  border: 1px solid var(--color-border-default);
  border-radius: var(--radius-base);
  flex-wrap: wrap;
  justify-content: center;
}
.wf-node {
  padding: var(--space-3) var(--space-4);
  border-radius: var(--radius-base);
  text-align: center;
  min-width: 120px;
  border: 2px solid;
}
.wf-node__label {
  font-size: var(--font-size-md);
  font-weight: var(--font-weight-semibold);
  margin-bottom: var(--space-1);
}
.wf-node__desc {
  font-size: var(--font-size-xs);
  color: var(--color-text-secondary);
}
.wf-node--pending {
  border-color: var(--color-pending);
  color: var(--color-pending);
}
.wf-node--running {
  border-color: var(--color-primary-500);
  color: var(--color-primary-500);
  background: var(--color-primary-50);
}
.wf-node--completed {
  border-color: var(--color-success);
  color: var(--color-success);
}
.wf-node--paused {
  border-color: var(--color-warning);
  color: var(--color-warning);
}
.wf-arrow {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-1);
}
.wf-arrow__label {
  font-size: var(--font-size-xs);
  color: var(--color-text-secondary);
}
.wf-arrow__svg {
  width: 60px;
  height: 20px;
}
.wf-arrow--down .wf-arrow__svg {
  transform: rotate(90deg);
}
.wf-arrow--back {
  order: -1;
  align-self: center;
}
.audit-timeline {
  display: flex;
  flex-direction: column;
  gap: 0;
}
.audit-item {
  display: flex;
  gap: var(--space-3);
  padding: var(--space-3) 0;
  position: relative;
}
.audit-item:not(:last-child)::before {
  content: '';
  position: absolute;
  left: 11px;
  top: 40px;
  bottom: -8px;
  width: 1px;
  background: var(--color-divider);
}
.audit-item__dot {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  position: relative;
  z-index: 1;
}
.audit-item__dot--edit {
  background: rgba(30, 39, 97, 0.1);
  color: var(--color-primary-500);
}
.audit-item__dot--add {
  background: rgba(22, 163, 74, 0.1);
  color: var(--color-success);
}
.audit-item__dot--gen {
  background: rgba(102, 127, 197, 0.1);
  color: var(--color-primary-400);
}
.audit-item__dot--create {
  background: rgba(217, 119, 6, 0.1);
  color: var(--color-warning);
}
.audit-item__content {
  flex: 1;
}
.audit-item__header {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  margin-bottom: var(--space-1);
}
.audit-item__user {
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  color: var(--color-text-primary);
}
.audit-item__time {
  font-size: var(--font-size-xs);
  color: var(--color-text-secondary);
}
.audit-item__action {
  font-size: var(--font-size-sm);
  color: var(--color-text-secondary);
  margin-bottom: var(--space-1);
}
.audit-item__detail {
  font-size: var(--font-size-xs);
  color: var(--color-text-tertiary);
  font-family: var(--font-family-mono);
}
.diff-view {
  background: var(--color-bg-surface);
  border: 1px solid var(--color-border-default);
  border-radius: var(--radius-base);
  overflow: hidden;
}
.diff-header {
  display: grid;
  grid-template-columns: 1fr 1fr;
  padding: var(--space-2) var(--space-3);
  background: var(--color-bg-subtle);
  border-bottom: 1px solid var(--color-border-default);
  font-size: var(--font-size-xs);
  font-weight: var(--font-weight-medium);
  color: var(--color-text-secondary);
}
.diff-body {
  font-family: var(--font-family-mono);
  font-size: var(--font-size-xs);
  line-height: 1.6;
}
.diff-row {
  display: grid;
  grid-template-columns: 32px 1fr;
  border-bottom: 1px solid var(--color-divider);
}
.diff-row:last-child {
  border-bottom: none;
}
.diff-line-num {
  padding: 0 var(--space-2);
  text-align: right;
  color: var(--color-text-tertiary);
  background: var(--color-bg-subtle);
}
.diff-content {
  padding: 0 var(--space-3);
  white-space: pre;
  overflow-x: auto;
  color: var(--color-text-secondary);
}
.diff-row--added {
  background: rgba(22, 163, 74, 0.04);
}
.diff-row--added .diff-line-num {
  color: var(--color-success);
}
.diff-row--removed {
  background: rgba(220, 38, 38, 0.04);
}
.diff-row--removed .diff-line-num {
  color: var(--color-danger);
}
.diff-row--modified {
  background: rgba(217, 119, 6, 0.04);
}
.diff-row--modified .diff-line-num {
  color: var(--color-warning);
}
.diff-add {
  color: var(--color-success);
  font-weight: bold;
}
.diff-modified {
  color: var(--color-danger);
  text-decoration: line-through;
}
.link-text {
  font-size: var(--font-size-sm);
  color: var(--color-primary-500);
  cursor: pointer;
  background: none;
  border: none;
  padding: 0;
}
.link-text:hover {
  text-decoration: underline;
}
@media (max-width: 1024px) {
  .stats-row {
    grid-template-columns: repeat(2, 1fr);
  }
  .color-grid {
    grid-template-columns: repeat(3, 1fr);
  }
  .designer-layout {
    grid-template-columns: 1fr;
  }
  .market-grid {
    grid-template-columns: 1fr;
  }
}
@media (max-width: 768px) {
  .stats-row {
    grid-template-columns: 1fr;
  }
  .color-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>
