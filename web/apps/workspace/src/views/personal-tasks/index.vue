<script setup lang="ts">
import type { TaskFilterType } from './use-personal-tasks';

import type {
  CompletedPersonalTask,
  PersonalTask,
  PersonalTaskList,
} from '#/api/contracts/personal-tasks';

import { computed, nextTick, onMounted, ref, useId, watch } from 'vue';

import { Page, useVbenModal } from '@vben/common-ui';
import { createIconifyIcon } from '@vben/icons';
import { usePreferences } from '@vben/preferences';

import {
  Button,
  Drawer,
  Empty,
  Input,
  message,
  Modal,
  Popconfirm,
} from 'ant-design-vue';

import { ApiProblemError } from '#/api/problem';
import { $t } from '#/locales';

import TaskCreateModalComponent from './components/task-create-modal.vue';
import TaskDetailDrawer from './components/task-detail-drawer.vue';
import TaskListColumn from './components/task-list-column.vue';
import TaskSidebar from './components/task-sidebar.vue';
import { getTodayLocalDate, usePersonalTasks } from './use-personal-tasks';

import './personal-tasks.css';

const {
  activeTaskId,
  addTask,
  addSubtask,
  allOpenCount,
  createList,
  deleteList,
  deleteTask,
  isCompletedExpanded,
  isLoadingTasks,
  isStarredFilter,
  isStarredFilterActive,
  isTodayFilter,
  isTodayFilterActive,
  lists,
  listsById,
  searchQuery,
  selectedListId,
  selectedListTitle,
  selectedTask,
  subtasksByParentId,
  taskCountsByListId,
  toggleStar,
  toggleStarredFilter,
  toggleTaskStatus,
  toggleTodayFilter,
  visibleCompletedTasks,
  loadPersonalTasks,
  updateList,
  updateTask,
  visibleOpenTasks,
} = usePersonalTasks();

onMounted(() => {
  void initializePersonalTasks();
});

async function initializePersonalTasks(): Promise<void> {
  try {
    await loadPersonalTasks();
  } catch {
    message.error($t('personalTasks.requestFailed'));
  }
}

async function runMutation(action: () => Promise<void>): Promise<boolean> {
  try {
    await action();
    return true;
  } catch (error) {
    message.error(
      error instanceof ApiProblemError
        ? error.problem.detail
        : $t('personalTasks.requestFailed'),
    );
    return false;
  }
}

const { isMobile } = usePreferences();
const [CreateTaskModal, createTaskModalApi] = useVbenModal({
  connectedComponent: TaskCreateModalComponent,
});
const isSidebarOpen = ref(!isMobile.value);
const hiddenListIds = ref(new Set<string>());

watch(isMobile, (mobile) => {
  isSidebarOpen.value = !mobile;
});

function selectList(listId: TaskFilterType): void {
  if (listsById.value.has(listId) && hiddenListIds.value.has(listId)) {
    const nextHiddenListIds = new Set(hiddenListIds.value);
    nextHiddenListIds.delete(listId);
    hiddenListIds.value = nextHiddenListIds;
  }
  selectedListId.value = listId;
  isTodayFilter.value = false;
  isStarredFilter.value = false;
  if (isMobile.value) isSidebarOpen.value = false;
}

function openCreateModal(): void {
  if (isMobile.value) isSidebarOpen.value = false;
  createTaskModalApi.setData({
    isStarredFilterActive: isStarredFilterActive.value,
    lists: lists.value,
    saveTask: (payload: Parameters<typeof addTask>[0]) =>
      runMutation(() => addTask(payload)),
    selectedListId: selectedListId.value,
  });
  createTaskModalApi.open();
}

const SearchIcon = createIconifyIcon('lucide:search');
const PanelOpenIcon = createIconifyIcon('lucide:panel-left-open');
const PanelCloseIcon = createIconifyIcon('lucide:panel-left-close');
const CalendarIcon = createIconifyIcon('lucide:calendar');
const StarIcon = createIconifyIcon('lucide:star');
const EditIcon = createIconifyIcon('lucide:pencil');
const TrashIcon = createIconifyIcon('lucide:trash-2');
let detailTrigger: HTMLElement | null = null;

const selectedCustomList = computed<null | PersonalTaskList>(() => {
  if (selectedListId.value === 'all') return null;
  return listsById.value.get(selectedListId.value) ?? null;
});

interface PersonalTaskGroup {
  completedTasks: CompletedPersonalTask[];
  list: PersonalTaskList;
  openTasks: PersonalTask[];
}

