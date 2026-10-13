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
          is_active: false,
          search: 'office',
          validation_mode: 'location',
        },
      ),
    ).toEqual({
      is_active: false,
      page: 2,
      per_page: 20,
      search: 'office',
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
        },
      ),
    ).toEqual({
      page: 1,
      per_page: 10,
    });
  });
});
