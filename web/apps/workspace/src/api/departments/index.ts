import type {
  CreateDepartmentPayload,
  Department,
  DepartmentIndexQuery,
  DepartmentWithRelations,
  PaginatedList,
  UpdateDepartmentPayload,
  User,
} from '#/api/contracts';
import type { ResourcePaginationQuery } from '#/api/resource';

import {
  createDepartmentPayloadSchema,
  departmentIndexQuerySchema,
  departmentSchema,
  departmentWithRelationsSchema,
  paginationQuerySchema,
  updateDepartmentPayloadSchema,
  userSchema,
} from '#/api/contracts';
import { requestClient } from '#/api/request';
import {
  createCollectionResourceApi,
  createResourceApi,
  parsePaginatedResponse,
} from '#/api/resource';

const baseDepartmentsResource = createResourceApi<
  DepartmentWithRelations,
  DepartmentIndexQuery,
  CreateDepartmentPayload,
  UpdateDepartmentPayload,
  Department,
  DepartmentWithRelations
>('/departments', {
  createPayloadSchema: createDepartmentPayloadSchema,
  createResponseSchema: departmentSchema,
  detailResponseSchema: departmentWithRelationsSchema,
  indexQuerySchema: departmentIndexQuerySchema,
  rowSchema: departmentWithRelationsSchema,
  updatePayloadSchema: updateDepartmentPayloadSchema,
  updateResponseSchema: departmentWithRelationsSchema,
});

export const departmentsResource = {
  create: baseDepartmentsResource.create,
  delete: baseDepartmentsResource.delete,
  getAll: baseDepartmentsResource.getAll,
  getById: baseDepartmentsResource.getById,
  update: baseDepartmentsResource.update,
};

export const departmentOptionsResource =
  createCollectionResourceApi<Department>('/departments', departmentSchema);

export const departmentUsersResource = {
  getAll: async (
    departmentId: string,
    query: ResourcePaginationQuery,
  ): Promise<PaginatedList<User>> =>
    parsePaginatedResponse(
      userSchema,
      await requestClient.get(`/departments/${departmentId}/users`, {
        params: paginationQuerySchema.parse(query),
      }),
    ),
};
