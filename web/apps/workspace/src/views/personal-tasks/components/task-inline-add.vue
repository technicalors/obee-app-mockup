<script setup lang="ts">
import type { InputRef } from 'ant-design-vue/es/vc-input/inputProps';

import type { PersonalTaskList } from '#/api/contracts/personal-tasks';

import { computed, nextTick, ref, watch } from 'vue';

import { createIconifyIcon } from '@vben/icons';

import { Button, Input, Select, Tag } from 'ant-design-vue';

import { $t } from '#/locales';

const props = defineProps<{
  canChooseList: boolean;
  listId: string;
  lists: PersonalTaskList[];
  saveTask: (payload: { listId: string; title: string }) => Promise<boolean>;
  showListLabel?: boolean;
}>();

const PlusIcon = createIconifyIcon('lucide:plus');
const inputRef = ref<InputRef | null>(null);
const isSaving = ref(false);
const title = ref('');
const trimmedTitle = computed(() => title.value.trim());
const chosenListId = ref(props.listId);
const chosenList = computed<PersonalTaskList>(() => {
  const list = props.lists.find((item) => item.id === chosenListId.value);
  if (list === undefined) {
    throw new Error(`Task list ${chosenListId.value} is not loaded`);
  }
  return list;
});

watch(
  () => props.listId,
  (listId) => {
    chosenListId.value = listId;
  },
);

async function submit(): Promise<void> {
  if (trimmedTitle.value.length === 0 || isSaving.value) return;

  isSaving.value = true;
  try {
    const wasSaved = await props.saveTask({
      listId: chosenListId.value,
      title: trimmedTitle.value,
    });
    if (wasSaved) title.value = '';
  } finally {
    isSaving.value = false;
  }

  await nextTick();
  inputRef.value?.focus();
}

function handleEnter(event: KeyboardEvent): void {
  if (event.isComposing || event.keyCode === 229) return;
  event.preventDefault();
  void submit();
}

function handleKeydown(event: KeyboardEvent): void {
  if (event.key === 'Escape') title.value = '';
}
</script>

<template>
  <div
    class="task-composer flex items-center gap-3 rounded-xl bg-card p-4 shadow-xs"
    data-testid="task-inline-add"
  >
    <Select
      v-if="canChooseList && showListLabel !== false"
      v-model:value="chosenListId"
      :bordered="false"
      :popup-match-select-width="false"
      class="task-composer-list max-w-32 shrink-0 sm:max-w-48"
      :aria-label="$t('personalTasks.taskDetail.list')"
      :disabled="isSaving"
      data-testid="task-inline-add-list-select"
    >
      <Select.Option v-for="list in lists" :key="list.id" :value="list.id">
        {{ list.title }}
      </Select.Option>
    </Select>
    <Tag
      v-else-if="showListLabel !== false"
      class="m-0 max-w-32 shrink-0 truncate rounded-full px-2 py-0 text-xs sm:max-w-48"
      data-testid="task-inline-add-list"
    >
      {{ chosenList.title }}
    </Tag>
    <div class="task-composer-field min-w-0 flex-1">
      <Input
        ref="inputRef"
        v-model:value="title"
        :bordered="false"
        :maxlength="1024"
        :aria-label="$t('personalTasks.inlineAdd.placeholder')"
        :placeholder="$t('personalTasks.inlineAdd.placeholder')"
        :disabled="isSaving"
        data-testid="task-inline-add-input"
        @press-enter="handleEnter"
        @keydown="handleKeydown"
      />
    </div>
    <Button
      type="text"
      shape="circle"
      class="task-composer-send shrink-0"
      :aria-label="$t('personalTasks.inlineAdd.send')"
      :title="$t('personalTasks.inlineAdd.send')"
      :disabled="trimmedTitle.length === 0 || isSaving"
      :loading="isSaving"
      data-testid="task-inline-add-send"
      @click="submit"
    >
      <template #icon>
        <PlusIcon class="size-5" />
      </template>
    </Button>
  </div>
</template>
