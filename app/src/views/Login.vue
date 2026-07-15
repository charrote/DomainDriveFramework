<template>
  <div class="login-page">
    <div class="login-card">
      <div class="login-header">
        <Icon name="settings" :size="32" />
        <h1 class="login-title">DDF MES</h1>
        <p class="login-subtitle">Domain-Driven 精密制造执行系统</p>
      </div>
      <form @submit.prevent="handleLogin" class="login-form">
        <div class="form-group">
          <label class="form-label">角色</label>
          <select v-model="form.username" class="form-input" required>
            <option value="" disabled>选择登录角色</option>
            <option value="admin">管理员 (admin)</option>
            <option value="supervisor">班组长 (supervisor)</option>
            <option value="operator">操作员 (operator)</option>
            <option value="inspector">质检员 (quality_inspector)</option>
          </select>
        </div>
        <div class="form-group">
          <label class="form-label">密码</label>
          <input v-model="form.password" type="password" class="form-input" placeholder="开发环境: 123456" />
        </div>
        <div v-if="error" class="form-error">{{ error }}</div>
        <DdfButton variant="primary" type="submit" :loading="loading" class="login-btn">登录</DdfButton>
        <p class="login-hint">开发环境：选择角色即可登录，密码 123456</p>
      </form>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const route = useRoute()
const auth = useAuthStore()
const form = reactive({ username: 'admin', password: '123456' })
const error = ref('')
const loading = ref(false)

async function handleLogin() {
  error.value = ''
  loading.value = true
  try {
    await auth.login(form)
    router.push(route.query.redirect || '/dashboard')
  } catch (err) {
    error.value = err.message || '登录失败'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-page { display: flex; align-items: center; justify-content: center; min-height: 100vh; background: var(--color-bg-subtle); }
.login-card { width: 400px; background: var(--color-bg-primary); border-radius: var(--radius-xl); border: 1px solid var(--color-border-default); padding: var(--space-8); box-shadow: var(--shadow-lg); }
.login-header { text-align: center; margin-bottom: var(--space-6); }
.login-title { font-size: var(--font-size-2xl); font-weight: var(--font-weight-semibold); margin-top: var(--space-2); }
.login-subtitle { font-size: var(--font-size-sm); color: var(--color-text-secondary); margin-top: var(--space-1); }
.form-group { margin-bottom: var(--space-4); }
.form-label { display: block; font-size: var(--font-size-sm); font-weight: var(--font-weight-medium); margin-bottom: var(--space-1); color: var(--color-text-primary); }
.form-input { width: 100%; padding: 8px 12px; border: 1px solid var(--color-border-default); border-radius: var(--radius-base); font-size: var(--font-size-sm); background: var(--color-bg-primary); color: var(--color-text-primary); }
.form-input:focus { outline: none; border-color: var(--color-primary-500); box-shadow: 0 0 0 2px var(--color-primary-100); }
.form-error { color: var(--color-red-500); font-size: var(--font-size-sm); margin-bottom: var(--space-3); }
.login-btn { width: 100%; margin-top: var(--space-2); }
.login-hint { text-align: center; font-size: var(--font-size-xs); color: var(--color-text-disabled); margin-top: var(--space-4); }
</style>
