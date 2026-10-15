import type { Dayjs } from 'dayjs';

import type { UserTreeSelectionUser } from '#/api/contracts';
import type {
  CreateWorkUserShiftRange,
  WorkUserShift,
} from '#/api/work-user-shifts';

import dayjs from 'dayjs';

import { getOrganizationRootId } from '#/api/organizations/hierarchy';

export type WorkUserShiftRangePayload = CreateWorkUserShiftRange;

export type UiWeekday = 2 | 3 | 4 | 5 | 6 | 7 | 8;

export const UI_WEEKDAYS: UiWeekday[] = [2, 3, 4, 5, 6, 7, 8];

export interface WorkShiftRangeFormValues {
  rootOrganizationId: string;
  dateFrom: string;
  dateTo: string;
  selectedWeekdays: UiWeekday[];
  workShiftId: string;
  repeatEveryWeeks: number;
  userIds: string[];
}

export type WorkShiftSummaryValues = Omit<
  WorkShiftRangeFormValues,
  'rootOrganizationId'
>;

export interface WorkShiftSummary {
  includedDays: number;
  selectedUsers: number;
  totalAssignments: number;
}

export interface CalendarDay {
  date: string;
  dayNumber: number;
  isCurrentMonth: boolean;
  isSaturday: boolean;
  isSunday: boolean;
  isToday: boolean;
  uiWeekday: UiWeekday;
}

export function getMonthDateRange(month: string): {
  dateFrom: string;
  dateTo: string;
} {
  const targetMonth = dayjs(`${month}-01`);

  return {
    dateFrom: targetMonth.startOf('month').format('YYYY-MM-DD'),
    dateTo: targetMonth.endOf('month').format('YYYY-MM-DD'),
  };
}

export function buildMonthCalendarGrid(month: string): CalendarDay[] {
  const firstOfMonth = dayjs(`${month}-01`);
  const firstDayOfWeek = firstOfMonth.day(); // 0 is Sunday, 1 is Monday
  const leadingDays = firstDayOfWeek === 0 ? 6 : firstDayOfWeek - 1;
  const startDate = firstOfMonth.subtract(leadingDays, 'day');

  const lastOfMonth = firstOfMonth.endOf('month');
  const lastDayOfWeek = lastOfMonth.day();
  const trailingDays = lastDayOfWeek === 0 ? 0 : 7 - lastDayOfWeek;
  const endDate = lastOfMonth.add(trailingDays, 'day');

  const days: CalendarDay[] = [];
  const todayStr = dayjs().format('YYYY-MM-DD');
  let current = startDate;

  while (current.isBefore(endDate) || current.isSame(endDate, 'day')) {
    const dateStr = current.format('YYYY-MM-DD');
    const dow = current.day();
    days.push({
      date: dateStr,
      dayNumber: current.date(),
      isCurrentMonth: current.format('YYYY-MM') === month,
      isSaturday: dow === 6,
      isSunday: dow === 0,
      isToday: dateStr === todayStr,
      uiWeekday: (dow === 0 ? 8 : dow + 1) as UiWeekday,
    });
    current = current.add(1, 'day');
  }

  return days;
}

export function formatShiftTime(value: string, timeZone?: string): string {
  if (!value) {
    return '';
  }

  return new Intl.DateTimeFormat('en-GB', {
    hour: '2-digit',
    hourCycle: 'h23',
    minute: '2-digit',
    timeZone: timeZone || 'Asia/Ho_Chi_Minh',
  }).format(new Date(value));
}

export function getUiWeekday(date: Dayjs): UiWeekday {
  const weekday = date.day();

  return (weekday === 0 ? 8 : weekday + 1) as UiWeekday;
}

export function listDaysInRange(dateFrom: string, dateTo: string): string[] {
  const startDate = dayjs(dateFrom).startOf('day');
  const endDate = dayjs(dateTo).startOf('day');
  const days: string[] = [];
  let currentDate = startDate;

  while (currentDate.isBefore(endDate) || currentDate.isSame(endDate, 'day')) {
    days.push(currentDate.format('YYYY-MM-DD'));
    currentDate = currentDate.add(1, 'day');
  }

  return days;
}

export function getIncludedWorkDates(
  dateFrom: string,
  dateTo: string,
  selectedWeekdays: UiWeekday[],
  repeatEveryWeeks = 1,
): string[] {
  const start = dayjs(dateFrom);
  const anchor = start
    .subtract(start.day() === 0 ? 6 : start.day() - 1, 'day')
    .startOf('day');
  return listDaysInRange(dateFrom, dateTo).filter((date) => {
    const weekday = getUiWeekday(dayjs(date));

    return (
      selectedWeekdays.includes(weekday) &&
      Math.floor(dayjs(date).diff(anchor, 'day') / 7) % repeatEveryWeeks === 0
    );
  });
}

export function buildWorkShiftRangePayload(
  values: WorkShiftRangeFormValues,
): WorkUserShiftRangePayload {
  return {
    root_organization_id: values.rootOrganizationId,
    date_from: values.dateFrom,
    date_to: values.dateTo,
    repeat_every_weeks: values.repeatEveryWeeks,
    selected_weekdays: values.selectedWeekdays,
    work_shift_id: values.workShiftId,
    user_ids: values.userIds,
  };
}

export function filterWorkShiftAssignableUsers(
  users: UserTreeSelectionUser[],
): UserTreeSelectionUser[] {
  return users.filter((user) => user.deleted_at === null);
}

export function resolveWorkShiftRootOrganizationId(
  users: UserTreeSelectionUser[],
  selectedUserIds: string[],
): null | string {
  const selectedUsers = users.filter((user) =>
    selectedUserIds.includes(user.id),
  );
  const firstUser = selectedUsers[0];
  if (
    firstUser === undefined ||
    selectedUsers.length !== selectedUserIds.length
  )
    return null;
  const rootOrganizationId = getOrganizationRootId(firstUser.organization);
  return selectedUsers.every(
    (user) => getOrganizationRootId(user.organization) === rootOrganizationId,
  )
    ? rootOrganizationId
    : null;
}

export function summarizeWorkShiftRange(
  values: WorkShiftSummaryValues,
): WorkShiftSummary {
  const includedDays = getIncludedWorkDates(
    values.dateFrom,
    values.dateTo,
    values.selectedWeekdays,
    values.repeatEveryWeeks,
  ).length;

  return {
    includedDays,
    selectedUsers: values.userIds.length,
    totalAssignments: includedDays * values.userIds.length,
  };
}

export function buildShiftLookup(
  shifts: WorkUserShift[],
): Map<string, WorkUserShift> {
  return new Map(
    shifts.map((shift) => [
      `${shift.user_id}:${shift.work_date.slice(0, 10)}`,
      shift,
    ]),
  );
}
