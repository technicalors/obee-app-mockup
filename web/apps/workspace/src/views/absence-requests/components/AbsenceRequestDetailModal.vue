<script setup lang="ts">
import type { AbsenceRequest } from '#/api/absence-requests';

import { computed, ref, watch } from 'vue';

import { useVbenModal } from '@vben/common-ui';
import { preferences } from '@vben/preferences';

import {
  Modal as AntModal,
  Button,
  Descriptions,
  DescriptionsItem,
  Input,
} from 'ant-design-vue';
import dayjs from 'dayjs';
import timezone from 'dayjs/plugin/timezone';
import utc from 'dayjs/plugin/utc';

import { $t } from '#/locales';

import AbsenceRequestStatusBadge from './AbsenceRequestStatusBadge.vue';

const props = defineProps<{
  approving: boolean;
  currentUserId: null | string;
  deleting: boolean;
  hasReviewPermission: boolean;
  open: boolean;
  rejecting: boolean;
  request: AbsenceRequest | null;
  returning: boolean;
}>();
const emit = defineEmits<{
  approve: [];
  delete: [];
  edit: [];
  reject: [note: string];
  return: [note: string];
  'update:open': [value: boolean];
}>();
dayjs.extend(utc);
dayjs.extend(timezone);

const [Modal, modalApi] = useVbenModal({
  class: 'w-[720px] max-w-[calc(100vw-1rem)]',
  contentClass: 'p-2 sm:p-4',
  footerClass: 'p-2 sm:p-3',
  headerClass: 'px-3 py-2.5 sm:px-5 sm:py-4',
  draggable: true,
  fullscreenButton: true,
  footer: true,
  showCancelButton: false,
  showConfirmButton: false,
  title: $t('absenceRequests.detail.title'),
  onOpenChange: (open) => {
    emit('update:open', open);
  },
});

watch(
  () => props.open,
  (isOpen) => {
    if (isOpen) {
      modalApi.open();
    } else {
      modalApi.close();
    }
  },
);

const isRejectMode = ref(false);
const isReturnMode = ref(false);
const rejectNote = ref('');
const rejectNoteError = ref(false);
watch(
  () => props.open,
  (isOpen) => {
    if (!isOpen) {
      isRejectMode.value = false;
      isReturnMode.value = false;
      rejectNote.value = '';
      rejectNoteError.value = false;
    }
  },
);

const canReview = computed(
  () =>
    props.request !== null &&
    props.currentUserId !== null &&
    props.hasReviewPermission &&
    props.request.status === 'pending' &&
    props.request.user_id !== props.currentUserId &&
    props.request.reviewer_id === props.currentUserId,
);

const canEdit = computed(
  () =>
    props.request !== null &&
    props.request.user_id === props.currentUserId &&
    props.request.status === 'returned',
);

const canDelete = computed(
  () =>
    props.request !== null &&
    props.currentUserId !== null &&
    ['pending', 'returned'].includes(props.request.status) &&
    props.request.user_id === props.currentUserId,
);

function formatAbsenceRequestDate(dateStr?: null | string): string {
  if (!dateStr) return '';
  return dayjs(dateStr).tz(preferences.app.timezone).format('DD/MM/YYYY HH:mm');
}

function handleApproveClick(): void {
  AntModal.confirm({
    content: $t('absenceRequests.detail.review.confirmApproveDescription'),
    onOk: () => emit('approve'),
    title: $t('absenceRequests.detail.review.confirmApproveTitle'),
  });
}

function handleRejectSubmit(): void {
  if (rejectNote.value === '') {
    isRejectMode.value = true;
    rejectNoteError.value = true;
    return;
  }
  AntModal.confirm({
    content: $t('absenceRequests.detail.review.confirmRejectDescription'),
    okButtonProps: { danger: true },
    onOk: () => emit('reject', rejectNote.value),
    title: $t('absenceRequests.detail.review.confirmRejectTitle'),
  });
}

function handleReturnSubmit(): void {
  if (rejectNote.value === '') {
    rejectNoteError.value = true;
    return;
  }
  emit('return', rejectNote.value);
}

function startRejectMode(): void {
  isRejectMode.value = true;
  isReturnMode.value = false;
  rejectNote.value = '';
  rejectNoteError.value = false;
}

function startReturnMode(): void {
  isReturnMode.value = true;
  isRejectMode.value = false;
  rejectNote.value = '';
  rejectNoteError.value = false;
}

function handleDeleteClick(): void {
  AntModal.confirm({
    content: $t('absenceRequests.detail.requester.confirmDeleteDescription'),
    okButtonProps: { danger: true },
    onOk: () => emit('delete'),
    title: $t('absenceRequests.detail.requester.confirmDeleteTitle'),
  });
}
</script>

