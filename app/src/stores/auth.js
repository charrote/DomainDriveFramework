import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

const DOMAIN_PERMISSIONS = {
  'base.user':              ['admin'],
  'base.org_structure':     ['admin', 'supervisor'],
  'base.operator':          ['admin', 'supervisor'],
  'base.skill':             ['admin', 'supervisor'],
  'base.shift':             ['admin', 'supervisor'],
  'base.device':            ['admin', 'supervisor', 'operator'],
  'base.workstation':       ['admin', 'supervisor', 'operator'],
  'base.material':          ['admin', 'supervisor', 'quality_inspector'],
  'base.material_attr':     ['admin', 'quality_inspector'],
  'base.bom':               ['admin', 'supervisor'],
  'base.process_route':     ['admin', 'supervisor'],
  'base.process_step':      ['admin', 'supervisor'],
  'base.process_param':     ['admin', 'supervisor'],
  'base.work_order':        ['admin', 'supervisor', 'operator'],
  'base.production_record': ['admin', 'supervisor', 'operator'],
  'base.quality':           ['admin', 'quality_inspector'],
  'base.defect':            ['admin', 'quality_inspector'],
  'base.inspection':        ['admin', 'quality_inspector'],
  'base.barcode':           ['admin', 'supervisor', 'operator'],
  'base.coding_rule':       ['admin', 'supervisor'],
  'base.container':         ['admin', 'supervisor', 'operator'],
}

export const useAuthStore = defineStore('auth', () => {
  const user = ref(JSON.parse(localStorage.getItem('ddf_user') || 'null'))
  const token = ref(localStorage.getItem('ddf_token') || '')
  const loading = ref(false)

  const isLoggedIn = computed(() => !!token.value)
  const role = computed(() => user.value?.role || '')
  const username = computed(() => user.value?.username || '')

  const permissions = computed(() => {
    if (!role.value) return []
    return Object.entries(DOMAIN_PERMISSIONS)
      .filter(([, roles]) => roles.includes(role.value))
      .map(([domain]) => domain)
  })

  const canAccess = computed(() => (domain) => {
    if (role.value === 'admin') return true
    return permissions.value.includes(domain)
  })

  async function login(loginData) {
    loading.value = true
    try {
      const mockUsers = {
        admin:  { username: '管理员', role: 'admin',  token: 'mock-token-admin' },
        supervisor: { username: '班组长',  role: 'supervisor', token: 'mock-token-supervisor' },
        operator:   { username: '操作员',  role: 'operator',   token: 'mock-token-operator' },
        inspector:  { username: '质检员',  role: 'quality_inspector', token: 'mock-token-inspector' },
      }
      const mockUser = mockUsers[loginData.username]
      if (!mockUser || (loginData.password && loginData.password !== '123456')) {
        throw new Error('用户名或密码错误')
      }
      user.value = { username: mockUser.username, role: mockUser.role }
      token.value = mockUser.token
      localStorage.setItem('ddf_user', JSON.stringify(user.value))
      localStorage.setItem('ddf_token', token.value)
      return true
    } catch (err) {
      console.error('Login failed:', err)
      throw err
    } finally {
      loading.value = false
    }
  }

  function logout() {
    user.value = null
    token.value = ''
    localStorage.removeItem('ddf_user')
    localStorage.removeItem('ddf_token')
  }

  return { user, token, loading, isLoggedIn, role, username, permissions, canAccess, login, logout }
})
