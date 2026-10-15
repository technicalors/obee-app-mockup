import type { VNode } from 'vue';

import type {
  PersonalTask,
  PersonalTaskList,
  PersonalTaskRecurrence,
} from '#/api/contracts/personal-tasks';

import { createApp, nextTick } from 'vue';

import {
  afterEach,
  beforeAll,
  beforeEach,
  describe,
  expect,
  it,
  vi,
} from 'vitest';

import { initComponentAdapter } from '#/adapter/component';
import { initSetupVbenForm } from '#/adapter/form';
import { createPersonalTaskApi } from '#/api/personal-tasks';

import TaskDetailDrawer from './components/task-detail-drawer.vue';
import PersonalTasksPage from './index.vue';
import { previewLists, previewTasks } from './preview-data';
import { getTodayLocalDate } from './use-personal-tasks';

const mountedApps: ReturnType<typeof createApp>[] = [];
const taskApiState = vi.hoisted(() => ({
  data: null as null | {
    lists: PersonalTaskList[];
    tasks: PersonalTask[];
  },
}));

vi.mock('#/api/personal-tasks', async () => {
  const fixtures = await import('./preview-data');
  const state = taskApiState;
  const read = (): NonNullable<typeof taskApiState.data> => {
    if (state.data === null) {
      const [list, otherList] = fixtures.previewLists;
      if (!list || !otherList)
        throw new Error('Task list fixture was not found');
      const templates = fixtures.previewTasks.filter(
        (task) => task.parent_id === null && task.status === 'needsAction',
      );
      const tasks = templates.slice(0, 3).map((task, index) => ({
        ...task,
        due_date: ['2026-10-02', '2026-10-03', '2026-10-06'][index] ?? null,
        position: index,
        task_list_id: list.id,
        title:
          [
            'Draft weekly product update',
            'Plan onboarding review',
            'Prepare release checklist',
          ][index] ?? task.title,
      }));
      state.data = {
        lists: [{ ...list }, { ...otherList }],
        tasks,
      };
    }
    return state.data;
  };
  const find = (taskId: string): PersonalTask => {
    const task = read().tasks.find((item) => item.id === taskId);
    if (!task) throw new Error(`Task ${taskId} was not found`);
    return task;
  };
  return {
    createPersonalTaskApi: vi.fn(
      async (payload: {
        due_date: null | string;
        notes: null | string;
        parent_id: null | string;
        recurrence: null | PersonalTaskRecurrence;
        starred: boolean;
        status: 'completed' | 'needsAction';
        task_list_id: string;
        title: string;
      }) => {
        const data = read();
        const template = data.tasks[0];
        if (!template) throw new Error('Task fixture was not found');
        for (const task of data.tasks) {
          if (
            task.task_list_id === payload.task_list_id &&
            task.parent_id === payload.parent_id
          ) {
            task.position += 1;
          }
        }
        const id = crypto.randomUUID();
        const task: PersonalTask = {
          ...template,
          completed_at: null,
          due_date: payload.due_date,
          extension: {
            ...template.extension,
            recurrence: payload.recurrence,
            starred: payload.starred,
            task_id: id,
          },
          id,
          notes: payload.notes,
          parent_id: payload.parent_id,
          position: 0,
          status: 'needsAction',
          task_list_id: payload.task_list_id,
          title: payload.title,
        };
        data.tasks.push(task);
        return task;
      },
    ),
    createTaskListApi: vi.fn(async (title: string) => {
      const data = read();
      const template = data.lists[0];
      if (!template) throw new Error('Task list fixture was not found');
      const list = {
        ...template,
        id: crypto.randomUUID(),
        is_default: false,
        title,
      };
      data.lists.push(list);
      return list;
    }),
    deletePersonalTaskApi: vi.fn(async (taskId: string) => {
      const data = read();
      data.tasks = data.tasks.filter(
        (task) => task.id !== taskId && task.parent_id !== taskId,
      );
    }),
    deleteTaskListApi: vi.fn(async (listId: string) => {
      const data = read();
      data.lists = data.lists.filter((list) => list.id !== listId);
      data.tasks = data.tasks.filter((task) => task.task_list_id !== listId);
    }),
    getPersonalTasksApi: vi.fn(async () => {
      const data = structuredClone(read());
      return {
        ...data,
        tasks: data.tasks.toSorted((a, b) => a.position - b.position),
      };
    }),
    movePersonalTaskApi: vi.fn(
      async (taskId: string, payload: { task_list_id: string }) => {
        const task = find(taskId);
        task.task_list_id = payload.task_list_id;
        return task;
      },
    ),
    updatePersonalTaskApi: vi.fn(
      async (
        taskId: string,
        payload: {
          due_date?: null | string;
          notes?: null | string;
          starred?: boolean;
          status?: 'completed' | 'needsAction';
          title?: string;
        },
      ) => {
        const data = read();
        const index = data.tasks.findIndex((item) => item.id === taskId);
        const current = data.tasks[index];
        if (!current) throw new Error(`Task ${taskId} was not found`);
        const { starred, status, ...content } = payload;
        const base = {
          ...current,
          ...content,
          extension: {
            ...current.extension,
            starred: starred ?? current.extension.starred,
          },
        };
        const next: PersonalTask =
          (status ?? current.status) === 'completed'
            ? {
                ...base,
                completed_at: current.completed_at ?? new Date().toISOString(),
                status: 'completed',
              }
            : { ...base, completed_at: null, status: 'needsAction' };
        data.tasks[index] = next;
        return next;
      },
    ),
    updateTaskListApi: vi.fn(async (listId: string, title: string) => {
      const data = read();
      const list = data.lists.find((item) => item.id === listId);
      if (!list) throw new Error('Task list fixture was not found');
      list.title = title;
      return list;
    }),
  };
});

