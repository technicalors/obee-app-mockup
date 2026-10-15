<script setup lang="ts">
import type { LeaveCoveragePreview } from '#/api/absence-requests';

import { $t } from '#/locales';

defineProps<{
  businessTrip?: boolean;
  error?: boolean;
  loading?: boolean;
  preview: LeaveCoveragePreview | null;
}>();

defineEmits<{ retry: [] }>();
</script>

<template>
  <div v-if="error" role="alert" class="p-2 text-xs text-destructive">
    {{ $t('absenceRequests.coverage.error') }}
    <button type="button" class="ml-2 underline" @click="$emit('retry')">
      {{ $t('absenceRequests.coverage.retry') }}
    </button>
  </div>

  <div
    v-else-if="preview && preview.items.length > 0"
    class="flex flex-wrap items-center justify-between gap-2 px-3 text-xs"
  >
    <div class="flex items-center gap-1.5">
      <span class="text-muted-foreground">{{
        $t('absenceRequests.coverage.total')
      }}</span>
      <span class="text-sm text-primary tabular-nums">
        {{
          $t('absenceRequests.detail.durationDays', {
            days: preview.total_days,
          })
        }}
      </span>
    </div>
    <div class="text-[11px] text-muted-foreground">
      <span v-if="!businessTrip">
        {{
          $t('absenceRequests.coverage.assignedDays', {
            days: preview.working_days,
          })
        }}
        <span v-if="preview.off_days > 0">
          {{
            $t('absenceRequests.coverage.unassignedDays', {
              days: preview.off_days,
            })
          }}
        </span>
      </span>
    </div>
  </div>
</template>
