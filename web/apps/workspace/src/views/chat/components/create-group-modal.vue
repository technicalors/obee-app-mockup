<script setup lang="ts">
import type { User } from '#/api';

import { computed, ref, watch } from 'vue';

import { Form, Input, Modal, Select } from 'ant-design-vue';

import { $t } from '#/locales';

interface Props {
  colleagues: User[];
  isLoadingColleagues: boolean;
  isSubmitting: boolean;
  open: boolean;
}

const props = defineProps<Props>();

const emit = defineEmits<{
  submit: [{ name: string; userIds: string[] }];
  'update:open': [val: boolean];
}>();

const groupName = ref('');
const selectedUserIds = ref<string[]>([]);

const colleagueOptions = computed(() =>
  props.colleagues.map((u) => ({
    disabled: !u.matrix_user_id,
    label: `${u.name} (@${u.username})${u.matrix_user_id ? '' : ` — ${$t('chat.userNotActivated')}`}`,
    value: u.id,
  })),
);

watch(
  () => props.open,
  (val) => {
    if (val) {
      groupName.value = '';
      selectedUserIds.value = [];
    }
  },
);

function handleOk(): void {
  const name = groupName.value.trim();
  if (!name || selectedUserIds.value.length === 0 || props.isSubmitting) {
    return;
  }
  emit('submit', {
    name,
    userIds: [...selectedUserIds.value],
  });
}
</script>

<template>
  <Modal
    :open="open"
    :title="$t('chat.createGroup')"
    :confirm-loading="isSubmitting"
    :ok-text="$t('chat.ok')"
    :cancel-text="$t('chat.cancel')"
    :ok-button-props="{
      disabled: !groupName.trim() || selectedUserIds.length === 0,
    }"
    destroy-on-close
    @cancel="emit('update:open', false)"
    @ok="handleOk"
  >
    <Form layout="vertical" class="pt-3">
      <Form.Item :label="$t('chat.groupName')" required>
        <Input
          v-model:value="groupName"
          :placeholder="$t('chat.groupNamePlaceholder')"
          allow-clear
          class="rounded-md"
        />
      </Form.Item>

      <Form.Item :label="$t('chat.selectUser')" required>
        <Select
          v-model:value="selectedUserIds"
          mode="multiple"
          :placeholder="$t('chat.selectUserPlaceholder')"
          :loading="isLoadingColleagues"
          class="w-full"
          show-search
          :options="colleagueOptions"
        />
      </Form.Item>
    </Form>
  </Modal>
</template>
