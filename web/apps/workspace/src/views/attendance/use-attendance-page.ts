import type { Dayjs } from 'dayjs';

import type { AttendanceEligibility, Coordinates } from './attendance-rules';

import type {
  AttendanceContext,
  AttendanceDayDetail,
  AttendanceLocation,
  AttendanceLog,
  AttendanceRangeSummary,
} from '#/api/contracts';

import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue';

import { notification } from 'ant-design-vue';

import {
  createAttendanceLog,
  getAttendanceContext,
  getAttendanceDayDetail,
  getAttendanceRange,
} from '#/api/attendance';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';

import {
  buildAttendanceCalendarCells,
  evaluateAttendanceEligibility,
  formatWorkSeconds,
  getAttendanceSummaryStatus,
  getMonthEndDate,
  getMonthStartDate,
  getTodayDate,
  shiftMonthValue,
} from './attendance-rules';

interface PunchLog {
  coords: string;
  ip: string;
  time: string;
}

interface AttendanceEvaluation {
  eligibility: AttendanceEligibility;
  location: AttendanceLocation;
}

type PositionState = 'denied' | 'failed' | 'idle' | 'loading' | 'ready';

const SHIFT_START_HOUR = 8;
const SHIFT_START_MINUTE = 0;

export function useAttendancePage() {
  const today = getTodayDate();
  const todayMonth = today.slice(0, 7);
  const activeTab = ref<'history' | 'punch'>('punch');
  const context = ref<AttendanceContext | null>(null);
  const currentTime = ref(new Date());
  const currentMonth = ref(today.slice(0, 7));
  const loadingContext = ref(false);
  const loadingRange = ref(false);
  const loadingSelectedDay = ref(false);
  const loadingTodayLogs = ref(false);
  const position = ref<Coordinates | null>(null);
  const positionState = ref<PositionState>('idle');
  const punching = ref(false);
  const rangeSummaries = ref<AttendanceRangeSummary[]>([]);
  const selectedDate = ref(today);
  const selectedDayDetail = ref<AttendanceDayDetail | null>(null);
  const todayDetail = ref<AttendanceDayDetail | null>(null);
  let timerId: null | number = null;

  const evaluations = computed<AttendanceEvaluation[]>(() => {
    if (context.value === null) {
      return [];
    }

    return context.value.assigned_locations.map((location) => ({
      eligibility: evaluateAttendanceEligibility(
        location,
        position.value,
        context.value?.ip_address ?? null,
      ),
      location,
    }));
  });

  const bestEvaluation = computed<AttendanceEvaluation | null>(() => {
    if (evaluations.value.length === 0) {
      return null;
    }

    const eligibleEvaluations = evaluations.value.filter(
      (evaluation) => evaluation.eligibility.eligible,
    );

    if (eligibleEvaluations.length > 0) {
      return eligibleEvaluations.toSorted(compareEvaluations)[0] ?? null;
    }

    return evaluations.value.toSorted(compareEvaluations)[0] ?? null;
  });

  const gpsLoading = computed(() => positionState.value === 'loading');
  const gpsValid = computed(
    () => bestEvaluation.value?.eligibility.location_matched === true,
  );
  const gpsCoords = computed(() => {
    if (position.value === null) {
      return positionStateLabel(positionState.value);
    }

    return `${position.value.latitude.toFixed(6)}, ${position.value.longitude.toFixed(6)}`;
  });
  const ipAddress = computed(
    () => context.value?.ip_address ?? $t('page.attendance.noIp'),
  );
  const ipLoading = computed(() => loadingContext.value);
  const ipValid = computed(
    () => bestEvaluation.value?.eligibility.ip_matched === true,
  );
  const canPunch = computed(() => {
    if (loadingContext.value || punching.value || context.value === null) {
      return false;
    }

    if (context.value.assigned_locations.length === 0) {
      return false;
    }

    if (position.value === null) {
      return true;
    }

    return bestEvaluation.value?.eligibility.eligible === true;
  });

  const todayPunches = computed<PunchLog[]>(() => {
    if (todayDetail.value === null) {
      return [];
    }

    return todayDetail.value.logs.toReversed().map((log) => logToPunch(log));
  });
  const todayOnTimeStatus = computed(() => {
    if (todayDetail.value === null || todayDetail.value.logs.length === 0) {
      return $t('page.attendance.noData');
    }

    if (todayDetail.value.first_check_in_at === null) {
      throw new Error('Attendance day detail is missing first_check_in_at.');
    }

    return isOnTimeCheckIn(todayDetail.value.first_check_in_at)
      ? $t('page.attendance.onTime')
      : $t('page.attendance.late');
  });
  const todayWorkHoursDecimal = computed(
    () => (todayDetail.value?.total_work_seconds ?? 0) / 3600,
  );
  const todayWorkHoursDecimalStr = computed(() =>
    $t('page.attendance.totalWorkHoursValue', {
      hours: todayWorkHoursDecimal.value.toFixed(1),
    }),
  );
  const todayWorkHoursMobileStr = computed(() =>
    formatWorkSeconds(todayDetail.value?.total_work_seconds ?? 0),
  );

  const calendarCells = computed(() =>
    buildAttendanceCalendarCells(
      currentMonth.value,
      rangeSummaries.value,
      today,
    ),
  );
  const canShiftNextMonth = computed(() => currentMonth.value < todayMonth);
  const monthlyTotalHours = computed(() =>
    (
      rangeSummaries.value.reduce(
        (total, summary) => total + summary.total_work_seconds,
        0,
      ) / 3600
    ).toFixed(1),
  );
  const monthlyWorkingDays = computed(
    () =>
      rangeSummaries.value.filter((summary) => summary.logs_count > 0).length,
  );
  const monthlyDeficientDays = computed(
    () =>
      rangeSummaries.value.filter(
        (summary) => getAttendanceSummaryStatus(summary) === 'deficient',
      ).length,
  );
  const selectedDayPunches = computed<PunchLog[]>(() => {
    if (selectedDayDetail.value === null) {
      return [];
    }

    return selectedDayDetail.value.logs
      .toReversed()
      .map((log) => logToPunch(log));
  });
  const selectedDayStatusText = computed(() => {
    if (
      selectedDayDetail.value === null ||
      selectedDayDetail.value.logs.length === 0
    ) {
      return $t('page.attendance.noData');
    }

    if (selectedDayDetail.value.first_check_in_at === null) {
      throw new Error('Attendance day detail is missing first_check_in_at.');
    }

    return isOnTimeCheckIn(selectedDayDetail.value.first_check_in_at)
      ? $t('page.attendance.onTime')
      : $t('page.attendance.late');
  });
  const selectedDayHoursText = computed(() =>
    $t('page.attendance.totalWorkHoursValue', {
      hours:
        selectedDayDetail.value === null
          ? '0.0'
          : (selectedDayDetail.value.total_work_seconds / 3600).toFixed(1),
    }),
  );

  async function loadInitialData(): Promise<void> {
    await Promise.all([
      loadContext(),
      loadTodayLogs(),
      loadRangeForMonth(currentMonth.value),
    ]);
  }

  async function loadContext(): Promise<void> {
    loadingContext.value = true;
    try {
      context.value = await getAttendanceContext();
    } catch (error: unknown) {
      showRequestError(
        error,
        $t('page.attendance.messages.unexpectedError'),
        'Failed to load attendance context.',
      );
    } finally {
      loadingContext.value = false;
    }
  }

  async function loadTodayLogs(): Promise<void> {
    loadingTodayLogs.value = true;
    try {
      todayDetail.value = await getAttendanceDayDetail(today);
      if (selectedDate.value === today) {
        selectedDayDetail.value = todayDetail.value;
      }
    } catch (error: unknown) {
      showRequestError(
        error,
        $t('page.attendance.messages.unexpectedError'),
        'Failed to load today attendance logs.',
      );
    } finally {
      loadingTodayLogs.value = false;
    }
  }

  async function loadRangeForMonth(month: string): Promise<void> {
    loadingRange.value = true;
    try {
      rangeSummaries.value = await getAttendanceRange({
        from: `${month}-01`,
        to: getMonthEndDate(month),
      });
    } catch (error: unknown) {
      showRequestError(
        error,
        $t('page.attendance.messages.unexpectedError'),
        'Failed to load monthly attendance logs.',
      );
    } finally {
      loadingRange.value = false;
    }
  }

  async function openDayDetail(date: string): Promise<void> {
    if (date > today) {
      return;
    }

    selectedDate.value = date;
    if (date === today) {
      selectedDayDetail.value = todayDetail.value;
      return;
    }

    loadingSelectedDay.value = true;
    try {
      selectedDayDetail.value = await getAttendanceDayDetail(date);
    } catch (error: unknown) {
      showRequestError(
        error,
        $t('page.attendance.messages.unexpectedError'),
        'Failed to load selected attendance day.',
      );
    } finally {
      loadingSelectedDay.value = false;
    }
  }

  function requestCurrentPosition(): void {
    if (!('geolocation' in navigator)) {
      positionState.value = 'failed';
      return;
    }

    positionState.value = 'loading';
    navigator.geolocation.getCurrentPosition(
      (geolocationPosition) => {
        position.value = {
          latitude: geolocationPosition.coords.latitude,
          longitude: geolocationPosition.coords.longitude,
        };
        positionState.value = 'ready';
      },
      (error) => {
        positionState.value =
          error.code === error.PERMISSION_DENIED ? 'denied' : 'failed';
      },
      { enableHighAccuracy: true, maximumAge: 30_000, timeout: 15_000 },
    );
  }

  async function handleRefreshGPS(): Promise<void> {
    requestCurrentPosition();
  }

  async function handleRefreshIP(): Promise<void> {
    await loadContext();
  }

  async function handlePunch(): Promise<void> {
    if (position.value === null) {
      requestCurrentPosition();
      return;
    }

    if (bestEvaluation.value?.eligibility.eligible !== true) {
      notification.error({
        description: $t('page.attendance.notEligible'),
        message: $t('page.attendance.messages.notEligibleTitle'),
      });
      return;
    }

    punching.value = true;
    try {
      await createAttendanceLog(position.value);
      notification.success({
        message: $t('page.attendance.messages.punchSuccess'),
      });
      await Promise.all([
        loadContext(),
        loadTodayLogs(),
        activeTab.value === 'history'
          ? loadRangeForMonth(currentMonth.value)
          : Promise.resolve(),
      ]);
    } catch (error: unknown) {
      showRequestError(
        error,
        $t('page.attendance.messages.unexpectedError'),
        'Failed to create attendance log.',
      );
    } finally {
      punching.value = false;
    }
  }

  async function shiftMonth(offset: number): Promise<void> {
    const nextMonth = shiftMonthValue(currentMonth.value, offset);
    if (nextMonth > todayMonth) {
      return;
    }

    currentMonth.value = nextMonth;
    await loadRangeForMonth(currentMonth.value);
    syncSelectedDateToMonth(nextMonth);
  }

  async function selectCurrentMonth(): Promise<void> {
    const now = new Date();
    currentMonth.value = getMonthStartDate(now).slice(0, 7);
    await Promise.all([
      loadRangeForMonth(currentMonth.value),
      openDayDetail(getTodayDate(now)),
    ]);
  }

  async function selectMonth(value: Dayjs | string): Promise<void> {
    const month = typeof value === 'string' ? value : value.format('YYYY-MM');
    if (month > todayMonth) {
      return;
    }

    currentMonth.value = month;
    await loadRangeForMonth(month);

    const monthStart = `${month}-01`;
    const monthEnd = getMonthEndDate(month);
    if (selectedDate.value < monthStart || selectedDate.value > monthEnd) {
      syncSelectedDateToMonth(month);
    }
  }

  function isFutureMonth(value: Dayjs): boolean {
    return value.format('YYYY-MM') > todayMonth;
  }

  function syncSelectedDateToMonth(month: string): void {
    selectedDate.value = `${month}-01`;
    selectedDayDetail.value = null;
  }

  function formatSelectedDateLabel(date: string): string {
    const year = Number(date.slice(0, 4));
    const month = Number(date.slice(5, 7));
    const day = Number(date.slice(8, 10));
    const selected = new Date(year, month - 1, day);
    const weekdays = [
      $t('page.attendance.weekdays.sun'),
      $t('page.attendance.weekdays.mon'),
      $t('page.attendance.weekdays.tue'),
      $t('page.attendance.weekdays.wed'),
      $t('page.attendance.weekdays.thu'),
      $t('page.attendance.weekdays.fri'),
      $t('page.attendance.weekdays.sat'),
    ];

    return `${weekdays[selected.getDay()]}, ${String(day).padStart(
      2,
      '0',
    )}/${String(month).padStart(2, '0')}/${year}`;
  }

  function getTickingDateString(date: Date): string {
    return formatSelectedDateLabel(getTodayDate(date));
  }

  function getTickingTimeString(date: Date): string {
    return [
      date.getHours().toString().padStart(2, '0'),
      date.getMinutes().toString().padStart(2, '0'),
      date.getSeconds().toString().padStart(2, '0'),
    ].join(':');
  }

  onMounted(() => {
    void loadInitialData();
    requestCurrentPosition();
    timerId = window.setInterval(() => {
      currentTime.value = new Date();
    }, 1000);
  });

  onBeforeUnmount(() => {
    if (timerId !== null) {
      window.clearInterval(timerId);
    }
  });

  watch(activeTab, (tab) => {
    if (tab === 'history') {
      void loadRangeForMonth(currentMonth.value);
    }
  });

  return {
    activeTab,
    calendarCells,
    canShiftNextMonth,
    canPunch,
    currentMonth,
    currentTime,
    formatSelectedDateLabel,
    getTickingDateString,
    getTickingTimeString,
    gpsCoords,
    gpsLoading,
    gpsValid,
    handlePunch,
    handleRefreshGPS,
    handleRefreshIP,
    ipAddress,
    ipLoading,
    ipValid,
    isFutureMonth,
    loadingRange,
    loadingSelectedDay,
    monthlyDeficientDays,
    monthlyTotalHours,
    monthlyWorkingDays,
    openDayDetail,
    positionState,
    punching,
    selectedDate,
    selectedDayHoursText,
    selectedDayPunches,
    selectedDayStatusText,
    selectCurrentMonth,
    selectMonth,
    shiftMonth,
    todayOnTimeStatus,
    todayPunches,
    todayWorkHoursDecimalStr,
    todayWorkHoursMobileStr,
  };
}

