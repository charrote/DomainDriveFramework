<template>
  <div class="not-found">
    <Icon name="alert-circle" :size="48" />
    <h1>404</h1>
    <p>页面不存在</p>
    <DdfButton variant="primary" @click="$router.push('/dashboard')">返回工作台</DdfButton>
  </div>
</template>
<style scoped>
.not-found { display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 60vh; gap: var(--space-4); color: var(--color-text-secondary); }
.not-found h1 { font-size: var(--font-size-4xl); font-weight: var(--font-weight-bold); color: var(--color-text-primary); }
</style>