const visibleListIds = computed(
  () =>
    new Set(
      lists.value
        .filter((list) => !hiddenListIds.value.has(list.id))
        .map((list) => list.id),
    ),
);
const visibleTaskGroups = computed<PersonalTaskGroup[]>(() => {
  const visibleLists = selectedCustomList.value
    ? [selectedCustomList.value]
    : lists.value.filter((list) => visibleListIds.value.has(list.id));

  return visibleLists.map((list) => ({
    completedTasks: visibleCompletedTasks.value.filter(
      (task) => task.task_list_id === list.id,
    ),
    list,
    openTasks: visibleOpenTasks.value.filter(
      (task) => task.task_list_id === list.id,
    ),
  }));
});
const visibleGroupedOpenCount = computed(() =>
  visibleTaskGroups.value.reduce(
    (count, group) => count + group.openTasks.length,
    0,
  ),
);
const visibleGroupedTaskCount = computed(() =>
  visibleTaskGroups.value.reduce(
    (count, group) =>
      count + group.openTasks.length + group.completedTasks.length,
    0,
  ),
);

function toggleListVisibility(listId: string): void {
  const nextHiddenListIds = new Set(hiddenListIds.value);
  if (nextHiddenListIds.has(listId)) {
    nextHiddenListIds.delete(listId);
  } else {
    nextHiddenListIds.add(listId);
  }
  hiddenListIds.value = nextHiddenListIds;

  if (nextHiddenListIds.has(listId) && selectedListId.value === listId) {
    selectList('all');
  }
}

const renameFieldId = useId();
const completedTasksId = useId();
const isRenamingList = ref(false);
const editingListName = ref('');

function openRenameList(list: PersonalTaskList): void {
  editingListName.value = list.title;
  isRenamingList.value = true;
}

async function handleSaveListName(): Promise<void> {
  const title = editingListName.value.trim();
  if (selectedCustomList.value && title.length > 0) {
    const listId = selectedCustomList.value.id;
    await runMutation(() => updateList(listId, title));
    isRenamingList.value = false;
    editingListName.value = '';
  }
}

function cancelRenameList(): void {
  isRenamingList.value = false;
  editingListName.value = '';
}

const displayTitle = computed(() => {
  if (selectedListTitle.value === 'all') {
    return $t('personalTasks.lists.all');
  }
  if (selectedListTitle.value === 'starred') {
    return $t('personalTasks.lists.starred');
  }
  if (selectedListTitle.value === 'today') {
    return $t('personalTasks.lists.today');
  }
  return selectedListTitle.value;
});

const isDetailDrawerOpen = computed(() => activeTaskId.value !== null);

function openDetail(taskId: string): void {
  detailTrigger =
    document.activeElement instanceof HTMLElement
      ? document.activeElement
      : null;
  activeTaskId.value = taskId;
}

async function closeDetail(): Promise<void> {
  activeTaskId.value = null;
  await nextTick();
  detailTrigger?.focus();
}
</script>

