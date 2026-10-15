import type { MatrixCredentials } from '#/api/contracts';

import { IndexedDBDriver, StorageManager } from '@vben/utils';

import { matrixCredentialsSchema } from '#/api/contracts';

const matrixSessionStorage = new StorageManager({
  driver: new IndexedDBDriver({
    dbName: 'obee-matrix-session',
    storeName: 'credentials',
  }),
  prefix: 'v1',
});

function getSessionKey(obeeUserId: string): string {
  return `session:${obeeUserId}`;
}

export async function loadMatrixSession(
  obeeUserId: string,
): Promise<MatrixCredentials | null> {
  const stored = await matrixSessionStorage.getItem<unknown>(
    getSessionKey(obeeUserId),
  );

  return stored === null ? null : matrixCredentialsSchema.parse(stored);
}

export async function saveMatrixSession(
  obeeUserId: string,
  credentials: MatrixCredentials,
): Promise<void> {
  await matrixSessionStorage.setItem(getSessionKey(obeeUserId), credentials);
}
