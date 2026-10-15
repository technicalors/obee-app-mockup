import type {
  AttendanceLocation,
  AttendanceRangeSummary,
} from '#/api/contracts';

export interface Coordinates {
  latitude: number;
  longitude: number;
}

export interface AttendanceEligibility {
  distance_meters: null | number;
  eligible: boolean;
  ip_matched: boolean;
  location_matched: boolean;
}

export interface AttendanceCalendarCell {
  date: string;
  dayNumber: number;
  inMonth: boolean;
  isFuture: boolean;
  status: 'deficient' | 'empty' | 'leave' | 'punched';
  workHours: string;
}

export function haversineMeters(from: Coordinates, to: Coordinates): number {
  const earthRadius = 6_371_000;
  const latitudeDelta = degreesToRadians(to.latitude - from.latitude);
  const longitudeDelta = degreesToRadians(to.longitude - from.longitude);
  const haversine =
    Math.sin(latitudeDelta / 2) ** 2 +
    Math.cos(degreesToRadians(from.latitude)) *
      Math.cos(degreesToRadians(to.latitude)) *
      Math.sin(longitudeDelta / 2) ** 2;

  return (
    2 * earthRadius * Math.asin(Math.sqrt(Math.min(1, Math.max(0, haversine))))
  );
}

export function evaluateAttendanceEligibility(
  location: AttendanceLocation,
  currentPosition: Coordinates | null,
  currentIpAddress: null | string,
): AttendanceEligibility {
  const distance =
    currentPosition === null
      ? null
      : haversineMeters(currentPosition, {
          latitude: location.latitude,
          longitude: location.longitude,
        });
  const locationMatched =
    distance !== null && distance <= location.radius_meters;
  const ipMatched =
    currentIpAddress !== null &&
    location.ips.some((ip) => ip.ip_address === currentIpAddress);

  switch (location.validation_mode) {
    case 'both': {
      return {
        distance_meters: distance,
        eligible: locationMatched && ipMatched,
        ip_matched: ipMatched,
        location_matched: locationMatched,
      };
    }
    case 'either': {
      return {
        distance_meters: distance,
        eligible: locationMatched || ipMatched,
        ip_matched: ipMatched,
        location_matched: locationMatched,
      };
    }
    case 'ip': {
      return {
        distance_meters: distance,
        eligible: ipMatched,
        ip_matched: ipMatched,
        location_matched: locationMatched,
      };
    }
    case 'location': {
      return {
        distance_meters: distance,
        eligible: locationMatched,
        ip_matched: ipMatched,
        location_matched: locationMatched,
      };
    }
  }
}

export function buildAttendanceCalendarCells(
  month: string,
  summaries: AttendanceRangeSummary[],
  today = getTodayDate(),
): AttendanceCalendarCell[] {
  const { monthNumber, year } = parseMonthValue(month);
  const firstDay = new Date(year, monthNumber - 1, 1);
  const firstWeekday = mondayWeekdayIndex(firstDay);
  const cells: AttendanceCalendarCell[] = [];
  const summariesByDate = new Map(
    summaries.map((summary) => [summary.date, summary]),
  );
  const previousMonthLastDay = new Date(year, monthNumber - 1, 0).getDate();

  for (let index = firstWeekday - 1; index >= 0; index--) {
    const dayNumber = previousMonthLastDay - index;
    cells.push({
      date: formatDate(new Date(year, monthNumber - 2, dayNumber)),
      dayNumber,
      inMonth: false,
      isFuture: false,
      status: 'empty',
      workHours: '',
    });
  }

  const currentMonthLastDay = new Date(year, monthNumber, 0).getDate();
  for (let dayNumber = 1; dayNumber <= currentMonthLastDay; dayNumber++) {
    const date = formatDate(new Date(year, monthNumber - 1, dayNumber));
    const summary = summariesByDate.get(date);

    cells.push({
      date,
      dayNumber,
      inMonth: true,
      isFuture: date > today,
      status: getAttendanceSummaryStatus(summary),
      workHours:
        summary === undefined
          ? '0:00'
          : formatWorkSeconds(summary.total_work_seconds),
    });
  }

  const totalCells = Math.ceil(cells.length / 7) * 7;
  const nextMonthPadding = totalCells - cells.length;
  for (let dayNumber = 1; dayNumber <= nextMonthPadding; dayNumber++) {
    cells.push({
      date: formatDate(new Date(year, monthNumber, dayNumber)),
      dayNumber,
      inMonth: false,
      isFuture: true,
      status: 'empty',
      workHours: '',
    });
  }

  return cells;
}

