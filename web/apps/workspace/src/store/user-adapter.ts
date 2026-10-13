import type { UserInfo } from '@vben/types';

import type { AuthUser } from '#/api';

import { preferences } from '@vben/preferences';

export const SESSION_MARKER = 'session';
const CUSTOMER_ROLE = 'customer';

export function isCustomerUser(user: AuthUser): boolean {
  return user.roles.some((role) => role.name === CUSTOMER_ROLE);
}

export function toUserInfo(user: AuthUser): UserInfo {
  return {
    ...user,
    avatar: user.avatar === null ? preferences.app.defaultAvatar : user.avatar,
    desc: user.email === null ? '' : user.email,
    homePath: preferences.app.defaultHomePath,
    realName: user.name,
    roles: user.roles.map((role) => role.name),
    token: SESSION_MARKER,
    userId: String(user.id),
    username: user.username,
  };
}
