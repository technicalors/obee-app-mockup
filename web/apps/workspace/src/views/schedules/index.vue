<script setup lang="ts">
import type { Dayjs } from 'dayjs';

import type {
  ScheduleAuthoringDraft,
  ScheduleAuthoringOption,
  ScheduleUserTreeOption,
} from './schedule-page';

import type { Schedule, ScheduleVisibility } from '#/api/schedules';

import { computed, ref, watch } from 'vue';
import { useRoute } from 'vue-router';

import { Page } from '@vben/common-ui';
import { preferences } from '@vben/preferences';
import { useUserStore } from '@vben/stores';

import { notification } from 'ant-design-vue';

import {
  createScheduleEvent,
  deleteScheduleEvent,
  getSchedule,
  getSchedules,
  joinScheduleEvent,
  leaveScheduleEvent,
  updateScheduleEvent,
} from '#/api/schedules';
import { usersResource } from '#/api/users';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';
import { useAuthStore } from '#/store';
import { getUserAvatarSource } from '#/views/users/avatar';

import type { ScheduleViewMode } from './components/ScheduleInteractionBar.vue';

import ScheduleCalendarSection from './components/ScheduleCalendarSection.vue';
import ScheduleDetailDrawer from './components/ScheduleDetailDrawer.vue';
import ScheduleFormDrawer from './components/ScheduleFormDrawer.vue';
import ScheduleInteractionBar from './components/ScheduleInteractionBar.vue';
import ScheduleWeekView from './components/ScheduleWeekView.vue';
import ScheduleYearView from './components/ScheduleYearView.vue';
import {
  buildAuthoringPayload,
  buildDepartmentUserTreeOptions,
  createDraftFromEvent,
  createScheduleDraftForDate,
  formatDayKey,
  formatDayLabel,
  formatMonthValue,
  formatWeekRangeLabel,
  formatYearLabel,
  getAuthoringRepeatPatternValues,
  getMonthGridDateRange,
  getWeekDates,
  getWeekDateRange,
  getYearDateRange,
  parseMonthValue,
  shiftDay,
  shiftWeek,
  shiftYear,
} from './schedule-page';

const selectedMonthValue = ref(formatMonthValue(new Date()));
const currentMonthValue = formatMonthValue(new Date());
const loading = ref(false);
const detailLoading = ref(false);
const actionLoading = ref(false);
const authoringSaving = ref(false);
const deleteDialogOpen = ref(false);
const authoringUsersLoading = ref(false);
const userStore = useUserStore();
const authStore = useAuthStore();
const route = useRoute();
const currentUserId = computed(() => userStore.userInfo?.userId || null);
const currentCompanyId = computed(() => authStore.user?.root_organization_id || null);
const authoringDraft = ref<null | ScheduleAuthoringDraft>(null);
const authoringUserOptions = ref<ScheduleAuthoringOption[]>([]);
const authoringUserTreeOptions = ref<ScheduleUserTreeOption[]>([]);
const selectedCalendarUserIds = ref<string[]>(
  currentUserId.value === null ? [] : [currentUserId.value],
);
const primarySectionMovableUserIds = ref<string[]>([]);
const schedules = ref<Awaited<ReturnType<typeof getSchedules>>>([]);
const selectedSchedule = ref<null | Schedule>(null);
const selectedScheduleId = ref<null | string>(null);
const visibility = ref<ScheduleVisibility>('all');
const today = formatDayKey(new Date());
const viewMode = ref<ScheduleViewMode>('month');
const weekAnchorDate = ref(today);
const dayAnchorDate = ref(today);
const selectedYear = ref<number>(new Date().getFullYear());

const weekDates = computed(() => getWeekDates(weekAnchorDate.value));
const dayDates = computed(() => [dayAnchorDate.value]);

const showMonthPicker = computed(() => viewMode.value === 'month');

const navigationLabel = computed(() => {
  switch (viewMode.value) {
    case 'year': {
      return formatYearLabel(selectedYear.value, preferences.app.locale);
    }
    case 'week': {
      return formatWeekRangeLabel(weekDates.value, preferences.app.locale);
    }
    case 'day': {
      return formatDayLabel(dayAnchorDate.value, preferences.app.locale);
    }
    default: {
      return currentMonthLabel.value;
    }
  }
});

const visibilityOptions = computed<
  Array<{ label: string; value: ScheduleVisibility }>
>(() => [
  { label: $t('page.schedules.actions.all'), value: 'all' },
  { label: $t('page.schedules.actions.participated'), value: 'participated' },
  { label: $t('page.schedules.actions.observed'), value: 'observed' },
  { label: $t('page.schedules.actions.created'), value: 'created' },
]);
const currentMonthLabel = computed(() =>
  formatCurrentMonthLabel(
    parseMonthValue(selectedMonthValue.value),
    preferences.app.locale,
  ),
);

const weekdayLabels = computed(() => {
  const formatter = new Intl.DateTimeFormat(preferences.app.locale, {
    weekday: 'long',
  });

  return Array.from({ length: 7 }, (_, index) =>
    formatter.format(new Date(Date.UTC(2026, 5, 15 + index))),
  );
});

