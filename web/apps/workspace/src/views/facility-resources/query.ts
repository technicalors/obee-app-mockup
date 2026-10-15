import type {
  FacilityResourceIndexQuery,
  FacilityResourceType,
  ResourcePaginationQuery,
} from '#/api';

export interface FacilityResourceTableFilters {
  code?: string;
  name?: string;
  search?: string;
  type?: FacilityResourceType;
}

export function createFacilityResourceIndexQuery(
  pagination: ResourcePaginationQuery,
  filters: FacilityResourceTableFilters,
): FacilityResourceIndexQuery {
  const query: FacilityResourceIndexQuery = { ...pagination };

  if (filters.search !== undefined && filters.search !== '') {
    query.search = filters.search;
  }

  if (filters.code !== undefined && filters.code !== '') {
    query.code = filters.code;
  }

  if (filters.name !== undefined && filters.name !== '') {
    query.name = filters.name;
  }

  if (filters.type !== undefined) {
    query.type = filters.type;
  }

  return query;
}
