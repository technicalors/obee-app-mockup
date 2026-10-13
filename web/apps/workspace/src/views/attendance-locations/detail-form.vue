<script setup lang="ts">
import type { AttendanceLocationFormValues } from './form';

import type { AttendanceLocation, Department, User } from '#/api';

import { computed, h, onMounted, reactive, ref, watch } from 'vue';
import { useRouter } from 'vue-router';

import { useAccess } from '@vben/access';
import { Page } from '@vben/common-ui';
import { IconifyIcon } from '@vben/icons';

import {
  Button,
  Card,
  Checkbox,
  Form,
  FormItem,
  Input,
  notification,
  Select,
  Spin,
  Switch,
  Tabs,
  Tag,
  Tooltip,
} from 'ant-design-vue';

import {
  attendanceLocationsResource,
  companyUsersResource,
  departmentOptionsResource,
} from '#/api';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';
import { useAuthStore } from '#/store';

import {
  buildAttendanceLocationCreatePayload,
  buildAttendanceLocationDetail,
  buildAttendanceLocationUpdatePayload,
  toAttendanceLocationFormValues,
} from './form';
import MapboxMapPicker from './MapboxMapPicker.vue';

interface EditableFormRef {
  validate: () => Promise<void>;
}

interface Props {
  id?: string;
  mode: 'create' | 'edit' | 'view';
}

const props = withDefaults(defineProps<Props>(), {
  id: '',
});

const DEFAULT_FORM_VALUES: AttendanceLocationFormValues = {
  department_ids: [],
  excluded_user_ids: [],
  ip_addresses: [],
  is_active: true,
  latitude: '10.777',
  longitude: '106.699',
  name: '',
  radius_meters: '100',
  user_ids: [],
  validation_mode: 'both',
};

const router = useRouter();
const { hasAccessByCodes } = useAccess();
const authStore = useAuthStore();

const loading = ref(false);
const optionsLoading = ref(false);
const submitting = ref(false);
const locating = ref(false);
const originalEntity = ref<AttendanceLocation>();
const departments = ref<Department[]>([]);
const users = ref<User[]>([]);
const formRef = ref<EditableFormRef | null>(null);
const formState = reactive<AttendanceLocationFormValues>({
  ...DEFAULT_FORM_VALUES,
});
const mapState = reactive({
  latitude: Number(DEFAULT_FORM_VALUES.latitude),
  longitude: Number(DEFAULT_FORM_VALUES.longitude),
  radius_meters: Number(DEFAULT_FORM_VALUES.radius_meters),
});

const detail = computed(() =>
  originalEntity.value === undefined
    ? null
    : buildAttendanceLocationDetail(originalEntity.value),
);

const validationModeOptions = computed(() => [
  {
    label: $t('page.attendanceLocations.validationMode.location'),
    value: 'location',
  },
  {
    label: $t('page.attendanceLocations.validationMode.ip'),
    value: 'ip',
  },
  {
    label: $t('page.attendanceLocations.validationMode.both'),
    value: 'both',
  },
  {
    label: $t('page.attendanceLocations.validationMode.either'),
    value: 'either',
  },
]);

const departmentOptions = computed(() =>
  departments.value.map((department) => ({
    label: department.name,
    value: String(department.id),
  })),
);
const departmentSearch = ref('');
const filteredDepartmentOptions = computed(() => {
  const query = departmentSearch.value.trim().toLowerCase();

  if (query === '') {
    return departmentOptions.value;
  }

  return departmentOptions.value.filter((department) =>
    department.label.toLowerCase().includes(query),
  );
});

const selectedDepartments = computed(() => {
  return departments.value.filter((dep) =>
    formState.department_ids.includes(String(dep.id)),
  );
});

function removeDepartment(id: number | string): void {
  formState.department_ids = formState.department_ids.filter(
    (depId) => depId !== String(id),
  );
}

const activeUserSearch = ref('');
const showIncludeSelect = ref(false);
const showExcludeSelect = ref(false);

const departmentUserIds = computed(() => {
  const selectedDepIds = new Set(formState.department_ids);
  return new Set(
    users.value
      .filter((user) =>
        user.departments.some((d) => selectedDepIds.has(String(d.id))),
      )
      .map((user) => String(user.id)),
  );
});

