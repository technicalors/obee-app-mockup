import type { ResourcePaginationQuery, UserIndexQuery } from '#/api';

export interface UserTableFilters {
  with_inactive?: boolean;
  role_names?: string[];
  search?: string;
}

export function createUserIndexQuery(
  pagination: ResourcePaginationQuery,
  filters: UserTableFilters,
): UserIndexQuery {
  const query: UserIndexQuery = { ...pagination };

  if (filters.search !== undefined && filters.search !== '') {
    query.search = filters.search;
  }

  if (filters.with_inactive) {
    query.with_inactive = 1;
  }

  if (filters.role_names !== undefined && filters.role_names.length > 0) {
    query.role_names = filters.role_names;
  }

  return query;
}
