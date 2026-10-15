import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  absenceListQuerySchema,
  approveAbsenceRequest,
  createAbsenceRequest,
  deleteAbsenceRequest,
  getAbsenceRequests,
  getLeaveBalance,
  getReviewerCapability,
  rejectAbsenceRequest,
  returnAbsenceRequest,
  submitAbsenceRequest,
  updateAbsenceRequest,
} from './index';

const requestClient = vi.hoisted(() => ({
  delete: vi.fn(),
  get: vi.fn(),
  post: vi.fn(),
  put: vi.fn(),
}));

vi.mock('#/api/request', () => ({ requestClient }));

const user = {
  avatar: null,
  organization_id: 'root-1',
  created_at: '2026-09-01T00:00:00Z',
  email: null,
  email_verified_at: null,
  id: 'user-1',
  deleted_at: null,
  name: 'Nguyen An',
  supabase_id: null,
  updated_at: '2026-09-01T00:00:00Z',
  username: 'nguyen.an',
};

const request = {
  address: 'Ha Noi',
  approval_note: null,
  approved_at: null,
  root_organization: {
    created_at: '2026-09-01T00:00:00Z',
    id: 'root-1',
    name: 'Acme',
    parent_id: null,
    tax_identification_number: null,
    type: 'Công ty',
    updated_at: '2026-09-01T00:00:00Z',
  },
  root_organization_id: 'root-1',
  created_at: '2026-09-29T00:00:00Z',
  duration_days: 1,
  end_at: '2026-10-05T17:00:00Z',
  id: 'request-1',
  leave_type: 'BUSINESS_TRIP',
  reason: 'Meet client',
  rejected_at: null,
  requested_by: 'user-1',
  requester: user,
  reviewer: { ...user, id: 'reviewer-1' },
  reviewer_id: 'reviewer-1',
  submitted_at: '2026-09-29T00:00:00Z',
  start_at: '2026-10-05T08:00:00Z',
  status: 'pending',
  updated_at: '2026-09-29T00:00:00Z',
  user,
  user_id: 'user-1',
};

