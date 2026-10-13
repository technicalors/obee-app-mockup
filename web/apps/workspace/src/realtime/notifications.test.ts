// cspell:ignore unstub
import { afterEach, describe, expect, it, vi } from 'vitest';

import { connectNotificationRealtime } from './notifications';

const echo = vi.hoisted(() => {
  const disconnect = vi.fn();
  const leave = vi.fn();
  const listen = vi.fn();
  const onConnectionChange = vi.fn(() => vi.fn());
  const privateChannel = vi.fn((_channelName: string) => ({ listen }));
  const constructor = vi.fn();

  class EchoMock {
    readonly connector = { onConnectionChange };

    constructor(options: unknown) {
      constructor(options);
    }

    disconnect(): void {
      disconnect();
    }

    leave(channelName: string): void {
      leave(channelName);
    }

    private(channelName: string): { listen: typeof listen } {
      return privateChannel(channelName);
    }
  }

  return {
    constructor,
    disconnect,
    EchoMock,
    leave,
    listen,
    onConnectionChange,
    privateChannel,
  };
});

vi.mock('laravel-echo', () => ({ default: echo.EchoMock }));
vi.mock('pusher-js', () => ({ default: vi.fn() }));
vi.mock('#/api/request', () => ({
  requestClient: { post: vi.fn() },
}));

const reverbEnvironmentVariables = [
  'VITE_GLOB_REVERB_APP_KEY',
  'VITE_GLOB_REVERB_HOST',
  'VITE_GLOB_REVERB_PORT',
  'VITE_GLOB_REVERB_SCHEME',
] as const;

describe('notification realtime', () => {
  afterEach(() => {
    vi.clearAllMocks();
    vi.unstubAllEnvs();
  });

  it('skips Reverb when its runtime configuration is absent', () => {
    for (const name of reverbEnvironmentVariables) {
      vi.stubEnv(name, undefined);
    }

    const disconnect = connectNotificationRealtime('user-1', vi.fn(), vi.fn());

    expect(echo.constructor).not.toHaveBeenCalled();
    expect(disconnect()).toBeUndefined();
  });

  it('connects to Reverb when its runtime configuration is complete', () => {
    vi.stubEnv('VITE_GLOB_REVERB_APP_KEY', 'reverb-key');
    vi.stubEnv('VITE_GLOB_REVERB_HOST', 'obee.local');
    vi.stubEnv('VITE_GLOB_REVERB_PORT', '8080');
    vi.stubEnv('VITE_GLOB_REVERB_SCHEME', 'http');

    connectNotificationRealtime('user-1', vi.fn(), vi.fn());

    expect(echo.constructor).toHaveBeenCalledWith(
      expect.objectContaining({
        broadcaster: 'reverb',
        forceTLS: false,
        key: 'reverb-key',
        wsHost: 'obee.local',
        wsPort: 8080,
      }),
    );
    expect(echo.privateChannel).toHaveBeenCalledWith('App.Models.User.user-1');
  });

  it('rejects partial Reverb runtime configuration', () => {
    for (const name of reverbEnvironmentVariables) {
      vi.stubEnv(name, undefined);
    }
    vi.stubEnv('VITE_GLOB_REVERB_APP_KEY', 'reverb-key');
    vi.stubEnv('VITE_GLOB_REVERB_SCHEME', 'http');

    expect(() =>
      connectNotificationRealtime('user-1', vi.fn(), vi.fn()),
    ).toThrow(/VITE_GLOB_REVERB_HOST/);
    expect(echo.constructor).not.toHaveBeenCalled();
  });
});
