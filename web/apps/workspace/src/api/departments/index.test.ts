import { beforeEach, describe, expect, it, vi } from 'vitest';

import { departmentUsersResource } from './index';

const requestClientState = vi.hoisted(() => ({
  get: vi.fn(),
}));

vi.mock('#/api/request', () => ({
  requestClient: requestClientState,
}));

describe('department users api', () => {
  beforeEach(() => {
    requestClientState.get.mockReset();
  });

  it('loads paginated department members through the relative endpoint', async () => {
    requestClientState.get.mockResolvedValue({
      items: [
        {
          avatar: null,
          company: {
            created_at: '2026-07-28T00:00:00.000000Z',
            id: 'company-1',
            name: 'Obee',
            tax_identification_number: '1234567890',
            updated_at: '2026-07-28T00:00:00.000000Z',
          },
          company_id: 'company-1',
          created_at: '2026-07-28T00:00:00.000000Z',
          departments: [
            {
              company_id: 'company-1',
              created_at: '2026-07-28T00:00:00.000000Z',
              id: 'department-1',
              name: 'Operations',
              parent_id: null,
              updated_at: '2026-07-28T00:00:00.000000Z',
            },
          ],
          email: 'jane@example.com',
          email_verified_at: null,
          id: 'user-1',
          is_active: true,
          name: 'Jane Doe',
          profile: null,
          roles: [],
          supabase_id: null,
          updated_at: '2026-07-28T00:00:00.000000Z',
          username: 'jane',
        },
      ],
      pagination: {
        has_next: true,
        page: 1,
        per_page: 10,
        total: 11,
      },
    });

    await expect(
      departmentUsersResource.getAll('department-1', {
        page: 1,
        per_page: 10,
      }),
    ).resolves.toMatchObject({
      items: [{ id: 'user-1' }],
      pagination: { total: 11 },
    });
    expect(requestClientState.get).toHaveBeenCalledWith(
      '/departments/department-1/users',
      {
        params: {
          page: 1,
          per_page: 10,
        },
      },
    );
  }, 10_000);
});
