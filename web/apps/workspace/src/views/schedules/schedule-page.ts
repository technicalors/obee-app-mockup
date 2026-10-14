import type { Dayjs } from 'dayjs';

import type { Company, Department, User } from '#/api/contracts';
import type { Schedule, ScheduleEventWritePayload } from '#/api/schedules';

export interface ScheduleAuthoringDraft {
  company_name: null;
  company_phone_number: null;
  end_date: string;
  end_time: null | string;
  has_reminder: boolean;
  is_general: boolean;
  mode: 'create' | 'edit' | 'reuse';
  note: null | string;
  observers: string[];
  participants: string[];
  physical_address: null | string;
  privacy: Schedule['event']['privacy'];
  remind_range: Schedule['event']['remind_range'];
  remind_value: Schedule['event']['remind_value'];
  repeat_end_time: Schedule['event']['repeat_end_time'];
  repeat_pattern: Schedule['event']['repeat_pattern'];
  repeat_start_time: Schedule['event']['repeat_start_time'];
  repeat_type: Schedule['event']['repeat_type'];
  schedule_type: Schedule['event']['schedule_type'];
  source_event_id: string;
  start_date: string;
  start_time: null | string;
  title: string;
  type: Schedule['event']['type'];
}

export interface ScheduleAuthoringOption {
  avatar?: null | string;
  label: string;
  value: number | string;
}

export interface ScheduleUserTreeOption {
  children?: ScheduleUserTreeOption[];
  key: string;
  label: string;
  selectable?: boolean;
  value: string;
}

export interface ScheduleMonthGridCell {
  date: string;
  dayNumber: number;
  inCurrentMonth: boolean;
  isToday: boolean;
  schedules: Schedule[];
}

export interface ScheduleWeekSegment {
  columnSpan: number;
  endDate: string;
  level: number;
  schedule: Schedule;
  startColumn: number;
  startDate: string;
}

const AUTHORING_TIME_ZONE = 'Asia/Ho_Chi_Minh';

export function formatMonthValue(value: Date): string {
  return `${value.getUTCFullYear()}-${String(value.getUTCMonth() + 1).padStart(2, '0')}`;
}

export function parseMonthValue(value: string): Date {
  const { month, year } = parseMonthParts(value);

  return new Date(Date.UTC(year, month - 1, 1));
}

export function parseMonthParts(value: string): {
  month: number;
  year: number;
} {
  const [yearString = '', monthString = ''] = value.split('-');
  const month = Number(monthString);
  const year = Number(yearString);

  if (!Number.isInteger(year) || !Number.isInteger(month)) {
    throw new TypeError('Invalid month value.');
  }

  return { month, year };
}

export function createScheduleDraftForDate(
  date: string,
  currentUserId: null | string,
): ScheduleAuthoringDraft {
  return {
    company_name: null,
    company_phone_number: null,
    end_date: date,
    end_time: '17:30',
    has_reminder: false,
    is_general: false,
    mode: 'create',
    note: null,
    observers: [],
    participants: currentUserId === null ? [] : [currentUserId],
    physical_address: null,
    privacy: 'public',
    remind_range: null,
    remind_value: null,
    repeat_end_time: null,
    repeat_pattern: null,
    repeat_start_time: null,
    repeat_type: null,
    schedule_type: 'ordinary',
    source_event_id: '',
    start_date: date,
    start_time: '08:00',
    title: '',
    type: 'meeting',
  };
}

export function createDraftFromEvent(
  schedule: Schedule,
  mode: 'edit' | 'reuse',
): ScheduleAuthoringDraft {
  return {
    company_name: null,
    company_phone_number: null,
    end_date: formatAuthoringDate(schedule.event.end_date),
    end_time: getDraftTimeValue(
      schedule.event.repeat_end_time,
      schedule.event.end_date,
    ),
    has_reminder: schedule.event.has_reminder,
    is_general: schedule.event.is_general,
    mode,
    note: schedule.event.note,
    observers: schedule.event.observers.map(({ id }) => id),
    participants: schedule.event.participants.map(({ id }) => id),
    physical_address: schedule.event.physical_address,
    privacy: schedule.event.privacy,
    remind_range: schedule.event.remind_range,
    remind_value: schedule.event.remind_value,
    repeat_end_time: schedule.event.repeat_end_time,
    repeat_pattern: schedule.event.repeat_pattern,
    repeat_start_time: schedule.event.repeat_start_time,
    repeat_type: schedule.event.repeat_type,
    schedule_type: schedule.event.schedule_type,
    source_event_id: schedule.event.id,
    start_date: formatAuthoringDate(schedule.event.start_date),
    start_time: getDraftTimeValue(
      schedule.event.repeat_start_time,
      schedule.event.start_date,
    ),
    title: schedule.event.title,
    type: schedule.event.type,
  };
}

