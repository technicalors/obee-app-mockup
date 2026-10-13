import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  createAttendanceLog,
  getAttendanceContext,
  getAttendanceDayDetail,
  getAttendanceRange,
} from './index';

const requestClientState = vi.hoisted(() => ({
  get: vi.fn(),
  post: vi.fn(),
}));

vi.mock('#/api/request', () => ({
  requestClient: requestClientState,
}));

function makeLocation() {
  return {
    created_at: '2026-06-23T08:00:00+07:00',
    departments: [],
    excluded_users: [],
    id: 'location-1',
    ips: [
      {
        attendance_location_id: 'location-1',
        created_at: '2026-06-23T08:00:00+07:00',
        id: 'ip-1',
        ip_address: '127.0.0.1',
        updated_at: '2026-06-23T08:00:00+07:00',
      },
    ],
    is_active: true,
    latitude: 20.859812,
    longitude: 106.697857,
    name: 'HQ',
    radius_meters: 100,
    updated_at: '2026-06-23T08:00:00+07:00',
    users: [],
    validation_mode: 'either',
  };
}

function makeLog() {
  return {
    attendance_location_id: 'location-1',
    checked_at: '2026-06-23T08:00:00+07:00',
    id: 'log-1',
    ip_address: '127.0.0.1',
    latitude: 20.859812,
    location: null,
    longitude: 106.697857,
    source: 'obee',
  };
}

function makeDayDetail() {
  return {
    date: '2026-06-23',
    first_check_in_at: '2026-06-23T08:00:00+07:00',
    last_check_out_at: '2026-06-23T17:30:00+07:00',
    logs: [makeLog()],
    total_work_seconds: 34_200,
  };
}

describe('attendance api', () => {
  beforeEach(() => {
    requestClientState.get.mockReset();
    requestClientState.post.mockReset();
  });

  it('loads attendance context through the relative endpoint', async () => {
    requestClientState.get.mockResolvedValue({
      assigned_locations: [makeLocation()],
      ip_address: '127.0.0.1',
      user: {
        id: 'user-1',
        name: 'Jane',
      },
    });

    await expect(getAttendanceContext()).resolves.toMatchObject({
      assigned_locations: [{ id: 'location-1' }],
      ip_address: '127.0.0.1',
    });
    expect(requestClientState.get).toHaveBeenCalledWith('/attendance/context');
  }, 10_000);

  it('loads one day detail with the selected date as query params', async () => {
    requestClientState.get.mockResolvedValue(makeDayDetail());

    await expect(getAttendanceDayDetail('2026-06-23')).resolves.toMatchObject({
      date: '2026-06-23',
    });
    expect(requestClientState.get).toHaveBeenCalledWith('/attendance/logs', {
      params: { date: '2026-06-23' },
    });
  });

  it('loads range summaries with from and to query params', async () => {
    requestClientState.get.mockResolvedValue([
      {
        date: '2026-06-23',
        first_check_in_at: '2026-06-23T08:00:00+07:00',
        last_check_out_at: '2026-06-23T17:30:00+07:00',
        logs_count: 2,
        on_leave: false,
        total_work_seconds: 34_200,
      },
    ]);

    await expect(
      getAttendanceRange({ from: '2026-06-01', to: '2026-06-30' }),
    ).resolves.toHaveLength(1);
    expect(requestClientState.get).toHaveBeenCalledWith(
      '/attendance/logs/range',
      {
        params: { from: '2026-06-01', to: '2026-06-30' },
      },
    );
  });

  it('posts punch coordinates through the relative attendance logs endpoint', async () => {
    requestClientState.post.mockResolvedValue({
      ...makeLog(),
      created_at: '2026-06-23T08:00:00+07:00',
      location: makeLocation(),
      updated_at: '2026-06-23T08:00:00+07:00',
      user_id: 'user-1',
    });

    await expect(
      createAttendanceLog({
        latitude: 20.859812,
        longitude: 106.697857,
      }),
    ).resolves.toMatchObject({ id: 'log-1' });
    expect(requestClientState.post).toHaveBeenCalledWith('/attendance/logs', {
      latitude: 20.859812,
      longitude: 106.697857,
    });
  });

  it('rejects backend payloads that miss required attendance fields', async () => {
    requestClientState.get.mockResolvedValue({ date: '2026-06-23' });

    await expect(getAttendanceDayDetail('2026-06-23')).rejects.toThrow(
      /required|expected/i,
    );
  });

  it('rejects invalid validation modes from context payloads', async () => {
    requestClientState.get.mockResolvedValue({
      assigned_locations: [{ ...makeLocation(), validation_mode: 'wifi' }],
      ip_address: '127.0.0.1',
      user: {
        id: 'user-1',
        name: 'Jane',
      },
    });

    await expect(getAttendanceContext()).rejects.toThrow(/invalid|expected/i);
  });

  it('rejects invalid punch payloads before posting', async () => {
    await expect(
      createAttendanceLog({
        latitude: 91,
        longitude: 106.697857,
      }),
    ).rejects.toThrow(/too_big|less than or equal|expected/i);
    expect(requestClientState.post).not.toHaveBeenCalled();
  });
});
