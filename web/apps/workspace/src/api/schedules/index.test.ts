import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  createScheduleEvent,
  deleteScheduleEvent,
  getSchedule,
  getSchedules,
  joinScheduleEvent,
  leaveScheduleEvent,
  updateScheduleEvent,
} from './index';

const requestClientState = vi.hoisted(() => ({
  delete: vi.fn(),
  get: vi.fn(),
  post: vi.fn(),
  put: vi.fn(),
}));

vi.mock('#/api/request', () => ({
  requestClient: requestClientState,
}));

function makeSchedule() {
  return {
    end: '2026-06-16T10:00:00.000000Z',
    event: {
      company_name: null,
      company_phone_number: null,
      created_at: '2026-06-16T08:00:00.000000Z',
      created_by: 'user-1',
      end_date: '2026-06-16T10:00:00.000000Z',
      has_reminder: false,
      id: 'event-1',
      is_general: false,
      note: null,
      observers: [],
      participants: [],
      physical_address: null,
      privacy: 'public',
      remind_range: null,
      remind_value: null,
      repeat_end_time: null,
      repeat_pattern: null,
      repeat_start_time: null,
      repeat_type: null,
      schedule_type: 'ordinary',
      start_date: '2026-06-16T09:00:00.000000Z',
      title: 'Planning',
      type: 'meeting',
      updated_at: '2026-06-16T08:00:00.000000Z',
      updated_by: null,
    },
    event_id: 'event-1',
    id: 'schedule-1',
    one_day: true,
    remind_at: null,
    start: '2026-06-16T09:00:00.000000Z',
  };
}

describe('getSchedules', () => {
  beforeEach(() => {
    requestClientState.delete.mockReset();
    requestClientState.get.mockReset();
    requestClientState.post.mockReset();
    requestClientState.put.mockReset();
  });

  it('requests visible-range schedules through the relative schedules endpoint', async () => {
    requestClientState.get.mockResolvedValue([makeSchedule()]);

    await expect(
      getSchedules({
        end_from: '2026-06-01',
        start_to: '2026-07-05',
        visibility: 'all',
      }),
    ).resolves.toHaveLength(1);

    expect(requestClientState.get).toHaveBeenCalledWith('/schedules', {
      params: {
        end_from: '2026-06-01',
        start_to: '2026-07-05',
        visibility: 'all',
      },
    });
  }, 10_000);

  it('passes through non-default visibility values unchanged', async () => {
    requestClientState.get.mockResolvedValue([makeSchedule()]);

    await getSchedules({
      end_from: '2026-06-01',
      start_to: '2026-07-05',
      visibility: 'participated',
    });

    expect(requestClientState.get).toHaveBeenCalledWith('/schedules', {
      params: {
        end_from: '2026-06-01',
        start_to: '2026-07-05',
        visibility: 'participated',
      },
    });
  });

  it('passes creator calendar filters through the schedules query contract', async () => {
    requestClientState.get.mockResolvedValue([makeSchedule()]);

    await getSchedules({
      end_from: '2026-06-01',
      start_to: '2026-07-05',
      user_ids: 'user-1,user-2',
      visibility: 'all',
    });

    expect(requestClientState.get).toHaveBeenCalledWith('/schedules', {
      params: {
        end_from: '2026-06-01',
        start_to: '2026-07-05',
        user_ids: 'user-1,user-2',
        visibility: 'all',
      },
    });
  });

  it('fails fast when the backend payload breaks the schedule contract', async () => {
    requestClientState.get.mockResolvedValue([{ id: 'schedule-1' }]);

    await expect(
      getSchedules({
        end_from: '2026-06-01',
        start_to: '2026-07-05',
        visibility: 'all',
      }),
    ).rejects.toThrow(/required|expected/i);
  });
});

