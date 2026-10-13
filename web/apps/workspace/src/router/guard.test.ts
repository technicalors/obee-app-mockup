import type { Router } from 'vue-router';

import { beforeEach, describe, expect, it, vi } from 'vitest';

interface TestRoute {
  fullPath: string;
  meta: Record<string, unknown>;
  name: string;
  path: string;
  query: Record<string, unknown>;
}

type GuardCallback = (to: TestRoute, from: TestRoute) => Promise<unknown>;

const guardState = vi.hoisted(() => ({
  ApiProblemError: class ApiProblemError extends Error {
    constructor(public readonly problem: { status: number }) {
      super('API problem');
      this.name = 'ApiProblemError';
    }
  },
  accessStore: {
    isAccessChecked: false,
    setAccessMenus: vi.fn(),
    setAccessRoutes: vi.fn(),
    setIsAccessChecked: vi.fn(),
  },
  afterEachGuards: [] as Array<() => void>,
  authStore: {
    clearSession: vi.fn(),
    fetchUserInfo: vi.fn(),
    hasSession: true,
  },
  beforeEachGuards: [] as GuardCallback[],
  userStore: {
    userInfo: null,
  },
}));

vi.mock('@vben/constants', () => ({
  LOGIN_PATH: '/auth/login',
}));

vi.mock('@vben/preferences', () => ({
  preferences: {
    app: {
      defaultHomePath: '/dashboard',
    },
    transition: {
      progress: false,
    },
  },
}));

vi.mock('@vben/stores', () => ({
  useAccessStore: () => guardState.accessStore,
  useUserStore: () => guardState.userStore,
}));

vi.mock('@vben/utils', () => ({
  startProgress: vi.fn(),
  stopProgress: vi.fn(),
}));

vi.mock('#/api', () => ({
  ApiProblemError: guardState.ApiProblemError,
}));

vi.mock('#/router/routes', () => ({
  accessRoutes: [],
  coreRouteNames: ['Login'],
}));

vi.mock('#/store', () => ({
  useAuthStore: () => guardState.authStore,
}));

vi.mock('./access', () => ({
  generateAccess: vi.fn(),
}));

function makeRoute(path: string): TestRoute {
  return {
    fullPath: path,
    meta: {},
    name: 'Dashboard',
    path,
    query: {},
  };
}

async function setupAccessGuard(): Promise<GuardCallback> {
  const { createRouterGuard } = await import('./guard');
  const router = {
    afterEach: vi.fn((guard: () => void) => {
      guardState.afterEachGuards.push(guard);
    }),
    beforeEach: vi.fn((guard: GuardCallback) => {
      guardState.beforeEachGuards.push(guard);
    }),
    resolve: vi.fn((path: string) => ({ path })),
  } as unknown as Router;

  createRouterGuard(router);

  const accessGuard = guardState.beforeEachGuards[1];

  if (accessGuard === undefined) {
    throw new Error('Access guard was not registered.');
  }

  return accessGuard;
}

describe('router access guard', () => {
  beforeEach(() => {
    vi.resetModules();
    vi.clearAllMocks();
    guardState.afterEachGuards.length = 0;
    guardState.beforeEachGuards.length = 0;
    guardState.accessStore.isAccessChecked = false;
    guardState.authStore.hasSession = true;
    guardState.userStore.userInfo = null;
  });

  it('redirects to login when the stored session marker no longer has a backend session', async () => {
    guardState.authStore.fetchUserInfo.mockRejectedValue(
      new guardState.ApiProblemError({ status: 401 }),
    );

    const accessGuard = await setupAccessGuard();
    const result = await accessGuard(makeRoute('/production'), makeRoute('/'));

    expect(guardState.authStore.clearSession).toHaveBeenCalledOnce();
    expect(result).toEqual({
      path: '/auth/login',
      query: {
        redirect: encodeURIComponent('/production'),
      },
      replace: true,
    });
  });
});
