import type {
  AttendanceContext,
  AttendanceDayDetail,
  AttendanceLog,
  AttendancePunchPayload,
  AttendanceRangeSummary,
} from '../contracts';

import { requestClient } from '#/api/request';

import {
  attendanceContextSchema,
  attendanceDayDetailSchema,
  attendanceLogSchema,
  attendancePunchPayloadSchema,
  attendanceRangeSummarySchema,
} from '../contracts';

export interface AttendanceRangeParams {
  from: string;
  to: string;
}

export async function getAttendanceContext(): Promise<AttendanceContext> {
  const payload = await requestClient.get<unknown>('/attendance/context');

  return attendanceContextSchema.parse(payload);
}

export async function getAttendanceDayDetail(
  date: string,
): Promise<AttendanceDayDetail> {
  const payload = await requestClient.get<unknown>('/attendance/logs', {
    params: { date },
  });

  return attendanceDayDetailSchema.parse(payload);
}

export async function getAttendanceRange(
  params: AttendanceRangeParams,
): Promise<AttendanceRangeSummary[]> {
  const payload = await requestClient.get<unknown>('/attendance/logs/range', {
    params,
  });

  return attendanceRangeSummarySchema.array().parse(payload);
}

export async function createAttendanceLog(
  payload: AttendancePunchPayload,
): Promise<AttendanceLog> {
  const parsedPayload = attendancePunchPayloadSchema.parse(payload);
  const response = await requestClient.post<unknown>(
    '/attendance/logs',
    parsedPayload,
  );

  return attendanceLogSchema.parse(response);
}