const hasExplicitAssignments = computed(
  () => formState.department_ids.length > 0 || formState.user_ids.length > 0,
);

const applicableUsers = computed(() => {
  const selectedUserIds = new Set(formState.user_ids);
  const excludedUserIds = new Set(formState.excluded_user_ids);

  return users.value.filter((user) => {
    const userId = String(user.id);
    const isApplicable = hasExplicitAssignments.value
      ? selectedUserIds.has(userId) || departmentUserIds.value.has(userId)
      : true;

    return isApplicable && !excludedUserIds.has(userId);
  });
});

const filteredApplicableUsers = computed(() => {
  const query = activeUserSearch.value.trim().toLowerCase();
  if (query === '') {
    return applicableUsers.value;
  }

  return applicableUsers.value.filter(
    (user) =>
      user.name.toLowerCase().includes(query) ||
      user.username.toLowerCase().includes(query),
  );
});

interface CustomUserRule {
  type: 'exclude' | 'include';
  user: User;
}

const customUserRules = computed<CustomUserRule[]>(() => {
  const usersById = new Map(users.value.map((user) => [String(user.id), user]));
  const rules: CustomUserRule[] = [];

  formState.user_ids.forEach((userId) => {
    const user = usersById.get(String(userId));
    if (user !== undefined) {
      rules.push({ type: 'include', user });
    }
  });

  formState.excluded_user_ids.forEach((userId) => {
    const user = usersById.get(String(userId));
    if (user !== undefined) {
      rules.push({ type: 'exclude', user });
    }
  });

  return rules.toSorted((a, b) => a.user.name.localeCompare(b.user.name));
});

const availableForInclude = computed(() => {
  const currentIncludes = new Set(formState.user_ids);
  return users.value.filter((user) => !currentIncludes.has(String(user.id)));
});

const availableForExclude = computed(() => {
  const currentExcludes = new Set(formState.excluded_user_ids);
  return users.value.filter((user) => !currentExcludes.has(String(user.id)));
});

function excludeUser(userId: number | string): void {
  const userIdStr = String(userId);
  formState.user_ids = formState.user_ids.filter(
    (id) => String(id) !== userIdStr,
  );
  if (!formState.excluded_user_ids.includes(userIdStr)) {
    formState.excluded_user_ids = [...formState.excluded_user_ids, userIdStr];
  }
}

function removeManualInclude(userId: number | string): void {
  formState.user_ids = formState.user_ids.filter(
    (id) => String(id) !== String(userId),
  );
}

function removeManualExclude(userId: number | string): void {
  formState.excluded_user_ids = formState.excluded_user_ids.filter(
    (id) => String(id) !== String(userId),
  );
}

function handleSelectInclude(userId: unknown): void {
  if (typeof userId !== 'number' && typeof userId !== 'string') {
    return;
  }

  const userIdStr = String(userId);
  formState.excluded_user_ids = formState.excluded_user_ids.filter(
    (id) => String(id) !== userIdStr,
  );
  if (!formState.user_ids.includes(userIdStr)) {
    formState.user_ids = [...formState.user_ids, userIdStr];
  }
  showIncludeSelect.value = false;
}

function handleSelectExclude(userId: unknown): void {
  if (typeof userId !== 'number' && typeof userId !== 'string') {
    return;
  }

  excludeUser(userId);
  showExcludeSelect.value = false;
}

function filterUserOption(input: string, option: unknown): boolean {
  if (typeof option !== 'object' || option === null || !('value' in option)) {
    return false;
  }

  const optionValue = option.value;
  if (typeof optionValue !== 'number' && typeof optionValue !== 'string') {
    return false;
  }

  const user = users.value.find((u) => String(u.id) === String(optionValue));
  if (user === undefined) {
    return false;
  }

  const searchStr = `${user.name} ${user.username}`.toLowerCase();
  return searchStr.includes(input.trim().toLowerCase());
}

const formRules = computed(() => ({
  latitude: [
    {
      message: $t('page.attendanceLocations.validation.latitudeRequired'),
      required: true,
    },
  ],
  longitude: [
    {
      message: $t('page.attendanceLocations.validation.longitudeRequired'),
      required: true,
    },
  ],
  name: [
    {
      message: $t('page.attendanceLocations.validation.nameRequired'),
      required: true,
    },
  ],
  radius_meters: [
    {
      message: $t('page.attendanceLocations.validation.radiusRequired'),
      required: true,
    },
  ],
  validation_mode: [
    {
      message: $t('page.attendanceLocations.validation.validationModeRequired'),
      required: true,
    },
  ],
}));

