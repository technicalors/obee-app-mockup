import { z } from '@vben/common-ui';

import { paginationQuerySchema } from './pagination';

export const organizationTypeSchema = z.string().min(1).max(255);

export const organizationSchema = z.object({
  created_at: z.string().datetime({ offset: true }),
  id: z.string(),
  name: z.string(),
  parent_id: z.string().nullable(),
  tax_identification_number: z.string().max(14).nullable(),
  type: organizationTypeSchema,
  updated_at: z.string().datetime({ offset: true }),
});

export interface OrganizationHierarchy extends Omit<
  z.infer<typeof organizationSchema>,
  'parent'
> {
  parent: null | OrganizationHierarchy;
}

export const organizationHierarchySchema: z.ZodType<OrganizationHierarchy> =
  z.lazy(() =>
    organizationSchema.extend({
      parent: organizationHierarchySchema.nullable(),
    }),
  );

const organizationPayloadSchema = z.object({
  name: z.string().min(1).max(255),
  parent_id: z.string().nullable(),
  tax_identification_number: z.string().max(14).nullable(),
  type: organizationTypeSchema,
});

type OrganizationPayload = z.infer<typeof organizationPayloadSchema>;

function addOrganizationParentRules(
  values: Partial<OrganizationPayload>,
  context: z.RefinementCtx,
): void {
  if (values.parent_id === undefined) {
    return;
  }

  if (
    values.type !== undefined &&
    ((values.parent_id === null && values.type !== 'Công ty') ||
      (values.parent_id !== null && values.type === 'Công ty'))
  ) {
    context.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'Organization type does not match its parent.',
      path: ['type'],
    });
  }

  if (
    values.parent_id !== null &&
    values.tax_identification_number !== undefined &&
    values.tax_identification_number !== null
  ) {
    context.addIssue({
      code: z.ZodIssueCode.custom,
      message:
        'Tax identification numbers are only allowed on root organizations.',
      path: ['tax_identification_number'],
    });
  }
}

export const createOrganizationPayloadSchema = organizationPayloadSchema
  .strict()
  .superRefine(addOrganizationParentRules);

export const updateOrganizationPayloadSchema = organizationPayloadSchema
  .partial()
  .strict()
  .superRefine(addOrganizationParentRules);

export const organizationIndexQuerySchema = paginationQuerySchema.extend({
  parent_id: z.string().nullable().optional(),
  search: z.string().optional(),
  type: z.string().min(1).max(255).optional(),
});

export type CreateOrganizationPayload = z.input<
  typeof createOrganizationPayloadSchema
>;
export type Organization = z.infer<typeof organizationSchema>;
export type OrganizationType = z.infer<typeof organizationTypeSchema>;
export type OrganizationIndexQuery = z.input<
  typeof organizationIndexQuerySchema
>;
export type UpdateOrganizationPayload = z.input<
  typeof updateOrganizationPayloadSchema
>;
