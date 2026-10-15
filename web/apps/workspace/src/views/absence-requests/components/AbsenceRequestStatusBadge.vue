<script setup lang="ts">
import type { AbsenceStatus } from '#/api/absence-requests';

import { computed } from 'vue';

import { $t } from '#/locales';

const props = defineProps<{
  status: AbsenceStatus;
}>();

const badgeConfig = computed(() => {
  switch (props.status) {
    case 'approved': {
      return {
        class:
          'border-emerald-200 bg-emerald-50 text-emerald-700 dark:border-emerald-500/30 dark:bg-emerald-950/40 dark:text-emerald-400',
        label: $t('absenceRequests.statuses.approved'),
        status: 'success' as const,
      };
    }
    case 'rejected': {
      return {
        class:
          'border-red-200 bg-red-50 text-red-700 dark:border-red-500/30 dark:bg-red-950/40 dark:text-red-400',
        label: $t('absenceRequests.statuses.rejected'),
        status: 'error' as const,
      };
    }
    case 'returned': {
      return {
        class:
          'border-amber-200 bg-amber-50 text-amber-700 dark:border-amber-500/30 dark:bg-amber-950/40 dark:text-amber-400',
        label: $t('absenceRequests.statuses.returned'),
        status: 'warning' as const,
      };
    }
    default: {
      return {
        class:
          'border-blue-200 bg-blue-50 text-blue-700 dark:border-blue-500/30 dark:bg-blue-950/40 dark:text-blue-400',
        label: $t('absenceRequests.statuses.pending'),
        status: 'processing' as const,
      };
    }
  }
});
</script>

<template>
  <span
    class="inline-flex shrink-0 items-center justify-center whitespace-nowrap rounded-md border px-2.5 py-0.5 text-xs font-medium text-center"
    :class="[badgeConfig.class]"
  >
    {{ badgeConfig.label }}
  </span>
</template>
