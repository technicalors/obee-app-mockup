import type { UserProfileFormValues } from './form';

import type { User } from '#/api';

import dayjs from 'dayjs';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import {
  buildUserCreatePayload,
  buildUserDetail,
  buildUserPasswordResetPayload,
  buildUserUpdatePayload,
  mergeUserFormValues,
  userEditFormValuesSchema,
  useUserFormSchema,
  waitForMinimumUserModalLoading,
} from './form';

const accessMocks = vi.hoisted(() => ({
  hasAccessByCodes: vi.fn(),
}));

const preferenceMocks = vi.hoisted(() => ({
  locale: {
    value: 'vi-VN',
  },
}));

const roleOptionsMocks = vi.hoisted(() => ({
  loadOnce: vi.fn(),
  roles: [
    {
      created_at: '2026-06-11T00:00:00.000000Z',
      description: null,
      id: 'role-1',
      name: 'admin',
      updated_at: '2026-06-11T00:00:00.000000Z',
    },
  ],
}));

const resourceMocks = vi.hoisted(() => ({
  getOrganizations: vi.fn().mockResolvedValue([]),
  getPositions: vi.fn().mockResolvedValue([]),
}));

vi.mock('@vben/access', () => ({
  useAccess: () => ({
    hasAccessByCodes: accessMocks.hasAccessByCodes,
  }),
}));

vi.mock('@vben/preferences', () => ({
  usePreferences: () => ({
    locale: preferenceMocks.locale,
  }),
}));

vi.mock('#/store/role-options', () => ({
  useRoleOptionsStore: () => roleOptionsMocks,
}));

vi.mock('#/api', () => ({
  organizationsResource: {
    getAllRows: resourceMocks.getOrganizations,
  },
  positionOptionsResource: {
    getAll: resourceMocks.getPositions,
  },
}));

function createUser(overrides: Partial<User> = {}): User {
  return {
    avatar: null,
    organization: {
      created_at: '2026-06-10T00:00:00.000000Z',
      id: 'organization-1',
      name: 'Operations',
      parent_id: null,
      tax_identification_number: null,
      type: 'Công ty',
      updated_at: '2026-06-10T00:00:00.000000Z',
    },
    organization_id: 'organization-1',
    created_at: '2026-06-11T00:00:00.000000Z',
    email: 'admin@example.com',
    email_verified_at: null,
    id: 'user-1',
    deleted_at: null,
    name: 'Admin User',
    profile: {
      address: '123 Main St',
      age: 30.1,
      bank_account_number: '0123456789',
      birthday: '1995-05-20',
      citizen_identification_card: null,
      code: 'EMP-001',
      created_at: '2026-06-11T00:00:00.000000Z',
      dependent_tax_identification_number: 'DPT-001',
      education_level: 'university',
      employee_type: 'employee',
      health_insurance_card_number: null,
      joined_at: '2020-01-01',
      phone_number: '+84987654321',
      personal_tax_identification_number: 'PIT-001',
      position: {
        created_at: '2026-06-11T00:00:00.000000Z',
        description: null,
        id: 'position-1',
        name: 'Engineer',
        updated_at: '2026-06-11T00:00:00.000000Z',
      },
      position_id: 'position-1',
      seniority: 4.6,
      sex: 'male',
      social_insurance_number: null,
      starting_date: '2021-01-01',
      updated_at: '2026-06-11T00:00:00.000000Z',
    },
    roles: [
      {
        created_at: '2026-06-11T00:00:00.000000Z',
        description: null,
        id: 'role-1',
        name: 'admin',
        updated_at: '2026-06-11T00:00:00.000000Z',
      },
    ],
    supabase_id: null,
    updated_at: '2026-06-12T00:00:00.000000Z',
    username: 'admin',
    ...overrides,
  };
}

beforeEach(() => {
  accessMocks.hasAccessByCodes.mockReturnValue(false);
  preferenceMocks.locale.value = 'vi-VN';
  resourceMocks.getOrganizations.mockReset().mockResolvedValue([]);
  resourceMocks.getPositions.mockReset().mockResolvedValue([]);
});

afterEach(() => {
  vi.useRealTimers();
});

describe('waitForMinimumUserModalLoading', () => {
  it('keeps loading visible for at least 500 milliseconds', async () => {
    vi.useFakeTimers();

    const waiting = waitForMinimumUserModalLoading(Date.now());

    await vi.advanceTimersByTimeAsync(499);
    expect(vi.getTimerCount()).toBe(1);

    await vi.advanceTimersByTimeAsync(1);
    await expect(waiting).resolves.toBeUndefined();
  });
});

