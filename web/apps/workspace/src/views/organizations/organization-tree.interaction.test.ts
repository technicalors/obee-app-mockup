/* eslint-disable vue/one-component-per-file */
// cspell:ignore unstub

import type { Organization } from '#/api';

import { createApp, defineComponent, h, nextTick } from 'vue';

import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import OrganizationDetailContent from './organization-detail-content.vue';
import OrganizationTree from './tree.vue';

const state = vi.hoisted(() => ({
  accessCodes: [] as string[],
  chartData: [] as unknown[],
  onNodeClick: null as ((node: unknown) => void) | null,
  getAllRows: vi.fn(),
  getById: vi.fn(),
  getMembers: vi.fn(),
  delete: vi.fn(),
  showRequestError: vi.fn(),
  modalOptions: [] as Array<Record<string, unknown>>,
  modalApis: [
    { open: vi.fn(), setData: vi.fn() },
    { open: vi.fn(), setData: vi.fn() },
  ],
  modalIndex: 0,
  confirm: vi.fn(),
  notificationSuccess: vi.fn(),
}));

vi.mock('@vben/access', () => ({
  useAccess: () => ({
    hasAccessByCodes: (codes: string[]) =>
      codes.every((code) => state.accessCodes.includes(code)),
  }),
}));

vi.mock('@vben/common-ui', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@vben/common-ui')>();
  return {
    ...actual,
    useVbenModal: (options: Record<string, unknown>) => {
      state.modalOptions.push(options);
      const api = state.modalApis[state.modalIndex];
      state.modalIndex += 1;
      if (api === undefined) throw new Error('Unexpected modal hook.');
      return [
        defineComponent({
          name: 'ConnectedModalStub',
          setup() {
            return () => h('div', { 'data-testid': 'connected-modal' });
          },
        }),
        api,
      ] as const;
    },
  };
});

vi.mock('@vben/icons', () => ({
  IconifyIcon: defineComponent({
    setup() {
      return () => h('span');
    },
  }),
}));

vi.mock('d3-org-chart', () => ({
  OrgChart: vi.fn(function (this: object) {
    const chart = new Proxy(this, {
      get: (_target, key) => {
        if (key === 'data') {
          return (data: unknown[]) => {
            state.chartData = data;
            return chart;
          };
        }
        if (key === 'onNodeClick') {
          return (callback: (node: unknown) => void) => {
            state.onNodeClick = callback;
            return chart;
          };
        }
        return (..._arguments: unknown[]) => chart;
      },
    });
    return chart;
  }),
}));

vi.mock('vue-router', () => ({
  useRouter: () => ({ push: vi.fn() }),
}));

vi.mock('#/api', () => ({
  organizationUsersResource: { getAll: state.getMembers },
  organizationsResource: {
    delete: state.delete,
    getAllRows: state.getAllRows,
    getById: state.getById,
  },
}));

vi.mock('#/locales', () => ({ $t: (key: string) => key }));
vi.mock('#/shared/request-feedback', () => ({
  showRequestError: state.showRequestError,
}));
vi.mock('#/store', () => ({
  useAuthStore: () => ({ fetchUserInfo: vi.fn() }),
}));
vi.mock('#/views/users/avatar', () => ({
  getUserAvatarSource: () => null,
}));

