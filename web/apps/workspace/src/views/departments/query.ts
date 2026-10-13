import type { DepartmentIndexQuery, ResourcePaginationQuery } from '#/api';

export interface DepartmentTableFilters {
  company_id?: string;
  name?: string;
  parent_id?: string;
  search?: string;
}

export function createDepartmentIndexQuery(
  pagination: ResourcePaginationQuery,
  filters: DepartmentTableFilters,
): DepartmentIndexQuery {
  const query: DepartmentIndexQuery = { ...pagination };

  if (filters.search !== undefined && filters.search !== '') {
    query.search = filters.search;
  }

  if (filters.name !== undefined && filters.name !== '') {
    query.name = filters.name;
  }

  if (filters.company_id !== undefined && filters.company_id !== '') {
    query.company_id = filters.company_id;
  }

  if (filters.parent_id !== undefined && filters.parent_id !== '') {
    query.parent_id = filters.parent_id;
  }

  return query;
}
