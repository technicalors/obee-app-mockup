import { describe, expect, it } from 'vitest';

import {
  createDepartmentPayloadSchema,
  departmentIndexQuerySchema,
  departmentWithRelationsSchema,
  updateDepartmentPayloadSchema,
} from './department';

const company = {
  created_at: '2026-07-28T00:00:00.000000Z',
  id: 'company-1',
  name: 'Obee',
  tax_identification_number: '1234567890',
  updated_at: '2026-07-28T00:00:00.000000Z',
};

const parent = {
  company_id: 'company-1',
  created_at: '2026-07-28T00:00:00.000000Z',
  id: 'department-parent',
  name: 'Operations',
  parent_id: null,
  updated_at: '2026-07-28T00:00:00.000000Z',
};

describe('department contracts', () => {
  it('requires company on department list rows', () => {
    expect(() =>
      departmentWithRelationsSchema.parse({
        company_id: 'company-1',
        created_at: '2026-07-28T00:00:00.000000Z',
        id: 'department-1',
        name: 'Support',
        parent: null,
        parent_id: null,
        updated_at: '2026-07-28T00:00:00.000000Z',
      }),
    ).toThrow('Required');
  });

  it('allows null parent for root departments with company', () => {
    const parsed = departmentWithRelationsSchema.parse({
      company,
      company_id: 'company-1',
      created_at: '2026-07-28T00:00:00.000000Z',
      id: 'department-1',
      name: 'Operations',
      parent: null,
      parent_id: null,
      updated_at: '2026-07-28T00:00:00.000000Z',
    });

    expect(parsed.company).toEqual(company);
    expect(parsed.parent).toBeNull();
  });

  it('only accepts department fields in create and update payloads', () => {
    const payload = {
      company_id: 'company-1',
      name: 'Support',
      parent_id: 'department-parent',
    };

    expect(createDepartmentPayloadSchema.parse(payload)).toEqual(payload);
    expect(updateDepartmentPayloadSchema.parse(payload)).toEqual(payload);
    expect(
      createDepartmentPayloadSchema.parse({
        company_id: 'company-1',
        name: 'Support',
      }),
    ).toEqual({
      company_id: 'company-1',
      name: 'Support',
    });
    expect(() =>
      createDepartmentPayloadSchema.parse({ ...payload, status: 'active' }),
    ).toThrow('Unrecognized key');
  });

  it('accepts all department index filters with pagination', () => {
    expect(
      departmentIndexQuerySchema.parse({
        company_id: 'company-1',
        name: 'Support',
        page: 2,
        parent_id: 'department-parent',
        per_page: 20,
        search: 'support',
      }),
    ).toEqual({
      company_id: 'company-1',
      name: 'Support',
      page: 2,
      parent_id: 'department-parent',
      per_page: 20,
      search: 'support',
    });
  });

  it('rejects invalid department row data', () => {
    expect(() =>
      departmentWithRelationsSchema.parse({
        company,
        company_id: 'company-1',
        created_at: '2026-07-28T00:00:00.000000Z',
        id: 'department-1',
        name: 'Support',
        parent,
        parent_id: 'department-parent',
        updated_at: 1,
      }),
    ).toThrow('Expected string');
  });
});
