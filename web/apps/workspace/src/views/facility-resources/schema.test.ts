import { describe, expect, it, vi } from 'vitest';

import {
  createFacilityResourceTableColumns,
  createFacilityResourceTableFilterSchema,
} from './schema';

vi.mock('#/locales', () => ({
  $t: (key: string) => key,
}));

describe('facility resource table schema', () => {
  it('offers a type filter in addition to free-text search', () => {
    expect(createFacilityResourceTableFilterSchema()).toEqual([
      expect.objectContaining({ fieldName: 'search' }),
      expect.objectContaining({
        component: 'Select',
        componentProps: {
          allowClear: true,
          options: [
            { label: 'facilityResource.types.room', value: 'room' },
            {
              label: 'facilityResource.types.equipment',
              value: 'equipment',
            },
          ],
        },
        fieldName: 'type',
        label: 'facilityResource.filters.type',
      }),
    ]);
  });

  it('includes all facility columns and formats both timestamps', () => {
    const columns = createFacilityResourceTableColumns({
      hasAccessByCodes: () => true,
      onAction: vi.fn(),
    });

    if (columns === undefined) {
      throw new Error('FacilityResource table columns are required');
    }

    expect(columns.map((column) => column.field)).toEqual([
      undefined,
      'code',
      'name',
      'type',
      'quantity',
      'note',
      'created_at',
      'updated_at',
      'actions',
    ]);
    expect(columns[0]).toMatchObject({
      title: 'facilityResource.columns.sequence',
      type: 'seq',
    });
    const typeColumn = columns.find((column) => column.field === 'type');
    expect(typeColumn).toMatchObject({ minWidth: 120 });
    const formatType = typeColumn?.formatter;
    if (typeof formatType !== 'function') {
      throw new TypeError('FacilityResource type formatter is required');
    }
    expect(
      formatType({ cellValue: 'room' } as Parameters<typeof formatType>[0]),
    ).toBe('facilityResource.types.room');
    expect(
      formatType({ cellValue: 'equipment' } as Parameters<
        typeof formatType
      >[0]),
    ).toBe('facilityResource.types.equipment');
    expect(columns.find((column) => column.field === 'quantity')).toMatchObject(
      {
        minWidth: 100,
      },
    );
    expect(columns.find((column) => column.field === 'note')).toMatchObject({
      minWidth: 180,
    });
    for (const field of ['created_at', 'updated_at']) {
      expect(columns.find((column) => column.field === field)).toMatchObject({
        field,
        formatter: 'formatDateTime',
        minWidth: 170,
      });
    }
  });
});
