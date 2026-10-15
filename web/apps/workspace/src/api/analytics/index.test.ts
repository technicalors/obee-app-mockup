import { describe, expect, it, vi } from 'vitest';

import { getAnalyticsOverview } from './index';

const requestClientState = vi.hoisted(() => ({
  get: vi.fn(),
}));

vi.mock('#/api/request', () => ({
  requestClient: requestClientState,
}));

describe('getAnalyticsOverview', () => {
  it('parses the overview payload', async () => {
    requestClientState.get.mockResolvedValue({
      checked_in_count: 2,
      date: '2026-09-25',
      employee_count: 7,
      leave_request_count: 2,
      not_checked_in_count: 5,
    });

    await expect(getAnalyticsOverview()).resolves.toEqual({
      checked_in_count: 2,
      date: '2026-09-25',
      employee_count: 7,
      leave_request_count: 2,
      not_checked_in_count: 5,
    });
    expect(requestClientState.get).toHaveBeenCalledWith('/analytics/overview');
  });
});
