import type { App } from 'vue';

import type { PersonalTaskList } from '#/api/contracts/personal-tasks';

import { createApp, defineComponent, h, nextTick } from 'vue';

import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import { previewLists } from './preview-data';
import { getTodayLocalDate } from './use-personal-tasks';

type Values = Record<string, unknown>;

interface SafeParser {
  safeParse: (value: unknown) => {
    error?: { issues: { message: string }[] };
    success: boolean;
  };
}

interface FieldSchema {
  component?: string;
  componentProps?: Record<string, unknown>;
  defaultValue?: unknown;
  dependencies?: {
    componentProps?: (values: Values) => Record<string, unknown>;
    disabled?: (values: Values) => boolean;
    if?: (values: Values) => boolean;
    rules?: (values: Values) => SafeParser;
    trigger?: (
      values: Values,
      form: { setFieldValue: (field: string, value: unknown) => void },
    ) => void;
    triggerFields?: string[];
  };
  fieldName: string;
  formItemClass?: string;
  hideLabel?: boolean;
  rules?: unknown;
}

const modalState = vi.hoisted(() => ({
  close: vi.fn(),
  data: null as unknown,
  lock: vi.fn(),
  options: null as null | {
    onConfirm: () => Promise<void>;
    onOpenChange: (open: boolean) => Promise<void>;
  },
  unlock: vi.fn(),
}));

const formState = vi.hoisted(() => ({
  config: null as null | { schema: FieldSchema[] },
  form: { setFieldError: vi.fn() },
  getValues: vi.fn(),
  resetForm: vi.fn(),
  setFieldValue: vi.fn(),
  setValues: vi.fn(),
  updateSchema: vi.fn(),
  validate: vi.fn(),
}));

vi.mock('@vben/common-ui', async (importOriginal) => ({
  ...(await importOriginal<typeof import('@vben/common-ui')>()),
  useVbenModal: (options: {
    onConfirm?: () => Promise<void> | void;
    onOpenChange?: (open: boolean) => Promise<void> | void;
  }) => {
    if (options.onConfirm === undefined || options.onOpenChange === undefined) {
      throw new Error('Task create modal handlers are missing');
    }
    modalState.options = {
      onConfirm: async () => options.onConfirm?.(),
      onOpenChange: async (open) => options.onOpenChange?.(open),
    };
    return [
      defineComponent(
        (_, { slots }) =>
          () =>
            h('div', [slots.title?.(), slots.default?.()]),
      ),
      {
        close: modalState.close,
        getData: () => modalState.data,
        lock: modalState.lock,
        unlock: modalState.unlock,
      },
    ];
  },
}));

vi.mock('#/adapter/form', async () => {
  const actual =
    await vi.importActual<typeof import('@vben/common-ui')>('@vben/common-ui');
  return {
    useVbenForm: (config: typeof formState.config) => {
      formState.config = config;
      return [
        defineComponent(
          (_, { slots }) =>
            () =>
              h('div', [slots.default?.()]),
        ),
        formState,
      ];
    },
    z: actual.z,
  };
});

vi.mock('@vben/icons', () => ({
  createIconifyIcon: () => ({ template: '<span aria-hidden="true"></span>' }),
}));

vi.mock('@vben/preferences', () => ({
  preferences: { app: { locale: 'en-US' } },
}));

vi.mock('#/locales', () => ({
  $t: (key: string, params?: Record<string, unknown>) =>
    params ? `${key} ${JSON.stringify(params)}` : key,
}));

vi.mock('#/api/personal-tasks', () => ({
  createPersonalTaskApi: vi.fn(),
  createTaskListApi: vi.fn(),
  deletePersonalTaskApi: vi.fn(),
  deleteTaskListApi: vi.fn(),
  getPersonalTasksApi: vi.fn(),
  movePersonalTaskApi: vi.fn(),
  updatePersonalTaskApi: vi.fn(),
  updateTaskListApi: vi.fn(),
}));

const [defaultList, otherList] = previewLists;
if (!defaultList?.is_default || !otherList) {
  throw new Error('Personal task list fixtures are incomplete');
}

let app: App | null = null;
let host: HTMLElement;

beforeEach(async () => {
  vi.clearAllMocks();
  const { default: TaskCreateModal } =
    await import('./components/task-create-modal.vue');
  host = document.createElement('div');
  app = createApp(TaskCreateModal);
  app.mount(host);
});

afterEach(() => {
  app?.unmount();
  app = null;
});