const pageTitle = computed(() => {
  if (props.mode === 'create') {
    return $t('page.attendanceLocations.create.title');
  }

  if (props.mode === 'edit') {
    return originalEntity.value === undefined
      ? $t('page.attendanceLocations.edit.title')
      : `${$t('page.attendanceLocations.edit.title')}: ${originalEntity.value.name}`;
  }

  return originalEntity.value === undefined
    ? $t('page.attendanceLocations.detail.title')
    : `${$t('page.attendanceLocations.detail.title')}: ${originalEntity.value.name}`;
});

const canEdit = computed(() =>
  hasAccessByCodes(['attendance-locations.update']),
);

function syncMapStateFromForm(): void {
  if (formState.latitude !== '') {
    mapState.latitude = Number(formState.latitude);
  }

  if (formState.longitude !== '') {
    mapState.longitude = Number(formState.longitude);
  }

  if (formState.radius_meters !== '') {
    mapState.radius_meters = Number(formState.radius_meters);
  }
}

function setFormValues(values: AttendanceLocationFormValues): void {
  Object.assign(formState, values);
  syncMapStateFromForm();
}

async function loadOptions(): Promise<void> {
  optionsLoading.value = true;
  try {
    const companyId = authStore.user?.company_id;
    if (!companyId) {
      return;
    }

    const [departmentsList, allUsers] = await Promise.all([
      departmentOptionsResource.getAll(),
      companyUsersResource.getAll({
        department_company_id: companyId,
      }),
    ]);
    departments.value = departmentsList;
    users.value = allUsers;
  } finally {
    optionsLoading.value = false;
  }
}

async function loadEditableState(): Promise<void> {
  loading.value = true;
  try {
    await loadOptions();
    if (props.mode === 'create') {
      setFormValues(DEFAULT_FORM_VALUES);
      return;
    }

    if (!props.id) {
      return;
    }

    const data = await attendanceLocationsResource.getById(props.id);
    originalEntity.value = data;
    setFormValues(toAttendanceLocationFormValues(data));
  } catch (error) {
    showRequestError(
      error,
      $t('page.attendanceLocations.messages.unexpectedError'),
      'Failed to load attendance location details:',
    );
    goBack();
  } finally {
    loading.value = false;
  }
}

async function loadReadonlyState(): Promise<void> {
  if (!props.id) {
    return;
  }

  loading.value = true;
  try {
    originalEntity.value = await attendanceLocationsResource.getById(props.id);
  } catch (error) {
    showRequestError(
      error,
      $t('page.attendanceLocations.messages.unexpectedError'),
      'Failed to load attendance location details:',
    );
    goBack();
  } finally {
    loading.value = false;
  }
}

function handleMapChange(position: { latitude: number; longitude: number }) {
  mapState.latitude = position.latitude;
  mapState.longitude = position.longitude;
  formState.latitude = String(position.latitude);
  formState.longitude = String(position.longitude);
}

async function getCurrentLocation() {
  if (!navigator.geolocation) {
    notification.warning({
      message: $t('page.attendanceLocations.messages.geolocationUnsupported'),
    });
    return;
  }

  locating.value = true;
  navigator.geolocation.getCurrentPosition(
    (position) => {
      mapState.latitude = position.coords.latitude;
      mapState.longitude = position.coords.longitude;
      formState.latitude = String(position.coords.latitude);
      formState.longitude = String(position.coords.longitude);
      notification.success({
        message: $t('page.attendanceLocations.messages.geolocationSuccess'),
      });
      locating.value = false;
    },
    (error) => {
      let msg = $t('page.attendanceLocations.messages.geolocationUnknown');

      switch (error.code) {
        case error.PERMISSION_DENIED: {
          msg = $t(
            'page.attendanceLocations.messages.geolocationPermissionDenied',
          );
          break;
        }
        case error.POSITION_UNAVAILABLE: {
          msg = $t('page.attendanceLocations.messages.geolocationUnavailable');
          break;
        }
        case error.TIMEOUT: {
          msg = $t('page.attendanceLocations.messages.geolocationTimeout');
          break;
        }
      }

      notification.error({ message: msg });
      locating.value = false;
    },
    { enableHighAccuracy: true, maximumAge: 0, timeout: 10_000 },
  );
}