const isCurrentMonthSelected = computed(
  () => selectedMonthValue.value === currentMonthValue,
);
const isCurrentPeriodSelected = computed(() => {
  switch (viewMode.value) {
    case 'year': {
      return selectedYear.value === new Date().getFullYear();
    }
    case 'week': {
      return weekDates.value.includes(today);
    }
    case 'day': {
      return dayAnchorDate.value === today;
    }
    default: {
      return isCurrentMonthSelected.value;
    }
  }
});
const detailDrawerOpen = computed(() => selectedScheduleId.value !== null);
const authoringDrawerOpen = computed(() => authoringDraft.value !== null);
const authoringDrawerTitle = computed(() =>
  authoringDraft.value === null
    ? $t('page.schedules.form.createTitle')
    : $t(`page.schedules.form.${authoringDraft.value.mode}Title`),
);
const authoringPayload = computed(() =>
  authoringDraft.value === null
    ? null
    : buildAuthoringPayload(authoringDraft.value),
);
const canSubmitAuthoringDraft = computed(() => authoringDraft.value !== null);
const calendarUsersById = computed(() => {
  const users = new Map(
    authoringUserOptions.value.map((user) => [String(user.value), user]),
  );

  for (const schedule of schedules.value) {
    for (const user of [
      ...schedule.event.participants,
      ...schedule.event.observers,
    ]) {
      if (!users.has(user.id)) {
        users.set(user.id, {
          avatar: user.avatar,
          label: user.name,
          value: user.id,
        });
      }
    }
  }

  if (authStore.user && !users.has(authStore.user.id)) {
    users.set(authStore.user.id, {
      avatar: authStore.user.avatar,
      label: authStore.user.name,
      value: authStore.user.id,
    });
  }

  return users;
});
const isCalendarUserFilterActive = computed(() => {
  if (selectedCalendarUserIds.value.length === 0) {
    return false;
  }

  if (currentUserId.value === null) {
    return selectedCalendarUserIds.value.length > 0;
  }

  return (
    selectedCalendarUserIds.value.length !== 1 ||
    selectedCalendarUserIds.value[0] !== currentUserId.value
  );
});
const visibilityDisabled = computed(() => isCalendarUserFilterActive.value);
const requestedCalendarUserIds = computed<null | string[]>(() => {
  if (isCalendarUserFilterActive.value === false) {
    return null;
  }

  return selectedCalendarUserIds.value;
});
const allowCreateSchedules = computed(
  () =>
    currentUserId.value !== null &&
    currentCompanyId.value !== null &&
    !isCalendarUserFilterActive.value,
);
const selectedNonCurrentCalendarUserIds = computed(() =>
  selectedCalendarUserIds.value.filter(
    (userId) => userId !== currentUserId.value,
  ),
);
const primarySectionUserIds = computed(() => {
  const pinnedCurrentUserIds =
    currentUserId.value !== null &&
    selectedCalendarUserIds.value.includes(currentUserId.value)
      ? [currentUserId.value]
      : [];

  const movableUserIds = primarySectionMovableUserIds.value.filter((userId) =>
    selectedNonCurrentCalendarUserIds.value.includes(userId),
  );

  return [...pinnedCurrentUserIds, ...movableUserIds];
});
const secondarySectionUserIds = computed(() =>
  selectedNonCurrentCalendarUserIds.value.filter(
    (userId) => !primarySectionMovableUserIds.value.includes(userId),
  ),
);
const primaryCalendarTabs = computed(() =>
  buildSectionTabs(primarySectionUserIds.value, {
    fallbackToAllSchedules: true,
  }),
);
const secondaryCalendarTabs = computed(() =>
  buildSectionTabs(secondarySectionUserIds.value),
);
const primarySectionSchedules = computed(() =>
  buildSectionSchedules(primarySectionUserIds.value),
);
const secondarySectionSchedules = computed(() =>
  buildSectionSchedules(secondarySectionUserIds.value),
);
const canEditSchedule = computed(
  () =>
    selectedSchedule.value !== null &&
    isScheduleCreator(selectedSchedule.value),
);
const canDeleteSchedule = computed(() => canEditSchedule.value);
const canReuseSchedule = computed(() => canEditSchedule.value);
const canLeaveSchedule = computed(
  () =>
    selectedSchedule.value !== null &&
    isScheduleParticipant(selectedSchedule.value),
);
const canJoinSchedule = computed(
  () =>
    selectedSchedule.value !== null &&
    !isScheduleParticipant(selectedSchedule.value) &&
    isScheduleObserver(selectedSchedule.value),
);
const authoringTypeOptions = computed(() => [
  { label: $t('page.schedules.form.typeOptions.training'), value: 'training' },
  { label: $t('page.schedules.form.typeOptions.seminar'), value: 'seminar' },
  {
    label: $t('page.schedules.form.typeOptions.interview'),
    value: 'interview',
  },
  { label: $t('page.schedules.form.typeOptions.meetup'), value: 'meetup' },
  { label: $t('page.schedules.form.typeOptions.meeting'), value: 'meeting' },
  { label: $t('page.schedules.form.typeOptions.holiday'), value: 'holiday' },
  {
    label: $t('page.schedules.form.typeOptions.business_trip'),
    value: 'business_trip',
  },
]);
const authoringScheduleTypeOptions = computed(() => [
  {
    label: $t('page.schedules.form.scheduleTypeOptions.ordinary'),
    value: 'ordinary',
  },
  {
    label: $t('page.schedules.form.scheduleTypeOptions.multiple_days'),
    value: 'multiple_days',
  },
  {
    label: $t('page.schedules.form.scheduleTypeOptions.repeat'),
    value: 'repeat',
  },
]);
const authoringRepeatTypeOptions = computed(() => [
  {
    label: $t('page.schedules.form.repeatOptions.daily'),
    value: 'daily',
  },
  {
    label: $t('page.schedules.form.repeatOptions.weekly'),
    value: 'weekly',
  },
  {
    label: $t('page.schedules.form.repeatOptions.monthly'),
    value: 'monthly',
  },
]);
const authoringPrivacyOptions = computed(() => [
  {
    label: $t('page.schedules.form.privacyOptions.public'),
    value: 'public',
  },
  {
    label: $t('page.schedules.form.privacyOptions.private'),
    value: 'private',
  },
]);
const authoringReminderRangeOptions = computed(() => [
  {
    label: $t('page.schedules.form.reminderRangeOptions.minute'),
    value: 'minute',
  },
  {
    label: $t('page.schedules.form.reminderRangeOptions.hour'),
    value: 'hour',
  },
  {
    label: $t('page.schedules.form.reminderRangeOptions.day'),
    value: 'day',
  },
]);
const authoringWeekdayPatternOptions = computed(() =>
  weekdayLabels.value.map((label, value) => ({ label, value })),
);
const authoringMonthPatternOptions = computed(() =>
  Array.from({ length: 31 }, (_, index) => ({
    label: String(index + 1),
    value: index + 1,
  })),
);