describe('getSchedule', () => {
  beforeEach(() => {
    requestClientState.delete.mockReset();
    requestClientState.get.mockReset();
    requestClientState.post.mockReset();
    requestClientState.put.mockReset();
  });

  it('requests one schedule occurrence through the relative detail endpoint', async () => {
    requestClientState.get.mockResolvedValue(makeSchedule());

    await expect(getSchedule('schedule-1')).resolves.toMatchObject({
      id: 'schedule-1',
    });

    expect(requestClientState.get).toHaveBeenCalledWith(
      '/schedules/schedule-1',
    );
  });

  it('fails fast when the backend payload breaks the detail schedule contract', async () => {
    requestClientState.get.mockResolvedValue({ id: 'schedule-1' });

    await expect(getSchedule('schedule-1')).rejects.toThrow(
      /required|expected/i,
    );
  });
});

describe('joinScheduleEvent', () => {
  beforeEach(() => {
    requestClientState.delete.mockReset();
    requestClientState.get.mockReset();
    requestClientState.post.mockReset();
    requestClientState.put.mockReset();
  });

  it('requests join through the relative schedule-events endpoint', async () => {
    requestClientState.post.mockResolvedValue({ message: 'Joined' });

    await expect(joinScheduleEvent('event-1')).resolves.toMatchObject({
      message: 'Joined',
    });

    expect(requestClientState.post).toHaveBeenCalledWith(
      '/schedule-events/event-1/join',
    );
  });

  it('fails fast when the join payload breaks the contract', async () => {
    requestClientState.post.mockResolvedValue({});

    await expect(joinScheduleEvent('event-1')).rejects.toThrow(
      /required|expected/i,
    );
  });
});

describe('leaveScheduleEvent', () => {
  beforeEach(() => {
    requestClientState.delete.mockReset();
    requestClientState.get.mockReset();
    requestClientState.post.mockReset();
    requestClientState.put.mockReset();
  });

  it('requests leave through the relative schedule-events endpoint', async () => {
    requestClientState.post.mockResolvedValue({ message: 'Left' });

    await expect(leaveScheduleEvent('event-1')).resolves.toMatchObject({
      message: 'Left',
    });

    expect(requestClientState.post).toHaveBeenCalledWith(
      '/schedule-events/event-1/leave',
    );
  });

  it('fails fast when the leave payload breaks the contract', async () => {
    requestClientState.post.mockResolvedValue({});

    await expect(leaveScheduleEvent('event-1')).rejects.toThrow(
      /required|expected/i,
    );
  });
});

describe('deleteScheduleEvent', () => {
  beforeEach(() => {
    requestClientState.delete.mockReset();
    requestClientState.get.mockReset();
    requestClientState.post.mockReset();
    requestClientState.put.mockReset();
  });

  it('requests delete through the relative schedule-events endpoint', async () => {
    requestClientState.delete.mockResolvedValue({ message: 'Deleted' });

    await expect(deleteScheduleEvent('event-1')).resolves.toMatchObject({
      message: 'Deleted',
    });

    expect(requestClientState.delete).toHaveBeenCalledWith(
      '/schedule-events/event-1',
    );
  });

  it('fails fast when the delete payload breaks the contract', async () => {
    requestClientState.delete.mockResolvedValue({});

    await expect(deleteScheduleEvent('event-1')).rejects.toThrow(
      /required|expected/i,
    );
  });
});

