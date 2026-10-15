import type { Dayjs } from 'dayjs';

import type { PropType } from 'vue';

import type {
  AbsenceRequest,
  CreateAbsenceRequest,
  LeaveCoveragePreview,
  LeaveCoveragePreviewQuery,
  UpdateAbsenceRequest,
} from '#/api/absence-requests';
import type {
  OrganizationHierarchy,
  User,
  UserTreeSelectionUser,
} from '#/api/contracts';
import type { WorkShift } from '#/api/work-shifts';
import type { WorkUserShift } from '#/api/work-user-shifts';

import { createApp, defineComponent, h, nextTick, reactive } from 'vue';

import dayjs from 'dayjs';
import { afterEach, describe, expect, it, vi } from 'vitest';

import AbsenceRequestFormModal from '#/views/absence-requests/components/AbsenceRequestFormModal.vue';
import AbsenceRequestsPage from '#/views/absence-requests/index.vue';
import WorkUserShiftsPage from '#/views/work-user-shifts/index.vue';

const api = vi.hoisted(() => ({
  createAbsenceRequest: vi.fn(async (_payload: CreateAbsenceRequest) => {}),
  updateAbsenceRequest: vi.fn(
    async (_id: string, _payload: UpdateAbsenceRequest) => {},
  ),
  getAbsenceRequests: vi.fn(
    async (
      _query: Record<string, unknown>,
    ): Promise<{ items: AbsenceRequest[]; pagination: { total: number } }> => ({
      items: [],
      pagination: { total: 0 },
    }),
  ),
  getWorkUserShifts: vi.fn(async (): Promise<WorkUserShift[]> => []),
  getMyWorkUserShifts: vi.fn(
    async ({ from }: { from: string }): Promise<WorkUserShift[]> => {
      const user = {
        id: 'user-1',
        organization_id: 'root-1',
        name: 'Employee',
        username: 'employee',
        email: null,
        email_verified_at: null,
        avatar: null,
        deleted_at: null,
        supabase_id: null,
        created_at: '2026-09-01T00:00:00Z',
        updated_at: '2026-09-01T00:00:00Z',
      };
      const periods = [
        {
          id: 'p1',
          work_shift_id: 'definition',
          start_time: '08:00:00',
          end_time: '12:00:00',
          start_day_offset: 0,
          end_day_offset: 0,
          created_at: '2026-09-01T00:00:00Z',
          updated_at: '2026-09-01T00:00:00Z',
        },
        {
          id: 'p2',
          work_shift_id: 'definition',
          start_time: '13:30:00',
          end_time: '17:30:00',
          start_day_offset: 0,
          end_day_offset: 0,
          created_at: '2026-09-01T00:00:00Z',
          updated_at: '2026-09-01T00:00:00Z',
        },
      ];
      return [
        {
          id: 'assignment',
          root_organization_id: 'root-1',
          user_id: 'user-1',
          work_shift_id: 'definition',
          work_date: from,
          start_at: `${from}T01:00:00.000000Z`,
          end_at: `${from}T10:30:00.000000Z`,
          work_periods: [
            {
              start_at: `${from}T01:00:00.000000Z`,
              end_at: `${from}T05:00:00.000000Z`,
            },
            {
              start_at: `${from}T06:30:00.000000Z`,
              end_at: `${from}T10:30:00.000000Z`,
            },
          ],
          work_shift: {
            id: 'definition',
            root_organization_id: 'root-1',
            name: 'Ca tùy chỉnh',
            created_by: 'manager',
            created_at: '2026-09-01T00:00:00Z',
            updated_at: '2026-09-01T00:00:00Z',
            periods,
          },
          created_by: 'manager',
          created_at: '2026-09-01T00:00:00Z',
          updated_at: '2026-09-01T00:00:00Z',
          creator: user,
          user,
          root_organization: {
            id: 'root-1',
            name: 'Company',
            parent_id: null,
            tax_identification_number: null,
            type: 'Công ty',
            created_at: '2026-09-01T00:00:00Z',
            updated_at: '2026-09-01T00:00:00Z',
          },
        },
      ];
    },
  ),
  getWorkShifts: vi.fn(async (_rootId: string): Promise<WorkShift[]> => []),
  previewLeaveCoverage: vi.fn(
    async (
      _query: LeaveCoveragePreviewQuery,
    ): Promise<LeaveCoveragePreview> => ({
      total_days: 1,
      working_days: 1,
      holiday_days: 0,
      off_days: 0,
      items: [],
    }),
  ),
}));
const treeState = vi.hoisted(() => ({ users: [] as UserTreeSelectionUser[] }));

