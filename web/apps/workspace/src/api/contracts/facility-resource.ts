import { z } from '@vben/common-ui';

import { paginationQuerySchema } from './pagination';

export const facilityResourceTypeSchema = z.enum(['room', 'equipment']);

const facilityResourceFieldsSchema = z.object({
  code: z.string().min(1).max(36),
  name: z.string().min(1).max(255),
  type: facilityResourceTypeSchema,
  quantity: z.number().int().min(1).max(2_147_483_647),
  note: z.string().min(1).max(65_535).nullable(),
});
const optionalFacilityResourceNoteSchema = z
  .string()
  .min(1)
  .max(65_535)
  .nullable()
  .optional();

export const facilityResourceSchema = facilityResourceFieldsSchema
  .extend({
    created_at: z.string().datetime({ offset: true }),
    id: z.string(),
    updated_at: z.string().datetime({ offset: true }),
  })
  .refine(({ type, quantity }) => type !== 'room' || quantity === 1, {
    path: ['quantity'],
  });

export const createFacilityResourcePayloadSchema = facilityResourceFieldsSchema
  .pick({
    code: true,
    name: true,
    type: true,
    quantity: true,
    note: true,
  })
  .extend({ note: optionalFacilityResourceNoteSchema })
  .strict()
  .refine(({ type, quantity }) => type !== 'room' || quantity === 1, {
    path: ['quantity'],
  });

export const updateFacilityResourcePayloadSchema = facilityResourceFieldsSchema
  .pick({
    name: true,
    type: true,
    quantity: true,
    note: true,
  })
  .extend({ note: optionalFacilityResourceNoteSchema })
  .strict()
  .refine(({ type, quantity }) => type !== 'room' || quantity === 1, {
    path: ['quantity'],
  });

export const facilityResourceIndexQuerySchema = paginationQuerySchema.extend({
  code: z.string().optional(),
  name: z.string().optional(),
  search: z.string().optional(),
  type: facilityResourceTypeSchema.optional(),
});

export type FacilityResource = z.infer<typeof facilityResourceSchema>;
export type FacilityResourceType = z.infer<typeof facilityResourceTypeSchema>;
export type CreateFacilityResourcePayload = z.input<
  typeof createFacilityResourcePayloadSchema
>;
export type UpdateFacilityResourcePayload = z.input<
  typeof updateFacilityResourcePayloadSchema
>;
export type FacilityResourceIndexQuery = z.input<
  typeof facilityResourceIndexQuerySchema
>;