export function buildAuthoringPayload(
  draft: ScheduleAuthoringDraft,
): ScheduleEventWritePayload {
  const usesTimeRange = draft.schedule_type !== 'multiple_days';

  return {
    company_name: draft.company_name,
    company_phone_number: draft.company_phone_number,
    end_date: buildAuthoringDateTime(
      draft.end_date,
      draft.end_time,
      usesTimeRange,
    ),
    has_reminder: draft.has_reminder,
    is_general: draft.is_general,
    note: draft.note,
    observers: draft.observers,
    participants: draft.participants,
    physical_address: draft.physical_address,
    privacy: draft.privacy,
    remind_range: draft.has_reminder ? draft.remind_range : null,
    remind_value: draft.has_reminder ? draft.remind_value : null,
    repeat_end_time:
      draft.schedule_type === 'repeat' ? draft.end_time : draft.repeat_end_time,
    repeat_pattern: draft.repeat_pattern,
    repeat_start_time:
      draft.schedule_type === 'repeat'
        ? draft.start_time
        : draft.repeat_start_time,
    repeat_type: draft.repeat_type,
    schedule_type: draft.schedule_type,
    start_date: buildAuthoringDateTime(
      draft.start_date,
      draft.start_time,
      usesTimeRange,
    ),
    title: draft.title,
    type: draft.type,
  };
}

export function getAuthoringPayloadValue(
  value: null | number[] | string,
): string {
  if (value === null) {
    return 'null';
  }

  return Array.isArray(value) ? JSON.stringify(value) : value;
}

export function formatAuthoringDate(value: Dayjs | string): string {
  return typeof value === 'string'
    ? formatDayKeyInTimeZone(value, AUTHORING_TIME_ZONE)
    : value.format('YYYY-MM-DD');
}

export function formatAuthoringTime(value: null | string): string {
  return value === null ? '' : value.slice(0, 5);
}

export function getAuthoringRepeatPatternValues(
  draft: ScheduleAuthoringDraft,
): number[] {
  return draft.repeat_pattern ?? [];
}

export function getMonthGridDateRange(monthDate: Date): {
  end: string;
  start: string;
} {
  const monthStart = new Date(
    Date.UTC(monthDate.getUTCFullYear(), monthDate.getUTCMonth(), 1),
  );
  const monthEnd = new Date(
    Date.UTC(monthDate.getUTCFullYear(), monthDate.getUTCMonth() + 1, 0),
  );
  const gridStart = new Date(monthStart);
  gridStart.setUTCDate(
    gridStart.getUTCDate() - ((gridStart.getUTCDay() + 6) % 7),
  );
  const gridEnd = new Date(gridStart);
  gridEnd.setUTCDate(gridStart.getUTCDate() + 34);

  if (gridEnd < monthEnd) {
    gridEnd.setTime(gridStart.getTime());
    gridEnd.setUTCDate(gridStart.getUTCDate() + 41);
  }

  return {
    end: formatDayKey(gridEnd),
    start: formatDayKey(gridStart),
  };
}

