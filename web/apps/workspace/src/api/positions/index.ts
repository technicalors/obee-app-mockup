import type {
  CreatePositionPayload,
  Position,
  PositionIndexQuery,
  UpdatePositionPayload,
} from '#/api/contracts';

import {
  createPositionPayloadSchema,
  positionIndexQuerySchema,
  positionSchema,
  updatePositionPayloadSchema,
} from '#/api/contracts';
import { createCollectionResourceApi, createResourceApi } from '#/api/resource';

const basePositionsResource = createResourceApi<
  Position,
  PositionIndexQuery,
  CreatePositionPayload,
  UpdatePositionPayload
>('/positions', {
  createPayloadSchema: createPositionPayloadSchema,
  createResponseSchema: positionSchema,
  detailResponseSchema: positionSchema,
  indexQuerySchema: positionIndexQuerySchema,
  rowSchema: positionSchema,
  updatePayloadSchema: updatePositionPayloadSchema,
  updateResponseSchema: positionSchema,
});

export const positionsResource = {
  create: (payload: CreatePositionPayload): Promise<Position> =>
    basePositionsResource.create(payload),
  delete: basePositionsResource.delete,
  getAll: basePositionsResource.getAll,
  getById: (id: number | string): Promise<Position> =>
    basePositionsResource.getById(id),
  update: (
    id: number | string,
    payload: UpdatePositionPayload,
  ): Promise<Position> => basePositionsResource.update(id, payload),
};

export const positionOptionsResource = createCollectionResourceApi<Position>(
  '/positions',
  positionSchema,
);
