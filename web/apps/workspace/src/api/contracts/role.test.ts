import { describe, expect, it } from 'vitest';

import {
  createRolePayloadSchema,
  roleWithPermissionsSchema,
  updateRolePayloadSchema,
} from './role';

const permission = {
  created_at: '2026-08-05T00:00:00.000000Z',
  description: null,
  id: 'a8a621c8-f7b6-4e90-80e9-3484d186f8d4',
  name: 'roles.viewAny',
  updated_at: '2026-08-05T00:00:00.000000Z',
};

describe('role contracts', () => {
  it('requires permissions on every role response', () => {
    expect(() =>
      roleWithPermissionsSchema.parse({
        created_at: null,
        description: null,
        id: 'role-1',
        name: 'admin',
        updated_at: null,
      }),
    ).toThrow('Required');
  });

  it('only accepts fields supported by role mutations', () => {
    expect(
      createRolePayloadSchema.parse({
        name: 'manager',
        permission_ids: [permission.id],
      }),
    ).toMatchObject({ name: 'manager' });

    expect(() =>
      updateRolePayloadSchema.parse({
        permissions: [permission],
      }),
    ).toThrow('Unrecognized key');
  });

  it('accepts the full role response contract', () => {
    expect(
      roleWithPermissionsSchema.parse({
        created_at: null,
        description: null,
        id: 'role-1',
        name: 'admin',
        permissions: [permission],
        updated_at: null,
      }),
    ).toMatchObject({ permissions: [permission] });
  });
});