vi.mock('#/shared/user-tree-select/user-tree-select.vue', () => ({
  default: defineComponent({
    props: {
      modelValue: { type: Array as PropType<string[]>, required: true },
      users: {
        type: Array as PropType<UserTreeSelectionUser[]>,
        required: true,
      },
      testId: { type: String, required: true },
      multiple: { type: Boolean, default: true },
      loading: Boolean,
      loadError: Boolean,
    },
    emits: ['update:modelValue'],
    setup(props, { emit }) {
      return () =>
        h(
          'div',
          {
            'data-testid': props.testId,
            'data-users': JSON.stringify(props.users),
            'data-selected': JSON.stringify(props.modelValue),
            'data-multiple': String(props.multiple !== false),
          },
          [
            h(
              'button',
              {
                onClick: () =>
                  emit(
                    'update:modelValue',
                    props.multiple === false
                      ? ['user-2']
                      : ['user-1', 'user-2'],
                  ),
              },
              'select',
            ),
            h(
              'button',
              { onClick: () => emit('update:modelValue', []) },
              'clear',
            ),
          ],
        );
    },
  }),
}));
vi.mock('@vben/access', () => ({
  useAccess: () => ({ hasAccessByCodes: () => true }),
}));
vi.mock('@vben/common-ui', () => ({
  Page: { template: '<div><slot /></div>' },
  useVbenModal: () => [
    {
      template: '<div data-testid="modal"><slot /><slot name="footer" /></div>',
    },
    { open: vi.fn(), close: vi.fn(), setState: vi.fn() },
  ],
}));
vi.mock('@vben/icons', () => ({ IconifyIcon: { render: () => null } }));
vi.mock('@vben/preferences', () => ({
  preferences: { app: { locale: 'en-US', timezone: 'Asia/Ho_Chi_Minh' } },
}));
vi.mock('#/locales', () => ({
  $t: (key: string, values?: Record<string, number | string>) => {
    if (values === undefined) return key;
    if (key === 'absenceRequests.detail.durationDays')
      return `${values.days} days`;
    return `${key} ${Object.values(values).join(' ')}`;
  },
}));
vi.mock('#/shared/request-feedback', () => ({ showRequestError: vi.fn() }));
vi.mock('#/store', () => ({
  useAuthStore: () => ({
    user: { id: 'user-1', root_organization_id: 'root-1', roles: [] },
  }),
}));
vi.mock('#/api', async () => {
  const { userTreeResource } = await import('#/api/users');
  return {
    userTreeResource,
    getOrganizationRootId: (organization: OrganizationHierarchy) => {
      let root = organization;
      while (root.parent !== null) root = root.parent;
      return root.id;
    },
  };
});
vi.mock('ant-design-vue', () => {
  const wrapper = { template: '<div><slot /></div>' };
  return {
    Badge: wrapper,
    Alert: { template: '<div><slot /><slot name="action" /></div>' },
    Button: { template: '<button><slot /></button>' },
    DatePicker: defineComponent({
      props: {
        valueFormat: { type: String, default: undefined },
        value: {
          type: [Object, String] as PropType<Dayjs | string>,
          default: null,
        },
      },
      emits: ['update:value', 'change'],
      setup(props, { emit }) {
        return () =>
          h(
            'button',
            {
              'data-testid': 'date-picker',
              'data-display':
                typeof props.value === 'string' || props.value === null
                  ? props.value
                  : props.value.format('YYYY-MM-DD HH:mm'),
              onClick: (event: Event) => {
                const date =
                  (event.target as HTMLElement).dataset.date || '2026-10-01';
                emit('update:value', props.valueFormat ? date : dayjs(date));
                emit('change');
              },
            },
            'Choose date',
          );
      },
    }),
    RangePicker: {
      props: { valueFormat: { type: String, default: undefined } },
      emits: ['update:value', 'change'],
      template:
        "<button data-testid=\"range-picker\" @click=\"$emit('update:value', ['2026-10-01', '2026-10-05']); $emit('change')\">Choose range</button>",
    },
    Descriptions: wrapper,
    DescriptionsItem: {
      props: { label: { type: String, default: '' } },
      template: '<div>{{ label }}<slot /></div>',
    },
    Empty: wrapper,
    InputNumber: wrapper,
    Form: wrapper,
    FormItem: wrapper,
    Input: Object.assign(
      { ...wrapper },
      {
        TextArea: {
          props: ['value'],
          emits: ['update:value'],
          template:
            '<textarea :value="value" @input="$emit(\'update:value\', $event.target.value)" />',
        },
      },
    ),
    Modal: wrapper,
    Pagination: wrapper,
    Popconfirm: wrapper,
    Radio: Object.assign(
      { ...wrapper },
      {
        Button: wrapper,
        Group: wrapper,
      },
    ),
    Select: defineComponent({
      props: {
        value: { type: String, default: undefined },
        options: {
          type: Array as PropType<{ label: string; value: string }[]>,
          default: () => [],
        },
        disabled: Boolean,
      },
      emits: ['update:value', 'change'],
      setup(props, { emit }) {
        return () =>
          h(
            'select',
            {
              value: props.value,
              disabled: props.disabled,
              onChange: (event: Event) => {
                const value =
                  (event.target as HTMLSelectElement).value || undefined;
                emit('update:value', value);
                emit('change', value);
              },
            },
            [
              h('option', { value: '' }, 'Choose'),
              ...props.options.map((option) =>
                h('option', { value: option.value }, option.label),
              ),
            ],
          );
      },
    }),
    Switch: wrapper,
    Skeleton: wrapper,
    Spin: wrapper,
    Tag: wrapper,
    TimePicker: wrapper,
    Tabs: Object.assign(
      { ...wrapper },
      {
        TabPane: { template: '<div><slot name="tab" /><slot /></div>' },
      },
    ),
    notification: { success: vi.fn(), warning: vi.fn() },
  };
});
vi.mock('#/api/users', () => ({
  userTreeResource: {
    getAll: async (_query?: Record<string, unknown>) => treeState.users,
  },
}));
vi.mock('#/views/work-user-shifts/shift-config-modal.vue', () => ({
  default: defineComponent({
    emits: ['refresh'],
    setup(_props, { emit }) {
      return () =>
        h(
          'button',
          { 'data-testid': 'catalog-saved', onClick: () => emit('refresh') },
          'Save catalog',
        );
    },
  }),
}));
vi.mock('#/api/work-shifts', () => ({ getWorkShifts: api.getWorkShifts }));
vi.mock('#/api/work-user-shifts', () => ({
  getMyWorkUserShifts: api.getMyWorkUserShifts,
  createWorkUserShiftRange: vi.fn(),
  deleteWorkUserShift: vi.fn(),
  updateWorkUserShift: vi.fn(),
  getWorkUserShifts: api.getWorkUserShifts,
}));
vi.mock('#/api/absence-requests', () => ({
  approveAbsenceRequest: vi.fn(),
  createAbsenceRequest: api.createAbsenceRequest,
  createAbsenceRequestSchema: {
    safeParse: (values: CreateAbsenceRequest) => ({
      success: true,
      data: values,
    }),
  },
  deleteAbsenceRequest: vi.fn(),
  getAbsenceRequest: vi.fn(),
  getAbsenceRequests: api.getAbsenceRequests,
  getLeaveBalance: async () => null,
  getReviewerCapability: async () => false,
  previewLeaveCoverage: api.previewLeaveCoverage,
  rejectAbsenceRequest: vi.fn(),
  returnAbsenceRequest: vi.fn(),
  updateAbsenceRequest: api.updateAbsenceRequest,
}));
vi.mock(
  '#/views/absence-requests/components/AbsenceRequestBalanceNotice.vue',
  () => ({ default: { render: () => null } }),
);
vi.mock(
  '#/views/absence-requests/components/AbsenceRequestReviewNoteModal.vue',
  () => ({ default: { render: () => null } }),
);

