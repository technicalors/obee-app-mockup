<script setup lang="ts">
import type {
  PersonalTask,
  PersonalTaskList,
} from '#/api/contracts/personal-tasks';

import { ref, useId, watch } from 'vue';

import { createIconifyIcon } from '@vben/icons';

import {
  Button,
  DatePicker,
  Drawer,
  Input,
  Popconfirm,
  Select,
  Textarea,
} from 'ant-design-vue';

import { $t } from '#/locales';

const props = defineProps<{
  lists: PersonalTaskList[];
  open: boolean;
  subtasks: PersonalTask[];
  task: null | PersonalTask;
}>();
const emit = defineEmits<{
  addSubtask: [parentId: string, title: string];
  close: [];
  delete: [taskId: string];
  deleteSubtask: [subtaskId: string];
  toggleStar: [taskId: string];
  toggleStatus: [taskId: string];
  toggleSubtaskStatus: [subtaskId: string];
  update: [
    taskId: string,
    updates: {
      dueDate?: null | string;
      notes?: null | string;
      starred?: boolean;
      taskListId?: string;
      title?: string;
    },
  ];
}>();
const CheckIcon = createIconifyIcon('lucide:check');
const StarIcon = createIconifyIcon('lucide:star');
const PlusIcon = createIconifyIcon('lucide:plus');
const TrashIcon = createIconifyIcon('lucide:trash-2');
const fieldId = useId();
const editableTitle = ref('');
const editableNotes = ref('');
const editableDueDate = ref<string>();
const editableListId = ref('');
const newSubtaskTitle = ref('');

watch(
  () => props.task,
  (newTask) => {
    newSubtaskTitle.value = '';
    if (newTask) {
      editableTitle.value = newTask.title;
      editableNotes.value = newTask.notes ?? '';
      editableDueDate.value = newTask.due_date ?? undefined;
      editableListId.value = newTask.task_list_id;
    }
  },
  { immediate: true },
);

function handleFieldBlur(): void {
  if (!props.task) return;
  emit('update', props.task.id, {
    dueDate: editableDueDate.value ?? null,
    notes: editableNotes.value.trim() || null,
    taskListId: editableListId.value,
    title: editableTitle.value.trim() || props.task.title,
  });
}

function handleTitleEnter(event: KeyboardEvent): void {
  if (!event.isComposing && event.keyCode !== 229) handleFieldBlur();
}

function handleAddSubtask(event?: KeyboardEvent): void {
  if (event?.isComposing || event?.keyCode === 229) return;
  if (props.task && newSubtaskTitle.value.trim()) {
    emit('addSubtask', props.task.id, newSubtaskTitle.value);
    newSubtaskTitle.value = '';
  }
}

function handleSaveAndClose(): void {
  if (!props.task) return;
  const title = editableTitle.value.trim() || props.task.title;
  const listId = editableListId.value || props.task.task_list_id;
  emit('update', props.task.id, {
    dueDate: editableDueDate.value ?? null,
    notes: editableNotes.value.trim() || null,
    taskListId: listId,
    title,
  });
  emit('close');
}

function handleCancel(): void {
  if (props.task) {
    editableTitle.value = props.task.title;
    editableNotes.value = props.task.notes ?? '';
    editableDueDate.value = props.task.due_date ?? undefined;
    editableListId.value = props.task.task_list_id;
  }
  emit('close');
}
</script>

