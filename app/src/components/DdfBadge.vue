<template>
  <span class="ddf-badge" :class="variantClass">
    <slot />
  </span>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  variant: {
    type: String,
    default: 'normal',
    validator: v => ['featured', 'normal'].includes(v),
  },
})

const variantClass = computed(() => `ddf-badge--${props.variant}`)
</script>

<style scoped>
.ddf-badge {
  display: inline-block;
  padding: 2px 8px;
  font-size: var(--font-size-xs);
  font-weight: var(--font-weight-medium);
  border-radius: var(--radius-full);
  line-height: 1.4;
}
.ddf-badge--featured {
  background: #fef3c7;
  color: #92400e;
}
.ddf-badge--normal {
  background: var(--color-bg-subtle);
  color: var(--color-text-secondary);
}
[data-theme="dark"] .ddf-badge--featured {
  background: rgba(254, 243, 199, 0.15);
  color: #fbbf24;
}
</style>