export function buildDepartmentUserTreeOptions(
  users: User[],
): ScheduleUserTreeOption[] {
  const departmentsById = new Map<string, Department>();
  const departmentIdsByParentId = new Map<null | string, string[]>();
  const usersByDepartmentId = new Map<string, User[]>();
  const usersWithoutDepartment: User[] = [];

  for (const user of users) {
    if (user.departments.length === 0) {
      usersWithoutDepartment.push(user);
      continue;
    }

    for (const department of user.departments) {
      let hierarchyDepartment: Department | null | undefined = department;

      while (
        hierarchyDepartment !== null &&
        hierarchyDepartment !== undefined
      ) {
        departmentsById.set(hierarchyDepartment.id, hierarchyDepartment);
        hierarchyDepartment = hierarchyDepartment.parent;
      }

      const departmentUsers = usersByDepartmentId.get(department.id);

      if (departmentUsers === undefined) {
        usersByDepartmentId.set(department.id, [user]);
        continue;
      }

      departmentUsers.push(user);
    }
  }

  for (const department of departmentsById.values()) {
    const siblingDepartmentIds =
      departmentIdsByParentId.get(department.parent_id) ?? [];

    if (siblingDepartmentIds.includes(department.id)) {
      continue;
    }

    departmentIdsByParentId.set(
      department.parent_id,
      [...siblingDepartmentIds, department.id].toSorted((left, right) => {
        const leftDepartment = departmentsById.get(left);
        const rightDepartment = departmentsById.get(right);

        if (leftDepartment === undefined || rightDepartment === undefined) {
          return left.localeCompare(right);
        }
        return leftDepartment.name.localeCompare(rightDepartment.name);
      }),
    );
  }

  const rootChildren = [
    ...buildDepartmentTreeOptions(
      null,
      departmentIdsByParentId,
      departmentsById,
      usersByDepartmentId,
    ),
    ...buildUserTreeLeafOptions(usersWithoutDepartment),
  ];

  const company = getScheduleUserTreeCompany(users, departmentsById);

  if (company === null) {
    return rootChildren;
  }

  return [
    {
      children: rootChildren,
      key: `company-${company.id}`,
      label: company.name,
      selectable: false,
      value: `company-${company.id}`,
    },
  ];
}

function buildDepartmentTreeOptions(
  parentDepartmentId: null | string,
  departmentIdsByParentId: Map<null | string, string[]>,
  departmentsById: Map<string, Department>,
  usersByDepartmentId: Map<string, User[]>,
): ScheduleUserTreeOption[] {
  return (departmentIdsByParentId.get(parentDepartmentId) ?? []).flatMap(
    (departmentId) => {
      const department = departmentsById.get(departmentId);

      if (department === undefined) {
        return [];
      }

      return [
        {
          children: [
            ...buildDepartmentTreeOptions(
              department.id,
              departmentIdsByParentId,
              departmentsById,
              usersByDepartmentId,
            ),
            ...buildUserTreeLeafOptions(
              usersByDepartmentId.get(department.id) ?? [],
            ),
          ],
          key: `department-${department.id}`,
          label: department.name,
          selectable: false,
          value: `department-${department.id}`,
        },
      ];
    },
  );
}

function buildUserTreeLeafOptions(users: User[]): ScheduleUserTreeOption[] {
  return [...users]
    .toSorted((left, right) => left.name.localeCompare(right.name))
    .map((user) => ({
      key: user.id,
      label: user.name,
      value: user.id,
    }));
}

function getScheduleUserTreeCompany(
  users: User[],
  departmentsById: Map<string, Department>,
): Company | null {
  const companyFromUsers = users.find((user) => user.company !== null)?.company;

  if (companyFromUsers !== undefined) {
    return companyFromUsers;
  }

  return (
    [...departmentsById.values()].find(
      (department) => department.company !== null,
    )?.company ?? null
  );
}

export function buildMonthGrid(
  monthDate: Date,
  monthSchedules: Schedule[],
  today: string,
  timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone,
): ScheduleMonthGridCell[] {
  const { end: gridEndKey, start: gridStartKey } =
    getMonthGridDateRange(monthDate);
  const gridStart = parseDayKey(gridStartKey);
  const gridEnd = parseDayKey(gridEndKey);
  const gridLength =
    Math.floor((gridEnd.getTime() - gridStart.getTime()) / 86_400_000) + 1;
  const schedulesByDay = new Map<string, Schedule[]>();

  for (const schedule of monthSchedules) {
    const scheduleStartKey = formatDayKeyInTimeZone(schedule.start, timeZone);
    const scheduleEndKey = formatDayKeyInTimeZone(schedule.end, timeZone);
    let visibleStartKey = scheduleStartKey;
    let visibleEndKey = scheduleEndKey;

    if (gridStartKey > visibleStartKey) {
      visibleStartKey = gridStartKey;
    }

    if (gridEndKey < visibleEndKey) {
      visibleEndKey = gridEndKey;
    }

    if (visibleStartKey > visibleEndKey) {
      continue;
    }

    const visibleStart = parseDayKey(visibleStartKey);
    const visibleEnd = parseDayKey(visibleEndKey);
    const visibleDayCount =
      Math.floor((visibleEnd.getTime() - visibleStart.getTime()) / 86_400_000) +
      1;

    for (let dayOffset = 0; dayOffset < visibleDayCount; dayOffset += 1) {
      const cursor = new Date(visibleStart);
      cursor.setUTCDate(visibleStart.getUTCDate() + dayOffset);
      const key = formatDayKey(cursor);
      const currentSchedules = schedulesByDay.get(key);

      if (currentSchedules === undefined) {
        schedulesByDay.set(key, [schedule]);
      } else {
        currentSchedules.push(schedule);
      }
    }
  }

  return Array.from({ length: gridLength }, (_, index) => {
    const date = new Date(gridStart);
    date.setUTCDate(gridStart.getUTCDate() + index);
    const key = formatDayKey(date);
    const cellSchedules = schedulesByDay.get(key) ?? [];

    cellSchedules.sort(compareSchedules);

    return {
      date: key,
      dayNumber: date.getUTCDate(),
      inCurrentMonth: date.getUTCMonth() === monthDate.getUTCMonth(),
      isToday: key === today,
      schedules: cellSchedules,
    };
  });
}

