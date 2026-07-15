<template>
  <button
    class="ddf-btn"
    :class="[
      `ddf-btn--${variant}`,
      sizeClass,
      { 'ddf-btn--disabled': disabled },
    ]"
    :disabled="disabled"
    :aria-disabled="disabled"
    v-bind="$attrs"
    @click="$emit('click', $event)"
  >
    <slot />
  </button>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  variant: {
    type: String,
    default: 'primary',
    validator: v => ['primary', 'outline', 'text', 'ghost'].includes(v),
  },
  size: {
    type: String,
    default: 'md',
    validator: v => ['sm', 'md'].includes(v),
  },
  disabled: { type: Boolean, default: false },
})

defineEmits(['click'])

const sizeClass = computed(() => props.size === 'sm' ? 'ddf-btn--sm' : '')
</script>

<style scoped>
.ddf-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  padding: 8px 16px;
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  border-radius: var(--radius-base);
  border: 1px solid transparent;
  cursor: pointer;
  transition: all var(--transition-fast);
  white-space: nowrap;
  line-height: 1.4;
  font-family: inherit;
}
.ddf-btn:focus-visible {
  outline: 2px solid var(--color-primary-500);
  outline-offset: 2px;
}
.ddf-btn--sm {
  padding: 5px 12px;
  font-size: var(--font-size-xs);
}
/* primary */
.ddf-btn--primary {
  background: var(--color-primary-500);
  color: white;
  border-color: var(--color-primary-500);
}
.ddf-btn--primary:hover:not(:disabled) {
  background: var(--color-primary-600);
  border-color: var(--color-primary-600);
}
.ddf-btn--primary:active:not(:disabled) {
  background: var(--color-primary-700);
}
/* outline */
.ddf-btn--outline {
  background: transparent;
  border-color: var(--color-border-default);
  color: var(--color-text-secondary);
}
.ddf-btn--outline:hover:not(:disabled) {
  border-color: var(--color-primary-500);
  color: var(--color-primary-500);
}
/* text */
.ddf-btn--text {
  background: transparent;
  border: none;
  color: var(--color-primary-500);
  padding-left: 8px;
  padding-right: 8px;
}
.ddf-btn--text:hover:not(:disabled) {
  background: var(--color-primary-50);
}
/* ghost / disabled */
.ddf-btn--ghost,
.ddf-btn--disabled {
  background: var(--color-bg-subtle);
  border-color: var(--color-border-default);
  color: var(--color-text-disabled);
  cursor: not-allowed;
}
[data-theme="dark"] .ddf-btn--text:hover:not(:disabled) {
  background: rgba(102, 127, 197, 0.12);
}
</style>
