import { describe, expect, it, vi } from 'vitest';

import { $t } from '#/locales';

import {
  buildFacilityResourceCreatePayload,
  buildFacilityResourceUpdatePayload,
  useFacilityResourceFormSchema,
} from './form';

describe('facility resource form', () => {
  it('builds strict create and update payloads', () => {
    const values = {
      code: 'EQ-001',
      ignored: 'ignored',
      name: 'Laptop',
      note: '',
      quantity: 4,
      type: 'equipment',
    };

    expect(buildFacilityResourceCreatePayload(values)).toEqual({
      code: 'EQ-001',
      name: 'Laptop',
      note: null,
      quantity: 4,
      type: 'equipment',
    });
    expect(buildFacilityResourceUpdatePayload(values)).toEqual({
      name: 'Laptop',
      note: null,
      quantity: 4,
      type: 'equipment',
    });
  });

  it('provides facility fields and makes the code read-only when editing', () => {
    const { createFormSchema, editFormSchema } =
      useFacilityResourceFormSchema();

    expect(createFormSchema.value.map((schema) => schema.fieldName)).toEqual([
      'code',
      'name',
      'type',
      'quantity',
      'note',
    ]);
    expect(editFormSchema.value.map((schema) => schema.fieldName)).toEqual([
      'code',
      'name',
      'type',
      'quantity',
      'note',
    ]);
    const code = editFormSchema.value.find(
      (schema) => schema.fieldName === 'code',
    );
    expect(code).toMatchObject({ componentProps: { disabled: true } });
    if (!code?.rules || typeof code.rules === 'string') {
      throw new TypeError('FacilityResource code rules must be a Zod schema');
    }
    expect(code.rules.safeParse('').success).toBe(false);
    const note = createFormSchema.value.find(
      (schema) => schema.fieldName === 'note',
    );
    expect(note).toMatchObject({
      componentProps: {
        class: 'h-[188px] resize-none overflow-y-auto',
        maxlength: 65_535,
      },
    });
    const noteRules = note?.rules;
    if (!noteRules || typeof noteRules === 'string') {
      throw new TypeError('FacilityResource note rules must be a Zod schema');
    }
    expect(noteRules.safeParse(undefined).success).toBe(true);
  });

  it('locks room quantity and resets it to one on a type change', () => {
    const { createFormSchema } = useFacilityResourceFormSchema();
    const quantity = createFormSchema.value.find(
      (schema) => schema.fieldName === 'quantity',
    );
    const dependencies = quantity?.dependencies;
    const setFieldValue = vi.fn();
    const isQuantityDisabled = dependencies?.disabled;

    if (typeof isQuantityDisabled !== 'function') {
      throw new TypeError('Quantity disabled dependency must be a function');
    }

    expect(isQuantityDisabled({ type: 'room' }, {} as never, {} as never)).toBe(
      true,
    );
    expect(
      isQuantityDisabled({ type: 'equipment' }, {} as never, {} as never),
    ).toBe(false);
    dependencies?.trigger?.(
      { quantity: 5, type: 'room' },
      {} as never,
      { setFieldValue } as never,
    );
    expect(setFieldValue).toHaveBeenCalledWith('quantity', 1, false);
  });

  it('localizes quantity validation errors', () => {
    const { createFormSchema } = useFacilityResourceFormSchema();
    const quantity = createFormSchema.value.find(
      (schema) => schema.fieldName === 'quantity',
    );
    const rules = quantity?.rules;

    if (!rules || typeof rules === 'string') {
      throw new TypeError(
        'FacilityResource quantity rules must be a Zod schema',
      );
    }

    expect(rules.safeParse(undefined).error?.issues[0]?.message).toBe(
      $t('facilityResource.validation.quantityPositive'),
    );
    expect(rules.safeParse(1.5).error?.issues[0]?.message).toBe(
      $t('facilityResource.validation.quantityPositive'),
    );
    expect(rules.safeParse(0).error?.issues[0]?.message).toBe(
      $t('facilityResource.validation.quantityPositive'),
    );
    expect(rules.safeParse(2_147_483_648).error?.issues[0]?.message).toBe(
      $t('facilityResource.validation.quantityMax'),
    );
  });
});
