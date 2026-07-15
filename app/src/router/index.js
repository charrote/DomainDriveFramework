import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import entities from '@/entities.json'

function kebab(str) {
  return str
    .replace(/([A-Z]+)([A-Z][a-z])/g, '$1-$2')
    .replace(/([a-z0-9])([A-Z])/g, '$1-$2')
    .replace(/([a-z])([0-9])/g, '$1-$2')
    .toLowerCase()
}

function loadView(name) {
  return () => import(`@/views/entities/${name}.vue`)
}

const dynamicRoutes = entities.flatMap((entity) => {
  const kb = kebab(entity.name)
  const base = `/${kb}`
  return [
    { path: base,                     name: `${kb}-list`,   meta: { title: entity.label, domain: entity.domain }, component: loadView(`${kb}-list`) },
    { path: `${base}/create`,         name: `${kb}-create`, meta: { title: `新建${entity.label}`, domain: entity.domain }, component: loadView(`${kb}-form`) },
    { path: `${base}/:id/edit`,       name: `${kb}-edit`,   meta: { title: `编辑${entity.label}`, domain: entity.domain }, component: loadView(`${kb}-form`) },
  ]
})

const routes = [
  { path: '/login',     name: 'login',    meta: { title: '登录', guest: true }, component: () => import('@/views/Login.vue') },
  { path: '/',          redirect: '/dashboard' },
  { path: '/dashboard', name: 'dashboard', meta: { title: '工作台' },           component: () => import('@/views/Dashboard.vue') },
  ...dynamicRoutes,
  { path: '/:pathMatch(.*)*', name: 'not-found', component: () => import('@/views/NotFound.vue') },
]

const router = createRouter({ history: createWebHistory(), routes })

router.beforeEach((to, from, next) => {
  const auth = useAuthStore()
  document.title = to.meta.title ? `${to.meta.title} — DDF MES` : 'DDF MES'
  if (to.meta.guest) return next()
  if (!auth.isLoggedIn) return next({ name: 'login', query: { redirect: to.fullPath } })
  if (to.meta.domain && !auth.canAccess(to.meta.domain)) {
    console.warn(`Access denied to ${to.meta.domain}`)
    return next({ name: 'dashboard' })
  }
  next()
})

export default router
