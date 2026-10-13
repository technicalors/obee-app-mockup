import type { VbenFormSchema } from '#/adapter/form';
import type {
  AttendanceLocation,
  CreateAttendanceLocationPayload,
  Department,
  UpdateAttendanceLocationPayload,
  User,
} from '#/api';

import { computed, markRaw, ref } from 'vue';

import { formatDateTime } from '@vben/utils';

import _ from 'lodash';

import { z } from '#/adapter/form';
import { companyUsersResource, departmentOptionsResource } from '#/api';
import {
  createAttendanceLocationPayloadSchema,
  updateAttendanceLocationPayloadSchema,
} from '#/api/contracts';
import { $t } from '#/locales';
import { buildSectionedFormSchema } from '#/shared/resource-form';
import { useAuthStore } from '#/store';

export interface AttendanceLocationFormFieldContext {
  departments: readonly Department[];
  users: readonly User[];
}

export interface AttendanceLocationFormValues {
  department_ids: string[];
  excluded_user_ids: string[];
  ip_addresses: string[];
  is_active: boolean;
  latitude: string;
  longitude: string;
  name: string;
  radius_meters: string;
  user_ids: string[];
  validation_mode: string;
}

type AttendanceLocationFormMode = 'create' | 'edit';
type AttendanceLocationFormSectionKey =
  | 'assignments'
  | 'basic'
  | 'ips'
  | 'location';

type AttendanceLocationFormFieldSchema =
  | ((context: AttendanceLocationFormFieldContext) => null | VbenFormSchema)
  | VbenFormSchema;

interface AttendanceLocationFormField {
  key: string;
  label: string;
  modes: readonly AttendanceLocationFormMode[];
  schema?: AttendanceLocationFormFieldSchema;
  span?: 'full' | 'half';
}

interface AttendanceLocationFormGroup {
  children: readonly AttendanceLocationFormField[];
  icon: string;
  key: AttendanceLocationFormSectionKey;
  title: string;
}

export interface AttendanceLocationDetailRow {
  key: string;
  label: string;
  span: 'full' | 'half';
  tags?: readonly string[];
  value: string;
}

export interface AttendanceLocationDetailSection {
  icon: string;
  key: string;
  rows: AttendanceLocationDetailRow[];
  title: string;
}

export interface AttendanceLocationDetail {
  name: string;
  sections: AttendanceLocationDetailSection[];
  status: {
    active: boolean;
    label: string;
  };
}

