import { describe, expect, it } from 'vitest';

import { createPositionIndexQuery } from './query';

describe('createPositionIndexQuery', () => {
  it('maps a position search filter to the API query', () => {
    expect(
      createPositionIndexQuery(
        {
          page: 2,
          per_page: 20,
        },
        {
          search: 'engineer',
        },
      ),
    ).toEqual({
      page: 2,
      per_page: 20,
      search: 'engineer',
    });
  });

  it('omits an empty search filter', () => {
    expect(
      createPositionIndexQuery(
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