vi.mock('ant-design-vue', () => {
  const Button = defineComponent({
    emits: ['click'],
    setup(_, { attrs, emit, slots }) {
      return () =>
        h(
          'button',
          { ...attrs, onClick: () => emit('click') },
          slots.default?.(),
        );
    },
  });
  const Select = defineComponent({
    emits: ['update:value'],
    setup(_, { slots }) {
      return () => h('div', slots.default?.());
    },
  });
  const SelectOption = defineComponent({
    props: { value: { default: '', type: String } },
    setup(props, { slots }) {
      return () => h('span', { 'data-value': props.value }, slots.default?.());
    },
  });
  Object.assign(Select, { Option: SelectOption });

  return {
    Avatar: defineComponent({
      props: {
        size: { default: 0, type: Number },
        src: { default: null, type: String },
      },
      setup(props) {
        return () => h('img', { src: props.src ?? '' });
      },
    }),
    Button,
    Descriptions: defineComponent({
      setup(_, { slots }) {
        return () => h('div', slots.default?.());
      },
    }),
    DescriptionsItem: defineComponent({
      props: { label: { default: '', type: String } },
      setup(props, { slots }) {
        return () =>
          h('div', [
            h('span', props.label),
            h('span', { 'data-description-value': true }, slots.default?.()),
          ]);
      },
    }),
    Drawer: defineComponent({
      props: { open: { default: false, type: Boolean } },
      emits: ['close'],
      setup(props, { slots }) {
        return () =>
          h(
            'aside',
            { 'data-open': String(props.open), 'data-testid': 'tree-drawer' },
            [
              slots.title?.(),
              slots.extra?.(),
              props.open ? slots.default?.() : null,
            ],
          );
      },
    }),
    Empty: defineComponent({
      props: { description: { default: '', type: String } },
      setup(props) {
        return () => h('div', props.description);
      },
    }),
    Modal: { confirm: state.confirm },
    notification: { success: state.notificationSuccess },
    Pagination: defineComponent({
      props: {
        current: { default: 1, type: Number },
        pageSize: { default: 5, type: Number },
        total: { default: 0, type: Number },
      },
      emits: ['change'],
      setup(props, { emit }) {
        return () =>
          h(
            'div',
            Array.from(
              { length: Math.ceil(props.total / props.pageSize) },
              (_, index) => {
                const page = index + 1;
                return h(
                  'button',
                  {
                    'data-page': String(page),
                    onClick: () => emit('change', page),
                  },
                  String(page),
                );
              },
            ),
          );
      },
    }),
    Select,
    Spin: defineComponent({
      props: { spinning: { default: false, type: Boolean } },
      setup(props, { slots }) {
        return () =>
          h(
            'div',
            { 'data-spinning': String(props.spinning) },
            slots.default?.(),
          );
      },
    }),
  };
});

const apps: ReturnType<typeof createApp>[] = [];
const targets: HTMLElement[] = [];

function createOrganization(
  id: string,
  name: string,
  parentId: null | string,
  type: Organization['type'],
): Organization {
  return {
    created_at: '2026-10-01T00:00:00Z',
    id,
    name,
    parent_id: parentId,
    tax_identification_number: null,
    type,
    updated_at: '2026-10-01T00:00:00Z',
  };
}

const rootOrganization = createOrganization('root-1', 'Acme', null, 'Công ty');
const childOrganization = createOrganization(
  'organization-1',
  'Research',
  rootOrganization.id,
  'Nhóm',
);

function deferred<T>(): {
  promise: Promise<T>;
  reject: (error: Error) => void;
  resolve: (value: T) => void;
} {
  let resolve!: (value: T) => void;
  let reject!: (error: Error) => void;
  const promise = new Promise<T>((resolvePromise, rejectPromise) => {
    resolve = resolvePromise;
    reject = rejectPromise;
  });
  return { promise, reject, resolve };
}

function mount(
  component: typeof OrganizationDetailContent | typeof OrganizationTree,
  props: Record<string, unknown> = {},
): {
  app: ReturnType<typeof createApp>;
  target: HTMLElement;
} {
  const target = document.createElement('div');
  document.body.append(target);
  const app = createApp(component, props);
  apps.push(app);
  targets.push(target);
  app.mount(target);
  return { app, target };
}

async function flushAsync(): Promise<void> {
  for (let index = 0; index < 10; index += 1) {
    await Promise.resolve();
    await nextTick();
  }
}

function clickButton(target: HTMLElement, text: string): void {
  const button = [...target.querySelectorAll('button')].find((candidate) =>
    candidate.textContent?.includes(text),
  );
  if (button === undefined) throw new Error(`Button ${text} was not rendered.`);
  button.click();
}

function clickGraphNode(organization: Organization): void {
  if (state.onNodeClick === null)
    throw new Error('Graph node callback missing.');
  state.onNodeClick({ data: { organization } });
}

function memberResult(page: number, name: string) {
  return {
    items: [
      {
        id: `user-${page}`,
        name,
        username: `user${page}`,
        roles: [{ name: 'staff' }],
      },
    ],
    pagination: { has_next: page === 1, page, per_page: 5, total: 10 },
  };
}

