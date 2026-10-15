import type { VbenFormSchema } from '#/adapter/form';
import type { Organization } from '#/api';

import { ref } from 'vue';

import { beforeEach, describe, expect, it, vi } from 'vitest';

import { z } from '#/adapter/form';

import {
  buildOrganizationCreatePayload,
  buildOrganizationUpdatePayload,
  toOrganizationFormValues,
  useOrganizationFormSchema,
} from './form';
import { createOrganizationTableColumns } from './schema';

const localeMock = vi.hoisted(() => ({
  labels: {
    en: new Map<string, string>([
      ['organizations.fields.name', 'Name'],
      ['organizations.fields.type', 'Type'],
      ['organizations.types.company', 'Company'],
      ['organizations.types.department', 'Department'],
      ['organizations.types.division', 'Division'],
      ['organizations.types.team', 'Team'],
      ['organizations.types.unit', 'Unit'],
    ]),
    vi: new Map<string, string>([
      ['organizations.fields.name', 'Tên'],
      ['organizations.fields.type', 'Loại'],
      ['organizations.types.company', 'Công ty'],
      ['organizations.types.department', 'Phòng ban'],
      ['organizations.types.division', 'Bộ phận'],
      ['organizations.types.team', 'Nhóm'],
      ['organizations.types.unit', 'Tổ'],
    ]),
  },
  locale: { value: 'vi' } as { value: string },
}));

vi.mock('#/api', () => ({
  organizationsResource: {
    getAllRows: vi.fn(),
  },
}));

vi.mock('#/locales', () => ({
  $t: (key: string) =>
    localeMock.labels[localeMock.locale.value as 'en' | 'vi'].get(key) ?? key,
}));

function createOrganization(
  overrides: Partial<Organization> = {},
): Organization {
  return {
    created_at: '2026-06-11T00:00:00.000000Z',
    id: 'organization-1',
    name: 'Operations',
    parent_id: null,
    tax_identification_number: 'AB-123',
    type: 'Công ty',
    updated_at: '2026-06-11T00:00:00.000000Z',
    ...overrides,
  };
}

function getField(schema: VbenFormSchema[], fieldName: string): VbenFormSchema {
  const field = schema.find((item) => item.fieldName === fieldName);
  if (field === undefined) {
    throw new Error(`Missing organization form field: ${fieldName}`);
  }
  return field;
}

async function getDependentRule(
  field: VbenFormSchema,
  values: Record<string, unknown>,
) {
  const rules = field.dependencies?.rules;
  if (typeof rules !== 'function') {
    throw new TypeError(`Missing dependent rules for ${field.fieldName}.`);
  }

  const rule = await rules(values, {} as never, {} as never);
  if (
    rule === null ||
    rule === undefined ||
    typeof rule === 'string' ||
    !('safeParse' in rule)
  ) {
    throw new TypeError(`Invalid dependent rules for ${field.fieldName}.`);
  }

  return rule as z.ZodTypeAny;
}

describe('organization form values', () => {
  it('maps nullable tax IDs and the single type value directly from the contract', () => {
    expect(
      toOrganizationFormValues(
        createOrganization({
          parent_id: 'parent-1',
          tax_identification_number: null,
          type: 'Phòng ban',
        }),
      ),
    ).toEqual({
      name: 'Operations',
      parent_id: 'parent-1',
      tax_identification_number: null,
      type: 'Phòng ban',
    });
  });
});

