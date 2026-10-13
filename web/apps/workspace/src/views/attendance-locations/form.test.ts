import type { AttendanceLocation, Department, User } from '#/api';

import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  buildAttendanceLocationCreatePayload,
  buildAttendanceLocationDetail,
  buildAttendanceLocationUpdatePayload,
  toAttendanceLocationFormValues,
  useAttendanceLocationFormSchema,
} from './form';

const accessMocks = vi.hoisted(() => ({
  hasAccessByCodes: vi.fn(),
}));

const authStoreMocks = vi.hoisted(() => ({
  user: {
    company_id: 'company-1',
  },
}));

const apiMocks = vi.hoisted(() => {
  const departmentFixture: Department = {
    children: [],
    company: null,
    company_id: 'company-1',
    created_at: null,
    id: 'dept-1',
    name: 'Operations',
    parent: null,
    parent_id: null,
    updated_at: null,
  };
  const userFixture: User = {
    avatar: null,
    company: null,
    company_id: 'company-1',
    created_at: '2026-06-24T00:00:00.000000Z',
    departments: [],
    email: 'alice@example.com',
    email_verified_at: null,
    id: 'user-1',
    is_active: true,
    name: 'Alice',
    profile: null,
    roles: [],
    supabase_id: null,
    updated_at: '2026-06-24T00:00:00.000000Z',
    username: 'alice',
  };

  return {
    companyUsersResource: {
      getAll: vi.fn().mockResolvedValue([userFixture]),
    },
    departmentFixture,
    departmentOptionsResource: {
      getAll: vi.fn().mockResolvedValue([departmentFixture]),
    },
  };
});

vi.mock('@vben/access', () => ({
  useAccess: () => ({
    hasAccessByCodes: accessMocks.hasAccessByCodes,
  }),
}));

vi.mock('#/store', () => ({
  useAuthStore: () => authStoreMocks,
}));

vi.mock('#/api', () => ({
  companyUsersResource: apiMocks.companyUsersResource,
  departmentOptionsResource: apiMocks.departmentOptionsResource,
}));

function createAttendanceLocation(
  overrides: Partial<AttendanceLocation> = {},
): AttendanceLocation {
  return {
    created_at: '2026-06-24T00:00:00.000000Z',
    departments: [apiMocks.departmentFixture],
    excluded_users: [],
    id: 'location-1',
    ips: [
      {
        attendance_location_id: 'location-1',
        created_at: '2026-06-24T00:00:00.000000Z',
        id: 'ip-1',
        ip_address: '192.168.1.1',
        updated_at: '2026-06-24T00:00:00.000000Z',
      },
    ],
    is_active: true,
    latitude: 10.762622,
    longitude: 106.660172,
    name: 'Main Office',
    radius_meters: 100,
    updated_at: '2026-06-24T00:00:00.000000Z',
    users: [
      {
        id: 'user-1',
        name: 'Alice',
      },
    ],
    validation_mode: 'both',
    ...overrides,
  };
}

beforeEach(() => {
  accessMocks.hasAccessByCodes.mockReturnValue(false);
});

describe('toAttendanceLocationFormValues', () => {
  it('maps editable fields directly from attendance location object', () => {
    const values = toAttendanceLocationFormValues(createAttendanceLocation());

    expect(values).toEqual({
      department_ids: ['dept-1'],
      excluded_user_ids: [],
      ip_addresses: ['192.168.1.1'],
      is_active: true,
      latitude: '10.762622',
      longitude: '106.660172',
      name: 'Main Office',
      radius_meters: '100',
      user_ids: ['user-1'],
      validation_mode: 'both',
    });
  });
});

describe('payload builders', () => {
  it('builds create payload successfully converting strings to numbers', () => {
    expect(
      buildAttendanceLocationCreatePayload({
        department_ids: ['dept-1'],
        excluded_user_ids: [],
        ip_addresses: ['192.168.1.1', '10.0.0.1'],
        is_active: true,
        latitude: '10.762622',
        longitude: '106.660172',
        name: 'Main Office',
        radius_meters: '100',
        user_ids: ['user-1'],
        validation_mode: 'both',
      }),
    ).toEqual({
      department_ids: ['dept-1'],
      excluded_user_ids: [],
      ip_addresses: ['192.168.1.1', '10.0.0.1'],
      is_active: true,
      latitude: 10.762622,
      longitude: 106.660172,
      name: 'Main Office',
      radius_meters: 100,
      user_ids: ['user-1'],
      validation_mode: 'both',
    });
  });

  it('builds update payload successfully converting strings to numbers', () => {
    expect(
      buildAttendanceLocationUpdatePayload({
        department_ids: ['dept-1'],
        excluded_user_ids: [],
        ip_addresses: ['192.168.1.1', '10.0.0.1'],
        is_active: true,
        latitude: '10.762622',
        longitude: '106.660172',
        name: 'Main Office',
        radius_meters: '100',
        user_ids: ['user-1'],
        validation_mode: 'both',
      }),
    ).toEqual({
      department_ids: ['dept-1'],
      excluded_user_ids: [],
      ip_addresses: ['192.168.1.1', '10.0.0.1'],
      is_active: true,
      latitude: 10.762622,
      longitude: 106.660172,
      name: 'Main Office',
      radius_meters: 100,
      user_ids: ['user-1'],
      validation_mode: 'both',
    });
  });
});

describe('buildAttendanceLocationDetail', () => {
  it('maps fields to readable detail sections', () => {
    const detail = buildAttendanceLocationDetail(createAttendanceLocation());
    expect(detail.name).toBe('Main Office');
    expect(detail.status.active).toBe(true);
  });
});

describe('useAttendanceLocationFormSchema', () => {
  it('builds create form schema with placeholders for editable fields', () => {
    const { createFormSchema } = useAttendanceLocationFormSchema();
    const schema = createFormSchema.value;

    expect(
      schema.find((field) => field.fieldName === 'name')?.componentProps,
    ).toMatchObject({
      placeholder: 'page.attendanceLocations.placeholders.name',
    });

    expect(
      schema.find((field) => field.fieldName === 'validation_mode')
        ?.componentProps,
    ).toMatchObject({
      placeholder: 'page.attendanceLocations.placeholders.validationMode',
    });

    expect(
      schema.find((field) => field.fieldName === '__map_picker')?.component,
    ).toBe('FormSlot');
  });
});
