<script setup lang="ts">
import type { AbsenceRequest } from '#/api/absence-requests';

import { computed, ref, watch } from 'vue';

import { useVbenModal } from '@vben/common-ui';

import { Button, Input } from 'ant-design-vue';

import { $t } from '#/locales';

const props = defineProps<{
  loading: boolean;
  mode: 'reject' | 'return';
  open: boolean;
  request: AbsenceRequest | null;
}>();

const emit = defineEmits<{
  submit: [note: string];
  'update:open': [value: boolean];
}>();

const note = ref('');
const error = ref(false);

const title = computed(() => {
  return props.mode === 'reject'
    ? $t('absenceRequests.actions.reject')
    : $t('absenceRequests.actions.return');
});

const label = computed(() => {
  return props.mode === 'reject'
    ? $t('absenceRequests.detail.review.rejectNoteLabel')
    : $t('absenceRequests.detail.review.returnNoteLabel');
});

const placeholder = computed(() => {
  return props.mode === 'reject'
    ? $t('absenceRequests.detail.review.rejectNotePlaceholder')
    : $t('absenceRequests.detail.review.returnNoteRequired');
});

const [Modal, modalApi] = useVbenModal({
  class: 'w-[480px] max-w-[calc(100vw-1rem)]',
  contentClass: 'p-2 sm:p-4',
  footerClass: 'p-2 sm:p-3',
  headerClass: 'px-3 py-2.5 sm:px-5 sm:py-4',
  draggable: true,
  footer: true,
  fullscreenButton: false,
  showCancelButton: false,
  showConfirmButton: false,
  title: title.value,
  onOpenChange: (open) => {
    emit('update:open', open);
  },
});

watch(title, (val) => {
  modalApi.setState({ title: val });
});

watch(
  () => props.open,
  (isOpen) => {
    if (isOpen) {
      note.value = '';
      error.value = false;
      modalApi.open();
    } else {
      modalApi.close();
    }
  },
);

function handleSubmit(): void {
  if (note.value === '') {
    error.value = true;
    return;
  }
  emit('submit', note.value);
}
</script>

<template>
  <Modal :close-on-click-modal="false" :draggable="true">
    <div class="space-y-3 px-1 py-1 sm:px-4 sm:py-2">
      <div
        v-if="request"
        class="rounded-lg bg-muted/40 p-2.5 text-xs text-muted-foreground"
      >
        <p class="font-medium text-foreground">
          {{ request.requester.name }} –
          {{ $t(`absenceRequests.types.${request.leave_type}`) }}
        </p>
      </div>

      <div class="space-y-1.5">
        <label class="text-xs font-semibold text-foreground">
          {{ label }} <span class="text-destructive">*</span>
        </label>
        <Input.TextArea
          v-model:value="note"
          :rows="4"
          :placeholder="placeholder"
          :status="error ? 'error' : ''"
          @change="error = false"
        />
        <p v-if="error" class="text-xs text-destructive">
          {{
            mode === 'reject'
              ? $t('absenceRequests.detail.review.rejectNoteRequired')
              : $t('absenceRequests.detail.review.returnNoteRequired')
          }}
        </p>
      </div>
    </div>

    <template #footer>
      <div class="flex items-center justify-end gap-2">
        <Button @click="emit('update:open', false)">
          {{ $t('absenceRequests.actions.cancel') }}
        </Button>
        <Button
          :danger="mode === 'reject'"
          :type="mode === 'reject' ? 'primary' : 'primary'"
          :loading="loading"
          @click="handleSubmit"
        >
          {{ title }}
        </Button>
      </div>
    </template>
  </Modal>
</template>