beforeEach(() => {
  state.accessCodes = [
    'organizations.view',
    'organizations.update',
    'organizations.create',
    'organizations.delete',
  ];
  state.chartData = [];
  state.onNodeClick = null;
  state.getAllRows
    .mockReset()
    .mockResolvedValue([rootOrganization, childOrganization]);
  state.getById.mockReset().mockImplementation(async (id: string) => {
    return [rootOrganization, childOrganization].find(
      (organization) => organization.id === id,
    );
  });
  state.getMembers.mockReset().mockResolvedValue(memberResult(1, 'Member One'));
  state.delete.mockReset().mockResolvedValue(undefined);
  state.showRequestError.mockReset();
  state.modalOptions = [];
  state.modalIndex = 0;
  for (const api of state.modalApis) {
    api.open.mockReset();
    api.setData.mockReset();
  }
  state.confirm.mockReset();
  state.notificationSuccess.mockReset();
  vi.stubGlobal(
    'ResizeObserver',
    class {
      disconnect(): void {}
      observe(): void {}
    },
  );
});

afterEach(() => {
  for (const app of apps.splice(0)) app.unmount();
  for (const target of targets.splice(0)) target.remove();
  vi.unstubAllGlobals();
});

describe('organization graph and drawer interactions', () => {
  it('opens root/child modals and shows selected parent and direct users in a full-width drawer', async () => {
    const { target } = mount(OrganizationTree);
    await flushAsync();

    expect(target.querySelector('.organization-org-chart')).not.toBeNull();
    expect(target.querySelector('section')?.className).not.toContain(
      'grid-cols',
    );
    expect(state.modalOptions.map((options) => options.zIndex)).toEqual([
      2100, 2100,
    ]);

    clickButton(target, 'organizations.actions.createRoot');
    expect(state.modalApis[0]?.setData).toHaveBeenLastCalledWith(
      expect.objectContaining({ parentId: null }),
    );
    expect(state.modalApis[0]?.open).toHaveBeenCalledOnce();

    clickGraphNode(childOrganization);
    await flushAsync();
    expect(
      target.querySelector<HTMLElement>('[data-testid="tree-drawer"]')?.dataset
        .open,
    ).toBe('true');
    expect(target.textContent).toContain(rootOrganization.name);
    expect(target.textContent).toContain('organizations.types.team');
    expect(target.textContent).toContain('Member One');
    expect(target.textContent).toContain('organizations.tree.memberCount');

    clickButton(target, 'organizations.actions.createChild');
    expect(state.modalApis[0]?.setData).toHaveBeenLastCalledWith(
      expect.objectContaining({ parentId: childOrganization.id }),
    );
    expect(state.modalApis[0]?.open).toHaveBeenCalledTimes(2);

    clickButton(target, 'organizations.actions.view');
    expect(state.modalApis[1]?.setData).toHaveBeenLastCalledWith(
      expect.objectContaining({
        mode: 'view',
        organization: childOrganization,
        organizations: [rootOrganization, childOrganization],
      }),
    );
    expect(state.modalApis[1]?.open).toHaveBeenCalledOnce();
  });

  it('allows create-child with create permission alone without requesting details or users', async () => {
    state.accessCodes = ['organizations.viewAny', 'organizations.create'];
    const { target } = mount(OrganizationTree);
    await flushAsync();
    clickGraphNode(childOrganization);
    await flushAsync();

    expect(state.getById).not.toHaveBeenCalled();
    expect(state.getMembers).not.toHaveBeenCalled();
    clickButton(target, 'organizations.actions.createChild');
    expect(state.modalApis[0]?.setData).toHaveBeenLastCalledWith(
      expect.objectContaining({ parentId: childOrganization.id }),
    );
    expect(state.modalApis[0]?.open).toHaveBeenCalledOnce();
  });

  it('keeps the newest tree when the first list response arrives after a save reload', async () => {
    const firstLoad = deferred<Organization[]>();
    const createdRoot = createOrganization(
      'root-2',
      'Created root',
      null,
      'Công ty',
    );
    state.getAllRows
      .mockReset()
      .mockReturnValueOnce(firstLoad.promise)
      .mockResolvedValueOnce([createdRoot]);

    const { target } = mount(OrganizationTree);
    await flushAsync();
    clickButton(target, 'organizations.actions.createRoot');
    const data = state.modalApis[0]?.setData.mock.lastCall?.[0] as
      | undefined
      | { onSaved?: () => Promise<void> };
    if (data?.onSaved === undefined) throw new Error('Save callback missing.');
    await data.onSaved();
    await flushAsync();

    firstLoad.resolve([rootOrganization]);
    await flushAsync();
    expect(state.chartData).toEqual(
      expect.arrayContaining([expect.objectContaining({ id: createdRoot.id })]),
    );
    expect(state.chartData).not.toEqual(
      expect.arrayContaining([
        expect.objectContaining({ id: rootOrganization.id }),
      ]),
    );
  });
});

