import { describe, expect, it } from 'vitest';

import { createEmployeeHistoryIndexQuery } from './query';

describe('createEmployeeHistoryIndexQuery', () => {
  it('maps an employee search filter to the API query', () => {
    expect(
      createEmployeeHistoryIndexQuery(
        {
          page: 2,
          per_page: 20,
        },
        {
          search: 'NV001',
        },
      ),
    ).toEqual({
      page: 2,
      per_page: 20,
      search: 'NV001',
    });
  });

  it('omits an empty search filter', () => {
    expect(
      createEmployeeHistoryIndexQuery(
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
