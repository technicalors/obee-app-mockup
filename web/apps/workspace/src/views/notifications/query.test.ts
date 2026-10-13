import { describe, expect, it } from 'vitest';

import { createNotificationIndexQuery } from './query';

describe('createNotificationIndexQuery', () => {
  it('passes pagination through and omits the read filter for all notifications', () => {
    expect(
      createNotificationIndexQuery({ page: 2, per_page: 20 }, 'all'),
    ).toEqual({ page: 2, per_page: 20 });
  });

  it.each([
    ['read', 1],
    ['unread', 0],
  ] as const)('maps the %s state to is_read=%s', (readState, isRead) => {
    expect(
      createNotificationIndexQuery({ page: 1, per_page: 10 }, readState),
    ).toEqual({
      is_read: isRead,
      page: 1,
      per_page: 10,
    });
  });
});
