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
        <span class="topbar__subtitle">精密制造执行系统</span>
      </div>
      <nav class="topbar__nav">
        <router-link to="/dashboard" class="topbar__nav-item">工作台</router-link>
      </nav>
      <div class="topbar__actions">
        <button class="topbar__action-btn" @click="toggleTheme" :title="'主题: ' + theme">
          <Icon :name="themeIcon" :size="16" />
        </button>
        <template v-if="auth.isLoggedIn">
          <div class="topbar__avatar"><div class="avatar-circle">{{ auth.username.charAt(0) }}</div></div>
          <button class="topbar__action-btn topbar__action-btn--text" @click="auth.logout">退出</button>
        </template>
        <router-link v-else to="/login" class="topbar__action-btn topbar__action-btn--text">登录</router-link>
      </div>
    </header>

    <div class="main-container">
      <!-- Sidebar -->
      <aside class="sidebar">
        <nav class="sidebar__nav">
          <div class="sidebar__group">
            <div class="sidebar__group-title">领域模块</div>
            <router-link v-for="g in domainGroups" :key="g.name" :to="g.path" class="sidebar__item" v-show="auth.canAccess(g.domain)">
              <Icon :name="g.icon" :size="16" />
              <span>{{ g.label }}</span>
            </router-link>
          </div>
          <div class="sidebar__group">
            <div class="sidebar__group-title">系统</div>
            <router-link to="/dashboard" class="sidebar__item">
              <Icon name="barChart" :size="16" />
              <span>控制台</span>
            </router-link>
          </div>
        </nav>
        <div class="sidebar__profile">
          <span class="sidebar__profile-dot" :class="{ paused: !auth.isLoggedIn }"></span>
          <span class="sidebar__profile-text">{{ auth.isLoggedIn ? auth.role : '未登录' }}</span>
        </div>
      </aside>

      <!-- Content -->
      <main class="content">
        <router-view />
      </main>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useAuthStore } from '@/stores/auth'
import entities from '@/entities.json'

const auth = useAuthStore()
const theme = ref(localStorage.getItem('ddf_theme') || 'light')

function toggleTheme() {
  const order = ['light', 'dark', 'hc']
  const idx = order.indexOf(theme.value)
  theme.value = order[(idx + 1) % order.length]
  document.documentElement.setAttribute('data-theme', theme.value)
  localStorage.setItem('ddf_theme', theme.value)
}

const themeIcon = computed(() => ({ light: 'moon', dark: 'sun', hc: 'sun' }[theme.value]))

function toKebab(str) {
  return str.replace(/([A-Z]+)([A-Z][a-z])/g, '$1-$2').replace(/([a-z0-9])([A-Z])/g, '$1-$2').replace(/([a-z])([0-9])/g, '$1-$2').toLowerCase()
}

const domainGroups = [
  { name: 'org', label: '组织架构', icon: 'users', domain: 'base.org_structure', path: '/' },
  { name: 'material', label: '物料管理', icon: 'package', domain: 'base.material', path: '/' },
  { name: 'device', label: '设备管理', icon: 'cpu', domain: 'base.device', path: '/' },
  { name: 'process', label: '工艺管理', icon: 'file-text', domain: 'base.process_route', path: '/' },
  { name: 'production', label: '生产执行', icon: 'play', domain: 'base.work_order', path: '/' },
  { name: 'quality', label: '品质管控', icon: 'check-circle', domain: 'base.quality', path: '/' },
  { name: 'trace', label: '追溯辅助', icon: 'search', domain: 'base.barcode', path: '/' },
]

// 为每个 domain group 找到第一个可访问实体的路径
for (const g of domainGroups) {
  const first = entities.find(e => e.domain.startsWith(g.domain))
  if (first) g.path = '/' + toKebab(first.name)
}
</script>

<style scoped>
.ddf-app { font-family: var(--font-family-base); font-size: var(--font-size-base); color: var(--color-text-primary); background: var(--color-bg-page); min-height: 100vh; display: flex; flex-direction: column; }

