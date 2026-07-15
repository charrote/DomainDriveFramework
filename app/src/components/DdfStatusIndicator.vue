<template>
  <span class="status-dot" :style="{ background: color }"></span>
</template>

<script setup>
defineProps({
  color: {
    type: String,
    required: true,
  },
})
</script>

<style scoped>
.status-dot {
  display: inline-block;
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
}
</style>