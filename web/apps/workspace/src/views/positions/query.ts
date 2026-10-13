import type { PositionIndexQuery, ResourcePaginationQuery } from '#/api';

export interface PositionTableFilters {
  search?: string;
}

export function createPositionIndexQuery(
  pagination: ResourcePaginationQuery,
  filters: PositionTableFilters,
): PositionIndexQuery {
  const query: PositionIndexQuery = { ...pagination };

  if (filters.search !== undefined && filters.search !== '') {
    query.search = filters.search;
  }

  return query;
}
