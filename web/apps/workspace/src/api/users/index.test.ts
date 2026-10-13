import { beforeEach, describe, expect, it, vi } from 'vitest';

import { usersResource } from './index';

const requestClientMock = vi.hoisted(() => ({
  post: vi.fn(),
}));

vi.mock('#/api/request', () => ({
  requestClient: requestClientMock,
}));

vi.mock('#/api/resource', () => ({
  createCollectionResourceApi: vi.fn(() => ({
    getAll: vi.fn(),
  })),
  createResourceApi: vi.fn(() => ({
    create: vi.fn(),
    delete: vi.fn(),
    getAll: vi.fn(),
    getById: vi.fn(),
    update: vi.fn(),
  })),
}));

describe('usersResource', () => {
  beforeEach(() => {
    requestClientMock.post.mockReset();
  });

  it('uploads an avatar through the user avatar endpoint', async () => {
    const user = {
      avatar: 'https://obee.local/storage/avatars/users/user-1/avatar.png',
      company: null,
      company_id: null,
      created_at: '2026-06-11T00:00:00.000000Z',
      departments: [],
      email: null,
      email_verified_at: null,
      id: 'user-1',
      is_active: true,
      name: 'Employee One',
      profile: null,
      roles: [],
      supabase_id: null,
      updated_at: '2026-06-11T00:00:00.000000Z',
      username: 'employee.one',
    };
    const file = new File(['avatar'], 'avatar.png', { type: 'image/png' });
    requestClientMock.post.mockResolvedValue(user);

    await expect(usersResource.updateAvatar('user-1', file)).resolves.toEqual(
      user,
    );
    expect(requestClientMock.post).toHaveBeenCalledWith(
      '/users/user-1/avatar',
      expect.any(FormData),
      { headers: { 'Content-Type': 'multipart/form-data' } },
    );
    const firstCall = requestClientMock.post.mock.calls.at(0);
    expect(firstCall).toBeDefined();
    if (firstCall === undefined) {
      throw new Error('The avatar upload request was not recorded.');
    }

    const formData = firstCall[1] as FormData;
    expect(formData.get('avatar')).toBe(file);
  });
});
