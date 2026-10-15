/* eslint-disable vue/one-component-per-file -- Component mocks and mounts are local to this test. */

import type { DefaultOptionType } from 'ant-design-vue/es/vc-tree-select/TreeSelect';

import type { PropType } from 'vue';

import type {
  OrganizationHierarchy,
  UserTreeSelectionUser,
} from '#/api/contracts';

import { createApp, defineComponent, h } from 'vue';

import { afterEach, describe, expect, it, vi } from 'vitest';

import { userTreeSelectionUserSchema } from '#/api/contracts';

import { buildUserTreeOptions } from './user-tree-select';
import UserTreeSelect from './user-tree-select.vue';

vi.mock('#/locales', () => ({ $t: (key: string) => key }));
vi.mock('ant-design-vue', () => ({
  TreeSelect: Object.assign(
    defineComponent({
      props: {
        dataTestid: { type: String, default: undefined },
        disabled: Boolean,
        filterTreeNode: {
          type: Function as PropType<
            (input: string, option: DefaultOptionType) => boolean
          >,
          default: undefined,
        },
        multiple: Boolean,
        notFoundContent: { type: String, default: undefined },
        value: {
          type: [String, Array] as PropType<string | string[]>,
          default: undefined,
        },
      },
      emits: ['update:value'],
      setup(
        props: {
          dataTestid?: string;
          disabled?: boolean;
          filterTreeNode?: (
            input: string,
            option: DefaultOptionType,
          ) => boolean;
          multiple?: boolean;
          notFoundContent?: string;
          value?: string | string[];
        },
        { emit },
      ) {
        return () =>
          h(
            'div',
            {
              'data-current': Array.isArray(props.value)
                ? props.value.join(',')
                : (props.value ?? ''),
              'data-testid': props.dataTestid,
              'data-disabled': String(props.disabled),
              'data-multiple': String(props.multiple),
              'data-not-found-content': props.notFoundContent,
              'data-searches-profile-code': String(
                props.filterTreeNode?.('emp-001', {
                  searchText: 'Alice alice emp-001',
                } satisfies DefaultOptionType),
              ),
            },
            [
              h(
                'button',
                {
                  disabled: props.disabled,
                  onClick: () =>
                    emit(
                      'update:value',
                      props.multiple
                        ? [
                            ...(Array.isArray(props.value) ? props.value : []),
                            'organization-team',
                            'user-1',
                            'user-1',
                          ]
                        : 'user-2',
                    ),
                },
                'select',
              ),
              h(
                'button',
                {
                  disabled: props.disabled,
                  onClick: () => emit('update:value', undefined),
                  type: 'button',
                },
                'clear',
              ),
            ],
          );
      },
    }),
    { SHOW_CHILD: 'SHOW_CHILD' },
  ),
}));

function makeOrganization(
  id: string,
  name: string,
  parent: null | OrganizationHierarchy = null,
): OrganizationHierarchy {
  return {
    id,
    name,
    parent_id: parent?.id ?? null,
    parent,
    tax_identification_number: null,
    type: parent === null ? 'Công ty' : 'Nhóm',
    created_at: '2026-06-16T08:00:00.000000Z',
    updated_at: '2026-06-16T08:00:00.000000Z',
  };
}

function makeUser(
  organization: OrganizationHierarchy,
  overrides: Partial<UserTreeSelectionUser> = {},
): UserTreeSelectionUser {
  return {
    id: 'user-1',
    deleted_at: null,
    name: 'Alice Nguyen',
    organization,
    organization_id: organization.id,
    profile: null,
    username: 'alice',
    ...overrides,
  };
}

const rootOrganization = makeOrganization('root', 'Obee Company');
const division = makeOrganization('division', 'Delivery', rootOrganization);
const department = makeOrganization('department', 'Operations', division);
const team = makeOrganization('team', 'Field Team', department);
const usersWithHierarchy = [
  userTreeSelectionUserSchema.parse(
    makeUser(team, {
      profile: { code: 'EMP-001' },
    }),
  ),
  userTreeSelectionUserSchema.parse(
    makeUser(team, { id: 'user-2', name: 'Bob Tran', username: 'bob' }),
  ),
];

const mountedApps: Array<ReturnType<typeof createApp>> = [];

function mountTreeSelect(options: {
  loadError?: boolean;
  loading?: boolean;
  modelValue: string[];
  multiple: boolean;
  users: UserTreeSelectionUser[];
}) {
  const host = document.createElement('div');
  const app = createApp(UserTreeSelect, options);
  mountedApps.push(app);
  app.mount(host);

  return host;
}

afterEach(() => {
  mountedApps.splice(0).forEach((app) => app.unmount());
});