<template>
  <Drawer
    :open="open"
    width="min(580px, 100vw)"
    placement="right"
    root-class-name="personal-tasks-ui"
    :title="$t('personalTasks.taskDetail.title')"
    @close="emit('close')"
  >
    <div v-if="task" class="flex min-w-0 flex-col gap-5">
      <div
        class="flex items-center justify-between gap-3 rounded-xl border border-border/70 bg-muted/40 p-2.5 sm:p-3"
      >
        <button
          type="button"
          class="task-focus flex min-h-8 items-center gap-2 rounded-md px-1 text-sm font-medium transition-colors hover:text-primary"
          :aria-pressed="task.status === 'completed'"
          :aria-label="
            $t(
              task.status === 'completed'
                ? 'personalTasks.actions.markOpen'
                : 'personalTasks.actions.markCompleted',
              { title: task.title },
            )
          "
          @click="emit('toggleStatus', task.id)"
        >
          <span
            class="flex size-5 items-center justify-center rounded-full border-2 transition-all duration-150 active:scale-75"
            :class="
              task.status === 'completed'
                ? 'border-primary bg-primary text-primary-foreground'
                : 'border-muted-foreground/60 hover:border-primary'
            "
          >
            <CheckIcon
              v-if="task.status === 'completed'"
              class="size-3 stroke-[2.5]"
            />
          </span>
          <span
            :class="
              task.status === 'completed'
                ? 'text-muted-foreground line-through'
                : 'text-foreground'
            "
          >
            {{
              $t(
                task.status === 'completed'
                  ? 'personalTasks.taskStatus.completed'
                  : 'personalTasks.taskStatus.needsAction',
              )
            }}
          </span>
        </button>
        <div class="flex items-center gap-1">
          <button
            type="button"
            class="task-icon-button"
            :class="
              task.extension.starred
                ? 'text-amber-600 dark:text-amber-400'
                : 'text-muted-foreground/60 hover:text-muted-foreground'
            "
            :aria-pressed="task.extension.starred"
            :aria-label="
              $t(
                task.extension.starred
                  ? 'personalTasks.actions.removeStar'
                  : 'personalTasks.actions.star',
                { title: task.title },
              )
            "
            @click="emit('toggleStar', task.id)"
          >
            <StarIcon
              class="size-4"
              :class="{ 'fill-current': task.extension.starred }"
            />
          </button>
        </div>
      </div>

      <div class="flex flex-col gap-1.5">
        <label :for="`${fieldId}-title`" class="task-label">
          {{ $t('personalTasks.taskDetail.title') }}
          <span class="task-required">*</span>
        </label>
        <Input
          :id="`${fieldId}-title`"
          v-model:value="editableTitle"
          :placeholder="$t('personalTasks.taskDetail.titlePlaceholder')"
          data-testid="detail-title-input"
          @blur="handleFieldBlur"
          @press-enter="handleTitleEnter"
        />
      </div>

      <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
        <div class="flex min-w-0 flex-col gap-1.5">
          <label :for="`${fieldId}-list`" class="task-label">
            {{ $t('personalTasks.taskDetail.list') }}
            <span class="task-required">*</span>
          </label>
          <Select
            :id="`${fieldId}-list`"
            v-model:value="editableListId"
            class="w-full"
            :aria-label="$t('personalTasks.taskDetail.list')"
            data-testid="detail-list-input"
            @change="handleFieldBlur"
          >
            <Select.Option
              v-for="item in lists"
              :key="item.id"
              :value="item.id"
            >
              {{ item.title }}
            </Select.Option>
          </Select>
        </div>
        <div class="flex min-w-0 flex-col gap-1.5">
          <label :for="`${fieldId}-date`" class="task-label">
            {{ $t('personalTasks.taskDetail.dueDate') }}
          </label>
          <DatePicker
            :id="`${fieldId}-date`"
            v-model:value="editableDueDate"
            format="YYYY-MM-DD"
            value-format="YYYY-MM-DD"
            allow-clear
            class="w-full"
            :placeholder="$t('personalTasks.taskDetail.dueDatePlaceholder')"
            data-testid="detail-date-input"
            @change="handleFieldBlur"
          />
        </div>
      </div>

      <div class="flex flex-col gap-1.5">
        <label :for="`${fieldId}-notes`" class="task-label">
          {{ $t('personalTasks.taskDetail.notes') }}
        </label>
        <Textarea
          :id="`${fieldId}-notes`"
          v-model:value="editableNotes"
          :auto-size="{ minRows: 4, maxRows: 8 }"
          :placeholder="$t('personalTasks.taskDetail.notesPlaceholder')"
          data-testid="detail-notes-input"
          @blur="handleFieldBlur"
        />
      </div>

      <section
        class="flex flex-col gap-3 border-t border-border/70 pt-4"
        :aria-labelledby="`${fieldId}-subtasks`"
      >
        <div class="flex items-center justify-between">
          <h3
            :id="`${fieldId}-subtasks`"
            class="m-0 text-sm font-semibold text-foreground flex items-center gap-1.5"
          >
            <span>{{ $t('personalTasks.taskDetail.subtasks') }}</span>
            <span
              class="rounded-full bg-muted px-2 py-0.5 text-xs font-medium text-muted-foreground"
            >
              {{ subtasks.length }}
            </span>
          </h3>
        </div>

        <div v-if="subtasks.length > 0" class="flex flex-col gap-1">
          <div
            v-for="sub in subtasks"
            :key="sub.id"
            class="flex items-center gap-2 rounded-lg px-2 py-1.5 transition-colors hover:bg-muted/50 focus-within:bg-muted/50"
          >
            <button
              type="button"
              class="task-icon-button shrink-0 !size-6 !min-h-6"
              :aria-pressed="sub.status === 'completed'"
              :aria-label="
                $t(
                  sub.status === 'completed'
                    ? 'personalTasks.actions.markOpen'
                    : 'personalTasks.actions.markCompleted',
                  { title: sub.title },
                )
              "
              @click="emit('toggleSubtaskStatus', sub.id)"
            >
              <span
                class="flex size-4 items-center justify-center rounded-full border transition-all duration-150 active:scale-75"
                :class="
                  sub.status === 'completed'
                    ? 'border-primary bg-primary text-primary-foreground'
                    : 'border-muted-foreground/60 hover:border-primary'
                "
              >
                <CheckIcon
                  v-if="sub.status === 'completed'"
                  class="size-2.5 stroke-[2.5]"
                />
              </span>
            </button>
            <span
              class="min-w-0 flex-1 break-words text-sm leading-5"
              :class="
                sub.status === 'completed'
                  ? 'text-muted-foreground line-through'
                  : 'text-foreground'
              "
            >
              {{ sub.title }}
            </span>
            <Popconfirm
              :title="$t('personalTasks.taskDetail.deleteConfirm')"
              :ok-text="$t('personalTasks.actions.delete')"
              :cancel-text="$t('personalTasks.quickAdd.cancel')"
              @confirm="emit('deleteSubtask', sub.id)"
            >
              <button
                type="button"
                class="task-icon-button text-muted-foreground/60 hover:text-rose-600"
                :aria-label="
                  $t('personalTasks.actions.deleteNamed', {
                    title: sub.title,
                  })
                "
                data-testid="detail-subtask-delete"
              >
                <TrashIcon class="size-3.5" />
              </button>
            </Popconfirm>
          </div>
        </div>

        <div class="flex flex-col gap-1.5 pt-1">
          <label :for="`${fieldId}-new-subtask`" class="task-label">
            {{ $t('personalTasks.taskDetail.addSubtask') }}
          </label>
          <div class="flex gap-2">
            <Input
              :id="`${fieldId}-new-subtask`"
              v-model:value="newSubtaskTitle"
              class="min-w-0 flex-1"
              :placeholder="$t('personalTasks.taskDetail.subtaskPlaceholder')"
              @press-enter="handleAddSubtask"
            >
              <template #prefix>
                <PlusIcon class="size-4 text-muted-foreground/60" />
              </template>
            </Input>
            <Button
              type="primary"
              :disabled="!newSubtaskTitle.trim()"
              @click="handleAddSubtask()"
            >
              {{ $t('personalTasks.actions.add') }}
            </Button>
          </div>
        </div>
      </section>
    </div>

    <template #footer>
      <div v-if="task" class="flex items-center justify-end gap-2.5 px-2 py-1">
        <Button data-testid="detail-cancel-button" @click="handleCancel">
          {{ $t('personalTasks.quickAdd.cancel') }}
        </Button>
        <Popconfirm
          :title="$t('personalTasks.taskDetail.deleteConfirm')"
          :ok-text="$t('personalTasks.actions.delete')"
          :cancel-text="$t('personalTasks.quickAdd.cancel')"
          @confirm="emit('delete', task.id)"
        >
          <Button
            danger
            class="!border-rose-500 !text-rose-500 hover:!border-rose-600 hover:!text-rose-600 !bg-card"
            :aria-label="
              $t('personalTasks.actions.deleteNamed', {
                title: task.title,
              })
            "
            data-testid="detail-delete-button"
          >
            {{ $t('personalTasks.actions.delete') }}
          </Button>
        </Popconfirm>
        <Button
          type="primary"
          :disabled="!editableTitle.trim() || !editableListId"
          data-testid="detail-save-button"
          @click="handleSaveAndClose"
        >
          {{ $t('personalTasks.actions.save') }}
        </Button>
      </div>
    </template>
  </Drawer>
</template>
