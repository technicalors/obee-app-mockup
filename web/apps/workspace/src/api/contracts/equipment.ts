import { z } from '@vben/common-ui';

import { paginationQuerySchema } from './pagination';

export const equipmentSchema = z.object({
  code: z.string().min(1).max(36),
  created_at: z.string().datetime({ offset: true }),
  id: z.string(),
  name: z.string().min(1).max(255),
  updated_at: z.string().datetime({ offset: true }),
});

export const createEquipmentPayloadSchema = equipmentSchema
  .pick({
    code: true,
    name: true,
  })
  .strict();

export const updateEquipmentPayloadSchema = createEquipmentPayloadSchema
  .partial()
  .strict();

export const equipmentIndexQuerySchema = paginationQuerySchema.extend({
  code: z.string().optional(),
  name: z.string().optional(),
  search: z.string().optional(),
});

export type Equipment = z.infer<typeof equipmentSchema>;
export type CreateEquipmentPayload = z.input<
  typeof createEquipmentPayloadSchema
>;
export type UpdateEquipmentPayload = z.input<
  typeof updateEquipmentPayloadSchema
>;
export type EquipmentIndexQuery = z.input<typeof equipmentIndexQuerySchema>;
