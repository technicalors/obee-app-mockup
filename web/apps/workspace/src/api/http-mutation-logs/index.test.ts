import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  getHttpMutationLogApi,
  getHttpMutationLogMarkdownApi,
  getHttpMutationLogsApi,
  suggestHttpMutationLogActionsApi,
  suggestHttpMutationLogUsersApi,
} from './index';

const request = vi.hoisted(() => ({ get: vi.fn() }));

vi.mock('#/api/request', () => ({
  requestClient: { get: request.get },
}));

const id = '019e2444-4fa6-716d-a1fe-58fd4e9c602d';

describe('http mutation-log API', () => {
  beforeEach(() => {
    request.get.mockReset();
  });

  it('reads an empty paginated result and rejects a malformed row', async () => {
    request.get.mockResolvedValueOnce({
      items: [],
      pagination: { has_next: false, page: 1, per_page: 10, total: 0 },
    });
    await expect(
      getHttpMutationLogsApi({ page: 1, per_page: 10 }),
    ).resolves.toMatchObject({ items: [], pagination: { total: 0 } });
    expect(request.get).toHaveBeenCalledWith('/http-mutation-logs', {
      params: { page: 1, per_page: 10 },
    });

    request.get.mockResolvedValueOnce({
      items: [{ id, code: 'ABC1234' }],
      pagination: { has_next: false, page: 1, per_page: 10, total: 1 },
    });
    await expect(
      getHttpMutationLogsApi({ page: 1, per_page: 10 }),
    ).rejects.toThrow(/action/);
  });

  it('loads detail and Markdown by UUID and preserves the returned text', async () => {
    request.get.mockResolvedValueOnce({ invalid: true });
    await expect(getHttpMutationLogApi(id)).rejects.toThrow(/action/);
    expect(request.get).toHaveBeenCalledWith(`/http-mutation-logs/${id}`);

    request.get.mockResolvedValueOnce({ markdown: '# Log ABC1234' });
    await expect(getHttpMutationLogMarkdownApi(id)).resolves.toBe(
      '# Log ABC1234',
    );
    expect(request.get).toHaveBeenCalledWith(
      `/http-mutation-logs/${id}/markdown`,
    );
  });

  it('uses the existing suggestion endpoint for actions and users', async () => {
    request.get.mockResolvedValueOnce(['UpdateUserAction']);
    await expect(suggestHttpMutationLogActionsApi('Update')).resolves.toEqual([
      'UpdateUserAction',
    ]);
    expect(request.get).toHaveBeenCalledWith('/http-mutation-logs/suggest', {
      params: { kind: 'action', limit: 10, q: 'Update' },
    });

    request.get.mockResolvedValueOnce([
      {
        avatar: null,
        email: null,
        id,
        name: 'Admin',
        username: 'admin',
      },
    ]);
    await expect(suggestHttpMutationLogUsersApi('adm')).resolves.toHaveLength(
      1,
    );
    expect(request.get).toHaveBeenLastCalledWith(
      '/http-mutation-logs/suggest',
      { params: { kind: 'user', limit: 10, q: 'adm' } },
    );
  });
});
