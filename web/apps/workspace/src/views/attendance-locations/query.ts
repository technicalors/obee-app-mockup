import type {
  AttendanceLocationIndexQuery,
  AttendanceValidationMode,
} from '#/api';
import type { ResourcePaginationQuery } from '#/api/resource';

export type AttendanceLocationStatusFilter = 'active' | 'all' | 'deleted';

export interface AttendanceLocationTableFilters {
  search?: string;
  status?: AttendanceLocationStatusFilter;
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

  if (filters.status === 'all') {
    query.trashed = 'with';
  }

  if (filters.status === 'deleted') {
    query.trashed = 'only';
  }

  if (filters.validation_mode !== undefined) {
    query.validation_mode = filters.validation_mode;
  }

  return query;
}
