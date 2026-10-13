import { z } from '@vben/common-ui';

import { paginationQuerySchema } from './pagination';

export const positionSchema = z.object({
  created_at: z.string().datetime({ offset: true }).nullable(),
  description: z.string().nullable(),
  id: z.string(),
  name: z.string().min(1).max(255),
  updated_at: z.string().datetime({ offset: true }).nullable(),
});

export const createPositionPayloadSchema = positionSchema
  .pick({
    description: true,
    name: true,
  })
  .strict();

export const updatePositionPayloadSchema = createPositionPayloadSchema
  .partial()
  .strict();

export const positionIndexQuerySchema = paginationQuerySchema.extend({
  name: z.string().optional(),
  search: z.string().optional(),
});

export type Position = z.infer<typeof positionSchema>;
export type CreatePositionPayload = z.input<typeof createPositionPayloadSchema>;
export type UpdatePositionPayload = z.input<typeof updatePositionPayloadSchema>;
export type PositionIndexQuery = z.input<typeof positionIndexQuerySchema>;
