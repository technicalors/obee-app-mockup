import type {
  CreateOrganizationPayload,
  Organization,
  OrganizationIndexQuery,
  PaginatedList,
  UpdateOrganizationPayload,
  User,
} from '#/api/contracts';
import type { ResourcePaginationQuery } from '#/api/resource';

import {
  createOrganizationPayloadSchema,
  organizationIndexQuerySchema,
  organizationSchema,
  paginationQuerySchema,
  updateOrganizationPayloadSchema,
  userSchema,
} from '#/api/contracts';
import { requestClient } from '#/api/request';
import { createResourceApi, parsePaginatedResponse } from '#/api/resource';

const baseOrganizationsResource = createResourceApi<
  Organization,
  OrganizationIndexQuery,
  CreateOrganizationPayload,
  UpdateOrganizationPayload
>('/organizations', {
  createPayloadSchema: createOrganizationPayloadSchema,
  createResponseSchema: organizationSchema,
  detailResponseSchema: organizationSchema,
  indexQuerySchema: organizationIndexQuerySchema,
  rowSchema: organizationSchema,
  updatePayloadSchema: updateOrganizationPayloadSchema,
  updateResponseSchema: organizationSchema,
});

export const organizationsResource = {
  create: baseOrganizationsResource.create,
  delete: baseOrganizationsResource.delete,
  getAll: baseOrganizationsResource.getAll,
  getById: baseOrganizationsResource.getById,
  getAllRows: async (): Promise<Organization[]> => {
    const organizations: Organization[] = [];
    let page = 1;

    while (true) {
      const result = await baseOrganizationsResource.getAll({
        page,
        per_page: 100,
      });
      organizations.push(...result.items);
      if (!result.pagination.has_next) {
        return organizations;
      }
      page += 1;
    }
  },
  update: baseOrganizationsResource.update,
};

export const organizationUsersResource = {
  getAll: async (
    organizationId: string,
    query: ResourcePaginationQuery,
  ): Promise<PaginatedList<User>> =>
    parsePaginatedResponse(
      userSchema,
      await requestClient.get(`/organizations/${organizationId}/users`, {
        params: paginationQuerySchema.parse(query),
      }),
    ),
};