export function getScheduleShape(
  schedule: Schedule,
): 'multi-day' | 'one-day' | 'repeat' {
  if (schedule.event.schedule_type === 'repeat') {
    return 'repeat';
  }

  if (schedule.event.schedule_type === 'multiple_days') {
    return 'multi-day';
  }

  return 'one-day';
}

export function getScheduleShapeLabel(schedule: Schedule): '1D' | 'MD' | 'RP' {
  switch (getScheduleShape(schedule)) {
    case 'multi-day': {
      return 'MD';
    }
    case 'repeat': {
      return 'RP';
    }
    default: {
      return '1D';
    }
  }
}

export function formatScheduleTileMeta(
  schedule: Schedule,
  timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone,
): string {
  if (getScheduleShape(schedule) === 'multi-day') {
    const { endDate, startDate } = getScheduleVisibleDateRange(
      schedule,
      timeZone,
    );

    return `${formatDayMonth(startDate)} - ${formatDayMonth(endDate)}`;
  }

  const startTime = formatTimeInTimeZone(schedule.start, timeZone);
  const endTime = formatTimeInTimeZone(schedule.end, timeZone);

  return startTime === endTime ? startTime : `${startTime} - ${endTime}`;
}

export function buildWeekSegments(
  cells: ScheduleMonthGridCell[],
  timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone,
): ScheduleWeekSegment[] {
  const weekStart = cells[0]?.date;
  const weekEnd = cells.at(-1)?.date;

  if (weekStart === undefined || weekEnd === undefined) {
    return [];
  }

  const uniqueSchedules = new Map<string, Schedule>();

  for (const cell of cells) {
    for (const schedule of cell.schedules) {
      if (getScheduleShape(schedule) === 'multi-day') {
        uniqueSchedules.set(schedule.id, schedule);
      }
    }
  }

  const occupiedColumns: number[] = [];

  return [...uniqueSchedules.values()]
    .map((schedule) => {
      const { endDate, startDate } = getScheduleVisibleDateRange(
        schedule,
        timeZone,
      );
      let visibleStartDate = startDate;
      let visibleEndDate = endDate;

      if (weekStart > visibleStartDate) {
        visibleStartDate = weekStart;
      }

      if (weekEnd < visibleEndDate) {
        visibleEndDate = weekEnd;
      }

      if (visibleStartDate > visibleEndDate) {
        return null;
      }

      const startIndex = cells.findIndex(
        ({ date }) => date === visibleStartDate,
      );
      const endIndex = cells.findIndex(({ date }) => date === visibleEndDate);

      if (startIndex === -1 || endIndex === -1) {
        return null;
      }

      let level = 0;

      while ((occupiedColumns[level] ?? -1) >= startIndex) {
        level += 1;
      }

      occupiedColumns[level] = endIndex;

      return {
        columnSpan: endIndex - startIndex + 1,
        endDate: visibleEndDate,
        level,
        schedule,
        startColumn: startIndex + 1,
        startDate: visibleStartDate,
      };
    })
    .filter((segment): segment is ScheduleWeekSegment => segment !== null)
    .toSorted(
      (left, right) =>
        left.level - right.level ||
        left.startColumn - right.startColumn ||
        compareSchedules(left.schedule, right.schedule),
    );
}