function formatCurrentMonthLabel(date: Date, locale: string): string {
  const formatter = new Intl.DateTimeFormat(locale, {
    month: 'long',
    year: 'numeric',
  });
  const month = formatter
    .formatToParts(date)
    .find(({ type }) => type === 'month');
  const year = formatter
    .formatToParts(date)
    .find(({ type }) => type === 'year');
  const between = formatter
    .formatToParts(date)
    .filter(({ type }) => type !== 'month' && type !== 'year')
    .map(({ value }) => value)
    .join('')
    .trim();

  if (month === undefined || year === undefined) {
    return formatter
      .format(date)
      .replace(/^./u, (value) => value.toUpperCase());
  }

  const yearPrefix = between === '' ? '' : `${between} `;

  return `${month.value.replace(/^./u, (value) => value.toUpperCase())}, ${yearPrefix}${year.value}`.trim();
}

watch(
  [selectedMonthValue, visibility, selectedCalendarUserIds],
  async () => {
    await loadSchedules();
  },
  { immediate: true },
);

watch(
  [viewMode, weekAnchorDate, dayAnchorDate, selectedYear],
  async () => {
    if (viewMode.value !== 'month') {
      await loadSchedules();
    }
  },
);

watch(
  () => route.query.event_id,
  (eventId) => {
    if (typeof eventId === 'string') {
      void openScheduleEventDetail(eventId);
    }
  },
  { immediate: true },
);

watch(isCalendarUserFilterActive, (active) => {
  if (active && visibility.value !== 'all') {
    visibility.value = 'all';
  }
});

watch(
  [currentUserId, selectedNonCurrentCalendarUserIds],
  ([userId, selectedNonCurrentUserIds]) => {
    primarySectionMovableUserIds.value =
      primarySectionMovableUserIds.value.filter((selectedUserId) =>
        selectedNonCurrentUserIds.includes(selectedUserId),
      );

    const isCurrentUserSelected =
      userId !== null && selectedCalendarUserIds.value.includes(userId);

    if (
      isCurrentUserSelected ||
      selectedNonCurrentUserIds.length === 0 ||
      primarySectionMovableUserIds.value.length > 0
    ) {
      return;
    }

    const [fallbackPrimaryUserId] = selectedNonCurrentUserIds;

    if (fallbackPrimaryUserId !== undefined) {
      primarySectionMovableUserIds.value = [fallbackPrimaryUserId];
    }
  },
  { immediate: true },
);

watch(
  currentUserId,
  (userId) => {
    if (userId !== null && selectedCalendarUserIds.value.length === 0) {
      selectedCalendarUserIds.value = [userId];
    }
  },
  { immediate: true },
);

watch(
  currentCompanyId,
  async (companyId) => {
    if (companyId === null) {
      authoringUserOptions.value = [];
      return;
    }

    await loadAuthoringUsers();
  },
  { immediate: true },
);

function buildSectionTabs(
  userIds: string[],
  options?: { fallbackToAllSchedules?: boolean },
): Array<{
  avatar: null | string;
  canTransfer: boolean;
  key: string;
  title: string;
}> {
  if (userIds.length === 0) {
    return options?.fallbackToAllSchedules === true
      ? [
          {
            avatar: null,
            canTransfer: false,
            key: 'default',
            title: $t('page.schedules.actions.all'),
          },
        ]
      : [];
  }

  return userIds.map((userId) => ({
    avatar: calendarUsersById.value.get(userId)?.avatar ?? null,
    canTransfer: userId !== currentUserId.value,
    key: userId,
    title:
      calendarUsersById.value.get(userId)?.label ?? $t('common.notProvided'),
  }));
}

