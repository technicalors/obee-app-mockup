import type { UserProfileFormValues } from './form';

import type { User } from '#/api';

import dayjs from 'dayjs';
import { beforeEach, describe, expect, it, vi } from 'vitest';

import {
  buildUserCreatePayload,
  buildUserDetail,
  buildUserPasswordResetPayload,
  buildUserUpdatePayload,
  mergeUserFormValues,
  toUserFormValues,
  useUserFormSchema,
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
  getDepartments: vi.fn().mockResolvedValue([]),
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
  departmentOptionsResource: {
    getAll: resourceMocks.getDepartments,
  },
  positionOptionsResource: {
    getAll: resourceMocks.getPositions,
  },
}));

function createUser(overrides: Partial<User> = {}): User {
  return {
    avatar: null,
    company: {
      created_at: '2026-06-10T00:00:00.000000Z',
      id: 'company-1',
      name: 'Obee',
      tax_identification_number: 'TAX-001',
      updated_at: '2026-06-10T00:00:00.000000Z',
    },
    company_id: 'company-1',
    created_at: '2026-06-11T00:00:00.000000Z',
    departments: [
      {
        children: [],
        company: null,
        company_id: 'company-1',
        created_at: '2026-06-10T00:00:00.000000Z',
        id: 'department-1',
        name: 'Operations',
        parent: null,
        parent_id: null,
        updated_at: '2026-06-10T00:00:00.000000Z',
      },
    ],
    email: 'admin@example.com',
    email_verified_at: null,
    id: 'user-1',
    is_active: true,
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
  resourceMocks.getDepartments.mockReset().mockResolvedValue([]);
  resourceMocks.getPositions.mockReset().mockResolvedValue([]);
});

describe('toUserFormValues', () => {
  it('maps profile, department, and position fields from the user contract', () => {
    const values = toUserFormValues(createUser());

    expect(values).toMatchObject({
      department_id: 'department-1',
      email: 'admin@example.com',
      is_active: true,
      name: 'Admin User',
      profile: {
        code: 'EMP-001',
        position_id: 'position-1',
      },
      role_names: ['admin'],
    });
    const birthday = values.profile?.birthday;
    expect(dayjs.isDayjs(birthday)).toBe(true);
    if (!dayjs.isDayjs(birthday)) {
      throw new TypeError('Birthday must be a Dayjs value.');
    }

    expect(birthday.format('YYYY-MM-DD')).toBe('1995-05-20');
  });

  it('initializes a missing profile for an edit payload', () => {
    const values = toUserFormValues(createUser({ profile: null }));

    expect(values.profile).toEqual({
      address: null,
      bank_account_number: null,
      birthday: null,
      citizen_identification_card: null,
      code: '',
      dependent_tax_identification_number: null,
      education_level: null,
      health_insurance_card_number: null,
      joined_at: null,
      phone_number: null,
      personal_tax_identification_number: null,
      position_id: null,
      sex: null,
      social_insurance_number: null,
      starting_date: null,
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

  it('builds a create payload with the selected department, position, and roles', () => {
    expect(
      buildUserCreatePayload(
        {
          department_id: 'department-1',
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
      department_id: 'department-1',
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
        is_active: true,
        name: 'Admin User',
        profile,
        role_names: ['admin'],
        username: 'admin',
      },
      false,
    );

    expect(payload).toMatchObject({
      is_active: true,
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
  it('splits create fields into basic and additional tabs without a company input', () => {
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
    expect(basicFields).not.toContain('__company');
    expect(additionalFields).toContain('profile.starting_date');
    expect(additionalFields.at(-1)).toBe('profile.address');
    expect(additionalFields).not.toContain('is_active');
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

  it('keeps the active status in the edit basic form and accepts an empty phone number', () => {
    const { editAdditionalFormSchema, editBasicFormSchema } =
      useUserFormSchema();
    const statusField = editBasicFormSchema.value.find(
      (field) => field.fieldName === 'is_active',
    );
    const phoneField = editAdditionalFormSchema.value.find(
      (field) => field.fieldName === 'profile.phone_number',
    );
    const phoneRule = phoneField?.rules;

    expect(statusField).toMatchObject({
      component: 'Switch',
      defaultValue: true,
    });
    expect(
      editAdditionalFormSchema.value.map((field) => field.fieldName),
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

  it('renders departments as a parent-child tree', async () => {
    resourceMocks.getDepartments.mockResolvedValue([
      {
        children: [],
        company: null,
        company_id: 'company-1',
        created_at: null,
        id: 'child-department',
        name: 'Child Department',
        parent: null,
        parent_id: 'root-department',
        updated_at: null,
      },
      {
        children: [],
        company: null,
        company_id: 'company-1',
        created_at: null,
        id: 'root-department',
        name: 'Root Department',
        parent: null,
        parent_id: null,
        updated_at: null,
      },
    ]);

    const { createBasicFormSchema, loadOptions } = useUserFormSchema();
    await loadOptions();

    expect(
      createBasicFormSchema.value.find(
        (field) => field.fieldName === 'department_id',
      ),
    ).toMatchObject({
      component: 'TreeSelect',
      componentProps: {
        treeData: [
          {
            children: [
              {
                children: [],
                label: 'Child Department',
                value: 'child-department',
              },
            ],
            label: 'Root Department',
            value: 'root-department',
          },
        ],
        treeDefaultExpandAll: true,
        treeNodeFilterProp: 'label',
      },
    });
  });
});

describe('buildUserDetail', () => {
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
        value: 'page.users.educationLevels.university',
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
