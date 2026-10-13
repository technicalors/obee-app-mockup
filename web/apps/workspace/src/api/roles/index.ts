import type {
  CreateRolePayload,
  Role,
  UpdateRolePayload,
} from '#/api/contracts';

import {
  createRolePayloadSchema,
  roleWithPermissionsSchema,
  updateRolePayloadSchema,
} from '#/api/contracts';
import { requestClient } from '#/api/request';
import { createCollectionResourceApi } from '#/api/resource';

export const rolesResource = createCollectionResourceApi<Role>(
  '/roles',
  roleWithPermissionsSchema,
);

export const rolesManagementResource = {
  create: async (payload: CreateRolePayload): Promise<Role> =>
    roleWithPermissionsSchema.parse(
      await requestClient.post<Role>(
        '/roles',
        createRolePayloadSchema.parse(payload),
      ),
    ),
  update: async (id: string, payload: UpdateRolePayload): Promise<Role> =>
    roleWithPermissionsSchema.parse(
      await requestClient.put<Role>(
        `/roles/${id}`,
        updateRolePayloadSchema.parse(payload),
      ),
    ),
};
