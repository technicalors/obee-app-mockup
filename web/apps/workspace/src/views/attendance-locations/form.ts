import type { VbenFormSchema } from '#/adapter/form';
import type {
  AttendanceLocation,
  CreateAttendanceLocationPayload,
  Organization,
  UpdateAttendanceLocationPayload,
  UserTreeSelectionUser,
} from '#/api';

import { computed, markRaw, ref } from 'vue';

import { formatDateTime } from '@vben/utils';

import _ from 'lodash';

import { z } from '#/adapter/form';
import {
  filterOrganizationsByRoot,
  organizationsResource,
  userTreeResource,
} from '#/api';
import {
  createAttendanceLocationPayloadSchema,
  MAX_ATTENDANCE_RADIUS_METERS,
  updateAttendanceLocationPayloadSchema,
} from '#/api/contracts';
import { $t } from '#/locales';
import { buildSectionedFormSchema } from '#/shared/resource-form';
import { useAuthStore } from '#/store';

export interface AttendanceLocationFormFieldContext {
  organizations: readonly Organization[];
  users: readonly UserTreeSelectionUser[];
}

export interface AttendanceLocationFormValues {
  organization_ids: string[];
  excluded_user_ids: string[];
  ip_addresses: string[];
  latitude: string;
  longitude: string;
  name: string;
  radius_meters: string;
  user_ids: string[];
  validation_mode: string;
}

export function createAttendanceLocationRadiusInputSchema() {
  return z
    .string()
    .min(1, $t('attendanceLocations.validation.radiusRequired'))
    .refine(
      (value) =>
        value === '' ||
        createAttendanceLocationPayloadSchema.shape.radius_meters.safeParse(
          Number(value),
        ).success,
      $t('attendanceLocations.validation.radiusRange', {
        max: MAX_ATTENDANCE_RADIUS_METERS,
      }),
    );
}

