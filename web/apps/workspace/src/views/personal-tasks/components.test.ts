import type { Component } from 'vue';

import type {
  CompletedPersonalTask,
  PersonalTask,
} from '#/api/contracts/personal-tasks';

import { createApp, h, nextTick, reactive } from 'vue';

import { afterEach, describe, expect, it, vi } from 'vitest';

import TaskDetailDrawer from './components/task-detail-drawer.vue';
import TaskInlineAdd from './components/task-inline-add.vue';
import TaskItem from './components/task-item.vue';
import TaskSidebar from './components/task-sidebar.vue';
import PersonalTasksPage from './index.vue';
import { previewLists, previewTasks } from './preview-data';
import { compareCompletedTasks, compareOpenTasks } from './use-personal-tasks';

vi.mock('#/api/personal-tasks', async () => {
  const fixtures = await import('./preview-data');
  const lists = fixtures.previewLists;
  const listIds = new Set(lists.map((list) => list.id));
  const tasks = fixtures.previewTasks.filter((task) =>
    listIds.has(task.task_list_id),
  );
  const data = {
    lists,
    tasks,
  };
  return {
    createPersonalTaskApi: vi.fn(),
    createTaskListApi: vi.fn(async (title: string) => {
      const template = data.lists[0];
      if (!template) throw new Error('Task list fixture was not found');
      const list = { ...template, id: crypto.randomUUID(), title };
      data.lists.push(list);
      return list;
    }),
    deletePersonalTaskApi: vi.fn(async (taskId: string) => {
      data.tasks = data.tasks.filter((task) => task.id !== taskId);
    }),
    deleteTaskListApi: vi.fn(async (listId: string) => {
      data.lists = data.lists.filter((list) => list.id !== listId);
    }),
    getPersonalTasksApi: vi.fn(async () => structuredClone(data)),
    updatePersonalTaskApi: vi.fn(),
    updateTaskListApi: vi.fn(async (listId: string, title: string) => {
      const list = data.lists.find((item) => item.id === listId);
      if (!list) throw new Error('Task list fixture was not found');
      list.title = title;
      return list;
    }),
  };
});

function getPreviewTask(index: number): PersonalTask {
  const task = previewTasks[index];
  if (!task) throw new Error(`Task fixture ${index} was not found`);
  return task;
}

function openTask(
  overrides: Partial<PersonalTask> & { starred?: boolean },
): PersonalTask {
  const { starred, ...fields } = overrides;
  const task = getPreviewTask(0);
  return {
    ...task,
    ...fields,
    completed_at: null,
    extension: { ...task.extension, starred: starred ?? false },
    status: 'needsAction',
  };
}

function completedTask(completedAt: string): CompletedPersonalTask {
  return {
    ...getPreviewTask(0),
    completed_at: completedAt,
    status: 'completed',
  };
}

const preferencesState = vi.hoisted(() => ({ isMobile: false }));

vi.mock('@vben/preferences', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@vben/preferences')>();
  const { computed } = await import('vue');
  return {
    ...actual,
    usePreferences: () => ({
      ...actual.usePreferences(),
      isMobile: computed(() => preferencesState.isMobile),
    }),
  };
});

