import { describe, expect, it, vi } from 'vitest';

import { createUserIndexQuery } from './query';
import { createUserTableColumns, createUserTableFilterSchema } from './schema';

vi.mock('#/store/role-options', () => ({
  useRoleOptionsStore: () => ({ loadOnce: vi.fn() }),
}));

describe('createUserIndexQuery', () => {
  it('maps supported user filters to the users index contract', () => {
    expect(
      createUserIndexQuery(
        {
          page: 2,
          per_page: 20,
        },
        {
          role_names: ['admin'],
          search: 'alice',
          status: 'all',
        },
      ),
    ).toEqual({
      page: 2,
      per_page: 20,
      role_names: ['admin'],
      search: 'alice',
      trashed: 'with',
    });
  });

  it('lists only active users when optional filters are empty', () => {
    expect(
      createUserIndexQuery(
        {
          page: 1,
          per_page: 10,
        },
        {
          role_names: [],
          search: '',
          status: 'active',
        },
      ),
    ).toEqual({
      page: 1,
      per_page: 10,
    });
  });

  it('requests only deleted users for the deleted status', () => {
    expect(
      createUserIndexQuery({ page: 1, per_page: 10 }, { status: 'deleted' }),
    ).toEqual({
      page: 1,
      per_page: 10,
      trashed: 'only',
    });
  });
});

describe('createUserTableFilterSchema', () => {
  it('defaults the status filter to active users', () => {
    const statusFilter = createUserTableFilterSchema().find(
      (field) => field.fieldName === 'status',
    );

    expect(statusFilter?.defaultValue).toBe('active');
  });
});

describe('createUserTableColumns', () => {
  it('shows the requested user columns in the intended order', () => {
    const columns = createUserTableColumns({
      hasAccessByCodes: () => false,
      onAction: () => {},
    });

    if (columns === undefined) {
      throw new TypeError('User table columns are required.');
    }

    expect(columns.map((column) => column.title)).toEqual([
      'users.columns.sequence',
      'users.columns.name',
      'users.columns.username',
      'users.columns.employeeId',
      'users.columns.email',
      'users.columns.organization',
      'users.columns.roles',
      'users.columns.status',
      'users.columns.actions',
    ]);

    expect(columns[0]).toMatchObject({ type: 'seq' });
    expect(columns[1]).toMatchObject({ field: 'name', minWidth: 170 });
    expect(columns[2]).toMatchObject({ field: 'username', minWidth: 140 });
    expect(columns[4]).toMatchObject({ field: 'email', minWidth: 190 });
    expect(columns[5]).toMatchObject({ field: 'organization', minWidth: 160 });
    expect(columns[6]).toMatchObject({ field: 'roles', minWidth: 145 });
    expect(columns[7]).toMatchObject({ field: 'deleted_at', minWidth: 110 });
    expect(columns[8]).toMatchObject({
      field: 'actions',
      fixed: 'right',
      width: 132,
    });

    if (typeof columns[3]?.formatter !== 'function') {
      throw new TypeError('Employee-code column formatter is required.');
    }

    if (typeof columns[4]?.formatter !== 'function') {
      throw new TypeError('Email column formatter is required.');
    }

    expect(columns[1]?.field).toBe('name');
    expect(
      columns[3].formatter({ row: { profile: { code: 'EMP-001' } } } as never),
    ).toBe('EMP-001');
    expect(columns[3].formatter({ row: { profile: null } } as never)).toBe(
      'common.notProvided',
    );
    expect(
      columns[4].formatter({ row: { email: 'alice@example.com' } } as never),
    ).toBe('alice@example.com');
    expect(columns[4].formatter({ row: { email: null } } as never)).toBe(
      'common.notProvided',
    );
  });

  it('renders the direct organization and roles as plain text', () => {
    const columns = createUserTableColumns({
      hasAccessByCodes: () => false,
      onAction: () => {},
    });
    const organizationColumn = columns?.[5];
    const rolesColumn = columns?.[6];

    if (
      typeof organizationColumn?.formatter !== 'function' ||
      typeof rolesColumn?.formatter !== 'function'
    ) {
      throw new TypeError(
        'Organization and role text formatters are required.',
      );
    }

    const row = {
      organization: { id: 'organization-1', name: 'Engineering' },
      roles: [
        { id: 'role-1', name: 'Administrator' },
        { id: 'role-2', name: 'Reviewer' },
      ],
    };

    expect(organizationColumn.cellRender).toBeUndefined();
    expect(rolesColumn.cellRender).toBeUndefined();
    expect(organizationColumn.formatter({ row } as never)).toBe('Engineering');
    expect(rolesColumn.formatter({ row } as never)).toBe(
      'Administrator, Reviewer',
    );

    const emptyRow = { organization: null, roles: [] };
    expect(organizationColumn.formatter({ row: emptyRow } as never)).toBe(
      'common.notProvided',
    );
    expect(rolesColumn.formatter({ row: emptyRow } as never)).toBe(
      'common.notProvided',
    );
  });
});

describe('user table row actions', () => {
  function visibleActionCodes(deletedAt: null | string): string[] {
    const columns = createUserTableColumns({
      hasAccessByCodes: () => true,
      onAction: () => {},
    });
    const options = columns?.[8]?.cellRender?.options as
      | Array<{ code: string; visible: (row: unknown) => boolean }>
      | undefined;

    if (options === undefined) {
      throw new TypeError('User row actions are required.');
    }

    return options
      .filter((option) => option.visible({ deleted_at: deletedAt }))
      .map((option) => option.code);
  }

  it('offers edit and delete for active users', () => {
    expect(visibleActionCodes(null)).toEqual(['view', 'edit', 'delete']);
  });

  it('offers view and restore for deleted users', () => {
    expect(visibleActionCodes('2026-01-01T00:00:00.000000Z')).toEqual([
      'view',
      'restore',
    ]);
  });
});
