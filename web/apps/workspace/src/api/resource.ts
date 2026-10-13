import type { z } from '@vben/common-ui';

import type { PaginatedList } from '#/api/contracts';

import { paginatedListSchema } from '#/api/contracts';
import { requestClient } from '#/api/request';

type ResourceId = number | string;
type RequestSchema<Input extends object> = z.ZodType<
  object,
  z.ZodTypeDef,
  Input
>;
type ResponseSchema<Output extends object> = z.ZodType<
  Output,
  z.ZodTypeDef,
  unknown
>;

export interface ResourcePaginationQuery {
  page: number;
  per_page: number;
}

export interface ResourceApi<
  Row extends object,
  IndexQuery extends ResourcePaginationQuery,
  CreatePayload extends object,
  UpdatePayload extends object,
  CreateResult extends object = Row,
  DetailResult extends object = Row,
  UpdateResult extends object = DetailResult,
  ActionPayload extends object = object,
  ActionResult extends object = UpdateResult,
> {
  create: (payload: CreatePayload) => Promise<CreateResult>;
  delete: (id: ResourceId) => Promise<void>;
  getAll: (params: IndexQuery) => Promise<PaginatedList<Row>>;
  getById: (id: ResourceId) => Promise<DetailResult>;
  update: (id: ResourceId, payload: UpdatePayload) => Promise<UpdateResult>;
  updateAction: (
    id: ResourceId,
    action: string,
    payload: ActionPayload,
  ) => Promise<ActionResult>;
}

export interface CollectionResourceApi<
  Row extends object,
  Query extends object,
> {
  getAll: (params?: Query) => Promise<Row[]>;
}

interface ResourceApiSchemas<
  Row extends object,
  IndexQuery extends ResourcePaginationQuery,
  CreatePayload extends object,
  UpdatePayload extends object,
  CreateResult extends object,
  DetailResult extends object,
  UpdateResult extends object,
  ActionPayload extends object,
  ActionResult extends object,
> {
  actionPayloadSchema?: RequestSchema<ActionPayload>;
  actionResponseSchema?: ResponseSchema<ActionResult>;
  createPayloadSchema?: RequestSchema<CreatePayload>;
  createResponseSchema?: ResponseSchema<CreateResult>;
  detailResponseSchema?: ResponseSchema<DetailResult>;
  indexQuerySchema?: RequestSchema<IndexQuery>;
  rowSchema: ResponseSchema<Row>;
  updatePayloadSchema?: RequestSchema<UpdatePayload>;
  updateResponseSchema?: ResponseSchema<UpdateResult>;
}

function parseInput<Input extends object>(
  schema: RequestSchema<Input> | undefined,
  payload: Input,
): object {
  if (schema === undefined) {
    return payload;
  }

  return schema.parse(payload);
}

function parseResponse<Output extends object>(
  schema: ResponseSchema<Output> | undefined,
  payload: unknown,
): Output {
  if (schema === undefined) {
    return payload as Output;
  }

  return schema.parse(payload);
}

export function createResourceApi<
  Row extends object,
  IndexQuery extends ResourcePaginationQuery,
  CreatePayload extends object,
  UpdatePayload extends object,
  CreateResult extends object = Row,
  DetailResult extends object = Row,
  UpdateResult extends object = DetailResult,
  ActionPayload extends object = object,
  ActionResult extends object = UpdateResult,
>(
  endpoint: string,
  schemas: ResourceApiSchemas<
    Row,
    IndexQuery,
    CreatePayload,
    UpdatePayload,
    CreateResult,
    DetailResult,
    UpdateResult,
    ActionPayload,
    ActionResult
  >,
): ResourceApi<
  Row,
  IndexQuery,
  CreatePayload,
  UpdatePayload,
  CreateResult,
  DetailResult,
  UpdateResult,
  ActionPayload,
  ActionResult
> {
  const {
    actionPayloadSchema,
    actionResponseSchema,
    createPayloadSchema,
    createResponseSchema,
    detailResponseSchema,
    indexQuerySchema,
    rowSchema,
    updatePayloadSchema,
    updateResponseSchema,
  } = schemas;

  return {
    create: async (payload) =>
      parseResponse(
        createResponseSchema,
        await requestClient.post<CreateResult>(
          endpoint,
          parseInput(createPayloadSchema, payload),
        ),
      ),
    delete: async (id) => {
      await requestClient.delete(`${endpoint}/${id}`);
    },
    getAll: async (params) =>
      parsePaginatedResponse(
        rowSchema,
        await requestClient.get<PaginatedList<Row>>(endpoint, {
          params: parseInput(indexQuerySchema, params),
        }),
      ),
    getById: async (id) =>
      parseResponse(
        detailResponseSchema,
        await requestClient.get<DetailResult>(`${endpoint}/${id}`),
      ),
    update: async (id, payload) =>
      parseResponse(
        updateResponseSchema,
        await requestClient.put<UpdateResult>(
          `${endpoint}/${id}`,
          parseInput(updatePayloadSchema, payload),
        ),
      ),
    updateAction: async (id, action, payload) =>
      parseResponse(
        actionResponseSchema,
        await requestClient.put<ActionResult>(
          `${endpoint}/${id}/${action}`,
          parseInput(actionPayloadSchema, payload),
        ),
      ),
  };
}

export function createCollectionResourceApi<
  Row extends object,
  Query extends object = Record<string, never>,
>(
  endpoint: string,
  rowSchema?: ResponseSchema<Row>,
  querySchema?: RequestSchema<Query>,
): CollectionResourceApi<Row, Query> {
  return {
    getAll: async (params) => {
      const response =
        params === undefined
          ? await requestClient.get<Row[]>(endpoint)
          : await requestClient.get<Row[]>(endpoint, {
              params: parseInput(querySchema, params),
            });

      if (rowSchema === undefined) {
        return response;
      }

      return rowSchema.array().parse(response);
    },
  };
}

export function parsePaginatedResponse<Row extends object>(
  rowSchema: ResponseSchema<Row>,
  payload: unknown,
): PaginatedList<Row> {
  return paginatedListSchema(rowSchema).parse(payload);
}
