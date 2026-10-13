import type { AuthUser } from '../contracts';

import { requestClient, skipAuthRedirectConfig } from '#/api/request';

import { authUserSchema } from '../contracts';

export async function getUserInfoApi() {
  return authUserSchema.parse(
    await requestClient.get<AuthUser>('/auth/user', skipAuthRedirectConfig()),
  );
}
