import { describe, expect, it } from 'vitest';

import {
  createEquipmentPayloadSchema,
  equipmentIndexQuerySchema,
  equipmentSchema,
  updateEquipmentPayloadSchema,
} from './equipment';

describe('equipment contracts', () => {
  it('requires code, name, and datetime timestamps on equipment responses', () => {
    expect(
      equipmentSchema.parse({
        code: 'EQ-001',
        created_at: '2026-07-29T08:30:00.000Z',
        id: 'equipment-1',
        name: 'Laptop',
        updated_at: '2026-07-29T08:30:00.000Z',
      }),
    ).toEqual({
      code: 'EQ-001',
      created_at: '2026-07-29T08:30:00.000Z',
      id: 'equipment-1',
      name: 'Laptop',
      updated_at: '2026-07-29T08:30:00.000Z',
    });
  });

  it('rejects malformed datetime values on equipment responses', () => {
    expect(() =>
      equipmentSchema.parse({
        code: 'EQ-001',
        created_at: '2026-07-29',
        id: 'equipment-1',
        name: 'Laptop',
        updated_at: '2026-07-29T08:30:00.000Z',
      }),
    ).toThrow('Invalid');
  });

  it('enforces code and name length on create payloads', () => {
    expect(
      createEquipmentPayloadSchema.parse({
        code: 'EQ-001',
        name: 'Laptop',
      }),
    ).toEqual({
      code: 'EQ-001',
      name: 'Laptop',
    });

    expect(() =>
      createEquipmentPayloadSchema.parse({
        code: 'E'.repeat(37),
        name: 'Laptop',
      }),
    ).toThrow('too_big');

    expect(() =>
      createEquipmentPayloadSchema.parse({
        code: 'EQ-001',
        ignored: true,
        name: 'Laptop',
      }),
    ).toThrow('Unrecognized key');
  });

  it('accepts partial update payloads and rejects extra keys', () => {
    expect(
      updateEquipmentPayloadSchema.parse({
        name: 'Laptop Lenovo',
      }),
    ).toEqual({
      name: 'Laptop Lenovo',
    });

    expect(() =>
      updateEquipmentPayloadSchema.parse({
        code: 'EQ-001',
        ignored: true,
      }),
    ).toThrow('Unrecognized key');
  });

  it('extends the pagination query base for equipment index queries', () => {
    expect(
      equipmentIndexQuerySchema.parse({
        code: 'EQ-',
        page: 2,
        per_page: 20,
        search: 'laptop',
      }),
    ).toEqual({
      code: 'EQ-',
      page: 2,
      per_page: 20,
      search: 'laptop',
    });
  });
});
