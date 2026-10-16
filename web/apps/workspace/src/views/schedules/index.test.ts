import type { Schedule } from '#/api/schedules';

import { computed, createApp, nextTick } from 'vue';

import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import { formatScheduleTileMeta } from './schedule-page';

function flattenTreeOptions(
  treeData: Array<{
    children?: unknown[];
    label: string;
    selectable?: boolean;
    value: string;
  }>,
): Array<{ label: string; value: string }> {
  return treeData.flatMap((node) => {
    const children = Array.isArray(node.children)
      ? flattenTreeOptions(
          node.children as Array<{
            children?: unknown[];
            label: string;
            selectable?: boolean;
            value: string;
          }>,
        )
      : [];

    return node.selectable === false
      ? children
      : [{ label: node.label, value: node.value }, ...children];
  });
}

const schedulesState = vi.hoisted(() => ({
  createScheduleEvent: vi.fn(),
  deleteScheduleEvent: vi.fn(),
  getSchedule: vi.fn(),
  getSchedules: vi.fn(),
  joinScheduleEvent: vi.fn(),
  leaveScheduleEvent: vi.fn(),
  updateScheduleEvent: vi.fn(),
}));
const usersState = vi.hoisted(() => ({
  getAll: vi.fn(),
}));
const notificationState = vi.hoisted(() => ({
  success: vi.fn(),
}));
const requestFeedbackState = vi.hoisted(() => ({
  showRequestError: vi.fn(),
}));
const userStoreState = vi.hoisted(() => ({
  userStore: {
    userInfo: {
      userId: 'user-1',
    },
  },
}));
const authStoreState = vi.hoisted(() => ({
  authStore: {
    user: {
      company_id: 'company-1' as null | string,
    },
  },
}));
const layoutState = vi.hoisted(() => ({
  contentIsMaximize: false,
}));
const routerState = vi.hoisted(() => ({
  route: { query: {} as Record<string, string> },
}));

vi.mock('@vben/common-ui', () => ({
  Page: {
    template: '<div data-testid="page"><slot /></div>',
  },
  VbenButton: {
    emits: ['click'],
    template: '<button type="button" @click="$emit(`click`)"><slot /></button>',
  },
  VbenIconButton: {
    emits: ['click'],
    template: '<button type="button" @click="$emit(`click`)"><slot /></button>',
  },
}));

vi.mock('@vben/preferences', () => ({
  preferences: {
    app: {
      locale: 'en-US',
    },
  },
}));

vi.mock('@vben/hooks', () => ({
  useContentMaximize: () => ({
    contentIsMaximize: computed(() => layoutState.contentIsMaximize),
    toggleMaximize: vi.fn(),
  }),
}));

vi.mock('@vben/icons', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@vben/icons')>();

  return {
    ...actual,
    createIconifyIcon: (name: string) => ({
      props: ['class'],
      data: () => ({ iconName: name }),
      template: '<span :data-icon="iconName" :class="$props.class"></span>',
    }),
  };
});

vi.mock('@vben/stores', () => ({
  useUserStore: () => userStoreState.userStore,
}));

vi.mock('vue-router', () => ({
  useRoute: () => routerState.route,
}));

vi.mock('#/api/schedules', () => ({
  createScheduleEvent: schedulesState.createScheduleEvent,
  deleteScheduleEvent: schedulesState.deleteScheduleEvent,
  getSchedule: schedulesState.getSchedule,
  getSchedules: schedulesState.getSchedules,
  joinScheduleEvent: schedulesState.joinScheduleEvent,
  leaveScheduleEvent: schedulesState.leaveScheduleEvent,
  updateScheduleEvent: schedulesState.updateScheduleEvent,
}));

vi.mock('#/api/users', () => ({
  companyUsersResource: {
    getAll: usersState.getAll,
  },
}));

vi.mock('#/store', () => ({
  useAuthStore: () => authStoreState.authStore,
}));

vi.mock('#/views/users/avatar', () => ({
  getUserAvatarSource: (user: { id: string }) => `avatar:${user.id}`,
}));

vi.mock('#/shared/request-feedback', () => ({
  showRequestError: requestFeedbackState.showRequestError,
}));

vi.mock('#/locales', () => ({
  $t: (
    key: string,
    params?: { count?: number; range?: string; value?: number | string },
  ) => {
    const messages: Record<string, string> = {
      'page.schedules.actions.all': 'All schedules',
      'page.schedules.actions.created': 'Created',
      'page.schedules.actions.create': 'Create',
      'page.schedules.actions.nextMonth': 'Next month',
      'page.schedules.actions.observed': 'Observed',
      'page.schedules.actions.previousMonth': 'Previous month',
      'page.schedules.actions.participated': 'Participated',
      'page.schedules.actions.selectCalendars': 'Calendars',
      'page.schedules.actions.selectMonth': 'Select month',
      'page.schedules.actions.selectVisibility': 'Visibility',
      'page.schedules.actions.today': 'Today',
      'page.schedules.currentMonth': 'Current month',
      'page.schedules.detail.location': 'Location',
      'page.schedules.detail.collapseUsers': 'Collapse',
      'page.schedules.detail.title': 'Schedule detail',
      'page.schedules.detail.actions.delete': 'Delete',
      'page.schedules.detail.actions.edit': 'Edit',
      'page.schedules.detail.actions.join': 'Join',
      'page.schedules.detail.actions.leave': 'Leave',
      'page.schedules.detail.actions.reuse': 'Reuse',
      'page.schedules.form.cancel': 'Cancel',
      'page.schedules.form.editTitle': 'Edit schedule',
      'page.schedules.form.reuseTitle': 'Reuse schedule',
      'page.schedules.form.companyRequiredTitle': 'Company membership required',
      'page.schedules.form.companyRequiredDescription':
        'You need to belong to a company before you can create a schedule.',
      'page.schedules.form.eventType': 'Event type',
      'page.schedules.form.hasReminder': 'Enable reminder',
      'page.schedules.form.location': 'Physical address',
      'page.schedules.form.note': 'Note',
      'page.schedules.form.observers': 'Observers',
      'page.schedules.form.participants': 'Participants',
      'page.schedules.form.privacy': 'Privacy',
      'page.schedules.form.repeat.dayPattern': 'Repeat days',
      'page.schedules.form.repeat.monthPattern': 'Repeat dates',
      'page.schedules.form.repeat.selectAll': 'Select all',
      'page.schedules.form.repeat.endTime': 'Repeat end time',
      'page.schedules.form.repeat.startTime': 'Repeat start time',
      'page.schedules.form.repeat.type': 'Repeat type',
      'page.schedules.form.repeatOptions.daily': 'Daily',
      'page.schedules.form.repeatOptions.monthly': 'Monthly',
      'page.schedules.form.repeatOptions.weekly': 'Weekly',
      'page.schedules.form.repeatTitle': 'Repeat settings',
      'page.schedules.form.reminderRange': 'Reminder range',
      'page.schedules.form.reminderValue': 'Reminder value',
      'page.schedules.form.save': 'Save',
      'page.schedules.form.scheduleType': 'Schedule type',
      'page.schedules.form.startDate': 'Start date',
      'page.schedules.form.endDate': 'End date',
      'page.schedules.form.startTime': 'Start time',
      'page.schedules.form.endTime': 'End time',
      'page.schedules.form.title': 'Title',
      'page.schedules.form.userOptionsLoading': 'Loading employees',
      'page.schedules.form.isGeneral': 'General schedule',
      'page.schedules.form.createDescription':
        'Create a schedule from the selected date context.',
      'page.schedules.form.createTitle': 'Create schedule',
      'page.schedules.form.modes.create': 'Create mode',
      'page.schedules.form.modes.edit': 'Edit mode',
      'page.schedules.form.modes.reuse': 'Reuse mode',
      'page.schedules.form.privacyOptions.private': 'Private',
      'page.schedules.form.privacyOptions.public': 'Public',
      'page.schedules.form.reminderRangeOptions.day': 'Day',
      'page.schedules.form.reminderRangeOptions.hour': 'Hour',
      'page.schedules.form.reminderRangeOptions.minute': 'Minute',
      'page.schedules.form.scheduleTypeOptions.multiple_days': 'Multiple days',
      'page.schedules.form.scheduleTypeOptions.ordinary': 'Ordinary',
      'page.schedules.form.scheduleTypeOptions.repeat': 'Repeat',
      'page.schedules.form.typeOptions.business_trip': 'Business trip',
      'page.schedules.form.typeOptions.holiday': 'Holiday',
      'page.schedules.form.typeOptions.interview': 'Interview',
      'page.schedules.form.typeOptions.meeting': 'Meeting',
      'page.schedules.form.typeOptions.meetup': 'Meetup',
      'page.schedules.form.typeOptions.seminar': 'Seminar',
      'page.schedules.form.typeOptions.training': 'Training',
      'page.schedules.detail.reuse.description':
        'Review the reused event draft before Epic 3 form editing arrives.',
      'page.schedules.detail.reuse.mode': 'Reuse draft',
      'page.schedules.detail.multiDay': 'Multi-day schedule',
      'page.schedules.detail.note': 'Note',
      'page.schedules.detail.observers': 'Observers',
      'page.schedules.detail.participants': 'Participants',
      'page.schedules.detail.reminderOff': 'Reminder off',
      'page.schedules.detail.reminderOn': 'Reminder {value} {range} before',
      'page.schedules.detail.repeat.daily': 'Repeats daily',
      'page.schedules.detail.repeat.monthly': 'Repeats monthly',
      'page.schedules.detail.repeat.weekly': 'Repeats weekly',
      'page.schedules.detail.time': 'Time',
      'page.schedules.detail.type': 'Type',
      'page.schedules.detail.reminder': 'Reminder',
      'page.schedules.detail.typeLabels.business_trip': 'Business trip',
      'page.schedules.detail.typeLabels.holiday': 'Holiday',
      'page.schedules.detail.typeLabels.interview': 'Interview',
      'page.schedules.detail.typeLabels.meeting': 'Meeting',
      'page.schedules.detail.typeLabels.meetup': 'Meetup',
      'page.schedules.detail.typeLabels.seminar': 'Seminar',
      'page.schedules.detail.typeLabels.training': 'Training',
      'page.schedules.detail.reminderRange.day': 'day',
      'page.schedules.detail.reminderRange.hour': 'hour',
      'page.schedules.detail.reminderRange.minute': 'minute',
      'page.schedules.description': 'Description',
      'page.schedules.empty': 'No schedules match this filter.',
      'page.schedules.loading': 'Loading month data',
      'page.schedules.messages.deleteSuccess': 'Deleted schedule',
      'page.schedules.messages.createSuccess': 'Created schedule',
      'page.schedules.messages.joinSuccess': 'Joined schedule',
      'page.schedules.messages.leaveSuccess': 'Left schedule',
      'page.schedules.messages.updateSuccess': 'Updated schedule',
      'page.schedules.messages.unexpectedError': 'Unexpected error',
      'page.schedules.delete.cancel': 'Cancel',
      'page.schedules.delete.confirm': 'Delete schedule',
      'page.schedules.delete.description':
        'Delete this schedule event? This action cannot be undone.',
      'page.schedules.delete.title': 'Delete schedule',
      'page.schedules.title': 'Schedules',
    };

    if (key === 'page.schedules.loadedCount') {
      return `Loaded ${params?.count ?? 0} schedules`;
    }

    if (key === 'page.schedules.detail.reminderOn') {
      return `Reminder ${params?.value ?? ''} ${params?.range ?? ''} before`.trim();
    }

    if (key === 'page.schedules.detail.showMoreUsers') {
      return `+${params?.count ?? 0} more users`;
    }

    return messages[key] ?? key;
  },
}));