function buildSectionSchedules(userIds: string[]): Schedule[] {
  if (userIds.length === 0) {
    return schedules.value;
  }

  const sectionUserIds = new Set(userIds);

  return schedules.value.filter(
    (schedule) =>
      sectionUserIds.has(schedule.event.created_by) ||
      schedule.event.participants.some(({ id }) => sectionUserIds.has(id)) ||
      schedule.event.observers.some(({ id }) => sectionUserIds.has(id)),
  );
}

function shiftPeriod(offset: number): void {
  switch (viewMode.value) {
    case 'year': {
      selectedYear.value = shiftYear(selectedYear.value, offset);
      break;
    }
    case 'week': {
      weekAnchorDate.value = shiftWeek(weekAnchorDate.value, offset);
      break;
    }
    case 'day': {
      dayAnchorDate.value = shiftDay(dayAnchorDate.value, offset);
      break;
    }
    default: {
      shiftMonth(offset);
    }
  }
}

function shiftMonth(offset: number): void {
  const nextMonth = parseMonthValue(selectedMonthValue.value);
  nextMonth.setUTCMonth(nextMonth.getUTCMonth() + offset);
  selectedMonthValue.value = formatMonthValue(nextMonth);
}

function selectCurrentMonth(): void {
  const now = new Date();
  const todayKey = formatDayKey(now);
  selectedMonthValue.value = formatMonthValue(now);
  selectedYear.value = now.getFullYear();
  weekAnchorDate.value = todayKey;
  dayAnchorDate.value = todayKey;
}

function updateSelectedMonth(value: Dayjs | string): void {
  selectedMonthValue.value =
    typeof value === 'string' ? value : value.format('YYYY-MM');
}

function updateVisibility(value: ScheduleVisibility | undefined): void {
  if (value !== undefined) {
    visibility.value = value;
  }
}

function updateViewMode(mode: ScheduleViewMode): void {
  if (mode === 'year') {
    selectedYear.value = Number(selectedMonthValue.value.slice(0, 4));
  }
  viewMode.value = mode;
}

function selectMonthFromYearView(monthValue: string): void {
  selectedMonthValue.value = monthValue;
  viewMode.value = 'month';
}

function selectDayFromYearView(date: string): void {
  dayAnchorDate.value = date;
  weekAnchorDate.value = date;
  selectedMonthValue.value = date.slice(0, 7);
  viewMode.value = 'day';
}

function updateSelectedCalendarUsers(value: string[] | undefined): void {
  const nextUserIds = value === undefined ? [] : [...new Set(value)];

  if (nextUserIds.length === 0) {
    selectedCalendarUserIds.value =
      currentUserId.value === null ? [] : [currentUserId.value];
    return;
  }

  selectedCalendarUserIds.value = nextUserIds;
}

function transferTabToPrimarySection(tabKey: string): void {
  if (
    tabKey === currentUserId.value ||
    primarySectionMovableUserIds.value.includes(tabKey)
  ) {
    return;
  }

  primarySectionMovableUserIds.value = [
    ...primarySectionMovableUserIds.value,
    tabKey,
  ];
}

function transferTabToSecondarySection(tabKey: string): void {
  if (tabKey === currentUserId.value) {
    return;
  }

  const nextPrimaryMovableUserIds = primarySectionMovableUserIds.value.filter(
    (userId) => userId !== tabKey,
  );

  if (
    currentUserId.value === null ||
    !selectedCalendarUserIds.value.includes(currentUserId.value)
  ) {
    const hasPrimaryTabsAfterTransfer = nextPrimaryMovableUserIds.length > 0;

    if (!hasPrimaryTabsAfterTransfer) {
      const fallbackPrimaryUserId = secondarySectionUserIds.value.find(
        (userId) => userId !== tabKey,
      );

      primarySectionMovableUserIds.value =
        fallbackPrimaryUserId === undefined ? [] : [fallbackPrimaryUserId];
      return;
    }
  }

  primarySectionMovableUserIds.value = nextPrimaryMovableUserIds;
}

async function loadAuthoringUsers(): Promise<void> {
  if (currentCompanyId.value === null) {
    authoringUserOptions.value = [];
    authoringUserTreeOptions.value = [];
    return;
  }

  authoringUsersLoading.value = true;

  try {
    const result = await usersResource.getAll({
      page: 1,
      per_page: 100,
    });
    const users = result.items;

    authoringUserOptions.value = users.map((user) => ({
      avatar: getUserAvatarSource(user),
      label: user.name,
      value: user.id,
    }));
    authoringUserTreeOptions.value = buildDepartmentUserTreeOptions(users);

    if (
      currentUserId.value !== null &&
      selectedCalendarUserIds.value.length === 0
    ) {
      selectedCalendarUserIds.value = [currentUserId.value];
    }
  } catch (error: unknown) {
    showRequestError(
      error,
      $t('page.schedules.messages.unexpectedError'),
      'Unexpected authoring users load error:',
    );
  } finally {
    authoringUsersLoading.value = false;
  }
}

async function openScheduleDetail(scheduleId: string): Promise<void> {
  selectedScheduleId.value = scheduleId;
  selectedSchedule.value = null;
  detailLoading.value = true;

  try {
    const schedule = await getSchedule(scheduleId);

    if (selectedScheduleId.value === scheduleId) {
      selectedSchedule.value = schedule;
    }
  } finally {
    if (selectedScheduleId.value === scheduleId) {
      detailLoading.value = false;
    }
  }
}

