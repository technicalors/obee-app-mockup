import { z } from '@vben/common-ui';

import {
  organizationHierarchySchema,
  organizationSchema,
} from './organization';
import { paginationQuerySchema } from './pagination';
import { permissionSchema } from './permission';
import { roleSchema } from './role';
import { trashedFilterSchema } from './trashed';
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
  profile: userProfileSchema.nullable().default(null),
  roles: z.array(roleSchema).default([]),
  email_verified_at: z.string().datetime({ offset: true }).nullable(),
  organization: organizationSchema.nullable(),
  organization_id: z.string().nullable(),
  supabase_id: z.string().nullable(),
  matrix_user_id: z.string().nullable().optional(),
  created_at: z.string().datetime({ offset: true }),
  updated_at: z.string().datetime({ offset: true }),
  deleted_at: z.string().datetime({ offset: true }).nullable(),
});

export const userTreeSelectionUserSchema = userSchema
  .pick({ id: true, name: true, username: true, deleted_at: true })
  .extend({
    organization: organizationHierarchySchema,
    organization_id: z.string(),
    profile: userProfileSchema.pick({ code: true }).nullable(),
  });

export type UserTreeSelectionUser = z.infer<typeof userTreeSelectionUserSchema>;

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
  trashed: trashedFilterSchema.optional(),
  organization_id: z.string().optional(),
  root_organization_id: z.string().optional(),
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
    organization_id: z.string().nullable().optional(),
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
  })
  .extend({
    organization_id: z.string().nullable().optional(),
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
  permissions: z.array(permissionSchema),
  root_organization_id: z.string().nullable(),
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
