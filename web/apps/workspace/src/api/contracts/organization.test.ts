import { describe, expect, it } from 'vitest';

import {
  createOrganizationPayloadSchema,
  organizationIndexQuerySchema,
  organizationSchema,
  updateOrganizationPayloadSchema,
} from './organization';

describe('organization contracts', () => {
  it('accepts custom response types and nullable tax IDs up to 14 characters', () => {
    expect(
      organizationSchema.parse({
        created_at: '2026-06-11T00:00:00.000000Z',
        id: 'organization-1',
        name: 'Operations',
        parent_id: null,
        tax_identification_number: 'AB-123',
        type: 'Công ty',
        updated_at: '2026-06-11T00:00:00.000000Z',
      }).tax_identification_number,
    ).toBe('AB-123');

    expect(() =>
      organizationSchema.parse({
        created_at: '2026-06-11T00:00:00.000000Z',
        id: 'organization-1',
        name: 'Operations',
        parent_id: null,
        tax_identification_number: 'A'.repeat(15),
        type: 'Công ty',
        updated_at: '2026-06-11T00:00:00.000000Z',
      }),
    ).toThrow('at most 14');

    expect(
      organizationSchema.parse({
        created_at: '2026-06-11T00:00:00.000000Z',
        id: 'organization-1',
        name: 'Operations',
        parent_id: null,
        tax_identification_number: null,
        type: 'Xưởng',
        updated_at: '2026-06-11T00:00:00.000000Z',
      }).type,
    ).toBe('Xưởng');
  });

  it('accepts root and child create payloads only with matching types', () => {
    expect(
      createOrganizationPayloadSchema.parse({
        name: 'Root',
        parent_id: null,
        tax_identification_number: 'AB-123',
        type: 'Công ty',
      }),
    ).toMatchObject({ type: 'Công ty' });

    expect(
      createOrganizationPayloadSchema.parse({
        name: 'Department',
        parent_id: 'organization-1',
        tax_identification_number: null,
        type: 'Phòng ban',
      }),
    ).toMatchObject({ type: 'Phòng ban' });

    expect(() =>
      createOrganizationPayloadSchema.parse({
        name: 'Invalid root',
        parent_id: null,
        tax_identification_number: null,
        type: 'Phòng ban',
      }),
    ).toThrow('Organization type does not match its parent.');

    expect(
      createOrganizationPayloadSchema.parse({
        name: 'Custom type',
        parent_id: 'organization-1',
        tax_identification_number: null,
        type: 'Xưởng',
      }).type,
    ).toBe('Xưởng');

    expect(() =>
      createOrganizationPayloadSchema.parse({
        name: 'Invalid child',
        parent_id: 'organization-1',
        tax_identification_number: 'AB-123',
        type: 'Nhóm',
      }),
    ).toThrow(
      'Tax identification numbers are only allowed on root organizations.',
    );
  });

  it('keeps update payloads partial while checking supplied parent and type', () => {
    expect(
      updateOrganizationPayloadSchema.parse({ parent_id: 'organization-1' }),
    ).toEqual({ parent_id: 'organization-1' });

    expect(() =>
      updateOrganizationPayloadSchema.parse({
        parent_id: 'organization-1',
        type: 'Công ty',
      }),
    ).toThrow('Organization type does not match its parent.');

    expect(() =>
      updateOrganizationPayloadSchema.parse({
        parent_id: 'organization-1',
        tax_identification_number: 'AB-123',
      }),
    ).toThrow(
      'Tax identification numbers are only allowed on root organizations.',
    );

    expect(() =>
      createOrganizationPayloadSchema.parse({
        extra: true,
        name: 'Root',
        parent_id: null,
        tax_identification_number: null,
        type: 'Công ty',
      }),
    ).toThrow('Unrecognized key');
  });

  it('accepts custom optional organization type filters', () => {
    expect(
      organizationIndexQuerySchema.parse({
        page: 2,
        parent_id: 'organization-parent',
        per_page: 20,
        search: 'operations',
      }),
    ).toEqual({
      page: 2,
      parent_id: 'organization-parent',
      per_page: 20,
      search: 'operations',
    });

    expect(
      organizationIndexQuerySchema.parse({
        page: 2,
        per_page: 20,
        type: 'Xưởng',
      }),
    ).toEqual({ page: 2, per_page: 20, type: 'Xưởng' });
  });
});
