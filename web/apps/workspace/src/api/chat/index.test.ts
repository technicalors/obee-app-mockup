import { beforeEach, describe, expect, it, vi } from 'vitest';

import { getMatrixCredentialsApi } from './index';

const postMock = vi.hoisted(() => vi.fn());

vi.mock('#/api/request', () => ({
  requestClient: {
    post: postMock,
  },
}));

describe('chat API', () => {
  beforeEach(() => {
    postMock.mockReset();
    postMock.mockResolvedValue({
      access_token: 'syt_token',
      device_id: 'BROWSER_DEVICE',
      homeserver_url: 'http://obee.local',
      matrix_user_id: '@admin:obee.local',
    });
  });

  it('requests a new Matrix session without a device id initially', async () => {
    await getMatrixCredentialsApi();

    expect(postMock).toHaveBeenCalledWith('/chat/matrix-credentials', {});
  });

  it('requests a fresh token for the stored Matrix device', async () => {
    await getMatrixCredentialsApi('BROWSER_DEVICE');

    expect(postMock).toHaveBeenCalledWith('/chat/matrix-credentials', {
      device_id: 'BROWSER_DEVICE',
    });
  });
});
