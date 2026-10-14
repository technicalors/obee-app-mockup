import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';

import { defineConfig } from '@vben/vite-config';

import { loadEnv, type Plugin } from 'vite';

function serveMobileDev(): Plugin {
  return {
    name: 'serve-mobile-dev',
    configureServer(server) {
      server.middlewares.use((req, res, next) => {
        const url = (req.url || '').split('?')[0];
        if (url === '/mobile' || url.startsWith('/mobile/')) {
          let relativePath = url.replace(/^\/mobile\/?/, '');
          if (!relativePath || relativePath.endsWith('/')) {
            relativePath += 'index.html';
          }
          const filePath = path.resolve(process.cwd(), 'public/mobile', relativePath);
          if (fs.existsSync(filePath) && fs.statSync(filePath).isFile()) {
            const ext = path.extname(filePath);
            const mimeTypes: Record<string, string> = {
              '.css': 'text/css; charset=utf-8',
              '.html': 'text/html; charset=utf-8',
              '.ico': 'image/x-icon',
              '.js': 'application/javascript; charset=utf-8',
              '.json': 'application/json',
              '.mjs': 'application/javascript; charset=utf-8',
              '.otf': 'font/otf',
              '.png': 'image/png',
              '.svg': 'image/svg+xml',
              '.ttf': 'font/ttf',
              '.wasm': 'application/wasm',
            };
            res.setHeader('Content-Type', mimeTypes[ext] || 'application/octet-stream');
            fs.createReadStream(filePath).pipe(res);
            return;
          }
          const indexPath = path.resolve(process.cwd(), 'public/mobile/index.html');
          if (fs.existsSync(indexPath)) {
            res.setHeader('Content-Type', 'text/html; charset=utf-8');
            fs.createReadStream(indexPath).pipe(res);
            return;
          }
        }
        next();
      });
    },
  };
}

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
      plugins: [serveMobileDev()],
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