vi.mock('@vben/icons', () => ({
  createIconifyIcon: () => ({ template: '<span aria-hidden="true"></span>' }),
}));
vi.mock('#/locales', () => ({
  $t: (key: string) => key,
}));
vi.mock('@vben/common-ui', async (importOriginal) => ({
  ...(await importOriginal<typeof import('@vben/common-ui')>()),
  Page: { template: '<main><slot /></main>' },
}));
vi.mock('ant-design-vue', () => {
  const Input = {
    props: ['value', 'placeholder', 'autoSize', 'allowClear'],
    emits: ['update:value', 'pressEnter', 'blur'],
    template:
      '<input :value="value" :placeholder="placeholder" @input="$emit(\'update:value\', $event.target.value)" @keydown.enter="$emit(\'pressEnter\', $event)" @blur="$emit(\'blur\', $event)" />',
    methods: {
      focus(this: { $el: HTMLInputElement }) {
        this.$el.focus();
      },
    },
  };
  const Select = {
    props: ['value', 'size'],
    emits: ['update:value', 'change'],
    template:
      '<select :value="value" @change="$emit(\'update:value\', $event.target.value); $emit(\'change\', $event.target.value)"><slot /></select>',
    Option: {
      props: ['value'],
      template: '<option :value="value"><slot /></option>',
    },
  };
  return {
    Input,
    Select,
    Textarea: {
      ...Input,
      template:
        '<textarea :value="value" @input="$emit(\'update:value\', $event.target.value)" @blur="$emit(\'blur\', $event)"></textarea>',
    },
    DatePicker: {
      props: ['value', 'format', 'valueFormat', 'allowClear', 'placeholder'],
      emits: ['update:value', 'change'],
      template:
        '<input type="date" :value="value" @change="$emit(\'update:value\', $event.target.value || null); $emit(\'change\', $event.target.value || null)" />',
    },
    Button: {
      props: ['type', 'size', 'disabled'],
      template: '<button type="button" :disabled="disabled"><slot /></button>',
    },
    Drawer: {
      props: [
        'open',
        'width',
        'placement',
        'rootClassName',
        'title',
        'bodyStyle',
      ],
      emits: ['close'],
      template:
        '<section v-if="open" data-testid="drawer"><button data-testid="drawer-close" @click="$emit(\'close\')">Close</button><slot /><slot name="footer" /></section>',
    },
    Modal: {
      props: [
        'open',
        'title',
        'footer',
        'width',
        'rootClassName',
        'okButtonProps',
        'okText',
        'cancelText',
      ],
      emits: ['cancel', 'ok'],
      template:
        '<section v-if="open" data-testid="modal"><slot /><button data-testid="modal-ok" :disabled="okButtonProps?.disabled" @click="$emit(\'ok\')">{{ okText }}</button><button data-testid="modal-cancel" @click="$emit(\'cancel\')">{{ cancelText }}</button></section>',
    },
    Popconfirm: {
      props: ['title', 'okText', 'cancelText'],
      emits: ['confirm'],
      data: () => ({ open: false }),
      template:
        '<span><span @click="open = true"><slot /></span><span v-if="open"><button data-testid="confirm-delete" @click="$emit(\'confirm\'); open = false">{{ okText }}</button><button data-testid="cancel-delete" @click="open = false">{{ cancelText }}</button></span></span>',
    },
    Tag: { template: '<span><slot /></span>' },
    Alert: {
      props: ['message'],
      template: '<div>{{ message }}<slot name="action" /></div>',
    },
    Empty: {
      props: ['image', 'description'],
      template: '<div><slot name="description" /><slot /></div>',
    },
    message: {
      error: vi.fn(),
      info: vi.fn(),
      success: vi.fn(),
    },
  };
});

const [firstTask] = previewTasks;
const [obeeList, otherList] = previewLists;
const childTask = previewTasks.find((task) => task.parent_id !== null);
if (!firstTask || !obeeList || !otherList || !childTask) {
  throw new Error('Personal task test fixtures are incomplete');
}

const apps: ReturnType<typeof createApp>[] = [];
function mount(
  component: Component,
  props: Record<string, unknown> = {},
): HTMLElement {
  const host = document.createElement('div');
  document.body.append(host);
  const app = createApp(() => h(component, props));
  apps.push(app);
  app.mount(host);
  return host;
}
function element<T extends HTMLElement = HTMLElement>(
  host: HTMLElement,
  selector: string,
): T {
  const result = host.querySelector<T>(selector);
  if (!result) throw new Error(`Missing ${selector}`);
  return result;
}
async function click(host: HTMLElement, selector: string): Promise<void> {
  element(host, selector).click();
  await nextTick();
}
async function input(
  host: HTMLElement,
  selector: string,
  value: string,
  event = 'input',
): Promise<void> {
  const field = element<HTMLInputElement>(host, selector);
  field.value = value;
  field.dispatchEvent(new Event(event, { bubbles: true }));
  await nextTick();
}
afterEach(() => {
  preferencesState.isMobile = false;
  for (const app of apps.splice(0)) app.unmount();
  document.body.replaceChildren();
});

