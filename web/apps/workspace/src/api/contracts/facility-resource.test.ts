import { describe, expect, it } from 'vitest';

import {
  createFacilityResourcePayloadSchema,
  facilityResourceIndexQuerySchema,
  facilityResourceSchema,
  updateFacilityResourcePayloadSchema,
} from './facility-resource';

describe('facilityResource contracts', () => {
  it('requires the complete facility response contract', () => {
    expect(
      facilityResourceSchema.parse({
        code: 'EQ-001',
        created_at: '2026-07-29T08:30:00.000Z',
        id: 'facility-resource-1',
        name: 'Laptop',
        note: null,
        quantity: 3,
        type: 'equipment',
        updated_at: '2026-07-29T08:30:00.000Z',
      }),
    ).toEqual({
      code: 'EQ-001',
      created_at: '2026-07-29T08:30:00.000Z',
      id: 'facility-resource-1',
      name: 'Laptop',
      note: null,
      quantity: 3,
      type: 'equipment',
      updated_at: '2026-07-29T08:30:00.000Z',
    });
  });

  it('rejects malformed datetime values on facilityResource responses', () => {
    expect(() =>
      facilityResourceSchema.parse({
        code: 'EQ-001',
        created_at: '2026-07-29',
        id: 'facility-resource-1',
        name: 'Laptop',
        note: null,
        quantity: 1,
        type: 'equipment',
        updated_at: '2026-07-29T08:30:00.000Z',
      }),
    ).toThrow('Invalid');
  });

  it('requires complete create payloads and enforces lengths', () => {
    expect(
      createFacilityResourcePayloadSchema.parse({
        code: 'EQ-001',
        name: 'Laptop',
        note: null,
        quantity: 1,
        type: 'equipment',
      }),
    ).toEqual({
      code: 'EQ-001',
      name: 'Laptop',
      note: null,
      quantity: 1,
      type: 'equipment',
    });

    expect(() =>
      createFacilityResourcePayloadSchema.parse({
        code: 'E'.repeat(37),
        name: 'Laptop',
        note: null,
        quantity: 1,
        type: 'equipment',
      }),
    ).toThrow('too_big');

    expect(() =>
      createFacilityResourcePayloadSchema.parse({
        code: 'EQ-001',
        ignored: true,
        name: 'Laptop',
        note: null,
        quantity: 1,
        type: 'equipment',
      }),
    ).toThrow('Unrecognized key');

    expect(
      createFacilityResourcePayloadSchema.parse({
        code: 'EQ-002',
        name: 'Facility without a note',
        quantity: 1,
        type: 'equipment',
      }),
    ).toEqual({
      code: 'EQ-002',
      name: 'Facility without a note',
      quantity: 1,
      type: 'equipment',
    });

    expect(() =>
      createFacilityResourcePayloadSchema.parse({
        code: 'EQ-001',
        name: 'Meeting room',
        note: null,
        quantity: 2,
        type: 'room',
      }),
    ).toThrow(/./);
  });

  it('requires update fields, rejects code, and validates quantity by type', () => {
    expect(
      updateFacilityResourcePayloadSchema.parse({
        name: 'Meeting room',
        note: 'Room 1',
        quantity: 1,
        type: 'room',
      }),
    ).toEqual({
      name: 'Meeting room',
      note: 'Room 1',
      quantity: 1,
      type: 'room',
    });

    expect(() =>
      updateFacilityResourcePayloadSchema.parse({
        code: 'EQ-001',
        name: 'Laptop',
        note: null,
        quantity: 1,
        type: 'equipment',
      }),
    ).toThrow('Unrecognized key');

    expect(
      updateFacilityResourcePayloadSchema.parse({
        name: 'Facility without a note',
        quantity: 1,
        type: 'equipment',
      }),
    ).toEqual({
      name: 'Facility without a note',
      quantity: 1,
      type: 'equipment',
    });

    expect(() =>
      updateFacilityResourcePayloadSchema.parse({
        name: 'Laptop',
        note: null,
        quantity: 0,
        type: 'equipment',
      }),
    ).toThrow(/./);

    expect(() =>
      updateFacilityResourcePayloadSchema.parse({
        name: 'Laptop',
        note: null,
        quantity: 1.5,
        type: 'equipment',
      }),
    ).toThrow(/./);

    expect(() =>
      updateFacilityResourcePayloadSchema.parse({
        name: 'Laptop',
        note: null,
        quantity: 2_147_483_648,
        type: 'equipment',
      }),
    ).toThrow(/./);
  });

  it('extends the pagination query base for facilityResource index queries', () => {
    expect(
      facilityResourceIndexQuerySchema.parse({
        code: 'EQ-',
        page: 2,
        per_page: 20,
        search: 'laptop',
        type: 'room',
      }),
    ).toEqual({
      code: 'EQ-',
      page: 2,
      per_page: 20,
      search: 'laptop',
      type: 'room',
    });

    expect(() =>
      facilityResourceIndexQuerySchema.parse({ type: 'invalid' }),
    ).toThrow(/./);
  });
});
