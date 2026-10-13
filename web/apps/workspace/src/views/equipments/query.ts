import type { EquipmentIndexQuery, ResourcePaginationQuery } from '#/api';

export interface EquipmentTableFilters {
  code?: string;
  name?: string;
  search?: string;
}

export function createEquipmentIndexQuery(
  pagination: ResourcePaginationQuery,
  filters: EquipmentTableFilters,
): EquipmentIndexQuery {
  const query: EquipmentIndexQuery = { ...pagination };

  if (filters.search !== undefined && filters.search !== '') {
    query.search = filters.search;
  }

  if (filters.code !== undefined && filters.code !== '') {
    query.code = filters.code;
  }

  if (filters.name !== undefined && filters.name !== '') {
    query.name = filters.name;
  }

  return query;
}
