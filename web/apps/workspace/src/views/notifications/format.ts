export const VIETNAM_TIME_ZONE = 'Asia/Ho_Chi_Minh';

const vietnamDateTimeFormatter = new Intl.DateTimeFormat('vi-VN', {
  day: '2-digit',
  hour: '2-digit',
  hour12: false,
  minute: '2-digit',
  month: '2-digit',
  timeZone: VIETNAM_TIME_ZONE,
  year: 'numeric',
});

export function formatNotificationDateTime(value: string): string {
  return vietnamDateTimeFormatter.format(new Date(value));
}
