<template>
  <span class="link-text" @click="$emit('click')">
    <slot />
  </span>
</template>

<script setup>
defineEmits(['click'])
</script>

<style scoped>
.link-text {
  font-size: var(--font-size-sm);
  color: var(--color-primary-500);
  cursor: pointer;
  background: none;
  border: none;
  padding: 0;
}

.link-text:hover {
  text-decoration: underline;
}
</style>