describe('personal task creation', () => {
  it('keeps the inline input open, creates on Enter or send and ignores Escape and blank titles', async () => {
    const saveTask = vi.fn(async () => true);
    const host = mount(TaskInlineAdd, {
      canChooseList: false,
      listId: obeeList.id,
      lists: previewLists,
      saveTask,
    });
    const field = element<HTMLInputElement>(
      host,
      '[data-testid="task-inline-add-input"]',
    );
    const send = element<HTMLButtonElement>(
      host,
      '[data-testid="task-inline-add-send"]',
    );
    const pressKey = (options: KeyboardEventInit): void => {
      field.dispatchEvent(
        new KeyboardEvent('keydown', { bubbles: true, ...options }),
      );
    };

    expect(
      element(host, '[data-testid="task-inline-add-list"]').textContent?.trim(),
    ).toBe(obeeList.title);
    expect(
      host.querySelector('[data-testid="task-inline-add-list-select"]'),
    ).toBeNull();
    expect(send.disabled).toBe(true);
    pressKey({ key: 'Enter' });
    await nextTick();
    expect(saveTask).not.toHaveBeenCalled();

    await input(host, '[data-testid="task-inline-add-input"]', '   ');
    expect(send.disabled).toBe(true);
    pressKey({ key: 'Enter' });
    await nextTick();
    expect(saveTask).not.toHaveBeenCalled();

    await input(host, '[data-testid="task-inline-add-input"]', 'Discard me');
    pressKey({ key: 'Escape' });
    await nextTick();
    expect(field.value).toBe('');
    expect(saveTask).not.toHaveBeenCalled();

    await input(host, '[data-testid="task-inline-add-input"]', 'Enter task');
    pressKey({ key: 'Enter', isComposing: true });
    expect(saveTask).not.toHaveBeenCalled();
    pressKey({ key: 'Enter' });
    await vi.waitFor(() =>
      expect(saveTask).toHaveBeenCalledExactlyOnceWith({
        listId: obeeList.id,
        title: 'Enter task',
      }),
    );
    await vi.waitFor(() => expect(field.value).toBe(''));

    await input(host, '[data-testid="task-inline-add-input"]', 'Send task');
    send.click();
    await vi.waitFor(() =>
      expect(saveTask).toHaveBeenLastCalledWith({
        listId: obeeList.id,
        title: 'Send task',
      }),
    );
    expect(saveTask).toHaveBeenCalledTimes(2);
  });

  it('lets all tasks choose the target list with a select instead of a tag', async () => {
    const saveTask = vi.fn(async () => true);
    const host = mount(TaskInlineAdd, {
      canChooseList: true,
      listId: obeeList.id,
      lists: previewLists,
      saveTask,
    });
    expect(
      host.querySelector('[data-testid="task-inline-add-list"]'),
    ).toBeNull();
    expect(
      element<HTMLSelectElement>(
        host,
        '[data-testid="task-inline-add-list-select"]',
      ).value,
    ).toBe(obeeList.id);

    await input(
      host,
      '[data-testid="task-inline-add-list-select"]',
      otherList.id,
      'change',
    );
    await input(host, '[data-testid="task-inline-add-input"]', 'Other task');
    await click(host, '[data-testid="task-inline-add-send"]');
    await vi.waitFor(() =>
      expect(saveTask).toHaveBeenCalledExactlyOnceWith({
        listId: otherList.id,
        title: 'Other task',
      }),
    );
  });

  it('keeps the inline title when saving fails', async () => {
    const saveTask = vi.fn(async () => false);
    const host = mount(TaskInlineAdd, {
      canChooseList: false,
      listId: obeeList.id,
      lists: previewLists,
      saveTask,
    });
    await input(host, '[data-testid="task-inline-add-input"]', 'Retry me');
    await click(host, '[data-testid="task-inline-add-send"]');
    await vi.waitFor(() =>
      expect(saveTask).toHaveBeenCalledExactlyOnceWith({
        listId: obeeList.id,
        title: 'Retry me',
      }),
    );
    expect(
      element<HTMLInputElement>(host, '[data-testid="task-inline-add-input"]')
        .value,
    ).toBe('Retry me');
  });

  it('opens task creation from the sidebar only when lists exist', async () => {
    const createTask = vi.fn();
    const host = mount(TaskSidebar, {
      allOpenCount: 0,
      lists: previewLists,
      onCreateTask: createTask,
      selectedListId: 'all',
      taskCountsByListId: new Map(),
    });
    await click(host, '[data-testid="create-task-trigger"]');
    expect(createTask).toHaveBeenCalledTimes(1);

    const emptyHost = mount(TaskSidebar, {
      allOpenCount: 0,
      lists: [],
      selectedListId: 'all',
      taskCountsByListId: new Map(),
    });
    expect(
      element<HTMLButtonElement>(
        emptyHost,
        '[data-testid="create-task-trigger"]',
      ).disabled,
    ).toBe(true);
  });
});