export function updateAttendanceLocationUserAssignments(
  values: AttendanceLocationFormValues,
  field: 'excluded_user_ids' | 'user_ids',
  selectedIds: string[],
): void {
  const userIds = [...new Set(selectedIds)];

  if (field === 'user_ids') {
    values.user_ids = userIds;
    const includedUserIds = new Set(userIds);
    values.excluded_user_ids = values.excluded_user_ids.filter(
      (userId) => !includedUserIds.has(userId),
    );
    return;
  }

  values.excluded_user_ids = userIds;
  const excludedUserIds = new Set(userIds);
  values.user_ids = values.user_ids.filter(
    (userId) => !excludedUserIds.has(userId),
  );
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
        label: $t('attendanceLocations.fields.name'),
        modes: ['create', 'edit'],
        schema: {
          component: 'Input',
          componentProps: {
            placeholder: $t('attendanceLocations.placeholders.name'),
          },
          fieldName: 'name',
          label: $t('attendanceLocations.fields.name'),
          rules: markRaw(
            z
              .string()
              .min(1, $t('attendanceLocations.validation.nameRequired'))
              .max(255),
          ),
        },
      },
      {
        key: 'validation_mode',
        label: $t('attendanceLocations.fields.validationMode'),
        modes: ['create', 'edit'],
        schema: {
          component: 'Select',
          componentProps: {
            options: [
              {
                label: $t('attendanceLocations.validationMode.location'),
                value: 'location',
              },
              {
                label: $t('attendanceLocations.validationMode.ip'),
                value: 'ip',
              },
              {
                label: $t('attendanceLocations.validationMode.both'),
                value: 'both',
              },
              {
                label: $t('attendanceLocations.validationMode.either'),
                value: 'either',
              },
            ],
            placeholder: $t('attendanceLocations.placeholders.validationMode'),
          },
          fieldName: 'validation_mode',
          label: $t('attendanceLocations.fields.validationMode'),
          rules: markRaw(
            z
              .string()
              .min(
                1,
                $t('attendanceLocations.validation.validationModeRequired'),
              ),
          ),
        },
      },
    ],
    icon: 'lucide:info',
    key: 'basic',
    title: $t('attendanceLocations.sections.basic'),
  },
  {
    children: [
      {
        key: 'latitude',
        label: $t('attendanceLocations.fields.latitude'),
        modes: ['create', 'edit'],
        schema: {
          component: 'Input',
          componentProps: {
            inputmode: 'decimal',
            placeholder: $t('attendanceLocations.placeholders.latitude'),
            type: 'text',
          },
          fieldName: 'latitude',
          label: $t('attendanceLocations.fields.latitude'),
          rules: markRaw(
            z
              .string()
              .min(1, $t('attendanceLocations.validation.latitudeRequired')),
          ),
        },
      },
      {
        key: 'longitude',
        label: $t('attendanceLocations.fields.longitude'),
        modes: ['create', 'edit'],
        schema: {
          component: 'Input',
          componentProps: {
            inputmode: 'decimal',
            placeholder: $t('attendanceLocations.placeholders.longitude'),
            type: 'text',
          },
          fieldName: 'longitude',
          label: $t('attendanceLocations.fields.longitude'),
          rules: markRaw(
            z
              .string()
              .min(1, $t('attendanceLocations.validation.longitudeRequired')),
          ),
        },
      },
      {
        key: 'radius_meters',
        label: $t('attendanceLocations.fields.radius'),
        modes: ['create', 'edit'],
        schema: {
          component: 'Input',
          componentProps: {
            inputmode: 'numeric',
            placeholder: $t('attendanceLocations.placeholders.radius'),
            type: 'text',
          },
          fieldName: 'radius_meters',
          label: $t('attendanceLocations.fields.radius'),
          rules: markRaw(createAttendanceLocationRadiusInputSchema()),
        },
      },
      {
        key: 'map_picker',
        label: $t('attendanceLocations.fields.mapLocation'),
        modes: ['create', 'edit'],
        schema: {
          component: 'FormSlot',
          fieldName: '__map_picker',
          formItemClass: 'md:col-span-2',
          label: $t('attendanceLocations.fields.mapLocation'),
          rules: markRaw(z.undefined().optional()),
          valueFormat: () => undefined,
        },
        span: 'full',
      },
    ],
    icon: 'lucide:map-pin',
    key: 'location',
    title: $t('attendanceLocations.sections.location'),
  },
  {
    children: [
      {
        key: 'ip_addresses',
        label: $t('attendanceLocations.fields.ips'),
        modes: ['edit'],
        schema: {
          component: 'Select',
          componentProps: {
            mode: 'tags',
            placeholder: $t('attendanceLocations.placeholders.ips'),
          },
          fieldName: 'ip_addresses',
          formItemClass: 'md:col-span-2',
          label: $t('attendanceLocations.fields.ips'),
          rules: markRaw(z.array(z.string()).optional()),
        },
        span: 'full',
      },
    ],
    icon: 'lucide:network',
    key: 'ips',
    title: $t('attendanceLocations.sections.ips'),
  },
  {
    children: [
      {
        key: 'organization_ids',
        label: $t('attendanceLocations.fields.organizations'),
        modes: ['edit'],
        schema: ({ organizations }) => ({
          component: 'Select',
          componentProps: {
            allowClear: true,
            mode: 'multiple',
            options: organizations.map((organization) => ({
              label: organization.name,
              value: organization.id,
            })),
            placeholder: $t('attendanceLocations.placeholders.organizations'),
          },
          fieldName: 'organization_ids',
          formItemClass: 'md:col-span-2',
          label: $t('attendanceLocations.fields.organizations'),
          rules: markRaw(z.array(z.string()).optional()),
        }),
        span: 'full',
      },
      {
        key: 'user_ids',
        label: $t('attendanceLocations.fields.users'),
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
            placeholder: $t('attendanceLocations.placeholders.users'),
          },
          fieldName: 'user_ids',
          formItemClass: 'md:col-span-2',
          label: $t('attendanceLocations.fields.users'),
          rules: markRaw(z.array(z.string()).optional()),
        }),
        span: 'full',
      },
      {
        key: 'excluded_user_ids',
        label: $t('attendanceLocations.fields.excludedUsers'),
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
            placeholder: $t('attendanceLocations.placeholders.excludedUsers'),
          },
          fieldName: 'excluded_user_ids',
          formItemClass: 'md:col-span-2',
          label: $t('attendanceLocations.fields.excludedUsers'),
          rules: markRaw(z.array(z.string()).optional()),
        }),
        span: 'full',
      },
    ],
    icon: 'lucide:users',
    key: 'assignments',
    title: $t('attendanceLocations.sections.assignments'),
  },
];

