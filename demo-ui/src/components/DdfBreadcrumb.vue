<template>
  <nav class="ddf-breadcrumb" aria-label="Breadcrumb">
    <component :is="firstLink ? 'a' : 'span'" class="ddf-breadcrumb__home" :href="firstLink || undefined">
      <Icon name="home" :size="14" />
    </component>
    <template v-for="(item, i) in items" :key="i">
      <span class="ddf-breadcrumb__sep" aria-hidden="true">/</span>
      <component
        :is="i < items.length - 1 ? 'a' : 'span'"
        class="ddf-breadcrumb__item"
        :class="{ 'ddf-breadcrumb__item--current': i === items.length - 1 }"
        :href="i < items.length - 1 ? item.href : undefined"
        :aria-current="i === items.length - 1 ? 'page' : undefined"
      >
        {{ item.label }}
      </component>
    </template>
  </nav>
</template>

<script setup>
import Icon from './Icon.vue'

defineProps({
  items: {
    type: Array,
    default: () => [],
  },
  firstLink: {
    type: String,
    default: undefined,
  },
})
</script>

<style scoped>
.ddf-breadcrumb {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  padding: var(--space-2) 0 var(--space-3);
  font-size: var(--font-size-sm);
  color: var(--color-text-secondary);
}
.ddf-breadcrumb__home {
  display: inline-flex;
  color: inherit;
  text-decoration: none;
}
.ddf-breadcrumb__item {
  color: inherit;
  text-decoration: none;
}
.ddf-breadcrumb a:hover {
  color: var(--color-primary-500);
}
.ddf-breadcrumb__item--current {
  color: var(--color-text-primary);
  font-weight: var(--font-weight-medium);
}
.ddf-breadcrumb__sep {
  color: var(--color-steel-300);
  user-select: none;
}
</style>