const attendanceLocationFormGroups: readonly AttendanceLocationFormGroup[] = [
  {
    children: [
      {
        key: 'name',
        label: $t('page.attendanceLocations.fields.name'),
        modes: ['create', 'edit'],
        schema: {
          component: 'Input',
          componentProps: {
            placeholder: $t('page.attendanceLocations.placeholders.name'),
          },
          fieldName: 'name',
          label: $t('page.attendanceLocations.fields.name'),
          rules: markRaw(
            z
              .string()
              .min(1, $t('page.attendanceLocations.validation.nameRequired'))
              .max(255),
          ),
        },
      },
      {
        key: 'validation_mode',
        label: $t('page.attendanceLocations.fields.validationMode'),
        modes: ['create', 'edit'],
        schema: {
          component: 'Select',
          componentProps: {
            options: [
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
            ],
            placeholder: $t(
              'page.attendanceLocations.placeholders.validationMode',
            ),
          },
          fieldName: 'validation_mode',
          label: $t('page.attendanceLocations.fields.validationMode'),
          rules: markRaw(
            z
              .string()
              .min(
                1,
                $t(
                  'page.attendanceLocations.validation.validationModeRequired',
                ),
              ),
          ),
        },
      },
      {
        key: 'is_active',
        label: $t('page.attendanceLocations.fields.status'),
        modes: ['create', 'edit'],
        schema: {
          component: 'Switch',
          componentProps: {
            class: 'w-auto',
          },
          defaultValue: true,
          fieldName: 'is_active',
          label: $t('page.attendanceLocations.fields.status'),
          rules: markRaw(z.boolean()),
        },
      },
    ],
    icon: 'lucide:info',
    key: 'basic',
    title: $t('page.attendanceLocations.sections.basic'),
  },
  {
    children: [
      {
        key: 'latitude',
        label: $t('page.attendanceLocations.fields.latitude'),
        modes: ['create', 'edit'],
        schema: {
          component: 'Input',
          componentProps: {
            inputmode: 'decimal',
            placeholder: $t('page.attendanceLocations.placeholders.latitude'),
            type: 'text',
          },
          fieldName: 'latitude',
          label: $t('page.attendanceLocations.fields.latitude'),
          rules: markRaw(
            z
              .string()
              .min(
                1,
                $t('page.attendanceLocations.validation.latitudeRequired'),
              ),
          ),
        },
      },
      {
        key: 'longitude',
        label: $t('page.attendanceLocations.fields.longitude'),
        modes: ['create', 'edit'],
        schema: {
          component: 'Input',
          componentProps: {
            inputmode: 'decimal',
            placeholder: $t('page.attendanceLocations.placeholders.longitude'),
            type: 'text',
          },
          fieldName: 'longitude',
          label: $t('page.attendanceLocations.fields.longitude'),
          rules: markRaw(
            z
              .string()
              .min(
                1,
                $t('page.attendanceLocations.validation.longitudeRequired'),
              ),
          ),
        },
      },
      {
        key: 'radius_meters',
        label: $t('page.attendanceLocations.fields.radius'),
        modes: ['create', 'edit'],
        schema: {
          component: 'Input',
          componentProps: {
            inputmode: 'numeric',
            placeholder: $t('page.attendanceLocations.placeholders.radius'),
            type: 'text',
          },
          fieldName: 'radius_meters',
          label: $t('page.attendanceLocations.fields.radius'),
          rules: markRaw(
            z
              .string()
              .min(1, $t('page.attendanceLocations.validation.radiusRequired')),
          ),
        },
      },
      {
        key: 'map_picker',
        label: $t('page.attendanceLocations.fields.mapLocation'),
        modes: ['create', 'edit'],
        schema: {
          component: 'FormSlot',
          fieldName: '__map_picker',
          formItemClass: 'md:col-span-2',
          label: $t('page.attendanceLocations.fields.mapLocation'),
          rules: markRaw(z.undefined().optional()),
          valueFormat: () => undefined,
        },
        span: 'full',
      },
    ],
    icon: 'lucide:map-pin',
    key: 'location',
    title: $t('page.attendanceLocations.sections.location'),
  },
  {
    children: [
      {
        key: 'ip_addresses',
        label: $t('page.attendanceLocations.fields.ips'),
        modes: ['edit'],
        schema: {
          component: 'Select',
          componentProps: {
            mode: 'tags',
            placeholder: $t('page.attendanceLocations.placeholders.ips'),
          },
          fieldName: 'ip_addresses',
          formItemClass: 'md:col-span-2',
          label: $t('page.attendanceLocations.fields.ips'),
          rules: markRaw(z.array(z.string()).optional()),
        },
        span: 'full',
      },
    ],
    icon: 'lucide:network',
    key: 'ips',
    title: $t('page.attendanceLocations.sections.ips'),
  },
  {
    children: [
      {
        key: 'department_ids',
        label: $t('page.attendanceLocations.fields.departments'),
        modes: ['edit'],
        schema: ({ departments }) => ({
          component: 'Select',
          componentProps: {
            allowClear: true,
            mode: 'multiple',
            options: departments.map((dept) => ({
              label: dept.name,
              value: String(dept.id),
            })),
            placeholder: $t(
              'page.attendanceLocations.placeholders.departments',
            ),
          },
          fieldName: 'department_ids',
          formItemClass: 'md:col-span-2',
          label: $t('page.attendanceLocations.fields.departments'),
          rules: markRaw(z.array(z.string()).optional()),
        }),
        span: 'full',
      },
      {
        key: 'user_ids',
        label: $t('page.attendanceLocations.fields.users'),
        modes: ['edit'],
        schema: ({ users }) => ({
          component: 'Select',
          componentProps: {
            allowClear: true,
            mode: 'multiple',
            options: users.map((user) => ({
              label: user.name,
              value: String(user.id),
            })),
            placeholder: $t('page.attendanceLocations.placeholders.users'),
          },
          fieldName: 'user_ids',
          formItemClass: 'md:col-span-2',
          label: $t('page.attendanceLocations.fields.users'),
          rules: markRaw(z.array(z.string()).optional()),
        }),
        span: 'full',
      },
      {
        key: 'excluded_user_ids',
        label: $t('page.attendanceLocations.fields.excludedUsers'),
        modes: ['edit'],
        schema: ({ users }) => ({
          component: 'Select',
          componentProps: {
            allowClear: true,
            mode: 'multiple',
            options: users.map((user) => ({
              label: user.name,
              value: String(user.id),
            })),
            placeholder: $t(
              'page.attendanceLocations.placeholders.excludedUsers',
            ),
          },
          fieldName: 'excluded_user_ids',
          formItemClass: 'md:col-span-2',
          label: $t('page.attendanceLocations.fields.excludedUsers'),
          rules: markRaw(z.array(z.string()).optional()),
        }),
        span: 'full',
      },
    ],
    icon: 'lucide:users',
    key: 'assignments',
    title: $t('page.attendanceLocations.sections.assignments'),
  },
];

