import type { WorkShift } from '#/api/work-shifts';

import { createApp, defineComponent, h, nextTick, reactive, ref } from 'vue';

import { afterAll, beforeEach, describe, expect, it, vi } from 'vitest';

import enWorkShifts from '#/locales/langs/en-US/workShifts.json';
import viWorkShifts from '#/locales/langs/vi-VN/workShifts.json';
import zhWorkShifts from '#/locales/langs/zh-CN/workShifts.json';

import ShiftConfigModal from './shift-config-modal.vue';

vi.hoisted(() => {
  vi.stubEnv('VITE_GLOB_BACKEND_URL', undefined);
});

// cspell:ignore unstub
afterAll(() => {
  vi.unstubAllEnvs();
});

const translationLocale = ref<'en-US' | 'vi-VN' | 'zh-CN'>('vi-VN');
const messagesByLocale = {
  'en-US': enWorkShifts,
  'vi-VN': viWorkShifts,
  'zh-CN': zhWorkShifts,
};

const api = vi.hoisted(() => ({
  createWorkShift: vi.fn(),
  updateWorkShift: vi.fn(),
  deleteWorkShift: vi.fn(),
}));

vi.mock('#/api/work-shifts', () => ({
  createWorkShift: api.createWorkShift,
  updateWorkShift: api.updateWorkShift,
  deleteWorkShift: api.deleteWorkShift,
}));

vi.mock('#/shared/request-feedback', () => ({
  showRequestError: vi.fn(),
}));

vi.mock('@vben/icons', () => ({ IconifyIcon: { render: () => null } }));

vi.mock('#/locales', () => ({
  $t: (key: string, params: Record<string, number | string> = {}) => {
    let message: unknown = {
      workShifts: messagesByLocale[translationLocale.value],
    };
    for (const segment of key.split('.')) {
      if (typeof message !== 'object' || message === null)
        throw new Error(`Missing translation: ${key}`);
      message = (message as Record<string, unknown>)[segment];
    }
    if (typeof message !== 'string')
      throw new Error(`Missing translation: ${key}`);
    return message.replaceAll(/\{(\w+)\}/g, (_match, field: string) => {
      if (params[field] === undefined)
        throw new Error(`Missing interpolation: ${key}.${field}`);
      return String(params[field]);
    });
  },
}));

vi.mock('@vben/common-ui', async (importOriginal) => {
  const actual = (await importOriginal()) as Record<string, unknown>;
  return {
    ...actual,
    useVbenModal: (options: Record<string, unknown>) => {
      const state = reactive({ open: false, title: options.title });
      return [
        defineComponent({
          setup(_props, { slots }) {
            return () =>
              state.open
                ? h('div', { 'data-testid': 'modal' }, [
                    h('h2', String(state.title)),
                    slots.default?.(),
                    slots.footer?.(),
                  ])
                : null;
          },
        }),
        {
          open: () => {
            state.open = true;
          },
          close: () => {
            state.open = false;
          },
          setState: ({ title }: { title: string }) => {
            state.title = title;
          },
        },
      ];
    },
  };
});

