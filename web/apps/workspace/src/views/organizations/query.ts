import type {
  OrganizationIndexQuery,
  OrganizationType,
  ResourcePaginationQuery,
} from '#/api';

export interface OrganizationTableFilters {
  parent_id?: string;
  search?: string;
  type?: '' | OrganizationType;
}

export function createOrganizationIndexQuery(
  pagination: ResourcePaginationQuery,
  filters: OrganizationTableFilters,
): OrganizationIndexQuery {
  const query: OrganizationIndexQuery = { ...pagination };

  if (filters.search !== undefined && filters.search !== '') {
    query.search = filters.search;
  }
  if (filters.type !== undefined && filters.type !== '') {
    query.type = filters.type;
  }
  if (filters.parent_id !== undefined && filters.parent_id !== '') {
    query.parent_id = filters.parent_id;
  }

  return query;
}