describe('task action boundaries', () => {
  it('opens detail independently of completion/star and only deletes after confirmation', async () => {
    const open = vi.fn();
    const toggle = vi.fn();
    const star = vi.fn();
    const remove = vi.fn();
    const task = firstTask;
    const host = mount(TaskItem, {
      task,
      listsById: new Map(previewLists.map((list) => [list.id, list])),
      saveSubtask: vi.fn(async () => true),
      onOpenDetail: open,
      onToggleStatus: toggle,
      onToggleStar: star,
      onDelete: remove,
    });
    await click(host, '[data-testid="task-checkbox"]');
    await click(host, '[data-testid="task-star-button"]');
    expect(toggle).toHaveBeenCalledExactlyOnceWith(task.id);
    expect(star).toHaveBeenCalledExactlyOnceWith(task.id);
    expect(open).not.toHaveBeenCalled();
    await click(host, '[data-testid="task-delete-button"]');
    expect(remove).not.toHaveBeenCalled();
    await click(host, '[data-testid="cancel-delete"]');
    expect(remove).not.toHaveBeenCalled();
    await click(host, '[data-testid="task-delete-button"]');
    await click(host, '[data-testid="confirm-delete"]');
    expect(remove).toHaveBeenCalledExactlyOnceWith(task.id);
    expect(open).not.toHaveBeenCalled();
    await click(host, '[data-testid="task-detail-trigger"]');
    expect(open).toHaveBeenCalledExactlyOnceWith(task.id);
  });

  it('exposes completed and starred states without fading the row', () => {
    const task = {
      ...firstTask,
      completed_at: '2026-10-02T10:00:00.000000Z',
      extension: { ...firstTask.extension, starred: true },
      status: 'completed',
    };
    const host = mount(TaskItem, {
      task,
      listsById: new Map(),
      saveSubtask: vi.fn(async () => true),
    });
    expect(
      element(host, '[data-testid="task-checkbox"]').getAttribute(
        'aria-pressed',
      ),
    ).toBe('true');
    expect(
      element(host, '[data-testid="task-star-button"]').getAttribute(
        'aria-pressed',
      ),
    ).toBe('true');
    expect(element(host, '[data-testid="task-row"]').className).not.toContain(
      'opacity',
    );
  });

  it('marks repeating tasks next to their due date', () => {
    const props = {
      listsById: new Map(),
      saveSubtask: vi.fn(async () => true),
    };
    const repeating = mount(TaskItem, {
      ...props,
      task: {
        ...openTask({ due_date: '2026-10-08' }),
        extension: {
          ...firstTask.extension,
          recurrence: {
            count: null,
            frequency: 'week',
            interval: 1,
            until: null,
            weekdays: [4],
          },
        },
      },
    });
    const single = mount(TaskItem, {
      ...props,
      task: openTask({ due_date: '2026-10-08' }),
    });

    expect(
      repeating.querySelector('[data-testid="task-recurrence-icon"]'),
    ).not.toBeNull();
    expect(
      single.querySelector('[data-testid="task-recurrence-icon"]'),
    ).toBeNull();
  });

  it('adds multiple subtasks inline, ignores IME Enter and retains failed input', async () => {
    const saveSubtask =
      vi.fn<(parentId: string, title: string) => Promise<boolean>>();
    saveSubtask.mockResolvedValueOnce(true);
    saveSubtask.mockResolvedValueOnce(false);
    const host = mount(TaskItem, {
      task: firstTask,
      listsById: new Map(previewLists.map((list) => [list.id, list])),
      saveSubtask,
    });

    await click(host, '[data-testid="task-add-subtask"]');
    const inputField = element<HTMLInputElement>(
      host,
      '[data-testid="task-subtask-input"]',
    );
    expect(document.activeElement).toBe(inputField);
    await input(host, '[data-testid="task-subtask-input"]', 'First child');
    inputField.dispatchEvent(
      new KeyboardEvent('keydown', {
        key: 'Enter',
        isComposing: true,
        bubbles: true,
      }),
    );
    await nextTick();
    expect(saveSubtask).not.toHaveBeenCalled();
    inputField.dispatchEvent(
      new KeyboardEvent('keydown', { key: 'Enter', bubbles: true }),
    );
    await vi.waitFor(() =>
      expect(saveSubtask).toHaveBeenCalledExactlyOnceWith(
        firstTask.id,
        'First child',
      ),
    );
    await vi.waitFor(() => expect(inputField.value).toBe(''));

    await input(host, '[data-testid="task-subtask-input"]', 'Retry child');
    await click(host, '[data-testid="task-subtask-save"]');
    await vi.waitFor(() => expect(saveSubtask).toHaveBeenCalledTimes(2));
    expect(inputField.value).toBe('Retry child');

    inputField.dispatchEvent(
      new KeyboardEvent('keydown', { key: 'Escape', bubbles: true }),
    );
    await nextTick();
    expect(host.querySelector('[data-testid="task-subtask-input"]')).toBeNull();
    expect(document.activeElement).toBe(
      element(host, '[data-testid="task-add-subtask"]'),
    );
  });
});