vi.mock('ant-design-vue', () => {
  const wrapper = defineComponent({
    setup(_props, { slots }) {
      return () => h('div', slots.default?.());
    },
  });

  return {
    Alert: defineComponent({
      props: ['message', 'description', 'type'],
      template: '<div role="alert">{{ message }} {{ description }}</div>',
    }),
    Button: defineComponent({
      props: ['disabled', 'loading'],
      emits: ['click'],
      template:
        '<button :disabled="disabled" @click="$emit(\'click\')"><slot /></button>',
    }),
    Checkbox: defineComponent({
      props: { checked: Boolean },
      emits: ['update:checked'],
      setup(props, { slots, emit }) {
        return () =>
          h('label', [
            h('input', {
              type: 'checkbox',
              checked: props.checked,
              onClick: () => emit('update:checked', !props.checked),
            }),
            slots.default?.(),
          ]);
      },
    }),
    Empty: wrapper,
    Form: {
      useForm: () => ({
        validate: async () => undefined,
        validateInfos: {},
        clearValidate: () => undefined,
      }),
    },
    FormItem: wrapper,
    Input: defineComponent({
      props: ['value'],
      emits: ['update:value'],
      template:
        '<input :value="value" @input="$emit(\'update:value\', $event.target.value)" />',
    }),
    Modal: defineComponent({
      props: ['open', 'title'],
      setup(props, { slots }) {
        return () =>
          props.open
            ? h('div', { 'data-testid': 'modal' }, slots.default?.())
            : null;
      },
    }),
    notification: { success: vi.fn(), error: vi.fn(), warning: vi.fn() },
    Popconfirm: defineComponent({
      emits: ['confirm'],
      setup(_props, { slots, emit }) {
        return () =>
          h('div', [
            slots.default?.(),
            h(
              'button',
              {
                'data-testid': 'confirm-delete',
                onClick: () => emit('confirm'),
              },
              'Confirm',
            ),
          ]);
      },
    }),
    Select: defineComponent({
      props: ['value', 'options'],
      emits: ['update:value'],
      setup(props, { emit }) {
        return () =>
          h(
            'select',
            {
              value: props.value,
              onChange: (e: Event) =>
                emit(
                  'update:value',
                  Number((e.target as HTMLSelectElement).value),
                ),
            },
            props.options?.map((opt: { label: string; value: number }) =>
              h('option', { value: opt.value }, opt.label),
            ),
          );
      },
    }),
    Tag: defineComponent({
      template: '<span><slot /></span>',
    }),
    TimePicker: defineComponent({
      props: ['value', 'allowClear'],
      emits: ['update:value'],
      template:
        '<input :data-clearable="allowClear" class="time-picker" :value="value" @input="$emit(\'update:value\', $event.target.value)" />',
    }),
  };
});

const mockShifts: WorkShift[] = [
  {
    id: 'shift-1',
    root_organization_id: 'root-1',
    name: 'Ca hành chính',
    created_by: 'creator',
    created_at: null,
    updated_at: null,
    periods: [
      {
        id: 'p1',
        work_shift_id: 'shift-1',
        start_time: '08:00:00',
        end_time: '12:00:00',
        start_day_offset: 0,
        end_day_offset: 0,
        created_at: null,
        updated_at: null,
      },
      {
        id: 'p2',
        work_shift_id: 'shift-1',
        start_time: '13:30:00',
        end_time: '17:30:00',
        start_day_offset: 0,
        end_day_offset: 0,
        created_at: null,
        updated_at: null,
      },
    ],
  },
  {
    id: 'shift-2',
    root_organization_id: 'root-1',
    name: 'Ca đêm',
    created_by: 'creator',
    created_at: null,
    updated_at: null,
    periods: [
      {
        id: 'p3',
        work_shift_id: 'shift-2',
        start_time: '22:00:00',
        end_time: '06:00:00',
        start_day_offset: 0,
        end_day_offset: 1,
        created_at: null,
        updated_at: null,
      },
    ],
  },
];

