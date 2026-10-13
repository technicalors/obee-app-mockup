import { z } from '@vben/common-ui';

import { companySchema } from './company';
import { departmentSchema } from './department';
import { paginationQuerySchema } from './pagination';
import { roleSchema } from './role';
import {
  userProfileEducationLevelSchema,
  userProfileSchema,
} from './user-profile';

export const userSchema = z.object({
  id: z.string(),
  username: z.string().min(3).max(50),
  name: z.string().min(1).max(255),
  email: z.string().email().max(255).nullable(),
  avatar: z.string().nullable(),
  is_active: z.boolean(),
  profile: userProfileSchema.nullable().default(null),
  roles: z.array(roleSchema).default([]),
  email_verified_at: z.string().datetime({ offset: true }).nullable(),
  company: companySchema.nullable(),
  company_id: z.string().nullable(),
  departments: z.array(departmentSchema),
  supabase_id: z.string().nullable(),
  created_at: z.string().datetime({ offset: true }),
  updated_at: z.string().datetime({ offset: true }),
});

export const updateUserProfilePayloadSchema = z
  .object({
    address: z.string().max(255).nullable().optional(),
    birthday: z.string().date().nullable().optional(),
    bank_account_number: z.string().max(255).nullable().optional(),
    citizen_identification_card: z.string().max(255).nullable().optional(),
    code: z.string().min(1).max(36).optional(),
    dependent_tax_identification_number: z
      .string()
      .max(255)
      .nullable()
      .optional(),
    education_level: userProfileEducationLevelSchema.nullable().optional(),
    employee_type: z.string().max(255).nullable().optional(),
    health_insurance_card_number: z.string().max(255).nullable().optional(),
    joined_at: z.string().date().nullable().optional(),
    phone_number: z
      .string()
      .regex(/^\+?\d{8,15}$/)
      .nullable()
      .optional(),
    personal_tax_identification_number: z
      .string()
      .max(255)
      .nullable()
      .optional(),
    position_id: z.string().nullable().optional(),
    sex: z.enum(['female', 'male']).nullable().optional(),
    social_insurance_number: z.string().max(255).nullable().optional(),
    starting_date: z.string().date().nullable().optional(),
  })
  .strict();

export const createUserProfilePayloadSchema = updateUserProfilePayloadSchema
  .extend({
    code: z.string().min(1).max(36),
  })
  .strict();

export const userIndexQuerySchema = paginationQuerySchema.extend({
  with_inactive: z.literal(1).optional(),
  role_names: z.array(z.string()).optional(),
  search: z.string().optional(),
});

export const createUserPayloadSchema = userSchema
  .pick({
    email: true,
    name: true,
    username: true,
  })
  .extend({
    department_id: z.string().nullable().optional(),
    password: z.string().min(6).max(255),
    profile: createUserProfilePayloadSchema.optional(),
    role_names: z.array(z.string()).optional(),
  })
  .strict();

export const updateUserPayloadSchema = userSchema
  .pick({
    email: true,
    name: true,
    username: true,
    is_active: true,
  })
  .extend({
    department_id: z.string().nullable().optional(),
    profile: updateUserProfilePayloadSchema.optional(),
    role_names: z.array(z.string()).optional(),
  })
  .strict();

export const resetUserPasswordPayloadSchema = z
  .object({
    password: z.string().min(6).max(255),
    password_confirmation: z.string().min(6).max(255),
  })
  .strict()
  .refine((value) => value.password === value.password_confirmation, {
    path: ['password_confirmation'],
  });

export const authUserSchema = userSchema.extend({
  permissions: z.array(z.string()),
});

export type User = z.infer<typeof userSchema>;
export type AuthUser = z.infer<typeof authUserSchema>;
export type UserIndexQuery = z.input<typeof userIndexQuerySchema>;
export type CreateUserProfilePayload = z.input<
  typeof createUserProfilePayloadSchema
>;
export type CreateUserPayload = z.input<typeof createUserPayloadSchema>;
export type UpdateUserPayload = z.input<typeof updateUserPayloadSchema>;
export type ResetUserPasswordPayload = z.input<
  typeof resetUserPasswordPayloadSchema
>;
