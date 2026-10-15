import { describe, expect, it } from 'vitest';

import {
  previewLists,
  previewTasks,
} from '#/views/personal-tasks/preview-data';
import { mockPersonalTaskLists, mockPersonalTasks } from '#/mocks/data';

import {
  personalTaskListSchema,
  personalTaskRecurrenceSchema,
  personalTaskSchema,
  personalTasksResponseSchema,
} from './personal-tasks';

const [task] = previewTasks;
const [list] = previewLists;
if (!task || !list) throw new Error('Personal task fixtures are incomplete');

describe('personal task contracts', () => {
  it('accepts the mock API payload', () => {
    expect(
      personalTasksResponseSchema.safeParse({
        lists: mockPersonalTaskLists,
        tasks: mockPersonalTasks,
      }).success,
    ).toBe(true);
  });

  it('accepts the list and task models returned by the API', () => {
    expect(
      personalTasksResponseSchema.parse({
        lists: previewLists,
        tasks: previewTasks,
      }),
    ).toEqual({ lists: previewLists, tasks: previewTasks });
  });

  it('ties completed_at to the task status', () => {
    expect(
      personalTaskSchema.safeParse({
        ...task,
        completed_at: '2026-10-02T09:11:34.000000Z',
        status: 'needsAction',
      }).success,
    ).toBe(false);
    expect(
      personalTaskSchema.safeParse({
        ...task,
        completed_at: null,
        status: 'completed',
      }).success,
    ).toBe(false);
  });

  it('rejects invalid values, Google Tasks limits, and removed sync fields', () => {
    expect(
      personalTaskSchema.safeParse({ ...task, status: 'pending' }).success,
    ).toBe(false);
    expect(
      personalTaskSchema.safeParse({ ...task, id: 'task-1' }).success,
    ).toBe(false);
    expect(
      personalTaskSchema.safeParse({ ...task, due_date: '2026-02-30' }).success,
    ).toBe(false);
    expect(
      personalTaskSchema.safeParse({ ...task, notes: 'n'.repeat(8193) })
        .success,
    ).toBe(false);
    expect(
      personalTaskSchema.safeParse({ ...task, google_id: 'remote-id' }).success,
    ).toBe(false);
    expect(
      personalTaskListSchema.safeParse({ ...list, source: 'google' }).success,
    ).toBe(false);
  });

  it('accepts recurrence rules and rejects inconsistent ones', () => {
    const rule = {
      count: null,
      frequency: 'week',
      interval: 2,
      until: null,
      weekdays: [1, 3],
    };
    expect(
      personalTaskSchema.safeParse({
        ...task,
        extension: { ...task.extension, recurrence: rule },
      }).success,
    ).toBe(true);

    for (const invalid of [
      { ...rule, weekdays: null },
      { ...rule, frequency: 'day' },
      { ...rule, weekdays: [1, 1] },
      { ...rule, weekdays: [7] },
      { ...rule, interval: 0 },
      { ...rule, count: 3, until: '2026-12-31' },
      { ...rule, extra: true },
    ]) {
      expect(personalTaskRecurrenceSchema.safeParse(invalid).success).toBe(
        false,
      );
    }
  });

  it('accepts monthly weekday rules from migrated tasks', () => {
    expect(
      personalTaskSchema.safeParse({
        ...task,
        extension: {
          ...task.extension,
          recurrence: {
            count: null,
            frequency: 'month_weekday',
            interval: 1,
            until: null,
            weekdays: null,
          },
        },
      }).success,
    ).toBe(true);
  });
});
