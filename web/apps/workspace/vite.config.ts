import process from 'node:process';

import { defineConfig } from '@vben/vite-config';

import { loadEnv } from 'vite';

function getProxyTarget(mode: string): string {
  const env = loadEnv(mode, process.cwd(), '');
  const backendURL = env.VITE_GLOB_BACKEND_URL;

  if (typeof backendURL !== 'string' || backendURL === '') {
    throw new Error('VITE_GLOB_BACKEND_URL is required for the dev proxy.');
  }

  return backendURL;
}

export default defineConfig(async ({ mode }) => {
  const proxyTarget = getProxyTarget(mode);
  const proxyOrigin = new URL(proxyTarget).origin;

  return {
    application: {},
    vite: {
      optimizeDeps: {
        include: ['dayjs/locale/en', 'dayjs/locale/vi'],
      },
      server: {
        proxy: {
          '/api': {
            changeOrigin: true,
            headers: {
              Origin: proxyOrigin,
              Referer: `${proxyOrigin}/`,
            },
            target: proxyTarget,
            ws: true,
          },
          '/sanctum': {
            changeOrigin: true,
            headers: {
              Origin: proxyOrigin,
              Referer: `${proxyOrigin}/`,
            },
            target: proxyTarget,
          },
        },
      },
    },
  };
}, 'application');