async function openScheduleEventDetail(eventId: string): Promise<void> {
  try {
    const [schedule] = await getSchedules({
      event_id: eventId,
      visibility: 'all',
    });

    if (schedule === undefined) {
      throw new Error(`No schedule occurrence exists for event ${eventId}.`);
    }

    await openScheduleDetail(schedule.id);
  } catch (error: unknown) {
    showRequestError(
      error,
      $t('page.schedules.messages.unexpectedError'),
      'Unexpected schedule notification navigation error:',
    );
  }
}

async function loadSchedules(showLoading = true): Promise<Schedule[]> {
  let start: string;
  let end: string;

  if (viewMode.value === 'year') {
    const range = getYearDateRange(selectedYear.value);
    start = range.start;
    end = range.end;
  } else if (viewMode.value === 'week') {
    const range = getWeekDateRange(weekDates.value);
    start = range.start;
    end = range.end;
  } else if (viewMode.value === 'day') {
    start = dayDates.value[0]!;
    end = dayDates.value[0]!;
  } else {
    const range = getMonthGridDateRange(
      parseMonthValue(selectedMonthValue.value),
    );
    start = range.start;
    end = range.end;
  }

  if (showLoading) {
    loading.value = true;
  }

  try {
    const nextSchedules = await getSchedules({
      end_from: start,
      start_to: end,
      ...(requestedCalendarUserIds.value === null
        ? {}
        : { user_ids: requestedCalendarUserIds.value.join(',') }),
      visibility: isCalendarUserFilterActive.value ? 'all' : visibility.value,
    });

    schedules.value = nextSchedules;

    return nextSchedules;
  } finally {
    if (showLoading) {
      loading.value = false;
    }
  }
}

async function joinSelectedSchedule(): Promise<void> {
  await updateScheduleParticipation('join');
}

async function leaveSelectedSchedule(): Promise<void> {
  await updateScheduleParticipation('leave');
}

function openDeleteDialog(): void {
  if (selectedSchedule.value === null || actionLoading.value) {
    return;
  }

  deleteDialogOpen.value = true;
}

function closeDeleteDialog(): void {
  if (actionLoading.value) {
    return;
  }

  deleteDialogOpen.value = false;
}

async function confirmDeleteSchedule(): Promise<void> {
  if (selectedSchedule.value === null || actionLoading.value) {
    return;
  }

  actionLoading.value = true;

  try {
    await deleteScheduleEvent(selectedSchedule.value.event.id);
    await loadSchedules(false);
    notification.success({
      message: $t('page.schedules.messages.deleteSuccess'),
    });
    actionLoading.value = false;
    deleteDialogOpen.value = false;
    closeScheduleDetail();
  } catch (error: unknown) {
    showRequestError(
      error,
      $t('page.schedules.messages.unexpectedError'),
      'Unexpected schedule delete error:',
    );
  } finally {
    actionLoading.value = false;
  }
}

function openReuseDrawer(): void {
  if (selectedSchedule.value === null) {
    return;
  }

  authoringDraft.value = createDraftFromEvent(selectedSchedule.value, 'reuse');
  closeScheduleDetail();
}

function openCreateDrawer(date: string): void {
  authoringDraft.value = createScheduleDraftForDate(date, currentUserId.value);
}

function openEditDrawer(): void {
  if (selectedSchedule.value === null) {
    return;
  }

  authoringDraft.value = createDraftFromEvent(selectedSchedule.value, 'edit');
  closeScheduleDetail();
}

function closeAuthoringDrawer(): void {
  if (authoringSaving.value) {
    return;
  }

  authoringDraft.value = null;
}

async function submitAuthoringDraft(): Promise<void> {
  if (
    authoringDraft.value === null ||
    authoringPayload.value === null ||
    authoringSaving.value
  ) {
    return;
  }

  if (authoringDraft.value.mode !== 'edit' && currentCompanyId.value === null) {
    return;
  }

  authoringSaving.value = true;

  try {
    await (authoringDraft.value.mode === 'edit'
      ? updateScheduleEvent(
          authoringDraft.value.source_event_id,
          authoringPayload.value,
        )
      : createScheduleEvent(authoringPayload.value));

    await loadSchedules(false);
    notification.success({
      message: $t(
        `page.schedules.messages.${authoringDraft.value.mode === 'edit' ? 'updateSuccess' : 'createSuccess'}`,
      ),
    });
    authoringSaving.value = false;
    closeAuthoringDrawer();
  } catch (error: unknown) {
    showRequestError(
      error,
      $t('page.schedules.messages.unexpectedError'),
      'Unexpected schedule authoring error:',
    );
  } finally {
    authoringSaving.value = false;
  }
}

function updateAuthoringDate(
  field: 'end_date' | 'start_date',
  value: Dayjs | string,
): void {
  if (authoringDraft.value === null) {
    return;
  }

  authoringDraft.value[field] =
    typeof value === 'string' ? value : value.format('YYYY-MM-DD');
}

function updateAuthoringScheduleType(value: unknown): void {
  if (authoringDraft.value === null) {
    return;
  }

  authoringDraft.value.schedule_type =
    value as Schedule['event']['schedule_type'];

  if (authoringDraft.value.schedule_type !== 'repeat') {
    authoringDraft.value.repeat_type = null;
    authoringDraft.value.repeat_pattern = null;
    authoringDraft.value.repeat_start_time = null;
    authoringDraft.value.repeat_end_time = null;
  }
}