describe('userEditFormValuesSchema', () => {
  it('transforms the user contract into separately owned form values', () => {
    const values = userEditFormValuesSchema.parse(createUser());

    expect(values.basic).toMatchObject({
      organization_id: 'organization-1',
      name: 'Admin User',
      new_password: '',
      profile: {
        code: 'EMP-001',
        position_id: 'position-1',
      },
      role_names: ['admin'],
      username: 'admin',
    });
    expect(values.additional).toMatchObject({
      email: 'admin@example.com',
      profile: {
        address: '123 Main St',
        sex: 'male',
      },
    });

    expect(values.additional.profile.birthday?.format('YYYY-MM-DD')).toBe(
      '1995-05-20',
    );
    expect(values.additional.profile.joined_at?.format('YYYY-MM-DD')).toBe(
      '2020-01-01',
    );
    expect(values.additional.profile.starting_date?.format('YYYY-MM-DD')).toBe(
      '2021-01-01',
    );
    expect(dayjs.isDayjs(values.additional.profile.birthday)).toBe(true);
  });

  it('maps a null email to an empty string for the text field', () => {
    expect(
      userEditFormValuesSchema.parse(createUser({ email: null })).additional
        .email,
    ).toBe('');
  });

  it('initializes a missing profile for an edit payload', () => {
    const values = userEditFormValuesSchema.parse(
      createUser({ email: null, profile: null }),
    );

    expect(values.basic.profile).toEqual({
      code: '',
      position_id: null,
    });
    expect(values.additional).toEqual({
      email: '',
      profile: {},
    });
  });
});

describe('payload builders', () => {
  const profile: UserProfileFormValues = {
    address: '123 Main St',
    bank_account_number: '0123456789',
    birthday: '1995-05-20',
    code: 'EMP-001',
    dependent_tax_identification_number: 'DPT-001',
    education_level: 'university',
    joined_at: '2020-01-01',
    phone_number: '+84987654321',
    personal_tax_identification_number: 'PIT-001',
    position_id: 'position-1',
    sex: 'male' as const,
    starting_date: '2021-01-01',
  };

  it('builds a create payload with the selected organization, position, and roles', () => {
    expect(
      buildUserCreatePayload(
        {
          organization_id: 'organization-1',
          email: 'admin@example.com',
          name: 'Admin User',
          password: 'secret123',
          profile,
          role_names: ['admin'],
          username: 'admin',
        },
        true,
      ),
    ).toMatchObject({
      organization_id: 'organization-1',
      profile: {
        code: 'EMP-001',
        position_id: 'position-1',
      },
      role_names: ['admin'],
    });
  });

  it('maps an empty email form value to null at the request boundary', () => {
    expect(
      buildUserCreatePayload(
        {
          email: '',
          name: 'Legacy User',
          password: 'secret123',
          profile: {
            code: 'legacy.user',
          },
          username: 'legacy.user',
        },
        false,
      ),
    ).toMatchObject({
      email: null,
    });
  });

  it('omits roles from user payloads without role-management access', () => {
    const payload = buildUserUpdatePayload(
      {
        email: 'admin@example.com',
        name: 'Admin User',
        profile,
        role_names: ['admin'],
        username: 'admin',
      },
      false,
    );

    expect(payload).toMatchObject({
      username: 'admin',
    });
    expect(payload).not.toHaveProperty('role_names');
  });

  it('merges basic and additional tab values into one nested profile payload', () => {
    expect(
      mergeUserFormValues(
        {
          name: 'Admin User',
          profile: {
            code: 'EMP-001',
            position_id: 'position-1',
          },
        },
        {
          email: 'admin@example.com',
          profile: {
            birthday: dayjs('1995-05-20'),
            sex: 'male',
          },
          username: 'admin',
        },
      ),
    ).toMatchObject({
      name: 'Admin User',
      profile: {
        code: 'EMP-001',
        position_id: 'position-1',
        sex: 'male',
      },
    });
  });

  it('only creates a password reset payload when an edit password is supplied', () => {
    expect(
      buildUserPasswordResetPayload({
        new_password: '',
      }),
    ).toBeNull();
    expect(
      buildUserPasswordResetPayload({
        new_password: 'secret123',
      }),
    ).toEqual({
      password: 'secret123',
      password_confirmation: 'secret123',
    });
  });
});

