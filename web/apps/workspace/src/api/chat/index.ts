import type { MatrixCredentials } from '#/api/contracts';

import { matrixCredentialsSchema } from '#/api/contracts';
import { requestClient } from '#/api/request';

export async function getMatrixCredentialsApi(
  deviceId?: string,
): Promise<MatrixCredentials> {
  const payload = deviceId === undefined ? {} : { device_id: deviceId };

  return matrixCredentialsSchema.parse(
    await requestClient.post<unknown>('/chat/matrix-credentials', payload),
  );
}