describe('buildUserTreeOptions', () => {
  it('keeps users from different root organizations in separate trees', () => {
    const secondRoot = makeOrganization('root-2', 'Second root');
    const secondTeam = makeOrganization('other-team', 'Other Team', secondRoot);
    const secondUser = userTreeSelectionUserSchema.parse(
      makeUser(secondTeam, { id: 'user-3' }),
    );
    const roots = buildUserTreeOptions([...usersWithHierarchy, secondUser]);

    expect(roots.map((root) => root.value)).toEqual([
      'organization-root',
      'organization-root-2',
    ]);
    expect(roots[1]).toMatchObject({
      children: [
        { value: 'organization-other-team', children: [{ value: 'user-3' }] },
      ],
    });
    expect(JSON.stringify(roots[0])).not.toContain('user-3');
  });

  it('builds organization ancestry and groups direct organization users', () => {
    const [root] = buildUserTreeOptions(usersWithHierarchy);

    expect(root).toMatchObject({
      label: 'Obee Company',
      value: 'organization-root',
      children: [
        {
          label: 'Delivery',
          value: 'organization-division',
          children: [
            {
              label: 'Operations',
              value: 'organization-department',
              children: [
                {
                  label: 'Field Team',
                  value: 'organization-team',
                  children: [
                    {
                      key: 'user-1',
                      label: 'Alice Nguyen',
                      searchText: 'Alice Nguyen alice EMP-001',
                      value: 'user-1',
                    },
                    { key: 'user-2', value: 'user-2' },
                  ],
                },
              ],
            },
          ],
        },
      ],
    });
  });
});

describe('user tree response contract', () => {
  it('requires a direct organization for a tree user', () => {
    expect(() =>
      userTreeSelectionUserSchema.parse({
        id: 'user-1',
        deleted_at: null,
        name: 'Alice Nguyen',
        profile: null,
        username: 'alice',
      }),
    ).toThrow('organization');
  });

  it('requires the recursive parent relation on every selected organization', () => {
    expect(() =>
      userTreeSelectionUserSchema.parse({
        ...makeUser(team),
        organization: { ...team, parent: { ...department, parent: undefined } },
      }),
    ).toThrow('parent');
  });
});

describe('user tree select', () => {
  it('emits only unique user IDs when a checked department branch is returned', () => {
    const emitted: unknown[] = [];
    const host = document.createElement('div');

    const app = createApp(UserTreeSelect, {
      modelValue: [],
      multiple: true,
      users: usersWithHierarchy,
      'onUpdate:modelValue': (value: unknown) => emitted.push(value),
    });
    mountedApps.push(app);
    app.mount(host);
    host.querySelector('button')?.click();

    expect(emitted).toEqual([['user-1']]);
    expect(
      host.querySelector<HTMLElement>('[data-current]')?.dataset
        .searchesProfileCode,
    ).toBe('true');
    expect(
      host.querySelector<HTMLElement>('[data-current]')?.dataset
        .notFoundContent,
    ).toBe('');
  });

  it('supports a single selected user', () => {
    const host = document.createElement('div');
    const emitted: unknown[] = [];
    const app = createApp(UserTreeSelect, {
      modelValue: ['user-1'],
      multiple: false,
      users: usersWithHierarchy,
      'onUpdate:modelValue': (value: unknown) => emitted.push(value),
    });
    mountedApps.push(app);
    app.mount(host);
    host.querySelector('button')?.click();

    expect(
      host.querySelector<HTMLElement>('[data-multiple]')?.dataset.multiple,
    ).toBe('false');
    expect(emitted).toEqual([['user-2']]);
  });

  it('emits an empty array when cleared', () => {
    const emitted: unknown[] = [];
    const host = document.createElement('div');
    const app = createApp(UserTreeSelect, {
      modelValue: ['user-1'],
      multiple: true,
      users: usersWithHierarchy,
      'onUpdate:modelValue': (value: unknown) => emitted.push(value),
    });
    mountedApps.push(app);
    app.mount(host);
    [...host.querySelectorAll('button')]
      .find((button) => button.textContent === 'clear')
      ?.click();

    expect(emitted).toEqual([[]]);
  });

  it('preserves the selection and disables changes after a load error', () => {
    const host = mountTreeSelect({
      loadError: true,
      modelValue: ['user-1'],
      multiple: true,
      users: usersWithHierarchy,
    });

    expect(
      host.querySelector<HTMLElement>('[data-current]')?.dataset.current,
    ).toBe('user-1');
    expect(
      host.querySelector<HTMLElement>('[data-disabled]')?.dataset.disabled,
    ).toBe('true');
    expect(host.querySelector('[role="alert"]')?.textContent).toBe(
      'userTreeSelect.loadError',
    );
  });

  it('preserves the selection and disables changes while loading', () => {
    const host = mountTreeSelect({
      loading: true,
      modelValue: ['user-1'],
      multiple: true,
      users: usersWithHierarchy,
    });

    expect(
      host.querySelector<HTMLElement>('[data-current]')?.dataset.current,
    ).toBe('user-1');
    expect(
      host.querySelector<HTMLElement>('[data-disabled]')?.dataset.disabled,
    ).toBe('true');
  });
});

describe('existing assignments outside the available options', () => {
  it('preserves an assigned user absent from the available root options', () => {
    const emitted: unknown[] = [];
    const host = document.createElement('div');
    const app = createApp(UserTreeSelect, {
      modelValue: ['transferred-user'],
      multiple: true,
      users: usersWithHierarchy,
      'onUpdate:modelValue': (value: unknown) => emitted.push(value),
    });
    mountedApps.push(app);
    app.mount(host);
    host.querySelector('button')?.click();
    expect(emitted).toEqual([['transferred-user', 'user-1']]);

    [...host.querySelectorAll('button')]
      .find((button) => button.textContent === 'clear')
      ?.click();

    expect(emitted).toEqual([['transferred-user', 'user-1'], []]);
  });
});
