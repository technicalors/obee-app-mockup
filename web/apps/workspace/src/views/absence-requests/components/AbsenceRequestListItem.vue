<script setup lang="ts">
import type { AbsenceRequest } from '#/api/absence-requests';

import { computed } from 'vue';

import { IconifyIcon } from '@vben/icons';
import { preferences } from '@vben/preferences';

import { Button, Tooltip } from 'ant-design-vue';
import dayjs from 'dayjs';
import timezone from 'dayjs/plugin/timezone';
import utc from 'dayjs/plugin/utc';

import { $t } from '#/locales';

import {
  canDeleteRequest,
  canEditRequest,
  canReviewRequest,
} from '../absence-page';
import AbsenceRequestStatusBadge from './AbsenceRequestStatusBadge.vue';

const props = defineProps<{
  actionLoadingId?: null | string;
  currentUserId: null | string;
  hasReviewPermission: boolean;
  highlightForReview?: boolean;
  request: AbsenceRequest;
}>();
const emit = defineEmits<{
  approve: [request: AbsenceRequest];
  delete: [request: AbsenceRequest];
  edit: [request: AbsenceRequest];
  open: [request: AbsenceRequest];
  reject: [request: AbsenceRequest];
  return: [request: AbsenceRequest];
}>();
dayjs.extend(utc);
dayjs.extend(timezone);

const shouldHighlight = computed(
  () =>
    props.highlightForReview ||
    (props.request.status === 'pending' &&
      props.currentUserId !== null &&
      props.request.reviewer.id === props.currentUserId),
);

const canReview = computed(() =>
  canReviewRequest(
    props.request,
    props.currentUserId,
    props.hasReviewPermission,
  ),
);

const canEdit = computed(() =>
  canEditRequest(props.request, props.currentUserId),
);

const canDelete = computed(() =>
  canDeleteRequest(props.request, props.currentUserId),
);

const isActionLoading = computed(
  () => props.actionLoadingId === props.request.id,
);

function formatAbsenceRequestDate(dateStr: string): string {
  return dayjs(dateStr).tz(preferences.app.timezone).format('DD/MM/YYYY HH:mm');
}

function formatReasonPreview(reason: null | string): string {
  if (!reason) return '';
  return reason.length <= 100 ? reason : `${reason.slice(0, 100).trimEnd()}...`;
}
</script>

