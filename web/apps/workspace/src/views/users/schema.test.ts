import { describe, expect, it, vi } from 'vitest';

import { createUserIndexQuery } from './query';
import { createUserTableColumns } from './schema';

vi.mock('#/store/role-options', () => ({
  useRoleOptionsStore: vi.fn(),
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
          with_inactive: true,
          role_names: ['admin'],
          search: 'alice',
        },
      ),
    ).toEqual({
      with_inactive: 1,
      page: 2,
      per_page: 20,
      role_names: ['admin'],
      search: 'alice',
    });
  });

  it('omits empty optional filters from the users index contract', () => {
    expect(
      createUserIndexQuery(
        {
          page: 1,
          per_page: 10,
        },
        {
          role_names: [],
          search: '',
        },
      ),
    ).toEqual({
      page: 1,
      per_page: 10,
    });
  });

  it('omits with_inactive when the active-only option is selected', () => {
    expect(
      createUserIndexQuery(
        {
          page: 1,
          per_page: 10,
        },
        {
          with_inactive: false,
        },
      ),
    ).toEqual({
      page: 1,
      per_page: 10,
    });
  });
});

describe('createUserTableColumns', () => {
  it('shows only the requested user data columns before actions', () => {
    const columns = createUserTableColumns({
      hasAccessByCodes: () => false,
      onAction: () => {},
    });

    if (columns === undefined) {
      throw new TypeError('User table columns are required.');
    }

    expect(columns.slice(0, 4).map((column) => column.title)).toEqual([
      'page.users.columns.sequence',
      'page.users.columns.username',
      'page.users.columns.employeeId',
      'page.users.columns.status',
    ]);

    expect(columns[0]).toMatchObject({ type: 'seq' });

    if (typeof columns[2]?.formatter !== 'function') {
      throw new TypeError('Employee-code column formatter is required.');
    }

    expect(
      columns[2].formatter({
        row: { profile: { code: 'EMP-001' } },
      } as never),
    ).toBe('EMP-001');
  });
});