function compareEvaluations(
  left: AttendanceEvaluation,
  right: AttendanceEvaluation,
): number {
  const leftDistance = left.eligibility.distance_meters;
  const rightDistance = right.eligibility.distance_meters;

  if (leftDistance === null && rightDistance === null) {
    return 0;
  }

  if (leftDistance === null) {
    return 1;
  }

  if (rightDistance === null) {
    return -1;
  }

  return leftDistance - rightDistance;
}

function logToPunch(log: AttendanceLog): PunchLog {
  return {
    coords:
      log.latitude === null || log.longitude === null
        ? $t('page.attendance.noPosition')
        : `${log.latitude.toFixed(6)}, ${log.longitude.toFixed(6)}`,
    ip: log.ip_address === null ? $t('page.attendance.noIp') : log.ip_address,
    time: new Date(log.checked_at).toLocaleTimeString('vi-VN', {
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
    }),
  };
}

function isOnTimeCheckIn(checkedAt: string): boolean {
  const hours = Number(checkedAt.slice(11, 13));
  const minutes = Number(checkedAt.slice(14, 16));

  return (
    hours < SHIFT_START_HOUR ||
    (hours === SHIFT_START_HOUR && minutes <= SHIFT_START_MINUTE)
  );
}

function positionStateLabel(state: PositionState): string {
  switch (state) {
    case 'denied': {
      return $t('page.attendance.position.denied');
    }
    case 'failed': {
      return $t('page.attendance.position.failed');
    }
    case 'idle': {
      return $t('page.attendance.position.idle');
    }
    case 'loading': {
      return $t('page.attendance.position.loading');
    }
    case 'ready': {
      return $t('page.attendance.position.ready');
    }
  }
}
