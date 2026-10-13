import type { Permission } from '#/api';

import { describe, expect, it } from 'vitest';

import {
  createPermissionMatrix,
  CRUD_ACTIONS,
  formatPermissionResource,
  hasSamePermissionIds,
  mergeMatrixPermissionIds,
} from './matrix';

const permissions: Permission[] = [
  {
    created_at: null,
    description: null,
    id: 'permission-users-view-any',
    name: 'users.viewAny',
    updated_at: null,
  },
  {
    created_at: null,
    description: null,
    id: 'permission-users-create',
    name: 'users.create',
    updated_at: null,
  },
  {
    created_at: null,
    description: null,
    id: 'permission-http-mutation-logs-view-any',
    name: 'http-mutation-logs.viewAny',
    updated_at: null,
  },
  {
    created_at: null,
    description: null,
    id: 'permission-system-manage',
    name: 'system.database.manage',
    updated_at: null,
  },
];

describe('role permission matrix', () => {
  it('groups CRUD permissions by resource, displays readable labels, and sorts them alphabetically', () => {
    const matrix = createPermissionMatrix(permissions);

    expect(CRUD_ACTIONS).toEqual([
      'viewAny',
      'view',
      'create',
      'update',
      'delete',
    ]);
    expect(matrix.map((resource) => resource.displayName)).toEqual([
      'Http mutation logs',
      'Users',
    ]);
    expect(matrix[1]).toEqual(
      expect.objectContaining({
        displayName: 'Users',
        permissions: {
          create: permissions[1],
          viewAny: permissions[0],
        },
        resource: 'users',
      }),
    );
  });

  it('formats dashed and dotted resource names for display', () => {
    expect(formatPermissionResource('http-mutation-logs')).toBe(
      'Http mutation logs',
    );
    expect(formatPermissionResource('system.database')).toBe('System database');
  });

  it('keeps permissions outside the CRUD matrix when a role is saved', () => {
    const matrix = createPermissionMatrix(permissions);

    expect(
      mergeMatrixPermissionIds(
        ['permission-users-view-any', 'permission-system-manage'],
        matrix,
        ['permission-users-create'],
      ),
    ).toEqual(['permission-system-manage', 'permission-users-create']);
  });

  it('deduplicates permissions when selected ids already contain non-matrix permissions', () => {
    const matrix = createPermissionMatrix(permissions);

    expect(
      mergeMatrixPermissionIds(
        ['permission-users-view-any', 'permission-system-manage'],
        matrix,
        ['permission-system-manage', 'permission-users-create'],
      ),
    ).toEqual(['permission-system-manage', 'permission-users-create']);
  });

  it('compares drafts independent of permission ordering', () => {
    expect(hasSamePermissionIds(['a', 'b'], ['b', 'a'])).toBe(true);
    expect(hasSamePermissionIds(['a'], ['a', 'b'])).toBe(false);
  });
});
