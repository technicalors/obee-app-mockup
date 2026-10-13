import type { ResourcePaginationQuery, UserIndexQuery } from '#/api';

export interface EmployeeHistoryTableFilters {
  search?: string;
}

export function createEmployeeHistoryIndexQuery(
  pagination: ResourcePaginationQuery,
  filters: EmployeeHistoryTableFilters,
): UserIndexQuery {
  const query: UserIndexQuery = { ...pagination };

  if (filters.search !== undefined && filters.search !== '') {
    query.search = filters.search;
  }

  return query;
}
