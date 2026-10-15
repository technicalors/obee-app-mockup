import type { AttendanceLocation, Organization, User } from '#/api';

import { beforeEach, describe, expect, it, vi } from 'vitest';

import { $t } from '#/locales';

import {
  buildAttendanceLocationCreatePayload,
  buildAttendanceLocationDetail,
  buildAttendanceLocationUpdatePayload,
  createAttendanceLocationRadiusInputSchema,
  toAttendanceLocationFormValues,
  updateAttendanceLocationUserAssignments,
  useAttendanceLocationFormSchema,
} from './form';

const accessMocks = vi.hoisted(() => ({
  hasAccessByCodes: vi.fn(),
}));

const authStoreMocks = vi.hoisted(() => ({
  user: {
    root_organization_id: 'root-1',
  },
}));

const apiMocks = vi.hoisted(() => {
  const organizationFixture: Organization = {
    created_at: '2026-06-24T00:00:00.000000Z',
    id: 'org-1',
    name: 'Operations',
    parent_id: null,
    tax_identification_number: null,
    type: 'Công ty',
    updated_at: '2026-06-24T00:00:00.000000Z',
  };
  const userFixture: User = {
    avatar: null,
    organization: null,
    organization_id: 'root-1',
    created_at: '2026-06-24T00:00:00.000000Z',
    email: 'alice@example.com',
    email_verified_at: null,
    id: 'user-1',
    deleted_at: null,
    name: 'Alice',
    profile: null,
    roles: [],
    supabase_id: null,
    updated_at: '2026-06-24T00:00:00.000000Z',
    username: 'alice',
  };

  return {
    userTreeResource: {
      getAll: vi.fn().mockResolvedValue([userFixture]),
    },
    organizationFixture,
    organizationsResource: {
      getAllRows: vi.fn().mockResolvedValue([organizationFixture]),
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
  userTreeResource: apiMocks.userTreeResource,
  organizationsResource: apiMocks.organizationsResource,
  filterOrganizationsByRoot: (organizations: Organization[]) => organizations,
}));

function createAttendanceLocation(
  overrides: Partial<AttendanceLocation> = {},
): AttendanceLocation {
  return {
    created_at: '2026-06-24T00:00:00.000000Z',
    organizations: [apiMocks.organizationFixture],
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
    deleted_at: null,
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

describe('attendance radius input validation', () => {
  it.each(['1', '10001', '2000000000'])('accepts valid input %s', (value) => {
    expect(createAttendanceLocationRadiusInputSchema().parse(value)).toBe(
      value,
    );
  });

  it.each(['2000000001', '0', '-1', '1.5', 'abc'])(
    'shows the allowed range for invalid input %s',
    (value) => {
      const result =
        createAttendanceLocationRadiusInputSchema().safeParse(value);
      expect(result.success).toBe(false);
      if (result.success) throw new Error('Invalid radius was accepted.');
      expect(result.error.issues.map((issue) => issue.message)).toEqual([
        $t('attendanceLocations.validation.radiusRange', {
          max: 2_000_000_000,
        }),
      ]);
    },
  );

  it('shows the required message for empty input', () => {
    const result = createAttendanceLocationRadiusInputSchema().safeParse('');
    expect(result.success).toBe(false);
    if (result.success) throw new Error('Empty radius was accepted.');
    expect(result.error.issues.map((issue) => issue.message)).toEqual([
      $t('attendanceLocations.validation.radiusRequired'),
    ]);
  });
});

describe('toAttendanceLocationFormValues', () => {
  it('maps editable fields directly from attendance location object', () => {
    const values = toAttendanceLocationFormValues(createAttendanceLocation());

    expect(values).toEqual({
      organization_ids: ['org-1'],
      excluded_user_ids: [],
      ip_addresses: ['192.168.1.1'],
      latitude: '10.762622',
      longitude: '106.660172',
      name: 'Main Office',
      radius_meters: '100',
      user_ids: ['user-1'],
      validation_mode: 'both',
    });
  });
});

describe('updateAttendanceLocationUserAssignments', () => {
  it('deduplicates selections and removes users from the opposite assignment', () => {
    const values = {
      organization_ids: [],
      excluded_user_ids: ['user-3'],
      ip_addresses: [],
      latitude: '10',
      longitude: '106',
      name: 'Main Office',
      radius_meters: '100',
      user_ids: ['user-1', 'user-2'],
      validation_mode: 'both',
    };

    updateAttendanceLocationUserAssignments(values, 'user_ids', [
      'user-2',
      'user-3',
      'user-3',
    ]);

    expect(values.user_ids).toEqual(['user-2', 'user-3']);
    expect(values.excluded_user_ids).toEqual([]);

    updateAttendanceLocationUserAssignments(values, 'excluded_user_ids', [
      'user-1',
      'user-2',
      'user-1',
    ]);

    expect(values.user_ids).toEqual(['user-3']);
    expect(values.excluded_user_ids).toEqual(['user-1', 'user-2']);
  });
});

describe('payload builders', () => {
  it('builds create payload successfully converting strings to numbers', () => {
    expect(
      buildAttendanceLocationCreatePayload({
        organization_ids: ['org-1'],
        excluded_user_ids: [],
        ip_addresses: ['192.168.1.1', '10.0.0.1'],
        latitude: '10.762622',
        longitude: '106.660172',
        name: 'Main Office',
        radius_meters: '100',
        user_ids: ['user-1'],
        validation_mode: 'both',
      }),
    ).toEqual({
      organization_ids: ['org-1'],
      excluded_user_ids: [],
      ip_addresses: ['192.168.1.1', '10.0.0.1'],
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
        organization_ids: ['org-1'],
        excluded_user_ids: [],
        ip_addresses: ['192.168.1.1', '10.0.0.1'],
        latitude: '10.762622',
        longitude: '106.660172',
        name: 'Main Office',
        radius_meters: '100',
        user_ids: ['user-1'],
        validation_mode: 'both',
      }),
    ).toEqual({
      organization_ids: ['org-1'],
      excluded_user_ids: [],
      ip_addresses: ['192.168.1.1', '10.0.0.1'],
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
      placeholder: 'attendanceLocations.placeholders.name',
    });

    expect(
      schema.find((field) => field.fieldName === 'validation_mode')
        ?.componentProps,
    ).toMatchObject({
      placeholder: 'attendanceLocations.placeholders.validationMode',
    });

    expect(
      schema.find((field) => field.fieldName === '__map_picker')?.component,
    ).toBe('FormSlot');
  });
});
