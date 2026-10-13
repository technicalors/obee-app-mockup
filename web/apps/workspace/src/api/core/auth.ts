import type { AuthUser, LoginPayload } from '../contracts';

import { requestClient, skipAuthRedirectConfig } from '#/api/request';

import { authUserSchema, loginPayloadSchema } from '../contracts';

export async function loginApi(payload: LoginPayload) {
  const data = loginPayloadSchema.parse(payload);

  return authUserSchema.parse(
    await requestClient.post<AuthUser>(
      '/auth/login',
      data,
      skipAuthRedirectConfig(),
    ),
  );
}

export async function logoutApi(): Promise<void> {
  await requestClient.request(
    '/auth/logout',
    skipAuthRedirectConfig({ method: 'POST' }),
  );
}
