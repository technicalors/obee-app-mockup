import type {
  CreateFacilityResourcePayload,
  FacilityResource,
  FacilityResourceIndexQuery,
  UpdateFacilityResourcePayload,
} from '#/api/contracts';

import {
  createFacilityResourcePayloadSchema,
  facilityResourceIndexQuerySchema,
  facilityResourceSchema,
  updateFacilityResourcePayloadSchema,
} from '#/api/contracts';
import { createResourceApi } from '#/api/resource';

const baseFacilityResourcesResource = createResourceApi<
  FacilityResource,
  FacilityResourceIndexQuery,
  CreateFacilityResourcePayload,
  UpdateFacilityResourcePayload,
  FacilityResource,
  FacilityResource
>('/facility-resources', {
  createPayloadSchema: createFacilityResourcePayloadSchema,
  createResponseSchema: facilityResourceSchema,
  detailResponseSchema: facilityResourceSchema,
  indexQuerySchema: facilityResourceIndexQuerySchema,
  rowSchema: facilityResourceSchema,
  updatePayloadSchema: updateFacilityResourcePayloadSchema,
  updateResponseSchema: facilityResourceSchema,
});

export const facilityResourcesResource = {
  create: baseFacilityResourcesResource.create,
  delete: baseFacilityResourcesResource.delete,
  getAll: baseFacilityResourcesResource.getAll,
  getById: baseFacilityResourcesResource.getById,
  update: baseFacilityResourcesResource.update,
};
