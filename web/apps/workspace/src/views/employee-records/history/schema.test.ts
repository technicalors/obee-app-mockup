import { describe, expect, it, vi } from 'vitest';

import {
  createEmployeeHistoryTableColumns,
  createEmployeeHistoryTableFilterSchema,
} from './schema';

describe('createEmployeeHistoryTableFilterSchema', () => {
  it('defines the search filter schema', () => {
    const filterSchema = createEmployeeHistoryTableFilterSchema();
    expect(filterSchema).toHaveLength(1);
    expect(filterSchema[0]).toMatchObject({
      component: 'Input',
      fieldName: 'search',
      label: 'page.employeeHistory.filters.search',
    });
  });
});

describe('createEmployeeHistoryTableColumns', () => {
  it('renders all required employee history table columns in order', () => {
    const columns = createEmployeeHistoryTableColumns({
      onAction: () => {},
    });

    if (columns === undefined) {
      throw new TypeError('Columns are required.');
    }

    expect(columns.map((column) => column.title)).toEqual([
      'page.employeeHistory.columns.sequence',
      'page.employeeHistory.columns.employeeCode',
      'page.employeeHistory.columns.fullName',
      'page.employeeHistory.columns.gender',
      'page.employeeHistory.columns.department',
      'page.employeeHistory.columns.position',
      'page.employeeHistory.columns.joinedAt',
      'page.employeeHistory.columns.startingDate',
      'page.employeeHistory.columns.actions',
    ]);
  });

  it('formats column values and handles null fallbacks correctly', () => {
    const columns = createEmployeeHistoryTableColumns({
      onAction: () => {},
    });

    if (columns === undefined) {
      throw new TypeError('Columns are required.');
    }

    const codeCol = columns[1];
    const genderCol = columns[3];
    const deptCol = columns[4];
    const posCol = columns[5];
    const joinedCol = columns[6];
    const startingCol = columns[7];

    if (
      typeof codeCol?.formatter !== 'function' ||
      typeof genderCol?.formatter !== 'function' ||
      typeof deptCol?.formatter !== 'function' ||
      typeof posCol?.formatter !== 'function' ||
      typeof joinedCol?.formatter !== 'function' ||
      typeof startingCol?.formatter !== 'function'
    ) {
      throw new TypeError('All data column formatters are required.');
    }

    // When values are present
    const rowWithData = {
      departments: [
        { id: 'd1', name: 'Kỹ thuật' },
        { id: 'd2', name: 'R&D' },
      ],
      name: 'Nguyen Van A',
      profile: {
        code: 'NV001',
        joined_at: '2023-01-15',
        position: { id: 'p1', name: 'Lập trình viên' },
        sex: 'male',
        starting_date: '2023-03-15',
      },
    };

    expect(codeCol.formatter({ row: rowWithData } as never)).toBe('NV001');
    expect(genderCol.formatter({ row: rowWithData } as never)).toBe(
      'page.users.gender.male',
    );
    expect(deptCol.formatter({ row: rowWithData } as never)).toBe(
      'Kỹ thuật, R&D',
    );
    expect(posCol.formatter({ row: rowWithData } as never)).toBe(
      'Lập trình viên',
    );
    expect(joinedCol.formatter({ row: rowWithData } as never)).toBe(
      '2023-01-15',
    );
    expect(startingCol.formatter({ row: rowWithData } as never)).toBe(
      '2023-03-15',
    );

    // Female gender
    expect(
      genderCol.formatter({
        row: {
          ...rowWithData,
          profile: { ...rowWithData.profile, sex: 'female' },
        },
      } as never),
    ).toBe('page.users.gender.female');

    // When values are null or empty
    const rowEmpty = {
      departments: [],
      name: 'Nguyen Van B',
      profile: null,
    };

    expect(codeCol.formatter({ row: rowEmpty } as never)).toBe(
      'common.notProvided',
    );
    expect(genderCol.formatter({ row: rowEmpty } as never)).toBe(
      'common.notProvided',
    );
    expect(deptCol.formatter({ row: rowEmpty } as never)).toBe(
      'common.notProvided',
    );
    expect(posCol.formatter({ row: rowEmpty } as never)).toBe(
      'common.notProvided',
    );
    expect(joinedCol.formatter({ row: rowEmpty } as never)).toBe(
      'common.notProvided',
    );
    expect(startingCol.formatter({ row: rowEmpty } as never)).toBe(
      'common.notProvided',
    );
  });

  it('triggers onAction when clicking detail, edit, and delete actions', () => {
    const onAction = vi.fn();
    const columns = createEmployeeHistoryTableColumns({
      onAction,
    });

    const actionsCol = columns?.find((col) => col.field === 'actions');

    const cellRender = actionsCol?.cellRender as {
      attrs?: { onClick?: (code: string, row: unknown) => void };
      options?: Array<{ code: string; label: string }>;
    };

    expect(cellRender?.options?.[0]).toMatchObject({
      code: 'detail',
      label: 'page.employeeHistory.actions.detail',
    });
    expect(cellRender?.options?.[1]).toMatchObject({
      code: 'edit',
      label: 'page.users.actions.edit',
    });
    expect(cellRender?.options?.[2]).toMatchObject({
      code: 'delete',
      label: 'page.users.actions.delete',
    });

    const mockRow = { id: 'user-1' };
    cellRender?.attrs?.onClick?.('detail', mockRow);
    expect(onAction).toHaveBeenCalledWith('detail', mockRow);

    cellRender?.attrs?.onClick?.('edit', mockRow);
    expect(onAction).toHaveBeenCalledWith('edit', mockRow);

    cellRender?.attrs?.onClick?.('delete', mockRow);
    expect(onAction).toHaveBeenCalledWith('delete', mockRow);
  });

  it('checks permissions for edit and delete actions when hasAccessByCodes is provided', () => {
    const hasAccessByCodes = vi.fn().mockImplementation((codes: string[]) => {
      return codes.includes('users.view');
    });

    const columns = createEmployeeHistoryTableColumns({
      hasAccessByCodes,
      onAction: () => {},
    });

    const actionsCol = columns?.find((col) => col.field === 'actions');
    const cellRender = actionsCol?.cellRender as {
      options?: Array<{ code: string; visible?: () => boolean }>;
    };

    const detailOption = cellRender?.options?.find(
      (opt) => opt.code === 'detail',
    );
    const editOption = cellRender?.options?.find((opt) => opt.code === 'edit');
    const deleteOption = cellRender?.options?.find(
      (opt) => opt.code === 'delete',
    );

    expect(detailOption?.visible?.()).toBe(true);
    expect(editOption?.visible?.()).toBe(false);
    expect(deleteOption?.visible?.()).toBe(false);
  });
});