describe('useUserFormSchema', () => {
  it('includes a direct organization selector in the basic form', () => {
    accessMocks.hasAccessByCodes.mockReturnValue(true);
    const { createAdditionalFormSchema, createBasicFormSchema } =
      useUserFormSchema();

    const basicFields = createBasicFormSchema.value.map(
      (field) => field.fieldName,
    );
    const additionalFields = createAdditionalFormSchema.value.map(
      (field) => field.fieldName,
    );

    expect(basicFields).toEqual(
      expect.arrayContaining([
        'profile.code',
        'profile.position_id',
        'username',
      ]),
    );
    expect(basicFields).not.toContain('is_active');
    expect(basicFields.at(-1)).toBe('role_names');
    expect(
      createBasicFormSchema.value.find(
        (field) => field.fieldName === 'role_names',
      ),
    ).not.toHaveProperty('formItemClass');
    expect(basicFields).toContain('organization_id');
    expect(additionalFields).toContain('profile.starting_date');
    expect(additionalFields.at(-1)).toBe('profile.address');
    expect(additionalFields).not.toContain('username');
    expect(additionalFields).toEqual(
      expect.arrayContaining([
        'profile.personal_tax_identification_number',
        'profile.dependent_tax_identification_number',
        'profile.bank_account_number',
      ]),
    );

    expect(
      createBasicFormSchema.value.find(
        (field) => field.fieldName === 'profile.code',
      ),
    ).toMatchObject({
      dependencies: {
        triggerFields: ['profile.code'],
      },
    });
    expect(
      createAdditionalFormSchema.value.find(
        (field) => field.fieldName === 'profile.address',
      ),
    ).toMatchObject({
      componentProps: {
        autoSize: {
          maxRows: 4,
          minRows: 2,
        },
      },
      formItemClass: 'col-span-full',
    });
  });

  it('has no status field in the edit forms and accepts an empty phone number', () => {
    const { editAdditionalFormSchema, editBasicFormSchema } =
      useUserFormSchema();
    const phoneField = editAdditionalFormSchema.value.find(
      (field) => field.fieldName === 'profile.phone_number',
    );
    const phoneRule = phoneField?.rules;

    expect(
      editBasicFormSchema.value.map((field) => field.fieldName),
    ).not.toContain('is_active');
    expect(
      editBasicFormSchema.value.map((field) => field.fieldName),
    ).not.toContain('new_password_confirmation');
    expect(
      editAdditionalFormSchema.value.map((field) => field.fieldName),
    ).not.toContain('profile.employee_type');

    if (
      phoneRule === null ||
      phoneRule === undefined ||
      typeof phoneRule === 'string'
    ) {
      throw new TypeError('Phone validation rule is required.');
    }

    expect(phoneRule.safeParse(null).success).toBe(true);
  });

  it('validates create usernames against the users table length', () => {
    const { createBasicFormSchema } = useUserFormSchema();
    const usernameField = createBasicFormSchema.value.find(
      (field) => field.fieldName === 'username',
    );
    const usernameRule = usernameField?.rules;

    if (
      usernameRule === null ||
      usernameRule === undefined ||
      typeof usernameRule === 'string'
    ) {
      throw new TypeError('Username validation rule is required.');
    }

    expect(usernameRule.safeParse('a'.repeat(50)).success).toBe(true);
    expect(usernameRule.safeParse('ab').success).toBe(false);
    expect(usernameRule.safeParse('abc').success).toBe(true);
    expect(usernameRule.safeParse('a'.repeat(51)).success).toBe(false);
  });

  it('auto-fills a blank username from the employee code without validation', async () => {
    const { createBasicFormSchema } = useUserFormSchema();
    const employeeCode = createBasicFormSchema.value.find(
      (field) => field.fieldName === 'profile.code',
    );
    const trigger = employeeCode?.dependencies?.trigger;
    const controller = {
      setFieldValue: vi.fn(),
    };

    if (trigger === undefined) {
      throw new TypeError('Employee code auto-fill trigger is required.');
    }

    await trigger(
      { profile: { code: 'EMP-001' }, username: '' },
      {} as never,
      controller as never,
    );

    expect(controller.setFieldValue).toHaveBeenCalledWith(
      'username',
      'EMP-001',
      false,
    );
  });

  it('keeps a manually entered username when the employee code changes', async () => {
    const { createBasicFormSchema } = useUserFormSchema();
    const employeeCode = createBasicFormSchema.value.find(
      (field) => field.fieldName === 'profile.code',
    );
    const trigger = employeeCode?.dependencies?.trigger;
    const controller = {
      setFieldValue: vi.fn(),
    };

    if (trigger === undefined) {
      throw new TypeError('Employee code auto-fill trigger is required.');
    }

    await trigger(
      { profile: { code: 'EMP-001' }, username: 'manual-user' },
      {} as never,
      controller as never,
    );

    expect(controller.setFieldValue).not.toHaveBeenCalled();
  });

  it('uses the localized education-level options', () => {
    const { createAdditionalFormSchema } = useUserFormSchema();
    const educationLevel = createAdditionalFormSchema.value.find(
      (field) => field.fieldName === 'profile.education_level',
    );

    expect(educationLevel).toMatchObject({
      component: 'Select',
      componentProps: {
        options: [
          { value: 'unskilled_labor' },
          { value: 'intermediate' },
          { value: 'college' },
          { value: 'university' },
          { value: 'master' },
          { value: 'doctorate' },
          { value: 'professor' },
        ],
      },
    });
  });

  it('renders organizations as a parent-child tree', async () => {
    resourceMocks.getOrganizations.mockResolvedValue([
      {
        created_at: '2026-06-10T00:00:00.000000Z',
        id: 'child-organization',
        name: 'Child Organization',
        parent_id: 'root-organization',
        tax_identification_number: null,
        type: 'Nhóm',
        updated_at: '2026-06-10T00:00:00.000000Z',
      },
      {
        created_at: '2026-06-10T00:00:00.000000Z',
        id: 'root-organization',
        name: 'Root Organization',
        parent_id: null,
        tax_identification_number: null,
        type: 'Công ty',
        updated_at: '2026-06-10T00:00:00.000000Z',
      },
    ]);

    const { createBasicFormSchema, loadOptions } = useUserFormSchema();
    await loadOptions();

    expect(
      createBasicFormSchema.value.find(
        (field) => field.fieldName === 'organization_id',
      ),
    ).toMatchObject({
      component: 'TreeSelect',
      componentProps: {
        treeData: [
          {
            children: [
              {
                children: [],
                label: 'Child Organization',
                value: 'child-organization',
              },
            ],
            label: 'Root Organization',
            value: 'root-organization',
          },
        ],
        treeDefaultExpandAll: true,
        treeNodeFilterProp: 'label',
      },
    });
  });
});