export function toAttendanceLocationFormValues(
  entity: AttendanceLocation,
): AttendanceLocationFormValues {
  return {
    department_ids: entity.departments.map((d) => String(d.id)),
    excluded_user_ids: entity.excluded_users.map((u) => String(u.id)),
    ip_addresses: entity.ips.map((ip) => ip.ip_address),
    is_active: entity.is_active,
    latitude: String(entity.latitude),
    longitude: String(entity.longitude),
    name: entity.name,
    radius_meters: String(entity.radius_meters),
    user_ids: entity.users.map((u) => String(u.id)),
    validation_mode: entity.validation_mode,
  };
}

export function buildAttendanceLocationCreatePayload(
  values: Record<string, unknown>,
): CreateAttendanceLocationPayload {
  const payload = _.pick(values, [
    'name',
    'latitude',
    'longitude',
    'radius_meters',
    'validation_mode',
    'is_active',
    'user_ids',
    'department_ids',
    'excluded_user_ids',
    'ip_addresses',
  ]);

  if (payload.latitude !== undefined && payload.latitude !== '') {
    payload.latitude = Number(payload.latitude);
  }
  if (payload.longitude !== undefined && payload.longitude !== '') {
    payload.longitude = Number(payload.longitude);
  }
  if (payload.radius_meters !== undefined && payload.radius_meters !== '') {
    payload.radius_meters = Number(payload.radius_meters);
  }

  return createAttendanceLocationPayloadSchema.parse(payload);
}

export function buildAttendanceLocationUpdatePayload(
  values: Record<string, unknown>,
): UpdateAttendanceLocationPayload {
  const payload = _.pick(values, [
    'name',
    'latitude',
    'longitude',
    'radius_meters',
    'validation_mode',
    'is_active',
    'user_ids',
    'department_ids',
    'excluded_user_ids',
    'ip_addresses',
  ]);

  if (payload.latitude !== undefined && payload.latitude !== '') {
    payload.latitude = Number(payload.latitude);
  }
  if (payload.longitude !== undefined && payload.longitude !== '') {
    payload.longitude = Number(payload.longitude);
  }
  if (payload.radius_meters !== undefined && payload.radius_meters !== '') {
    payload.radius_meters = Number(payload.radius_meters);
  }

  return updateAttendanceLocationPayloadSchema.parse(payload);
}

