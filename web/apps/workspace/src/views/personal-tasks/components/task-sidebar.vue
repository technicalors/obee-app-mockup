<script setup lang="ts">
import type { TaskFilterType } from '../use-personal-tasks';

import type { PersonalTaskList } from '#/api/contracts/personal-tasks';

import { ref, useId } from 'vue';

import { createIconifyIcon } from '@vben/icons';

import { Button, Input, Modal } from 'ant-design-vue';

import { $t } from '#/locales';

const props = withDefaults(
  defineProps<{
    allOpenCount: number;
    hiddenListIds?: Set<string>;
    lists: PersonalTaskList[];
    selectedListId: TaskFilterType;
    taskCountsByListId: Map<string, number>;
  }>(),
  {
    hiddenListIds: () => new Set<string>(),
  },
);

const emit = defineEmits<{
  createList: [title: string];
  createTask: [];
  selectList: [listId: TaskFilterType];
  toggleListVisibility: [listId: string];
}>();

const ListIcon = createIconifyIcon('lucide:list-todo');
const PlusIcon = createIconifyIcon('lucide:plus');

const fieldId = useId();
const isCreatingList = ref(false);
const newListName = ref('');

function handleCreateList(): void {
  const name = newListName.value.trim();
  if (name) {
    emit('createList', name);
    newListName.value = '';
    isCreatingList.value = false;
  }
}

function cancelCreateList(): void {
  newListName.value = '';
  isCreatingList.value = false;
}

function isListVisible(listId: string): boolean {
  return !props.hiddenListIds.has(listId);
}
</script>

<template>
  <aside
    class="flex h-full min-h-0 w-full flex-col justify-between bg-card"
    :aria-label="$t('personalTasks.lists.navigationLabel')"
  >
    <div class="min-h-0 flex-1 overflow-y-auto p-2 flex flex-col gap-0.5">
      <Button
        type="primary"
        size="large"
        class="mb-2 flex w-full items-center justify-center gap-2"
        :disabled="lists.length === 0"
        data-testid="create-task-trigger"
        @click="emit('createTask')"
      >
        <template #icon>
          <PlusIcon class="size-4" />
        </template>
        <span>{{ $t('personalTasks.create.button') }}</span>
      </Button>

      <button
        type="button"
        class="flex items-center justify-between rounded-md px-2.5 py-2 text-sm font-medium transition-colors task-focus hover:bg-muted/80"
        :class="{
          'bg-primary/10 text-primary font-semibold': selectedListId === 'all',
          'text-foreground': selectedListId !== 'all',
        }"
        :aria-current="selectedListId === 'all' ? 'page' : undefined"
        data-testid="all-lists-option"
        @click="emit('selectList', 'all')"
      >
        <span class="flex items-center gap-2.5 truncate">
          <ListIcon class="size-4 shrink-0 text-muted-foreground" />
          <span class="truncate">{{ $t('personalTasks.lists.all') }}</span>
        </span>
        <span
          v-if="allOpenCount > 0"
          class="shrink-0 rounded bg-muted px-2 py-0.5 text-xs font-semibold text-muted-foreground tabular-nums"
        >
          {{ allOpenCount }}
        </span>
      </button>

      <div class="my-1 border-t border-border/60"></div>

      <div
        v-for="list in lists"
        :key="list.id"
        class="flex items-center rounded-md px-2.5 text-sm font-medium transition-colors hover:bg-muted/80"
        :class="{
          'bg-primary/10 text-primary font-semibold':
            selectedListId === list.id,
          'text-foreground': selectedListId !== list.id,
        }"
      >
        <input
          type="checkbox"
          class="size-4 shrink-0 cursor-pointer accent-[hsl(var(--primary))]"
          :checked="isListVisible(list.id)"
          :aria-label="list.title"
          data-testid="task-list-visibility-checkbox"
          :data-list-id="list.id"
          @change="emit('toggleListVisibility', list.id)"
        />
        <button
          type="button"
          class="task-focus flex min-w-0 flex-1 items-center justify-between gap-2 rounded-md px-2.5 py-2 text-left"
          :aria-current="selectedListId === list.id ? 'page' : undefined"
          data-testid="task-list-option"
          :data-list-id="list.id"
          @click="emit('selectList', list.id)"
        >
          <span class="truncate">{{ list.title }}</span>
          <span
            v-if="(taskCountsByListId.get(list.id) ?? 0) > 0"
            class="shrink-0 rounded bg-muted px-2 py-0.5 text-xs font-semibold text-muted-foreground tabular-nums"
          >
            {{ taskCountsByListId.get(list.id) }}
          </span>
        </button>
      </div>

      <button
        type="button"
        class="task-focus mt-0.5 flex w-full items-center gap-2.5 rounded-md px-2.5 py-2 text-left text-sm font-medium text-muted-foreground transition-colors hover:bg-muted/70 hover:text-foreground"
        data-testid="create-list-trigger"
        @click="isCreatingList = true"
      >
        <PlusIcon class="size-4 shrink-0" />
        <span class="truncate">{{ $t('personalTasks.lists.createList') }}</span>
      </button>
    </div>
    <Modal
      :open="isCreatingList"
      root-class-name="personal-tasks-ui"
      :title="$t('personalTasks.lists.createList')"
      :ok-button-props="{ disabled: !newListName.trim() }"
      :ok-text="$t('personalTasks.lists.create')"
      :cancel-text="$t('personalTasks.quickAdd.cancel')"
      @ok="handleCreateList"
      @cancel="cancelCreateList"
    >
      <div class="py-4 flex flex-col gap-2">
        <label :for="fieldId" class="task-label">
          {{ $t('personalTasks.lists.name') }}
        </label>
        <Input
          :id="fieldId"
          v-model:value="newListName"
          size="middle"
          class="rounded-lg"
          :placeholder="$t('personalTasks.lists.namePlaceholder')"
          auto-focus
          @press-enter="
            (event: KeyboardEvent) => {
              if (!event.isComposing && event.keyCode !== 229)
                handleCreateList();
            }
          "
        />
      </div>
    </Modal>
  </aside>
</template>
