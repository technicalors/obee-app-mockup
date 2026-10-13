export interface RequestBaseURLs {
  apiBaseURL: string;
  csrfBaseURL: string;
}

export function resolveRequestBaseURLs(
  configuredBackendURL: string,
  isDev: boolean,
): RequestBaseURLs {
  if (configuredBackendURL === '') {
    throw new Error('VITE_GLOB_BACKEND_URL is required.');
  }

  const backendURL = new URL(configuredBackendURL).toString();

  if (isDev) {
    return {
      apiBaseURL: '/api',
      csrfBaseURL: '',
    };
  }

  return {
    apiBaseURL: new URL('/api', backendURL).toString(),
    csrfBaseURL: backendURL,
  };
}