export function buildAttendanceLocationDetail(
  entity: AttendanceLocation,
): AttendanceLocationDetail {
  return {
    name: entity.name,
    sections: [
      {
        icon: 'lucide:info',
        key: 'basic',
        rows: [
          {
            key: 'validation_mode',
            label: $t('page.attendanceLocations.fields.validationMode'),
            span: 'half',
            value: $t(
              `page.attendanceLocations.validationMode.${entity.validation_mode}`,
            ),
          },
        ],
        title: $t('page.attendanceLocations.sections.basic'),
      },
      {
        icon: 'lucide:map-pin',
        key: 'location',
        rows: [
          {
            key: 'latitude',
            label: $t('page.attendanceLocations.fields.latitude'),
            span: 'half',
            value: String(entity.latitude),
          },
          {
            key: 'longitude',
            label: $t('page.attendanceLocations.fields.longitude'),
            span: 'half',
            value: String(entity.longitude),
          },
          {
            key: 'radius_meters',
            label: $t('page.attendanceLocations.fields.radius'),
            span: 'half',
            value: `${entity.radius_meters}m`,
          },
        ],
        title: $t('page.attendanceLocations.sections.location'),
      },
      {
        icon: 'lucide:network',
        key: 'ips',
        rows: [
          {
            key: 'ip_addresses',
            label: $t('page.attendanceLocations.fields.ips'),
            span: 'full',
            value:
              entity.ips.length > 0
                ? entity.ips.map((ip) => ip.ip_address).join(', ')
                : $t('page.attendanceLocations.values.anyIp'),
          },
        ],
        title: $t('page.attendanceLocations.sections.ips'),
      },
      {
        icon: 'lucide:users',
        key: 'assignments',
        rows: [
          {
            key: 'departments',
            label: $t('page.attendanceLocations.fields.departments'),
            span: 'full',
            tags: entity.departments.map((d) => d.name),
            value:
              entity.departments.length > 0
                ? entity.departments.map((d) => d.name).join(', ')
                : $t('common.notProvided'),
          },
          {
            key: 'users',
            label: $t('page.attendanceLocations.fields.users'),
            span: 'full',
            tags: entity.users.map((u) => u.name),
            value:
              entity.users.length > 0
                ? entity.users.map((u) => u.name).join(', ')
                : $t('page.attendanceLocations.values.allUsers'),
          },
          {
            key: 'excluded_users',
            label: $t('page.attendanceLocations.fields.excludedUsers'),
            span: 'full',
            tags: entity.excluded_users.map((u) => u.name),
            value:
              entity.excluded_users.length > 0
                ? entity.excluded_users.map((u) => u.name).join(', ')
                : $t('common.notProvided'),
          },
        ],
        title: $t('page.attendanceLocations.sections.assignments'),
      },
      {
        icon: 'lucide:clock-3',
        key: 'information',
        rows: [
          {
            key: 'created_at',
            label: $t('page.attendanceLocations.fields.createdAt'),
            span: 'half',
            value: formatDateTime(entity.created_at),
          },
          {
            key: 'updated_at',
            label: $t('page.attendanceLocations.fields.updatedAt'),
            span: 'half',
            value: formatDateTime(entity.updated_at),
          },
        ],
        title: $t('page.attendanceLocations.sections.information'),
      },
    ],
    status: {
      active: entity.is_active,
      label: entity.is_active
        ? $t('page.attendanceLocations.status.active')
        : $t('page.attendanceLocations.status.inactive'),
    },
  };
}

export function useAttendanceLocationFormSchema() {
  const departments = ref<Department[]>([]);
  const users = ref<User[]>([]);
  const loading = ref(false);
  const authStore = useAuthStore();

  const fieldContext = computed<AttendanceLocationFormFieldContext>(() => ({
    departments: departments.value,
    users: users.value,
  }));

  const createFormSchema = computed(() =>
    buildSectionedFormSchema({
      context: fieldContext.value,
      groups: attendanceLocationFormGroups,
      mode: 'create',
    }),
  );

  const editFormSchema = computed(() =>
    buildSectionedFormSchema({
      context: fieldContext.value,
      groups: attendanceLocationFormGroups,
      mode: 'edit',
    }),
  );

  async function loadOptions(): Promise<void> {
    loading.value = true;
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
      loading.value = false;
    }
  }

  return {
    createFormSchema,
    editFormSchema,
    loading,
    loadOptions,
  };
}
