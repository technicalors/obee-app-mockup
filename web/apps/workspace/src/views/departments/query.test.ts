import { describe, expect, it } from 'vitest';

import { createDepartmentIndexQuery } from './query';

describe('createDepartmentIndexQuery', () => {
  it('maps department filters with pagination', () => {
    expect(
      createDepartmentIndexQuery(
        {
          page: 2,
          per_page: 20,
        },
        {
          company_id: 'company-1',
          name: 'Support',
          parent_id: 'department-parent',
          search: 'support',
        },
      ),
    ).toEqual({
      company_id: 'company-1',
      name: 'Support',
      page: 2,
      parent_id: 'department-parent',
      per_page: 20,
      search: 'support',
    });
  });

  it('omits empty department filters', () => {
    expect(
      createDepartmentIndexQuery(
        {
          page: 1,
          per_page: 10,
        },
        {
          company_id: '',
          name: '',
          parent_id: '',
          search: '',
        },
      ),
    ).toEqual({
      page: 1,
      per_page: 10,
    });
  });
});