describe('detail inputs and dialogs', () => {
  it('saves title/notes on blur and keeps date-only values when changing and clearing a date', async () => {
    const update = vi.fn();
    const props = reactive({
      open: true,
      task: { ...firstTask },
      lists: previewLists,
      subtasks: [],
      onUpdate: update,
    });
    const host = mount(TaskDetailDrawer, props);
    await input(host, '[data-testid="detail-title-input"]', 'Updated title');
    element(host, '[data-testid="detail-title-input"]').dispatchEvent(
      new Event('blur'),
    );
    await nextTick();
    expect(update).toHaveBeenLastCalledWith(
      props.task.id,
      expect.objectContaining({ title: 'Updated title' }),
    );
    await input(host, '[data-testid="detail-notes-input"]', 'Updated notes');
    element(host, '[data-testid="detail-notes-input"]').dispatchEvent(
      new Event('blur'),
    );
    await nextTick();
    expect(update).toHaveBeenLastCalledWith(
      props.task.id,
      expect.objectContaining({ notes: 'Updated notes' }),
    );
    await input(
      host,
      '[data-testid="detail-date-input"]',
      '2026-10-15',
      'change',
    );
    expect(update).toHaveBeenLastCalledWith(
      props.task.id,
      expect.objectContaining({ dueDate: '2026-10-15' }),
    );
    await input(host, '[data-testid="detail-date-input"]', '', 'change');
    expect(update).toHaveBeenLastCalledWith(
      props.task.id,
      expect.objectContaining({ dueDate: null }),
    );
    await input(
      host,
      '[data-testid="detail-list-input"]',
      otherList.id,
      'change',
    );
    expect(update).toHaveBeenLastCalledWith(
      props.task.id,
      expect.objectContaining({ taskListId: otherList.id }),
    );
  });

  it('confirms task and subtask deletion with the same actions', async () => {
    const remove = vi.fn();
    const removeChild = vi.fn();
    const task = firstTask;
    const child = childTask;
    const host = mount(TaskDetailDrawer, {
      open: true,
      task,
      lists: previewLists,
      subtasks: [child],
      onDelete: remove,
      onDeleteSubtask: removeChild,
    });
    await click(host, '[data-testid="detail-delete-button"]');
    await click(host, '[data-testid="cancel-delete"]');
    expect(remove).not.toHaveBeenCalled();
    await click(host, '[data-testid="detail-subtask-delete"]');
    await click(host, '[data-testid="confirm-delete"]');
    expect(removeChild).toHaveBeenCalledExactlyOnceWith(child.id);
    await click(host, '[data-testid="detail-delete-button"]');
    await click(host, '[data-testid="confirm-delete"]');
    expect(remove).toHaveBeenCalledExactlyOnceWith(task.id);
  });

  it('labels the create-list field and emits only on confirmation', async () => {
    const create = vi.fn();
    const host = mount(TaskSidebar, {
      lists: previewLists,
      selectedListId: 'all',
      allOpenCount: 3,
      taskCountsByListId: new Map(),
      onCreateList: create,
    });
    await click(host, '[data-testid="create-list-trigger"]');
    const field = element<HTMLInputElement>(
      host,
      '[data-testid="modal"] input',
    );
    expect(host.querySelector(`label[for="${field.id}"]`)).not.toBeNull();
    await input(host, '[data-testid="modal"] input', 'New list');
    await click(host, '[data-testid="modal-ok"]');
    expect(create).toHaveBeenCalledExactlyOnceWith('New list');
  });

  it('does not render an external account connection flow', () => {
    const host = mount(TaskSidebar, {
      lists: previewLists,
      selectedListId: 'all',
      allOpenCount: 3,
      taskCountsByListId: new Map(),
    });

    expect(
      host.querySelector('[data-testid="google-account-connect"]'),
    ).toBeNull();
    expect(
      host.querySelector('[data-testid="sidebar-account-footer"]'),
    ).toBeNull();
  });
});

