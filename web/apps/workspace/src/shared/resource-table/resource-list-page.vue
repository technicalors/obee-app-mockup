<script setup lang="ts">
import { Page } from '@vben/common-ui';
</script>

<template>
  <Page auto-content-height content-class="overflow-hidden">
    <div class="flex h-full min-h-0 flex-col">
      <slot></slot>
    </div>
  </Page>
</template>
