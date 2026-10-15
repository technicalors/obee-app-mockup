import type { Organization } from '#/api';

import { createApp, nextTick, ref } from 'vue';

import { expect, it, vi } from 'vitest';

import {
  createOrganizationTableColumns,
  createOrganizationTableFilterSchema,
} from './schema';

vi.mock('#/api', () => ({
  organizationsResource: { getAllRows: vi.fn() },
}));

vi.mock('#/locales', () => ({ $t: (key: string) => key }));

it('filters organization types with a clearable single select for the five supported types', () => {
  const typeFilter = createOrganizationTableFilterSchema().find(
    (field) => field.fieldName === 'type',
  );

  expect(typeFilter).toMatchObject({
    component: 'Select',
  });
  if (typeof typeFilter?.componentProps !== 'function') {
    throw new TypeError('Organization type filter props must remain reactive.');
  }
  expect(typeFilter.componentProps({}, {} as never)).toMatchObject({
    allowClear: true,
    options: [
      { label: 'organizations.types.company', value: 'Công ty' },
      { label: 'organizations.types.department', value: 'Phòng ban' },
      { label: 'organizations.types.division', value: 'Bộ phận' },
      { label: 'organizations.types.team', value: 'Nhóm' },
      { label: 'organizations.types.unit', value: 'Tổ' },
    ],
  });
});

it('updates the parent cell after its lookup finishes without reloading the row', async () => {
  const parentName = ref('Loading');
  const columns = createOrganizationTableColumns({
    hasAccessByCodes: () => true,
    onAction: vi.fn(),
    parentOrganizationName: () => parentName.value,
  });
  const parentColumn = columns?.find((column) => column.field === 'parent_id');
  const renderParent = parentColumn?.slots?.default;
  if (typeof renderParent !== 'function') {
    throw new TypeError('Organization parent cell slot is missing.');
  }
  const row: Organization = {
    created_at: '2026-10-02T00:00:00.000000Z',
    id: 'department-1',
    name: 'General Director',
    parent_id: 'company-1',
    tax_identification_number: null,
    type: 'Phòng ban',
    updated_at: '2026-10-02T00:00:00.000000Z',
  };
  const target = document.createElement('div');
  const app = createApp({ render: () => renderParent({ row } as never) });
  app.mount(target);

  try {
    expect(target.textContent).toBe('Loading');
    parentName.value = 'ORS';
    await nextTick();
    expect(target.textContent).toBe('ORS');
    expect(row.parent_id).toBe('company-1');
  } finally {
    app.unmount();
  }
});
