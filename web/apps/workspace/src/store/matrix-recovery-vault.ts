import { IndexedDBDriver, StorageManager } from '@vben/utils';

export interface MatrixRecoveryKeyScope {
  deviceId: string;
  matrixUserId: string;
  obeeUserId: string;
}

interface StoredRecoveryKey {
  ciphertext: ArrayBuffer;
  deviceId: string;
  iv: ArrayBuffer;
  matrixUserId: string;
  obeeUserId: string;
  version: 1;
  wrappingKey: CryptoKey;
}

const RECOVERY_KEY_ALGORITHM = 'AES-GCM';
const RECOVERY_KEY_IV_LENGTH = 12;

const recoveryKeyStorage = new StorageManager({
  driver: new IndexedDBDriver({
    dbName: 'obee-matrix-recovery',
    storeName: 'keys',
  }),
  prefix: 'v1',
});

function getStorageKey(scope: MatrixRecoveryKeyScope): string {
  return [scope.obeeUserId, scope.matrixUserId, scope.deviceId]
    .map((value) => encodeURIComponent(value))
    .join(':');
}

function getSubtleCrypto(): SubtleCrypto {
  if (!globalThis.crypto?.subtle) {
    throw new Error('Web Crypto API is not available');
  }

  return globalThis.crypto.subtle;
}

function isStoredRecoveryKey(value: unknown): value is StoredRecoveryKey {
  if (!value || typeof value !== 'object') return false;

  const stored = value as Partial<StoredRecoveryKey>;
  return (
    stored.version === 1 &&
    typeof stored.deviceId === 'string' &&
    typeof stored.matrixUserId === 'string' &&
    typeof stored.obeeUserId === 'string' &&
    stored.ciphertext instanceof ArrayBuffer &&
    stored.iv instanceof ArrayBuffer &&
    typeof stored.wrappingKey === 'object'
  );
}

export async function saveMatrixRecoveryKey(
  scope: MatrixRecoveryKeyScope,
  encodedRecoveryKey: string,
): Promise<boolean> {
  try {
    const subtle = getSubtleCrypto();
    const wrappingKey = (await subtle.generateKey(
      { length: 256, name: RECOVERY_KEY_ALGORITHM },
      false,
      ['decrypt', 'encrypt'],
    )) as CryptoKey;
    const iv = globalThis.crypto.getRandomValues(
      new Uint8Array(RECOVERY_KEY_IV_LENGTH),
    );
    const ciphertext = await subtle.encrypt(
      { iv, name: RECOVERY_KEY_ALGORITHM },
      wrappingKey,
      new TextEncoder().encode(encodedRecoveryKey),
    );

    await recoveryKeyStorage.setItem(getStorageKey(scope), {
      ciphertext,
      deviceId: scope.deviceId,
      iv: iv.buffer.slice(iv.byteOffset, iv.byteOffset + iv.byteLength),
      matrixUserId: scope.matrixUserId,
      obeeUserId: scope.obeeUserId,
      version: 1,
      wrappingKey,
    } satisfies StoredRecoveryKey);
    return true;
  } catch {
    return false;
  }
}

export async function loadMatrixRecoveryKey(
  scope: MatrixRecoveryKeyScope,
): Promise<null | string> {
  try {
    const stored = await recoveryKeyStorage.getItem<unknown>(
      getStorageKey(scope),
    );
    if (
      !isStoredRecoveryKey(stored) ||
      stored.deviceId !== scope.deviceId ||
      stored.matrixUserId !== scope.matrixUserId ||
      stored.obeeUserId !== scope.obeeUserId
    ) {
      return null;
    }

    const plaintext = await getSubtleCrypto().decrypt(
      { iv: stored.iv, name: RECOVERY_KEY_ALGORITHM },
      stored.wrappingKey,
      stored.ciphertext,
    );
    return new TextDecoder().decode(plaintext);
  } catch {
    return null;
  }
}

export async function clearMatrixRecoveryKey(
  scope: MatrixRecoveryKeyScope,
): Promise<void> {
  try {
    await recoveryKeyStorage.removeItem(getStorageKey(scope));
  } catch {
    // Storage cleanup must not prevent logout or crypto reset.
  }
}