function updateAuthoringNullableField(
  field: 'meeting_url' | 'note' | 'physical_address',
  value: string,
): void {
  if (authoringDraft.value === null) {
    return;
  }

  authoringDraft.value[field] = value === '' ? null : value;
}

function updateAuthoringLocationType(
  value: 'hybrid' | 'online' | 'physical',
): void {
  if (authoringDraft.value !== null) {
    authoringDraft.value.location_type = value;
  }
}

function updateAuthoringMeetingUrl(value: string): void {
  if (authoringDraft.value !== null) {
    authoringDraft.value.meeting_url = value === '' ? null : value;
  }
}

function updateAuthoringEquipmentIds(value: string[]): void {
  if (authoringDraft.value !== null) {
    authoringDraft.value.equipment_ids = value;
  }
}

async function updateScheduleTime(
  scheduleId: string,
  newStartIso: string,
  newEndIso: string,
): Promise<void> {
  const target = schedules.value.find((s) => s.id === scheduleId);
  if (!target) return;

  try {
    target.start = newStartIso;
    target.end = newEndIso;
    target.event.start_date = newStartIso;
    target.event.end_date = newEndIso;

    await updateScheduleEvent(target.event.id, {
      company_name: target.event.company_name,
      company_phone_number: target.event.company_phone_number,
      end_date: newEndIso,
      equipment_ids: target.event.equipment_ids,
      has_reminder: target.event.has_reminder,
      is_general: target.event.is_general,
      meeting_url: target.event.meeting_url,
      note: target.event.note,
      observers: target.event.observers.map((u) => u.id),
      participants: target.event.participants.map((u) => u.id),
      physical_address: target.event.physical_address,
      privacy: target.event.privacy,
      remind_range: target.event.remind_range,
      remind_value: target.event.remind_value,
      repeat_end_time: target.event.repeat_end_time,
      repeat_pattern: target.event.repeat_pattern,
      repeat_start_time: target.event.repeat_start_time,
      repeat_type: target.event.repeat_type,
      schedule_type: target.event.schedule_type,
      start_date: newStartIso,
      title: target.event.title,
      type: target.event.type,
    });

    notification.success({
      message: 'Đã cập nhật thời gian sự kiện.',
    });
  } catch (error: unknown) {
    showRequestError(
      error,
      $t('page.schedules.messages.unexpectedError'),
      'Unexpected schedule time update error:',
    );
  }
}

function updateAuthoringField(
  field: 'observers' | 'participants' | 'privacy' | 'title' | 'type',
  value:
    | Schedule['event']['privacy']
    | Schedule['event']['type']
    | string
    | string[],
): void {
  if (authoringDraft.value === null) {
    return;
  }

  switch (field) {
    case 'observers':
    case 'participants': {
      authoringDraft.value[field] = value as string[];
      return;
    }
    case 'privacy': {
      authoringDraft.value.privacy = value as Schedule['event']['privacy'];
      return;
    }
    case 'title': {
      authoringDraft.value.title = value as string;
      return;
    }
    default: {
      authoringDraft.value.type = value as Schedule['event']['type'];
    }
  }
}

function updateAuthoringRepeatType(value: unknown): void {
  if (authoringDraft.value === null) {
    return;
  }

  authoringDraft.value.repeat_type = value as Schedule['event']['repeat_type'];
  authoringDraft.value.repeat_pattern = null;
}

function updateAuthoringTime(
  field: 'end_time' | 'start_time',
  value: Dayjs | null | string,
): void {
  if (authoringDraft.value === null) {
    return;
  }

  if (value === null || value === '') {
    authoringDraft.value[field] = null;
    return;
  }

  authoringDraft.value[field] =
    typeof value === 'string' ? value : value.format('HH:mm');
}

function updateAuthoringGeneral(value: boolean | number | string): void {
  if (authoringDraft.value === null) {
    return;
  }

  authoringDraft.value.is_general = value === true;
}

function toggleAuthoringRepeatPattern(value: number): void {
  if (
    authoringDraft.value === null ||
    authoringDraft.value.repeat_type === null ||
    !['monthly', 'weekly'].includes(authoringDraft.value.repeat_type)
  ) {
    return;
  }

  const nextPattern = new Set(
    getAuthoringRepeatPatternValues(authoringDraft.value),
  );

  if (nextPattern.has(value)) {
    nextPattern.delete(value);
  } else {
    nextPattern.add(value);
  }

  const sortedPattern = [...nextPattern].toSorted(
    (left, right) => left - right,
  );

  authoringDraft.value.repeat_pattern =
    sortedPattern.length === 0 ? null : sortedPattern;
}

function selectAllAuthoringRepeatPatterns(): void {
  if (
    authoringDraft.value === null ||
    authoringDraft.value.repeat_type === null ||
    !['monthly', 'weekly'].includes(authoringDraft.value.repeat_type)
  ) {
    return;
  }

  const allPatternValues =
    authoringDraft.value.repeat_type === 'weekly'
      ? authoringWeekdayPatternOptions.value.map(({ value }) => Number(value))
      : authoringMonthPatternOptions.value.map(({ value }) => Number(value));

  const selectedPatternValues = getAuthoringRepeatPatternValues(
    authoringDraft.value,
  );
  const isAllSelected =
    selectedPatternValues.length === allPatternValues.length &&
    selectedPatternValues.every(
      (value, index) => value === allPatternValues[index],
    );

  authoringDraft.value.repeat_pattern = isAllSelected ? null : allPatternValues;
}