describe('shiftConfigModal', () => {
  beforeEach(() => {
    translationLocale.value = 'vi-VN';
    vi.clearAllMocks();
  });

  it('mounts closed without accessing uninitialized form state', () => {
    const root = document.createElement('div');
    const app = createApp(ShiftConfigModal, {
      open: false,
      shifts: mockShifts,
      rootOrganizationId: 'root-1',
      canCreate: false,
      canUpdate: false,
      canDelete: false,
    });
    expect(() => app.mount(root)).not.toThrow();
    app.unmount();
  });

  it.each(['create', 'update', 'delete'])(
    'gates %s permission independently',
    async (permission) => {
      const root = document.createElement('div');
      const app = createApp(ShiftConfigModal, {
        open: true,
        shifts: mockShifts,
        rootOrganizationId: 'root-1',
        canCreate: permission === 'create',
        canUpdate: permission === 'update',
        canDelete: permission === 'delete',
      });
      app.mount(root);
      await nextTick();
      expect(root.querySelector('[data-testid="add-shift-btn"]') !== null).toBe(
        permission === 'create',
      );
      const buttons = [...root.querySelectorAll('button')];
      expect(
        buttons.some((button) => button.textContent?.includes('Sửa')),
      ).toBe(permission === 'update');
      expect(
        root.querySelector('[data-testid="confirm-delete"]') !== null,
      ).toBe(permission === 'delete');
      if (permission === 'create') {
        root
          .querySelector<HTMLButtonElement>('[data-testid="add-shift-btn"]')
          ?.click();
        await nextTick();
      }
      expect(
        root.querySelectorAll('.time-picker[data-clearable="false"]'),
      ).toHaveLength(permission === 'create' ? 2 : 0);
      app.unmount();
    },
  );

  it('hides day selectors when overnight is off and requires explicit next-day selection', async () => {
    const root = document.createElement('div');
    const app = createApp(ShiftConfigModal, {
      open: true,
      shifts: mockShifts,
      rootOrganizationId: 'root-1',
      canCreate: true,
      canUpdate: true,
      canDelete: true,
    });
    app.mount(root);
    root
      .querySelector<HTMLButtonElement>('[data-testid="add-shift-btn"]')
      ?.click();
    await nextTick();
    const times = root.querySelectorAll<HTMLInputElement>('.time-picker');
    if (times[0] === undefined || times[1] === undefined)
      throw new Error('Missing times');
    times[0].value = '22:00:00';
    times[0].dispatchEvent(new Event('input'));
    times[1].value = '06:00:00';
    times[1].dispatchEvent(new Event('input'));
    await nextTick();
    expect(root.textContent).toContain('Giờ kết thúc phải sau giờ bắt đầu.');
    expect(root.querySelectorAll('select')).toHaveLength(0);
    const checkbox = root.querySelector<HTMLInputElement>(
      'input[type="checkbox"]',
    );
    if (checkbox === null) throw new Error('Missing checkbox');
    checkbox.click();
    await nextTick();
    expect(root.querySelectorAll('select')).toHaveLength(2);
    const endDay = root.querySelectorAll<HTMLSelectElement>('select')[1];
    if (endDay === undefined) throw new Error('Missing end day');
    expect(endDay.value).toBe('0');
    endDay.value = '1';
    endDay.dispatchEvent(new Event('change'));
    await nextTick();
    expect(root.textContent).not.toContain(
      'Giờ kết thúc phải sau giờ bắt đầu.',
    );
    checkbox.click();
    await nextTick();
    expect(root.querySelectorAll('select')).toHaveLength(0);
    expect(root.textContent).toContain('Giờ kết thúc phải sau giờ bắt đầu.');
    app.unmount();
  });

  it('opens existing overnight periods with their saved day offsets', async () => {
    const root = document.createElement('div');
    const app = createApp(ShiftConfigModal, {
      open: true,
      shifts: mockShifts,
      rootOrganizationId: 'root-1',
      canCreate: true,
      canUpdate: true,
      canDelete: true,
    });
    app.mount(root);
    const editButtons = [
      ...root.querySelectorAll<HTMLButtonElement>('button'),
    ].filter((button) => button.textContent?.includes('Sửa'));
    editButtons[1]?.click();
    await nextTick();
    const checkbox = root.querySelector<HTMLInputElement>(
      'input[type="checkbox"]',
    );
    if (checkbox === null) throw new Error('Missing checkbox');
    expect(checkbox.checked).toBe(true);
    expect(
      [...root.querySelectorAll<HTMLSelectElement>('select')].map(
        (select) => select.value,
      ),
    ).toEqual(['0', '1']);
    expect(root.querySelectorAll('[data-testid="modal"]')).toHaveLength(2);
    app.unmount();
  });

  it('adds and removes periods through labeled icon buttons', async () => {
    const root = document.createElement('div');
    const app = createApp(ShiftConfigModal, {
      open: true,
      shifts: mockShifts,
      rootOrganizationId: 'root-1',
      canCreate: true,
      canUpdate: true,
      canDelete: true,
    });
    app.mount(root);
    root
      .querySelector<HTMLButtonElement>('[data-testid="add-shift-btn"]')
      ?.click();
    await nextTick();
    const addButton = root.querySelector<HTMLButtonElement>(
      '[aria-label="Thêm khoảng"]',
    );
    if (addButton === null) throw new Error('Missing add period');
    expect(addButton.textContent).toContain('Thêm khoảng');
    addButton.click();
    await nextTick();
    expect(root.querySelectorAll('.time-picker')).toHaveLength(4);
    const deleteButton = root.querySelector<HTMLButtonElement>(
      '[aria-label="Xóa khoảng 2"]',
    );
    if (deleteButton === null) throw new Error('Missing remove period');
    expect(deleteButton.textContent).toBe('');
    deleteButton.click();
    await nextTick();
    expect(root.querySelectorAll('.time-picker')).toHaveLength(2);
    app.unmount();
  });

  it('updates open modal titles, labels, day options and validation when changing language', async () => {
    const root = document.createElement('div');
    const app = createApp(ShiftConfigModal, {
      open: true,
      shifts: mockShifts,
      rootOrganizationId: 'root-1',
      canCreate: true,
      canUpdate: true,
      canDelete: true,
    });
    app.mount(root);
    root
      .querySelector<HTMLButtonElement>('[data-testid="add-shift-btn"]')
      ?.click();
    await nextTick();
    const times = root.querySelectorAll<HTMLInputElement>('.time-picker');
    if (times[0] === undefined || times[1] === undefined)
      throw new Error('Missing times');
    times[0].value = '22:00:00';
    times[0].dispatchEvent(new Event('input'));
    times[1].value = '06:00:00';
    times[1].dispatchEvent(new Event('input'));
    const checkbox = root.querySelector<HTMLInputElement>(
      'input[type="checkbox"]',
    );
    if (checkbox === null) throw new Error('Missing checkbox');
    checkbox.click();
    await nextTick();
    translationLocale.value = 'en-US';
    await nextTick();
    expect(root.textContent).toContain('Shift configuration & catalog');
    expect(root.textContent).toContain('Add work shift');
    expect(root.textContent).toContain('Work across midnight');
    expect(root.textContent).toContain('End time must be after start time.');
    expect(
      [...root.querySelectorAll('select option')].map(
        (option) => option.textContent,
      ),
    ).toEqual(['Assignment day', 'Next day', 'Assignment day', 'Next day']);
    translationLocale.value = 'zh-CN';
    await nextTick();
    expect(root.textContent).toContain('班次配置与目录');
    expect(root.textContent).toContain('新增班次');
    expect(root.textContent).toContain('跨日工作');
    expect(root.textContent).toContain('结束时间必须晚于开始时间。');
    app.unmount();
  });

  it('renders list of shifts with names, periods and total hours', async () => {
    const root = document.createElement('div');
    const app = createApp(ShiftConfigModal, {
      open: true,
      shifts: mockShifts,
      rootOrganizationId: 'root-1',
      canCreate: true,
      canUpdate: true,
      canDelete: true,
    });
    app.mount(root);
    await nextTick();

    expect(root.textContent).toContain('Ca hành chính');
    expect(root.textContent).toContain('Tổng: 8 giờ · 2 khoảng');
    expect(root.textContent).toContain('Ca đêm');
    expect(root.textContent).toContain('Tổng: 8 giờ · 1 khoảng');
    expect(root.textContent).toContain('08:00');
    expect(root.textContent).toContain('4 giờ');
    expect(root.textContent).toContain('06:00+1');
    expect(root.textContent).toContain('+1 = hôm sau');

    app.unmount();
  });

  it('opens edit form and displays overnight warning alert', async () => {
    const root = document.createElement('div');
    const app = createApp(ShiftConfigModal, {
      open: true,
      shifts: mockShifts,
      rootOrganizationId: 'root-1',
      canCreate: true,
      canUpdate: true,
      canDelete: true,
    });
    app.mount(root);
    await nextTick();

    const editButtons = [
      ...root.querySelectorAll<HTMLButtonElement>('button'),
    ].filter((b) => b.textContent?.includes('Sửa'));
    expect(editButtons.length).toBe(2);

    editButtons[0]?.click();
    await nextTick();

    expect(root.textContent).toContain('Chỉnh sửa ca làm việc');
    expect(root.textContent).toContain('áp dụng cho mọi ngày đã phân ca này');

    app.unmount();
  });

  it('deletes shift when confirmed and emits refresh', async () => {
    api.deleteWorkShift.mockResolvedValueOnce(undefined);
    const onRefresh = vi.fn();
    const root = document.createElement('div');
    const app = createApp(ShiftConfigModal, {
      open: true,
      shifts: mockShifts,
      rootOrganizationId: 'root-1',
      canCreate: true,
      canUpdate: true,
      canDelete: true,
      onRefresh,
    });
    app.mount(root);
    await nextTick();

    const deleteConfirmBtn = root.querySelector<HTMLButtonElement>(
      '[data-testid="confirm-delete"]',
    );
    expect(deleteConfirmBtn).toBeDefined();
    deleteConfirmBtn?.click();
    await nextTick();

    expect(api.deleteWorkShift).toHaveBeenCalledWith('shift-1');

    app.unmount();
  });

  it('opens create form, submits new shift and emits refresh', async () => {
    api.createWorkShift.mockResolvedValueOnce({
      id: 'shift-new',
      root_organization_id: 'root-1',
      name: 'Ca mới',
      periods: [],
    });
    const onRefresh = vi.fn();
    const root = document.createElement('div');
    const app = createApp(ShiftConfigModal, {
      open: true,
      shifts: mockShifts,
      rootOrganizationId: 'root-1',
      canCreate: true,
      canUpdate: true,
      canDelete: true,
      onRefresh,
    });
    app.mount(root);
    await nextTick();

    const addBtn = root.querySelector<HTMLButtonElement>(
      '[data-testid="add-shift-btn"]',
    );
    expect(addBtn).toBeDefined();
    addBtn?.click();
    await nextTick();

    expect(root.textContent).toContain('Thêm ca làm việc mới');

    const nameInput = root.querySelector<HTMLInputElement>('input');
    if (nameInput === null) throw new Error('Missing shift name');
    nameInput.value = 'Ca mới';
    nameInput.dispatchEvent(new Event('input'));
    const timeInputs = root.querySelectorAll<HTMLInputElement>('.time-picker');
    const startInput = timeInputs[0];
    const endInput = timeInputs[1];
    if (startInput === undefined || endInput === undefined)
      throw new Error('Missing times');
    startInput.value = '22:00:00';
    startInput.dispatchEvent(new Event('input'));
    endInput.value = '06:00:00';
    endInput.dispatchEvent(new Event('input'));
    await nextTick();
    expect(root.querySelectorAll('[data-testid="modal"]')).toHaveLength(2);
    const checkbox = root.querySelector<HTMLInputElement>(
      'input[type="checkbox"]',
    );
    if (checkbox === null) throw new Error('Missing overnight checkbox');
    expect(root.querySelectorAll('select')).toHaveLength(0);
    checkbox.click();
    await nextTick();
    const endDay = root.querySelectorAll<HTMLSelectElement>('select')[1];
    if (endDay === undefined) throw new Error('Missing end day');
    endDay.value = '1';
    endDay.dispatchEvent(new Event('change'));
    await nextTick();

    const submitBtn = [
      ...root.querySelectorAll<HTMLButtonElement>('button'),
    ].find((b) => b.textContent?.includes('Tạo ca làm việc'));
    expect(submitBtn).toBeDefined();
    submitBtn?.click();
    await new Promise<void>((resolve) => setTimeout(resolve, 0));
    await nextTick();

    expect(api.createWorkShift).toHaveBeenCalledWith(
      expect.objectContaining({
        name: 'Ca mới',
        root_organization_id: 'root-1',
        periods: [
          {
            start_time: '22:00:00',
            end_time: '06:00:00',
            start_day_offset: 0,
            end_day_offset: 1,
          },
        ],
      }),
    );
    expect(api.createWorkShift.mock.lastCall?.[0]).not.toHaveProperty('code');
    expect(root.textContent).not.toContain('Ví dụ dễ đọc');
    expect(onRefresh).toHaveBeenCalled();

    app.unmount();
  });
});
