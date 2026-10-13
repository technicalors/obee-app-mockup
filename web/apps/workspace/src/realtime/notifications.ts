import type { InboxNotification } from '#/api/contracts';

import { z } from '@vben/common-ui';

import Echo from 'laravel-echo';
import Pusher from 'pusher-js';

import { notificationSchema } from '#/api/contracts';
import { requestClient } from '#/api/request';

interface ReverbRuntimeConfig {
  VITE_GLOB_REVERB_APP_KEY?: unknown;
  VITE_GLOB_REVERB_HOST?: unknown;
  VITE_GLOB_REVERB_PORT?: unknown;
  VITE_GLOB_REVERB_SCHEME?: unknown;
}

interface ReverbConfig {
  appKey: string;
  host: string;
  port: number;
  scheme: 'http' | 'https';
}

const broadcastAuthorizationSchema = z
  .object({
    auth: z.string().min(1),
  })
  .strict();

function readRuntimeString(value: unknown, name: string): string {
  if (typeof value !== 'string' || value === '') {
    throw new TypeError(`${name} must be a non-empty string.`);
  }

  return value;
}

function readRuntimePort(value: unknown): number {
  const port = Number(readRuntimeString(value, 'VITE_GLOB_REVERB_PORT'));

  if (!Number.isSafeInteger(port) || port < 1 || port > 65_535) {
    throw new TypeError('VITE_GLOB_REVERB_PORT must be a valid port number.');
  }

  return port;
}

function getReverbRuntimeConfig(): ReverbRuntimeConfig {
  const runtimeConfig = import.meta.env.PROD
    ? (window._VBEN_ADMIN_PRO_APP_CONF_ as ReverbRuntimeConfig)
    : import.meta.env;

  return {
    VITE_GLOB_REVERB_APP_KEY: runtimeConfig.VITE_GLOB_REVERB_APP_KEY,
    VITE_GLOB_REVERB_HOST: runtimeConfig.VITE_GLOB_REVERB_HOST,
    VITE_GLOB_REVERB_PORT: runtimeConfig.VITE_GLOB_REVERB_PORT,
    VITE_GLOB_REVERB_SCHEME: runtimeConfig.VITE_GLOB_REVERB_SCHEME,
  };
}

function getReverbConfig(): ReverbConfig | undefined {
  const runtimeConfig = getReverbRuntimeConfig();
  const hasReverbConfiguration = [
    runtimeConfig.VITE_GLOB_REVERB_APP_KEY,
    runtimeConfig.VITE_GLOB_REVERB_HOST,
    runtimeConfig.VITE_GLOB_REVERB_PORT,
    runtimeConfig.VITE_GLOB_REVERB_SCHEME,
  ].some((value) => value !== undefined);

  if (!hasReverbConfiguration) {
    return undefined;
  }

  const scheme = readRuntimeString(
    runtimeConfig.VITE_GLOB_REVERB_SCHEME,
    'VITE_GLOB_REVERB_SCHEME',
  );

  if (scheme !== 'http' && scheme !== 'https') {
    throw new TypeError('VITE_GLOB_REVERB_SCHEME must be http or https.');
  }

  return {
    appKey: readRuntimeString(
      runtimeConfig.VITE_GLOB_REVERB_APP_KEY,
      'VITE_GLOB_REVERB_APP_KEY',
    ),
    host: readRuntimeString(
      runtimeConfig.VITE_GLOB_REVERB_HOST,
      'VITE_GLOB_REVERB_HOST',
    ),
    port: readRuntimePort(runtimeConfig.VITE_GLOB_REVERB_PORT),
    scheme,
  };
}

export function connectNotificationRealtime(
  userId: string,
  onNotification: (notification: InboxNotification) => void,
  onSyncRequired: () => void,
): () => void {
  const config = getReverbConfig();

  // Reverb is optional rather than required, so environments without the service can still
  // load the notification inbox through the API without failing while opening a WebSocket.
  if (config === undefined) {
    return () => undefined;
  }

  const echo = new Echo<'reverb'>({
    Pusher,
    broadcaster: 'reverb',
    channelAuthorization: {
      customHandler: (params, callback) => {
        void requestClient
          .post<unknown>('/broadcasting/auth', {
            channel_name: params.channelName,
            socket_id: params.socketId,
          })
          .then((response) => broadcastAuthorizationSchema.parse(response))
          .then((response) => callback(null, response))
          .catch((error: unknown) => {
            callback(
              error instanceof Error
                ? error
                : new Error('Unable to authorize the notification channel.'),
              null,
            );
          });
      },
    },
    enabledTransports: config.scheme === 'https' ? ['wss'] : ['ws'],
    forceTLS: config.scheme === 'https',
    key: config.appKey,
    withoutInterceptors: true,
    wsHost: config.host,
    wsPort: config.port,
    wssPort: config.port,
  });

  let hasConnected = false;
  const stopListeningToConnection = echo.connector.onConnectionChange(
    (status) => {
      if (status === 'connected') {
        if (hasConnected) {
          onSyncRequired();
        }

        hasConnected = true;

        return;
      }

      if (hasConnected && (status === 'disconnected' || status === 'failed')) {
        onSyncRequired();
      }
    },
  );

  echo
    .private(`App.Models.User.${userId}`)
    .listen('.notification.changed', (payload: unknown) => {
      onNotification(notificationSchema.parse(payload));
    });

  return () => {
    stopListeningToConnection();
    echo.leave(`App.Models.User.${userId}`);
    echo.disconnect();
  };
}
