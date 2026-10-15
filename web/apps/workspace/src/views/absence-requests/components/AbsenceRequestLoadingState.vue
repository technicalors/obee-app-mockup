<script setup lang="ts">
import { Skeleton } from 'ant-design-vue';

defineProps<{
  description: string;
  title: string;
}>();
</script>

<template>
  <div class="space-y-3" role="status" aria-busy="true">
    <div class="space-y-1">
      <p class="text-sm font-medium text-foreground">{{ title }}</p>
      <p class="text-sm text-muted-foreground">{{ description }}</p>
    </div>

    <div class="space-y-3">
      <div
        v-for="i in 4"
        :key="i"
        class="rounded-xl border border-border bg-card p-4 space-y-3"
      >
        <Skeleton active :paragraph="{ rows: 2 }" />
      </div>
    </div>
  </div>
</template>
