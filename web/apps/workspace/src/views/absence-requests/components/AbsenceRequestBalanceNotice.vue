<script setup lang="ts">
import type { LeaveBalance } from '#/api/absence-requests';

import dayjs from 'dayjs';

import { $t } from '#/locales';

defineProps<{
  balance: LeaveBalance | null;
  isError: boolean;
  isLoading: boolean;
}>();
</script>

<template>
  <div
    v-if="isLoading"
    class="rounded-xl border border-border bg-muted/30 px-4 py-3 text-sm"
  >
    <p class="font-semibold text-foreground">
      {{ $t('absenceRequests.create.balance.loadingTitle') }}
    </p>
    <p class="mt-1 text-muted-foreground">
      {{ $t('absenceRequests.create.balance.loadingDescription') }}
    </p>
  </div>

  <div
    v-else-if="isError || !balance"
    class="rounded-xl border border-amber-200 bg-amber-50 px-4 py-3 text-sm"
  >
    <p class="font-semibold text-amber-950">
      {{ $t('absenceRequests.create.balance.unavailableTitle') }}
    </p>
    <p class="mt-1 text-amber-900">
      {{ $t('absenceRequests.create.balance.unavailableDescription') }}
    </p>
  </div>

  <div
    v-else
    class="rounded-xl border border-border bg-muted/30 px-4 py-3 text-sm text-foreground"
  >
    <p class="font-semibold">
      {{ $t('absenceRequests.create.balance.title') }}
    </p>
    <p class="mt-1 text-sm text-muted-foreground">
      {{ $t('absenceRequests.create.balance.referenceDescription') }}
    </p>
    <dl class="mt-3 grid gap-2 text-sm sm:grid-cols-2">
      <div>
        <dt class="text-muted-foreground">
          {{ $t('absenceRequests.create.balance.remaining') }}
        </dt>
        <dd class="font-medium text-foreground">
          {{
            $t('absenceRequests.create.balance.daysValue', {
              count: balance.remaining,
            })
          }}
        </dd>
      </div>
      <div>
        <dt class="text-muted-foreground">
          {{ $t('absenceRequests.create.balance.used') }}
        </dt>
        <dd class="font-medium text-foreground">
          {{
            $t('absenceRequests.create.balance.daysValue', {
              count: balance.used,
            })
          }}
        </dd>
      </div>
      <div>
        <dt class="text-muted-foreground">
          {{ $t('absenceRequests.create.balance.entitlement') }}
        </dt>
        <dd class="font-medium text-foreground">
          {{
            $t('absenceRequests.create.balance.daysValue', {
              count: balance.entitlement,
            })
          }}
        </dd>
      </div>
      <div>
        <dt class="text-muted-foreground">
          {{ $t('absenceRequests.create.balance.cycle') }}
        </dt>
        <dd class="font-medium text-foreground">
          {{
            balance.cycle_start && balance.cycle_end
              ? `${dayjs(balance.cycle_start).format('DD/MM/YYYY')} - ${dayjs(balance.cycle_end).format('DD/MM/YYYY')}`
              : $t('absenceRequests.create.balance.cycleUnavailable')
          }}
        </dd>
      </div>
    </dl>
  </div>
</template>
