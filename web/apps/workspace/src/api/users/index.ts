import type {
  CreateUserPayload,
  ResetUserPasswordPayload,
  UpdateUserPayload,
  User,
  UserIndexQuery,
  UserTreeSelectionUser,
} from '#/api/contracts';

import { z } from '@vben/common-ui';

import {
  createUserPayloadSchema,
  resetUserPasswordPayloadSchema,
  trashedFilterSchema,
  updateUserPayloadSchema,
  userIndexQuerySchema,
  userSchema,
  userTreeSelectionUserSchema,
} from '#/api/contracts';
import { requestClient } from '#/api/request';
import { createCollectionResourceApi, createResourceApi } from '#/api/resource';

const baseUsersResource = createResourceApi<
  User,
  UserIndexQuery,
  CreateUserPayload,
  UpdateUserPayload
>('/users', {
  createPayloadSchema: createUserPayloadSchema,
  createResponseSchema: userSchema,
  detailResponseSchema: userSchema,
  indexQuerySchema: userIndexQuerySchema,
  rowSchema: userSchema,
  updatePayloadSchema: updateUserPayloadSchema,
  updateResponseSchema: userSchema,
});

const userTreeQuerySchema = z.object({
  organization_id: z.string().uuid().optional(),
  root_organization_id: z.string().uuid().optional(),
  permission_name: z.string().optional(),
  trashed: trashedFilterSchema.optional(),
});
type UserTreeQuery = z.input<typeof userTreeQuerySchema>;

export const userTreeResource = createCollectionResourceApi<
  UserTreeSelectionUser,
  UserTreeQuery
>('/users/tree', userTreeSelectionUserSchema, userTreeQuerySchema);

export const usersResource = {
  create: (payload: CreateUserPayload): Promise<User> =>
    baseUsersResource.create(payload),
  delete: baseUsersResource.delete,
  getAll: baseUsersResource.getAll,
  getById: (id: number | string): Promise<User> =>
    baseUsersResource.getById(id),
  restore: async (id: number | string): Promise<void> => {
    await requestClient.post(`/users/${id}/restore`);
  },
  resetPassword: async (
    id: number | string,
    payload: ResetUserPasswordPayload,
  ): Promise<void> => {
    await requestClient.put(
      `/users/${id}/password`,
      resetUserPasswordPayloadSchema.parse(payload),
    );
  },
  updateAvatar: async (id: number | string, file: File): Promise<User> => {
    const formData = new FormData();
    formData.append('avatar', file);

    const response = await requestClient.post<unknown>(
      `/users/${id}/avatar`,
      formData,
      { headers: { 'Content-Type': 'multipart/form-data' } },
    );

    return userSchema.parse(response);
  },
  update: (id: number | string, payload: UpdateUserPayload): Promise<User> =>
    baseUsersResource.update(id, payload),
};
