import type {
  HttpMutationLog,
  HttpMutationLogIndexQuery,
  HttpMutationLogSuggestionQuery,
  HttpMutationLogUserSuggestion,
  PaginatedList,
} from '#/api/contracts';

import { z } from '@vben/common-ui';

import {
  httpMutationLogIndexQuerySchema,
  httpMutationLogMarkdownSchema,
  httpMutationLogSchema,
  httpMutationLogSuggestionQuerySchema,
  httpMutationLogUserSuggestionSchema,
  paginatedListSchema,
} from '#/api/contracts';
import { requestClient } from '#/api/request';

export async function getHttpMutationLogsApi(
  query: HttpMutationLogIndexQuery,
): Promise<PaginatedList<HttpMutationLog>> {
  return paginatedListSchema(httpMutationLogSchema).parse(
    await requestClient.get<unknown>('/http-mutation-logs', {
      params: httpMutationLogIndexQuerySchema.parse(query),
    }),
  );
}

export async function getHttpMutationLogApi(
  id: string,
): Promise<HttpMutationLog> {
  return httpMutationLogSchema.parse(
    await requestClient.get<unknown>(`/http-mutation-logs/${id}`),
  );
}

export async function getHttpMutationLogMarkdownApi(
  id: string,
): Promise<string> {
  return httpMutationLogMarkdownSchema.parse(
    await requestClient.get<unknown>(`/http-mutation-logs/${id}/markdown`),
  ).markdown;
}

export async function suggestHttpMutationLogActionsApi(
  q: string,
): Promise<string[]> {
  const query: HttpMutationLogSuggestionQuery = {
    kind: 'action',
    limit: 10,
    ...(q === '' ? {} : { q }),
  };

  return z.array(z.string()).parse(
    await requestClient.get<unknown>('/http-mutation-logs/suggest', {
      params: httpMutationLogSuggestionQuerySchema.parse(query),
    }),
  );
}

export async function suggestHttpMutationLogUsersApi(
  q: string,
): Promise<HttpMutationLogUserSuggestion[]> {
  const query: HttpMutationLogSuggestionQuery = {
    kind: 'user',
    limit: 10,
    ...(q === '' ? {} : { q }),
  };

  return httpMutationLogUserSuggestionSchema.array().parse(
    await requestClient.get<unknown>('/http-mutation-logs/suggest', {
      params: httpMutationLogSuggestionQuerySchema.parse(query),
    }),
  );
}

export const httpMutationLogsResource = {
  getAll: getHttpMutationLogsApi,
};
