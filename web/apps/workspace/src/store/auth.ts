import type { AuthUser, LoginPayload } from '#/api';

import { computed, ref } from 'vue';
import { useRouter } from 'vue-router';

import { LOGIN_PATH } from '@vben/constants';
import { preferences } from '@vben/preferences';
import { resetAllStores, useAccessStore, useUserStore } from '@vben/stores';

import { notification } from 'ant-design-vue';
import { acceptHMRUpdate, defineStore } from 'pinia';

import {
  ApiProblemError,
  ensureCsrfCookie,
  getUserInfoApi,
  loginApi,
  logoutApi,
} from '#/api';
import { $t } from '#/locales';

import { isCustomerUser, SESSION_MARKER, toUserInfo } from './user-adapter';

export { isCustomerUser, SESSION_MARKER, toUserInfo };

function isUnauthorizedError(error: unknown): boolean {
  return error instanceof ApiProblemError && error.problem.status === 401;
}

export const useAuthStore = defineStore(
  'auth',
  () => {
    const accessStore = useAccessStore();
    const userStore = useUserStore();
    const router = useRouter();

    const loginLoading = ref(false);
    const user = ref<AuthUser | null>(null);
    const hasSession = computed(
      () => accessStore.accessToken === SESSION_MARKER && user.value !== null,
    );

    async function authLogin(
      params: LoginPayload,
      onSuccess?: () => Promise<void> | void,
    ) {
      try {
        loginLoading.value = true;
        await ensureCsrfCookie();

        const userInfo = await loginApi(params);

        if (isCustomerUser(userInfo)) {
          await logout(false);
          notification.error({
            description: $t('auth.customerLoginBlockedDescription'),
            message: $t('auth.customerLoginBlocked'),
          });
          return { userInfo: null };
        }

        setAuthenticatedUser(userInfo);

        if (accessStore.loginExpired) {
          accessStore.setLoginExpired(false);
        } else {
          onSuccess
            ? await onSuccess()
            : await router.push(preferences.app.defaultHomePath);
        }

        notification.success({
          description: `${$t('authentication.loginSuccessDesc')}: ${userInfo.name}`,
          duration: 3,
          message: $t('authentication.loginSuccess'),
        });

        return { userInfo };
      } catch (error: unknown) {
        if (error instanceof ApiProblemError) {
          notification.error({
            description: error.problem.detail,
            message: error.problem.title,
          });
          return { userInfo: null };
        }

        throw error;
      } finally {
        loginLoading.value = false;
      }
    }

    async function logout(redirect: boolean = true) {
      try {
        await ensureCsrfCookie();
        await logoutApi();
      } catch (error: unknown) {
        if (!isUnauthorizedError(error)) {
          throw error;
        }
      }

      clearSession();

      await router.replace({
        path: LOGIN_PATH,
        query: redirect
          ? {
              redirect: encodeURIComponent(router.currentRoute.value.fullPath),
            }
          : {},
      });
    }

    function setAuthenticatedUser(authenticatedUser: AuthUser) {
      user.value = authenticatedUser;
      accessStore.setAccessToken(SESSION_MARKER);
      userStore.setUserInfo(toUserInfo(authenticatedUser));
      accessStore.setAccessCodes(
        authenticatedUser.permissions.map((permission) => permission.name),
      );
    }

    function clearSession() {
      user.value = null;
      resetAllStores();
      accessStore.setLoginExpired(false);
    }

    async function fetchUserInfo() {
      const userInfo = await getUserInfoApi();

      if (isCustomerUser(userInfo)) {
        await logout(false);
        throw new Error('Customer users cannot access the admin application.');
      }

      setAuthenticatedUser(userInfo);
      return toUserInfo(userInfo);
    }

    function $reset() {
      loginLoading.value = false;
      user.value = null;
    }

    return {
      $reset,
      authLogin,
      clearSession,
      fetchUserInfo,
      hasSession,
      loginLoading,
      logout,
      setAuthenticatedUser,
      user,
    };
  },
  {
    persist: {
      pick: ['user'],
    },
  },
);

const hot = import.meta.hot;
if (hot) {
  hot.accept(acceptHMRUpdate(useAuthStore, hot));
}
