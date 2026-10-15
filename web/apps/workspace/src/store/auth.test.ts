import type { AuthUser } from '#/api';

import { describe, expect, it } from 'vitest';

import { authUserSchema } from '#/api/contracts';

import { isCustomerUser, SESSION_MARKER, toUserInfo } from './user-adapter';

function makeUser(overrides: Partial<AuthUser> = {}): AuthUser {
  return {
    avatar: null,
    organization: null,
    organization_id: null,
    root_organization_id: null,
    created_at: '2026-06-11T00:00:00.000000Z',
    email: 'admin@example.com',
    email_verified_at: null,
    id: 'user-1',
    deleted_at: null,
    name: 'Admin User',
    permissions: [
      {
        id: 'permission-1',
        name: 'users.viewAny',
        description: null,
        created_at: null,
        updated_at: null,
      },
    ],
    profile: null,
    supabase_id: null,
    roles: [
      {
        created_at: '2026-06-11T00:00:00.000000Z',
        description: null,
        id: 'role-1',
        name: 'admin',
        updated_at: '2026-06-11T00:00:00.000000Z',
      },
    ],
    updated_at: '2026-06-11T00:00:00.000000Z',
    username: 'admin',
    ...overrides,
  };
}

describe('auth user adapter', () => {
  it('parses the login auth shape without optional relations', () => {
    expect(
      authUserSchema.parse({
        avatar: null,
        organization: null,
        organization_id: null,
        root_organization_id: null,
        created_at: '2026-06-11T00:00:00.000000Z',
        email: 'admin@example.com',
        email_verified_at: null,
        id: 'user-1',
        deleted_at: null,
        name: 'Admin User',
        permissions: [
          {
            id: 'permission-1',
            name: 'users.viewAny',
            description: null,
            created_at: null,
            updated_at: null,
          },
        ],
        profile: null,
        roles: [],
        supabase_id: null,
        updated_at: '2026-06-11T00:00:00.000000Z',
        username: 'admin',
      }),
    ).toMatchObject({
      email: 'admin@example.com',
      permissions: [
        {
          id: 'permission-1',
          name: 'users.viewAny',
          description: null,
          created_at: null,
          updated_at: null,
        },
      ],
    });
  });

  it('parses the authenticated user shape with relations', () => {
    expect(
      authUserSchema.parse({
        avatar: null,
        organization: null,
        organization_id: null,
        root_organization_id: null,
        created_at: '2026-06-11T00:00:00.000000Z',
        email: 'admin@example.com',
        email_verified_at: null,
        id: 'user-1',
        deleted_at: null,
        name: 'Admin User',
        permissions: [
          {
            id: 'permission-1',
            name: 'users.viewAny',
            description: null,
            created_at: null,
            updated_at: null,
          },
        ],
        profile: null,
        roles: [],
        supabase_id: null,
        updated_at: '2026-06-11T00:00:00.000000Z',
        username: 'admin',
      }),
    ).toMatchObject({
      organization: null,
      root_organization_id: null,
    });
  });

  it('rejects permission names and incomplete permission models at the API boundary', () => {
    const user = makeUser();
    expect(
      authUserSchema.safeParse({ ...user, permissions: ['users.viewAny'] })
        .success,
    ).toBe(false);
    expect(
      authUserSchema.safeParse({
        ...user,
        permissions: [{ name: 'users.viewAny' }],
      }).success,
    ).toBe(false);
  });

  it('maps raw user roles and access fields to user info', () => {
    const userInfo = toUserInfo(makeUser());

    expect(userInfo.roles).toEqual(['admin']);
    expect(userInfo.token).toBe(SESSION_MARKER);
    expect(userInfo.userId).toBe('user-1');
    expect(userInfo.realName).toBe('Admin User');
  });

  it('maps a null email to an empty framework description', () => {
    expect(toUserInfo(makeUser({ email: null })).desc).toBe('');
  });

  it('detects customer users', () => {
    expect(
      isCustomerUser(
        makeUser({
          roles: [
            {
              created_at: '2026-06-11T00:00:00.000000Z',
              description: null,
              id: 'role-2',
              name: 'customer',
              updated_at: '2026-06-11T00:00:00.000000Z',
            },
          ],
        }),
      ),
    ).toBe(true);
  });
});