describe('organization payload builders', () => {
  it('strips section markers and preserves a root tax ID as a nullable string', () => {
    expect(
      buildOrganizationCreatePayload({
        __section_organization: true,
        name: 'Operations',
        parent_id: null,
        tax_identification_number: 'AB-123',
        type: 'Công ty',
      }),
    ).toEqual({
      name: 'Operations',
      parent_id: null,
      tax_identification_number: 'AB-123',
      type: 'Công ty',
    });
  });

  it('requires tax clearing when demoting a root organization', () => {
    expect(() =>
      buildOrganizationUpdatePayload({
        name: 'Operations',
        parent_id: 'parent-1',
        tax_identification_number: 'AB-123',
        type: 'Phòng ban',
      }),
    ).toThrow(
      'Tax identification numbers are only allowed on root organizations.',
    );

    expect(
      buildOrganizationUpdatePayload({
        name: 'Operations',
        parent_id: 'parent-1',
        tax_identification_number: null,
        type: 'Phòng ban',
      }),
    ).toEqual({
      name: 'Operations',
      parent_id: 'parent-1',
      tax_identification_number: null,
      type: 'Phòng ban',
    });
  });

  it('rejects a type that does not match the selected parent', () => {
    expect(() =>
      buildOrganizationCreatePayload({
        name: 'Invalid root',
        parent_id: null,
        tax_identification_number: null,
        type: 'Phòng ban',
      }),
    ).toThrow('Organization type does not match its parent.');
  });
});

