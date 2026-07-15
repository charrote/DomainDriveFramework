<template>
  <span
    class="ddf-tag"
    :class="sizeClass"
    :style="tagStyle"
  >
    <slot />
  </span>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  color: {
    type: String,
    required: true,
  },
  size: {
    type: String,
    default: 'md',
  },
})

const sizeClass = computed(() => `ddf-tag--${props.size}`)

const tagStyle = computed(() => {
  const colorMap = {
    success: { bg: 'rgba(22,163,74,0.1)', text: 'var(--color-success)', border: 'rgba(22,163,74,0.2)' },
    warning: { bg: 'rgba(217,119,6,0.1)', text: 'var(--color-warning)', border: 'rgba(217,119,6,0.2)' },
    danger:  { bg: 'rgba(220,38,38,0.1)', text: 'var(--color-danger)', border: 'rgba(220,38,38,0.2)' },
    info:    { bg: 'rgba(81,88,109,0.1)', text: 'var(--color-info)', border: 'rgba(81,88,109,0.2)' },
    pending: { bg: 'rgba(156,163,175,0.1)', text: 'var(--color-pending)', border: 'rgba(156,163,175,0.2)' },
    running: { bg: 'rgba(30,39,97,0.1)', text: 'var(--color-primary-500)', border: 'rgba(30,39,97,0.2)' },
    paused:  { bg: 'rgba(217,119,6,0.1)', text: 'var(--color-warning)', border: 'rgba(217,119,6,0.2)' },
    completed: { bg: 'rgba(22,163,74,0.1)', text: 'var(--color-success)', border: 'rgba(22,163,74,0.2)' },
    cancelled: { bg: 'rgba(220,38,38,0.1)', text: 'var(--color-danger)', border: 'rgba(220,38,38,0.2)' },
    steel:   { bg: 'var(--color-bg-subtle)', text: 'var(--color-text-secondary)', border: 'var(--color-border-default)' },
  }
  return colorMap[props.color] || { bg: 'var(--color-bg-subtle)', text: 'var(--color-text-secondary)', border: 'var(--color-border-default)' }
})
</script>

<style scoped>
.ddf-tag {
  display: inline-block;
  padding: 2px 8px;
  font-size: var(--font-size-xs);
  font-weight: var(--font-weight-medium);
  border-radius: var(--radius-full);
  border: 1px solid;
  line-height: 1.4;
}

.ddf-tag--sm {
  padding: 1px 6px;
  font-size: var(--font-size-xs);
}

.ddf-tag--xs {
  padding: 0 4px;
  font-size: 10px;
}
</style>