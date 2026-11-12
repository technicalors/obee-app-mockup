<script setup lang="ts">
defineProps<{ label: string }>();
</script>

<template>
  <div>
    <label
      class="mb-1 block text-[11px] font-semibold uppercase tracking-wider text-muted-foreground"
    >
      {{ label }}
    </label>
    <slot></slot>
  </div>
</template>
