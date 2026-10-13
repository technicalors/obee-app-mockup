import type { AuthUser } from '#/api';

import { useAccessStore, useUserStore } from '@vben/stores';

import { createPinia, setActivePinia } from 'pinia';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import { SESSION_MARKER } from './user-adapter';

const router = vi.hoisted(() => ({
  currentRoute: {
    value: {
      fullPath: '/dashboard',
    },
  },
  push: vi.fn(),
  replace: vi.fn(),
}));

const api = vi.hoisted(() => ({
  ensureCsrfCookie: vi.fn(),
  getUserInfoApi: vi.fn(),
  loginApi: vi.fn(),
  logoutApi: vi.fn(),
}));

vi.mock('vue-router', () => ({
  useRouter: () => router,
}));

vi.mock('ant-design-vue', () => ({
  notification: {
    error: vi.fn(),
    success: vi.fn(),
  },
}));

vi.mock('#/locales', () => ({
  $t: (key: string) => key,
}));

vi.mock('#/api', () => ({
  ApiProblemError: class ApiProblemError extends Error {},
  ensureCsrfCookie: api.ensureCsrfCookie,
  getUserInfoApi: api.getUserInfoApi,
  loginApi: api.loginApi,
  logoutApi: api.logoutApi,
}));

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

describe('auth store login flow', () => {
  beforeEach(() => {
    setActivePinia(createPinia());
    vi.clearAllMocks();
  });

  it('bootstraps CSRF before posting login credentials', async () => {
    const { useAuthStore } = await import('./auth');
    const payload = {
      email: 'admin@example.com',
      password: 'secret',
    };

    api.loginApi.mockResolvedValue(makeUser());

    await useAuthStore().authLogin(payload);

    expect(api.ensureCsrfCookie).toHaveBeenCalledOnce();
    expect(api.loginApi).toHaveBeenCalledWith(payload);

    const csrfCallOrder = api.ensureCsrfCookie.mock.invocationCallOrder[0];
    const loginCallOrder = api.loginApi.mock.invocationCallOrder[0];

    expect(csrfCallOrder).toBeDefined();
    expect(loginCallOrder).toBeDefined();
    expect(csrfCallOrder as number).toBeLessThan(loginCallOrder as number);
  });

  it('does not treat a stale session marker as an active session', async () => {
    const { useAuthStore } = await import('./auth');

    useAccessStore().setAccessToken(SESSION_MARKER);

    expect(useAuthStore().hasSession).toBe(false);
  });

  it('fetches fresh user info from the API and updates access codes', async () => {
    const { useAuthStore } = await import('./auth');
    const authStore = useAuthStore();
    const accessStore = useAccessStore();
    const user = makeUser({
      permissions: ['departments.viewAny'],
    });

    api.getUserInfoApi.mockResolvedValue(user);

    const userInfo = await authStore.fetchUserInfo();

    expect(api.getUserInfoApi).toHaveBeenCalledOnce();
    expect(accessStore.accessToken).toBe(SESSION_MARKER);
    expect(accessStore.accessCodes).toEqual(['departments.viewAny']);
    expect(userInfo.realName).toBe('Admin User');
    expect(useUserStore().userInfo?.realName).toBe('Admin User');
  });
});