const scheduleTypeClasses = {
  business_trip: 'border-[#b99976] bg-[#b99976]',
  holiday: 'border-[#b592d8] bg-[#b592d8]',
  interview: 'border-[#ef9201] bg-[#ef9201]',
  meeting: 'border-[#f194a7] bg-[#f194a7]',
  meetup: 'border-[#f44848] bg-[#f44848]',
  seminar: 'border-[#57b3ed] bg-[#57b3ed]',
  training: 'border-[#3182dc] bg-[#3182dc]',
  default: 'border-[#6b7280] bg-[#6b7280]',
};

export function getScheduleTypeClass(schedule: Schedule): string {
  const generalClasses = 'border text-white';
  const targetColorClass =
    scheduleTypeClasses[schedule.event.type] ?? scheduleTypeClasses.default;

  return `${generalClasses} ${targetColorClass}`;
}

export function getScheduleCardClass(schedule: Schedule): string {
  switch (getScheduleShape(schedule)) {
    case 'multi-day': {
      const generalClasses = 'rounded-md border text-white';
      const targetColorClass =
        scheduleTypeClasses[schedule.event.type] ?? scheduleTypeClasses.default;
      return `${generalClasses} ${targetColorClass}`;
    }

    case 'repeat': {
      return 'rounded-md border border-dashed border-black/30 bg-accent/70 text-foreground';
    }
    default: {
      return 'rounded-md border border-transparent bg-accent/70 text-foreground';
    }
  }
}

export function formatDayKey(value: Date): string {
  return `${value.getUTCFullYear()}-${String(value.getUTCMonth() + 1).padStart(2, '0')}-${String(value.getUTCDate()).padStart(2, '0')}`;
}

export function parseDayKey(value: string): Date {
  const [yearString = '', monthString = '', dayString = ''] = value.split('-');
  const day = Number(dayString);
  const month = Number(monthString);
  const year = Number(yearString);

  if (
    !Number.isInteger(year) ||
    !Number.isInteger(month) ||
    !Number.isInteger(day)
  ) {
    throw new TypeError('Invalid day key.');
  }

  return new Date(Date.UTC(year, month - 1, day));
}

export function formatDayKeyInTimeZone(value: string, timeZone: string): string {
  const formatter = new Intl.DateTimeFormat('en-CA', {
    day: '2-digit',
    month: '2-digit',
    timeZone,
    year: 'numeric',
  });
  const parts = formatter.formatToParts(new Date(value));
  const year = parts.find(({ type }) => type === 'year');
  const month = parts.find(({ type }) => type === 'month');
  const day = parts.find(({ type }) => type === 'day');

  if (year === undefined || month === undefined || day === undefined) {
    throw new TypeError('Invalid schedule day.');
  }

  return `${year.value}-${month.value}-${day.value}`;
}

function getScheduleVisibleDateRange(
  schedule: Schedule,
  timeZone: string,
): {
  endDate: string;
  startDate: string;
} {
  return {
    endDate: formatDayKeyInTimeZone(schedule.end, timeZone),
    startDate: formatDayKeyInTimeZone(schedule.start, timeZone),
  };
}

function formatDayMonth(value: string): string {
  return `${value.slice(8, 10)}/${value.slice(5, 7)}`;
}

function formatTimeInTimeZone(value: string, timeZone: string): string {
  const formatter = new Intl.DateTimeFormat('en-GB', {
    hour: '2-digit',
    hour12: false,
    minute: '2-digit',
    timeZone,
  });

  return formatter.format(new Date(value));
}

function compareSchedules(left: Schedule, right: Schedule): number {
  return (
    scheduleShapeRank(left) - scheduleShapeRank(right) ||
    left.start.localeCompare(right.start) ||
    left.event.title.localeCompare(right.event.title)
  );
}

function scheduleShapeRank(schedule: Schedule): number {
  switch (getScheduleShape(schedule)) {
    case 'multi-day': {
      return 0;
    }
    case 'repeat': {
      return 1;
    }
    default: {
      return 2;
    }
  }
}

function buildAuthoringDateTime(
  date: string,
  time: null | string,
  usesTimeRange: boolean,
): string {
  if (!usesTimeRange || time === null) {
    return date;
  }

  return `${date}T${time}`;
}

export function getDraftTimeValue(
  repeatTime: null | string,
  dateTime: string,
): null | string {
  if (repeatTime !== null) {
    return repeatTime.slice(0, 5);
  }

  return formatTimeInTimeZone(dateTime, AUTHORING_TIME_ZONE);
}