describe('buildUserDetail', () => {
  it('keeps status in basic information and shows missing profile values consistently', () => {
    const detail = buildUserDetail(createUser({ email: null, profile: null }));
    const basic = detail.sections.find((section) => section.key === 'basic');
    const additional = detail.sections.find(
      (section) => section.key === 'additional',
    );

    expect(basic?.rows).toContainEqual(
      expect.objectContaining({
        key: 'status',
        value: 'users.status.active',
      }),
    );
    expect(additional?.rows).not.toContainEqual(
      expect.objectContaining({ key: 'status' }),
    );
    expect(
      buildUserDetail(createUser({ deleted_at: '2026-01-01T00:00:00.000000Z' }))
        .sections[0]?.rows,
    ).toContainEqual(
      expect.objectContaining({
        key: 'status',
        value: 'users.status.deleted',
      }),
    );
    expect(basic?.rows).toContainEqual(
      expect.objectContaining({
        key: 'code',
        value: null,
      }),
    );
    expect(additional?.rows).toContainEqual(
      expect.objectContaining({
        key: 'email',
        value: null,
      }),
    );
  });

  it('shows the direct organization and roles as readable text', () => {
    const user = createUser();
    const organization = user.organization;
    const role = user.roles[0];
    if (organization === null || role === undefined) {
      throw new TypeError('User fixture requires an organization and a role.');
    }
    const detail = buildUserDetail({
      ...user,
      organization: { ...organization, name: 'Finance' },
      roles: [role, { ...role, id: 'role-2', name: 'editor' }],
    });
    const basic = detail.sections.find((section) => section.key === 'basic');

    expect(basic?.rows).toContainEqual(
      expect.objectContaining({
        key: 'organization',
        value: 'Finance',
      }),
    );
    expect(basic?.rows).toContainEqual(
      expect.objectContaining({
        key: 'role_names',
        value: 'admin, editor',
      }),
    );
  });

  it('localizes the education level stored in the profile', () => {
    const user = createUser();

    if (user.profile === null) {
      throw new TypeError('User profile is required.');
    }

    const detail = buildUserDetail({
      ...user,
      profile: {
        ...user.profile,
        education_level: 'university',
      },
    });
    const additional = detail.sections.find(
      (section) => section.key === 'additional',
    );

    expect(additional?.rows).toContainEqual(
      expect.objectContaining({
        key: 'education_level',
        value: 'users.educationLevels.university',
      }),
    );
  });

  it('shows tax identification and bank account values from the profile contract', () => {
    const detail = buildUserDetail(createUser());
    const additional = detail.sections.find(
      (section) => section.key === 'additional',
    );

    expect(additional?.rows.at(-1)?.key).toBe('address');
    expect(additional?.rows).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          key: 'personal_tax_identification_number',
          value: 'PIT-001',
        }),
        expect.objectContaining({
          key: 'dependent_tax_identification_number',
          value: 'DPT-001',
        }),
        expect.objectContaining({
          key: 'bank_account_number',
          value: '0123456789',
        }),
        expect.objectContaining({
          key: 'address',
          span: 'full',
          value: '123 Main St',
        }),
      ]),
    );
  });
});
