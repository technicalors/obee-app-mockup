import type {
  CompletedPersonalTask,
  PersonalTask,
  PersonalTaskList,
  PersonalTaskRecurrence,
} from '#/api/contracts/personal-tasks';

import { computed, ref } from 'vue';

import {
  createPersonalTaskApi,
  createTaskListApi,
  deletePersonalTaskApi,
  deleteTaskListApi,
  getPersonalTasksApi,
  movePersonalTaskApi,
  updatePersonalTaskApi,
  updateTaskListApi,
} from '#/api/personal-tasks';

export type TaskFilterType = 'all' | 'starred' | 'today' | string;

export function getTodayLocalDate(): string {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const day = String(now.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

export function compareOpenTasks(a: PersonalTask, b: PersonalTask): number {
  if (a.extension.starred !== b.extension.starred) {
    return a.extension.starred ? -1 : 1;
  }
  if (a.due_date !== b.due_date) {
    if (a.due_date === null) return 1;
    if (b.due_date === null) return -1;
    return a.due_date.localeCompare(b.due_date);
  }
  if (a.due_date !== null && a.due_time !== b.due_time) {
    return (a.due_time ?? '17:00').localeCompare(b.due_time ?? '17:00');
  }
  return a.position - b.position;
}

export function compareCompletedTasks(
  a: CompletedPersonalTask,
  b: CompletedPersonalTask,
): number {
  return b.completed_at.localeCompare(a.completed_at);
}

export function usePersonalTasks() {
  const lists = ref<PersonalTaskList[]>([]);
  const tasks = ref<PersonalTask[]>([]);
  const selectedListId = ref<TaskFilterType>('all');
  const searchQuery = ref('');
  const isLoadingTasks = ref(true);
  const activeTaskId = ref<null | string>(null);
  const isCompletedExpanded = ref(false);
  const isTodayFilter = ref(false);
  const isStarredFilter = ref(false);

  const isTodayFilterActive = computed(
    () => isTodayFilter.value || selectedListId.value === 'today',
  );
  const isStarredFilterActive = computed(
    () => isStarredFilter.value || selectedListId.value === 'starred',
  );
  const listsById = computed(
    () => new Map(lists.value.map((list) => [list.id, list])),
  );
  const taskCountsByListId = computed(() => {
    const counts = new Map<string, number>();
    for (const task of tasks.value) {
      if (task.status === 'needsAction' && task.parent_id === null) {
        counts.set(task.task_list_id, (counts.get(task.task_list_id) ?? 0) + 1);
      }
    }
    return counts;
  });
  const taskTotalsByListId = computed(() => {
    const counts = new Map<string, number>();
    for (const task of tasks.value) {
      counts.set(task.task_list_id, (counts.get(task.task_list_id) ?? 0) + 1);
    }
    return counts;
  });
  const starredCount = computed(
    () =>
      tasks.value.filter(
        (task) =>
          task.status === 'needsAction' &&
          task.parent_id === null &&
          task.extension.starred,
      ).length,
  );
  const todayOpenCount = computed(
    () =>
      tasks.value.filter(
        (task) =>
          task.status === 'needsAction' &&
          task.parent_id === null &&
          task.due_date === getTodayLocalDate(),
      ).length,
  );
  const allOpenCount = computed(
    () =>
      tasks.value.filter(
        (task) => task.status === 'needsAction' && task.parent_id === null,
      ).length,
  );
  const subtasksByParentId = computed(() => {
    const map = new Map<string, PersonalTask[]>();
    for (const task of tasks.value) {
      if (task.parent_id !== null) {
        const existing = map.get(task.parent_id) ?? [];
        existing.push(task);
        map.set(task.parent_id, existing);
      }
    }
    return map;
  });
  const selectedListTitle = computed(() => {
    if (selectedListId.value === 'all') return 'all';
    if (selectedListId.value === 'starred') return 'starred';
    if (selectedListId.value === 'today') return 'today';
    return listsById.value.get(selectedListId.value)?.title ?? 'all';
  });

  function filterTask(task: PersonalTask): boolean {
    if (task.parent_id !== null) return false;
    const isDueToday = task.due_date === getTodayLocalDate();
    if (selectedListId.value === 'starred') {
      if (!task.extension.starred) return false;
    } else if (selectedListId.value === 'today') {
      if (!isDueToday) return false;
    } else if (
      selectedListId.value !== 'all' &&
      task.task_list_id !== selectedListId.value
    ) {
      return false;
    }
    if (isTodayFilter.value && !isDueToday) return false;
    if (isStarredFilter.value && !task.extension.starred) return false;
    const query = searchQuery.value.trim().toLocaleLowerCase();
    if (query.length > 0) {
      const matchTitle = task.title.toLocaleLowerCase().includes(query);
      const matchNotes =
        task.notes !== null && task.notes.toLocaleLowerCase().includes(query);
      if (!matchTitle && !matchNotes) return false;
    }
    return true;
  }

  const visibleOpenTasks = computed(() =>
    tasks.value
      .filter((task) => filterTask(task) && task.status === 'needsAction')
      .toSorted(compareOpenTasks),
  );
  const visibleCompletedTasks = computed(() =>
    tasks.value
      .filter(
        (task): task is CompletedPersonalTask =>
          task.status === 'completed' && filterTask(task),
      )
      .toSorted(compareCompletedTasks),
  );
  const selectedTask = computed(
    () => tasks.value.find((task) => task.id === activeTaskId.value) ?? null,
  );

  async function loadPersonalTasks(): Promise<void> {
    try {
      const data = await getPersonalTasksApi();
      lists.value = data.lists;
      tasks.value = data.tasks;
    } finally {
      isLoadingTasks.value = false;
    }
  }

  function toggleTodayFilter(): void {
    if (selectedListId.value === 'today') {
      selectedListId.value = 'all';
      isTodayFilter.value = false;
    } else {
      isTodayFilter.value = !isTodayFilter.value;
    }
  }

  function toggleStarredFilter(): void {
    if (selectedListId.value === 'starred') {
      selectedListId.value = 'all';
      isStarredFilter.value = false;
    } else {
      isStarredFilter.value = !isStarredFilter.value;
    }
  }

  function findTask(taskId: string): PersonalTask {
    const task = tasks.value.find((item) => item.id === taskId);
    if (task === undefined) throw new Error(`Task ${taskId} is not loaded`);
    return task;
  }

  async function toggleTaskStatus(taskId: string): Promise<void> {
    const task = findTask(taskId);
    await updatePersonalTaskApi(taskId, {
      status: task.status === 'needsAction' ? 'completed' : 'needsAction',
    });
    await loadPersonalTasks();
  }

  async function toggleStar(taskId: string): Promise<void> {
    const task = findTask(taskId);
    await updatePersonalTaskApi(taskId, { starred: !task.extension.starred });
    await loadPersonalTasks();
  }

  async function addTask(payload: {
    dueDate: null | string;
    dueTime: null | string;
    listId: string;
    notes: null | string;
    recurrence: null | PersonalTaskRecurrence;
    starred: boolean;
    title: string;
  }): Promise<void> {
    await createPersonalTaskApi({
      due_date: payload.dueDate,
      due_time: payload.dueTime,
      notes: payload.notes,
      parent_id: null,
      recurrence: payload.recurrence,
      starred: payload.starred,
      status: 'needsAction',
      task_list_id: payload.listId,
      title: payload.title,
    });
    await loadPersonalTasks();
  }

  async function addSubtask(parentId: string, title: string): Promise<void> {
    const parent = tasks.value.find((task) => task.id === parentId);
    if (parent) {
      await createPersonalTaskApi({
        due_date: null,
        due_time: null,
        notes: null,
        parent_id: parent.id,
        recurrence: null,
        starred: false,
        status: 'needsAction',
        task_list_id: parent.task_list_id,
        title,
      });
      await loadPersonalTasks();
    }
  }

  async function updateTask(
    taskId: string,
    updates: {
      dueDate?: null | string;
      dueTime?: null | string;
      notes?: null | string;
      starred?: boolean;
      taskListId?: string;
      title?: string;
    },
  ): Promise<void> {
    const { taskListId, ...content } = updates;
    if (Object.keys(content).length > 0) {
      await updatePersonalTaskApi(taskId, {
        ...(content.dueDate === undefined ? {} : { due_date: content.dueDate }),
        ...(content.dueTime === undefined ? {} : { due_time: content.dueTime }),
        ...(content.notes === undefined ? {} : { notes: content.notes }),
        ...(content.starred === undefined ? {} : { starred: content.starred }),
        ...(content.title === undefined ? {} : { title: content.title }),
      });
    }
    if (
      taskListId !== undefined &&
      taskListId !== findTask(taskId).task_list_id
    ) {
      await movePersonalTaskApi(taskId, { task_list_id: taskListId });
    }
    await loadPersonalTasks();
  }

  async function deleteTask(taskId: string): Promise<void> {
    await deletePersonalTaskApi(taskId);
    if (activeTaskId.value === taskId) activeTaskId.value = null;
    await loadPersonalTasks();
  }

  async function createList(title: string): Promise<void> {
    const list = await createTaskListApi(title);
    lists.value.push(list);
    selectedListId.value = list.id;
  }

  async function updateList(listId: string, title: string): Promise<void> {
    const list = await updateTaskListApi(listId, title);
    lists.value = lists.value.map((item) =>
      item.id === list.id ? list : item,
    );
  }

  async function deleteList(listId: string): Promise<void> {
    await deleteTaskListApi(listId);
    if (selectedListId.value === listId) selectedListId.value = 'all';
    await loadPersonalTasks();
  }

  return {
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
    starredCount,
    subtasksByParentId,
    taskCountsByListId,
    taskTotalsByListId,
    tasks,
    todayOpenCount,
    toggleStar,
    toggleStarredFilter,
    toggleTaskStatus,
    toggleTodayFilter,
    loadPersonalTasks,
    updateList,
    updateTask,
    visibleCompletedTasks,
    visibleOpenTasks,
  };
}