async function submit() {
  if (props.mode === 'view') {
    return;
  }

  submitting.value = true;
  try {
    await formRef.value?.validate();

    if (props.mode === 'create') {
      await attendanceLocationsResource.create(
        buildAttendanceLocationCreatePayload(formState),
      );
      notification.success({
        message: $t('page.attendanceLocations.messages.created'),
      });
    } else if (props.id) {
      await attendanceLocationsResource.update(
        props.id,
        buildAttendanceLocationUpdatePayload(formState),
      );
      notification.success({
        message: $t('page.attendanceLocations.messages.updated'),
      });
    }

    goBack();
  } catch (error) {
    showRequestError(
      error,
      $t('page.attendanceLocations.messages.unexpectedError'),
      'Failed to save attendance location:',
    );
  } finally {
    submitting.value = false;
  }
}

function goBack() {
  router.push('/master-data/attendance-locations');
}

function navigateToEdit() {
  if (props.id) {
    router.push(`/master-data/attendance-locations/${props.id}/edit`);
  }
}

watch(
  () => [formState.latitude, formState.longitude, formState.radius_meters],
  syncMapStateFromForm,
);

onMounted(async () => {
  if (props.mode === 'view') {
    await loadReadonlyState();
    return;
  }

  await loadEditableState();
});
</script>