export function getWeekDates(anchorDate: string): string[] {
  const d = parseDayKey(anchorDate);
  const dayOfWeek = d.getUTCDay();
  const mondayOffset = dayOfWeek === 0 ? -6 : 1 - dayOfWeek;
  const monday = new Date(d);
  monday.setUTCDate(d.getUTCDate() + mondayOffset);

  return Array.from({ length: 7 }, (_, i) => {
    const date = new Date(monday);
    date.setUTCDate(monday.getUTCDate() + i);
    return formatDayKey(date);
  });
}

export function shiftWeek(anchorDate: string, offset: number): string {
  const d = parseDayKey(anchorDate);
  d.setUTCDate(d.getUTCDate() + offset * 7);
  return formatDayKey(d);
}

export function shiftDay(anchorDate: string, offset: number): string {
  const d = parseDayKey(anchorDate);
  d.setUTCDate(d.getUTCDate() + offset);
  return formatDayKey(d);
}

export function getWeekDateRange(dates: string[]): {
  end: string;
  start: string;
} {
  const first = dates[0];
  const last = dates[dates.length - 1];
  if (first === undefined || last === undefined) {
    throw new Error('Empty dates array.');
  }
  return { end: last, start: first };
}

export function formatWeekRangeLabel(
  dates: string[],
  locale: string,
): string {
  const first = dates[0];
  const last = dates[dates.length - 1];
  if (first === undefined || last === undefined) {
    return '';
  }

  const startDate = parseDayKey(first);
  const endDate = parseDayKey(last);

  const formatter = new Intl.DateTimeFormat(locale, {
    day: 'numeric',
    month: 'short',
  });
  const yearFormatter = new Intl.DateTimeFormat(locale, {
    year: 'numeric',
  });

  return `${formatter.format(startDate)} – ${formatter.format(endDate)}, ${yearFormatter.format(endDate)}`;
}

export function formatDayLabel(
  date: string,
  locale: string,
): string {
  const d = parseDayKey(date);
  const formatter = new Intl.DateTimeFormat(locale, {
    weekday: 'long',
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  });

  const formatted = formatter.format(d);
  return formatted.charAt(0).toUpperCase() + formatted.slice(1);
}

export function shiftYear(year: number, offset: number): number {
  return year + offset;
}

export function formatYearLabel(year: number, locale: string): string {
  if (locale.startsWith('vi')) {
    return `Năm ${year}`;
  }
  return String(year);
}

export function getYearDateRange(year: number): {
  end: string;
  start: string;
} {
  return {
    end: `${year}-12-31`,
    start: `${year}-01-01`,
  };
}

export interface YearDayCell {
  date: string;
  dayNumber: number;
  dayOfWeek: number;
  isWeekend: boolean;
}

export interface YearMonthData {
  days: YearDayCell[];
  leadingEmptyDays: number;
  monthIndex: number;
  monthLabel: string;
  monthNumber: number;
  monthValue: string;
  year: number;
}

export function buildYearGrid(year: number, locale: string): YearMonthData[] {
  const monthFormatter = new Intl.DateTimeFormat(locale, { month: 'long' });

  return Array.from({ length: 12 }, (_, monthIndex) => {
    const monthNumber = monthIndex + 1;
    const monthPad = String(monthNumber).padStart(2, '0');
    const monthValue = `${year}-${monthPad}`;
    const firstDay = new Date(Date.UTC(year, monthIndex, 1));
    const rawDayOfWeek = firstDay.getUTCDay();
    // Monday-indexed: 0 = Mon, ..., 6 = Sun
    const leadingEmptyDays = rawDayOfWeek === 0 ? 6 : rawDayOfWeek - 1;

    const daysCount = new Date(Date.UTC(year, monthIndex + 1, 0)).getUTCDate();
    const monthLabel = monthFormatter.format(firstDay);

    const days: YearDayCell[] = Array.from({ length: daysCount }, (_, dayIdx) => {
      const dayNumber = dayIdx + 1;
      const dayPad = String(dayNumber).padStart(2, '0');
      const date = `${monthValue}-${dayPad}`;
      const dayDate = new Date(Date.UTC(year, monthIndex, dayNumber));
      const dow = dayDate.getUTCDay();
      const mondayIndexedDow = dow === 0 ? 6 : dow - 1;

      return {
        date,
        dayNumber,
        dayOfWeek: mondayIndexedDow,
        isWeekend: dow === 0 || dow === 6,
      };
    });

    return {
      days,
      leadingEmptyDays,
      monthIndex,
      monthLabel,
      monthNumber,
      monthValue,
      year,
    };
  });
}

