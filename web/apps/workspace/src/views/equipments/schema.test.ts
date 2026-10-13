import { describe, expect, it, vi } from 'vitest';

import { createEquipmentTableColumns } from './schema';

vi.mock('#/locales', () => ({
  $t: (key: string) => key,
}));

describe('equipment table schema', () => {
  it('includes a formatted updated-at column', () => {
    const columns = createEquipmentTableColumns({
      hasAccessByCodes: () => true,
      onAction: vi.fn(),
    });

    if (columns === undefined) {
      throw new Error('Equipment table columns are required');
    }

    const updatedAtColumn = columns.find(
      (column) => column.field === 'updated_at',
    );

    expect(updatedAtColumn).toMatchObject({
      field: 'updated_at',
      formatter: 'formatDateTime',
      minWidth: 170,
      title: 'page.equipment.columns.updatedAt',
    });
  });
});