vi.mock('ant-design-vue', () => ({
  Avatar: {
    props: ['src'],
    template:
      '<span data-testid="avatar" :data-avatar-src="src ?? ``"><slot /></span>',
  },
  Alert: {
    props: ['description', 'message'],
    template:
      '<section data-testid="alert"><h3>{{ message }}</h3><p>{{ description }}</p></section>',
  },
  DatePicker: {
    emits: ['update:value'],
    props: ['picker', 'value'],
    template:
      '<input :data-testid="picker === `month` ? `month-picker` : `date-picker`" :type="picker === `month` ? `month` : `date`" :value="value ?? \'\'" @input="$emit(`update:value`, $event.target.value)" />',
  },
  TimePicker: {
    emits: ['update:value'],
    props: ['value'],
    template:
      '<input data-testid="time-picker" type="time" :value="value ?? \'\'" @input="$emit(`update:value`, $event.target.value)" />',
  },
  Input: {
    emits: ['update:value'],
    props: ['value'],
    template:
      '<input :value="value ?? \'\'" @input="$emit(`update:value`, $event.target.value)" />',
  },
  InputNumber: {
    emits: ['update:value'],
    props: ['value'],
    template:
      '<input type="number" :value="value ?? \'\'" @input="$emit(`update:value`, Number($event.target.value))" />',
  },
  Select: {
    emits: ['update:value'],
    props: ['disabled', 'mode', 'options', 'value'],
    template:
      '<select :data-testid="mode === `multiple` ? `multi-select` : `visibility-filter`" :disabled="disabled" :multiple="mode === `multiple`" :value="value" @change="mode === `multiple` ? $emit(`update:value`, Array.from($event.target.selectedOptions).map((option) => option.value)) : $emit(`update:value`, $event.target.value)"><option v-for="option in options" :key="option.value" :value="option.value">{{ option.label }}</option></select>',
  },
  TreeSelect: {
    emits: ['update:value'],
    props: ['dataTestid', 'disabled', 'treeData', 'value'],
    setup(props: {
      treeData?: Array<{
        children?: unknown[];
        label: string;
        selectable?: boolean;
        value: string;
      }>;
    }) {
      return {
        flattenedOptions: computed(() =>
          flattenTreeOptions(props.treeData ?? []),
        ),
      };
    },
    template:
      '<select :data-testid="dataTestid ?? `tree-select`" :disabled="disabled" multiple :value="value" @change="$emit(`update:value`, Array.from($event.target.selectedOptions).map((option) => option.value))"><option v-for="option in flattenedOptions" :key="option.value" :value="option.value">{{ option.label }}</option></select>',
  },
  Switch: {
    emits: ['update:checked'],
    props: ['checked'],
    template:
      '<input type="checkbox" :checked="checked" @change="$emit(`update:checked`, $event.target.checked)" />',
  },
  Drawer: {
    emits: ['close'],
    props: ['open', 'title'],
    template:
      '<aside v-if="open" data-testid="schedule-detail-drawer"><header><h2>{{ title }}</h2><button type="button" data-testid="schedule-detail-close" @click="$emit(`close`)">Close</button></header><div><slot /></div><footer><slot name="footer" /></footer></aside>',
  },
  Modal: {
    emits: ['cancel', 'ok'],
    props: ['cancelText', 'okText', 'open', 'title'],
    template:
      '<section v-if="open" data-testid="schedule-delete-modal"><h2>{{ title }}</h2><div><slot /></div><button type="button" data-testid="schedule-delete-cancel" @click="$emit(`cancel`)">{{ cancelText }}</button><button type="button" data-testid="schedule-delete-confirm" @click="$emit(`ok`)">{{ okText }}</button></section>',
  },
  notification: notificationState,
}));

type ScheduleOverrides = Omit<Partial<Schedule>, 'event'> & {
  event?: Partial<Schedule['event']>;
};

function makeSchedule(overrides: ScheduleOverrides = {}): Schedule {
  const eventOverrides = overrides.event ?? {};
  const { event: _event, ...scheduleOverrides } = overrides;
  const baseEvent: Schedule['event'] = {
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
  };
  const baseSchedule: Omit<Schedule, 'event'> = {
    end: '2026-06-16T10:00:00.000000Z',
    event_id: 'event-1',
    id: 'schedule-1',
    one_day: true,
    remind_at: null,
    start: '2026-06-16T09:00:00.000000Z',
  };

  return {
    ...baseSchedule,
    ...scheduleOverrides,
    event: { ...baseEvent, ...eventOverrides },
  };
}

function expectedVisibleRangeParams(
  monthValue: string,
  visibility: 'all' | 'created' | 'observed' | 'participated',
) {
  const monthRanges: Record<string, { end_from: string; start_to: string }> = {
    '2026-06': {
      end_from: '2026-06-01',
      start_to: '2026-07-05',
    },
    '2026-07': {
      end_from: '2026-06-29',
      start_to: '2026-08-02',
    },
    '2026-08': {
      end_from: '2026-07-27',
      start_to: '2026-09-06',
    },
  };
  const range = monthRanges[monthValue];

  if (range === undefined) {
    throw new Error(`Missing expected visible range for month ${monthValue}.`);
  }

  return {
    ...range,
    visibility,
  };
}

async function flushPromises() {
  await Promise.resolve();
  await Promise.resolve();
  await nextTick();
}

function deferredPromise<T>() {
  let reject!: (reason?: unknown) => void;
  let resolve!: (value: PromiseLike<T> | T) => void;

  const promise = new Promise<T>((nextResolve, nextReject) => {
    resolve = nextResolve;
    reject = nextReject;
  });

  return { promise, reject, resolve };
}

