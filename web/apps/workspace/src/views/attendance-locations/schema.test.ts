import { describe, expect, it } from 'vitest';

import { createAttendanceLocationIndexQuery } from './query';

describe('createAttendanceLocationIndexQuery', () => {
  it('maps supported attendance location filters to the index contract', () => {
    expect(
      createAttendanceLocationIndexQuery(
        {
          page: 2,
          per_page: 20,
        },
        {
          search: 'office',
          status: 'deleted',
          validation_mode: 'location',
        },
      ),
    ).toEqual({
      page: 2,
      per_page: 20,
      search: 'office',
      trashed: 'only',
      validation_mode: 'location',
    });
  });

  it('omits empty optional filters from the index contract', () => {
    expect(
      createAttendanceLocationIndexQuery(
        {
          page: 1,
          per_page: 10,
        },
        {
          search: '',
          status: 'active',
        },
      ),
    ).toEqual({
      page: 1,
      per_page: 10,
    });
  });

  it('includes deleted locations for the all status', () => {
    expect(
      createAttendanceLocationIndexQuery(
        { page: 1, per_page: 10 },
        { status: 'all' },
      ),
    ).toEqual({
      page: 1,
      per_page: 10,
      trashed: 'with',
    });
  });
});
