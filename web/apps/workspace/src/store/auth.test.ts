import type { AuthUser } from '#/api';

import { describe, expect, it } from 'vitest';

import { authUserSchema } from '#/api/contracts';

import { isCustomerUser, SESSION_MARKER, toUserInfo } from './user-adapter';

function makeUser(overrides: Partial<AuthUser> = {}): AuthUser {
  return {
    avatar: null,
    company: null,
    company_id: null,
    created_at: '2026-06-11T00:00:00.000000Z',
    email: 'admin@example.com',
    email_verified_at: null,
    id: 'user-1',
    is_active: true,
    name: 'Admin User',
    permissions: ['users.viewAny'],
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
    departments: [],
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
        company: null,
        company_id: null,
        created_at: '2026-06-11T00:00:00.000000Z',
        departments: [],
        email: 'admin@example.com',
        email_verified_at: null,
        id: 'user-1',
        is_active: true,
        name: 'Admin User',
        permissions: ['users.viewAny'],
        profile: null,
        roles: [],
        supabase_id: null,
        updated_at: '2026-06-11T00:00:00.000000Z',
        username: 'admin',
      }),
    ).toMatchObject({
      email: 'admin@example.com',
      permissions: ['users.viewAny'],
    });
  });

  it('parses the authenticated user shape with relations', () => {
    expect(
      authUserSchema.parse({
        avatar: null,
        company: null,
        company_id: null,
        created_at: '2026-06-11T00:00:00.000000Z',
        departments: [],
        email: 'admin@example.com',
        email_verified_at: null,
        id: 'user-1',
        is_active: true,
        name: 'Admin User',
        permissions: ['users.viewAny'],
        profile: null,
        roles: [],
        supabase_id: null,
        updated_at: '2026-06-11T00:00:00.000000Z',
        username: 'admin',
      }),
    ).toMatchObject({
      company: null,
      departments: [],
    });
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
