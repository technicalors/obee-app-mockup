import { describe, expect, it } from 'vitest';

import { createFacilityResourceIndexQuery } from './query';

describe('createFacilityResourceIndexQuery', () => {
  it('includes only populated facility resource filters', () => {
    expect(
      createFacilityResourceIndexQuery(
        { page: 2, per_page: 20 },
        {
          code: 'EQ-',
          name: '',
          search: 'laptop',
          type: 'room',
        },
      ),
    ).toEqual({
      code: 'EQ-',
      page: 2,
      per_page: 20,
      search: 'laptop',
      type: 'room',
    });
  });

  it('omits an unset type filter', () => {
    expect(
      createFacilityResourceIndexQuery(
        { page: 1, per_page: 20 },
        { type: undefined },
      ),
    ).toEqual({ page: 1, per_page: 20 });
  });
});