<template>
  <article
    data-testid="absence-request-item"
    :data-attention="shouldHighlight"
    class="group relative flex flex-col justify-between rounded-xl border transition-all cursor-pointer hover:shadow-xs"
    :class="[
      shouldHighlight
        ? 'border-blue-300/60 bg-blue-50/40 shadow-xs hover:bg-blue-50/60 dark:border-blue-500/30 dark:bg-blue-950/20 dark:hover:bg-blue-950/35'
        : 'border-border bg-card/60 hover:border-primary/40 hover:bg-accent/40 dark:bg-card/40 dark:hover:bg-accent/25',
    ]"
    @click="emit('open', request)"
  >
    <div class="w-full text-left p-3.5 sm:p-4 space-y-3">
      <!-- Top Row: Title, Status, Date Range on the left; Actions on the right -->
      <div
        class="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between"
      >
        <div class="flex flex-wrap items-center gap-4 min-w-0">
          <div class="flex items-center gap-2 shrink-0 xl:w-[320px]">
            <span class="text-sm font-semibold text-foreground">
              {{ $t(`absenceRequests.types.${request.leave_type}`) }}
            </span>
            <AbsenceRequestStatusBadge :status="request.status" />
          </div>

          <div class="flex items-center gap-1.5 text-xs text-muted-foreground">
            <IconifyIcon
              icon="lucide:calendar"
              class="size-3.5 shrink-0 text-muted-foreground/70"
            />
            <span class="font-medium tabular-nums text-foreground">{{
              formatAbsenceRequestDate(request.start_at)
            }}</span>
            <span>–</span>
            <span class="font-medium tabular-nums text-foreground">{{
              formatAbsenceRequestDate(request.end_at)
            }}</span>
          </div>
        </div>

        <!-- Inline Actions -->
        <div
          class="flex flex-nowrap shrink-0 items-center justify-end gap-1 pt-2 sm:pt-0 border-t sm:border-t-0 border-border min-w-0"
          @click.stop
        >
          <!-- Reviewer Actions -->
          <template v-if="hasReviewPermission">
            <Tooltip :title="$t('absenceRequests.actions.approve')">
              <Button
                type="primary"
                size="small"
                :disabled="!canReview || isActionLoading"
                :loading="isActionLoading"
                class="inline-flex size-7 items-center justify-center p-0"
                @click.stop="canReview && emit('approve', request)"
              >
                <template #icon>
                  <IconifyIcon icon="lucide:check" class="size-4" />
                </template>
              </Button>
            </Tooltip>

            <Tooltip :title="$t('absenceRequests.actions.reject')">
              <Button
                size="small"
                danger
                :disabled="!canReview || isActionLoading"
                class="inline-flex size-7 items-center justify-center p-0"
                @click.stop="canReview && emit('reject', request)"
              >
                <template #icon>
                  <IconifyIcon
                    icon="lucide:x"
                    class="size-4 text-destructive"
                  />
                </template>
              </Button>
            </Tooltip>

            <Tooltip :title="$t('absenceRequests.detail.actions.return')">
              <Button
                size="small"
                :disabled="!canReview || isActionLoading"
                class="inline-flex size-7 items-center justify-center p-0"
                @click.stop="canReview && emit('return', request)"
              >
                <template #icon>
                  <IconifyIcon
                    icon="lucide:rotate-ccw"
                    class="size-4 text-amber-500"
                  />
                </template>
              </Button>
            </Tooltip>
          </template>

          <!-- Requester Edit Action -->
          <Tooltip :title="$t('absenceRequests.detail.actions.edit')">
            <Button
              size="small"
              :disabled="!canEdit || isActionLoading"
              class="inline-flex size-7 items-center justify-center p-0 text-muted-foreground hover:text-foreground"
              @click.stop="canEdit && emit('edit', request)"
            >
              <template #icon>
                <IconifyIcon icon="lucide:edit-3" class="size-4" />
              </template>
            </Button>
          </Tooltip>

          <!-- Requester Delete Action -->
          <Tooltip :title="$t('absenceRequests.actions.delete')">
            <Button
              size="small"
              danger
              :disabled="!canDelete || isActionLoading"
              :loading="isActionLoading"
              class="inline-flex size-7 items-center justify-center p-0"
              @click.stop="canDelete && emit('delete', request)"
            >
              <template #icon>
                <IconifyIcon icon="lucide:trash-2" class="size-4" />
              </template>
            </Button>
          </Tooltip>
        </div>
      </div>

      <!-- Bottom Row: 4 equal metadata columns directly underneath, perfectly aligned! -->
      <div
        class="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-[320px_minmax(250px,1.5fr)_minmax(140px,0.85fr)_minmax(140px,0.85fr)] pt-1"
      >
        <!-- Col 3: Requester -->
        <div class="space-y-0.5 min-w-0">
          <p
            class="text-[11px] font-medium uppercase tracking-wider text-muted-foreground"
          >
            {{ $t('absenceRequests.labels.requester') }}
          </p>
          <p
            class="text-xs font-medium text-foreground truncate"
            :title="request.requester.name"
          >
            {{ request.requester.name }}
          </p>
        </div>

        <!-- Col 2: Reason & Approval Note & Address -->
        <div class="space-y-0.5 min-w-0">
          <p
            class="text-[11px] font-medium uppercase tracking-wider text-muted-foreground"
          >
            {{ $t('absenceRequests.detail.fields.reason') }}
          </p>
          <p
            class="text-xs font-medium text-foreground truncate"
            :title="request.reason || ''"
          >
            {{ formatReasonPreview(request.reason) || '—' }}
          </p>
          <p
            v-if="
              request.approval_note &&
              (request.status === 'rejected' || request.status === 'returned')
            "
            class="text-[11px] font-medium uppercase tracking-wider text-muted-foreground mr-1"
          >
            {{
              request.status === 'rejected'
                ? $t('absenceRequests.detail.fields.rejectReason')
                : $t('absenceRequests.detail.fields.returnNote')
            }}
          </p>
          <p
            v-if="request.approval_note"
            class="text-xs font-medium text-foreground truncate"
            :title="request.approval_note"
          >
            {{ formatReasonPreview(request.approval_note) }}
          </p>
          <p
            v-if="request.address"
            class="flex items-center gap-1 text-[11px] text-muted-foreground truncate"
            :title="request.address"
          >
            <IconifyIcon icon="lucide:map-pin" class="size-3 shrink-0" />
            <span class="text-xs font-medium text-foreground truncate">{{
              request.address
            }}</span>
          </p>
        </div>
        <!-- Col 4: Reviewer -->
        <div class="space-y-0.5 min-w-0">
          <p
            class="text-[11px] font-medium uppercase tracking-wider text-muted-foreground"
          >
            {{ $t('absenceRequests.labels.reviewer') }}
          </p>
          <p
            class="text-xs font-medium text-foreground truncate"
            :title="request.reviewer?.name"
          >
            {{ request.reviewer?.name || '—' }}
          </p>
        </div>

        <!-- Col 1: Created At -->
        <div class="space-y-0.5 min-w-0">
          <p
            class="text-[11px] font-medium uppercase tracking-wider text-muted-foreground"
          >
            {{ $t('absenceRequests.detail.fields.createdAt') }}
          </p>
          <p class="text-xs font-medium text-foreground truncate">
            {{ formatAbsenceRequestDate(request.created_at) }}
          </p>
        </div>
      </div>
    </div>
  </article>
</template>
