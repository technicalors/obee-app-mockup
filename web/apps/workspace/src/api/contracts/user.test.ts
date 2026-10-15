import { describe, expect, it } from 'vitest';

import {
  authUserSchema,
  createUserPayloadSchema,
  updateUserPayloadSchema,
  userIndexQuerySchema,
  userSchema,
} from './user';
import { userProfileSchema } from './user-profile';

describe('user contracts', () => {
  it('requires organization, profile, roles, and organization_id on user responses', () => {
    expect(() =>
      userSchema.parse({
        avatar: null,
        organization_id: null,
        created_at: '2026-06-11T00:00:00.000000Z',
        email: 'admin@example.com',
        email_verified_at: null,
        id: 'user-1',
        deleted_at: null,
        name: 'Admin User',
        supabase_id: null,
        updated_at: '2026-06-11T00:00:00.000000Z',
        username: 'admin',
      }),
    ).toThrow('Required');
  });

  it('requires permissions on auth user responses', () => {
    expect(() =>
      authUserSchema.parse({
        avatar: null,
        organization: null,
        organization_id: null,
        created_at: '2026-06-11T00:00:00.000000Z',
        email: 'admin@example.com',
        email_verified_at: null,
        id: 'user-1',
        deleted_at: null,
        name: 'Admin User',
        profile: null,
        roles: [],
        supabase_id: null,
        updated_at: '2026-06-11T00:00:00.000000Z',
        username: 'admin',
      }),
    ).toThrow('Required');
  });

  it('only accepts create fields for create payloads', () => {
    expect(
      createUserPayloadSchema.parse({
        email: 'admin@example.com',
        name: 'Admin User',
        password: 'secret123',
        username: 'admin',
      }),
    ).toMatchObject({
      email: 'admin@example.com',
      name: 'Admin User',
      username: 'admin',
    });

    expect(() =>
      createUserPayloadSchema.parse({
        avatar: null,
        email: 'admin@example.com',
        name: 'Admin User',
        password: 'secret123',
        username: 'admin',
      }),
    ).toThrow('Unrecognized key');
  });

  it('rejects an active status when creating a user', () => {
    expect(() =>
      createUserPayloadSchema.parse({
        email: null,
        is_active: false,
        name: 'Inactive User',
        password: 'secret123',
        username: 'inactive-user',
      }),
    ).toThrow('Unrecognized key');
  });

  it('requires deleted_at on user responses', () => {
    const user = {
      avatar: null,
      created_at: '2026-06-11T00:00:00.000000Z',
      email: 'admin@example.com',
      email_verified_at: null,
      id: 'user-1',
      name: 'Admin User',
      organization: null,
      organization_id: null,
      profile: null,
      roles: [],
      supabase_id: null,
      updated_at: '2026-06-11T00:00:00.000000Z',
      username: 'admin',
    };

    expect(() => userSchema.parse(user)).toThrow('Required');
    expect(
      userSchema.parse({ ...user, deleted_at: '2026-06-12T00:00:00.000000Z' })
        .deleted_at,
    ).toBe('2026-06-12T00:00:00.000000Z');
  });

  it('limits usernames to the users table length', () => {
    const username = 'a'.repeat(50);

    expect(
      createUserPayloadSchema.parse({
        email: null,
        name: 'Length User',
        password: 'secret123',
        username,
      }).username,
    ).toBe(username);

    expect(() =>
      createUserPayloadSchema.parse({
        email: null,
        name: 'Length User',
        password: 'secret123',
        username: 'ab',
      }),
    ).toThrow('at least 3');

    expect(() =>
      createUserPayloadSchema.parse({
        email: null,
        name: 'Length User',
        password: 'secret123',
        username: `${username}a`,
      }),
    ).toThrow('at most 50');
  });

  it('accepts nullable legacy emails and only supported genders', () => {
    expect(
      createUserPayloadSchema.parse({
        email: null,
        name: 'Legacy User',
        password: 'secret123',
        profile: {
          code: 'legacy.user',
          sex: 'female',
        },
        username: 'legacy.user',
      }),
    ).toMatchObject({
      email: null,
      profile: {
        sex: 'female',
      },
    });

    expect(() =>
      createUserPayloadSchema.parse({
        email: null,
        name: 'Legacy User',
        password: 'secret123',
        profile: {
          code: 'legacy.user',
          sex: 'other',
        },
        username: 'legacy.user',
      }),
    ).toThrow('Invalid');
  });

  it('accepts nested update fields and rejects legacy flat fields', () => {
    expect(
      updateUserPayloadSchema.parse({
        email: 'admin@example.com',
        name: 'Admin User',
        profile: {
          address: '123 Main St',
          bank_account_number: '0123456789',
          birthday: '1995-05-20',
          dependent_tax_identification_number: 'DPT-001',
          phone_number: '+84987654321',
          personal_tax_identification_number: 'PIT-001',
          sex: 'male',
        },
        role_names: ['admin'],
        username: 'admin',
      }),
    ).toMatchObject({
      role_names: ['admin'],
    });

    expect(() =>
      updateUserPayloadSchema.parse({
        email: 'admin@example.com',
        name: 'Admin User',
        phone_number: '+84987654321',
        role_names: ['admin'],
        username: 'admin',
      }),
    ).toThrow('Unrecognized key');
  });

  it('rejects avatar updates in update payloads', () => {
    expect(() =>
      updateUserPayloadSchema.parse({
        avatar: null,
        email: 'admin@example.com',
        name: 'Admin User',
        username: 'admin',
      }),
    ).toThrow('Unrecognized key');
  });

  it('extends the pagination query base for user index queries', () => {
    expect(
      userIndexQuerySchema.parse({
        trashed: 'with',
        page: 2,
        per_page: 20,
        organization_id: 'organization-1',
        root_organization_id: 'root-organization-1',
        role_names: ['admin'],
        search: 'alice',
      }),
    ).toEqual({
      trashed: 'with',
      page: 2,
      per_page: 20,
      organization_id: 'organization-1',
      root_organization_id: 'root-organization-1',
      role_names: ['admin'],
      search: 'alice',
    });
  });

  it('rejects unknown trashed filters on user index queries', () => {
    expect(
      userIndexQuerySchema.safeParse({
        trashed: 'all',
        page: 1,
        per_page: 10,
      }).success,
    ).toBe(false);
  });

  it('rejects malformed datetime values on user responses', () => {
    expect(() =>
      userSchema.parse({
        avatar: null,
        organization: null,
        organization_id: null,
        created_at: '2026-06-11',
        email: 'admin@example.com',
        email_verified_at: null,
        id: 'user-1',
        deleted_at: null,
        name: 'Admin User',
        profile: null,
        roles: [],
        supabase_id: null,
        updated_at: '2026-06-11T00:00:00.000000Z',
        username: 'admin',
      }),
    ).toThrow('Invalid');
  });

  it('rejects invalid nested profile field formats in update payloads', () => {
    expect(() =>
      updateUserPayloadSchema.parse({
        email: 'admin@example.com',
        name: 'Admin User',
        profile: {
          address: '123 Main St',
          birthday: '20-05-1995',
          education_level: 'bachelor',
          phone_number: '0987',
          sex: 'invalid',
        },
        role_names: ['admin'],
        username: 'admin',
      }),
    ).toThrow('Invalid');
  });

  it('requires tax and bank account fields on profile responses', () => {
    expect(
      userProfileSchema.parse({
        address: null,
        age: null,
        bank_account_number: '0123456789',
        birthday: null,
        citizen_identification_card: null,
        code: 'EMP-001',
        created_at: '2026-06-11T00:00:00.000000Z',
        dependent_tax_identification_number: 'DPT-001',
        education_level: null,
        employee_type: null,
        health_insurance_card_number: null,
        joined_at: null,
        personal_tax_identification_number: 'PIT-001',
        phone_number: null,
        position: null,
        position_id: null,
        seniority: null,
        sex: null,
        social_insurance_number: null,
        starting_date: null,
        updated_at: '2026-06-11T00:00:00.000000Z',
      }),
    ).toMatchObject({
      bank_account_number: '0123456789',
      dependent_tax_identification_number: 'DPT-001',
      personal_tax_identification_number: 'PIT-001',
    });
  });
});