describe('absence request API', () => {
  beforeEach(() => vi.clearAllMocks());

  it('loads the paginated request list', async () => {
    requestClient.get.mockResolvedValueOnce({
      items: [request],
      pagination: { has_next: false, page: 1, per_page: 20, total: 1 },
    });

    await expect(
      getAbsenceRequests({ page: 1, per_page: 20, status: 'pending' }),
    ).resolves.toMatchObject({ items: [{ id: 'request-1' }] });
    expect(requestClient.get).toHaveBeenNthCalledWith(1, '/absence-requests', {
      params: { page: 1, per_page: 20, status: 'pending' },
    });
  });

  it('sends multiple request filters as arrays and rejects CSV or array scalar statuses', async () => {
    const params = {
      page: 1,
      per_page: 20,
      statuses: ['rejected', 'returned'] as const,
      user_ids: ['user-1', 'user-2'],
      reviewer_ids: ['reviewer-1', 'reviewer-2'],
    };
    requestClient.get.mockResolvedValueOnce({
      items: [],
      pagination: { has_next: false, page: 1, per_page: 20, total: 0 },
    });
    await getAbsenceRequests({ ...params, statuses: [...params.statuses] });
    expect(requestClient.get).toHaveBeenCalledWith('/absence-requests', {
      params,
    });
    expect(
      absenceListQuerySchema.safeParse({ status: 'rejected,returned' }).success,
    ).toBe(false);
    expect(
      absenceListQuerySchema.safeParse({ status: ['pending'] }).success,
    ).toBe(false);
    expect(
      absenceListQuerySchema.safeParse({ statuses: ['unknown'] }).success,
    ).toBe(false);
  });

  it('loads leave balance and rejects malformed responses', async () => {
    requestClient.get.mockResolvedValueOnce({
      cycle_end: '2027-01-01',
      cycle_start: '2026-01-01',
      entitlement: 12,
      remaining: 11.5,
      used: 0.5,
    });
    await expect(getLeaveBalance('2026-10-05')).resolves.toMatchObject({
      remaining: 11.5,
    });
    expect(requestClient.get).toHaveBeenCalledWith(
      '/absence-requests/leave-balance',
      { params: { as_of: '2026-10-05' } },
    );

    requestClient.get.mockResolvedValueOnce(true);
    await expect(getReviewerCapability()).resolves.toBe(true);

    requestClient.get.mockResolvedValueOnce({
      items: [{ ...request, reason: null }],
    });
    await expect(getAbsenceRequests({ page: 1, per_page: 20 })).rejects.toThrow(
      'reason',
    );
  });

  it('creates a trip and sends review mutations to the matching routes', async () => {
    requestClient.post.mockResolvedValue(request);
    const payload = {
      address: 'Ha Noi',
      root_organization_id: 'root-1',
      end_at: '2026-10-05T17:00:00Z',
      leave_type: 'BUSINESS_TRIP' as const,
      reason: 'Meet client',
      reviewer_id: 'reviewer-1',
      start_at: '2026-10-05T08:00:00Z',
    };

    await expect(createAbsenceRequest(payload)).resolves.toMatchObject({
      id: 'request-1',
    });
    await approveAbsenceRequest('request-1', { approval_note: null });
    await rejectAbsenceRequest('request-1', {
      approval_note: 'Needs revision',
    });
    await deleteAbsenceRequest('request-1');

    expect(requestClient.post).toHaveBeenNthCalledWith(
      1,
      '/absence-requests',
      payload,
    );
    expect(requestClient.post).toHaveBeenNthCalledWith(
      2,
      '/absence-requests/request-1/approve',
      { approval_note: null },
    );
    expect(requestClient.post).toHaveBeenNthCalledWith(
      3,
      '/absence-requests/request-1/reject',
      { approval_note: 'Needs revision' },
    );
    expect(requestClient.delete).toHaveBeenCalledWith(
      '/absence-requests/request-1',
    );
  });

  it('updates, submits and returns a request through its lifecycle routes', async () => {
    requestClient.put.mockResolvedValue(request);
    requestClient.post.mockResolvedValue(request);
    const payload = {
      address: 'Ha Noi',
      end_at: '2026-10-05T17:00:00Z',
      leave_type: 'BUSINESS_TRIP' as const,
      reason: 'Meet client',
      reviewer_id: 'reviewer-1',
      start_at: '2026-10-05T08:00:00Z',
    };
    await updateAbsenceRequest('request-1', payload);
    await submitAbsenceRequest('request-1');
    await returnAbsenceRequest('request-1', { approval_note: 'Add details' });
    expect(requestClient.put).toHaveBeenCalledWith(
      '/absence-requests/request-1',
      payload,
    );
    expect(requestClient.post).toHaveBeenCalledWith(
      '/absence-requests/request-1/submit',
    );
    expect(requestClient.post).toHaveBeenCalledWith(
      '/absence-requests/request-1/return',
      { approval_note: 'Add details' },
    );
  });

  it('blocks invalid leave periods and trips without an address before posting', async () => {
    const annual = {
      address: null,
      root_organization_id: 'root-1',
      end_at: '2026-10-06T17:00:00Z',
      leave_type: 'ANNUAL' as const,
      reason: 'Rest',
      reviewer_id: 'reviewer-1',
      start_at: '2026-10-05T08:00:00Z',
    };
    requestClient.post.mockResolvedValue(request);
    await expect(createAbsenceRequest(annual)).resolves.toMatchObject({
      id: 'request-1',
    });
    await expect(
      createAbsenceRequest({ ...annual, leave_type: 'UNPAID' }),
    ).resolves.toMatchObject({ id: 'request-1' });
    await expect(
      createAbsenceRequest({
        ...annual,
        address: null,
        leave_type: 'BUSINESS_TRIP',
      }),
    ).rejects.toThrow('address');
    expect(requestClient.post).toHaveBeenCalledTimes(2);
  });
});
