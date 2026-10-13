import type { Router } from 'vue-router';

import { LOGIN_PATH } from '@vben/constants';
import { preferences } from '@vben/preferences';
import { useAccessStore, useUserStore } from '@vben/stores';
import { startProgress, stopProgress } from '@vben/utils';

import { ApiProblemError } from '#/api';
import { accessRoutes, coreRouteNames } from '#/router/routes';
import { useAuthStore } from '#/store';

import { generateAccess } from './access';

function isUnauthorizedError(error: unknown): boolean {
  return error instanceof ApiProblemError && error.problem.status === 401;
}

function readRedirectQuery(redirect: unknown): null | string {
  if (redirect === undefined) {
    return null;
  }

  if (typeof redirect !== 'string') {
    throw new TypeError('Route redirect query must be a string.');
  }

  return decodeURIComponent(redirect);
}

function getAuthenticatedLoginTarget(
  redirect: unknown,
  homePath: string | undefined,
): string {
  const redirectPath = readRedirectQuery(redirect);

  if (redirectPath !== null) {
    return redirectPath;
  }

  if (homePath !== undefined) {
    return homePath;
  }

  return preferences.app.defaultHomePath;
}

function getPostAccessRedirectPath(
  redirect: unknown,
  toPath: string,
  toFullPath: string,
  userHomePath: string,
): string {
  const redirectPath = readRedirectQuery(redirect);

  if (redirectPath !== null) {
    return redirectPath;
  }

  if (toPath === preferences.app.defaultHomePath) {
    return userHomePath;
  }

  return toFullPath;
}

function redirectToLogin(to: { fullPath: string }) {
  return {
    path: LOGIN_PATH,
    query:
      to.fullPath === preferences.app.defaultHomePath
        ? {}
        : { redirect: encodeURIComponent(to.fullPath) },
    replace: true,
  };
}

/**
 * 通用守卫配置
 * @param router
 */
function setupCommonGuard(router: Router) {
  // 记录已经加载的页面
  const loadedPaths = new Set<string>();

  router.beforeEach((to) => {
    to.meta.loaded = loadedPaths.has(to.path);

    // 页面加载进度条
    if (!to.meta.loaded && preferences.transition.progress) {
      startProgress();
    }
    return true;
  });

  router.afterEach((to) => {
    // 记录页面是否加载,如果已经加载，后续的页面切换动画等效果不在重复执行

    loadedPaths.add(to.path);

    // 关闭页面加载进度条
    if (preferences.transition.progress) {
      stopProgress();
    }
  });
}

/**
 * 权限访问守卫配置
 * @param router
 */
function setupAccessGuard(router: Router) {
  router.beforeEach(async (to, from) => {
    const accessStore = useAccessStore();
    const userStore = useUserStore();
    const authStore = useAuthStore();

    // 基本路由，这些路由不需要进入权限拦截
    if (coreRouteNames.includes(to.name as string)) {
      if (to.path === LOGIN_PATH && authStore.hasSession) {
        return getAuthenticatedLoginTarget(
          to.query.redirect,
          userStore.userInfo?.homePath,
        );
      }
      return true;
    }

    if (!authStore.hasSession) {
      // 明确声明忽略权限访问权限，则可以访问
      if (to.meta.ignoreAccess) {
        return true;
      }

      // 没有访问权限，跳转登录页面
      if (to.fullPath !== LOGIN_PATH) {
        return redirectToLogin(to);
      }
      return to;
    }

    // 是否已经生成过动态路由
    if (accessStore.isAccessChecked) {
      return true;
    }

    // 生成路由表
    // 当前登录用户拥有的角色标识列表
    let userInfo = userStore.userInfo;

    if (!userInfo) {
      try {
        userInfo = await authStore.fetchUserInfo();
      } catch (error: unknown) {
        if (isUnauthorizedError(error)) {
          authStore.clearSession();
          return redirectToLogin(to);
        }

        throw error;
      }
    }

    const userRoles = userInfo.roles;

    // 生成菜单和路由
    const { accessibleMenus, accessibleRoutes } = await generateAccess({
      roles: userRoles,
      router,
      // 则会在菜单中显示，但是访问会被重定向到403
      routes: accessRoutes,
    });

    // 保存菜单信息和路由信息
    accessStore.setAccessMenus(accessibleMenus);
    accessStore.setAccessRoutes(accessibleRoutes);
    accessStore.setIsAccessChecked(true);
    const redirectPath = getPostAccessRedirectPath(
      from.query.redirect,
      to.path,
      to.fullPath,
      userInfo.homePath,
    );

    return {
      ...router.resolve(redirectPath),
      replace: true,
    };
  });
}

/**
 * 项目守卫配置
 * @param router
 */
function createRouterGuard(router: Router) {
  /** 通用 */
  setupCommonGuard(router);
  /** 权限访问 */
  setupAccessGuard(router);
}

export { createRouterGuard };
