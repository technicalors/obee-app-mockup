import { z } from '@vben/common-ui';

import { positionSchema } from './position';

export const userProfileEducationLevelSchema = z.enum([
  'unskilled_labor',
  'intermediate',
  'college',
  'university',
  'master',
  'doctorate',
  'professor',
]);

export const userProfileSchema = z.object({
  age: z.number().nullable(),
  address: z.string().nullable(),
  birthday: z.string().date().nullable(),
  citizen_identification_card: z.string().nullable(),
  dependent_tax_identification_number: z.string().nullable(),
  code: z.string().min(1).max(36),
  created_at: z.string().datetime({ offset: true }).nullable(),
  education_level: userProfileEducationLevelSchema.nullable(),
  employee_type: z.string().nullable(),
  health_insurance_card_number: z.string().nullable(),
  joined_at: z.string().date().nullable(),
  bank_account_number: z.string().nullable(),
  personal_tax_identification_number: z.string().nullable(),
  phone_number: z
    .string()
    .regex(/^\+?\d{8,15}$/)
    .nullable(),
  position: positionSchema.nullable(),
  position_id: z.string().nullable(),
  seniority: z.number().nullable(),
  sex: z.enum(['female', 'male']).nullable(),
  social_insurance_number: z.string().nullable(),
  starting_date: z.string().date().nullable(),
  updated_at: z.string().datetime({ offset: true }).nullable(),
});

export type UserProfile = z.infer<typeof userProfileSchema>;
