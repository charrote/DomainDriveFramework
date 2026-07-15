<template>
  <div class="dashboard">
    <div class="page-header">
      <h1 class="page-title">工作台</h1>
      <p class="page-desc">欢迎回来，{{ authStore.username }}</p>
    </div>
    <div class="stats-grid">
      <div v-for="stat in stats" :key="stat.label" class="stat-card">
        <div class="stat-value">{{ stat.value }}</div>
        <div class="stat-label">{{ stat.label }}</div>
      </div>
    </div>
    <div class="domain-section">
      <h2 class="section-title">领域模块</h2>
      <div class="domain-grid">
        <router-link v-for="group in domainGroups" :key="group.name" :to="group.path" class="domain-card" v-show="authStore.canAccess(group.domain)">
          <div class="domain-card__header">
            <Icon :name="group.icon" :size="24" />
            <h3>{{ group.label }}</h3>
          </div>
          <p class="domain-card__desc">{{ group.description }}</p>
          <span class="domain-card__count">{{ group.count }} 个实体</span>
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useAuthStore } from '@/stores/auth'
import entities from '@/entities.json'

const authStore = useAuthStore()

function toKebab(str) {
  return str.replace(/([A-Z]+)([A-Z][a-z])/g, '$1-$2').replace(/([a-z0-9])([A-Z])/g, '$1-$2').replace(/([a-z])([0-9])/g, '$1-$2').toLowerCase()
}

const stats = computed(() => [
  { label: '实体模型', value: entities.length },
  { label: '当前角色', value: authStore.role },
  { label: '可访问模块', value: entities.filter(e => authStore.canAccess(e.domain)).length },
  { label: '系统状态', value: '运行中' },
])

const domainGroups = computed(() => {
  const groups = [
    { name: 'org', label: '组织架构', icon: 'users', domain: 'base.org_structure', description: '工厂、车间、产线管理', entities: [] },
    { name: 'user', label: '人员管理', icon: 'user', domain: 'base.user', description: '用户、操作员、技能、排班', entities: [] },
    { name: 'device', label: '设备管理', icon: 'cpu', domain: 'base.device', description: '设备台账、工作站', entities: [] },
    { name: 'material', label: '物料管理', icon: 'package', domain: 'base.material', description: '物料、分类、BOM、属性', entities: [] },
    { name: 'process', label: '工艺管理', icon: 'file-text', domain: 'base.process_route', description: '工艺路线、工序、参数', entities: [] },
    { name: 'production', label: '生产执行', icon: 'play', domain: 'base.work_order', description: '工单、生产记录', entities: [] },
    { name: 'quality', label: '品质管控', icon: 'check-circle', domain: 'base.quality', description: '质检、缺陷、检验标准', entities: [] },
    { name: 'trace', label: '追溯辅助', icon: 'search', domain: 'base.barcode', description: '条码、编码规则、容器', entities: [] },
  ]
  for (const g of groups) {
    g.count = entities.filter(e => e.domain.startsWith(g.domain)).length
    const first = entities.find(e => e.domain.startsWith(g.domain) && authStore.canAccess(e.domain))
    g.path = first ? '/' + toKebab(first.name) : '/dashboard'
  }
  return groups
})
</script>

<style scoped>
.page-header { margin-bottom: var(--space-6); }
.page-title { font-size: var(--font-size-2xl); font-weight: var(--font-weight-semibold); }
.page-desc { color: var(--color-text-secondary); margin-top: var(--space-1); }
.stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: var(--space-4); margin-bottom: var(--space-8); }
.stat-card { background: var(--color-bg-primary); border: 1px solid var(--color-border-default); border-radius: var(--radius-lg); padding: var(--space-5); }
.stat-value { font-size: var(--font-size-3xl); font-weight: var(--font-weight-bold); color: var(--color-primary-500); }
.stat-label { font-size: var(--font-size-sm); color: var(--color-text-secondary); margin-top: var(--space-1); }
.section-title { font-size: var(--font-size-lg); font-weight: var(--font-weight-semibold); margin-bottom: var(--space-4); }
.domain-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: var(--space-4); }
.domain-card { background: var(--color-bg-primary); border: 1px solid var(--color-border-default); border-radius: var(--radius-lg); padding: var(--space-5); text-decoration: none; color: inherit; transition: all var(--transition-fast); }
.domain-card:hover { border-color: var(--color-primary-500); box-shadow: var(--shadow-md); }
.domain-card__header { display: flex; align-items: center; gap: var(--space-2); margin-bottom: var(--space-2); }
.domain-card__header h3 { font-size: var(--font-size-base); font-weight: var(--font-weight-semibold); }
.domain-card__desc { font-size: var(--font-size-sm); color: var(--color-text-secondary); }
.domain-card__count { display: inline-block; font-size: var(--font-size-xs); color: var(--color-primary-500); margin-top: var(--space-2); }
</style>