vi.mock('vue', async (importOriginal) => {
  const actual = await importOriginal<typeof import('vue')>();
  return {
    ...actual,
    TransitionGroup: {
      name: 'TransitionGroup',
      props: ['tag'],
      setup(
        props: { tag?: string },
        { slots }: { slots: { default?: () => VNode[] } },
      ) {
        return () =>
          actual.h(props.tag || 'div', slots.default ? slots.default() : []);
      },
    },
  };
});

vi.mock('@vben/common-ui', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@vben/common-ui')>();
  return {
    ...actual,
    Page: {
      template: '<main><slot /></main>',
    },
    VbenButton: {
      template: '<button type="button" v-bind="$attrs"><slot /></button>',
    },
  };
});

vi.mock('@vben/icons', () => ({
  createIconifyIcon: () => ({
    template: '<span aria-hidden="true"></span>',
  }),
}));

vi.mock('#/locales', () => ({
  $t: (key: string, params?: Record<string, unknown>) => {
    if (params && 'count' in params) {
      return `${key}:${params.count}`;
    }
    return key;
  },
}));

function mountPage(): HTMLElement {
  const element = document.createElement('div');
  document.body.append(element);
  const app = createApp(PersonalTasksPage);
  mountedApps.push(app);
  app.mount(element);
  return element;
}

async function mountLoadedPage(): Promise<HTMLElement> {
  const element = mountPage();
  await vi.waitFor(() =>
    expect(element.querySelector('[data-testid="task-row"]')).not.toBeNull(),
  );
  return element;
}

beforeAll(async () => {
  await initComponentAdapter();
  await initSetupVbenForm();
  await Promise.all([
    import('ant-design-vue/es/date-picker'),
    import('ant-design-vue/es/input'),
    import('ant-design-vue/es/select'),
  ]);
}, 30_000);

beforeEach(() => {
  taskApiState.data = null;
});

afterEach(() => {
  for (const app of mountedApps.splice(0)) {
    app.unmount();
  }
  document.body.replaceChildren();
});