<template>
  <Page
    auto-content-height
    content-class="h-full !p-0 overflow-hidden"
    class="h-full"
  >
    <div
      class="personal-tasks-ui flex h-full min-w-0 w-full overflow-hidden bg-background"
      data-testid="personal-tasks-page"
    >
      <div
        v-if="!isMobile"
        class="h-full shrink-0 overflow-hidden border-border transition-[width] duration-200 ease-out"
        :class="isSidebarOpen ? 'w-64 border-r' : 'w-0'"
        data-testid="task-sidebar-panel"
        :aria-hidden="!isSidebarOpen"
        :inert="!isSidebarOpen"
      >
        <div class="h-full w-64">
          <TaskSidebar
            :all-open-count="allOpenCount"
            :hidden-list-ids="hiddenListIds"
            :lists="lists"
            :selected-list-id="selectedListId"
            :task-counts-by-list-id="taskCountsByListId"
            @create-list="(title) => runMutation(() => createList(title))"
            @create-task="openCreateModal"
            @select-list="selectList"
            @toggle-list-visibility="toggleListVisibility"
          />
        </div>
      </div>
      <Drawer
        v-else
        :open="isSidebarOpen"
        placement="left"
        :width="280"
        :closable="false"
        root-class-name="personal-tasks-ui"
        :body-style="{ padding: 0 }"
        @close="isSidebarOpen = false"
      >
        <TaskSidebar
          :all-open-count="allOpenCount"
          :hidden-list-ids="hiddenListIds"
          :lists="lists"
          :selected-list-id="selectedListId"
          :task-counts-by-list-id="taskCountsByListId"
          @create-list="(title) => runMutation(() => createList(title))"
          @create-task="openCreateModal"
          @select-list="selectList"
          @toggle-list-visibility="toggleListVisibility"
        />
      </Drawer>
      <main
        class="flex min-w-0 flex-1 flex-col h-full overflow-hidden bg-background"
      >
        <header
          class="flex shrink-0 flex-wrap items-center justify-between gap-3 border-b border-border bg-card p-4"
        >
          <div class="flex min-w-0 flex-1 items-center gap-2 sm:gap-3">
            <button
              type="button"
              class="task-icon-button -ml-1 shrink-0 text-muted-foreground hover:text-foreground"
              :aria-expanded="isSidebarOpen"
              :aria-label="
                $t(
                  isSidebarOpen
                    ? 'personalTasks.sidebar.close'
                    : 'personalTasks.sidebar.open',
                )
              "
              :title="
                $t(
                  isSidebarOpen
                    ? 'personalTasks.sidebar.close'
                    : 'personalTasks.sidebar.open',
                )
              "
              data-testid="sidebar-toggle"
              @click="isSidebarOpen = !isSidebarOpen"
            >
              <PanelCloseIcon v-if="isSidebarOpen" class="size-4" />
              <PanelOpenIcon v-else class="size-4" />
            </button>
            <h1
              class="m-0 min-w-0 truncate text-lg font-semibold text-foreground"
            >
              {{ displayTitle }}
            </h1>
            <span
              class="shrink-0 whitespace-nowrap rounded-full bg-muted px-2 py-0.5 text-xs font-semibold text-muted-foreground"
            >
              {{
                $t('personalTasks.lists.openCount', {
                  count: visibleGroupedOpenCount,
                })
              }}
            </span>

            <template v-if="selectedCustomList">
              <button
                type="button"
                class="task-focus flex size-7 items-center justify-center rounded text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
                :aria-label="
                  $t('personalTasks.lists.renameList', {
                    title: selectedCustomList.title,
                  })
                "
                :title="
                  $t('personalTasks.lists.renameList', {
                    title: selectedCustomList.title,
                  })
                "
                data-testid="rename-list-trigger"
                @click="openRenameList(selectedCustomList)"
              >
                <EditIcon class="size-4" />
              </button>

              <Popconfirm
                v-if="!selectedCustomList.is_default"
                :title="$t('personalTasks.lists.deleteConfirm')"
                :ok-text="$t('personalTasks.actions.delete')"
                :cancel-text="$t('personalTasks.quickAdd.cancel')"
                @confirm="runMutation(() => deleteList(selectedCustomList!.id))"
              >
                <button
                  type="button"
                  class="task-focus flex size-7 items-center justify-center rounded text-muted-foreground transition-colors hover:bg-muted hover:text-destructive"
                  :aria-label="
                    $t('personalTasks.lists.deleteList', {
                      title: selectedCustomList.title,
                    })
                  "
                  :title="
                    $t('personalTasks.lists.deleteList', {
                      title: selectedCustomList.title,
                    })
                  "
                  data-testid="delete-list-trigger"
                >
                  <TrashIcon class="size-4" />
                </button>
              </Popconfirm>
            </template>
          </div>

          <div
            class="flex w-full min-w-0 items-center gap-2 sm:w-auto sm:gap-3"
          >
            <Button
              :type="isTodayFilterActive ? 'primary' : 'default'"
              size="middle"
              class="shrink-0 flex items-center gap-1.5"
              :aria-label="$t('personalTasks.filters.today')"
              :title="$t('personalTasks.filters.today')"
              data-testid="today-filter-button"
              :aria-pressed="isTodayFilterActive"
              @click="toggleTodayFilter"
            >
              <template #icon>
                <CalendarIcon class="size-3.5" />
              </template>
              <span class="hidden sm:inline">{{
                $t('personalTasks.filters.today')
              }}</span>
            </Button>

            <Button
              :type="isStarredFilterActive ? 'primary' : 'default'"
              size="middle"
              class="shrink-0 flex items-center gap-1.5"
              :aria-label="$t('personalTasks.filters.starred')"
              :title="$t('personalTasks.filters.starred')"
              data-testid="starred-filter-button"
              :aria-pressed="isStarredFilterActive"
              @click="toggleStarredFilter"
            >
              <template #icon>
                <StarIcon class="size-3.5" />
              </template>
              <span class="hidden sm:inline">{{
                $t('personalTasks.filters.starred')
              }}</span>
            </Button>

            <div class="min-w-0 flex-1 sm:w-60 sm:flex-none">
              <Input
                v-model:value="searchQuery"
                size="middle"
                :aria-label="$t('personalTasks.filters.search')"
                :placeholder="$t('personalTasks.filters.searchPlaceholder')"
                data-testid="task-search"
                allow-clear
              >
                <template #prefix>
                  <SearchIcon class="size-3.5 text-muted-foreground" />
                </template>
              </Input>
            </div>
          </div>
        </header>
        <div
          class="min-h-0 flex-1 overflow-hidden bg-muted p-4"
          data-testid="task-board"
        >
          <div
            v-if="isLoadingTasks"
            class="my-12 text-center text-sm text-muted-foreground"
            role="status"
          >
            {{ $t('personalTasks.taskList.loading') }}
          </div>
          <p
            v-else-if="lists.length === 0"
            class="m-0 rounded-lg border border-dashed border-border px-4 py-3 text-sm text-muted-foreground"
          >
            {{ $t('personalTasks.lists.noListsHint') }}
          </p>
          <p
            v-else-if="visibleTaskGroups.length === 0"
            class="m-0 rounded-lg border border-dashed border-border bg-card px-4 py-3 text-sm text-muted-foreground"
            data-testid="task-no-visible-lists"
          >
            {{ $t('personalTasks.lists.noVisibleListsHint') }}
          </p>
          <div
            v-else-if="searchQuery.length === 0 || visibleGroupedTaskCount > 0"
            class="flex h-full min-w-0 snap-x snap-mandatory gap-4 overflow-x-auto overflow-y-hidden pb-2"
            data-testid="task-list"
          >
            <TaskListColumn
              v-for="group in visibleTaskGroups"
              :key="group.list.id"
              :list="group.list"
              :open-tasks="group.openTasks"
              :completed-tasks="group.completedTasks"
              :completed-tasks-id="`${completedTasksId}-${group.list.id}`"
              :is-completed-expanded="isCompletedExpanded"
              :lists-by-id="listsById"
              :subtasks-by-parent-id="subtasksByParentId"
              :save-subtask="
                (parentId, title) =>
                  runMutation(() => addSubtask(parentId, title))
              "
              :save-task="
                ({ listId, title }) =>
                  runMutation(() =>
                    addTask({
                      dueDate: isTodayFilterActive ? getTodayLocalDate() : null,
                      dueTime: isTodayFilterActive ? '17:00' : null,
                      listId,
                      notes: null,
                      recurrence: null,
                      starred: isStarredFilterActive,
                      title,
                    }),
                  )
              "
              :save-due-date="
                (taskId, dueDate, dueTime) =>
                  runMutation(() => updateTask(taskId, { dueDate, dueTime }))
              "
              @toggle-completed="isCompletedExpanded = !isCompletedExpanded"
              @toggle-status="(id) => runMutation(() => toggleTaskStatus(id))"
              @toggle-star="(id) => runMutation(() => toggleStar(id))"
              @open-detail="openDetail"
              @delete="(id) => runMutation(() => deleteTask(id))"
            />
          </div>
          <Empty
            v-else
            class="my-16"
            :image-style="{ height: '160px' }"
            data-testid="task-empty-state"
          >
            <template #description>
              <span class="text-base text-muted-foreground">
                {{ $t('personalTasks.taskList.noResultsTitle') }}
              </span>
            </template>
            <Button data-testid="clear-search-button" @click="searchQuery = ''">
              {{ $t('personalTasks.filters.clearSearch') }}
            </Button>
          </Empty>
        </div>
      </main>
    </div>

    <CreateTaskModal />

    <TaskDetailDrawer
      :open="isDetailDrawerOpen"
      :task="selectedTask"
      :lists="lists"
      :subtasks="
        selectedTask ? (subtasksByParentId.get(selectedTask.id) ?? []) : []
      "
      @close="closeDetail"
      @toggle-status="(id) => runMutation(() => toggleTaskStatus(id))"
      @toggle-star="(id) => runMutation(() => toggleStar(id))"
      @update="(id, payload) => runMutation(() => updateTask(id, payload))"
      @delete="(id) => runMutation(() => deleteTask(id))"
      @add-subtask="(id, title) => runMutation(() => addSubtask(id, title))"
      @toggle-subtask-status="(id) => runMutation(() => toggleTaskStatus(id))"
      @delete-subtask="(id) => runMutation(() => deleteTask(id))"
    />

    <Modal
      :open="isRenamingList"
      root-class-name="personal-tasks-ui"
      :title="$t('personalTasks.lists.renameListTitle')"
      :ok-button-props="{ disabled: !editingListName.trim() }"
      :ok-text="$t('personalTasks.actions.save')"
      :cancel-text="$t('personalTasks.quickAdd.cancel')"
      @ok="handleSaveListName"
      @cancel="cancelRenameList"
    >
      <div class="py-4 flex flex-col gap-2">
        <label :for="renameFieldId" class="task-label">
          {{ $t('personalTasks.lists.name') }}
        </label>
        <Input
          :id="renameFieldId"
          v-model:value="editingListName"
          size="middle"
          class="rounded-lg"
          :placeholder="$t('personalTasks.lists.namePlaceholder')"
          auto-focus
          @press-enter="
            (event: KeyboardEvent) => {
              if (!event.isComposing && event.keyCode !== 229)
                handleSaveListName();
            }
          "
        />
      </div>
    </Modal>
  </Page>
</template>
