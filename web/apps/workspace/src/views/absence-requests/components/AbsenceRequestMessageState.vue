<script setup lang="ts">
import { computed } from 'vue';

const props = withDefaults(
  defineProps<{
    description: string;
    title: string;
    tone?: 'default' | 'error';
  }>(),
  { tone: 'default' },
);

const borderClasses = computed(() =>
  props.tone === 'error'
    ? 'border-destructive/30 bg-destructive/5'
    : 'border-dashed border-border bg-muted/30',
);
</script>

<template>
  <div class="rounded-xl border p-6" :class="[borderClasses]">
    <div class="space-y-1.5">
      <p class="text-sm font-medium text-foreground">
        {{ title }}
      </p>
      <p class="text-sm text-muted-foreground">
        {{ description }}
      </p>
    </div>
  </div>
</template>
