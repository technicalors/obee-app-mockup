import type {
  AbsenceListQuery,
  AbsenceRequest,
  AbsenceStatus,
  LeaveType,
} from '#/api/absence-requests';

import dayjs from 'dayjs';

export type RequestTab =
  | 'all'
  | 'approved'
  | 'my'
  | 'pending'
  | 'rejected'
  | 'review';

export function buildAbsenceListQuery(input: {
  currentUserId: string;
  from?: string;
  leaveType: LeaveType | undefined;
  page: number;
  perPage?: number;
  reviewerId?: string;
  reviewerIds?: string[];
  status: AbsenceStatus | undefined;
  tab: RequestTab;
  to?: string;
  userId?: string;
  userIds?: string[];
}): AbsenceListQuery {
  const query: AbsenceListQuery = {
    page: input.page,
    per_page: input.perPage ?? 10,
    ...(input.leaveType === undefined ? {} : { leave_type: input.leaveType }),
    ...(input.from ? { from: input.from } : {}),
    ...(input.to ? { to: input.to } : {}),
  };

  if (input.tab === 'pending') {
    query.status = 'pending';
  } else if (input.tab === 'approved') {
    query.status = 'approved';
  } else if (input.tab === 'rejected') {
    query.statuses = ['rejected', 'returned'];
  } else if (input.status !== undefined) {
    query.status = input.status;
  }

  if (input.tab === 'my') {
    query.user_id = input.currentUserId;
  } else if (input.userIds && input.userIds.length > 0) {
    query.user_ids = input.userIds;
  } else if (input.userId !== undefined && input.userId !== '') {
    query.user_id = input.userId;
  }

  if (input.tab === 'review') {
    query.reviewer_id = input.currentUserId;
  } else if (input.reviewerIds && input.reviewerIds.length > 0) {
    query.reviewer_ids = input.reviewerIds;
  } else if (input.reviewerId !== undefined && input.reviewerId !== '') {
    query.reviewer_id = input.reviewerId;
  }

  return query;
}

export function canReviewRequest(
  request: AbsenceRequest,
  currentUserId: null | string,
  hasReviewPermission: boolean,
): boolean {
  if (!currentUserId || !hasReviewPermission) return false;
  return (
    request.status === 'pending' &&
    request.reviewer_id === currentUserId &&
    request.user_id !== currentUserId
  );
}

export function canEditRequest(
  request: AbsenceRequest,
  currentUserId: null | string,
): boolean {
  if (!currentUserId) return false;
  return request.status === 'returned' && request.user_id === currentUserId;
}

export function canDeleteRequest(
  request: AbsenceRequest,
  currentUserId: null | string,
): boolean {
  if (!currentUserId) return false;
  return (
    ['pending', 'returned'].includes(request.status) &&
    request.user_id === currentUserId
  );
}

export const ABSENCE_REQUEST_TYPE = {
  TIMEOFF: 'TIMEOFF',
  BUSINESS_TRIP: 'BUSINESS_TRIP',
} as const;

export const ABSENCE_REQUEST_TIMEOFF_SUBTYPE = {
  ANNUAL: 'ANNUAL',
  UNPAID: 'UNPAID',
} as const;

export type AbsenceRequestType =
  (typeof ABSENCE_REQUEST_TYPE)[keyof typeof ABSENCE_REQUEST_TYPE];
export type AbsenceRequestTimeoffSubtype =
  (typeof ABSENCE_REQUEST_TIMEOFF_SUBTYPE)[keyof typeof ABSENCE_REQUEST_TIMEOFF_SUBTYPE];

export function deriveAbsenceRequestLeaveType(input: {
  requestType: '' | AbsenceRequestType;
  timeoffSubtype: '' | AbsenceRequestTimeoffSubtype;
}): '' | LeaveType {
  if (input.requestType === ABSENCE_REQUEST_TYPE.BUSINESS_TRIP) {
    return 'BUSINESS_TRIP';
  }
  if (input.requestType === ABSENCE_REQUEST_TYPE.TIMEOFF) {
    return input.timeoffSubtype;
  }
  return '';
}

export interface AbsenceRequestFilterState {
  from: string;
  leave_type: '' | LeaveType;
  reviewer_id: string;
  reviewer_ids: string[];
  status: '' | AbsenceStatus;
  to: string;
  user_id: string;
  user_ids: string[];
}

export function getDefaultAbsenceFilters(
  now: Date = new Date(),
): AbsenceRequestFilterState {
  const today = dayjs(now);
  return {
    from: today.subtract(30, 'day').format('YYYY-MM-DD'),
    leave_type: '',
    reviewer_id: '',
    reviewer_ids: [],
    status: '',
    to: today.format('YYYY-MM-DD'),
    user_id: '',
    user_ids: [],
  };
}

export function countActiveAbsenceFilters(
  current: AbsenceRequestFilterState,
  defaults: AbsenceRequestFilterState,
  activeTab: RequestTab,
): number {
  let count = 0;
  if (current.leave_type !== '') count++;
  const isStatusLockedByTab = [
    'approved',
    'pending',
    'rejected',
    'review',
  ].includes(activeTab);
  if (!isStatusLockedByTab && current.status !== '') count++;
  if (
    activeTab !== 'review' &&
    (current.reviewer_id !== '' || current.reviewer_ids.length > 0)
  )
    count++;
  if (
    activeTab !== 'my' &&
    (current.user_id !== '' || current.user_ids.length > 0)
  )
    count++;
  if (current.from !== defaults.from) count++;
  if (current.to !== defaults.to) count++;
  return count;
}
