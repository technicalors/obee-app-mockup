import { z } from '@vben/common-ui';

import { companySchema } from './company';
import { paginationQuerySchema } from './pagination';

export interface Department {
  children?: Department[];
  company?: null | z.infer<typeof companySchema>;
  company_id: null | string;
  created_at: null | string;
  id: string;
  name: string;
  parent?: Department | null;
  parent_id: null | string;
  updated_at: null | string;
}

const departmentFields = {
  company: companySchema.nullable().optional(),
  company_id: z.string().nullable(),
  created_at: z.string().nullable(),
  id: z.string(),
  name: z.string(),
  parent_id: z.string().nullable(),
  updated_at: z.string().nullable(),
};

export const departmentSchema: z.ZodType<Department> = z.lazy(() =>
  z.object({
    ...departmentFields,
    children: z.array(departmentSchema).optional(),
    parent: departmentSchema.nullable().optional(),
  }),
);

export const departmentWithRelationsSchema = z.object({
  ...departmentFields,
  children: z.array(departmentSchema).optional(),
  company: companySchema,
  parent: departmentSchema.nullable(),
});

export const createDepartmentPayloadSchema = z
  .object({
    company_id: z.string().nullable(),
    name: z.string(),
    parent_id: z.string().nullable(),
  })
  .partial({ parent_id: true })
  .strict();

export const updateDepartmentPayloadSchema = z
  .object({
    company_id: z.string().nullable(),
    name: z.string(),
    parent_id: z.string().nullable(),
  })
  .partial()
  .strict();

export const departmentIndexQuerySchema = paginationQuerySchema.extend({
  company_id: z.string().nullable().optional(),
  name: z.string().optional(),
  parent_id: z.string().nullable().optional(),
  search: z.string().optional(),
});

export type CreateDepartmentPayload = z.input<
  typeof createDepartmentPayloadSchema
>;
export type DepartmentIndexQuery = z.input<typeof departmentIndexQuerySchema>;
export type DepartmentWithRelations = z.infer<
  typeof departmentWithRelationsSchema
>;
export type UpdateDepartmentPayload = z.input<
  typeof updateDepartmentPayloadSchema
>;
