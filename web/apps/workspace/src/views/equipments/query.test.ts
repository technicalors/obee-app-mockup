import { describe, expect, it } from 'vitest';

import { createEquipmentIndexQuery } from './query';

describe('createEquipmentIndexQuery', () => {
  it('includes only populated equipment filters', () => {
    expect(
      createEquipmentIndexQuery(
        { page: 2, per_page: 20 },
        {
          code: 'EQ-',
          name: '',
          search: 'laptop',
        },
      ),
    ).toEqual({
      code: 'EQ-',
      page: 2,
      per_page: 20,
      search: 'laptop',
    });
  });
});