const rootOrganization: OrganizationHierarchy = {
  id: 'root-1',
  name: 'Organization root',
  tax_identification_number: null,
  type: 'Công ty',
  parent_id: null,
  parent: null,
  created_at: '2026-09-30T00:00:00Z',
  updated_at: '2026-09-30T00:00:00Z',
};
const organization: OrganizationHierarchy = {
  id: 'organization-1',
  name: 'Team',
  type: 'Nhóm',
  tax_identification_number: null,
  parent_id: rootOrganization.id,
  parent: rootOrganization,
  created_at: '2026-09-30T00:00:00Z',
  updated_at: '2026-09-30T00:00:00Z',
};
const treeUser: UserTreeSelectionUser = {
  id: 'user-1',
  username: 'admin',
  name: 'Administrator',
  organization,
  organization_id: organization.id,
  deleted_at: null,
  profile: null,
};
const user: User = {
  ...treeUser,
  avatar: null,
  created_at: '2026-09-30T00:00:00Z',
  email: null,
  email_verified_at: null,
  organization: {
    id: organization.id,
    name: organization.name,
    type: organization.type,
    parent_id: organization.parent_id,
    tax_identification_number: null,
    created_at: organization.created_at,
    updated_at: organization.updated_at,
  },
  profile: null,
  roles: [],
  supabase_id: null,
  updated_at: '2026-09-30T00:00:00Z',
};
treeState.users = [
  treeUser,
  {
    ...treeUser,
    id: 'user-2',
    name: 'Reviewer',
    username: 'reviewer',
    organization: {
      ...organization,
      id: 'organization-2',
      name: 'Other team',
    },
    organization_id: 'organization-2',
  },
  { ...treeUser, id: 'user-3', deleted_at: '2026-01-01T00:00:00.000000Z' },
];
const apps: ReturnType<typeof createApp>[] = [];
afterEach(() => apps.splice(0).forEach((app) => app.unmount()));

async function flush() {
  await new Promise<void>((resolve) => setTimeout(resolve, 0));
  await nextTick();
}

function mount(component: Parameters<typeof createApp>[0]) {
  const element = document.createElement('div');
  const app = createApp(component);
  apps.push(app);
  app.mount(element);
  return element;
}

function getTree(element: HTMLElement, id: string): HTMLElement {
  const tree = element.querySelector<HTMLElement>(`[data-testid="${id}"]`);
  if (tree === null) throw new Error(`Missing user selector ${id}`);
  return tree;
}

function select(tree: HTMLElement, action: 'clear' | 'select') {
  const button = [...tree.querySelectorAll('button')].find(
    (item) => item.textContent === action,
  );
  if (button === undefined) throw new Error('Missing selection action');
  button.click();
}

