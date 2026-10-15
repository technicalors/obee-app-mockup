import { describe, expect, it } from 'vitest';

import { createHttpMutationLogIndexQuery } from './query';
import { createHttpMutationLogTableColumns } from './schema';

describe('mutation log filters', () => {
  it('maps all supported filters and uses custom time instead of a preset', () => {
    expect(
      createHttpMutationLogIndexQuery(
        { page: 2, per_page: 20 },
        {
          action: 'UpdateUserAction',
          search: 'X6',
          from: '2026-05-15T08:00:00+07:00',
          is_error: 0,
          range: '1h',
          requested_by: '019e2444-4fa6-716d-a1fe-58fd4e9c602e',
          response_status: 422,
          to: '2026-05-15T09:00:00+07:00',
        },
      ),
    ).toMatchObject({
      action: 'UpdateUserAction',
      search: 'X6',
      from: '2026-05-15T08:00:00+07:00',
      is_error: 0,
      page: 2,
      per_page: 20,
      requested_by: '019e2444-4fa6-716d-a1fe-58fd4e9c602e',
      response_status: 422,
      to: '2026-05-15T09:00:00+07:00',
    });
    expect(
      createHttpMutationLogIndexQuery(
        { page: 1, per_page: 10 },
        { search: 'X6' },
      ).search,
    ).toBe('X6');
    const query = createHttpMutationLogIndexQuery(
      { page: 1, per_page: 10 },
      { from: '2026-05-15T08:00:00+07:00', range: '1h' },
    );
    expect(query.from).toBe('2026-05-15T08:00:00+07:00');
    expect(query.range).toBeUndefined();
  });

  it('omits blank optional filters without dropping the no-error choice', () => {
    expect(
      createHttpMutationLogIndexQuery(
        { page: 1, per_page: 10 },
        {
          action: '',
          search: '',
          from: '',
          is_error: 0,
          to: '',
        },
      ),
    ).toEqual({ page: 1, per_page: 10, is_error: 0 });
  });
});

describe('mutation log table actions', () => {
  it('only exposes detail when the view permission is present', () => {
    let allowed = false;
    const columns = createHttpMutationLogTableColumns(
      () => allowed,
      () => {},
    );
    if (!columns) throw new Error('Mutation log columns are missing');
    const actionColumn = columns.find((column) => column.field === 'actions');
    if (!actionColumn || !actionColumn.cellRender) {
      throw new Error('Mutation log detail action is missing');
    }
    const viewAction = actionColumn.cellRender.options?.[0];
    if (!viewAction || typeof viewAction.visible !== 'function') {
      throw new Error('Mutation log view visibility is missing');
    }
    expect(viewAction.visible()).toBe(false);
    allowed = true;
    expect(viewAction.visible()).toBe(true);
  });
});