function field(name: string): FieldSchema {
  const schema = formState.config?.schema.find(
    (item) => item.fieldName === name,
  );
  if (!schema) throw new Error(`Missing ${name} field`);
  return schema;
}

function openWith(data: {
  isStarredFilterActive?: boolean;
  lists?: PersonalTaskList[];
  saveTask?: () => Promise<boolean>;
  selectedListId?: string;
}): Promise<void> {
  modalState.data = {
    isStarredFilterActive: false,
    lists: previewLists,
    saveTask: vi.fn(async () => true),
    selectedListId: 'all',
    ...data,
  };
  if (!modalState.options) throw new Error('Modal was not configured');
  return modalState.options.onOpenChange(true);
}

function dependencies(name: string): NonNullable<FieldSchema['dependencies']> {
  const fieldDependencies = field(name).dependencies;
  if (!fieldDependencies) throw new Error(`Missing ${name} dependencies`);
  return fieldDependencies;
}

function starButton(): HTMLButtonElement {
  const button = host.querySelector<HTMLButtonElement>(
    '[data-testid="create-task-star"]',
  );
  if (!button) throw new Error('Missing star button');
  return button;
}

function optionsOf(
  name: string,
  values: Values,
): { label: string; value: string }[] {
  const componentProps = dependencies(name).componentProps;
  if (!componentProps) throw new Error(`Missing ${name} component props`);
  return componentProps(values).options as { label: string; value: string }[];
}

function isShown(name: string, values: Values): boolean {
  const condition = dependencies(name).if;
  if (!condition) throw new Error(`Missing ${name} visibility`);
  return condition(values);
}

const submitValues = async (
  values: Values,
): Promise<ReturnType<typeof vi.fn>> => {
  const saveTask = vi.fn(async () => true);
  await openWith({ saveTask });
  formState.validate.mockResolvedValue({ valid: true });
  formState.getValues.mockResolvedValue({
    end_type: 'never',
    frequency: 'week',
    interval: 1,
    task_list_id: defaultList.id,
    title: 'Task',
    ...values,
  });
  await confirm();
  return saveTask;
};

const rule = (overrides: Values) => ({
  count: null,
  interval: 1,
  until: null,
  weekdays: null,
  ...overrides,
});

function confirm(): Promise<void> {
  if (!modalState.options) throw new Error('Modal was not configured');
  return modalState.options.onConfirm();
}

