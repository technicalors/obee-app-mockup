import type {
  CreateEquipmentPayload,
  Equipment,
  EquipmentIndexQuery,
  UpdateEquipmentPayload,
} from '#/api/contracts';

import {
  createEquipmentPayloadSchema,
  equipmentIndexQuerySchema,
  equipmentSchema,
  updateEquipmentPayloadSchema,
} from '#/api/contracts';
import { createResourceApi } from '#/api/resource';

const baseEquipmentsResource = createResourceApi<
  Equipment,
  EquipmentIndexQuery,
  CreateEquipmentPayload,
  UpdateEquipmentPayload,
  Equipment,
  Equipment
>('/equipments', {
  createPayloadSchema: createEquipmentPayloadSchema,
  createResponseSchema: equipmentSchema,
  detailResponseSchema: equipmentSchema,
  indexQuerySchema: equipmentIndexQuerySchema,
  rowSchema: equipmentSchema,
  updatePayloadSchema: updateEquipmentPayloadSchema,
  updateResponseSchema: equipmentSchema,
});

export const equipmentsResource = {
  create: baseEquipmentsResource.create,
  delete: baseEquipmentsResource.delete,
  getAll: baseEquipmentsResource.getAll,
  getById: baseEquipmentsResource.getById,
  update: baseEquipmentsResource.update,
};
