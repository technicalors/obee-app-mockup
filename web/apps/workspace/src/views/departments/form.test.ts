import type { DepartmentWithRelations } from '#/api';

import { describe, expect, it, vi } from 'vitest';

import {
  buildDepartmentCreatePayload,
  buildDepartmentUpdatePayload,
  toDepartmentFormValues,
  useDepartmentFormSchema,
} from './form';

vi.mock('#/api', () => ({
  companiesResource: {
    getAll: vi.fn(),
  },
  departmentOptionsResource: {
    getAll: vi.fn(),
  },
}));

const department: DepartmentWithRelations = {
  children: [],
  company: {
    created_at: '2026-07-28T00:00:00.000000Z',
    id: 'company-1',
    name: 'Obee',
    tax_identification_number: '1234567890',
    updated_at: '2026-07-28T00:00:00.000000Z',
  },
  company_id: 'company-1',
  created_at: '2026-07-28T00:00:00.000000Z',
  id: 'department-1',
  name: 'Support',
  parent: null,
  parent_id: null,
  updated_at: '2026-07-28T00:00:00.000000Z',
};

describe('department form', () => {
  it('maps editable values from the department contract', () => {
    expect(toDepartmentFormValues(department)).toEqual({
      company_id: 'company-1',
      name: 'Support',
      parent_id: null,
    });
  });

  it('strips section markers from create and update payloads', () => {
    const values = {
      '__section.department': undefined,
      company_id: 'company-1',
      name: 'Support',
      parent_id: null,
    };

    expect(buildDepartmentCreatePayload(values)).toEqual({
      company_id: 'company-1',
      name: 'Support',
      parent_id: null,
    });
    expect(buildDepartmentUpdatePayload(values)).toEqual({
      company_id: 'company-1',
      name: 'Support',
      parent_id: null,
    });
  });

  it('creates a root department without a parent value', () => {
    expect(
      buildDepartmentCreatePayload({
        company_id: 'company-1',
        name: 'Support',
      }),
    ).toEqual({
      company_id: 'company-1',
      name: 'Support',
    });
  });

  it('uses the same section and fields in create and edit forms', () => {
    const { createFormSchema, editFormSchema } = useDepartmentFormSchema();

    expect(createFormSchema.value.map((schema) => schema.fieldName)).toEqual([
      '__section.department',
      'name',
      'company_id',
      'parent_id',
    ]);
    expect(editFormSchema.value.map((schema) => schema.fieldName)).toEqual([
      '__section.department',
      'name',
      'company_id',
      'parent_id',
    ]);
  });
});
