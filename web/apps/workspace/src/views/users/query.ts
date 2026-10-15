import type { ResourcePaginationQuery, UserIndexQuery } from '#/api';

export type UserStatusFilter = 'active' | 'all' | 'deleted';

export interface UserTableFilters {
  role_names?: string[];
  search?: string;
  status?: UserStatusFilter;
}

export function createUserIndexQuery(
  pagination: ResourcePaginationQuery,
  filters: UserTableFilters,
): UserIndexQuery {
  const query: UserIndexQuery = { ...pagination };

  if (filters.search !== undefined && filters.search !== '') {
    query.search = filters.search;
  }

  if (filters.status === 'all') {
    query.trashed = 'with';
  }

  if (filters.status === 'deleted') {
    query.trashed = 'only';
  }

  if (filters.role_names !== undefined && filters.role_names.length > 0) {
    query.role_names = filters.role_names;
  }

  return query;
}