export function toAttendanceLocationFormValues(
  entity: AttendanceLocation,
): AttendanceLocationFormValues {
  return {
    organization_ids: entity.organizations.map(
      (organization) => organization.id,
    ),
    excluded_user_ids: entity.excluded_users.map((u) => String(u.id)),
    ip_addresses: entity.ips.map((ip) => ip.ip_address),
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
    'user_ids',
    'organization_ids',
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
    'user_ids',
    'organization_ids',
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
            label: $t('attendanceLocations.fields.validationMode'),
            span: 'half',
            value: $t(
              `attendanceLocations.validationMode.${entity.validation_mode}`,
            ),
          },
        ],
        title: $t('attendanceLocations.sections.basic'),
      },
      {
        icon: 'lucide:map-pin',
        key: 'location',
        rows: [
          {
            key: 'latitude',
            label: $t('attendanceLocations.fields.latitude'),
            span: 'half',
            value: String(entity.latitude),
          },
          {
            key: 'longitude',
            label: $t('attendanceLocations.fields.longitude'),
            span: 'half',
            value: String(entity.longitude),
          },
          {
            key: 'radius_meters',
            label: $t('attendanceLocations.fields.radius'),
            span: 'half',
            value: `${entity.radius_meters}m`,
          },
        ],
        title: $t('attendanceLocations.sections.location'),
      },
      {
        icon: 'lucide:network',
        key: 'ips',
        rows: [
          {
            key: 'ip_addresses',
            label: $t('attendanceLocations.fields.ips'),
            span: 'full',
            value:
              entity.ips.length > 0
                ? entity.ips.map((ip) => ip.ip_address).join(', ')
                : $t('attendanceLocations.values.anyIp'),
          },
        ],
        title: $t('attendanceLocations.sections.ips'),
      },
      {
        icon: 'lucide:users',
        key: 'assignments',
        rows: [
          {
            key: 'organizations',
            label: $t('attendanceLocations.fields.organizations'),
            span: 'full',
            tags: entity.organizations.map((organization) => organization.name),
            value:
              entity.organizations.length > 0
                ? entity.organizations
                    .map((organization) => organization.name)
                    .join(', ')
                : $t('common.notProvided'),
          },
          {
            key: 'users',
            label: $t('attendanceLocations.fields.users'),
            span: 'full',
            tags: entity.users.map((u) => u.name),
            value:
              entity.users.length > 0
                ? entity.users.map((u) => u.name).join(', ')
                : $t('attendanceLocations.values.allUsers'),
          },
          {
            key: 'excluded_users',
            label: $t('attendanceLocations.fields.excludedUsers'),
            span: 'full',
            tags: entity.excluded_users.map((u) => u.name),
            value:
              entity.excluded_users.length > 0
                ? entity.excluded_users.map((u) => u.name).join(', ')
                : $t('common.notProvided'),
          },
        ],
        title: $t('attendanceLocations.sections.assignments'),
      },
      {
        icon: 'lucide:clock-3',
        key: 'information',
        rows: [
          {
            key: 'created_at',
            label: $t('attendanceLocations.fields.createdAt'),
            span: 'half',
            value: formatDateTime(entity.created_at),
          },
          {
            key: 'updated_at',
            label: $t('attendanceLocations.fields.updatedAt'),
            span: 'half',
            value: formatDateTime(entity.updated_at),
          },
        ],
        title: $t('attendanceLocations.sections.information'),
      },
    ],
    status: {
      active: entity.deleted_at === null,
      label:
        entity.deleted_at === null
          ? $t('attendanceLocations.status.active')
          : $t('attendanceLocations.status.deleted'),
    },
  };
}

export function useAttendanceLocationFormSchema() {
  const organizations = ref<Organization[]>([]);
  const users = ref<UserTreeSelectionUser[]>([]);
  const loading = ref(false);
  const authStore = useAuthStore();

  const fieldContext = computed<AttendanceLocationFormFieldContext>(() => ({
    organizations: organizations.value,
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
      const rootOrganizationId = authStore.user?.root_organization_id;
      if (rootOrganizationId === null || rootOrganizationId === undefined) {
        organizations.value = [];
        users.value = [];
        return;
      }
      const [allOrganizations, allUsers] = await Promise.all([
        organizationsResource.getAllRows(),
        userTreeResource.getAll({ root_organization_id: rootOrganizationId }),
      ]);
      organizations.value = filterOrganizationsByRoot(
        allOrganizations,
        rootOrganizationId,
      );
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