describe('schedules workspace', () => {
  beforeEach(() => {
    schedulesState.createScheduleEvent.mockReset();
    schedulesState.getSchedules.mockReset();
    schedulesState.getSchedule.mockReset();
    schedulesState.deleteScheduleEvent.mockReset();
    schedulesState.joinScheduleEvent.mockReset();
    schedulesState.leaveScheduleEvent.mockReset();
    schedulesState.updateScheduleEvent.mockReset();
    usersState.getAll.mockReset();
    notificationState.success.mockReset();
    requestFeedbackState.showRequestError.mockReset();
    vi.useFakeTimers();
    vi.setSystemTime(new Date('2026-06-16T08:00:00Z'));
    userStoreState.userStore.userInfo.userId = 'user-1';
    authStoreState.authStore.user.company_id = 'company-1';
    layoutState.contentIsMaximize = false;
    routerState.route.query = {};
    schedulesState.getSchedules.mockResolvedValue([makeSchedule()]);
    schedulesState.getSchedule.mockResolvedValue(makeSchedule());
    schedulesState.deleteScheduleEvent.mockResolvedValue({
      message: 'Deleted',
    });
    schedulesState.joinScheduleEvent.mockResolvedValue({ message: 'Joined' });
    schedulesState.leaveScheduleEvent.mockResolvedValue({ message: 'Left' });
    schedulesState.createScheduleEvent.mockResolvedValue({
      id: 'event-created',
      schedules: [],
    });
    schedulesState.updateScheduleEvent.mockResolvedValue({
      id: 'event-1',
      schedules: [],
    });
    usersState.getAll.mockResolvedValue([
      {
        avatar: null,
        company_id: 'company-1',
        created_at: '2026-06-16T08:00:00.000000Z',
        departments: [],
        email: 'owner@example.com',
        email_verified_at: null,
        id: 'user-1',
        is_active: true,
        name: 'Owner User',
        permissions: [],
        profile: null,
        roles: [],
        updated_at: '2026-06-16T08:00:00.000000Z',
        username: 'owner',
      },
      {
        avatar: null,
        company_id: 'company-1',
        created_at: '2026-06-16T08:00:00.000000Z',
        departments: [],
        email: 'participant@example.com',
        email_verified_at: null,
        id: 'user-2',
        is_active: true,
        name: 'Participant User',
        permissions: [],
        profile: null,
        roles: [],
        updated_at: '2026-06-16T08:00:00.000000Z',
        username: 'participant',
      },
    ]);
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('loads authoring users from the authenticated company only', async () => {
    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    expect(usersState.getAll).toHaveBeenCalledWith({
      department_company_id: 'company-1',
    });

    app.unmount();
  });

  it('loads the current month and reloads when the employee navigates months', async () => {
    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    expect(schedulesState.getSchedules).toHaveBeenNthCalledWith(
      1,
      expectedVisibleRangeParams('2026-06', 'all'),
    );

    element
      .querySelector<HTMLButtonElement>('button[aria-label="Next month"]')
      ?.click();
    await flushPromises();

    expect(schedulesState.getSchedules).toHaveBeenNthCalledWith(
      2,
      expectedVisibleRangeParams('2026-07', 'all'),
    );

    const monthPicker = element.querySelector<HTMLInputElement>(
      '[data-testid="month-picker"]',
    );

    if (monthPicker === null) {
      throw new Error('Month picker not found.');
    }

    monthPicker.value = '2026-08';
    monthPicker.dispatchEvent(new Event('input'));
    await flushPromises();

    expect(schedulesState.getSchedules).toHaveBeenNthCalledWith(
      3,
      expectedVisibleRangeParams('2026-08', 'all'),
    );

    element
      .querySelector<HTMLButtonElement>('button[aria-label="Today"]')
      ?.click();
    await flushPromises();

    expect(schedulesState.getSchedules).toHaveBeenNthCalledWith(
      4,
      expectedVisibleRangeParams('2026-06', 'all'),
    );

    app.unmount();
  });

  it('opens the notified schedule event detail from the route query', async () => {
    routerState.route.query = { event_id: 'event-1' };

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    expect(schedulesState.getSchedules).toHaveBeenNthCalledWith(2, {
      event_id: 'event-1',
      visibility: 'all',
    });
    expect(schedulesState.getSchedule).toHaveBeenCalledWith('schedule-1');
    expect(
      element.querySelector('[data-testid="schedule-detail-drawer"]'),
    ).not.toBeNull();

    app.unmount();
  });

  it('shows the signed-in calendar plus a secondary tab section for selected employee calendars', async () => {
    schedulesState.getSchedules.mockResolvedValue([
      makeSchedule({
        id: 'schedule-1',
        event: {
          created_by: 'user-1',
          id: 'event-1',
          title: 'Owner planning',
        },
        event_id: 'event-1',
      }),
      makeSchedule({
        id: 'schedule-2',
        event: {
          created_by: 'user-2',
          id: 'event-2',
          title: 'Participant planning',
        },
        event_id: 'event-2',
      }),
    ]);

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    const calendarUserSelect = element.querySelector<HTMLSelectElement>(
      '[data-testid="calendar-user-tree-select"]',
    );
    const visibilityFilter = element.querySelector<HTMLSelectElement>(
      '[data-testid="visibility-filter"]',
    );

    if (calendarUserSelect === null) {
      throw new Error('Calendar user select not found.');
    }
    if (visibilityFilter === null) {
      throw new Error('Visibility filter not found.');
    }

    for (const option of calendarUserSelect.options) {
      option.selected = ['user-1', 'user-2'].includes(option.value);
    }

    calendarUserSelect.dispatchEvent(new Event('change'));
    await flushPromises();

    expect(visibilityFilter.value).toBe('all');
    expect(visibilityFilter.disabled).toBe(true);
    expect(schedulesState.getSchedules).toHaveBeenLastCalledWith({
      ...expectedVisibleRangeParams('2026-06', 'all'),
      user_ids: 'user-1,user-2',
    });

    expect(
      element.querySelector(
        '[data-testid="schedule-calendar-section-primary"]',
      ),
    ).not.toBeNull();
    expect(
      element.querySelector(
        '[data-testid="schedule-calendar-section-secondary"]',
      ),
    ).not.toBeNull();
    expect(
      element.querySelector<HTMLElement>(
        '[data-testid="schedule-calendar-section-primary"]',
      )?.className,
    ).toContain('h-[calc(100vh-13rem)]');
    expect(
      element.querySelector<HTMLElement>(
        '[data-testid="schedule-calendar-scroll-container"]',
      )?.className,
    ).toContain('overflow-auto');
    expect(
      element.querySelector(
        '[data-testid="schedule-calendar-scroll-container"] [data-testid="schedule-calendar-weekday-header"]',
      ),
    ).toBeNull();
    expect(
      element.querySelector('[data-testid="schedule-calendar-weekday-header"]'),
    ).not.toBeNull();
    expect(
      [
        ...element.querySelectorAll<HTMLElement>(
          '[data-testid="schedule-calendar-tab"]',
        ),
      ].map((tab) =>
        tab
          .querySelector<HTMLElement>(
            '[data-testid="schedule-calendar-tab-label"]',
          )
          ?.textContent?.trim(),
      ),
    ).toEqual(['Owner User', 'Participant User']);
    expect(
      element.querySelectorAll('[data-testid="schedule-content"]'),
    ).toHaveLength(2);
    expect(
      element
        .querySelector('[data-testid="schedule-calendar-section-primary"]')
        ?.querySelector('[data-testid="schedule-calendar-tab-transfer"]'),
    ).toBeNull();
    expect(
      element
        .querySelector('[data-testid="schedule-calendar-section-secondary"]')
        ?.querySelector('[data-testid="schedule-calendar-tab-transfer"]'),
    ).not.toBeNull();

    app.unmount();
  });

  it('transfers non-signed-in calendar tabs between sections', async () => {
    schedulesState.getSchedules.mockResolvedValue([
      makeSchedule({
        id: 'schedule-1',
        event: {
          created_by: 'user-1',
          id: 'event-1',
          title: 'Owner planning',
        },
        event_id: 'event-1',
      }),
      makeSchedule({
        id: 'schedule-2',
        event: {
          created_by: 'user-2',
          id: 'event-2',
          title: 'Participant planning',
        },
        event_id: 'event-2',
      }),
    ]);

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    const calendarUserSelect = element.querySelector<HTMLSelectElement>(
      '[data-testid="calendar-user-tree-select"]',
    );

    if (calendarUserSelect === null) {
      throw new Error('Calendar user select not found.');
    }

    for (const option of calendarUserSelect.options) {
      option.selected = ['user-1', 'user-2'].includes(option.value);
    }

    calendarUserSelect.dispatchEvent(new Event('change'));
    await flushPromises();

    const secondarySectionBeforeTransfer = element.querySelector<HTMLElement>(
      '[data-testid="schedule-calendar-section-secondary"]',
    );

    if (secondarySectionBeforeTransfer === null) {
      throw new Error('Secondary schedule section not found.');
    }

    secondarySectionBeforeTransfer
      .querySelector<HTMLButtonElement>(
        '[data-testid="schedule-calendar-tab-transfer"]',
      )
      ?.click();
    await flushPromises();

    expect(
      element.querySelector(
        '[data-testid="schedule-calendar-section-secondary"]',
      ),
    ).toBeNull();
    expect(
      [
        ...element.querySelectorAll<HTMLElement>(
          '[data-testid="schedule-calendar-section-primary"] [data-testid="schedule-calendar-tab"]',
        ),
      ].map((tab) =>
        tab
          .querySelector<HTMLElement>(
            '[data-testid="schedule-calendar-tab-label"]',
          )
          ?.textContent?.trim(),
      ),
    ).toEqual(['Owner User', 'Participant User']);
    expect(
      [
        ...element.querySelectorAll<HTMLElement>(
          '[data-testid="schedule-calendar-section-primary"] [data-schedule-id]',
        ),
      ].map((schedule) => schedule.dataset.scheduleId),
    ).toEqual(expect.arrayContaining(['schedule-1', 'schedule-2']));

    const primaryTransferButtons = [
      ...element.querySelectorAll<HTMLButtonElement>(
        '[data-testid="schedule-calendar-section-primary"] [data-testid="schedule-calendar-tab-transfer"]',
      ),
    ];
    const participantTransferButton = primaryTransferButtons.at(-1);

    participantTransferButton?.click();
    await flushPromises();

    expect(
      [
        ...element.querySelectorAll<HTMLElement>(
          '[data-testid="schedule-calendar-section-primary"] [data-testid="schedule-calendar-tab"]',
        ),
      ].map((tab) =>
        tab
          .querySelector<HTMLElement>(
            '[data-testid="schedule-calendar-tab-label"]',
          )
          ?.textContent?.trim(),
      ),
    ).toEqual(['Owner User']);
    expect(
      [
        ...element.querySelectorAll<HTMLElement>(
          '[data-testid="schedule-calendar-section-secondary"] [data-testid="schedule-calendar-tab"]',
        ),
      ].map((tab) =>
        tab
          .querySelector<HTMLElement>(
            '[data-testid="schedule-calendar-tab-label"]',
          )
          ?.textContent?.trim(),
      ),
    ).toEqual(['Participant User']);

    app.unmount();
  });

  it('shows shared user avatars when a section calendar renders schedules for multiple users', async () => {
    schedulesState.getSchedules.mockResolvedValue([
      makeSchedule({
        id: 'schedule-1',
        event: {
          created_by: 'user-1',
          id: 'event-1',
          participants: [
            {
              avatar: null,
              email: 'user2@example.com',
              id: 'user-2',
              name: 'Participant User',
            },
          ],
          title: 'Shared planning',
        },
        event_id: 'event-1',
      }),
    ]);

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    const calendarUserSelect = element.querySelector<HTMLSelectElement>(
      '[data-testid="calendar-user-tree-select"]',
    );

    if (calendarUserSelect === null) {
      throw new Error('Calendar user select not found.');
    }

    for (const option of calendarUserSelect.options) {
      option.selected = ['user-1', 'user-2'].includes(option.value);
    }

    calendarUserSelect.dispatchEvent(new Event('change'));
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>(
        '[data-testid="schedule-calendar-section-secondary"] [data-testid="schedule-calendar-tab-transfer"]',
      )
      ?.click();
    await flushPromises();

    expect(
      element.querySelectorAll(
        '[data-testid="schedule-calendar-section-primary"] [data-testid="schedule-shared-user-avatar"]',
      ),
    ).toHaveLength(2);

    app.unmount();
  });

  it('expands the calendar section height when content maximize is active', async () => {
    layoutState.contentIsMaximize = true;

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    expect(
      element.querySelector<HTMLElement>(
        '[data-testid="schedule-calendar-section-primary"]',
      )?.className,
    ).toContain('h-[calc(100vh-10rem)]');
    expect(
      element.querySelector<HTMLElement>(
        '[data-testid="schedule-calendar-section-primary"]',
      )?.className,
    ).not.toContain('h-[calc(100vh-13rem)]');

    app.unmount();
  });

  it('uses the next selected user as the primary calendar when the signed-in user is removed from the filter', async () => {
    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    const calendarUserSelect = element.querySelector<HTMLSelectElement>(
      '[data-testid="calendar-user-tree-select"]',
    );
    const visibilityFilter = element.querySelector<HTMLSelectElement>(
      '[data-testid="visibility-filter"]',
    );

    if (calendarUserSelect === null) {
      throw new Error('Calendar user select not found.');
    }
    if (visibilityFilter === null) {
      throw new Error('Visibility filter not found.');
    }

    visibilityFilter.value = 'observed';
    visibilityFilter.dispatchEvent(new Event('change'));
    await flushPromises();

    expect(visibilityFilter.value).toBe('observed');
    expect(visibilityFilter.disabled).toBe(false);

    for (const option of calendarUserSelect.options) {
      option.selected = option.value === 'user-2';
    }

    calendarUserSelect.dispatchEvent(new Event('change'));
    await flushPromises();

    expect(visibilityFilter.value).toBe('all');
    expect(visibilityFilter.disabled).toBe(true);
    expect(schedulesState.getSchedules).toHaveBeenLastCalledWith({
      ...expectedVisibleRangeParams('2026-06', 'all'),
      user_ids: 'user-2',
    });
    expect(
      element.querySelector('[data-testid="schedule-calendar-section-primary"]')
        ?.textContent,
    ).toContain('Participant User');
    expect(
      element.querySelector(
        '[data-testid="schedule-calendar-section-secondary"]',
      ),
    ).toBeNull();

    for (const option of calendarUserSelect.options) {
      option.selected = option.value === 'user-1';
    }

    calendarUserSelect.dispatchEvent(new Event('change'));
    await flushPromises();

    expect(visibilityFilter.value).toBe('all');
    expect(visibilityFilter.disabled).toBe(false);
    expect(schedulesState.getSchedules).toHaveBeenLastCalledWith(
      expectedVisibleRangeParams('2026-06', 'all'),
    );

    app.unmount();
  });

  it('moves overflowed secondary tabs into a dropdown menu and transfers hidden tabs from there', async () => {
    usersState.getAll.mockResolvedValue([
      {
        avatar: null,
        company_id: 'company-1',
        created_at: '2026-06-16T08:00:00.000000Z',
        departments: [],
        email: 'owner@example.com',
        email_verified_at: null,
        id: 'user-1',
        is_active: true,
        name: 'Owner User',
        permissions: [],
        profile: null,
        roles: [],
        updated_at: '2026-06-16T08:00:00.000000Z',
        username: 'owner',
      },
      {
        avatar: null,
        company_id: 'company-1',
        created_at: '2026-06-16T08:00:00.000000Z',
        departments: [],
        email: 'user2@example.com',
        email_verified_at: null,
        id: 'user-2',
        is_active: true,
        name: 'User Two',
        permissions: [],
        profile: null,
        roles: [],
        updated_at: '2026-06-16T08:00:00.000000Z',
        username: 'user2',
      },
      {
        avatar: null,
        company_id: 'company-1',
        created_at: '2026-06-16T08:00:00.000000Z',
        departments: [],
        email: 'user3@example.com',
        email_verified_at: null,
        id: 'user-3',
        is_active: true,
        name: 'User Three',
        permissions: [],
        profile: null,
        roles: [],
        updated_at: '2026-06-16T08:00:00.000000Z',
        username: 'user3',
      },
      {
        avatar: null,
        company_id: 'company-1',
        created_at: '2026-06-16T08:00:00.000000Z',
        departments: [],
        email: 'user4@example.com',
        email_verified_at: null,
        id: 'user-4',
        is_active: true,
        name: 'User Four',
        permissions: [],
        profile: null,
        roles: [],
        updated_at: '2026-06-16T08:00:00.000000Z',
        username: 'user4',
      },
      {
        avatar: null,
        company_id: 'company-1',
        created_at: '2026-06-16T08:00:00.000000Z',
        departments: [],
        email: 'user5@example.com',
        email_verified_at: null,
        id: 'user-5',
        is_active: true,
        name: 'User Five',
        permissions: [],
        profile: null,
        roles: [],
        updated_at: '2026-06-16T08:00:00.000000Z',
        username: 'user5',
      },
      {
        avatar: null,
        company_id: 'company-1',
        created_at: '2026-06-16T08:00:00.000000Z',
        departments: [],
        email: 'user6@example.com',
        email_verified_at: null,
        id: 'user-6',
        is_active: true,
        name: 'User Six',
        permissions: [],
        profile: null,
        roles: [],
        updated_at: '2026-06-16T08:00:00.000000Z',
        username: 'user6',
      },
    ]);
    schedulesState.getSchedules.mockResolvedValue(
      ['user-1', 'user-2', 'user-3', 'user-4', 'user-5', 'user-6'].map(
        (userId, index) =>
          makeSchedule({
            id: `schedule-${index + 1}`,
            event: {
              created_by: userId,
              id: `event-${index + 1}`,
              title: `Schedule ${index + 1}`,
            },
            event_id: `event-${index + 1}`,
          }),
      ),
    );

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    const calendarUserSelect = element.querySelector<HTMLSelectElement>(
      '[data-testid="calendar-user-tree-select"]',
    );

    if (calendarUserSelect === null) {
      throw new Error('Calendar user select not found.');
    }

    for (const option of calendarUserSelect.options) {
      option.selected = [
        'user-1',
        'user-2',
        'user-3',
        'user-4',
        'user-5',
        'user-6',
      ].includes(option.value);
    }

    calendarUserSelect.dispatchEvent(new Event('change'));
    await flushPromises();

    const secondarySection = element.querySelector<HTMLElement>(
      '[data-testid="schedule-calendar-section-secondary"]',
    );

    expect(secondarySection).not.toBeNull();
    if (secondarySection === null) {
      throw new Error('Secondary schedule section not found.');
    }

    const initialVisibleLabels = [
      ...secondarySection.querySelectorAll<HTMLElement>(
        '[data-testid="schedule-calendar-tab"]',
      ),
    ].map(
      (tab) =>
        tab
          .querySelector<HTMLElement>(
            '[data-testid="schedule-calendar-tab-label"]',
          )
          ?.textContent?.trim() ?? '',
    );

    expect(initialVisibleLabels).toHaveLength(4);

    secondarySection
      ?.querySelector<HTMLButtonElement>(
        '[data-testid="schedule-calendar-tab-overflow-toggle"]',
      )
      ?.click();
    await flushPromises();

    const overflowLabels = [
      ...secondarySection.querySelectorAll<HTMLElement>(
        '[data-testid="schedule-calendar-tab-overflow-item"]',
      ),
    ].map(
      (tab) =>
        tab
          .querySelector<HTMLElement>(
            '[data-testid="schedule-calendar-tab-overflow-label"]',
          )
          ?.textContent?.trim() ?? '',
    );

    expect(overflowLabels).toHaveLength(1);
    const [hiddenLabel = ''] = overflowLabels;
    expect(initialVisibleLabels).not.toContain(hiddenLabel);
    expect(
      secondarySection.querySelector(
        '[data-testid="schedule-calendar-tab-overflow-transfer"]',
      ),
    ).not.toBeNull();

    secondarySection
      ?.querySelector<HTMLButtonElement>(
        '[data-testid="schedule-calendar-tab-overflow-transfer"]',
      )
      ?.click();
    await flushPromises();

    expect(
      [
        ...element.querySelectorAll<HTMLElement>(
          '[data-testid="schedule-calendar-section-primary"] [data-testid="schedule-calendar-tab"]',
        ),
      ].map((tab) =>
        tab
          .querySelector<HTMLElement>(
            '[data-testid="schedule-calendar-tab-label"]',
          )
          ?.textContent?.trim(),
      ),
    ).toEqual(expect.arrayContaining(['Owner User', hiddenLabel]));

    app.unmount();
  });

  it('shows a page-level loading state while month data is in flight', async () => {
    let resolveSchedules:
      | ((value: ReturnType<typeof makeSchedule>[]) => void)
      | undefined;

    schedulesState.getSchedules.mockImplementation(
      () =>
        new Promise((resolve) => {
          resolveSchedules = resolve;
        }),
    );

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    const content = element.querySelector<HTMLElement>(
      '[data-testid="schedule-content"]',
    );

    expect(content?.getAttribute('aria-busy')).toBe('true');
    expect(element.textContent).toContain('Loading month data');

    resolveSchedules?.([makeSchedule()]);
    await flushPromises();

    expect(content?.getAttribute('aria-busy')).toBe('false');
    expect(element.textContent).toContain('Planning');
    expect(
      element.querySelector<HTMLElement>('[data-schedule-id="schedule-1"]')
        ?.dataset.scheduleShape,
    ).toBe('one-day');

    app.unmount();
  });

  it('reloads with the selected visibility value and still shows the calendar for empty months', async () => {
    schedulesState.getSchedules
      .mockResolvedValueOnce([makeSchedule()])
      .mockResolvedValueOnce([]);

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    const visibilityFilter = element.querySelector<HTMLSelectElement>(
      '[data-testid="visibility-filter"]',
    );

    if (visibilityFilter === null) {
      throw new Error('Visibility filter not found.');
    }

    visibilityFilter.value = 'observed';
    visibilityFilter.dispatchEvent(new Event('change'));
    await flushPromises();

    expect(schedulesState.getSchedules).toHaveBeenNthCalledWith(
      2,
      expectedVisibleRangeParams('2026-06', 'observed'),
    );
    expect(
      element.querySelectorAll('[data-testid="schedule-day-cell"]'),
    ).toHaveLength(35);

    app.unmount();
  });

  it('renders the month grid from concrete schedules without hidden placeholders', async () => {
    schedulesState.getSchedules.mockResolvedValueOnce([
      makeSchedule(),
      makeSchedule({
        end: '2026-06-18T17:00:00.000000Z',
        event: {
          id: 'event-2',
          repeat_type: 'daily',
          schedule_type: 'repeat',
          title: 'Daily Standup',
          type: 'training',
        },
        event_id: 'event-2',
        id: 'schedule-2',
        start: '2026-06-18T08:30:00.000000Z',
      }),
      makeSchedule({
        end: '2026-06-21T17:00:00.000000Z',
        event: {
          end_date: '2026-06-21T17:00:00.000000Z',
          id: 'event-3',
          schedule_type: 'multiple_days',
          start_date: '2026-06-20T09:00:00.000000Z',
          title: 'Roadshow',
          type: 'business_trip',
        },
        event_id: 'event-3',
        id: 'schedule-3',
        one_day: false,
        start: '2026-06-20T09:00:00.000000Z',
      }),
    ]);

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    expect(
      element.querySelectorAll('[data-testid="schedule-day-cell"]').length,
    ).toBe(35);
    expect(
      element.querySelectorAll('[data-testid="schedule-create-day"]').length,
    ).toBe(35);
    expect(
      element.querySelector(
        '[data-testid="schedule-create-day"][data-create-day-key="2026-06-01"]',
      ),
    ).not.toBeNull();
    expect(
      element.querySelector(
        '[data-testid="schedule-create-day"][data-create-day-key="2026-07-05"]',
      ),
    ).not.toBeNull();
    const calendarContent = element.querySelector<HTMLElement>(
      '[data-testid="schedule-content"]',
    );

    expect(calendarContent?.textContent).toContain('Planning');
    expect(calendarContent?.textContent).toContain('Daily Standup');
    expect(calendarContent?.textContent).toContain('Roadshow');
    expect(calendarContent?.textContent).not.toContain('Loaded 3 schedules');
    expect(calendarContent?.textContent).not.toContain('private');

    app.unmount();
  });

  it('marks one-day, repeating, and multi-day schedules with different presentation attributes', async () => {
    schedulesState.getSchedules.mockResolvedValueOnce([
      makeSchedule(),
      makeSchedule({
        end: '2026-06-18T17:00:00.000000Z',
        event: {
          id: 'event-2',
          repeat_type: 'daily',
          schedule_type: 'repeat',
          title: 'Daily Standup',
          type: 'training',
        },
        event_id: 'event-2',
        id: 'schedule-2',
        start: '2026-06-18T08:30:00.000000Z',
      }),
      makeSchedule({
        end: '2026-06-21T17:00:00.000000Z',
        event: {
          end_date: '2026-06-21T17:00:00.000000Z',
          id: 'event-3',
          schedule_type: 'multiple_days',
          start_date: '2026-06-20T09:00:00.000000Z',
          title: 'Roadshow',
          type: 'business_trip',
        },
        event_id: 'event-3',
        id: 'schedule-3',
        one_day: false,
        start: '2026-06-20T09:00:00.000000Z',
      }),
    ]);

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    expect(
      element.querySelector<HTMLElement>('[data-schedule-id="schedule-1"]')
        ?.dataset.scheduleShape,
    ).toBe('one-day');
    expect(
      element.querySelector<HTMLElement>('[data-schedule-id="schedule-2"]')
        ?.dataset.scheduleShape,
    ).toBe('repeat');
    expect(
      element.querySelector<HTMLElement>('[data-schedule-id="schedule-3"]')
        ?.dataset.scheduleShape,
    ).toBe('multi-day');
    expect(
      element.querySelector<HTMLElement>('[data-schedule-id="schedule-1"]')
        ?.dataset.scheduleType,
    ).toBe('meeting');
    expect(
      element.querySelector<HTMLElement>('[data-schedule-id="schedule-1"]')
        ?.textContent,
    ).toContain('Meeting');
    expect(
      element.querySelector<HTMLElement>('[data-schedule-id="schedule-1"]')
        ?.textContent,
    ).toContain(formatScheduleTileMeta(makeSchedule()));
    expect(
      element.querySelector<HTMLElement>('[data-schedule-id="schedule-2"]')
        ?.dataset.scheduleType,
    ).toBe('training');
    expect(
      element.querySelector<HTMLElement>('[data-schedule-id="schedule-2"]')
        ?.textContent,
    ).toContain('Training');
    expect(
      element.querySelector<HTMLElement>('[data-schedule-id="schedule-2"]')
        ?.textContent,
    ).toContain(
      formatScheduleTileMeta(
        makeSchedule({
          end: '2026-06-18T17:00:00.000000Z',
          event: {
            id: 'event-2',
            repeat_type: 'daily',
            schedule_type: 'repeat',
            title: 'Daily Standup',
            type: 'training',
          },
          event_id: 'event-2',
          id: 'schedule-2',
          start: '2026-06-18T08:30:00.000000Z',
        }),
      ),
    );
    expect(
      element.querySelector<HTMLElement>('[data-schedule-id="schedule-3"]')
        ?.dataset.scheduleType,
    ).toBe('business_trip');
    expect(
      element.querySelector<HTMLElement>('[data-schedule-id="schedule-3"]')
        ?.textContent,
    ).not.toContain(
      formatScheduleTileMeta(
        makeSchedule({
          end: '2026-06-21T17:00:00.000000Z',
          event: {
            end_date: '2026-06-21T17:00:00.000000Z',
            id: 'event-3',
            schedule_type: 'multiple_days',
            start_date: '2026-06-20T09:00:00.000000Z',
            title: 'Roadshow',
            type: 'business_trip',
          },
          event_id: 'event-3',
          id: 'schedule-3',
          one_day: false,
          start: '2026-06-20T09:00:00.000000Z',
        }),
      ),
    );
    expect(
      element.querySelector<HTMLElement>('[data-schedule-id="schedule-3"]')
        ?.textContent,
    ).toContain('Roadshow');
    expect(
      element.querySelectorAll(
        '[data-schedule-id="schedule-3"][data-schedule-span="2"]',
      ),
    ).toHaveLength(1);
    expect(
      element.querySelector<HTMLElement>('[data-schedule-id="schedule-3"]')
        ?.dataset.scheduleSpan,
    ).toBe('2');
    expect(
      element
        .querySelector<HTMLElement>('[data-schedule-id="schedule-3"]')
        ?.getAttribute('style'),
    ).toContain('width: calc(200% + 1.1rem);');
    expect(
      element
        .querySelector<HTMLElement>(
          '[data-testid="schedule-segment-lane"][data-segment-lane-date="2026-06-19"]',
        )
        ?.querySelector('[data-schedule-id="schedule-3"]'),
    ).toBeNull();
    expect(
      element.querySelector<HTMLElement>(
        '[data-testid="schedule-segment-lane"][data-segment-lane-date="2026-06-20"]',
      )?.style.height,
    ).toBe('2.75rem');
    expect(
      element.querySelector<HTMLElement>(
        '[data-testid="schedule-segment-lane"][data-segment-lane-date="2026-06-20"]',
      )?.style.marginBottom,
    ).toBe('-0.563rem');
    expect(
      element.querySelector<HTMLElement>(
        '[data-testid="schedule-segment-lane"][data-segment-lane-date="2026-06-21"]',
      )?.style.height,
    ).toBe('2.75rem');
    expect(element.textContent).not.toContain('1D');
    expect(element.textContent).not.toContain('RP');
    expect(element.textContent).not.toContain('MD');

    app.unmount();
  });

  it('shows Monday-first weekdays and marks today without a text badge', async () => {
    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    const todayButton = element.querySelector<HTMLButtonElement>(
      'button[aria-label="Today"]',
    );

    expect(todayButton?.getAttribute('aria-pressed')).toBe('true');
    expect(
      element
        .querySelector<HTMLElement>('[data-day-key="2026-06-16"]')
        ?.getAttribute('aria-current'),
    ).toBe('date');
    expect(
      [
        ...element.querySelectorAll<HTMLElement>(
          '.grid.grid-cols-7.text-xs.font-bold.uppercase.tracking-wide > div',
        ),
      ].map((node) => node.textContent?.trim()?.slice(0, 3)),
    ).toEqual(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']);
    expect(
      element.querySelector<HTMLElement>('[data-day-key="2026-06-16"]')
        ?.className,
    ).toContain('bg-yellow-400/10');
    expect(
      element.querySelector<HTMLElement>(
        '[data-day-key="2026-06-16"] span.font-semibold',
      )?.className,
    ).toContain('underline');
    expect(
      element.querySelector<HTMLElement>('[data-day-key="2026-06-20"]')
        ?.className,
    ).toContain('bg-sky-400/10');
    expect(
      element.querySelector<HTMLElement>('[data-day-key="2026-06-21"]')
        ?.className,
    ).toContain('bg-pink-400/10');
    expect(
      element.querySelector<HTMLElement>('[data-day-key="2026-06-16"]')
        ?.textContent,
    ).not.toContain('Today');

    todayButton?.click();
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('button[aria-label="Next month"]')
      ?.click();
    await flushPromises();

    expect(todayButton?.getAttribute('aria-pressed')).toBe('false');

    app.unmount();
  });

  it('opens a detail drawer from a visible schedule and keeps loading inside the drawer shell', async () => {
    let resolveSchedule:
      | ((value: ReturnType<typeof makeSchedule>) => void)
      | undefined;

    schedulesState.getSchedule.mockImplementation(
      () =>
        new Promise((resolve) => {
          resolveSchedule = resolve;
        }),
    );

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-schedule-id="schedule-1"]')
      ?.click();

    await nextTick();

    expect(schedulesState.getSchedule).toHaveBeenCalledWith('schedule-1');
    expect(
      element.querySelector('[data-testid="schedule-detail-drawer"]'),
    ).not.toBeNull();
    expect(element.textContent).toContain('Loading month data');
    expect(
      element.querySelector('[data-testid="schedule-action-edit"]'),
    ).toBeNull();
    expect(
      element.querySelector('[data-testid="schedule-action-delete"]'),
    ).toBeNull();
    expect(
      element.querySelector('[data-testid="schedule-action-reuse"]'),
    ).toBeNull();
    expect(
      element.querySelector('[data-testid="schedule-action-join"]'),
    ).toBeNull();
    expect(
      element.querySelector('[data-testid="schedule-action-leave"]'),
    ).toBeNull();

    resolveSchedule?.(makeSchedule());
    await flushPromises();

    expect(element.textContent).toContain('Planning');

    app.unmount();
  });

  it('renders loaded occurrence detail with readable timing, collaborators, reminder state, and location', async () => {
    schedulesState.getSchedule.mockResolvedValueOnce(
      makeSchedule({
        end: '2026-06-20T17:00:00.000000Z',
        event: {
          has_reminder: true,
          note: 'Bring passport',
          observers: [
            {
              avatar: null,
              email: 'observer@example.com',
              id: 'user-3',
              name: 'Observer User',
            },
          ],
          participants: [
            {
              avatar: null,
              email: 'participant@example.com',
              id: 'user-2',
              name: 'Participant User',
            },
          ],
          physical_address: '123 Main St',
          remind_range: 'minute',
          remind_value: 15,
          repeat_end_time: '09:30',
          repeat_start_time: '09:00',
          repeat_type: 'daily',
          schedule_type: 'repeat',
          start_date: '2026-06-18T09:00:00.000000Z',
          title: 'Daily Standup',
          type: 'training',
        },
        start: '2026-06-18T09:00:00.000000Z',
      }),
    );

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-schedule-id="schedule-1"]')
      ?.click();
    await flushPromises();

    expect(element.textContent).toContain('Schedule detail');
    expect(element.textContent).toContain('Daily Standup');
    expect(element.textContent).toContain('Training');
    expect(
      element.querySelector('[data-testid="schedule-detail-type-badge"]')
        ?.className,
    ).toContain('bg-[#4478b8]');
    expect(
      element.querySelector('[data-testid="schedule-detail-type-badge"]')
        ?.className,
    ).toContain('border-[#4478b8]');
    expect(element.textContent).toContain(
      '18/06/2026 16:00 - 21/06/2026 00:00',
    );
    expect(element.textContent).toContain('Repeats daily');
    expect(element.textContent).toContain('Participant User');
    expect(element.textContent).toContain('Observer User');
    expect(element.textContent).toContain('Reminder 15 minute before');
    expect(element.textContent).toContain('123 Main St');
    expect(element.textContent).toContain('Bring passport');
    expect(
      element.querySelectorAll(
        '[data-testid="schedule-detail-participant-badge"]',
      ),
    ).toHaveLength(1);
    expect(
      element.querySelector('[data-testid="schedule-detail-participant-badge"]')
        ?.className,
    ).toContain('bg-primary');
    expect(
      element.querySelector('[data-testid="schedule-detail-time-icon"]'),
    ).not.toBeNull();
    expect(
      element.querySelector(
        '[data-testid="schedule-detail-participants-icon"]',
      ),
    ).not.toBeNull();
    expect(
      element.querySelector('[data-testid="schedule-detail-observers-icon"]'),
    ).not.toBeNull();
    expect(
      element.querySelectorAll(
        '[data-testid="schedule-detail-observer-badge"]',
      ),
    ).toHaveLength(1);
    expect(
      element.querySelector('[data-testid="schedule-detail-footer"]'),
    ).not.toBeNull();

    app.unmount();
  });

  it('collapses long collaborator lists until the user asks to view more', async () => {
    const collaborators = Array.from({ length: 10 }, (_, index) => ({
      avatar: null,
      email: `collaborator-${index + 1}@example.com`,
      id: `collaborator-${index + 1}`,
      name: `Collaborator ${index + 1}`,
    }));

    schedulesState.getSchedule.mockResolvedValueOnce(
      makeSchedule({
        event: {
          observers: collaborators,
          participants: collaborators,
        },
      }),
    );

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-schedule-id="schedule-1"]')
      ?.click();
    await flushPromises();

    expect(
      element.querySelectorAll(
        '[data-testid="schedule-detail-participant-badge"]',
      ),
    ).toHaveLength(8);
    expect(
      element.querySelectorAll(
        '[data-testid="schedule-detail-observer-badge"]',
      ),
    ).toHaveLength(8);
    expect(
      element.querySelector(
        '[data-testid="schedule-detail-show-more-participants"]',
      )?.textContent,
    ).toContain('+2 more users');

    element
      .querySelector<HTMLButtonElement>(
        '[data-testid="schedule-detail-show-more-participants"]',
      )
      ?.click();
    await flushPromises();

    expect(
      element.querySelectorAll(
        '[data-testid="schedule-detail-participant-badge"]',
      ),
    ).toHaveLength(10);
    expect(
      element.querySelector(
        '[data-testid="schedule-detail-collapse-participants"]',
      ),
    ).not.toBeNull();

    element
      .querySelector<HTMLButtonElement>(
        '[data-testid="schedule-detail-show-more-observers"]',
      )
      ?.click();
    await flushPromises();

    expect(
      element.querySelectorAll(
        '[data-testid="schedule-detail-observer-badge"]',
      ),
    ).toHaveLength(10);
    expect(
      element.querySelector(
        '[data-testid="schedule-detail-collapse-observers"]',
      ),
    ).not.toBeNull();

    app.unmount();
  });

  it('shows creator actions only for the event creator', async () => {
    schedulesState.getSchedule.mockResolvedValueOnce(
      makeSchedule({
        event: {
          created_by: 'user-1',
          observers: [
            {
              avatar: null,
              email: 'observer@example.com',
              id: 'user-3',
              name: 'Observer User',
            },
          ],
          participants: [
            {
              avatar: null,
              email: 'participant@example.com',
              id: 'user-2',
              name: 'Participant User',
            },
          ],
        },
      }),
    );

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-schedule-id="schedule-1"]')
      ?.click();
    await flushPromises();

    expect(
      element.querySelector('[data-testid="schedule-action-edit"]'),
    ).not.toBeNull();
    expect(
      element.querySelector('[data-testid="schedule-action-delete"]'),
    ).not.toBeNull();
    expect(
      element.querySelector('[data-testid="schedule-action-reuse"]'),
    ).not.toBeNull();
    expect(
      element.querySelector('[data-testid="schedule-action-join"]'),
    ).toBeNull();
    expect(
      element.querySelector('[data-testid="schedule-action-leave"]'),
    ).toBeNull();

    app.unmount();
  });

  it('shows only leave for a participant who is not the creator', async () => {
    userStoreState.userStore.userInfo.userId = 'user-2';
    schedulesState.getSchedules.mockResolvedValueOnce([
      makeSchedule({
        event: {
          created_by: 'user-1',
          participants: [
            {
              avatar: null,
              email: 'participant@example.com',
              id: 'user-2',
              name: 'Participant User',
            },
          ],
        },
      }),
    ]);
    schedulesState.getSchedule.mockResolvedValueOnce(
      makeSchedule({
        event: {
          created_by: 'user-1',
          observers: [
            {
              avatar: null,
              email: 'observer@example.com',
              id: 'user-3',
              name: 'Observer User',
            },
          ],
          participants: [
            {
              avatar: null,
              email: 'participant@example.com',
              id: 'user-2',
              name: 'Participant User',
            },
          ],
        },
      }),
    );

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-schedule-id="schedule-1"]')
      ?.click();
    await flushPromises();

    expect(
      element.querySelector('[data-testid="schedule-action-leave"]'),
    ).not.toBeNull();
    expect(
      element.querySelector('[data-testid="schedule-action-edit"]'),
    ).toBeNull();
    expect(
      element.querySelector('[data-testid="schedule-action-delete"]'),
    ).toBeNull();
    expect(
      element.querySelector('[data-testid="schedule-action-reuse"]'),
    ).toBeNull();
    expect(
      element.querySelector('[data-testid="schedule-action-join"]'),
    ).toBeNull();

    app.unmount();
  });

  it('shows only join for an observer who is not a participant', async () => {
    userStoreState.userStore.userInfo.userId = 'user-3';
    schedulesState.getSchedules.mockResolvedValueOnce([
      makeSchedule({
        event: {
          created_by: 'user-1',
          observers: [
            {
              avatar: null,
              email: 'observer@example.com',
              id: 'user-3',
              name: 'Observer User',
            },
          ],
          participants: [
            {
              avatar: null,
              email: 'participant@example.com',
              id: 'user-2',
              name: 'Participant User',
            },
          ],
        },
      }),
    ]);
    schedulesState.getSchedule.mockResolvedValueOnce(
      makeSchedule({
        event: {
          created_by: 'user-1',
          observers: [
            {
              avatar: null,
              email: 'observer@example.com',
              id: 'user-3',
              name: 'Observer User',
            },
          ],
          participants: [
            {
              avatar: null,
              email: 'participant@example.com',
              id: 'user-2',
              name: 'Participant User',
            },
          ],
        },
      }),
    );

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-schedule-id="schedule-1"]')
      ?.click();
    await flushPromises();

    expect(
      element.querySelector('[data-testid="schedule-action-join"]'),
    ).not.toBeNull();
    expect(
      element.querySelector('[data-testid="schedule-action-edit"]'),
    ).toBeNull();
    expect(
      element.querySelector('[data-testid="schedule-action-delete"]'),
    ).toBeNull();
    expect(
      element.querySelector('[data-testid="schedule-action-reuse"]'),
    ).toBeNull();
    expect(
      element.querySelector('[data-testid="schedule-action-leave"]'),
    ).toBeNull();

    app.unmount();
  });

  it('joins from the detail drawer, refreshes authoritative data, and keeps the drawer open when still visible', async () => {
    userStoreState.userStore.userInfo.userId = 'user-3';
    schedulesState.getSchedule
      .mockResolvedValueOnce(
        makeSchedule({
          event: {
            created_by: 'user-1',
            observers: [
              {
                avatar: null,
                email: 'observer@example.com',
                id: 'user-3',
                name: 'Observer User',
              },
            ],
            participants: [
              {
                avatar: null,
                email: 'participant@example.com',
                id: 'user-2',
                name: 'Participant User',
              },
            ],
          },
        }),
      )
      .mockResolvedValueOnce(
        makeSchedule({
          event: {
            created_by: 'user-1',
            observers: [],
            participants: [
              {
                avatar: null,
                email: 'participant@example.com',
                id: 'user-2',
                name: 'Participant User',
              },
              {
                avatar: null,
                email: 'observer@example.com',
                id: 'user-3',
                name: 'Observer User',
              },
            ],
            title: 'Planning Updated',
          },
        }),
      );
    schedulesState.getSchedules
      .mockResolvedValueOnce([
        makeSchedule({
          event: {
            created_by: 'user-1',
            observers: [
              {
                avatar: null,
                email: 'observer@example.com',
                id: 'user-3',
                name: 'Observer User',
              },
            ],
            participants: [
              {
                avatar: null,
                email: 'participant@example.com',
                id: 'user-2',
                name: 'Participant User',
              },
            ],
          },
        }),
      ])
      .mockResolvedValueOnce([
        makeSchedule({
          event: {
            created_by: 'user-1',
            participants: [
              {
                avatar: null,
                email: 'participant@example.com',
                id: 'user-2',
                name: 'Participant User',
              },
              {
                avatar: null,
                email: 'observer@example.com',
                id: 'user-3',
                name: 'Observer User',
              },
            ],
            title: 'Planning Updated',
          },
        }),
      ]);

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-schedule-id="schedule-1"]')
      ?.click();
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-testid="schedule-action-join"]')
      ?.click();
    await flushPromises();
    await flushPromises();

    expect(schedulesState.joinScheduleEvent).toHaveBeenCalledWith('event-1');
    expect(schedulesState.getSchedules).toHaveBeenNthCalledWith(
      2,
      expectedVisibleRangeParams('2026-06', 'all'),
    );
    expect(schedulesState.getSchedule).toHaveBeenNthCalledWith(2, 'schedule-1');
    expect(notificationState.success).toHaveBeenCalledWith({
      message: 'Joined schedule',
    });
    expect(
      element.querySelector('[data-testid="schedule-detail-drawer"]'),
    ).not.toBeNull();
    expect(element.textContent).toContain('Planning Updated');

    app.unmount();
  });

  it('leaves from the detail drawer and closes it when the refreshed filter no longer includes the schedule', async () => {
    userStoreState.userStore.userInfo.userId = 'user-2';
    schedulesState.getSchedule.mockResolvedValueOnce(
      makeSchedule({
        event: {
          created_by: 'user-1',
          observers: [],
          participants: [
            {
              avatar: null,
              email: 'participant@example.com',
              id: 'user-2',
              name: 'Participant User',
            },
          ],
        },
      }),
    );
    schedulesState.getSchedules
      .mockResolvedValueOnce([
        makeSchedule({
          event: {
            created_by: 'user-1',
            participants: [
              {
                avatar: null,
                email: 'participant@example.com',
                id: 'user-2',
                name: 'Participant User',
              },
            ],
          },
        }),
      ])
      .mockResolvedValueOnce([
        makeSchedule({
          event: {
            created_by: 'user-1',
            participants: [
              {
                avatar: null,
                email: 'participant@example.com',
                id: 'user-2',
                name: 'Participant User',
              },
            ],
          },
        }),
      ])
      .mockResolvedValueOnce([]);

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    const visibilityFilter = element.querySelector<HTMLSelectElement>(
      '[data-testid="visibility-filter"]',
    );

    if (visibilityFilter === null) {
      throw new Error('Visibility filter not found.');
    }

    visibilityFilter.value = 'observed';
    visibilityFilter.dispatchEvent(new Event('change'));
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-schedule-id="schedule-1"]')
      ?.click();
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-testid="schedule-action-leave"]')
      ?.click();
    await flushPromises();

    expect(schedulesState.leaveScheduleEvent).toHaveBeenCalledWith('event-1');
    expect(schedulesState.getSchedules).toHaveBeenNthCalledWith(
      3,
      expectedVisibleRangeParams('2026-06', 'observed'),
    );
    expect(schedulesState.getSchedule).toHaveBeenCalledTimes(1);
    expect(notificationState.success).toHaveBeenCalledWith({
      message: 'Left schedule',
    });
    expect(
      element.querySelector('[data-testid="schedule-detail-drawer"]'),
    ).toBeNull();
    expect(
      element.querySelectorAll('[data-testid="schedule-day-cell"]'),
    ).toHaveLength(35);

    app.unmount();
  });

  it('routes join failures through shared request feedback', async () => {
    userStoreState.userStore.userInfo.userId = 'user-3';
    schedulesState.getSchedules.mockResolvedValueOnce([
      makeSchedule({
        event: {
          created_by: 'user-1',
          observers: [
            {
              avatar: null,
              email: 'observer@example.com',
              id: 'user-3',
              name: 'Observer User',
            },
          ],
          participants: [],
        },
      }),
    ]);
    schedulesState.getSchedule.mockResolvedValueOnce(
      makeSchedule({
        event: {
          created_by: 'user-1',
          observers: [
            {
              avatar: null,
              email: 'observer@example.com',
              id: 'user-3',
              name: 'Observer User',
            },
          ],
          participants: [],
        },
      }),
    );
    const error = new Error('join failed');
    schedulesState.joinScheduleEvent.mockRejectedValueOnce(error);

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-schedule-id="schedule-1"]')
      ?.click();
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-testid="schedule-action-join"]')
      ?.click();
    await flushPromises();

    expect(requestFeedbackState.showRequestError).toHaveBeenCalledWith(
      error,
      'Unexpected error',
      'Unexpected schedule participation error:',
    );
    expect(notificationState.success).not.toHaveBeenCalled();

    app.unmount();
  });

  it('opens a confirmation dialog before delete and only deletes after confirm', async () => {
    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-schedule-id="schedule-1"]')
      ?.click();
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>(
        '[data-testid="schedule-action-delete"]',
      )
      ?.click();
    await flushPromises();

    expect(schedulesState.deleteScheduleEvent).not.toHaveBeenCalled();
    expect(
      element.querySelector('[data-testid="schedule-delete-modal"]'),
    ).not.toBeNull();

    element
      .querySelector<HTMLButtonElement>(
        '[data-testid="schedule-delete-confirm"]',
      )
      ?.click();
    await flushPromises();

    expect(schedulesState.deleteScheduleEvent).toHaveBeenCalledWith('event-1');

    app.unmount();
  });

  it('deletes from the detail drawer, refreshes month data, and closes back to month context', async () => {
    schedulesState.getSchedules
      .mockResolvedValueOnce([makeSchedule()])
      .mockResolvedValueOnce([]);

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-schedule-id="schedule-1"]')
      ?.click();
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>(
        '[data-testid="schedule-action-delete"]',
      )
      ?.click();
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>(
        '[data-testid="schedule-delete-confirm"]',
      )
      ?.click();
    await flushPromises();

    expect(schedulesState.getSchedules).toHaveBeenNthCalledWith(
      2,
      expectedVisibleRangeParams('2026-06', 'all'),
    );
    expect(notificationState.success).toHaveBeenCalledWith({
      message: 'Deleted schedule',
    });
    expect(
      element.querySelector('[data-testid="schedule-detail-drawer"]'),
    ).toBeNull();
    expect(
      element.querySelectorAll('[data-testid="schedule-day-cell"]'),
    ).toHaveLength(35);

    app.unmount();
  });

  it('starts reuse inline by opening the shared authoring drawer with a seeded draft', async () => {
    schedulesState.getSchedule.mockResolvedValueOnce(
      makeSchedule({
        event: {
          note: 'Bring passport',
          physical_address: '123 Main St',
          title: 'Planning Template',
        },
      }),
    );

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-schedule-id="schedule-1"]')
      ?.click();
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-testid="schedule-action-reuse"]')
      ?.click();
    await flushPromises();

    expect(
      element.querySelector('[data-testid="schedule-authoring-drawer"]'),
    ).not.toBeNull();
    expect(
      element.querySelector<HTMLInputElement>(
        '[data-testid="schedule-form-title"]',
      )?.value,
    ).toBe('Planning Template');
    expect(
      element.querySelector<HTMLInputElement>(
        '[data-testid="schedule-form-physical-address"]',
      )?.value,
    ).toBe('123 Main St');
    expect(
      element.querySelector<HTMLTextAreaElement>(
        '[data-testid="schedule-form-note"]',
      )?.value,
    ).toBe('Bring passport');

    app.unmount();
  });

  it('submits reuse through create, refreshes month data, and closes the drawer', async () => {
    schedulesState.getSchedule.mockResolvedValueOnce(
      makeSchedule({
        event: {
          id: 'event-1',
          note: 'Bring passport',
          physical_address: '123 Main St',
          title: 'Planning Template',
        },
      }),
    );

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-schedule-id="schedule-1"]')
      ?.click();
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-testid="schedule-action-reuse"]')
      ?.click();
    await flushPromises();

    expect(element.textContent).toContain('Reuse schedule');

    element
      .querySelector<HTMLButtonElement>('[data-testid="schedule-form-submit"]')
      ?.click();
    await flushPromises();

    expect(schedulesState.createScheduleEvent).toHaveBeenCalledWith({
      company_name: null,
      company_phone_number: null,
      end_date: '2026-06-16T17:00',
      has_reminder: false,
      is_general: false,
      note: 'Bring passport',
      observers: [],
      participants: [],
      physical_address: '123 Main St',
      privacy: 'public',
      remind_range: null,
      remind_value: null,
      repeat_end_time: null,
      repeat_pattern: null,
      repeat_start_time: null,
      repeat_type: null,
      schedule_type: 'ordinary',
      start_date: '2026-06-16T16:00',
      title: 'Planning Template',
      type: 'meeting',
    });
    expect(schedulesState.updateScheduleEvent).not.toHaveBeenCalled();
    expect(schedulesState.getSchedules).toHaveBeenNthCalledWith(
      2,
      expectedVisibleRangeParams('2026-06', 'all'),
    );
    expect(notificationState.success).toHaveBeenCalledWith({
      message: 'Created schedule',
    });
    expect(
      element.querySelector('[data-testid="schedule-authoring-drawer"]'),
    ).toBeNull();

    app.unmount();
  });

  it('keeps the authoring drawer open and avoids page-level loading while create is in flight', async () => {
    const createRequest = deferredPromise<{ id: string; schedules: never[] }>();
    schedulesState.createScheduleEvent.mockReturnValueOnce(
      createRequest.promise,
    );

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    element
      .querySelector<HTMLButtonElement>(
        '[data-testid="schedule-create-day"][data-create-day-key="2026-06-16"]',
      )
      ?.click();
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-testid="schedule-form-submit"]')
      ?.click();
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-testid="schedule-detail-close"]')
      ?.click();
    await flushPromises();

    expect(
      element.querySelector('[data-testid="schedule-authoring-drawer"]'),
    ).not.toBeNull();
    expect(element.textContent).not.toContain('Loading month data');
    expect(schedulesState.getSchedules).toHaveBeenCalledTimes(1);

    createRequest.resolve({
      id: 'event-created',
      schedules: [],
    });
    await flushPromises();

    expect(
      element.querySelector('[data-testid="schedule-authoring-drawer"]'),
    ).toBeNull();

    app.unmount();
  });

  it('opens create from day context in the shared authoring drawer with the selected date seeded', async () => {
    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    element
      .querySelector<HTMLButtonElement>(
        '[data-testid="schedule-create-day"][data-create-day-key="2026-06-16"]',
      )
      ?.click();
    await flushPromises();

    expect(
      element.querySelector('[data-testid="schedule-authoring-drawer"]'),
    ).not.toBeNull();
    expect(element.textContent).toContain('Create schedule');
    expect(
      element.querySelector<HTMLInputElement>(
        '[data-testid="schedule-form-start-date"]',
      )?.value,
    ).toBe('2026-06-16');
    expect(
      element.querySelector<HTMLInputElement>(
        '[data-testid="schedule-form-end-date"]',
      )?.value,
    ).toBe('2026-06-16');
    expect(
      element.querySelector<HTMLInputElement>(
        '[data-testid="schedule-form-start-time"]',
      )?.value,
    ).toBe('08:00');
    expect(
      element.querySelector<HTMLInputElement>(
        '[data-testid="schedule-form-end-time"]',
      )?.value,
    ).toBe('17:30');
    expect(schedulesState.deleteScheduleEvent).not.toHaveBeenCalled();
    expect(schedulesState.joinScheduleEvent).not.toHaveBeenCalled();
    expect(schedulesState.leaveScheduleEvent).not.toHaveBeenCalled();

    app.unmount();
  });

  it('hides create entry points for users without a company', async () => {
    authStoreState.authStore.user.company_id = null;

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    expect(
      element.querySelector(
        '[data-testid="schedule-create-day"][data-create-day-key="2026-06-16"]',
      ),
    ).toBeNull();
    expect(
      element.querySelector('[data-testid="schedule-authoring-drawer"]'),
    ).toBeNull();
    expect(
      element.querySelector('[data-testid="schedule-form-company-required"]'),
    ).toBeNull();
    expect(element.textContent).not.toContain('Company membership required');
    expect(element.textContent).not.toContain(
      'You need to belong to a company before you can create a schedule.',
    );
    expect(
      element.querySelector('[data-testid="schedule-form-title"]'),
    ).toBeNull();
    expect(
      element.querySelector('[data-testid="schedule-form-submit"]'),
    ).toBeNull();
    expect(usersState.getAll).not.toHaveBeenCalled();
    expect(schedulesState.createScheduleEvent).not.toHaveBeenCalled();

    app.unmount();
  });

  it('cancels create and preserves the current month and filter context', async () => {
    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('button[aria-label="Next month"]')
      ?.click();
    await flushPromises();

    const visibilityFilter = element.querySelector<HTMLSelectElement>(
      '[data-testid="visibility-filter"]',
    );

    if (visibilityFilter === null) {
      throw new Error('Visibility filter not found.');
    }

    visibilityFilter.value = 'observed';
    visibilityFilter.dispatchEvent(new Event('change'));
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>(
        '[data-testid="schedule-create-day"][data-create-day-key="2026-07-01"]',
      )
      ?.click();
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-testid="schedule-form-cancel"]')
      ?.click();
    await flushPromises();

    expect(
      element.querySelector('[data-testid="schedule-authoring-drawer"]'),
    ).toBeNull();
    expect(
      element.querySelector<HTMLInputElement>('[data-testid="month-picker"]')
        ?.value,
    ).toBe('2026-07');
    expect(visibilityFilter.value).toBe('observed');
    expect(schedulesState.getSchedules).toHaveBeenCalledTimes(3);
    expect(schedulesState.deleteScheduleEvent).not.toHaveBeenCalled();
    expect(schedulesState.joinScheduleEvent).not.toHaveBeenCalled();
    expect(schedulesState.leaveScheduleEvent).not.toHaveBeenCalled();

    app.unmount();
  });

  it('opens edit in the shared authoring drawer with baseline fields and seeded event values', async () => {
    schedulesState.getSchedule.mockResolvedValueOnce(
      makeSchedule({
        event: {
          end_date: '2026-06-18T00:00:00.000000Z',
          has_reminder: true,
          note: 'Bring passport',
          observers: [
            {
              avatar: null,
              email: 'observer@example.com',
              id: 'user-2',
              name: 'Participant User',
            },
          ],
          participants: [
            {
              avatar: null,
              email: 'owner@example.com',
              id: 'user-1',
              name: 'Owner User',
            },
          ],
          physical_address: '123 Main St',
          privacy: 'private',
          remind_range: 'hour',
          remind_value: 2,
          schedule_type: 'multiple_days',
          start_date: '2026-06-16T00:00:00.000000Z',
          title: 'Planning Edit',
          type: 'seminar',
        },
      }),
    );

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-schedule-id="schedule-1"]')
      ?.click();
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-testid="schedule-action-edit"]')
      ?.click();
    await flushPromises();

    expect(
      element.querySelector('[data-testid="schedule-authoring-drawer"]'),
    ).not.toBeNull();
    expect(element.textContent).toContain('Edit schedule');
    expect(
      element.querySelector<HTMLInputElement>(
        '[data-testid="schedule-form-title"]',
      )?.value,
    ).toBe('Planning Edit');
    expect(
      element.querySelector<HTMLSelectElement>(
        '[data-testid="schedule-form-type"]',
      )?.value,
    ).toBe('seminar');
    expect(
      element.querySelector<HTMLSelectElement>(
        '[data-testid="schedule-form-schedule-type"]',
      )?.value,
    ).toBe('multiple_days');
    expect(
      element.querySelector<HTMLInputElement>(
        '[data-testid="schedule-form-start-date"]',
      )?.value,
    ).toBe('2026-06-16');
    expect(
      element.querySelector<HTMLInputElement>(
        '[data-testid="schedule-form-end-date"]',
      )?.value,
    ).toBe('2026-06-18');
    expect(
      element.querySelector('[data-testid="schedule-form-start-time"]'),
    ).toBeNull();
    expect(
      element.querySelector('[data-testid="schedule-form-end-time"]'),
    ).toBeNull();
    expect(
      element.querySelector<HTMLInputElement>(
        '[data-testid="schedule-form-physical-address"]',
      )?.value,
    ).toBe('123 Main St');
    expect(
      element.querySelector<HTMLTextAreaElement>(
        '[data-testid="schedule-form-note"]',
      )?.value,
    ).toBe('Bring passport');
    expect(
      element.querySelector<HTMLInputElement>(
        '[data-testid="schedule-form-remind-value"]',
      )?.value,
    ).toBe('2');
    expect(
      element.querySelector<HTMLSelectElement>(
        '[data-testid="schedule-form-remind-range"]',
      )?.value,
    ).toBe('hour');
    expect(
      element.querySelector<HTMLInputElement>(
        '[data-testid="schedule-form-has-reminder"]',
      )?.checked,
    ).toBe(true);
    expect(
      element.querySelector('[data-testid="schedule-form-company-name"]'),
    ).toBeNull();
    expect(
      element.querySelector(
        '[data-testid="schedule-form-company-phone-number"]',
      ),
    ).toBeNull();
    expect(
      element.querySelector<HTMLElement>(
        '[data-testid="schedule-authoring-drawer"]',
      )?.dataset.payloadCompanyName,
    ).toBe('null');
    expect(
      element.querySelector<HTMLElement>(
        '[data-testid="schedule-authoring-drawer"]',
      )?.dataset.payloadCompanyPhoneNumber,
    ).toBe('null');
    expect(usersState.getAll).toHaveBeenCalledWith({
      department_company_id: 'company-1',
    });
    expect(schedulesState.deleteScheduleEvent).not.toHaveBeenCalled();
    expect(schedulesState.joinScheduleEvent).not.toHaveBeenCalled();
    expect(schedulesState.leaveScheduleEvent).not.toHaveBeenCalled();

    app.unmount();
  });

  it('reveals repeat controls only for repeat schedules and marks the required repeat fields', async () => {
    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    element
      .querySelector<HTMLButtonElement>(
        '[data-testid="schedule-create-day"][data-create-day-key="2026-06-16"]',
      )
      ?.click();
    await flushPromises();

    expect(
      element.querySelector('[data-testid="schedule-form-repeat-section"]'),
    ).toBeNull();

    const scheduleType = element.querySelector<HTMLSelectElement>(
      '[data-testid="schedule-form-schedule-type"]',
    );

    if (scheduleType === null) {
      throw new Error('Schedule type select not found.');
    }

    scheduleType.value = 'repeat';
    scheduleType.dispatchEvent(new Event('change'));
    await flushPromises();

    expect(
      element.querySelector('[data-testid="schedule-form-repeat-section"]'),
    ).not.toBeNull();
    expect(
      element
        .querySelector<HTMLSelectElement>(
          '[data-testid="schedule-form-repeat-type"]',
        )
        ?.getAttribute('aria-required'),
    ).toBe('true');
    expect(
      element.querySelector('[data-testid="schedule-form-start-time"]'),
    ).not.toBeNull();
    expect(
      element.querySelector('[data-testid="schedule-form-end-time"]'),
    ).not.toBeNull();
    expect(
      element.querySelector<HTMLElement>(
        '[data-testid="schedule-authoring-drawer"]',
      )?.dataset.payloadScheduleType,
    ).toBe('repeat');

    app.unmount();
  });

  it('keeps weekly repeat pattern values as backend weekday numbers', async () => {
    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    element
      .querySelector<HTMLButtonElement>(
        '[data-testid="schedule-create-day"][data-create-day-key="2026-06-16"]',
      )
      ?.click();
    await flushPromises();

    const scheduleType = element.querySelector<HTMLSelectElement>(
      '[data-testid="schedule-form-schedule-type"]',
    );

    if (scheduleType === null) {
      throw new Error('Schedule type select not found.');
    }

    scheduleType.value = 'repeat';
    scheduleType.dispatchEvent(new Event('change'));
    await flushPromises();

    const repeatType = element.querySelector<HTMLSelectElement>(
      '[data-testid="schedule-form-repeat-type"]',
    );

    if (repeatType === null) {
      throw new Error('Repeat type select not found.');
    }

    repeatType.value = 'weekly';
    repeatType.dispatchEvent(new Event('change'));
    await flushPromises();

    expect(
      element
        .querySelector<HTMLElement>(
          '[data-testid="schedule-form-repeat-pattern-grid"]',
        )
        ?.className.includes('grid-cols-4'),
    ).toBe(true);

    element
      .querySelector<HTMLButtonElement>(
        '[data-testid="schedule-form-repeat-pattern-1"]',
      )
      ?.click();
    element
      .querySelector<HTMLButtonElement>(
        '[data-testid="schedule-form-repeat-pattern-3"]',
      )
      ?.click();
    await flushPromises();

    const repeatStartTime = element.querySelector<HTMLInputElement>(
      '[data-testid="schedule-form-start-time"]',
    );
    const repeatEndTime = element.querySelector<HTMLInputElement>(
      '[data-testid="schedule-form-end-time"]',
    );

    if (repeatStartTime === null || repeatEndTime === null) {
      throw new Error('Repeat time inputs not found.');
    }

    repeatStartTime.value = '09:00';
    repeatStartTime.dispatchEvent(new Event('input'));
    repeatEndTime.value = '09:30';
    repeatEndTime.dispatchEvent(new Event('input'));
    await flushPromises();

    expect(
      element.querySelector<HTMLElement>(
        '[data-testid="schedule-authoring-drawer"]',
      )?.dataset.payloadRepeatType,
    ).toBe('weekly');
    expect(
      element.querySelector<HTMLElement>(
        '[data-testid="schedule-authoring-drawer"]',
      )?.dataset.payloadRepeatPattern,
    ).toBe('[1,3]');
    expect(
      element.querySelector<HTMLElement>(
        '[data-testid="schedule-authoring-drawer"]',
      )?.dataset.payloadRepeatStartTime,
    ).toBe('09:00');
    expect(
      element.querySelector<HTMLElement>(
        '[data-testid="schedule-authoring-drawer"]',
      )?.dataset.payloadRepeatEndTime,
    ).toBe('09:30');
    expect(
      element
        .querySelector<HTMLButtonElement>(
          '[data-testid="schedule-form-repeat-pattern-1"]',
        )
        ?.className.includes('bg-primary'),
    ).toBe(true);
    expect(schedulesState.deleteScheduleEvent).not.toHaveBeenCalled();
    expect(schedulesState.joinScheduleEvent).not.toHaveBeenCalled();
    expect(schedulesState.leaveScheduleEvent).not.toHaveBeenCalled();

    app.unmount();
  });

  it('supports monthly repeat pattern selection and clears stale pattern values when repeat type changes', async () => {
    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    element
      .querySelector<HTMLButtonElement>(
        '[data-testid="schedule-create-day"][data-create-day-key="2026-06-16"]',
      )
      ?.click();
    await flushPromises();

    const scheduleType = element.querySelector<HTMLSelectElement>(
      '[data-testid="schedule-form-schedule-type"]',
    );

    if (scheduleType === null) {
      throw new Error('Schedule type select not found.');
    }

    scheduleType.value = 'repeat';
    scheduleType.dispatchEvent(new Event('change'));
    await flushPromises();

    const repeatType = element.querySelector<HTMLSelectElement>(
      '[data-testid="schedule-form-repeat-type"]',
    );

    if (repeatType === null) {
      throw new Error('Repeat type select not found.');
    }

    repeatType.value = 'monthly';
    repeatType.dispatchEvent(new Event('change'));
    await flushPromises();

    expect(
      element
        .querySelector<HTMLElement>(
          '[data-testid="schedule-form-repeat-pattern-grid"]',
        )
        ?.className.includes('grid-cols-8'),
    ).toBe(true);

    element
      .querySelector<HTMLButtonElement>(
        '[data-testid="schedule-form-repeat-pattern-15"]',
      )
      ?.click();
    await flushPromises();

    expect(
      element.querySelector<HTMLElement>(
        '[data-testid="schedule-authoring-drawer"]',
      )?.dataset.payloadRepeatPattern,
    ).toBe('[15]');

    repeatType.value = 'daily';
    repeatType.dispatchEvent(new Event('change'));
    await flushPromises();

    expect(
      element.querySelector(
        '[data-testid="schedule-form-repeat-pattern-group"]',
      ),
    ).toBeNull();
    expect(
      element.querySelector<HTMLElement>(
        '[data-testid="schedule-authoring-drawer"]',
      )?.dataset.payloadRepeatType,
    ).toBe('daily');
    expect(
      element.querySelector<HTMLElement>(
        '[data-testid="schedule-authoring-drawer"]',
      )?.dataset.payloadRepeatPattern,
    ).toBe('null');

    app.unmount();
  });

  it('selects all repeat pattern values for the active repeat type', async () => {
    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    element
      .querySelector<HTMLButtonElement>(
        '[data-testid="schedule-create-day"][data-create-day-key="2026-06-16"]',
      )
      ?.click();
    await flushPromises();

    const scheduleType = element.querySelector<HTMLSelectElement>(
      '[data-testid="schedule-form-schedule-type"]',
    );

    if (scheduleType === null) {
      throw new Error('Schedule type select not found.');
    }

    scheduleType.value = 'repeat';
    scheduleType.dispatchEvent(new Event('change'));
    await flushPromises();

    const repeatType = element.querySelector<HTMLSelectElement>(
      '[data-testid="schedule-form-repeat-type"]',
    );

    if (repeatType === null) {
      throw new Error('Repeat type select not found.');
    }

    repeatType.value = 'weekly';
    repeatType.dispatchEvent(new Event('change'));
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>(
        '[data-testid="schedule-form-repeat-pattern-select-all"]',
      )
      ?.click();
    await flushPromises();

    expect(
      element.querySelector<HTMLElement>(
        '[data-testid="schedule-authoring-drawer"]',
      )?.dataset.payloadRepeatPattern,
    ).toBe('[0,1,2,3,4,5,6]');

    element
      .querySelector<HTMLButtonElement>(
        '[data-testid="schedule-form-repeat-pattern-select-all"]',
      )
      ?.click();
    await flushPromises();

    expect(
      element.querySelector<HTMLElement>(
        '[data-testid="schedule-authoring-drawer"]',
      )?.dataset.payloadRepeatPattern,
    ).toBe('null');

    repeatType.value = 'monthly';
    repeatType.dispatchEvent(new Event('change'));
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>(
        '[data-testid="schedule-form-repeat-pattern-select-all"]',
      )
      ?.click();
    await flushPromises();

    expect(
      element.querySelector<HTMLElement>(
        '[data-testid="schedule-authoring-drawer"]',
      )?.dataset.payloadRepeatPattern,
    ).toBe(
      '[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31]',
    );

    element
      .querySelector<HTMLButtonElement>(
        '[data-testid="schedule-form-repeat-pattern-select-all"]',
      )
      ?.click();
    await flushPromises();

    expect(
      element.querySelector<HTMLElement>(
        '[data-testid="schedule-authoring-drawer"]',
      )?.dataset.payloadRepeatPattern,
    ).toBe('null');

    app.unmount();
  });

  it('submits repeat pattern values as an array payload', async () => {
    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    element
      .querySelector<HTMLButtonElement>(
        '[data-testid="schedule-create-day"][data-create-day-key="2026-06-16"]',
      )
      ?.click();
    await flushPromises();

    const scheduleType = element.querySelector<HTMLSelectElement>(
      '[data-testid="schedule-form-schedule-type"]',
    );

    if (scheduleType === null) {
      throw new Error('Schedule type select not found.');
    }

    scheduleType.value = 'repeat';
    scheduleType.dispatchEvent(new Event('change'));
    await flushPromises();

    const repeatType = element.querySelector<HTMLSelectElement>(
      '[data-testid="schedule-form-repeat-type"]',
    );

    if (repeatType === null) {
      throw new Error('Repeat type select not found.');
    }

    repeatType.value = 'weekly';
    repeatType.dispatchEvent(new Event('change'));
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>(
        '[data-testid="schedule-form-repeat-pattern-1"]',
      )
      ?.click();
    element
      .querySelector<HTMLButtonElement>(
        '[data-testid="schedule-form-repeat-pattern-3"]',
      )
      ?.click();
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-testid="schedule-form-submit"]')
      ?.click();
    await flushPromises();

    expect(schedulesState.createScheduleEvent).toHaveBeenCalledWith(
      expect.objectContaining({
        repeat_pattern: [1, 3],
        repeat_type: 'weekly',
        schedule_type: 'repeat',
      }),
    );

    app.unmount();
  });

  it('submits create through schedule-events, refreshes month data, and closes the drawer', async () => {
    schedulesState.getSchedules
      .mockResolvedValueOnce([makeSchedule()])
      .mockResolvedValueOnce([
        makeSchedule({
          event: {
            id: 'event-created',
            title: 'Created Planning',
          },
          event_id: 'event-created',
          id: 'schedule-created',
        }),
      ]);

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    element
      .querySelector<HTMLButtonElement>(
        '[data-testid="schedule-create-day"][data-create-day-key="2026-06-16"]',
      )
      ?.click();
    await flushPromises();

    const titleInput = element.querySelector<HTMLInputElement>(
      '[data-testid="schedule-form-title"]',
    );

    if (titleInput === null) {
      throw new Error('Title input not found.');
    }

    titleInput.value = 'Created Planning';
    titleInput.dispatchEvent(new Event('input'));
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-testid="schedule-form-submit"]')
      ?.click();
    await flushPromises();

    expect(schedulesState.createScheduleEvent).toHaveBeenCalledWith({
      company_name: null,
      company_phone_number: null,
      end_date: '2026-06-16T17:30',
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
      start_date: '2026-06-16T08:00',
      title: 'Created Planning',
      type: 'meeting',
    });
    expect(schedulesState.getSchedules).toHaveBeenNthCalledWith(
      2,
      expectedVisibleRangeParams('2026-06', 'all'),
    );
    expect(notificationState.success).toHaveBeenCalledWith({
      message: 'Created schedule',
    });
    expect(
      element.querySelector('[data-testid="schedule-authoring-drawer"]'),
    ).toBeNull();

    app.unmount();
  });

  it('submits edit through schedule-events, refreshes month data, and closes the drawer', async () => {
    schedulesState.getSchedule.mockResolvedValueOnce(
      makeSchedule({
        event: {
          id: 'event-1',
          title: 'Planning Edit',
        },
      }),
    );

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-schedule-id="schedule-1"]')
      ?.click();
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-testid="schedule-action-edit"]')
      ?.click();
    await flushPromises();

    const titleInput = element.querySelector<HTMLInputElement>(
      '[data-testid="schedule-form-title"]',
    );

    if (titleInput === null) {
      throw new Error('Title input not found.');
    }

    titleInput.value = 'Planning Edit Saved';
    titleInput.dispatchEvent(new Event('input'));
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-testid="schedule-form-submit"]')
      ?.click();
    await flushPromises();

    expect(schedulesState.updateScheduleEvent).toHaveBeenCalledWith('event-1', {
      company_name: null,
      company_phone_number: null,
      end_date: '2026-06-16T17:00',
      has_reminder: false,
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
      start_date: '2026-06-16T16:00',
      title: 'Planning Edit Saved',
      type: 'meeting',
    });
    expect(notificationState.success).toHaveBeenCalledWith({
      message: 'Updated schedule',
    });
    expect(
      element.querySelector('[data-testid="schedule-authoring-drawer"]'),
    ).toBeNull();

    app.unmount();
  });

  it('keeps the drawer open and reports request errors when create fails', async () => {
    const error = new Error('Validation failed');
    schedulesState.createScheduleEvent.mockRejectedValueOnce(error);

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    element
      .querySelector<HTMLButtonElement>(
        '[data-testid="schedule-create-day"][data-create-day-key="2026-06-16"]',
      )
      ?.click();
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-testid="schedule-form-submit"]')
      ?.click();
    await flushPromises();

    expect(requestFeedbackState.showRequestError).toHaveBeenCalledWith(
      error,
      'Unexpected error',
      'Unexpected schedule authoring error:',
    );
    expect(
      element.querySelector('[data-testid="schedule-authoring-drawer"]'),
    ).not.toBeNull();
    expect(notificationState.success).not.toHaveBeenCalled();

    app.unmount();
  });

  it('keeps the drawer open and reports request errors when reuse create fails', async () => {
    const error = new Error('Validation failed');
    schedulesState.createScheduleEvent.mockRejectedValueOnce(error);
    schedulesState.getSchedule.mockResolvedValueOnce(
      makeSchedule({
        event: {
          id: 'event-1',
          title: 'Planning Template',
        },
      }),
    );

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-schedule-id="schedule-1"]')
      ?.click();
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-testid="schedule-action-reuse"]')
      ?.click();
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-testid="schedule-form-submit"]')
      ?.click();
    await flushPromises();

    expect(requestFeedbackState.showRequestError).toHaveBeenCalledWith(
      error,
      'Unexpected error',
      'Unexpected schedule authoring error:',
    );
    expect(schedulesState.updateScheduleEvent).not.toHaveBeenCalled();
    expect(
      element.querySelector('[data-testid="schedule-authoring-drawer"]'),
    ).not.toBeNull();
    expect(notificationState.success).not.toHaveBeenCalled();

    app.unmount();
  });

  it('keeps the detail drawer open and ignores close while join is in flight', async () => {
    userStoreState.userStore.userInfo.userId = 'user-3';
    schedulesState.getSchedules.mockResolvedValueOnce([
      makeSchedule({
        event: {
          created_by: 'user-1',
          observers: [
            {
              avatar: null,
              email: 'observer@example.com',
              id: 'user-3',
              name: 'Observer User',
            },
          ],
          participants: [],
        },
      }),
    ]);
    schedulesState.getSchedule.mockResolvedValueOnce(
      makeSchedule({
        event: {
          created_by: 'user-1',
          observers: [
            {
              avatar: null,
              email: 'observer@example.com',
              id: 'user-3',
              name: 'Observer User',
            },
          ],
          participants: [],
        },
      }),
    );
    const joinRequest = deferredPromise<{ message: string }>();
    schedulesState.joinScheduleEvent.mockReturnValueOnce(joinRequest.promise);

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-schedule-id="schedule-1"]')
      ?.click();
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-testid="schedule-action-join"]')
      ?.click();
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-testid="schedule-detail-close"]')
      ?.click();
    await flushPromises();

    expect(
      element.querySelector('[data-testid="schedule-detail-drawer"]'),
    ).not.toBeNull();
    expect(element.textContent).not.toContain('Loading month data');
    expect(schedulesState.getSchedules).toHaveBeenCalledTimes(1);

    joinRequest.resolve({ message: 'Joined' });
    await flushPromises();

    app.unmount();
  });

  it('shows multi-day detail clearly and does not surface deferred company fields', async () => {
    schedulesState.getSchedule.mockResolvedValueOnce(
      makeSchedule({
        end: '2026-06-21T17:00:00.000000Z',
        event: {
          company_name: 'Future Company',
          company_phone_number: '0123456789',
          physical_address: null,
          schedule_type: 'multiple_days',
          start_date: '2026-06-20T09:00:00.000000Z',
          title: 'Roadshow',
          type: 'business_trip',
        },
        one_day: false,
        start: '2026-06-20T09:00:00.000000Z',
      }),
    );

    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-schedule-id="schedule-1"]')
      ?.click();
    await flushPromises();

    const drawer = element.querySelector<HTMLElement>(
      '[data-testid="schedule-detail-drawer"]',
    );

    expect(drawer?.textContent).toContain('Roadshow');
    expect(drawer?.textContent).toContain('Multi-day schedule');
    expect(drawer?.textContent).not.toContain('Reminder off');
    expect(drawer?.textContent).not.toContain('Future Company');
    expect(drawer?.textContent).not.toContain('0123456789');

    app.unmount();
  });

  it('closes the detail drawer without losing the current month or active filter context', async () => {
    const { default: SchedulesPage } = await import('./index.vue');
    const element = document.createElement('div');
    const app = createApp(SchedulesPage);
    app.mount(element);

    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('button[aria-label="Next month"]')
      ?.click();
    await flushPromises();

    const visibilityFilter = element.querySelector<HTMLSelectElement>(
      '[data-testid="visibility-filter"]',
    );

    if (visibilityFilter === null) {
      throw new Error('Visibility filter not found.');
    }

    visibilityFilter.value = 'observed';
    visibilityFilter.dispatchEvent(new Event('change'));
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-schedule-id="schedule-1"]')
      ?.click();
    await flushPromises();

    element
      .querySelector<HTMLButtonElement>('[data-testid="schedule-detail-close"]')
      ?.click();
    await flushPromises();

    expect(
      element.querySelector('[data-testid="schedule-detail-drawer"]'),
    ).toBeNull();
    expect(
      element.querySelector<HTMLInputElement>('[data-testid="month-picker"]')
        ?.value,
    ).toBe('2026-07');
    expect(visibilityFilter.value).toBe('observed');
    expect(schedulesState.getSchedules).toHaveBeenCalledTimes(3);

    app.unmount();
  });
});