describe('personal tasks page (Obee task CRUD)', () => {
  it('shows completed tasks in a section that is collapsed by default', async () => {
    const [list] = previewLists;
    const openTask = previewTasks.find(
      (task) => task.status === 'needsAction' && task.parent_id === null,
    );
    const completedTask = previewTasks.find(
      (task) => task.status === 'completed' && task.parent_id === null,
    );
    if (!list || !openTask || !completedTask) {
      throw new Error('Personal task fixtures were not found');
    }
    taskApiState.data = {
      lists: [{ ...list }],
      tasks: [
        { ...openTask, task_list_id: list.id },
        { ...completedTask, task_list_id: list.id },
      ],
    };

    const element = await mountLoadedPage();
    const toggle = element.querySelector<HTMLButtonElement>(
      '[data-testid="completed-accordion-toggle"]',
    );

    expect(toggle).not.toBeNull();
    expect(toggle?.getAttribute('aria-expanded')).toBe('false');
    expect(element.textContent).not.toContain(completedTask.title);
    expect(
      element.querySelector('[data-testid="task-empty-state"]'),
    ).toBeNull();

    toggle?.click();
    await nextTick();

    expect(toggle?.getAttribute('aria-expanded')).toBe('true');
    expect(element.textContent).toContain(completedTask.title);

    toggle?.click();
    await nextTick();

    expect(toggle?.getAttribute('aria-expanded')).toBe('false');
    expect(element.textContent).not.toContain(completedTask.title);
  });

  it('renders saved Obee lists and tasks', async () => {
    const element = await mountLoadedPage();

    expect(
      element.querySelector('[data-testid="personal-tasks-page"]'),
    ).not.toBeNull();
    expect(
      element.querySelector('[data-testid="all-lists-option"]'),
    ).not.toBeNull();
    expect(
      element.querySelector('[data-testid="starred-list-option"]'),
    ).toBeNull();

    expect(element.textContent).toContain('My Tasks');
    expect(element.textContent).toContain('Draft weekly product update');
    expect(element.textContent).not.toContain('Review onboarding flow');

    expect(
      element.querySelector('[data-testid="create-task-trigger"]'),
    ).not.toBeNull();
    expect(element.querySelector('[data-testid="task-quick-add"]')).toBeNull();
    expect(
      element.querySelector('[data-testid="today-list-option"]'),
    ).toBeNull();
    expect(
      element.querySelector('[data-testid="today-filter-button"]'),
    ).not.toBeNull();
    expect(
      element.querySelector('[data-testid="starred-filter-button"]'),
    ).not.toBeNull();
  });

  it('creates a root task from the create modal and its child through the existing API contract', async () => {
    vi.mocked(createPersonalTaskApi).mockClear();
    const element = await mountLoadedPage();
    element
      .querySelector<HTMLButtonElement>('[data-testid="create-task-trigger"]')
      ?.click();
    const rootInput = await vi.waitFor(() => {
      const field = document.querySelector<HTMLInputElement>(
        '[data-testid="create-task-title"]',
      );
      if (!field) throw new Error('Create-task title input was not found');
      return field;
    }, 5000);
    rootInput.value = 'New parent task';
    rootInput.dispatchEvent(new Event('input', { bubbles: true }));
    await nextTick();
    rootInput.dispatchEvent(
      new KeyboardEvent('keydown', {
        key: 'Enter',
        keyCode: 13,
        bubbles: true,
      }),
    );

    await vi.waitFor(() =>
      expect(createPersonalTaskApi).toHaveBeenCalledTimes(1),
    );
    await vi.waitFor(() =>
      expect(
        [
          ...element.querySelectorAll<HTMLElement>('[data-testid="task-row"]'),
        ].some((row) => row.textContent?.includes('New parent task')),
      ).toBe(true),
    );
    const parentRow = [
      ...element.querySelectorAll<HTMLElement>('[data-testid="task-row"]'),
    ].find((row) => row.textContent?.includes('New parent task'));
    if (!parentRow?.dataset.taskId) {
      throw new Error('Created parent task row was not found');
    }
    const parentItem = parentRow.parentElement;
    const addSubtaskButton = parentItem?.querySelector<HTMLButtonElement>(
      '[data-testid="task-add-subtask"]',
    );
    if (!addSubtaskButton) throw new Error('Add-subtask button was not found');
    addSubtaskButton.click();
    await nextTick();

    const subtaskInput = parentItem?.querySelector<HTMLInputElement>(
      '[data-testid="task-subtask-input"]',
    );
    if (!subtaskInput) throw new Error('Subtask input was not found');
    subtaskInput.value = 'New child task';
    subtaskInput.dispatchEvent(new Event('input', { bubbles: true }));
    await nextTick();
    subtaskInput.dispatchEvent(
      new KeyboardEvent('keydown', {
        key: 'Enter',
        keyCode: 13,
        bubbles: true,
      }),
    );

    await vi.waitFor(() =>
      expect(createPersonalTaskApi).toHaveBeenCalledTimes(2),
    );
    expect(createPersonalTaskApi).toHaveBeenNthCalledWith(1, {
      due_date: getTodayLocalDate(),
      notes: null,
      parent_id: null,
      recurrence: null,
      starred: false,
      status: 'needsAction',
      task_list_id: previewLists[0]?.id,
      title: 'New parent task',
    });
    expect(createPersonalTaskApi).toHaveBeenNthCalledWith(
      2,
      expect.objectContaining({
        parent_id: parentRow.dataset.taskId,
        task_list_id: vi.mocked(createPersonalTaskApi).mock.calls[0]?.[0]
          .task_list_id,
        title: 'New child task',
      }),
    );
  });

  it('adds a task from the bottom input to the selected list, or the default list from all tasks', async () => {
    vi.mocked(createPersonalTaskApi).mockClear();
    const element = await mountLoadedPage();
    const [defaultList, otherList] = previewLists;
    if (!defaultList || !otherList) {
      throw new Error('Task list fixtures were not found');
    }
    const addInline = async (title: string): Promise<void> => {
      const field = element.querySelector<HTMLInputElement>(
        '[data-testid="task-inline-add-input"]',
      );
      if (!field) throw new Error('Inline-add input was not found');
      field.value = title;
      field.dispatchEvent(new Event('input', { bubbles: true }));
      await nextTick();
      field.dispatchEvent(
        new KeyboardEvent('keydown', {
          key: 'Enter',
          keyCode: 13,
          bubbles: true,
        }),
      );
    };

    await addInline('From all tasks');
    await vi.waitFor(() =>
      expect(createPersonalTaskApi).toHaveBeenCalledExactlyOnceWith({
        due_date: null,
        notes: null,
        parent_id: null,
        recurrence: null,
        starred: false,
        status: 'needsAction',
        task_list_id: defaultList.id,
        title: 'From all tasks',
      }),
    );
    await vi.waitFor(() => {
      const field = element.querySelector<HTMLInputElement>(
        '[data-testid="task-inline-add-input"]',
      );
      expect(field?.value).toBe('');
      expect(field?.disabled).toBe(false);
    });

    element
      .querySelector<HTMLButtonElement>(
        `[data-testid="task-list-option"][data-list-id="${otherList.id}"]`,
      )
      ?.click();
    await nextTick();
    await addInline('From other list');
    await vi.waitFor(() =>
      expect(createPersonalTaskApi).toHaveBeenLastCalledWith(
        expect.objectContaining({
          task_list_id: otherList.id,
          title: 'From other list',
        }),
      ),
    );
    await vi.waitFor(() =>
      expect(
        element.querySelector('[data-testid="task-row"]')?.textContent,
      ).toContain('From other list'),
    );
  });

  it('filters tasks with deadline ending today when clicking today filter button', async () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date('2026-10-02T10:00:00Z'));
    try {
      const element = await mountLoadedPage();

      const todayFilterButton = element.querySelector<HTMLButtonElement>(
        '[data-testid="today-filter-button"]',
      );
      expect(todayFilterButton).not.toBeNull();

      // Click today filter button in header
      todayFilterButton?.click();
      await nextTick();

      // Only task with due_date = 2026-10-02 should be visible
      expect(element.textContent).toContain('Draft weekly product update');
      expect(element.textContent).not.toContain('Review onboarding flow');

      // Click today filter button again to toggle off
      todayFilterButton?.click();
      await nextTick();

      expect(element.textContent).toContain('Draft weekly product update');
      expect(element.textContent).toContain('Plan onboarding review');
    } finally {
      vi.useRealTimers();
    }
  });

  it('filters tasks when clicking starred filter button in header', async () => {
    const element = await mountLoadedPage();

    const starredFilterButton = element.querySelector<HTMLButtonElement>(
      '[data-testid="starred-filter-button"]',
    );
    expect(starredFilterButton).not.toBeNull();

    starredFilterButton?.click();
    await nextTick();

    // In preview data, Draft weekly product update (30) is starred: true, Plan onboarding review (31) is starred: false
    expect(element.textContent).toContain('Draft weekly product update');
    expect(element.textContent).not.toContain('Plan onboarding review');

    starredFilterButton?.click();
    await nextTick();

    expect(element.textContent).toContain('Draft weekly product update');
    expect(element.textContent).toContain('Plan onboarding review');
  });

  it('filters tasks when clicking a specific list', async () => {
    const element = await mountLoadedPage();

    // Select the Obee list
    const obeeListButton = [
      ...element.querySelectorAll<HTMLButtonElement>(
        '[data-testid="task-list-option"]',
      ),
    ].find((button) => button.textContent?.includes('My Tasks'));
    expect(obeeListButton).not.toBeNull();
    obeeListButton?.click();
    await nextTick();

    expect(element.textContent).toContain('Draft weekly product update');
  });

  it('shows rename for every list but no delete action for the default list', async () => {
    const element = await mountLoadedPage();

    expect(
      element.querySelector('[data-testid="rename-list-trigger"]'),
    ).toBeNull();
    expect(
      element.querySelector('[data-testid="delete-list-trigger"]'),
    ).toBeNull();

    // Select custom list
    const obeeListButton = [
      ...element.querySelectorAll<HTMLButtonElement>(
        '[data-testid="task-list-option"]',
      ),
    ].find((button) => button.textContent?.includes('My Tasks'));
    obeeListButton?.click();
    await nextTick();

    const renameButton = element.querySelector<HTMLButtonElement>(
      '[data-testid="rename-list-trigger"]',
    );
    expect(renameButton).not.toBeNull();
    expect(
      element.querySelector('[data-testid="delete-list-trigger"]'),
    ).toBeNull();

    renameButton?.click();
    await nextTick();

    await vi.waitFor(() => {
      expect(document.querySelector('.ant-modal input')).not.toBeNull();
    });

    const input = document.querySelector<HTMLInputElement>('.ant-modal input');
    if (!input) throw new Error('Rename input was not found');
    input.value = 'Renamed Obee tasks';
    input.dispatchEvent(new Event('input'));
    await nextTick();

    const okButton = [
      ...document.querySelectorAll<HTMLButtonElement>(
        '.ant-modal-footer button',
      ),
    ].find((b) => b.textContent?.includes('personalTasks.actions.save'));
    okButton?.click();
    await nextTick();

    await vi.waitFor(() => {
      expect(element.textContent).toContain('Renamed Obee tasks');
    });
  });

  it('allows deleting a non-default list from the header', async () => {
    const element = await mountLoadedPage();

    const projectListButton = [
      ...element.querySelectorAll<HTMLButtonElement>(
        '[data-testid="task-list-option"]',
      ),
    ].find((button) => button.textContent?.includes('Project tasks'));
    projectListButton?.click();
    await nextTick();

    const deleteButton = element.querySelector<HTMLButtonElement>(
      '[data-testid="delete-list-trigger"]',
    );
    expect(deleteButton).not.toBeNull();
    expect(deleteButton?.disabled).toBeFalsy();

    deleteButton?.click();
    await nextTick();

    await vi.waitFor(() => {
      expect(
        document.querySelector(
          '.ant-popconfirm-buttons button.ant-btn-primary',
        ),
      ).not.toBeNull();
    });

    const confirmButton = document.querySelector<HTMLButtonElement>(
      '.ant-popconfirm-buttons button.ant-btn-primary',
    );
    confirmButton?.click();
    await nextTick();

    await vi.waitFor(() => {
      expect(element.textContent).not.toContain('Project tasks');
    });
    expect(element.textContent).toContain('My Tasks');
  });

  it('shows empty state when search finds no matching task', async () => {
    const element = await mountLoadedPage();

    const search =
      element.querySelector<HTMLInputElement>(
        '[data-testid="task-search"] input',
      ) ??
      element.querySelector<HTMLInputElement>(
        'input[data-testid="task-search"]',
      ) ??
      element.querySelector<HTMLInputElement>('[data-testid="task-search"]') ??
      element.querySelector<HTMLInputElement>('header input');
    if (search === null) {
      throw new Error('Task search input was not found.');
    }
    search.value = 'nonexistent query term 12345';
    search.dispatchEvent(new Event('input'));
    await nextTick();

    expect(element.querySelector('[data-testid="task-list"]')).toBeNull();
    expect(
      element.querySelector('[data-testid="task-empty-state"]'),
    ).not.toBeNull();
  });

  it('toggles task completion when clicking circular checkbox and auto sorts to bottom', async () => {
    const element = await mountLoadedPage();

    const taskRows = element.querySelectorAll<HTMLElement>(
      '[data-testid="task-row"]',
    );
    expect(taskRows.length).toBeGreaterThan(0);
    const firstRow = taskRows[0];
    if (!firstRow) throw new Error('Task row was not found');
    const firstTaskId = firstRow.dataset.taskId;

    const checkbox = firstRow.querySelector<HTMLButtonElement>(
      '[data-testid="task-checkbox"]',
    );
    expect(checkbox).not.toBeNull();

    checkbox?.click();
    await nextTick();
    await vi.waitFor(() => {
      expect(
        element.querySelector('[data-testid="completed-accordion-toggle"]'),
      ).not.toBeNull();
    });

    const completedToggle = element.querySelector<HTMLButtonElement>(
      '[data-testid="completed-accordion-toggle"]',
    );
    expect(completedToggle?.getAttribute('aria-expanded')).toBe('false');
    expect(element.querySelector(`[data-task-id="${firstTaskId}"]`)).toBeNull();

    completedToggle?.click();
    await nextTick();

    // The toggled task is now marked completed
    await vi.waitFor(() =>
      expect(
        element.querySelector(`[data-task-id="${firstTaskId}"]`),
      ).not.toBeNull(),
    );
    const toggledRow = element.querySelector<HTMLElement>(
      `[data-task-id="${firstTaskId}"]`,
    );
    expect(toggledRow).not.toBeNull();
    if (!toggledRow) {
      throw new Error('Expected toggledRow to be present');
    }
    const toggledCheckbox = toggledRow.querySelector(
      '[data-testid="task-checkbox"]',
    );
    expect(toggledCheckbox?.getAttribute('aria-pressed')).toBe('true');

    // The completed section follows all open tasks.
    const allRows = [
      ...element.querySelectorAll<HTMLElement>('[data-testid="task-row"]'),
    ];
    const openRows = allRows.filter(
      (row) =>
        row
          .querySelector('[data-testid="task-checkbox"]')
          ?.getAttribute('aria-pressed') === 'false',
    );
    expect(allRows.indexOf(toggledRow)).toBeGreaterThanOrEqual(openRows.length);

    // Reopen (start) the task: it automatically moves to the top of the list
    toggledCheckbox?.dispatchEvent(new MouseEvent('click', { bubbles: true }));
    await nextTick();
    await vi.waitFor(() => {
      expect(
        element
          .querySelector(
            `[data-task-id="${firstTaskId}"] [data-testid="task-checkbox"]`,
          )
          ?.getAttribute('aria-pressed'),
      ).toBe('false');
    });

    const reopenedRows = [
      ...element.querySelectorAll<HTMLElement>('[data-testid="task-row"]'),
    ];
    const reopenedRow = reopenedRows[0];
    if (!reopenedRow) throw new Error('Reopened task row was not found');
    expect(reopenedRow.dataset.taskId).toBe(firstTaskId);
    expect(
      reopenedRow
        .querySelector('[data-testid="task-checkbox"]')
        ?.getAttribute('aria-pressed'),
    ).toBe('false');
  });

  it('toggles star state when clicking star button', async () => {
    const element = await mountLoadedPage();

    const starButtons = element.querySelectorAll<HTMLButtonElement>(
      '[data-testid="task-star-button"]',
    );
    expect(starButtons.length).toBeGreaterThan(0);

    const firstStarButton = starButtons.item(0);
    if (!firstStarButton) throw new Error('Star button was not found');
    const initialAria = firstStarButton.getAttribute('aria-label');

    firstStarButton.click();
    await nextTick();
    await vi.waitFor(() => {
      expect(firstStarButton.getAttribute('aria-label')).not.toBe(initialAria);
    });

    const updatedAria = firstStarButton.getAttribute('aria-label');
    expect(updatedAria).not.toBe(initialAria);
  });

  it('moves a newly starred task above plain tasks, after starred tasks due sooner', async () => {
    const element = await mountLoadedPage();
    const openIds = (): (string | undefined)[] =>
      [...element.querySelectorAll<HTMLElement>('[data-testid="task-row"]')]
        .filter(
          (row) =>
            row
              .querySelector('[data-testid="task-checkbox"]')
              ?.getAttribute('aria-pressed') === 'false',
        )
        .map((row) => row.dataset.taskId);
    const orderedIds = [
      '00000000-0000-4000-8000-000000000030',
      '00000000-0000-4000-8000-000000000033',
      '00000000-0000-4000-8000-000000000031',
    ];
    const onboardingId = '00000000-0000-4000-8000-000000000031';
    const onboardingCheckbox = (): HTMLButtonElement | null =>
      element.querySelector<HTMLButtonElement>(
        `[data-task-id="${onboardingId}"] [data-testid="task-checkbox"]`,
      );

    expect(openIds()).toEqual(orderedIds);

    element
      .querySelector<HTMLButtonElement>(
        `[data-task-id="${onboardingId}"] [data-testid="task-star-button"]`,
      )
      ?.click();
    await vi.waitFor(() => {
      expect(
        element
          .querySelector(
            `[data-task-id="${onboardingId}"] [data-testid="task-star-button"]`,
          )
          ?.getAttribute('aria-pressed'),
      ).toBe('true');
    });
    const starredOrder = [orderedIds[0], onboardingId, orderedIds[1]];
    expect(openIds()).toEqual(starredOrder);

    onboardingCheckbox()?.click();
    await vi.waitFor(() => {
      expect(
        element.querySelector('[data-testid="completed-accordion-toggle"]'),
      ).not.toBeNull();
    });
    expect(onboardingCheckbox()).toBeNull();
    expect(openIds()).toEqual([orderedIds[0], orderedIds[1]]);

    element
      .querySelector<HTMLButtonElement>(
        '[data-testid="completed-accordion-toggle"]',
      )
      ?.click();
    await nextTick();
    expect(onboardingCheckbox()?.getAttribute('aria-pressed')).toBe('true');

    onboardingCheckbox()?.click();
    await vi.waitFor(() => {
      expect(onboardingCheckbox()?.getAttribute('aria-pressed')).toBe('false');
    });
    expect(openIds()).toEqual(starredOrder);
  });
});

