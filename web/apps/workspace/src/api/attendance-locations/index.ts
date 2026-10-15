import type {
  AttendanceLocation,
  AttendanceLocationIndexQuery,
  CreateAttendanceLocationPayload,
  UpdateAttendanceLocationPayload,
} from '#/api/contracts';

import {
  attendanceLocationIndexQuerySchema,
  attendanceLocationSchema,
  createAttendanceLocationPayloadSchema,
  updateAttendanceLocationPayloadSchema,
} from '#/api/contracts';
import { requestClient } from '#/api/request';
import { createResourceApi } from '#/api/resource';

const baseAttendanceLocationsResource = createResourceApi<
  AttendanceLocation,
  AttendanceLocationIndexQuery,
  CreateAttendanceLocationPayload,
  UpdateAttendanceLocationPayload
>('/attendance-locations', {
  createPayloadSchema: createAttendanceLocationPayloadSchema,
  createResponseSchema: attendanceLocationSchema,
  detailResponseSchema: attendanceLocationSchema,
  indexQuerySchema: attendanceLocationIndexQuerySchema,
  rowSchema: attendanceLocationSchema,
  updatePayloadSchema: updateAttendanceLocationPayloadSchema,
  updateResponseSchema: attendanceLocationSchema,
});

export const attendanceLocationsResource = {
  create: (
    payload: CreateAttendanceLocationPayload,
  ): Promise<AttendanceLocation> =>
    baseAttendanceLocationsResource.create(payload),
  delete: baseAttendanceLocationsResource.delete,
  getAll: (params: AttendanceLocationIndexQuery) =>
    baseAttendanceLocationsResource.getAll(params),
  getById: (id: number | string): Promise<AttendanceLocation> =>
    baseAttendanceLocationsResource.getById(id),
  restore: async (id: number | string): Promise<void> => {
    await requestClient.post(`/attendance-locations/${id}/restore`);
  },
  update: (
    id: number | string,
    payload: UpdateAttendanceLocationPayload,
  ): Promise<AttendanceLocation> =>
    baseAttendanceLocationsResource.update(id, payload),
};