describe('organization direct-user pagination', () => {
  it('shows the company root, direct parent and members in the department detail layout', async () => {
    const company = createOrganization(
      'company-root',
      'Ouransoft Group',
      null,
      'Công ty',
    );
    const parent = createOrganization(
      'technical-div',
      'Technical Div.',
      company.id,
      'Bộ phận',
    );
    const department = createOrganization(
      'ai-department',
      'Ai Apply & Dev Depart',
      parent.id,
      'Phòng ban',
    );
    state.getById.mockResolvedValue(department);
    state.getMembers.mockResolvedValue({
      items: [
        {
          id: 'user-1',
          name: 'Hoàng Văn Lượng',
          username: 'ORS063',
          roles: [],
        },
        {
          id: 'user-2',
          name: 'Nguyễn Thu Minh',
          username: 'ORS133',
          roles: [],
        },
      ],
      pagination: { has_next: false, page: 1, per_page: 5, total: 2 },
    });
    const { target } = mount(OrganizationDetailContent, {
      organization: department,
      organizations: [company, parent, department],
    });
    await flushAsync();

    expect(
      [...target.querySelectorAll('[data-description-value]')].map(
        (element) => element.textContent,
      ),
    ).toEqual(['Ouransoft Group', 'Technical Div.', '2']);
    expect(target.textContent).toContain('Hoàng Văn Lượng');
    expect(target.textContent).toContain('Nguyễn Thu Minh');
    expect(target.textContent).toContain('ORS063');
    expect(target.textContent).toContain('ORS133');
    expect(target.textContent).toContain('users.values.noRoles');
    expect(target.querySelectorAll('img')).toHaveLength(2);
    expect(target.textContent).not.toContain(
      'organizations.fields.taxIdentificationNumber',
    );
    expect(state.getMembers).toHaveBeenCalledWith(department.id, {
      page: 1,
      per_page: 5,
    });
  });

  it('ignores an older page response and keeps loading until the latest page resolves', async () => {
    const stalePage = deferred<ReturnType<typeof memberResult>>();
    const latestPage = deferred<ReturnType<typeof memberResult>>();
    state.getMembers
      .mockReset()
      .mockResolvedValueOnce(memberResult(1, 'Initial member'))
      .mockReturnValueOnce(stalePage.promise)
      .mockReturnValueOnce(latestPage.promise);

    const { target } = mount(OrganizationDetailContent, {
      organization: childOrganization,
      organizations: [rootOrganization, childOrganization],
    });
    await flushAsync();
    target.querySelector<HTMLButtonElement>('button[data-page="2"]')?.click();
    await nextTick();
    target.querySelector<HTMLButtonElement>('button[data-page="1"]')?.click();
    await nextTick();

    stalePage.resolve(memberResult(2, 'Stale member'));
    await flushAsync();
    expect(target.textContent).not.toContain('Stale member');
    expect(target.querySelector('[data-spinning="true"]')).not.toBeNull();

    latestPage.resolve(memberResult(1, 'Latest member'));
    await flushAsync();
    expect(target.textContent).toContain('Latest member');
    expect(target.textContent).not.toContain('Stale member');
    expect(target.querySelector('[data-spinning="false"]')).not.toBeNull();
  });
});
