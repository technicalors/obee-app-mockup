import { beforeEach, describe, expect, it, vi } from 'vitest';

import { createUserPayloadSchema, userSchema } from '#/api/contracts';

import { createResourceApi, parsePaginatedResponse } from './resource';

const requestClient = vi.hoisted(() => ({
  delete: vi.fn(),
  get: vi.fn(),
  post: vi.fn(),
  put: vi.fn(),
}));

vi.mock('#/api/request', () => ({ requestClient }));

describe('parsePaginatedResponse', () => {
  it('parses paginated rows with the configured row schema', () => {
    expect(
      parsePaginatedResponse(userSchema, {
        items: [
          {
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
            profile: null,
            roles: [],
            supabase_id: null,
            updated_at: '2026-06-11T00:00:00.000000Z',
            username: 'admin',
          },
        ],
        pagination: {
          has_next: false,
          page: 1,
          per_page: 10,
          total: 1,
        },
      }),
    ).toEqual({
      items: [
        expect.objectContaining({
          email: 'admin@example.com',
          id: 'user-1',
        }),
      ],
      pagination: {
        has_next: false,
        page: 1,
        per_page: 10,
        total: 1,
      },
    });
  });

  it('fails fast for malformed paginated rows', () => {
    expect(() =>
      parsePaginatedResponse(userSchema, {
        items: [
          {
            id: 'user-1',
          },
        ],
        pagination: {
          has_next: false,
          page: 1,
          per_page: 10,
          total: 1,
        },
      }),
    ).toThrow('Required');
  });

  it('requires roles and departments on list rows', () => {
    expect(() =>
      parsePaginatedResponse(userSchema, {
        items: [
          {
            avatar: null,
            company_id: null,
            created_at: '2026-06-11T00:00:00.000000Z',
            email: 'admin@example.com',
            email_verified_at: null,
            id: 'user-1',
            is_active: true,
            name: 'Admin User',
            supabase_id: null,
            updated_at: '2026-06-11T00:00:00.000000Z',
            username: 'admin',
          },
        ],
        pagination: {
          has_next: false,
          page: 1,
          per_page: 10,
          total: 1,
        },
      }),
    ).toThrow('Required');
  });

  it('requires company, profile, roles, and departments on user rows', () => {
    expect(() =>
      userSchema.parse({
        avatar: null,
        company_id: null,
        created_at: '2026-06-11T00:00:00.000000Z',
        departments: [],
        email: 'admin@example.com',
        email_verified_at: null,
        id: 'user-1',
        is_active: true,
        name: 'Admin User',
        roles: [],
        supabase_id: null,
        updated_at: '2026-06-11T00:00:00.000000Z',
        username: 'admin',
      }),
    ).toThrow('Required');
  });
});

describe('createResourceApi', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('validates request payloads before posting', async () => {
    const api = createResourceApi('/users', {
      createPayloadSchema: createUserPayloadSchema,
      rowSchema: userSchema,
    });

    await expect(
      api.create({
        department_id: 'department-1',
        email: 'not-an-email',
        name: 'Alice',
        password: 'secret123',
        username: 'alice',
      }),
    ).rejects.toThrow('Invalid email');

    expect(requestClient.post).not.toHaveBeenCalled();
  });

  it('requires the detail response shape for create responses', async () => {
    const api = createResourceApi('/users', {
      createPayloadSchema: createUserPayloadSchema,
      createResponseSchema: userSchema,
      rowSchema: userSchema,
    });

    requestClient.post.mockResolvedValue({
      avatar: null,
      company_id: null,
      created_at: '2026-06-11T00:00:00.000000Z',
      departments: [],
      email: 'admin@example.com',
      email_verified_at: null,
      id: 'user-1',
      is_active: true,
      name: 'Admin User',
      profile: null,
      roles: [],
      supabase_id: null,
      updated_at: '2026-06-11T00:00:00.000000Z',
      username: 'admin',
    });

    await expect(
      api.create({
        department_id: 'department-1',
        email: 'admin@example.com',
        name: 'Admin User',
        password: 'secret123',
        username: 'admin',
      }),
    ).rejects.toThrow('Required');
  });
});
