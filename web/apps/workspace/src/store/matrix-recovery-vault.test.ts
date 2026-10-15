import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  clearMatrixRecoveryKey,
  loadMatrixRecoveryKey,
  saveMatrixRecoveryKey,
} from './matrix-recovery-vault';

const storedValues = vi.hoisted(() => new Map<string, unknown>());

vi.mock('@vben/utils', () => ({
  IndexedDBDriver: class IndexedDBDriver {
    readonly driver = 'indexeddb';
  },
  StorageManager: class StorageManager {
    async getItem<T>(key: string): Promise<null | T> {
      return (storedValues.get(key) as T | undefined) ?? null;
    }

    async removeItem(key: string): Promise<void> {
      storedValues.delete(key);
    }

    async setItem(key: string, value: unknown): Promise<void> {
      storedValues.set(key, value);
    }
  },
}));

const scope = {
  deviceId: 'DEVICE_A',
  matrixUserId: '@admin:obee.local',
  obeeUserId: 'user-1',
};

describe('matrix recovery vault', () => {
  beforeEach(() => {
    storedValues.clear();
  });

  it('stores only encrypted recovery data and restores the original key', async () => {
    const encodedRecoveryKey = 'Es1234 recovery key';

    await expect(
      saveMatrixRecoveryKey(scope, encodedRecoveryKey),
    ).resolves.toBe(true);

    const stored = [...storedValues.values()][0] as Record<string, unknown>;
    expect(stored).not.toHaveProperty('encodedRecoveryKey');
    expect(stored).toHaveProperty('ciphertext');
    expect(stored).toHaveProperty('wrappingKey');
    await expect(loadMatrixRecoveryKey(scope)).resolves.toBe(
      encodedRecoveryKey,
    );
  });

  it('does not restore a key for another device and supports explicit cleanup', async () => {
    await saveMatrixRecoveryKey(scope, 'Es1234 recovery key');

    await expect(
      loadMatrixRecoveryKey({ ...scope, deviceId: 'DEVICE_B' }),
    ).resolves.toBeNull();

    await clearMatrixRecoveryKey(scope);
    await expect(loadMatrixRecoveryKey(scope)).resolves.toBeNull();
  });
});