describe('task create modal', () => {
  it('defaults to today, the open or default list and the starred filter on open', async () => {
    await openWith({ isStarredFilterActive: true, selectedListId: 'starred' });

    expect(formState.updateSchema).toHaveBeenCalledWith([
      {
        componentProps: {
          options: previewLists.map((list) => ({
            label: list.title,
            value: list.id,
          })),
        },
        fieldName: 'task_list_id',
      },
    ]);
    expect(formState.resetForm).toHaveBeenCalledOnce();
    expect(formState.setValues).toHaveBeenCalledExactlyOnceWith({
      due_date: getTodayLocalDate(),
      task_list_id: defaultList.id,
    });
    await nextTick();
    expect(starButton().getAttribute('aria-pressed')).toBe('true');

    await openWith({ selectedListId: otherList.id });
    expect(formState.setValues).toHaveBeenLastCalledWith({
      due_date: getTodayLocalDate(),
      task_list_id: otherList.id,
    });
    await nextTick();
    expect(starButton().getAttribute('aria-pressed')).toBe('false');
  });

  it('toggles the header star and saves it with the task', async () => {
    const saveTask = vi.fn(async () => true);
    await openWith({ saveTask });
    await nextTick();
    expect(host.textContent).toContain('personalTasks.create.modalTitle');

    starButton().click();
    await nextTick();
    expect(starButton().getAttribute('aria-pressed')).toBe('true');
    expect(starButton().getAttribute('aria-label')).toBe(
      'personalTasks.actions.removeStar',
    );

    formState.validate.mockResolvedValue({ valid: true });
    formState.getValues.mockResolvedValue({
      due_date: null,
      task_list_id: defaultList.id,
      title: 'Starred task',
    });
    await confirm();
    expect(saveTask).toHaveBeenCalledWith(
      expect.objectContaining({ starred: true }),
    );
  });

  it('builds every input from Vben form schema fields', () => {
    expect(
      formState.config?.schema.map((item) => [item.fieldName, item.component]),
    ).toEqual([
      ['title', 'Input'],
      ['due_date', 'DatePicker'],
      ['task_list_id', 'Select'],
      ['repeat', 'Select'],
      ['custom_divider', 'Divider'],
      ['interval', 'InputNumber'],
      ['frequency', 'Select'],
      ['weekdays', 'CheckboxGroup'],
      ['end_type', 'RadioGroup'],
      ['until', 'DatePicker'],
      ['count', 'InputNumber'],
      ['notes', 'Textarea'],
    ]);
  });

  it('rejects blank titles and caps lengths like the server', () => {
    const title = field('title');
    const titleRule = title.rules as SafeParser;

    expect(titleRule.safeParse('   ').success).toBe(false);
    expect(titleRule.safeParse('x'.repeat(1025)).success).toBe(false);
    expect(titleRule.safeParse('Task').success).toBe(true);
    expect(title.componentProps?.maxlength).toBe(1024);
    expect(field('notes').componentProps?.maxlength).toBe(8192);
  });

  it('saves a trimmed payload and closes', async () => {
    const saveTask = await submitValues({
      due_date: '2026-10-12',
      notes: '   ',
      task_list_id: otherList.id,
      title: '  Trim me  ',
    });

    expect(saveTask).toHaveBeenCalledExactlyOnceWith({
      dueDate: '2026-10-12',
      listId: otherList.id,
      notes: null,
      recurrence: null,
      starred: false,
      title: 'Trim me',
    });
    expect(modalState.lock).toHaveBeenCalledOnce();
    expect(modalState.unlock).toHaveBeenCalledOnce();
    expect(modalState.close).toHaveBeenCalledOnce();
  });

  it('stays open when saving fails and skips saving invalid forms', async () => {
    const saveTask = vi.fn(async () => false);
    await openWith({ saveTask });
    formState.validate.mockResolvedValue({ valid: true });
    formState.getValues.mockResolvedValue({
      due_date: null,
      task_list_id: defaultList.id,
      title: 'Retry me',
    });

    await confirm();
    expect(saveTask).toHaveBeenCalledOnce();
    expect(modalState.close).not.toHaveBeenCalled();

    formState.validate.mockResolvedValue({ valid: false });
    await confirm();
    expect(saveTask).toHaveBeenCalledOnce();
  });

  it('ignores duplicate submissions while the first save is pending', async () => {
    let finishSave: ((saved: boolean) => void) | undefined;
    const saveTask = vi.fn(
      () =>
        new Promise<boolean>((resolve) => {
          finishSave = resolve;
        }),
    );
    await openWith({ saveTask });
    formState.validate.mockResolvedValue({ valid: true });
    formState.getValues.mockResolvedValue({
      due_date: '2026-10-08',
      task_list_id: defaultList.id,
      title: 'Only once',
    });

    const firstSubmit = confirm();
    const duplicateSubmit = confirm();
    await vi.waitFor(() => expect(saveTask).toHaveBeenCalledOnce());

    expect(formState.validate).toHaveBeenCalledOnce();
    expect(modalState.lock).toHaveBeenCalledOnce();
    if (finishSave === undefined) throw new Error('Save was not started');
    finishSave(true);
    await Promise.all([firstSubmit, duplicateSubmit]);

    expect(modalState.close).toHaveBeenCalledOnce();
    expect(modalState.unlock).toHaveBeenCalledOnce();
  });

  it('offers Google Tasks style repeat options derived from the due date', () => {
    const options = optionsOf('repeat', { due_date: '2026-10-08' });

    expect(options.map((option) => option.value)).toEqual([
      'daily',
      'weekdays',
      'weekly',
      'monthly',
      'yearly',
      'custom',
    ]);
    expect(options.map((option) => option.label)).toEqual([
      'personalTasks.recurrence.daily',
      'personalTasks.recurrence.weekdaysPreset',
      'personalTasks.recurrence.weekly {"weekday":"Thursday"}',
      'personalTasks.recurrence.monthly {"day":"8"}',
      'personalTasks.recurrence.yearly {"date":"October 8"}',
      'personalTasks.recurrence.custom',
    ]);
    expect(field('repeat')).toMatchObject({
      componentProps: { placeholder: 'personalTasks.recurrence.none' },
      formItemClass: 'col-span-full',
    });
  });

  it('disables and clears the repeat without a due date', () => {
    const repeat = dependencies('repeat');
    const form = { setFieldValue: vi.fn() };

    expect(optionsOf('repeat', { due_date: null })).toEqual([]);
    expect(repeat.disabled?.({ due_date: null })).toBe(true);
    expect(repeat.disabled?.({ due_date: '2026-10-08' })).toBe(false);
    repeat.trigger?.({ due_date: '2026-10-08' }, form);
    expect(form.setFieldValue).not.toHaveBeenCalled();
    repeat.trigger?.({ due_date: null }, form);
    expect(form.setFieldValue).toHaveBeenCalledExactlyOnceWith(
      'repeat',
      undefined,
    );
  });

  it('shows the custom recurrence fields only for the matching choices', () => {
    for (const name of [
      'custom_divider',
      'interval',
      'frequency',
      'end_type',
    ]) {
      expect(isShown(name, { repeat: 'custom' })).toBe(true);
      expect(isShown(name, { repeat: 'weekly' })).toBe(false);
    }
    expect(isShown('weekdays', { frequency: 'week', repeat: 'custom' })).toBe(
      true,
    );
    expect(isShown('weekdays', { frequency: 'day', repeat: 'custom' })).toBe(
      false,
    );
    expect(isShown('until', { end_type: 'on', repeat: 'custom' })).toBe(true);
    expect(isShown('until', { end_type: 'after', repeat: 'custom' })).toBe(
      false,
    );
    expect(isShown('count', { end_type: 'after', repeat: 'custom' })).toBe(
      true,
    );
    expect(isShown('count', { end_type: 'after', repeat: 'daily' })).toBe(
      false,
    );
  });

  it('defaults the custom weekdays to the due date weekday and pluralizes units', () => {
    const form = { setFieldValue: vi.fn() };
    const weekdays = dependencies('weekdays');

    weekdays.trigger?.({ due_date: '2026-10-08', repeat: 'custom' }, form);
    expect(form.setFieldValue).toHaveBeenCalledExactlyOnceWith('weekdays', [4]);
    weekdays.trigger?.(
      { due_date: '2026-10-08', repeat: 'custom', weekdays: [1] },
      form,
    );
    expect(form.setFieldValue).toHaveBeenCalledOnce();

    const units = (interval: number) =>
      optionsOf('frequency', { interval }).map((option) => option.label);
    expect(units(1)[1]).toBe('personalTasks.recurrence.units.week');
    expect(units(2)[1]).toBe('personalTasks.recurrence.units.weekPlural');
  });

  it('validates custom recurrence inputs', () => {
    const untilRule = dependencies('until').rules?.({ due_date: '2026-10-08' });
    if (!untilRule) throw new Error('Missing until rule');
    expect(untilRule.safeParse('2026-10-07').success).toBe(false);
    expect(untilRule.safeParse('2026-10-08').success).toBe(true);
    expect(untilRule.safeParse(undefined).success).toBe(false);

    const intervalRule = field('interval').rules as SafeParser;
    expect(intervalRule.safeParse(0).success).toBe(false);
    expect(intervalRule.safeParse(1000).success).toBe(false);
    expect(intervalRule.safeParse(2).success).toBe(true);
    expect((field('weekdays').rules as SafeParser).safeParse([]).success).toBe(
      false,
    );
    expect(
      (field('weekdays').rules as SafeParser).safeParse([1, 1]).success,
    ).toBe(false);
    expect((field('weekdays').rules as SafeParser).safeParse([7]).success).toBe(
      false,
    );
    expect(untilRule.safeParse('2026-02-30').success).toBe(false);
    expect(
      (field('weekdays').rules as SafeParser).safeParse([]).error?.issues[0]
        ?.message,
    ).toBe('personalTasks.recurrence.weekdaysRequired');
    expect(
      (field('count').rules as SafeParser).safeParse(undefined).success,
    ).toBe(false);
  });

  it.each(['interval', 'count'])(
    'only lets digits into the %s input',
    (name) => {
      const { parser } = field(name).componentProps as {
        parser: (value: string) => string;
      };

      expect(parser('4.5')).toBe('45');
      expect(parser('-3')).toBe('3');
      expect(parser('1e2')).toBe('12');
      expect(parser('12')).toBe('12');
    },
  );

  it.each([
    ['interval', { interval: 0 }],
    ['frequency', { frequency: undefined }],
    ['weekdays', { weekdays: [1, 1] }],
    ['weekdays', { weekdays: [7] }],
    ['count', { count: 0, end_type: 'after' }],
    ['count', { end_type: 'after' }],
    ['until', { end_type: 'on' }],
    ['until', { end_type: 'on', until: '2026-02-30' }],
    ['until', { end_type: 'on', until: '2026-10-07' }],
    ['end_type', { end_type: undefined }],
    ['due_date', { due_date: null }],
  ])(
    'shows invalid recurrence on %s without rejecting submit',
    async (fieldName, invalid) => {
      const saveTask = await submitValues({
        due_date: '2026-10-08',
        repeat: 'custom',
        weekdays: [4],
        ...invalid,
      });
      expect(saveTask).not.toHaveBeenCalled();
      expect(formState.form.setFieldError).toHaveBeenCalledWith(
        fieldName,
        expect.any(String),
      );
      expect(modalState.lock).not.toHaveBeenCalled();
      expect(modalState.close).not.toHaveBeenCalled();
    },
  );

  it('ignores inactive custom inputs when validating a preset', async () => {
    const saveTask = await submitValues({
      count: 'invalid',
      due_date: '2026-10-08',
      end_type: 'invalid',
      frequency: 'invalid',
      interval: 'invalid',
      repeat: 'daily',
      until: 'invalid',
      weekdays: 'invalid',
    });
    expect(saveTask).toHaveBeenCalledWith(
      expect.objectContaining({ recurrence: rule({ frequency: 'day' }) }),
    );
    expect(formState.form.setFieldError).not.toHaveBeenCalled();
  });

  it('allows correcting recurrence input and submitting again', async () => {
    const saveTask = await submitValues({
      count: 0,
      due_date: '2026-10-08',
      end_type: 'after',
      repeat: 'custom',
      weekdays: [4],
    });
    expect(saveTask).not.toHaveBeenCalled();
    formState.getValues.mockResolvedValue({
      count: 2,
      due_date: '2026-10-08',
      end_type: 'after',
      frequency: 'week',
      interval: 1,
      repeat: 'custom',
      task_list_id: defaultList.id,
      title: 'Task',
      weekdays: [4],
    });
    await confirm();
    expect(saveTask).toHaveBeenCalledOnce();
    expect(modalState.close).toHaveBeenCalledOnce();
  });

  it('saves monthly weekday recurrence as a distinct pattern', async () => {
    const saveTask = await submitValues({
      due_date: '2026-10-08',
      frequency: 'month_weekday',
      interval: 2,
      repeat: 'custom',
    });
    expect(saveTask).toHaveBeenCalledWith(
      expect.objectContaining({
        recurrence: rule({ frequency: 'month_weekday', interval: 2 }),
      }),
    );
  });

  it.each([
    ['daily', rule({ frequency: 'day' })],
    ['weekdays', rule({ frequency: 'week', weekdays: [1, 2, 3, 4, 5] })],
    ['weekly', rule({ frequency: 'week', weekdays: [4] })],
    ['monthly', rule({ frequency: 'month' })],
    ['yearly', rule({ frequency: 'year' })],
  ])('saves the %s preset as a recurrence rule', async (repeat, expected) => {
    const saveTask = await submitValues({ due_date: '2026-10-08', repeat });

    expect(saveTask).toHaveBeenCalledWith(
      expect.objectContaining({ dueDate: '2026-10-08', recurrence: expected }),
    );
  });

  it('saves a custom recurrence and ignores fields of other end choices', async () => {
    const afterCount = await submitValues({
      count: 3,
      due_date: '2026-10-05',
      end_type: 'after',
      frequency: 'week',
      interval: 2,
      repeat: 'custom',
      until: '2026-12-31',
      weekdays: [3, 1],
    });
    expect(afterCount).toHaveBeenCalledWith(
      expect.objectContaining({
        recurrence: rule({
          count: 3,
          frequency: 'week',
          interval: 2,
          weekdays: [1, 3],
        }),
      }),
    );

    const onDate = await submitValues({
      count: 3,
      due_date: '2026-10-05',
      end_type: 'on',
      frequency: 'month',
      interval: 3,
      repeat: 'custom',
      until: '2027-10-05',
      weekdays: [1],
    });
    expect(onDate).toHaveBeenCalledWith(
      expect.objectContaining({
        recurrence: rule({
          frequency: 'month',
          interval: 3,
          until: '2027-10-05',
        }),
      }),
    );
  });

  it('saves on title Enter but ignores IME composition', async () => {
    const saveTask = vi.fn(async () => true);
    await openWith({ saveTask });
    formState.validate.mockResolvedValue({ valid: true });
    formState.getValues.mockResolvedValue({
      due_date: null,
      task_list_id: defaultList.id,
      title: 'Enter task',
    });
    const onPressEnter = field('title').componentProps?.onPressEnter as (
      event: KeyboardEvent,
    ) => void;

    onPressEnter(new KeyboardEvent('keydown', { isComposing: true }));
    expect(formState.validate).not.toHaveBeenCalled();

    onPressEnter(new KeyboardEvent('keydown', { key: 'Enter' }));
    await vi.waitFor(() => expect(saveTask).toHaveBeenCalledOnce());
  });
});