<template>
  <Modal
    :close-on-click-modal="false"
    :draggable="true"
    :fullscreen-button="true"
  >
    <div v-if="request" class="space-y-6 px-1 py-1 sm:px-4 sm:py-2">
      <!-- Header section -->
      <div class="space-y-1">
        <div class="flex items-center justify-between gap-4">
          <h2 class="text-lg font-semibold text-foreground">
            {{ $t(`absenceRequests.types.${request.leave_type}`) }}
          </h2>
          <AbsenceRequestStatusBadge :status="request.status" />
        </div>
        <div class="text-xs text-muted-foreground">
          {{
            request.status === 'approved' && request.approved_at
              ? `${$t('absenceRequests.detail.fields.approvedAt')} ${formatAbsenceRequestDate(request.approved_at)}`
              : request.status === 'rejected' && request.rejected_at
                ? `${$t('absenceRequests.detail.fields.rejectedAt')} ${formatAbsenceRequestDate(request.rejected_at)}`
                : request.submitted_at
                  ? `${$t('absenceRequests.detail.fields.submittedAt')} ${formatAbsenceRequestDate(request.submitted_at)}`
                  : `${$t('absenceRequests.detail.fields.createdAt')} ${formatAbsenceRequestDate(request.created_at)}`
          }}
        </div>
      </div>

      <Descriptions
        :colon="false"
        :column="{ xs: 1, sm: 2 }"
        class="[&_.ant-descriptions-item-content]:font-medium [&_.ant-descriptions-item-content]:text-foreground [&_.ant-descriptions-item-label]:text-xs [&_.ant-descriptions-item-label]:text-muted-foreground"
        layout="vertical"
        size="small"
      >
        <DescriptionsItem :label="$t('absenceRequests.detail.fields.startAt')">
          {{ formatAbsenceRequestDate(request.start_at) }}
        </DescriptionsItem>
        <DescriptionsItem :label="$t('absenceRequests.detail.fields.endAt')">
          {{ formatAbsenceRequestDate(request.end_at) }}
        </DescriptionsItem>
        <DescriptionsItem
          :label="$t('absenceRequests.detail.fields.requester')"
        >
          {{ request.requester.name }}
        </DescriptionsItem>
        <DescriptionsItem :label="$t('absenceRequests.detail.fields.reviewer')">
          {{ request.reviewer?.name }}
        </DescriptionsItem>
        <DescriptionsItem
          v-if="request.address"
          :label="$t('absenceRequests.detail.fields.address')"
          :span="2"
        >
          <span class="whitespace-pre-wrap">{{ request.address }}</span>
        </DescriptionsItem>
        <DescriptionsItem
          v-if="request.reason"
          :label="$t('absenceRequests.detail.fields.reason')"
          :span="2"
        >
          <span class="whitespace-pre-wrap">{{ request.reason }}</span>
        </DescriptionsItem>
        <DescriptionsItem
          v-if="request.approval_note"
          :label="
            request.status === 'rejected'
              ? $t('absenceRequests.detail.fields.rejectReason')
              : request.status === 'returned'
                ? $t('absenceRequests.detail.fields.returnNote')
                : $t('absenceRequests.detail.fields.approvalNote')
          "
          :span="2"
        >
          <span class="whitespace-pre-wrap">{{ request.approval_note }}</span>
        </DescriptionsItem>
      </Descriptions>

      <!-- Reject / Return Note Input -->
      <div
        v-if="canReview && (isRejectMode || isReturnMode)"
        class="space-y-1.5 rounded-lg border border-border bg-muted/20 p-3"
      >
        <label class="text-xs font-medium text-foreground">
          {{
            $t(
              isReturnMode
                ? 'absenceRequests.detail.review.returnNoteLabel'
                : 'absenceRequests.detail.review.rejectNoteLabel',
            )
          }}
        </label>
        <Input.TextArea
          v-model:value="rejectNote"
          :rows="3"
          :placeholder="
            $t('absenceRequests.detail.review.rejectNotePlaceholder')
          "
          :status="rejectNoteError ? 'error' : ''"
          @change="rejectNoteError = false"
        />
        <p v-if="rejectNoteError" class="text-xs text-destructive">
          {{
            $t(
              isReturnMode
                ? 'absenceRequests.detail.review.returnNoteRequired'
                : 'absenceRequests.detail.review.rejectNoteRequired',
            )
          }}
        </p>
      </div>
    </div>

    <!-- Modal Footer with actions -->
    <template #footer>
      <div class="flex w-full items-center justify-between gap-2">
        <div>
          <!-- Requester actions -->
          <template v-if="canDelete">
            <Button
              v-if="canEdit"
              :disabled="deleting"
              class="mr-2"
              @click="emit('edit')"
            >
              {{ $t('absenceRequests.detail.actions.edit') }}
            </Button>
            <Button
              danger
              :loading="deleting"
              :disabled="approving || rejecting"
              @click="handleDeleteClick"
            >
              {{
                deleting
                  ? $t('absenceRequests.detail.actions.deleting')
                  : $t('absenceRequests.detail.actions.delete')
              }}
            </Button>
          </template>
        </div>

        <div class="flex items-center gap-2">
          <!-- Reviewer actions -->
          <template v-if="canReview">
            <Button
              type="primary"
              :loading="approving"
              :disabled="rejecting || deleting"
              @click="handleApproveClick"
            >
              {{
                approving
                  ? $t('absenceRequests.detail.actions.approving')
                  : $t('absenceRequests.detail.actions.approve')
              }}
            </Button>
            <Button
              :loading="rejecting"
              :disabled="approving || deleting"
              @click="isRejectMode ? handleRejectSubmit() : startRejectMode()"
            >
              {{
                rejecting
                  ? $t('absenceRequests.detail.actions.rejecting')
                  : $t('absenceRequests.detail.actions.reject')
              }}
            </Button>
            <Button
              :loading="returning"
              :disabled="approving || rejecting || deleting"
              @click="isReturnMode ? handleReturnSubmit() : startReturnMode()"
            >
              {{ $t('absenceRequests.detail.actions.return') }}
            </Button>
          </template>

          <Button @click="emit('update:open', false)">
            {{ $t('absenceRequests.detail.actions.close') }}
          </Button>
        </div>
      </div>
    </template>
  </Modal>
</template>
