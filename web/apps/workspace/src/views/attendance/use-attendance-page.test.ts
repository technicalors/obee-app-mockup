import { createApp, nextTick } from 'vue';

import { beforeEach, describe, expect, it, vi } from 'vitest';

import { useAttendancePage } from './use-attendance-page';

const attendanceApiState = vi.hoisted(() => ({
  createAttendanceLog: vi.fn(),
  getAttendanceContext: vi.fn(),
  getAttendanceDayDetail: vi.fn(),
  getAttendanceRange: vi.fn(),
}));
const requestFeedbackState = vi.hoisted(() => ({
  showRequestError: vi.fn(),
}));
const notificationState = vi.hoisted(() => ({
  error: vi.fn(),
  success: vi.fn(),
}));

vi.mock('#/api/attendance', () => attendanceApiState);
vi.mock('#/shared/request-feedback', () => requestFeedbackState);
vi.mock('ant-design-vue', () => ({
  notification: notificationState,
}));
vi.mock('#/locales', () => ({
  $t: (key: string, params?: Record<string, string>) => {
    if (params === undefined) {
      return key;
    }

    return `${key}:${JSON.stringify(params)}`;
  },
}));

interface MountedPage {
  app: ReturnType<typeof createApp>;
  page: ReturnType<typeof useAttendancePage>;
}

function makeContext(hasShiftToday = true) {
  return {
    assigned_locations: [
      {
        created_at: '2026-06-23T08:00:00+07:00',
        organizations: [],
        excluded_users: [],
        id: 'location-1',
        ips: [],
        deleted_at: null,
        latitude: 20.859812,
        longitude: 106.697857,
        name: 'HQ',
        radius_meters: 100,
        updated_at: '2026-06-23T08:00:00+07:00',
        users: [],
        validation_mode: 'location',
      },
    ],
    has_shift_today: hasShiftToday,
    ip_address: '127.0.0.1',
    user: {
      id: 'user-1',
      name: 'Jane',
    },
  };
}

function makeDayDetail(
  date = '2026-06-23',
  logs: Array<{
    checked_at: string;
    id: string;
  }> = [],
) {
  const firstLog = logs[0];
  const lastLog = logs.at(-1);

  return {
    date,
    first_check_in_at: firstLog === undefined ? null : firstLog.checked_at,
    last_check_out_at: lastLog === undefined ? null : lastLog.checked_at,
    logs: logs.map((log) => ({
      attendance_location_id: 'location-1',
      checked_at: log.checked_at,
      id: log.id,
      ip_address: '127.0.0.1',
      latitude: 20.859812,
      location: null,
      longitude: 106.697857,
      source: 'obee',
    })),
    total_work_seconds:
      firstLog === undefined || lastLog === undefined || logs.length < 2
        ? 0
        : (new Date(lastLog.checked_at).getTime() -
            new Date(firstLog.checked_at).getTime()) /
          1000,
  };
}

function makeRange() {
  return [
    {
      date: '2026-06-23',
      first_check_in_at: null,
      last_check_out_at: null,
      logs_count: 0,
      total_work_seconds: 0,
    },
  ];
}

async function flushAsync(): Promise<void> {
  await Promise.resolve();
  await Promise.resolve();
  await nextTick();
}

function mountComposable(): MountedPage {
  let page: null | ReturnType<typeof useAttendancePage> = null;
  const app = createApp({
    setup() {
      page = useAttendancePage();

      return {};
    },
    template: '<div />',
  });

  app.mount(document.createElement('div'));

  return {
    app,
    get page() {
      if (page === null) {
        throw new Error('Attendance page composable did not mount.');
      }

      return page;
    },
  };
}