describe('workspace navigation and empty state', () => {
  async function mountLoadedPage(): Promise<HTMLElement> {
    const host = mount(PersonalTasksPage);
    await vi.waitFor(() =>
      expect(
        host.querySelector('[data-testid="task-detail-trigger"]'),
      ).not.toBeNull(),
    );
    return host;
  }

  it('renders the sidebar toggle first in the header with the filters and search', () => {
    const host = mount(PersonalTasksPage);
    const header = element(host, 'header');
    expect(header.querySelector('button')?.dataset.testid).toBe(
      'sidebar-toggle',
    );
    expect(host.querySelector('[data-testid="task-search"]')).not.toBeNull();
    expect(
      element(host, '[data-testid="today-filter-button"]').getAttribute(
        'aria-label',
      ),
    ).toBe('personalTasks.filters.today');
    expect(
      element(host, '[data-testid="starred-filter-button"]').getAttribute(
        'aria-label',
      ),
    ).toBe('personalTasks.filters.starred');
    expect(host.querySelector('#personal-task-sort')).toBeNull();
    expect(
      host.querySelector('[data-testid="sidebar-account-footer"]'),
    ).toBeNull();
  });

  it('collapses and expands the sidebar on desktop', async () => {
    const host = mount(PersonalTasksPage);
    const panel = element(host, '[data-testid="task-sidebar-panel"]');
    const toggle = element(host, '[data-testid="sidebar-toggle"]');
    expect(toggle.getAttribute('aria-expanded')).toBe('true');
    expect(panel.classList.contains('w-64')).toBe(true);

    await click(host, '[data-testid="sidebar-toggle"]');
    expect(toggle.getAttribute('aria-expanded')).toBe('false');
    expect(toggle.getAttribute('aria-label')).toBe(
      'personalTasks.sidebar.open',
    );
    expect(panel.classList.contains('w-0')).toBe(true);
    expect(panel.getAttribute('aria-hidden')).toBe('true');

    await click(host, '[data-testid="sidebar-toggle"]');
    expect(panel.classList.contains('w-64')).toBe(true);
  });

  it('opens the sidebar as a drawer on mobile and closes it after choosing a list', async () => {
    preferencesState.isMobile = true;
    const host = await mountLoadedPage();
    expect(host.querySelector('[data-testid="task-sidebar-panel"]')).toBeNull();
    expect(host.querySelector('[data-testid="drawer"]')).toBeNull();
    expect(
      element(host, '[data-testid="sidebar-toggle"]').getAttribute(
        'aria-expanded',
      ),
    ).toBe('false');

    await click(host, '[data-testid="sidebar-toggle"]');
    const drawer = element(host, '[data-testid="drawer"]');
    expect(
      drawer.querySelector('[data-testid="all-lists-option"]'),
    ).not.toBeNull();

    await click(
      host,
      `[data-testid="drawer"] [data-testid="task-list-option"][data-list-id="${otherList.id}"]`,
    );
    expect(host.querySelector('[data-testid="drawer"]')).toBeNull();
    expect(element(host, 'h1').textContent).toContain(otherList.title);
  });

  it('distinguishes search results from an empty list and clears search', async () => {
    const host = await mountLoadedPage();
    await input(host, '[data-testid="task-search"]', 'a-query-with-no-results');
    expect(
      element(host, '[data-testid="task-empty-state"]').textContent,
    ).toContain('personalTasks.taskList.noResultsTitle');
    await click(host, '[data-testid="clear-search-button"]');
    expect(host.querySelector('[data-testid="task-list"]')).not.toBeNull();
    await click(host, '[data-testid="create-list-trigger"]');
    await input(host, '[data-testid="modal"] input', 'Empty list');
    await click(host, '[data-testid="modal-ok"]');
    await vi.waitFor(() =>
      expect(
        element(host, '[data-testid="task-empty-state"]').textContent,
      ).toContain('personalTasks.taskList.emptyTitle'),
    );
    expect(
      element(host, '[data-testid="task-empty-state"]').textContent,
    ).toContain('personalTasks.taskList.emptyTitle');
    expect(
      host.querySelector('[data-testid="clear-search-button"]'),
    ).toBeNull();
  });

  it('returns focus to the task trigger when the detail drawer closes', async () => {
    const host = await mountLoadedPage();
    const trigger = element(host, '[data-testid="task-detail-trigger"]');
    trigger.focus();
    trigger.click();
    await nextTick();
    await click(host, '[data-testid="drawer-close"]');
    expect(document.activeElement).toBe(trigger);
  });
});