describe('user tree integration', () => {
  it('refreshes displayed assignments after saving the shift catalog', async () => {
    const [assignment] = await api.getMyWorkUserShifts({
      from: `${dayjs().format('YYYY-MM')}-10`,
    });
    if (assignment === undefined) throw new Error('Missing assignment');
    api.getWorkUserShifts
      .mockResolvedValueOnce([assignment])
      .mockResolvedValueOnce([
        {
          ...assignment,
          start_at: `${assignment.work_date}T00:00:00Z`,
          work_shift: { ...assignment.work_shift, name: 'Updated shift' },
        },
      ]);
    const element = mount(WorkUserShiftsPage);
    await flush();
    expect(element.textContent).toContain('Ca tùy chỉnh');
    const save = element.querySelector<HTMLButtonElement>(
      '[data-testid="catalog-saved"]',
    );
    if (save === null) throw new Error('Missing catalog save action');
    save.click();
    await flush();
    expect(element.textContent).toContain('Updated shift');
    expect(element.textContent).toContain('07:00');
    expect(element.textContent).not.toContain('Ca tùy chỉnh');
  });

  it('shows overnight calendar labels and detail periods in business time', async () => {
    const date = `${dayjs().format('YYYY-MM')}-10`;
    const [assignment] = await api.getMyWorkUserShifts({ from: date });
    if (assignment === undefined) throw new Error('Missing assignment');
    api.getWorkUserShifts.mockResolvedValueOnce([
      {
        ...assignment,
        start_at: `${date}T15:00:00Z`,
        end_at: `${date}T23:00:00Z`,
        work_periods: [
          { start_at: `${date}T15:00:00Z`, end_at: `${date}T19:00:00Z` },
          { start_at: `${date}T20:00:00Z`, end_at: `${date}T23:00:00Z` },
        ],
        work_shift: { ...assignment.work_shift, name: 'Night shift' },
      },
    ]);
    const element = mount(WorkUserShiftsPage);
    await flush();
    const pill = [
      ...element.querySelectorAll<HTMLElement>('div.bg-primary'),
    ].find((item) => item.textContent?.includes('Night shift'));
    if (pill === undefined) throw new Error('Missing night shift');
    expect(pill.textContent).toContain('workUserShifts.form.nextDay');
    pill.click();
    await flush();
    const text = element.textContent?.replaceAll(/\s+/g, ' ');
    expect(text).toContain('22:00 – 02:00 (+1)');
    expect(text).toContain('03:00 (+1) – 06:00 (+1)');
    expect(element.querySelectorAll('span.bg-primary.opacity-40')).toHaveLength(
      2,
    );
  });

  it.each([false, true])(
    'ignores previous organization catalog responses (failure: %s)',
    async (failOld) => {
      const original = api.getMyWorkUserShifts.getMockImplementation();
      if (original === undefined) throw new Error('Missing assignment fake');
      const [assignment] = await original({ from: '2026-10-01' });
      if (assignment === undefined) throw new Error('Missing assignment');
      const previousUsers = treeState.users;
      treeState.users = previousUsers.map((employee) =>
        employee.id === 'user-2'
          ? {
              ...employee,
              organization: { ...rootOrganization, id: 'root-2' },
              organization_id: 'root-2',
            }
          : employee,
      );
      let resolveOld!: (rows: WorkShift[]) => void;
      let rejectOld!: (error: Error) => void;
      api.getWorkShifts
        .mockImplementationOnce(
          () =>
            new Promise((resolve, reject) => {
              resolveOld = resolve;
              rejectOld = reject;
            }),
        )
        .mockResolvedValueOnce([
          {
            ...assignment.work_shift,
            id: 'current-shift',
            root_organization_id: 'root-2',
            name: 'Current organization shift',
          },
        ]);
      try {
        const element = mount(WorkUserShiftsPage);
        await flush();
        select(getTree(element, 'shift-calendar-user-tree-select'), 'select');
        await flush();
        if (failOld) rejectOld(new Error('old error'));
        else
          resolveOld([
            { ...assignment.work_shift, name: 'Old organization shift' },
          ]);
        await flush();
        expect(element.textContent).toContain('Current organization shift');
        expect(element.textContent).not.toContain('Old organization shift');

        [...element.querySelectorAll<HTMLButtonElement>('button')]
          .find((button) =>
            button.textContent?.includes('workUserShifts.actions.apply'),
          )
          ?.click();
        await flush();
        api.getWorkShifts.mockClear();
        select(getTree(element, 'shift-form-user-tree-select'), 'select');
        await flush();
        expect(api.getWorkShifts).not.toHaveBeenCalled();
        expect(element.textContent).not.toContain('Current organization shift');
      } finally {
        treeState.users = previousUsers;
        api.getWorkShifts.mockReset();
        api.getWorkShifts.mockResolvedValue([]);
      }
    },
  );
  it.each(['date', 'close'] as const)(
    'discards a pending assignment retry after %s changes',
    async (change) => {
      const original = api.getMyWorkUserShifts.getMockImplementation();
      if (original === undefined) throw new Error('Missing assignment fake');
      const oldRows = await original({ from: '2026-10-01' });
      let resolveRetry!: (rows: WorkUserShift[]) => void;
      api.getMyWorkUserShifts
        .mockRejectedValueOnce(new Error('offline'))
        .mockImplementationOnce(
          () =>
            new Promise((resolve) => {
              resolveRetry = resolve;
            }),
        );
      const props = reactive({
        balance: null,
        balanceError: false,
        balanceLoading: false,
        rootOrganizationId: 'root-1',
        currentUserId: 'user-1',
        editingRequest: null,
        open: false,
        requestType: 'TIMEOFF' as const,
        reviewerUsers: treeState.users,
        reviewerUsersLoadError: false,
        reviewerUsersLoading: false,
        submitting: false,
      });
      const element = mount({
        render: () => h(AbsenceRequestFormModal, props),
      });
      props.open = true;
      await flush();
      const picker = element.querySelector<HTMLButtonElement>(
        '[data-testid="date-picker"]',
      );
      if (picker === null) throw new Error('Missing date picker');
      picker.click();
      await flush();
      [...element.querySelectorAll<HTMLButtonElement>('button')]
        .find((button) =>
          button.textContent?.includes(
            'absenceRequests.create.shiftSelection.retry',
          ),
        )
        ?.click();
      await flush();
      expect(resolveRetry).toBeDefined();
      if (change === 'date') {
        picker.dataset.date = '2026-10-02';
        picker.click();
      } else {
        props.open = false;
        await flush();
        props.open = true;
      }
      await flush();
      api.previewLeaveCoverage.mockClear();
      resolveRetry(oldRows);
      await flush();
      expect(api.previewLeaveCoverage).not.toHaveBeenCalled();
      const shiftSelect = [
        ...element.querySelectorAll<HTMLSelectElement>('select'),
      ].find((select) =>
        [...select.options].some((option) => option.value === 'custom'),
      );
      if (shiftSelect === undefined) throw new Error('Missing shift selector');
      expect(shiftSelect.textContent?.includes('Ca tùy chỉnh')).toBe(
        change === 'date',
      );
    },
  );

  it.each([
    [
      '2026-10-01T01:00:00.000000Z',
      '2026-10-01T05:00:00.000000Z',
      '08:00',
      '12:00',
      '2026-10-01T01:15:00.000Z',
    ],
    [
      '2026-09-30T20:00:00.000000Z',
      '2026-09-30T23:00:00.000000Z',
      '03:00',
      '06:00',
      '2026-09-30T20:15:00.000Z',
    ],
  ])(
    'displays and submits assigned UTC periods in business time: %s',
    async (startAt, endAt, startLabel, endLabel, editedStartAt) => {
      const original = api.getMyWorkUserShifts.getMockImplementation();
      if (original === undefined) throw new Error('Missing assignment fake');
      const [assignment] = await original({ from: '2026-10-01' });
      if (assignment === undefined) throw new Error('Missing assignment');
      api.getMyWorkUserShifts.mockResolvedValueOnce([
        {
          ...assignment,
          start_at: startAt,
          end_at: endAt,
          work_periods: [{ start_at: startAt, end_at: endAt }],
        },
      ]);
      const submit = vi.fn();
      const balanceDateChange = vi.fn();
      const props = reactive({
        balance: null,
        balanceError: false,
        balanceLoading: false,
        rootOrganizationId: 'root-1',
        currentUserId: 'user-1',
        editingRequest: null,
        open: false,
        requestType: 'TIMEOFF' as const,
        reviewerUsers: treeState.users,
        reviewerUsersLoadError: false,
        reviewerUsersLoading: false,
        submitting: false,
        onSubmit: submit,
        onBalanceDateChange: balanceDateChange,
      });
      const element = mount({
        render: () => h(AbsenceRequestFormModal, props),
      });
      props.open = true;
      await flush();
      element
        .querySelector<HTMLButtonElement>('[data-testid="date-picker"]')
        ?.click();
      await flush();
      const shiftSelect = element.querySelector<HTMLSelectElement>(
        '[data-testid="absence-form-shift-select"]',
      );
      if (shiftSelect === null) throw new Error('Missing shift selector');
      expect(shiftSelect.textContent).toContain(`${startLabel} ${endLabel}`);
      expect(shiftSelect.textContent).not.toContain('01:00 05:00');
      expect(balanceDateChange).toHaveBeenLastCalledWith('2026-10-01');
      shiftSelect.value = '0';
      shiftSelect.dispatchEvent(new Event('change'));
      await flush();
      expect(api.previewLeaveCoverage).toHaveBeenLastCalledWith(
        expect.objectContaining({ start_at: startAt, end_at: endAt }),
      );
      shiftSelect.value = 'custom';
      shiftSelect.dispatchEvent(new Event('change'));
      await flush();
      const pickers = element.querySelectorAll<HTMLButtonElement>(
        '[data-testid="date-picker"]',
      );
      expect(pickers[1]?.dataset.display).toBe(`2026-10-01 ${startLabel}`);
      expect(pickers[2]?.dataset.display).toBe(`2026-10-01 ${endLabel}`);
      const reviewer = element.querySelector<HTMLSelectElement>(
        '[data-testid="absence-form-reviewer-select"]',
      );
      const reason = element.querySelector<HTMLTextAreaElement>('textarea');
      if (reviewer === null || reason === null)
        throw new Error('Missing inputs');
      reviewer.value = 'user-2';
      reviewer.dispatchEvent(new Event('change'));
      reason.value = 'Morning leave';
      reason.dispatchEvent(new Event('input'));
      await flush();
      [...element.querySelectorAll<HTMLButtonElement>('button')]
        .find((button) =>
          button.textContent?.includes('absenceRequests.create.actions.submit'),
        )
        ?.click();
      expect(submit).toHaveBeenCalledWith(
        expect.objectContaining({ start_at: startAt, end_at: endAt }),
      );
      const startPicker = pickers[1];
      if (startPicker === undefined) throw new Error('Missing start picker');
      startPicker.dataset.date = `2026-10-01T${startLabel.slice(0, 2)}:15:00`;
      startPicker.click();
      await flush();
      expect(api.previewLeaveCoverage).toHaveBeenLastCalledWith(
        expect.objectContaining({ start_at: editedStartAt }),
      );
    },
  );

  it('uses business-local custom defaults even when the browser timezone is UTC', async () => {
    const props = reactive({
      balance: null,
      balanceError: false,
      balanceLoading: false,
      rootOrganizationId: 'root-1',
      currentUserId: 'user-1',
      editingRequest: null,
      open: false,
      requestType: 'TIMEOFF' as const,
      reviewerUsers: treeState.users,
      reviewerUsersLoadError: false,
      reviewerUsersLoading: false,
      submitting: false,
    });
    const element = mount({ render: () => h(AbsenceRequestFormModal, props) });
    props.open = true;
    await flush();
    const shiftSelect = [
      ...element.querySelectorAll<HTMLSelectElement>('select'),
    ].find((select) =>
      [...select.options].some((option) => option.value === 'custom'),
    );
    if (shiftSelect === undefined) throw new Error('Missing shift selector');
    shiftSelect.value = 'custom';
    shiftSelect.dispatchEvent(new Event('change'));
    await flush();
    const payload = api.previewLeaveCoverage.mock.lastCall?.[0];
    expect(payload).toEqual(
      expect.objectContaining({
        start_at: expect.stringMatching(/T01:00:00.000Z$/),
        end_at: expect.stringMatching(/T10:30:00.000Z$/),
      }),
    );
  });
  it('shows a translated preview error and supports retry in the form modal', async () => {
    const request: AbsenceRequest = {
      id: 'preview-request',
      root_organization: rootOrganization,
      root_organization_id: rootOrganization.id,
      user,
      user_id: user.id,
      requester: user,
      requested_by: user.id,
      reviewer: { ...user, id: 'user-2' },
      reviewer_id: 'user-2',
      leave_type: 'UNPAID',
      status: 'returned',
      reason: 'Leave',
      address: null,
      start_at: '2026-10-01T01:00:00.000000Z',
      end_at: '2026-10-01T10:30:00.000000Z',
      duration_days: 1,
      created_at: '2026-10-01T00:00:00Z',
      updated_at: '2026-10-01T00:00:00Z',
      approved_at: null,
      rejected_at: null,
      submitted_at: null,
      approval_note: null,
    };
    api.previewLeaveCoverage.mockRejectedValueOnce(
      new Error('Preview unavailable'),
    );
    const props = reactive({ open: false });
    const element = mount({
      render: () =>
        h(AbsenceRequestFormModal, {
          ...props,
          balance: null,
          balanceError: false,
          balanceLoading: false,
          rootOrganizationId: rootOrganization.id,
          currentUserId: user.id,
          editingRequest: request,
          requestType: 'TIMEOFF',
          reviewerUsers: treeState.users,
          reviewerUsersLoading: false,
          reviewerUsersLoadError: false,
          submitting: false,
        }),
    });
    props.open = true;
    await flush();
    const alert = element.querySelector<HTMLElement>('[role="alert"]');
    expect(alert?.textContent).toContain('absenceRequests.coverage.error');
    api.previewLeaveCoverage.mockResolvedValueOnce({
      total_days: 1,
      working_days: 1,
      holiday_days: 0,
      off_days: 0,
      items: [
        {
          date: '2026-10-01',
          status: 'covered',
          work_shift_id: 'SHIFT_FULL_DAY',
          hours: 8,
          days: 1,
          note: 'Leave',
        },
      ],
    });
    alert?.querySelector<HTMLButtonElement>('button')?.click();
    await flush();
    expect(element.querySelector('[role="alert"]')).toBeNull();
    expect(element.textContent).toContain('1 days');
  });

  it('creates a pending request directly without a save-draft action', async () => {
    const record: AbsenceRequest = {
      id: 'pending-request',
      root_organization: rootOrganization,
      root_organization_id: rootOrganization.id,
      user,
      user_id: user.id,
      requester: user,
      requested_by: user.id,
      reviewer: { ...user, id: 'user-2' },
      reviewer_id: 'user-2',
      leave_type: 'ANNUAL',
      status: 'pending',
      reason: 'Leave reason',
      address: null,
      start_at: '2026-10-01T01:00:00.000000Z',
      end_at: '2026-10-01T10:30:00.000000Z',
      duration_days: 1,
      created_at: '2026-10-01T00:00:00Z',
      updated_at: '2026-10-01T00:00:00Z',
      approved_at: null,
      rejected_at: null,
      submitted_at: null,
      approval_note: null,
    };
    let created = false;
    api.getAbsenceRequests.mockImplementation(async (query) => {
      const items =
        created &&
        (query.status === undefined || query.status === record.status)
          ? [record]
          : [];
      return { items, pagination: { total: items.length } };
    });
    api.createAbsenceRequest.mockImplementation(async (payload) => {
      expect(payload).not.toHaveProperty('status');
      created = true;
    });
    api.updateAbsenceRequest.mockImplementation(async (_id, payload) => {
      record.status = 'pending';
      record.reason = payload.reason;
    });
    try {
      const element = mount(AbsenceRequestsPage);
      await flush();
      element
        .querySelector<HTMLButtonElement>(
          '[data-testid="create-timeoff-request"]',
        )
        ?.click();
      await flush();
      const form = element.querySelector<HTMLElement>('[data-testid="modal"]');
      if (form === null) throw new Error('Missing create form');
      const reviewer = form.querySelector<HTMLSelectElement>(
        '[data-testid="absence-form-reviewer-select"]',
      );
      if (reviewer === null) throw new Error('Missing reviewer selector');
      reviewer.value = 'user-2';
      reviewer.dispatchEvent(new Event('change'));
      form
        .querySelector<HTMLButtonElement>('[data-testid="date-picker"]')
        ?.click();
      const reason = form.querySelector<HTMLTextAreaElement>('textarea');
      if (reason === null) throw new Error('Missing reason input');
      reason.value = 'Leave reason';
      reason.dispatchEvent(new Event('input'));
      await flush();
      [...form.querySelectorAll<HTMLButtonElement>('button')]
        .find((button) =>
          button.textContent?.includes('absenceRequests.create.actions.submit'),
        )
        ?.click();
      await flush();
      expect(api.createAbsenceRequest).toHaveBeenCalledWith(
        expect.objectContaining({
          start_at: record.start_at,
          end_at: record.end_at,
        }),
      );
      expect(element.textContent).toContain('Leave reason');
      expect(form.textContent).not.toContain(
        'absenceRequests.create.actions.saveDraft',
      );
    } finally {
      api.getAbsenceRequests.mockImplementation(async () => ({
        items: [],
        pagination: { total: 0 },
      }));
      api.createAbsenceRequest.mockReset();
      api.updateAbsenceRequest.mockReset();
    }
  });

  it('shows the all tab and unscoped counts to employees without an admin role', async () => {
    api.getAbsenceRequests.mockClear();
    const element = mount(AbsenceRequestsPage);
    await flush();
    expect(element.textContent).toContain('absenceRequests.tabs.all');
    expect(api.getAbsenceRequests).toHaveBeenCalledWith(
      expect.objectContaining({ page: 1, per_page: 1 }),
    );
    const allQuery = api.getAbsenceRequests.mock.calls.find(
      ([query]) => query.per_page === 1 && !('status' in query),
    )?.[0];
    expect(allQuery).toBeDefined();
    expect(allQuery).not.toHaveProperty('user_id');
    expect(allQuery).not.toHaveProperty('reviewer_id');
    expect(
      getTree(element, 'absence-requester-tree-select').dataset.users,
    ).toBe(JSON.stringify(treeState.users));
    expect(
      getTree(element, 'absence-reviewer-filter-tree-select').dataset.users,
    ).toBe(JSON.stringify(treeState.users));
  });

  it.each([
    ['2026-10-02T08:00:00+07:00', '2026-10-02T17:30:00+07:00'],
    ['2026-10-02T09:15:00+07:00', '2026-10-02T11:45:00+07:00'],
  ])(
    'preserves existing single-day leave times when opening and saving an edit: %s',
    async (startAt, endAt) => {
      const request: AbsenceRequest = {
        id: 'request-edit',
        root_organization: rootOrganization,
        root_organization_id: rootOrganization.id,
        user,
        user_id: user.id,
        requester: user,
        requested_by: user.id,
        reviewer: { ...user, id: 'user-2', name: 'Reviewer' },
        reviewer_id: 'user-2',
        leave_type: 'UNPAID',
        status: 'returned',
        reason: 'Existing leave reason',
        address: null,
        start_at: startAt,
        end_at: endAt,
        duration_days: 1,
        created_at: '2026-09-30T00:00:00Z',
        updated_at: '2026-09-30T00:00:00Z',
        approved_at: null,
        rejected_at: null,
        submitted_at: null,
        approval_note: null,
      };
      const submit = vi.fn();
      const props = reactive({
        balance: null,
        balanceError: false,
        balanceLoading: false,
        rootOrganizationId: rootOrganization.id,
        currentUserId: user.id,
        editingRequest: request,
        open: false,
        requestType: 'TIMEOFF' as const,
        reviewerUsers: treeState.users,
        reviewerUsersLoadError: false,
        reviewerUsersLoading: false,
        submitting: false,
        onSubmit: submit,
      });
      const element = mount({
        render: () => h(AbsenceRequestFormModal, props),
      });
      props.open = true;
      await flush();
      const saveButton = [
        ...element.querySelectorAll<HTMLButtonElement>('button'),
      ].find((button) =>
        button.textContent?.includes('absenceRequests.create.actions.submit'),
      );
      expect(saveButton).toBeDefined();
      expect(saveButton?.disabled).toBe(false);
      saveButton?.click();
      expect(submit).toHaveBeenCalledWith(
        expect.objectContaining({
          start_at: startAt,
          end_at: endAt,
        }),
      );

      props.open = false;
      await nextTick();
      request.end_at = '2026-10-06T17:30:00+07:00';
      props.open = true;
      submit.mockClear();
      await flush();
      expect(saveButton?.disabled).toBe(false);
      saveButton?.click();
      expect(submit).toHaveBeenCalledWith(
        expect.objectContaining({ start_at: startAt, end_at: request.end_at }),
      );

      element
        .querySelector<HTMLButtonElement>('[data-testid="date-picker"]')
        ?.click();
      await flush();
      saveButton?.click();
      expect(submit).toHaveBeenCalledWith(
        expect.objectContaining({
          start_at: '2026-10-01T01:00:00.000000Z',
          end_at: '2026-10-01T10:30:00.000000Z',
        }),
      );
    },
  );

  it('uses single selection for the shift calendar and multiple selection for assignment, excluding inactive users', async () => {
    const element = mount(WorkUserShiftsPage);
    await flush();
    const calendar = getTree(element, 'shift-calendar-user-tree-select');
    const form = getTree(element, 'shift-form-user-tree-select');
    expect(calendar.dataset.multiple).toBe('false');
    expect(form.dataset.multiple).toBe('true');
    expect(calendar.dataset.users).not.toContain('user-3');
    select(calendar, 'select');
    await flush();
    expect(api.getWorkUserShifts).toHaveBeenLastCalledWith(
      expect.objectContaining({ user_id: 'user-2' }),
    );
    select(form, 'select');
    await nextTick();
    expect(form.dataset.selected).toBe('["user-1","user-2"]');
    select(calendar, 'clear');
    await nextTick();
    expect(calendar.dataset.selected).toBe('[]');
  });

  it('passes requester and reviewer tree selections into absence list filters and supports clearing', async () => {
    const element = mount(AbsenceRequestsPage);
    await flush();
    const requester = getTree(element, 'absence-requester-tree-select');
    const reviewer = getTree(element, 'absence-reviewer-filter-tree-select');
    expect(requester.dataset.multiple).toBe('true');
    expect(reviewer.dataset.multiple).toBe('true');
    select(requester, 'select');
    await flush();
    expect(api.getAbsenceRequests).toHaveBeenLastCalledWith(
      expect.objectContaining({ user_ids: ['user-1', 'user-2'] }),
    );
    select(reviewer, 'select');
    await flush();
    expect(api.getAbsenceRequests).toHaveBeenLastCalledWith(
      expect.objectContaining({ reviewer_ids: ['user-1', 'user-2'] }),
    );
    select(requester, 'clear');
    await flush();
    expect(requester.dataset.selected).toBe('[]');
    expect(api.getAbsenceRequests.mock.lastCall?.[0]).not.toHaveProperty(
      'user_id',
    );
  });

  it('keeps both request creation actions primary', async () => {
    const element = mount(AbsenceRequestsPage);
    await flush();
    expect(
      element
        .querySelector('[data-testid="create-timeoff-request"]')
        ?.getAttribute('type'),
    ).toBe('primary');
    expect(
      element
        .querySelector('[data-testid="create-business-trip-request"]')
        ?.getAttribute('type'),
    ).toBe('primary');
  });

  it('uses a fixed leave request mode and a normal reviewer select', async () => {
    const props = reactive({
      balance: null,
      balanceError: false,
      balanceLoading: false,
      rootOrganizationId: 'root-1',
      currentUserId: 'user-1',
      editingRequest: null,
      open: false,
      requestType: 'TIMEOFF' as const,
      reviewerUsers: treeState.users,
      reviewerUsersLoading: false,
      reviewerUsersLoadError: false,
      submitting: false,
    });
    const element = mount({ render: () => h(AbsenceRequestFormModal, props) });
    props.open = true;
    await nextTick();
    const reviewer = element.querySelector<HTMLSelectElement>(
      '[data-testid="absence-form-reviewer-select"]',
    );
    if (reviewer === null) throw new Error('Missing reviewer select');
    expect(
      element.querySelector(
        '[data-testid="absence-form-reviewer-tree-select"]',
      ),
    ).toBeNull();
    expect(
      [...element.querySelectorAll<HTMLOptionElement>('select option')].some(
        (option) => ['BUSINESS_TRIP', 'TIMEOFF'].includes(option.value),
      ),
    ).toBe(false);
    expect([...reviewer.options].map((option) => option.value)).toEqual([
      '',
      'user-2',
      'user-3',
    ]);
    expect(reviewer.options[1]?.textContent).toBe(treeState.users[1]?.name);
    reviewer.value = 'user-2';
    reviewer.dispatchEvent(new Event('change'));
    await nextTick();
    expect(reviewer.value).toBe('user-2');
    const datePicker = element.querySelector<HTMLButtonElement>(
      '[data-testid="date-picker"]',
    );
    if (datePicker === null) throw new Error('Missing leave date picker');
    datePicker.click();
    await flush();
    expect(api.previewLeaveCoverage).toHaveBeenLastCalledWith(
      expect.objectContaining({
        start_at: '2026-10-01T01:00:00.000000Z',
        end_at: '2026-10-01T10:30:00.000000Z',
      }),
    );
    reviewer.value = '';
    reviewer.dispatchEvent(new Event('change'));
    await nextTick();
    expect(reviewer.value).toBe('');
  });

  it('opens the business trip form without a request type selector', async () => {
    const props = reactive({
      balance: null,
      balanceError: false,
      balanceLoading: false,
      rootOrganizationId: 'root-1',
      currentUserId: 'user-1',
      editingRequest: null,
      open: false,
      requestType: 'BUSINESS_TRIP' as const,
      reviewerUsers: treeState.users,
      reviewerUsersLoadError: false,
      reviewerUsersLoading: false,
      submitting: false,
    });
    const element = mount({ render: () => h(AbsenceRequestFormModal, props) });
    props.open = true;
    await nextTick();
    expect(
      element.querySelector('[data-testid="absence-form-reviewer-select"]'),
    ).not.toBeNull();
    expect(
      [...element.querySelectorAll<HTMLOptionElement>('select option')].some(
        (option) => ['BUSINESS_TRIP', 'TIMEOFF'].includes(option.value),
      ),
    ).toBe(false);
  });
});
