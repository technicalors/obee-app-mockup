import type { HttpMutationLogIndexQuery, ResourcePaginationQuery } from '#/api';

export interface HttpMutationLogFilters {
  action?: string;
  search?: string;
  from?: string;
  is_error?: 0 | 1;
  range?: '1d' | '1h' | '2m' | '5m' | '15m';
  requested_by?: string;
  response_status?: number;
  to?: string;
}

export function createHttpMutationLogIndexQuery(
  pagination: ResourcePaginationQuery,
  filters: HttpMutationLogFilters,
): HttpMutationLogIndexQuery {
  const query: HttpMutationLogIndexQuery = { ...pagination };

  if (filters.search) query.search = filters.search;
  if (filters.action) query.action = filters.action;
  if (filters.requested_by) query.requested_by = filters.requested_by;
  if (filters.response_status !== undefined) {
    query.response_status = filters.response_status;
  }
  if (filters.is_error !== undefined) query.is_error = filters.is_error;
  if (filters.from) query.from = filters.from;
  if (filters.to) query.to = filters.to;
  if (!filters.from && !filters.to && filters.range) {
    query.range = filters.range;
  }

  return query;
}