function updateAuthoringReminderEnabled(
  value: boolean | number | string,
): void {
  if (authoringDraft.value === null) {
    return;
  }

  authoringDraft.value.has_reminder = value === true;

  if (value !== true) {
    authoringDraft.value.remind_range = null;
    authoringDraft.value.remind_value = null;
  }
}

function updateAuthoringReminderValue(value: string): void {
  if (authoringDraft.value === null) {
    return;
  }

  authoringDraft.value.remind_value = value === '' ? null : Number(value);
}

function updateAuthoringReminderRange(value: unknown): void {
  if (authoringDraft.value === null) {
    return;
  }

  authoringDraft.value.remind_range =
    value === undefined ? null : (value as Schedule['event']['remind_range']);
}

async function updateScheduleParticipation(
  action: 'join' | 'leave',
): Promise<void> {
  if (selectedSchedule.value === null || actionLoading.value) {
    return;
  }

  const eventId = selectedSchedule.value.event.id;
  const scheduleId = selectedSchedule.value.id;

  actionLoading.value = true;

  try {
    await (action === 'join'
      ? joinScheduleEvent(eventId)
      : leaveScheduleEvent(eventId));

    notification.success({
      message: $t(`page.schedules.messages.${action}Success`),
    });

    const refreshedSchedules = await loadSchedules(false);

    if (!refreshedSchedules.some(({ id }) => id === scheduleId)) {
      actionLoading.value = false;
      closeScheduleDetail();
      return;
    }

    detailLoading.value = true;

    try {
      const refreshedSchedule = await getSchedule(scheduleId);

      if (selectedScheduleId.value === scheduleId) {
        selectedSchedule.value = refreshedSchedule;
      }
    } finally {
      if (selectedScheduleId.value === scheduleId) {
        detailLoading.value = false;
      }
    }
  } catch (error: unknown) {
    showRequestError(
      error,
      $t('page.schedules.messages.unexpectedError'),
      'Unexpected schedule participation error:',
    );
  } finally {
    actionLoading.value = false;
  }
}

function closeScheduleDetail(): void {
  if (actionLoading.value) {
    return;
  }

  deleteDialogOpen.value = false;
  selectedScheduleId.value = null;
  selectedSchedule.value = null;
  detailLoading.value = false;
}

function isScheduleCreator(schedule: Schedule): boolean {
  return schedule.event.created_by === currentUserId.value;
}

function isScheduleParticipant(schedule: Schedule): boolean {
  return schedule.event.participants.some(
    ({ id }) => id === currentUserId.value,
  );
}

function isScheduleObserver(schedule: Schedule): boolean {
  return schedule.event.observers.some(({ id }) => id === currentUserId.value);
}
</script>

