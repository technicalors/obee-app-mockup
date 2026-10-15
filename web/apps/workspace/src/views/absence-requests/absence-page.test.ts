import type { AbsenceRequest } from '#/api/absence-requests';

import { describe, expect, it } from 'vitest';

import {
  buildAbsenceListQuery,
  canDeleteRequest,
  canReviewRequest,
  countActiveAbsenceFilters,
  deriveAbsenceRequestLeaveType,
  getDefaultAbsenceFilters,
} from './absence-page';

describe('absence request page behavior', () => {
  it('keeps pending, approved, rejected, and all scopes distinct', () => {
    const common = {
      currentUserId: 'employee-1',
      leaveType: undefined,
      page: 2,
      status: undefined,
    };
    expect(buildAbsenceListQuery({ ...common, tab: 'pending' })).toEqual({
      page: 2,
      per_page: 10,
      status: 'pending',
    });
    expect(buildAbsenceListQuery({ ...common, tab: 'approved' })).toEqual({
      page: 2,
      per_page: 10,
      status: 'approved',
    });
    expect(buildAbsenceListQuery({ ...common, tab: 'rejected' })).toEqual({
      page: 2,
      per_page: 10,
      statuses: ['rejected', 'returned'],
    });
    expect(buildAbsenceListQuery({ ...common, tab: 'all' })).toEqual({
      page: 2,
      per_page: 10,
    });
  });

  it('correctly derives leave type from request type and timeoff subtype', () => {
    expect(
      deriveAbsenceRequestLeaveType({
        requestType: 'BUSINESS_TRIP',
        timeoffSubtype: '',
      }),
    ).toBe('BUSINESS_TRIP');
    expect(
      deriveAbsenceRequestLeaveType({
        requestType: 'TIMEOFF',
        timeoffSubtype: 'ANNUAL',
      }),
    ).toBe('ANNUAL');
    expect(
      deriveAbsenceRequestLeaveType({
        requestType: 'TIMEOFF',
        timeoffSubtype: 'UNPAID',
      }),
    ).toBe('UNPAID');
    expect(
      deriveAbsenceRequestLeaveType({
        requestType: '',
        timeoffSubtype: '',
      }),
    ).toBe('');
  });

  it('calculates active filter count correctly', () => {
    const fixedDate = new Date(2026, 9, 30);
    const defaults = getDefaultAbsenceFilters(fixedDate);
    expect(defaults.from).toBe('2026-09-30');
    expect(defaults.to).toBe('2026-10-30');
    expect(countActiveAbsenceFilters(defaults, defaults, 'all')).toBe(0);

    const changed = {
      ...defaults,
      leave_type: 'ANNUAL' as const,
      status: 'pending' as const,
    };
    expect(countActiveAbsenceFilters(changed, defaults, 'all')).toBe(2);
    // In review tab, status is implicitly pending so locked status does not count
    expect(countActiveAbsenceFilters(changed, defaults, 'review')).toBe(1);
  });

  it('defaults the request list date range to 30 days prior and today', () => {
    const fixedDate = new Date(2026, 9, 30);
    const defaults = getDefaultAbsenceFilters(fixedDate);
    expect(
      buildAbsenceListQuery({
        currentUserId: 'employee-1',
        from: defaults.from || undefined,
        leaveType: undefined,
        page: 1,
        status: undefined,
        tab: 'pending',
        to: defaults.to || undefined,
      }),
    ).toEqual({
      from: '2026-09-30',
      page: 1,
      per_page: 10,
      status: 'pending',
      to: '2026-10-30',
    });
  });

  it('only allows the requester to delete and the assigned reviewer to decide pending requests', () => {
    const request = {
      reviewer_id: 'manager',
      status: 'pending',
      user_id: 'employee',
    } as AbsenceRequest;
    expect(canReviewRequest(request, 'manager', true)).toBe(true);
    expect(canReviewRequest(request, 'employee', true)).toBe(false);
    expect(canReviewRequest(request, 'manager', false)).toBe(false);
    expect(
      canReviewRequest({ ...request, user_id: 'manager' }, 'manager', true),
    ).toBe(false);
    expect(canDeleteRequest(request, 'employee')).toBe(true);
    expect(
      canDeleteRequest({ ...request, status: 'returned' }, 'employee'),
    ).toBe(true);
    expect(
      canDeleteRequest({ ...request, status: 'returned' }, 'employee'),
    ).toBe(true);
    expect(
      canDeleteRequest({ ...request, status: 'approved' }, 'employee'),
    ).toBe(false);
  });
});