describe('personal tasks with Ant Design controls', () => {
  it('saves a selected date as a string and clearing it as null', async () => {
    const update = vi.fn();
    const firstTask = previewTasks.at(0);
    if (!firstTask) throw new Error('Task fixture was not found');
    const task = { ...firstTask, due_date: '2026-10-01' };
    const host = document.createElement('div');
    document.body.append(host);
    const app = createApp(TaskDetailDrawer, {
      open: true,
      task,
      lists: previewLists,
      subtasks: [],
      onUpdate: update,
    });
    mountedApps.push(app);
    app.mount(host);
    await nextTick();
    await vi.waitFor(() => {
      expect(
        document.querySelector('.ant-drawer .ant-picker input'),
      ).not.toBeNull();
    });
    const picker = document.querySelector<HTMLInputElement>(
      '.ant-drawer .ant-picker input',
    );
    if (!picker) throw new Error('Date picker input was not found');
    picker.dispatchEvent(new MouseEvent('mouseup', { bubbles: true }));
    await nextTick();
    await vi.waitFor(() => {
      expect(
        document.querySelector(
          '.ant-picker-dropdown td[title="2026-10-15"] .ant-picker-cell-inner',
        ),
      ).not.toBeNull();
    });
    const day = document.querySelector<HTMLElement>(
      '.ant-picker-dropdown td[title="2026-10-15"] .ant-picker-cell-inner',
    );
    if (!day) throw new Error('October 15 was not available in the calendar');
    day.click();
    await nextTick();
    expect(update).toHaveBeenLastCalledWith(
      task.id,
      expect.objectContaining({ dueDate: '2026-10-15' }),
    );
    const clear = document.querySelector<HTMLElement>(
      '.ant-drawer .ant-picker-clear',
    );
    if (!clear) throw new Error('Date clear action was not found');
    clear.dispatchEvent(new MouseEvent('mouseup', { bubbles: true }));
    await nextTick();
    expect(update).toHaveBeenLastCalledWith(
      task.id,
      expect.objectContaining({ dueDate: null }),
    );
  });

  it('requires confirmation before deleting a task from the list', async () => {
    const host = await mountLoadedPage();
    const row = host.querySelector<HTMLElement>('[data-testid="task-row"]');
    const id = row?.dataset.taskId;
    const remove = row?.querySelector<HTMLButtonElement>(
      '[data-testid="task-delete-button"]',
    );
    if (!remove || !id) throw new Error('Task delete action was not found');
    remove.click();
    await nextTick();
    expect(host.querySelector(`[data-task-id="${id}"]`)).not.toBeNull();
    await vi.waitFor(() => {
      expect(
        document.querySelector('.ant-popconfirm-buttons button'),
      ).not.toBeNull();
    });
    const cancel = document.querySelector<HTMLButtonElement>(
      '.ant-popconfirm-buttons button',
    );
    if (!cancel) throw new Error('Delete cancellation was not found');
    cancel.click();
    await nextTick();
    expect(host.querySelector(`[data-task-id="${id}"]`)).not.toBeNull();
    remove.click();
    await nextTick();
    await vi.waitFor(() => {
      expect(
        document.querySelector(
          '.ant-popconfirm-buttons button.ant-btn-primary',
        ),
      ).not.toBeNull();
    });
    const confirm = document.querySelector<HTMLButtonElement>(
      '.ant-popconfirm-buttons button.ant-btn-primary',
    );
    if (!confirm) throw new Error('Delete confirmation was not found');
    confirm.click();
    await nextTick();
    await vi.waitFor(() => {
      expect(host.querySelector(`[data-task-id="${id}"]`)).toBeNull();
    });
  });
});
