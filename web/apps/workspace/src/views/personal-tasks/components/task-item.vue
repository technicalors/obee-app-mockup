<script setup lang="ts">
import type { InputRef } from 'ant-design-vue/es/vc-input/inputProps';

import type {
  PersonalTask,
  PersonalTaskList,
} from '#/api/contracts/personal-tasks';

import { computed, nextTick, ref, watch } from 'vue';

import { createIconifyIcon } from '@vben/icons';

import { Button, DatePicker, Input, Popconfirm, Tag } from 'ant-design-vue';

import dayjs from 'dayjs';

import { $t } from '#/locales';

const props = defineProps<{
  isSubtask?: boolean;
  listsById: Map<string, PersonalTaskList>;
  saveDueDate?: (
    taskId: string,
    dueDate: null | string,
    dueTime: null | string,
  ) => Promise<boolean>;
  saveSubtask: (parentId: string, title: string) => Promise<boolean>;
  showList?: boolean;
  subtasks?: PersonalTask[];
  task: PersonalTask;
}>();
const emit = defineEmits<{
  delete: [taskId: string];
  openDetail: [taskId: string];
  toggleStar: [taskId: string];
  toggleStatus: [taskId: string];
}>();
const CheckIcon = createIconifyIcon('lucide:check');
const StarIcon = createIconifyIcon('lucide:star');
const CalendarIcon = createIconifyIcon('lucide:calendar');
const RepeatIcon = createIconifyIcon('lucide:repeat');
const CornerDownRightIcon = createIconifyIcon('lucide:corner-down-right');
const TrashIcon = createIconifyIcon('lucide:trash-2');
const PlusIcon = createIconifyIcon('lucide:plus');
const XIcon = createIconifyIcon('lucide:x');
const addSubtaskTriggerRef = ref<HTMLButtonElement | null>(null);
const subtaskInputRef = ref<InputRef | null>(null);
const isAddingSubtask = ref(false);
const isSavingDueDate = ref(false);
const isSavingSubtask = ref(false);
const subtaskTitle = ref('');
const quickDueAt = ref<string>();

const isCompleted = computed(() => props.task.status === 'completed');
const isStarred = computed(() => props.task.extension.starred);
const listInfo = computed(() => props.listsById.get(props.task.task_list_id));
const isOverdue = computed(() => {
  if (props.task.due_date === null || isCompleted.value) return false;
  const dueTime = props.task.due_time ?? '17:00';
  return dayjs(`${props.task.due_date}T${dueTime}:00`).isBefore(dayjs());
});

watch(
  () => [props.task.due_date, props.task.due_time] as const,
  ([dueDate, dueTime]) => {
    quickDueAt.value = dueDate ? `${dueDate} ${dueTime ?? '17:00'}` : undefined;
  },
  { immediate: true },
);

async function handleQuickDueChange(value: unknown): Promise<void> {
  if (isSavingDueDate.value) return;

  const nextValue = typeof value === 'string' ? value : null;
  const [dueDate = null, dueTime = null] = nextValue?.split(' ') ?? [];
  isSavingDueDate.value = true;
  try {
    const wasSaved =
      (await props.saveDueDate?.(props.task.id, dueDate, dueTime)) ?? false;
    if (!wasSaved) {
      quickDueAt.value = props.task.due_date
        ? `${props.task.due_date} ${props.task.due_time ?? '17:00'}`
        : undefined;
    }
  } finally {
    isSavingDueDate.value = false;
  }
}

async function openSubtaskInput(): Promise<void> {
  isAddingSubtask.value = true;
  await nextTick();
  subtaskInputRef.value?.focus();
}

async function closeSubtaskInput(): Promise<void> {
  isAddingSubtask.value = false;
  subtaskTitle.value = '';
  await nextTick();
  addSubtaskTriggerRef.value?.focus();
}

async function addSubtask(): Promise<void> {
  if (subtaskTitle.value.length === 0 || isSavingSubtask.value) return;

  isSavingSubtask.value = true;
  try {
    const wasSaved = await props.saveSubtask(props.task.id, subtaskTitle.value);
    if (wasSaved) {
      subtaskTitle.value = '';
      await nextTick();
      subtaskInputRef.value?.focus();
    }
  } finally {
    isSavingSubtask.value = false;
  }
}

function handleSubtaskEnter(event: KeyboardEvent): void {
  if (event.isComposing || event.keyCode === 229) return;
  void addSubtask();
}

function handleSubtaskKeydown(event: KeyboardEvent): void {
  if (event.isComposing || event.keyCode === 229) return;
  if (event.key === 'Escape') {
    event.preventDefault();
    void closeSubtaskInput();
  }
}
</script>