describe('pure task sorting and comparison logic', () => {
  it('puts starred tasks first regardless of due date', () => {
    const plainSoon = openTask({ due_date: '2026-10-01', starred: false });
    const starredUndated = openTask({ due_date: null, starred: true });

    expect(compareOpenTasks(starredUndated, plainSoon)).toBeLessThan(0);
    expect(compareOpenTasks(plainSoon, starredUndated)).toBeGreaterThan(0);
  });

  it('sorts by nearest due date within the same star state with undated tasks last', () => {
    const early = openTask({ due_date: '2026-10-01', position: 2 });
    const late = openTask({ due_date: '2026-10-10', position: 0 });
    const undated = openTask({ due_date: null, position: 1 });

    expect(compareOpenTasks(early, late)).toBeLessThan(0);
    expect(compareOpenTasks(late, undated)).toBeLessThan(0);
    expect(compareOpenTasks(undated, early)).toBeGreaterThan(0);
  });

  it('falls back to position when star state and due date match', () => {
    const first = openTask({ due_date: '2026-10-05', position: 0 });
    const second = openTask({ due_date: '2026-10-05', position: 1 });

    expect(compareOpenTasks(first, second)).toBeLessThan(0);
  });

  it('sorts completed tasks descending by completion time', () => {
    const earlier = completedTask('2026-10-01T10:00:00.000000Z');
    const later = completedTask('2026-10-02T10:00:00.000000Z');

    expect(compareCompletedTasks(earlier, later)).toBeGreaterThan(0);
    expect(compareCompletedTasks(later, earlier)).toBeLessThan(0);
  });
});