/* Top Bar */
.topbar { height: 52px; background: var(--color-bg-surface); border-bottom: 1px solid var(--color-divider); display: flex; align-items: center; padding: 0 var(--space-4); position: sticky; top: 0; z-index: 200; }
.topbar__brand { display: flex; align-items: center; gap: 10px; margin-right: 32px; flex-shrink: 0; }
.topbar__logo { width: 28px; height: 28px; }
.topbar__title { font-size: var(--font-size-md); font-weight: var(--font-weight-semibold); color: var(--color-primary-500); }
.topbar__subtitle { font-size: var(--font-size-xs); color: var(--color-text-secondary); }
.topbar__nav { display: flex; gap: 2px; flex: 1; }
.topbar__nav-item { padding: 6px 14px; font-size: var(--font-size-sm); color: var(--color-text-secondary); background: none; border: none; border-radius: var(--radius-sm); cursor: pointer; transition: all var(--transition-fast); text-decoration: none; }
.topbar__nav-item:hover { background: var(--color-bg-subtle); color: var(--color-text-primary); }
.topbar__nav-item.router-link-exact-active { color: var(--color-primary-500); background: var(--color-primary-50); font-weight: var(--font-weight-medium); }
.topbar__actions { display: flex; align-items: center; gap: 12px; flex-shrink: 0; }
.topbar__action-btn { width: 36px; height: 36px; display: flex; align-items: center; justify-content: center; background: none; border: 1px solid var(--color-border-default); border-radius: var(--radius-sm); cursor: pointer; }
.topbar__action-btn:hover { border-color: var(--color-steel-300); background: var(--color-bg-subtle); }
.topbar__action-btn--text { width: auto; padding: 0 10px; font-size: var(--font-size-sm); text-decoration: none; color: var(--color-text-secondary); }
.avatar-circle { width: 32px; height: 32px; border-radius: 50%; background: var(--color-primary-500); color: white; display: flex; align-items: center; justify-content: center; font-size: var(--font-size-sm); font-weight: var(--font-weight-medium); }

/* Main */
.main-container { display: flex; flex: 1; overflow: hidden; }

/* Sidebar */
.sidebar { width: 220px; background: var(--color-bg-surface); border-right: 1px solid var(--color-divider); display: flex; flex-direction: column; overflow-y: auto; flex-shrink: 0; }
.sidebar__nav { padding: var(--space-3) 0; flex: 1; }
.sidebar__group { margin-bottom: var(--space-4); }
.sidebar__group-title { padding: var(--space-2) var(--space-4); font-size: var(--font-size-xs); font-weight: var(--font-weight-medium); color: var(--color-text-secondary); text-transform: uppercase; letter-spacing: 0.05em; }
.sidebar__item { display: flex; align-items: center; gap: var(--space-2); padding: 8px var(--space-4); font-size: var(--font-size-sm); color: var(--color-text-secondary); cursor: pointer; text-decoration: none; transition: all var(--transition-fast); position: relative; }
.sidebar__item:hover { background: var(--color-bg-subtle); color: var(--color-text-primary); }
.sidebar__item.router-link-active { background: var(--color-primary-50); color: var(--color-primary-500); font-weight: var(--font-weight-medium); }
.sidebar__item.router-link-active::before { content: ''; position: absolute; left: 0; top: 4px; bottom: 4px; width: 3px; background: var(--color-primary-500); border-radius: 0 2px 2px 0; }
.sidebar__profile { padding: var(--space-3) var(--space-4); border-top: 1px solid var(--color-divider); display: flex; align-items: center; gap: var(--space-2); font-size: var(--font-size-xs); color: var(--color-text-secondary); background: var(--color-bg-subtle); }
.sidebar__profile-dot { width: 8px; height: 8px; border-radius: 50%; background: var(--color-success); }
.sidebar__profile-dot.paused { background: var(--color-warning); }

/* Content */
.content { flex: 1; overflow-y: auto; padding: var(--space-4); max-width: 1200px; }
</style>