<template>
  <Page :title="pageTitle">
    <template #extra>
      <div class="flex flex-wrap items-center gap-3">
        <Button @click="goBack">
          {{ $t('page.attendanceLocations.actions.cancel') }}
        </Button>
        <Button
          v-if="mode === 'view' && canEdit"
          type="primary"
          :icon="h(IconifyIcon, { icon: 'lucide:pencil', class: 'size-4' })"
          @click="navigateToEdit"
        >
          {{ $t('page.attendanceLocations.actions.edit') }}
        </Button>
        <Button
          v-if="mode !== 'view'"
          type="primary"
          :loading="submitting"
          :icon="h(IconifyIcon, { icon: 'lucide:save', class: 'size-4' })"
          @click="submit"
        >
          {{ $t('page.attendanceLocations.actions.save') }}
        </Button>
      </div>
    </template>

    <div
      v-if="mode !== 'view' && (loading || optionsLoading)"
      class="flex min-h-72 items-center justify-center"
    >
      <Spin />
    </div>

    <div
      v-if="mode === 'view' && (loading || optionsLoading)"
      class="flex min-h-72 items-center justify-center"
    >
      <Spin />
    </div>

    <template v-else-if="mode === 'view'">
      <Card v-if="detail !== null" class="rounded-lg shadow-sm">
        <section class="border-b border-border pb-5">
          <div
            class="flex flex-col gap-4 md:flex-row md:items-center md:justify-between"
          >
            <div class="min-w-0 space-y-1">
              <p class="truncate text-xl font-semibold text-foreground">
                {{ detail.name }}
              </p>
              <p class="text-sm text-muted-foreground">
                {{ $t('page.attendanceLocations.detail.title') }}
              </p>
            </div>
            <Tag
              :color="detail.status.active ? 'green' : 'default'"
              class="w-fit rounded-full px-3 py-0.5 text-xs font-medium"
            >
              {{ detail.status.label }}
            </Tag>
          </div>
        </section>

        <section
          v-for="section in detail.sections"
          :key="section.key"
          class="border-t border-border py-5 first:border-t-0 first:pt-5 last:pb-0"
        >
          <header class="mb-4 flex items-center gap-2">
            <IconifyIcon
              :icon="section.icon"
              class="size-4 text-muted-foreground"
            />
            <h3 class="text-sm font-semibold text-foreground">
              {{ section.title }}
            </h3>
          </header>
          <div class="grid grid-cols-1 gap-x-8 gap-y-4 md:grid-cols-2">
            <div
              v-for="row in section.rows"
              :key="row.key"
              :class="row.span === 'full' ? 'md:col-span-2' : ''"
              class="min-w-0 space-y-1"
            >
              <p class="text-xs font-medium text-muted-foreground">
                {{ row.label }}
              </p>
              <div
                v-if="
                  row.tags !== undefined &&
                  row.tags.length > 0 &&
                  row.value !== $t('common.notProvided')
                "
                class="flex flex-wrap gap-2"
              >
                <Tag
                  v-for="tag in row.tags"
                  :key="tag"
                  class="m-0 rounded-full px-3 py-0.5 text-xs"
                >
                  {{ tag }}
                </Tag>
              </div>
              <p v-else class="whitespace-pre-wrap text-sm text-foreground">
                {{ row.value }}
              </p>
            </div>
          </div>
        </section>
      </Card>
    </template>

    <Card v-else class="rounded-lg shadow-sm">
      <Form
        ref="formRef"
        :model="formState"
        :rules="formRules"
        class="attendance-location-form"
        layout="vertical"
      >
        <Tabs>
          <Tabs.TabPane key="basic">
            <template #tab>
              <span class="inline-flex items-center gap-2">
                <IconifyIcon icon="lucide:map-pin" class="size-4" />
                {{ $t('page.attendanceLocations.sections.basic') }}
              </span>
            </template>

            <div
              class="grid grid-cols-1 gap-5 pt-2 xl:grid-cols-[minmax(280px,420px)_minmax(0,1fr)]"
            >
              <div
                class="grid grid-cols-1 gap-x-5 gap-y-1 md:grid-cols-2 xl:grid-cols-1"
              >
                <FormItem
                  :label="$t('page.attendanceLocations.fields.name')"
                  name="name"
                >
                  <Input
                    v-model:value="formState.name"
                    :placeholder="
                      $t('page.attendanceLocations.placeholders.name')
                    "
                  />
                </FormItem>
                <FormItem
                  :label="$t('page.attendanceLocations.fields.validationMode')"
                  name="validation_mode"
                >
                  <Select
                    v-model:value="formState.validation_mode"
                    :options="validationModeOptions"
                    :placeholder="
                      $t('page.attendanceLocations.placeholders.validationMode')
                    "
                  />
                </FormItem>
                <FormItem
                  :label="$t('page.attendanceLocations.fields.status')"
                  name="is_active"
                >
                  <Switch v-model:checked="formState.is_active" />
                </FormItem>
                <FormItem
                  :label="$t('page.attendanceLocations.fields.latitude')"
                  name="latitude"
                >
                  <Input
                    v-model:value="formState.latitude"
                    inputmode="decimal"
                    :placeholder="
                      $t('page.attendanceLocations.placeholders.latitude')
                    "
                    type="text"
                  />
                </FormItem>
                <FormItem
                  :label="$t('page.attendanceLocations.fields.longitude')"
                  name="longitude"
                >
                  <Input
                    v-model:value="formState.longitude"
                    inputmode="decimal"
                    :placeholder="
                      $t('page.attendanceLocations.placeholders.longitude')
                    "
                    type="text"
                  />
                </FormItem>
                <FormItem
                  :label="$t('page.attendanceLocations.fields.radius')"
                  name="radius_meters"
                >
                  <Input
                    v-model:value="formState.radius_meters"
                    inputmode="numeric"
                    :placeholder="
                      $t('page.attendanceLocations.placeholders.radius')
                    "
                    type="text"
                  />
                </FormItem>
              </div>

              <section class="min-w-0 space-y-3">
                <div
                  class="flex flex-col gap-3 md:flex-row md:items-start md:justify-between"
                >
                  <div class="space-y-1">
                    <h3 class="text-sm font-semibold text-foreground">
                      {{ $t('page.attendanceLocations.fields.mapLocation') }}
                    </h3>
                    <p class="text-xs text-muted-foreground">
                      {{ $t('page.attendanceLocations.help.mapPicker') }}
                    </p>
                  </div>
                  <Tooltip
                    :title="
                      $t('page.attendanceLocations.actions.locateCurrent')
                    "
                  >
                    <Button
                      :loading="locating"
                      class="w-fit"
                      :icon="
                        h(IconifyIcon, {
                          icon: 'lucide:crosshair',
                          class: 'size-4',
                        })
                      "
                      @click="getCurrentLocation"
                    >
                      {{ $t('page.attendanceLocations.actions.locateCurrent') }}
                    </Button>
                  </Tooltip>
                </div>
                <MapboxMapPicker
                  :latitude="mapState.latitude"
                  :longitude="mapState.longitude"
                  :radius="mapState.radius_meters"
                  @change="handleMapChange"
                />
              </section>
            </div>
          </Tabs.TabPane>

          <Tabs.TabPane key="ips">
            <template #tab>
              <span class="inline-flex items-center gap-2">
                <IconifyIcon icon="lucide:network" class="size-4" />
                {{ $t('page.attendanceLocations.sections.ips') }}
              </span>
            </template>

            <div class="pt-2">
              <FormItem
                :label="$t('page.attendanceLocations.fields.ips')"
                name="ip_addresses"
              >
                <Select
                  v-model:value="formState.ip_addresses"
                  mode="tags"
                  :placeholder="$t('page.attendanceLocations.placeholders.ips')"
                />
              </FormItem>
            </div>
          </Tabs.TabPane>

          <Tabs.TabPane key="departments">
            <template #tab>
              <span class="inline-flex items-center gap-2">
                <IconifyIcon icon="lucide:building-2" class="size-4" />
                {{ $t('page.attendanceLocations.fields.departments') }}
              </span>
            </template>

            <div class="pt-2">
              <FormItem
                :label="$t('page.attendanceLocations.fields.departments')"
                name="department_ids"
              >
                <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
                  <div class="flex flex-col gap-3">
                    <Input
                      v-model:value="departmentSearch"
                      :placeholder="
                        $t(
                          'page.attendanceLocations.placeholders.departmentSearch',
                        )
                      "
                      allow-clear
                    />
                    <div
                      class="min-h-[300px] max-h-[400px] overflow-y-auto rounded-lg border border-solid border-gray-200 bg-gray-50/50 p-4 dark:border-gray-800 dark:bg-gray-900/50"
                    >
                      <Checkbox.Group
                        v-model:value="formState.department_ids"
                        class="w-full"
                      >
                        <div class="flex flex-col gap-2">
                          <Checkbox
                            v-for="department in filteredDepartmentOptions"
                            :key="department.value"
                            :value="department.value"
                            class="m-0"
                          >
                            {{ department.label }}
                          </Checkbox>
                        </div>
                      </Checkbox.Group>
                    </div>
                  </div>

                  <div class="flex flex-col gap-3">
                    <div
                      class="flex min-h-[352px] max-h-[450px] flex-col gap-2 overflow-y-auto rounded-lg border border-solid border-gray-200 bg-gray-50/50 p-4 dark:border-gray-800 dark:bg-gray-900/50"
                    >
                      <div
                        class="mb-2 flex items-center justify-between text-xs font-semibold text-muted-foreground"
                      >
                        <span>{{
                          $t(
                            'page.attendanceLocations.customAssign.selectedDepartments',
                          )
                        }}</span>
                        <Tag
                          color="blue"
                          class="m-0 rounded-full px-2 py-0.5 text-xs font-medium"
                        >
                          {{ formState.department_ids.length }}
                        </Tag>
                      </div>
                      <div
                        v-if="selectedDepartments.length === 0"
                        class="flex flex-1 items-center justify-center text-sm italic text-muted-foreground"
                      >
                        {{
                          $t(
                            'page.attendanceLocations.customAssign.noDepartmentSelected',
                          )
                        }}
                      </div>
                      <div v-else class="flex flex-col gap-2">
                        <div
                          v-for="dep in selectedDepartments"
                          :key="dep.id"
                          class="flex items-center justify-between rounded-lg border border-solid border-gray-200 bg-card p-2.5 text-card-foreground shadow-sm transition-shadow hover:shadow-md dark:border-gray-800"
                        >
                          <span class="text-sm font-medium">{{
                            dep.name
                          }}</span>
                          <Tooltip
                            :title="
                              $t('page.attendanceLocations.actions.delete')
                            "
                          >
                            <Button
                              type="text"
                              danger
                              shape="circle"
                              size="small"
                              class="flex items-center justify-center shrink-0"
                              :icon="
                                h(IconifyIcon, {
                                  icon: 'lucide:trash-2',
                                  class: 'size-4',
                                })
                              "
                              @click="removeDepartment(dep.id)"
                            />
                          </Tooltip>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </FormItem>
            </div>
          </Tabs.TabPane>

          <Tabs.TabPane key="users">
            <template #tab>
              <span class="inline-flex items-center gap-2">
                <IconifyIcon icon="lucide:users" class="size-4" />
                {{ $t('page.attendanceLocations.fields.users') }}
              </span>
            </template>

            <div class="pt-2">
              <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
                <div class="flex flex-col gap-3">
                  <div class="flex items-center justify-between">
                    <h4 class="text-sm font-semibold text-foreground m-0">
                      {{
                        $t(
                          'page.attendanceLocations.customAssign.applicableUsers',
                        )
                      }}
                      ({{ applicableUsers.length }})
                    </h4>
                    <Input
                      v-model:value="activeUserSearch"
                      size="small"
                      :placeholder="
                        $t(
                          'page.attendanceLocations.customAssign.searchActiveUsers',
                        )
                      "
                      class="w-48"
                      allow-clear
                    />
                  </div>

                  <div
                    class="flex min-h-[350px] max-h-[500px] flex-col gap-2 overflow-y-auto rounded-lg border border-solid border-gray-200 bg-gray-50/50 p-4 dark:border-gray-800 dark:bg-gray-900/50"
                  >
                    <div
                      v-if="filteredApplicableUsers.length === 0"
                      class="flex flex-1 items-center justify-center text-sm italic text-muted-foreground"
                    >
                      {{
                        $t(
                          'page.attendanceLocations.customAssign.noActiveUsers',
                        )
                      }}
                    </div>
                    <div
                      v-for="user in filteredApplicableUsers"
                      :key="user.id"
                      class="flex items-center justify-between rounded-lg border border-solid border-gray-200 bg-card p-3 text-card-foreground shadow-sm transition-shadow hover:shadow-md dark:border-gray-800"
                    >
                      <div class="flex flex-col min-w-0">
                        <span
                          class="text-sm font-semibold text-foreground truncate"
                        >
                          {{ user.name }}
                        </span>
                        <span class="text-xs text-muted-foreground truncate">
                          @{{ user.username }}
                        </span>
                      </div>
                      <Button
                        type="primary"
                        danger
                        ghost
                        size="small"
                        class="flex items-center gap-1 shrink-0"
                        :icon="
                          h(IconifyIcon, {
                            icon: 'lucide:user-x',
                            class: 'size-3.5',
                          })
                        "
                        @click="excludeUser(user.id)"
                      >
                        {{
                          $t('page.attendanceLocations.customAssign.excludeBtn')
                        }}
                      </Button>
                    </div>
                  </div>
                </div>

                <div class="flex flex-col gap-3">
                  <h4 class="text-sm font-semibold text-foreground m-0">
                    {{
                      $t('page.attendanceLocations.customAssign.customRules')
                    }}
                  </h4>

                  <div
                    class="flex min-h-[350px] max-h-[500px] flex-col justify-between gap-4 overflow-y-auto rounded-lg border border-solid border-gray-200 bg-gray-50/50 p-4 dark:border-gray-800 dark:bg-gray-900/50"
                  >
                    <div class="flex flex-1 flex-col gap-2">
                      <div
                        v-if="customUserRules.length === 0"
                        class="flex flex-1 items-center justify-center text-sm italic text-muted-foreground"
                      >
                        {{
                          $t(
                            'page.attendanceLocations.customAssign.noCustomRules',
                          )
                        }}
                      </div>
                      <div v-else class="flex flex-col gap-2">
                        <div
                          v-for="rule in customUserRules"
                          :key="rule.user.id"
                          class="flex items-center justify-between rounded-lg border border-solid border-gray-200 bg-card p-2 text-card-foreground shadow-sm dark:border-gray-800"
                        >
                          <div class="flex items-center gap-3 min-w-0">
                            <span
                              v-if="rule.type === 'include'"
                              class="flex items-center justify-center size-5 rounded-full bg-green-500/10 text-green-600 dark:text-green-400 font-bold text-sm shrink-0"
                            >
                              +
                            </span>
                            <span
                              v-else
                              class="flex items-center justify-center size-5 rounded-full bg-red-500/10 text-red-600 dark:text-red-400 font-bold text-sm shrink-0"
                            >
                              -
                            </span>
                            <div class="flex flex-col min-w-0">
                              <span
                                class="text-sm font-medium text-foreground truncate"
                              >
                                {{ rule.user.name }}
                              </span>
                              <span
                                class="text-xs text-muted-foreground truncate"
                              >
                                @{{ rule.user.username }}
                              </span>
                            </div>
                          </div>

                          <Tooltip
                            :title="
                              $t('page.attendanceLocations.actions.delete')
                            "
                          >
                            <Button
                              type="text"
                              danger
                              shape="circle"
                              size="small"
                              class="shrink-0"
                              :icon="
                                h(IconifyIcon, {
                                  icon: 'lucide:trash-2',
                                  class: 'size-4',
                                })
                              "
                              @click="
                                rule.type === 'include'
                                  ? removeManualInclude(rule.user.id)
                                  : removeManualExclude(rule.user.id)
                              "
                            />
                          </Tooltip>
                        </div>
                      </div>
                    </div>

                    <div
                      class="flex flex-col gap-2 border-t border-solid border-gray-200 pt-3 dark:border-gray-800"
                    >
                      <div class="grid grid-cols-2 gap-2">
                        <template v-if="!showIncludeSelect">
                          <Button
                            type="dashed"
                            class="flex items-center justify-center gap-1 text-green-600 border-green-300 hover:text-green-700 hover:border-green-400"
                            :icon="
                              h(IconifyIcon, {
                                icon: 'lucide:user-plus',
                                class: 'size-4',
                              })
                            "
                            @click="
                              showIncludeSelect = true;
                              showExcludeSelect = false;
                            "
                          >
                            {{
                              $t(
                                'page.attendanceLocations.customAssign.includeBtn',
                              )
                            }}
                          </Button>
                        </template>
                        <template v-else>
                          <div class="col-span-2 flex gap-1 w-full">
                            <Select
                              show-search
                              :placeholder="
                                $t(
                                  'page.attendanceLocations.customAssign.includePlaceholder',
                                )
                              "
                              :filter-option="filterUserOption"
                              class="flex-1"
                              @change="handleSelectInclude"
                            >
                              <Select.Option
                                v-for="user in availableForInclude"
                                :key="user.id"
                                :value="user.id"
                              >
                                {{ user.name }} (@{{ user.username }})
                              </Select.Option>
                            </Select>
                            <Button @click="showIncludeSelect = false">
                              {{
                                $t('page.attendanceLocations.actions.cancel')
                              }}
                            </Button>
                          </div>
                        </template>

                        <template v-if="!showExcludeSelect">
                          <Button
                            type="dashed"
                            class="flex items-center justify-center gap-1 text-red-600 border-red-300 hover:text-red-700 hover:border-red-400"
                            :icon="
                              h(IconifyIcon, {
                                icon: 'lucide:user-minus',
                                class: 'size-4',
                              })
                            "
                            @click="
                              showExcludeSelect = true;
                              showIncludeSelect = false;
                            "
                          >
                            {{
                              $t(
                                'page.attendanceLocations.customAssign.excludeBtnAction',
                              )
                            }}
                          </Button>
                        </template>
                        <template v-else>
                          <div class="col-span-2 flex gap-1 w-full">
                            <Select
                              show-search
                              :placeholder="
                                $t(
                                  'page.attendanceLocations.customAssign.excludePlaceholder',
                                )
                              "
                              :filter-option="filterUserOption"
                              class="flex-1"
                              @change="handleSelectExclude"
                            >
                              <Select.Option
                                v-for="user in availableForExclude"
                                :key="user.id"
                                :value="user.id"
                              >
                                {{ user.name }} (@{{ user.username }})
                              </Select.Option>
                            </Select>
                            <Button @click="showExcludeSelect = false">
                              {{
                                $t('page.attendanceLocations.actions.cancel')
                              }}
                            </Button>
                          </div>
                        </template>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </Tabs.TabPane>
        </Tabs>
      </Form>
    </Card>
  </Page>
</template>

<style scoped>
:deep(.attendance-location-form .ant-form-item-label > label) {
  font-size: 14px;
  font-weight: 500;
}
</style>