<template>
  <div
    class="group flex flex-col rounded-xl border border-border/80 bg-card transition-all duration-150 hover:border-border hover:shadow-xs"
  >
    <div
      class="task-row flex items-center gap-2.5 rounded-xl px-3 py-2.5 sm:px-4 sm:py-3 transition-colors hover:bg-muted/40 focus-within:bg-muted/40"
      :class="{ 'pl-8 sm:pl-10': isSubtask }"
      data-testid="task-row"
      :data-task-id="task.id"
    >
      <button
        type="button"
        class="task-icon-button shrink-0 text-muted-foreground"
        :aria-pressed="isCompleted"
        :aria-label="
          $t(
            isCompleted
              ? 'personalTasks.actions.markOpen'
              : 'personalTasks.actions.markCompleted',
            { title: task.title },
          )
        "
        data-testid="task-checkbox"
        @click="emit('toggleStatus', task.id)"
      >
        <span
          class="flex size-5 items-center justify-center rounded-full border-2 transition-all duration-150 active:scale-75"
          :class="
            isCompleted
              ? 'border-primary bg-primary text-primary-foreground scale-100'
              : 'border-muted-foreground/60 hover:border-primary group-hover:border-primary/80 hover:scale-110'
          "
        >
          <CheckIcon v-if="isCompleted" class="size-3 stroke-[2.5]" />
        </span>
      </button>
      <div class="flex min-w-0 flex-1 flex-col items-start gap-1">
        <button
          type="button"
          class="task-focus flex w-full min-w-0 items-center gap-2 rounded text-left"
          :aria-label="
            $t('personalTasks.actions.openDetail', { title: task.title })
          "
          data-testid="task-detail-trigger"
          @click="emit('openDetail', task.id)"
        >
          <span
            class="truncate text-sm font-medium leading-6"
            :class="
              isCompleted
                ? 'text-muted-foreground/70 line-through'
                : 'text-foreground'
            "
          >
            {{ task.title }}
          </span>
          <Tag
            v-if="showList && listInfo"
            class="m-0 shrink-0 whitespace-nowrap rounded-full px-2 py-0 text-xs"
          >
            {{ listInfo.title }}
          </Tag>
        </button>
        <div
          v-if="task.due_date"
          class="inline-flex shrink-0 items-center gap-1"
        >
          <DatePicker
            v-model:value="quickDueAt"
            :allow-clear="true"
            :bordered="false"
            class="task-quick-due !h-7 !w-[8.5rem] !rounded-full !px-2 text-xs"
            :class="
              isOverdue
                ? '!border !border-rose-300/80 !bg-rose-50 dark:!border-rose-900/60 dark:!bg-rose-950/40 [&_input]:!text-rose-600 dark:[&_input]:!text-rose-400'
                : '!border !border-border/60 !bg-muted/60 [&_input]:!text-muted-foreground'
            "
            :disabled="isSavingDueDate"
            format="DD/MM HH:mm"
            value-format="YYYY-MM-DD HH:mm"
            :show-time="{ format: 'HH:mm' }"
            :placeholder="$t('personalTasks.taskDetail.dueDatePlaceholder')"
            :title="
              isOverdue ? $t('personalTasks.taskList.overdue') : undefined
            "
            data-testid="task-quick-due-picker"
            @change="handleQuickDueChange"
          >
            <template #suffixIcon>
              <CalendarIcon class="size-3" />
            </template>
          </DatePicker>
          <RepeatIcon
            v-if="task.extension.recurrence"
            class="size-3 text-muted-foreground"
            role="img"
            :aria-label="$t('personalTasks.recurrence.label')"
            data-testid="task-recurrence-icon"
          />
        </div>
        <RepeatIcon
          v-else-if="task.extension.recurrence"
          class="size-3 shrink-0 text-muted-foreground"
          role="img"
          :aria-label="$t('personalTasks.recurrence.label')"
          data-testid="task-recurrence-icon"
        />
      </div>
      <div class="flex shrink-0 items-center gap-1">
        <Popconfirm
          :title="$t('personalTasks.taskDetail.deleteConfirm')"
          :ok-text="$t('personalTasks.actions.delete')"
          :cancel-text="$t('personalTasks.quickAdd.cancel')"
          @confirm="emit('delete', task.id)"
        >
          <button
            type="button"
            class="task-icon-button task-delete-action text-muted-foreground hover:text-rose-600 dark:hover:text-rose-300"
            :aria-label="
              $t('personalTasks.actions.deleteNamed', {
                title: task.title,
              })
            "
            :title="$t('personalTasks.taskDetail.delete')"
            data-testid="task-delete-button"
          >
            <TrashIcon class="size-4" />
          </button>
        </Popconfirm>
        <button
          type="button"
          class="task-icon-button"
          :class="
            isStarred
              ? 'text-amber-600 dark:text-amber-400'
              : 'text-muted-foreground/60 hover:text-muted-foreground'
          "
          :aria-pressed="isStarred"
          :aria-label="
            $t(
              isStarred
                ? 'personalTasks.actions.removeStar'
                : 'personalTasks.actions.star',
              { title: task.title },
            )
          "
          data-testid="task-star-button"
          @click="emit('toggleStar', task.id)"
        >
          <StarIcon class="size-4" :class="{ 'fill-current': isStarred }" />
        </button>
      </div>
    </div>
    <div
      v-if="subtasks && subtasks.length > 0"
      class="ml-9 sm:ml-12 border-l border-border/60 pl-3 sm:pl-4 flex flex-col gap-1 pb-1 pt-0.5"
    >
      <div
        v-for="subtask in subtasks"
        :key="subtask.id"
        class="flex items-center gap-2 rounded-lg px-2 py-1.5 transition-colors hover:bg-muted/70 focus-within:bg-muted/70"
      >
        <CornerDownRightIcon
          class="size-3.5 shrink-0 text-muted-foreground/50"
          aria-hidden="true"
        />
        <button
          type="button"
          class="task-icon-button shrink-0 text-muted-foreground !size-6 !min-h-6"
          :aria-pressed="subtask.status === 'completed'"
          :aria-label="
            $t(
              subtask.status === 'completed'
                ? 'personalTasks.actions.markOpen'
                : 'personalTasks.actions.markCompleted',
              { title: subtask.title },
            )
          "
          @click="emit('toggleStatus', subtask.id)"
        >
          <span
            class="flex size-4 items-center justify-center rounded-full border transition-all duration-150 active:scale-75"
            :class="
              subtask.status === 'completed'
                ? 'border-primary bg-primary text-primary-foreground'
                : 'border-muted-foreground/60 hover:border-primary'
            "
          >
            <CheckIcon
              v-if="subtask.status === 'completed'"
              class="size-2.5 stroke-[2.5]"
            />
          </span>
        </button>
        <button
          type="button"
          class="task-focus min-h-7 min-w-0 flex-1 rounded text-left text-xs sm:text-[13px] leading-5"
          :class="
            subtask.status === 'completed'
              ? 'text-muted-foreground line-through'
              : 'text-foreground'
          "
          :aria-label="
            $t('personalTasks.actions.openDetail', {
              title: subtask.title,
            })
          "
          @click="emit('openDetail', subtask.id)"
        >
          <span class="line-clamp-2 break-words">{{ subtask.title }}</span>
        </button>
        <Popconfirm
          :title="$t('personalTasks.taskDetail.deleteConfirm')"
          :ok-text="$t('personalTasks.actions.delete')"
          :cancel-text="$t('personalTasks.quickAdd.cancel')"
          @confirm="emit('delete', subtask.id)"
        >
          <button
            type="button"
            class="task-icon-button task-delete-action shrink-0 text-muted-foreground hover:text-rose-600"
            :aria-label="
              $t('personalTasks.actions.deleteNamed', {
                title: subtask.title,
              })
            "
            @click.stop
          >
            <TrashIcon class="size-3.5" />
          </button>
        </Popconfirm>
      </div>
    </div>
    <div
      v-if="!isSubtask"
      class="ml-9 sm:ml-12 border-l border-transparent pl-3 sm:pl-4 pb-2 pt-0.5"
    >
      <div v-if="isAddingSubtask" class="flex items-center gap-2 px-2 py-1">
        <Input
          ref="subtaskInputRef"
          v-model:value="subtaskTitle"
          class="min-w-0 flex-1"
          :aria-label="$t('personalTasks.taskDetail.subtaskPlaceholder')"
          :placeholder="$t('personalTasks.taskDetail.subtaskPlaceholder')"
          :disabled="isSavingSubtask"
          data-testid="task-subtask-input"
          @press-enter="handleSubtaskEnter"
          @keydown="handleSubtaskKeydown"
        />
        <Button
          type="primary"
          :disabled="subtaskTitle.length === 0 || isSavingSubtask"
          data-testid="task-subtask-save"
          @click="addSubtask"
        >
          {{ $t('personalTasks.actions.add') }}
        </Button>
        <button
          type="button"
          class="task-icon-button shrink-0 text-muted-foreground"
          :aria-label="$t('personalTasks.quickAdd.cancel')"
          :disabled="isSavingSubtask"
          data-testid="task-subtask-cancel"
          @click="closeSubtaskInput"
        >
          <XIcon class="size-4" />
        </button>
      </div>
      <button
        v-else
        ref="addSubtaskTriggerRef"
        type="button"
        class="task-focus inline-flex min-h-7 items-center gap-1.5 rounded px-2 text-xs font-medium text-muted-foreground hover:text-primary hover:bg-primary/5 transition-colors"
        :aria-label="
          $t('personalTasks.actions.addSubtaskNamed', {
            title: task.title,
          })
        "
        data-testid="task-add-subtask"
        @click="openSubtaskInput"
      >
        <PlusIcon class="size-3.5" aria-hidden="true" />
        {{ $t('personalTasks.taskDetail.addSubtask') }}
      </button>
    </div>
  </div>
</template>
