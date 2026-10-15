import { describe, expect, it } from 'vitest';

import { matrixCredentialsSchema } from './chat';

describe('chat contracts', () => {
  it('validates valid matrix credentials', () => {
    const validPayload = {
      access_token: 'syt_dummy_token_123',
      device_id: 'DEVICE_ID',
      homeserver_url: 'http://obee.local',
      matrix_user_id: '@admin:obee.local',
    };

    expect(matrixCredentialsSchema.parse(validPayload)).toEqual(validPayload);
  });

  it('rejects invalid matrix credentials', () => {
    expect(() =>
      matrixCredentialsSchema.parse({
        access_token: '',
        homeserver_url: 'not-a-url',
        matrix_user_id: '',
      }),
    ).toThrow('Invalid url');
  });
});