describe('createScheduleEvent', () => {
  beforeEach(() => {
    requestClientState.delete.mockReset();
    requestClientState.get.mockReset();
    requestClientState.post.mockReset();
    requestClientState.put.mockReset();
  });

  it('requests create through the relative schedule-events endpoint', async () => {
    requestClientState.post.mockResolvedValue({ ok: true });

    await expect(
      createScheduleEvent({
        company_name: null,
        company_phone_number: null,
        end_date: '2026-06-16',
        has_reminder: false,
        is_general: false,
        note: null,
        observers: [],
        participants: ['user-1'],
        physical_address: null,
        privacy: 'public',
        remind_range: null,
        remind_value: null,
        repeat_end_time: null,
        repeat_pattern: null,
        repeat_start_time: null,
        repeat_type: null,
        schedule_type: 'ordinary',
        start_date: '2026-06-16',
        title: 'Planning',
        type: 'meeting',
      }),
    ).resolves.toBeUndefined();

    expect(requestClientState.post).toHaveBeenCalledWith('/schedule-events', {
      company_name: null,
      company_phone_number: null,
      end_date: '2026-06-16',
      has_reminder: false,
      is_general: false,
      note: null,
      observers: [],
      participants: ['user-1'],
      physical_address: null,
      privacy: 'public',
      remind_range: null,
      remind_value: null,
      repeat_end_time: null,
      repeat_pattern: null,
      repeat_start_time: null,
      repeat_type: null,
      schedule_type: 'ordinary',
      start_date: '2026-06-16',
      title: 'Planning',
      type: 'meeting',
    });
  });

  it('treats any 2xx create response as success', async () => {
    requestClientState.post.mockResolvedValue({ id: 'event-1' });

    await expect(
      createScheduleEvent({
        company_name: null,
        company_phone_number: null,
        end_date: '2026-06-16',
        has_reminder: false,
        is_general: false,
        note: null,
        observers: [],
        participants: ['user-1'],
        physical_address: null,
        privacy: 'public',
        remind_range: null,
        remind_value: null,
        repeat_end_time: null,
        repeat_pattern: null,
        repeat_start_time: null,
        repeat_type: null,
        schedule_type: 'ordinary',
        start_date: '2026-06-16',
        title: 'Planning',
        type: 'meeting',
      }),
    ).resolves.toBeUndefined();
  });
});

describe('updateScheduleEvent', () => {
  beforeEach(() => {
    requestClientState.delete.mockReset();
    requestClientState.get.mockReset();
    requestClientState.post.mockReset();
    requestClientState.put.mockReset();
  });

  it('requests update through the relative schedule-events endpoint', async () => {
    requestClientState.put.mockResolvedValue({ ok: true });

    await expect(
      updateScheduleEvent('event-1', {
        company_name: null,
        company_phone_number: null,
        end_date: '2026-06-16',
        has_reminder: false,
        is_general: false,
        note: null,
        observers: [],
        participants: ['user-1'],
        physical_address: null,
        privacy: 'public',
        remind_range: null,
        remind_value: null,
        repeat_end_time: null,
        repeat_pattern: null,
        repeat_start_time: null,
        repeat_type: null,
        schedule_type: 'ordinary',
        start_date: '2026-06-16',
        title: 'Planning',
        type: 'meeting',
      }),
    ).resolves.toBeUndefined();

    expect(requestClientState.put).toHaveBeenCalledWith(
      '/schedule-events/event-1',
      {
        company_name: null,
        company_phone_number: null,
        end_date: '2026-06-16',
        has_reminder: false,
        is_general: false,
        note: null,
        observers: [],
        participants: ['user-1'],
        physical_address: null,
        privacy: 'public',
        remind_range: null,
        remind_value: null,
        repeat_end_time: null,
        repeat_pattern: null,
        repeat_start_time: null,
        repeat_type: null,
        schedule_type: 'ordinary',
        start_date: '2026-06-16',
        title: 'Planning',
        type: 'meeting',
      },
    );
  });

  it('treats any 2xx update response as success', async () => {
    requestClientState.put.mockResolvedValue({ id: 'event-1' });

    await expect(
      updateScheduleEvent('event-1', {
        company_name: null,
        company_phone_number: null,
        end_date: '2026-06-16',
        has_reminder: false,
        is_general: false,
        note: null,
        observers: [],
        participants: ['user-1'],
        physical_address: null,
        privacy: 'public',
        remind_range: null,
        remind_value: null,
        repeat_end_time: null,
        repeat_pattern: null,
        repeat_start_time: null,
        repeat_type: null,
        schedule_type: 'ordinary',
        start_date: '2026-06-16',
        title: 'Planning',
        type: 'meeting',
      }),
    ).resolves.toBeUndefined();
  });
});
