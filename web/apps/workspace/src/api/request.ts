import type {
  AxiosError,
  AxiosResponse,
  InternalAxiosRequestConfig,
  RequestClientConfig,
  RequestClientOptions,
} from '@vben/request';

import { preferences } from '@vben/preferences';
import { isAxiosError, RequestClient } from '@vben/request';
import { resetAllStores, useAccessStore } from '@vben/stores';

import { mockAdapter } from '#/mocks/adapter';

import { ApiProblemError, parseProblemPayload } from './problem';
import { resolveRequestBaseURLs } from './request-base-urls';

interface AuthRedirectConfig {
  skipAuthRedirect?: boolean;
}

type AppRequestConfig = AuthRedirectConfig & RequestClientConfig;

interface RuntimeConfig {
  VITE_GLOB_BACKEND_URL?: unknown;
}

function readBackendURL(value: unknown): string {
  if (typeof value !== 'string') {
    throw new TypeError('VITE_GLOB_BACKEND_URL must be a string.');
  }

  return value;
}

function getConfiguredBackendURL(): string {
  if (!import.meta.env.PROD) {
    return readBackendURL(import.meta.env.VITE_GLOB_BACKEND_URL);
  }

  const runtimeConfig = window._VBEN_ADMIN_PRO_APP_CONF_ as RuntimeConfig;
  return readBackendURL(runtimeConfig.VITE_GLOB_BACKEND_URL);
}

const { apiBaseURL, csrfBaseURL } = resolveRequestBaseURLs(
  getConfiguredBackendURL(),
  import.meta.env.DEV,
);

export function skipAuthRedirectConfig(
  config: RequestClientConfig = {},
): AppRequestConfig {
  return {
    ...config,
    skipAuthRedirect: true,
  };
}

function createHttpStatusProblem(status: number): ApiProblemError {
  return new ApiProblemError({
    detail: 'Authentication is required.',
    status,
    title: 'Unauthenticated',
    type: 'about:blank',
  });
}

function getResponseContentType(response: AxiosResponse<unknown>): string {
  const contentType = response.headers['content-type'];

  return typeof contentType === 'string' ? contentType : '';
}

function redirectUnauthenticated(
  config:
    | (AuthRedirectConfig & InternalAxiosRequestConfig<unknown>)
    | undefined,
): void {
  if (config?.skipAuthRedirect === true) {
    return;
  }

  const accessStore = useAccessStore();
  accessStore.setAccessToken(null);

  if (
    preferences.app.loginExpiredMode === 'modal' &&
    accessStore.isAccessChecked
  ) {
    accessStore.setLoginExpired(true);
    return;
  }

  resetAllStores();
  accessStore.setLoginExpired(false);

  if (globalThis.location?.pathname !== '/auth/login') {
    globalThis.location.href = '/auth/login';
  }
}

function createRequestClient(baseURL: string, options?: RequestClientOptions) {
  const client = new RequestClient({
    ...options,
    baseURL,
    headers: {
      Accept: 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      ...options?.headers,
    },
    withCredentials: true,
    withXSRFToken: true,
  });

  client.addRequestInterceptor({
    fulfilled: async (config) => {
      const locale = preferences.app.locale;
      const languageMap: Record<string, string> = {
        'en-US': 'en',
        'vi-VN': 'vi',
      };
      config.headers['Accept-Language'] = languageMap[locale] ?? locale;
      return config;
    },
  });

  client.addResponseInterceptor({
    fulfilled: (response) => {
      if (response.config.responseReturn === 'raw') {
        return response;
      }

      return response.data;
    },
    rejected: (error: unknown) => {
      if (!isAxiosError(error)) {
        return Promise.reject(error);
      }

      const response = (error as AxiosError<unknown>).response;

      if (response === undefined) {
        return Promise.reject(error);
      }

      const contentType = getResponseContentType(response);
      let problem: ApiProblemError | null = null;

      if (contentType.includes('application/problem+json')) {
        problem = parseProblemPayload(response.data);
      } else if (response.status === 401) {
        problem = createHttpStatusProblem(response.status);
      }

      if (problem instanceof ApiProblemError) {
        if (problem.problem.status === 401) {
          redirectUnauthenticated(error.config);
        }

        // oxlint-disable-next-line no-throw-literal -- ApiProblemError extends Error.
        throw problem;
      }

      throw error;
    },
  });

  return client;
}

export const requestClient = createRequestClient(apiBaseURL, {
  responseReturn: 'body',
});

export const baseRequestClient = createRequestClient(apiBaseURL, {
  responseReturn: 'body',
});

if (import.meta.env.VITE_MOCK_API === 'true') {
  requestClient.instance.defaults.adapter = mockAdapter;
  baseRequestClient.instance.defaults.adapter = mockAdapter;
}

export async function ensureCsrfCookie(): Promise<void> {
  await requestClient.get(
    '/sanctum/csrf-cookie',
    skipAuthRedirectConfig({ baseURL: csrfBaseURL }),
  );
}

export {
  ApiProblemError,
  parseProblemPayload,
  ValidationProblemError,
} from './problem';