describe('useAttendancePage', () => {
  beforeEach(() => {
    attendanceApiState.createAttendanceLog.mockReset();
    attendanceApiState.getAttendanceContext.mockReset();
    attendanceApiState.getAttendanceDayDetail.mockReset();
    attendanceApiState.getAttendanceRange.mockReset();
    requestFeedbackState.showRequestError.mockReset();
    notificationState.error.mockReset();
    notificationState.success.mockReset();
    attendanceApiState.getAttendanceContext.mockResolvedValue(makeContext());
    attendanceApiState.getAttendanceDayDetail.mockResolvedValue(
      makeDayDetail(),
    );
    attendanceApiState.getAttendanceRange.mockResolvedValue(makeRange());
    Object.defineProperty(window.navigator, 'geolocation', {
      configurable: true,
      value: {
        getCurrentPosition: vi.fn(),
      },
    });
  });

  it('loads context, today detail, and current month range on mount', async () => {
    const mounted = mountComposable();
    await flushAsync();

    expect(attendanceApiState.getAttendanceContext).toHaveBeenCalledTimes(1);
    expect(attendanceApiState.getAttendanceDayDetail).toHaveBeenCalledTimes(1);
    expect(attendanceApiState.getAttendanceRange).toHaveBeenCalledTimes(1);

    mounted.app.unmount();
  });

  it('disables punching when no shift is assigned for today', async () => {
    attendanceApiState.getAttendanceContext.mockResolvedValue(
      makeContext(false),
    );
    const mounted = mountComposable();
    await flushAsync();

    expect(mounted.page.canPunch.value).toBe(false);
    expect(mounted.page.noShiftToday.value).toBe(true);

    await mounted.page.handlePunch();

    expect(attendanceApiState.createAttendanceLog).not.toHaveBeenCalled();
    mounted.app.unmount();
  });

  it('requests geolocation instead of posting when punching without a position', async () => {
    const getCurrentPosition = vi.fn();
    Object.defineProperty(window.navigator, 'geolocation', {
      configurable: true,
      value: { getCurrentPosition },
    });
    const mounted = mountComposable();
    await flushAsync();

    await mounted.page.handlePunch();

    expect(getCurrentPosition).toHaveBeenCalledTimes(2);
    expect(attendanceApiState.createAttendanceLog).not.toHaveBeenCalled();

    mounted.app.unmount();
  });

  it('posts coordinates and reloads context plus today detail after punch success', async () => {
    Object.defineProperty(window.navigator, 'geolocation', {
      configurable: true,
      value: {
        getCurrentPosition: vi.fn((success) =>
          success({
            coords: {
              latitude: 20.859812,
              longitude: 106.697857,
            },
          }),
        ),
      },
    });
    attendanceApiState.createAttendanceLog.mockResolvedValue({
      attendance_location_id: 'location-1',
      checked_at: '2026-06-23T08:00:00+07:00',
      id: 'log-1',
      ip_address: '127.0.0.1',
      latitude: 20.859812,
      location: null,
      longitude: 106.697857,
      source: 'obee',
    });
    const mounted = mountComposable();
    await flushAsync();

    await mounted.page.handlePunch();

    expect(attendanceApiState.createAttendanceLog).toHaveBeenCalledWith({
      latitude: 20.859812,
      longitude: 106.697857,
    });
    expect(attendanceApiState.getAttendanceContext).toHaveBeenCalledTimes(2);
    expect(attendanceApiState.getAttendanceDayDetail).toHaveBeenCalledTimes(2);
    expect(notificationState.success).toHaveBeenCalled();

    mounted.app.unmount();
  });

  it('loads the selected month and selects the first day without fetching day detail', async () => {
    const mounted = mountComposable();
    await flushAsync();
    attendanceApiState.getAttendanceDayDetail.mockClear();

    await mounted.page.selectMonth('2026-05');

    expect(attendanceApiState.getAttendanceRange).toHaveBeenCalledWith({
      from: '2026-05-01',
      to: '2026-05-31',
    });
    expect(attendanceApiState.getAttendanceDayDetail).not.toHaveBeenCalled();
    expect(mounted.page.selectedDate.value).toBe('2026-05-01');

    mounted.app.unmount();
  });

  it('loads calendar day detail when selecting a past day', async () => {
    attendanceApiState.getAttendanceDayDetail.mockResolvedValueOnce(
      makeDayDetail(),
    );
    attendanceApiState.getAttendanceDayDetail.mockResolvedValueOnce(
      makeDayDetail('2026-06-16', [
        {
          checked_at: '2026-06-16T08:00:00+07:00',
          id: 'log-1',
        },
        {
          checked_at: '2026-06-16T17:30:00+07:00',
          id: 'log-2',
        },
      ]),
    );
    const mounted = mountComposable();
    await flushAsync();
    attendanceApiState.getAttendanceDayDetail.mockClear();

    await mounted.page.openDayDetail('2026-06-16');

    expect(mounted.page.selectedDate.value).toBe('2026-06-16');
    expect(attendanceApiState.getAttendanceDayDetail).toHaveBeenCalledWith(
      '2026-06-16',
    );
    expect(mounted.page.selectedDayPunches.value).toHaveLength(2);
    expect(mounted.page.selectedDayStatusText.value).toBe('attendance.onTime');

    mounted.app.unmount();
  });

  it('derives selected day punctuality from the first check-in time', async () => {
    attendanceApiState.getAttendanceDayDetail.mockResolvedValueOnce(
      makeDayDetail(),
    );
    attendanceApiState.getAttendanceDayDetail.mockResolvedValueOnce(
      makeDayDetail('2026-06-20', [
        {
          checked_at: '2026-06-20T09:30:00+07:00',
          id: 'log-1',
        },
        {
          checked_at: '2026-06-20T17:30:00+07:00',
          id: 'log-2',
        },
      ]),
    );
    const mounted = mountComposable();
    await flushAsync();

    await mounted.page.openDayDetail('2026-06-20');

    expect(mounted.page.selectedDayStatusText.value).toBe('attendance.late');

    mounted.app.unmount();
  });

  it('treats an 08:00 first check-in as on time', async () => {
    attendanceApiState.getAttendanceDayDetail.mockResolvedValueOnce(
      makeDayDetail(),
    );
    attendanceApiState.getAttendanceDayDetail.mockResolvedValueOnce(
      makeDayDetail('2026-06-16', [
        {
          checked_at: '2026-06-16T08:00:00+07:00',
          id: 'log-1',
        },
        {
          checked_at: '2026-06-16T17:30:00+07:00',
          id: 'log-2',
        },
      ]),
    );
    const mounted = mountComposable();
    await flushAsync();

    await mounted.page.openDayDetail('2026-06-16');

    expect(mounted.page.selectedDayStatusText.value).toBe('attendance.onTime');

    mounted.app.unmount();
  });

  it('does not load future months', async () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date(2026, 5, 23, 12));
    const mounted = mountComposable();

    try {
      await flushAsync();
      attendanceApiState.getAttendanceRange.mockClear();

      await mounted.page.selectMonth('2026-07');
      await mounted.page.shiftMonth(1);

      expect(mounted.page.currentMonth.value).toBe('2026-06');
      expect(attendanceApiState.getAttendanceRange).not.toHaveBeenCalled();
    } finally {
      mounted.app.unmount();
      vi.useRealTimers();
    }
  });

  it('shows request errors when initial context load fails', async () => {
    const error = new Error('Problem');
    attendanceApiState.getAttendanceContext.mockRejectedValue(error);

    const mounted = mountComposable();
    await flushAsync();

    expect(requestFeedbackState.showRequestError).toHaveBeenCalledWith(
      error,
      'attendance.messages.unexpectedError',
      'Failed to load attendance context.',
    );

    mounted.app.unmount();
  });
});
