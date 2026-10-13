import { describe, expect, it } from 'vitest';

import {
  buildEquipmentCreatePayload,
  buildEquipmentUpdatePayload,
  useEquipmentFormSchema,
} from './form';

describe('equipment form', () => {
  it('builds strict create and update payloads', () => {
    const values = {
      code: 'EQ-001',
      ignored: 'ignored',
      name: 'Laptop',
    };

    expect(buildEquipmentCreatePayload(values)).toEqual({
      code: 'EQ-001',
      name: 'Laptop',
    });
    expect(buildEquipmentUpdatePayload(values)).toEqual({
      code: 'EQ-001',
      name: 'Laptop',
    });
  });

  it('provides the same fields for create and edit', () => {
    const { createFormSchema, editFormSchema } = useEquipmentFormSchema();

    expect(createFormSchema.value.map((schema) => schema.fieldName)).toEqual([
      '__section.equipment',
      'code',
      'name',
    ]);
    expect(editFormSchema.value.map((schema) => schema.fieldName)).toEqual([
      '__section.equipment',
      'code',
      'name',
    ]);
  });
});