describe('organization form schema', () => {
  let formSchema: ReturnType<typeof useOrganizationFormSchema>;

  beforeEach(() => {
    localeMock.locale = ref('vi');
    formSchema = useOrganizationFormSchema();
  });

  it('starts the create form with its fields instead of a section heading', () => {
    expect(
      formSchema.createFormSchema.value.map((field) => field.fieldName),
    ).toEqual(['name', 'type', 'parent_id', 'tax_identification_number']);
  });

  it('keeps all five organization types selectable, including company', () => {
    const typeField = getField(formSchema.createFormSchema.value, 'type');
    expect(typeField.componentProps).toMatchObject({
      dropdownStyle: { zIndex: 2200 },
    });
    expect(typeField.componentProps).toMatchObject({
      options: [
        {
          label: 'Công ty',
          value: 'Công ty',
        },
        { label: 'Phòng ban', value: 'Phòng ban' },
        { label: 'Bộ phận', value: 'Bộ phận' },
        { label: 'Nhóm', value: 'Nhóm' },
        { label: 'Tổ', value: 'Tổ' },
      ],
    });
  });

  it('updates field and type labels when the locale changes without changing values', () => {
    const values = toOrganizationFormValues(
      createOrganization({ parent_id: 'parent-1', type: 'Phòng ban' }),
    );

    expect(getField(formSchema.editFormSchema.value, 'name').label).toBe('Tên');
    expect(getField(formSchema.editFormSchema.value, 'type').label).toBe(
      'Loại',
    );
    expect(
      getField(formSchema.editFormSchema.value, 'type').componentProps,
    ).toMatchObject({
      options: [
        { label: 'Công ty', value: 'Công ty' },
        { label: 'Phòng ban', value: 'Phòng ban' },
        { label: 'Bộ phận', value: 'Bộ phận' },
        { label: 'Nhóm', value: 'Nhóm' },
        { label: 'Tổ', value: 'Tổ' },
      ],
    });

    localeMock.locale.value = 'en';

    expect(getField(formSchema.editFormSchema.value, 'name').label).toBe(
      'Name',
    );
    expect(getField(formSchema.editFormSchema.value, 'type').label).toBe(
      'Type',
    );
    expect(
      getField(formSchema.editFormSchema.value, 'type').componentProps,
    ).toMatchObject({
      options: [
        { label: 'Company', value: 'Công ty' },
        { label: 'Department', value: 'Phòng ban' },
        { label: 'Division', value: 'Bộ phận' },
        { label: 'Team', value: 'Nhóm' },
        { label: 'Unit', value: 'Tổ' },
      ],
    });
    expect(values.type).toBe('Phòng ban');
  });

  it('validates parent/type matches without changing either value', async () => {
    const typeField = getField(formSchema.editFormSchema.value, 'type');
    const rootRule = await getDependentRule(typeField, { parent_id: null });
    const clearedParentRule = await getDependentRule(typeField, {
      parent_id: undefined,
    });
    const childRule = await getDependentRule(typeField, {
      parent_id: 'parent-1',
    });

    expect(rootRule.safeParse('Công ty').success).toBe(true);
    expect(rootRule.safeParse('Phòng ban').success).toBe(false);
    expect(clearedParentRule.safeParse('Công ty').success).toBe(true);
    expect(childRule.safeParse('Phòng ban').success).toBe(true);
    expect(childRule.safeParse('Công ty').success).toBe(false);
  });

  it('disables the parent selector for company in create and edit forms', async () => {
    for (const schema of [
      formSchema.createFormSchema.value,
      formSchema.editFormSchema.value,
    ]) {
      const parentField = getField(schema, 'parent_id');
      const disabled = parentField.dependencies?.disabled;
      if (typeof disabled !== 'function') {
        throw new TypeError('Organization parent dependency is missing.');
      }

      expect(parentField.dependencies?.triggerFields).toEqual(['type']);
      expect(
        await disabled({ type: 'Công ty' }, {} as never, {} as never),
      ).toBe(true);
      for (const type of ['Phòng ban', 'Bộ phận', 'Nhóm', 'Tổ']) {
        expect(await disabled({ type }, {} as never, {} as never)).toBe(false);
      }
    }
  });

  it('allows up to 14 arbitrary tax ID characters only for root organizations', async () => {
    const taxField = getField(
      formSchema.createFormSchema.value,
      'tax_identification_number',
    );
    const rootRule = await getDependentRule(taxField, { type: 'Công ty' });
    const childRule = await getDependentRule(taxField, { type: 'Phòng ban' });

    expect(rootRule.safeParse(null).success).toBe(true);
    expect(rootRule.safeParse(undefined).success).toBe(true);
    expect(rootRule.isOptional()).toBe(true);
    expect(rootRule.safeParse('AB-123').success).toBe(true);
    expect(rootRule.safeParse('A'.repeat(14)).success).toBe(true);
    expect(rootRule.safeParse('A'.repeat(15)).success).toBe(false);
    expect(childRule.safeParse(null).success).toBe(true);
    expect(childRule.safeParse('AB-123').success).toBe(false);
  });

  it('shows the optional tax input only for company and formats cleared fields as null', async () => {
    const taxField = getField(
      formSchema.createFormSchema.value,
      'tax_identification_number',
    );
    const parentField = getField(
      formSchema.createFormSchema.value,
      'parent_id',
    );
    const showTax = taxField.dependencies?.show;
    if (
      typeof showTax !== 'function' ||
      taxField.valueFormat === undefined ||
      parentField.valueFormat === undefined
    ) {
      throw new TypeError(
        'Organization nullable input configuration is missing.',
      );
    }

    expect(await showTax({ type: 'Công ty' }, {} as never, {} as never)).toBe(
      true,
    );
    for (const type of ['Phòng ban', 'Bộ phận', 'Nhóm', 'Tổ']) {
      expect(await showTax({ type }, {} as never, {} as never)).toBe(false);
    }
    expect(taxField.valueFormat('', vi.fn(), {})).toBeNull();
    expect(taxField.valueFormat(undefined, vi.fn(), {})).toBeNull();
    expect(taxField.valueFormat('AB-123', vi.fn(), {})).toBe('AB-123');
    expect(parentField.valueFormat(undefined, vi.fn(), {})).toBeNull();
    expect(parentField.valueFormat('parent-1', vi.fn(), {})).toBe('parent-1');
    if (
      typeof parentField.rules === 'string' ||
      parentField.rules === null ||
      parentField.rules === undefined
    ) {
      throw new TypeError('Organization parent validation is missing.');
    }
    expect(parentField.rules.safeParse(null).success).toBe(true);
    expect(parentField.rules.isOptional()).toBe(true);
  });

  it('does not expose a tax identification number column in the organization list', () => {
    const columns = createOrganizationTableColumns({
      hasAccessByCodes: () => true,
      onAction: vi.fn(),
      parentOrganizationName: () => 'Parent',
    });
    expect(columns?.map((column) => column.field)).not.toContain(
      'tax_identification_number',
    );
  });
});
