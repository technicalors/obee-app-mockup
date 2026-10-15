<script setup lang="ts">
import type {
  CompletedPersonalTask,
  PersonalTask,
  PersonalTaskList,
} from '#/api/contracts/personal-tasks';

import { createIconifyIcon } from '@vben/icons';

import { Empty } from 'ant-design-vue';

import { $t } from '#/locales';

import TaskInlineAdd from './task-inline-add.vue';
import TaskItem from './task-item.vue';

defineProps<{
  completedTasks: CompletedPersonalTask[];
  completedTasksId: string;
  isCompletedExpanded: boolean;
  list: PersonalTaskList;
  listsById: Map<string, PersonalTaskList>;
  openTasks: PersonalTask[];
  saveSubtask: (parentId: string, title: string) => Promise<boolean>;
  saveTask: (payload: { listId: string; title: string }) => Promise<boolean>;
  subtasksByParentId: Map<string, PersonalTask[]>;
}>();

const emit = defineEmits<{
  delete: [taskId: string];
  openDetail: [taskId: string];
  toggleCompleted: [];
  toggleStar: [taskId: string];
  toggleStatus: [taskId: string];
}>();

const ChevronDownIcon = createIconifyIcon('lucide:chevron-down');
</script>

<template>
  <section
    class="task-list-column flex h-full min-h-0 w-[min(23rem,calc(100vw-2rem))] shrink-0 snap-start flex-col overflow-hidden rounded-xl border border-border bg-card shadow-xs sm:w-[23rem]"
    data-testid="task-list-column"
    :data-list-id="list.id"
  >
    <header
      class="flex shrink-0 items-center justify-between gap-3 px-4 pb-2 pt-4"
    >
      <h2
        class="m-0 min-w-0 flex-1 truncate text-base font-semibold text-foreground"
      >
        {{ list.title }}
      </h2>
      <span
        class="shrink-0 rounded-full bg-muted px-2 py-0.5 text-xs font-semibold text-muted-foreground tabular-nums"
      >
        {{ openTasks.length }}
      </span>
    </header>

    <div class="shrink-0 px-3 pb-3">
      <TaskInlineAdd
        :can-choose-list="false"
        :list-id="list.id"
        :lists="[list]"
        :save-task="saveTask"
        :show-list-label="false"
      />
    </div>

    <div class="min-h-0 flex-1 overflow-y-auto px-3 pb-3">
      <div
        v-if="openTasks.length > 0 || completedTasks.length > 0"
        class="flex flex-col gap-3"
      >
        <TransitionGroup
          v-if="openTasks.length > 0"
          name="task-list-anim"
          tag="div"
          class="flex flex-col gap-3"
        >
          <TaskItem
            v-for="task in openTasks"
            :key="task.id"
            :task="task"
            :lists-by-id="listsById"
            :subtasks="subtasksByParentId.get(task.id)"
            :save-subtask="saveSubtask"
            :show-list="false"
            @toggle-status="emit('toggleStatus', $event)"
            @toggle-star="emit('toggleStar', $event)"
            @open-detail="emit('openDetail', $event)"
            @delete="emit('delete', $event)"
          />
        </TransitionGroup>

        <section v-if="completedTasks.length > 0" class="flex flex-col gap-3">
          <button
            type="button"
            class="flex w-full items-center justify-between rounded-lg px-3 py-2 text-sm text-muted-foreground transition-colors hover:bg-muted/60"
            :aria-controls="completedTasksId"
            :aria-expanded="isCompletedExpanded"
            data-testid="completed-accordion-toggle"
            @click="emit('toggleCompleted')"
          >
            <span>
              {{
                $t('personalTasks.taskList.completedSection', {
                  count: completedTasks.length,
                })
              }}
            </span>
            <ChevronDownIcon
              class="size-4 transition-transform"
              :class="{ 'rotate-180': isCompletedExpanded }"
              aria-hidden="true"
            />
          </button>
          <TransitionGroup
            v-if="isCompletedExpanded"
            :id="completedTasksId"
            name="task-list-anim"
            tag="div"
            class="flex flex-col gap-3"
          >
            <TaskItem
              v-for="task in completedTasks"
              :key="task.id"
              :task="task"
              :lists-by-id="listsById"
              :subtasks="subtasksByParentId.get(task.id)"
              :save-subtask="saveSubtask"
              :show-list="false"
              @toggle-status="emit('toggleStatus', $event)"
              @toggle-star="emit('toggleStar', $event)"
              @open-detail="emit('openDetail', $event)"
              @delete="emit('delete', $event)"
            />
          </TransitionGroup>
        </section>
      </div>

      <Empty
        v-else
        class="my-10"
        :image-style="{ height: '96px' }"
        :description="$t('personalTasks.taskList.emptyTitle')"
        data-testid="task-list-column-empty"
      />
    </div>
  </section>
</template>