<template>
  <Page auto-content-height>
    <section class="space-y-4">
      <ScheduleInteractionBar
        :calendar-user-tree-options="authoringUserTreeOptions"
        :calendar-users-loading="authoringUsersLoading"
        :current-month-label="currentMonthLabel"
        :is-current-month-selected="isCurrentPeriodSelected"
        :navigation-label="navigationLabel"
        :on-select-current-month="selectCurrentMonth"
        :on-shift-period="shiftPeriod"
        :on-update-selected-calendar-users="updateSelectedCalendarUsers"
        :on-update-selected-month="updateSelectedMonth"
        :on-update-view-mode="updateViewMode"
        :on-update-visibility="updateVisibility"
        :selected-calendar-user-ids="selectedCalendarUserIds"
        :selected-month-value="selectedMonthValue"
        :show-month-picker="showMonthPicker"
        :view-mode="viewMode"
        :visibility-disabled="visibilityDisabled"
        :show-calendar-users-filter="currentCompanyId !== null"
        :visibility="visibility"
        :visibility-options="visibilityOptions"
      />

      <!-- Month View -->
      <div
        v-if="viewMode === 'month'"
        class="grid min-h-0 gap-4"
        :class="secondaryCalendarTabs.length > 0 ? 'lg:grid-cols-2' : ''"
      >
        <ScheduleCalendarSection
          :allow-create="allowCreateSchedules"
          :has-company="currentCompanyId !== null"
          :loading="loading"
          :month-value="selectedMonthValue"
          :on-open-create-drawer="openCreateDrawer"
          :on-open-schedule-detail="openScheduleDetail"
          :on-transfer-tab="transferTabToSecondarySection"
          :schedules="primarySectionSchedules"
          section-test-id="schedule-calendar-section-primary"
          :section-users="primaryCalendarTabs"
          :tabs="primaryCalendarTabs"
          :today="today"
          :weekday-labels="weekdayLabels"
        />

        <ScheduleCalendarSection
          v-if="secondaryCalendarTabs.length > 0"
          :allow-create="allowCreateSchedules"
          :has-company="currentCompanyId !== null"
          :loading="loading"
          :month-value="selectedMonthValue"
          :on-open-create-drawer="openCreateDrawer"
          :on-open-schedule-detail="openScheduleDetail"
          :on-transfer-tab="transferTabToPrimarySection"
          :schedules="secondarySectionSchedules"
          section-test-id="schedule-calendar-section-secondary"
          :section-users="secondaryCalendarTabs"
          :tabs="secondaryCalendarTabs"
          :today="today"
          :weekday-labels="weekdayLabels"
        />
      </div>

      <!-- Week View -->
      <div
        v-else-if="viewMode === 'week'"
        class="rounded border border-border bg-background"
        style="min-height: 600px"
      >
        <ScheduleWeekView
          :allow-create="allowCreateSchedules"
          :dates="weekDates"
          :has-company="currentCompanyId !== null"
          :loading="loading"
          :on-open-create-drawer="openCreateDrawer"
          :on-open-schedule-detail="openScheduleDetail"
          :on-update-time="updateScheduleTime"
          :schedules="schedules"
          :today="today"
          :weekday-labels="weekdayLabels"
        />
      </div>

      <!-- Day View -->
      <div
        v-else-if="viewMode === 'day'"
        class="rounded border border-border bg-background"
        style="min-height: 600px"
      >
        <ScheduleWeekView
          :allow-create="allowCreateSchedules"
          :dates="dayDates"
          :has-company="currentCompanyId !== null"
          :loading="loading"
          :on-open-create-drawer="openCreateDrawer"
          :on-open-schedule-detail="openScheduleDetail"
          :on-update-time="updateScheduleTime"
          :schedules="schedules"
          :today="today"
          :weekday-labels="weekdayLabels"
        />
      </div>

      <!-- Year View -->
      <div
        v-else-if="viewMode === 'year'"
        class="rounded border border-border bg-background"
      >
        <ScheduleYearView
          :allow-create="allowCreateSchedules"
          :has-company="currentCompanyId !== null"
          :loading="loading"
          :locale="preferences.app.locale"
          :on-open-create-drawer="openCreateDrawer"
          :on-open-schedule-detail="openScheduleDetail"
          :on-select-day="selectDayFromYearView"
          :on-select-month="selectMonthFromYearView"
          :schedules="schedules"
          :today="today"
          :year="selectedYear"
        />
      </div>
    </section>

    <ScheduleDetailDrawer
      :action-loading="actionLoading"
      :can-delete-schedule="canDeleteSchedule"
      :can-edit-schedule="canEditSchedule"
      :can-join-schedule="canJoinSchedule"
      :can-leave-schedule="canLeaveSchedule"
      :can-reuse-schedule="canReuseSchedule"
      :delete-dialog-open="deleteDialogOpen"
      :detail-loading="detailLoading"
      :on-close="closeScheduleDetail"
      :on-close-delete-dialog="closeDeleteDialog"
      :on-confirm-delete-schedule="confirmDeleteSchedule"
      :on-join-selected-schedule="joinSelectedSchedule"
      :on-leave-selected-schedule="leaveSelectedSchedule"
      :on-open-delete-dialog="openDeleteDialog"
      :on-open-edit-drawer="openEditDrawer"
      :on-open-reuse-drawer="openReuseDrawer"
      :open="detailDrawerOpen"
      :schedule="selectedSchedule"
      :title="$t('page.schedules.detail.title')"
    />

    <ScheduleFormDrawer
      :authoring-month-pattern-options="authoringMonthPatternOptions"
      :authoring-payload="authoringPayload"
      :authoring-privacy-options="authoringPrivacyOptions"
      :authoring-reminder-range-options="authoringReminderRangeOptions"
      :authoring-repeat-type-options="authoringRepeatTypeOptions"
      :authoring-saving="authoringSaving"
      :authoring-schedule-type-options="authoringScheduleTypeOptions"
      :authoring-type-options="authoringTypeOptions"
      :authoring-user-tree-options="authoringUserTreeOptions"
      :authoring-users-loading="authoringUsersLoading"
      :authoring-weekday-pattern-options="authoringWeekdayPatternOptions"
      :can-submit-authoring-draft="canSubmitAuthoringDraft"
      :draft="authoringDraft"
      :has-company="currentCompanyId !== null"
      :on-close="closeAuthoringDrawer"
      :on-select-all-authoring-repeat-patterns="
        selectAllAuthoringRepeatPatterns
      "
      :on-submit="submitAuthoringDraft"
      :on-toggle-authoring-repeat-pattern="toggleAuthoringRepeatPattern"
      :on-update-authoring-date="updateAuthoringDate"
      :on-update-authoring-field="updateAuthoringField"
      :on-update-authoring-general="updateAuthoringGeneral"
      :on-update-authoring-location-type="updateAuthoringLocationType"
      :on-update-authoring-meeting-url="updateAuthoringMeetingUrl"
      :on-update-authoring-equipment-ids="updateAuthoringEquipmentIds"
      :on-update-authoring-nullable-field="updateAuthoringNullableField"
      :on-update-authoring-reminder-enabled="updateAuthoringReminderEnabled"
      :on-update-authoring-reminder-range="updateAuthoringReminderRange"
      :on-update-authoring-reminder-value="updateAuthoringReminderValue"
      :on-update-authoring-time="updateAuthoringTime"
      :on-update-authoring-repeat-type="updateAuthoringRepeatType"
      :on-update-authoring-schedule-type="updateAuthoringScheduleType"
      :open="authoringDrawerOpen"
      :schedules="schedules"
      :title="authoringDrawerTitle"
    />
  </Page>
</template>
