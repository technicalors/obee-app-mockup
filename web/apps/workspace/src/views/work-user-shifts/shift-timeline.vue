<script setup lang="ts">
import type { WorkShiftPeriod } from '#/api/work-shifts';

import { computed } from 'vue';

type TimelinePeriod = Pick<
  WorkShiftPeriod,
  'end_day_offset' | 'end_time' | 'start_day_offset' | 'start_time'
>;

const props = defineProps<{ periods: TimelinePeriod[] }>();

function minutes(offset: number, time: string): number {
  return (
    offset * 1440 + Number(time.slice(0, 2)) * 60 + Number(time.slice(3, 5))
  );
}

/** Part after midnight wraps to the left of the bar and is dimmed. */
const segments = computed(() => {
  const result: { left: number; overflow: boolean; width: number }[] = [];
  const percent = (value: number) => (value / 1440) * 100;
  for (const period of props.periods) {
    const start = minutes(period.start_day_offset, period.start_time);
    const end = minutes(period.end_day_offset, period.end_time);
    if (end <= start) continue;
    if (start < 1440) {
      result.push({
        left: percent(start),
        overflow: false,
        width: percent(Math.min(end, 1440) - start),
      });
    }
    if (end > 1440) {
      const wrappedStart = Math.max(start, 1440) - 1440;
      result.push({
        left: percent(wrappedStart),
        overflow: true,
        width: percent(end - 1440 - wrappedStart),
      });
    }
  }
  return result;
});
</script>

<template>
  <div aria-hidden="true">
    <div class="relative h-2 rounded-full bg-muted">
      <span
        v-for="(segment, index) in segments"
        :key="index"
        class="absolute inset-y-0 rounded-full bg-primary"
        :class="{ 'opacity-40': segment.overflow }"
        :style="{ left: `${segment.left}%`, width: `${segment.width}%` }"
      ></span>
    </div>
    <div
      class="mt-1 flex justify-between text-[10px] tabular-nums text-muted-foreground"
    >
      <span>0h</span>
      <span>6h</span>
      <span>12h</span>
      <span>18h</span>
      <span>24h</span>
    </div>
  </div>
</template>
