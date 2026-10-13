import type {
  AttendanceLocationIndexQuery,
  AttendanceValidationMode,
} from '#/api';
import type { ResourcePaginationQuery } from '#/api/resource';

export interface AttendanceLocationTableFilters {
  is_active?: boolean;
  search?: string;
  validation_mode?: AttendanceValidationMode;
}

export function createAttendanceLocationIndexQuery(
  pagination: ResourcePaginationQuery,
  filters: AttendanceLocationTableFilters,
): AttendanceLocationIndexQuery {
  const query: AttendanceLocationIndexQuery = {
    ...pagination,
  };

  if (filters.search !== undefined && filters.search !== '') {
    query.search = filters.search;
  }

  if (filters.is_active !== undefined) {
    query.is_active = filters.is_active;
  }

  if (filters.validation_mode !== undefined) {
    query.validation_mode = filters.validation_mode;
  }

  return query;
}