export function formatWorkSeconds(totalSeconds: number): string {
  const totalMinutes = Math.floor(totalSeconds / 60);
  const hours = Math.floor(totalMinutes / 60);
  const minutes = totalMinutes % 60;

  return `${hours}:${minutes.toString().padStart(2, '0')}`;
}

export function getAttendanceSummaryStatus(
  summary: AttendanceRangeSummary | undefined,
): 'deficient' | 'empty' | 'leave' | 'punched' {
  if (summary === undefined) {
    return 'empty';
  }

  if (summary.logs_count >= 2) {
    return 'punched';
  }

  if (summary.logs_count === 1) {
    return 'deficient';
  }

  if (summary.on_leave) {
    return 'leave';
  }

  return 'empty';
}

export function getAttendanceCellSurfaceClasses(
  cell: Pick<AttendanceCalendarCell, 'inMonth' | 'isFuture' | 'status'>,
  selected = false,
): string[] {
  if (!cell.inMonth || cell.isFuture) {
    return [
      'bg-muted/10',
      'dark:bg-muted/20',
      'text-muted-foreground/35',
      'dark:text-muted-foreground/50',
      'pointer-events-none',
    ];
  }

  const classes = ['cursor-pointer'];

  switch (cell.status) {
    case 'deficient': {
      classes.push(
        'bg-amber-500/10',
        'dark:bg-amber-500/18',
        'dark:ring-1',
        'dark:ring-inset',
        'dark:ring-amber-500/35',
        'hover:bg-amber-500/15',
        'dark:hover:bg-amber-500/26',
      );
      break;
    }
    case 'empty': {
      classes.push(
        'bg-rose-500/8',
        'dark:bg-rose-500/16',
        'dark:ring-1',
        'dark:ring-inset',
        'dark:ring-rose-500/30',
        'hover:bg-rose-500/12',
        'dark:hover:bg-rose-500/24',
      );
      break;
    }
    case 'leave': {
      classes.push(
        'bg-blue-500/10',
        'dark:bg-blue-500/18',
        'dark:ring-1',
        'dark:ring-inset',
        'dark:ring-blue-500/35',
        'hover:bg-blue-500/15',
        'dark:hover:bg-blue-500/26',
      );
      break;
    }
    case 'punched': {
      classes.push(
        'bg-emerald-500/10',
        'dark:bg-emerald-500/18',
        'dark:ring-1',
        'dark:ring-inset',
        'dark:ring-emerald-500/35',
        'hover:bg-emerald-500/15',
        'dark:hover:bg-emerald-500/26',
      );
      break;
    }
  }

  if (selected) {
    classes.push('ring-2', 'ring-primary', 'ring-inset');
  }

  return classes;
}

export function getMonthEndDate(month: string): string {
  const { monthNumber, year } = parseMonthValue(month);

  return formatDate(new Date(year, monthNumber, 0));
}

export function getMonthStartDate(date: Date): string {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(
    2,
    '0',
  )}-01`;
}

export function getTodayDate(date = new Date()): string {
  return formatDate(date);
}

export function shiftMonthValue(month: string, offset: number): string {
  const { monthNumber, year } = parseMonthValue(month);
  const targetDate = new Date(year, monthNumber - 1 + offset, 1);

  return `${targetDate.getFullYear()}-${String(
    targetDate.getMonth() + 1,
  ).padStart(2, '0')}`;
}

function degreesToRadians(value: number): number {
  return (value * Math.PI) / 180;
}

function formatDate(date: Date): string {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(
    2,
    '0',
  )}-${String(date.getDate()).padStart(2, '0')}`;
}

function parseMonthValue(month: string): { monthNumber: number; year: number } {
  return {
    monthNumber: Number(month.slice(5, 7)),
    year: Number(month.slice(0, 4)),
  };
}

function mondayWeekdayIndex(date: Date): number {
  return (date.getDay() + 6) % 7;
}
