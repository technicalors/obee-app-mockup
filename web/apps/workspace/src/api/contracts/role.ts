import { z } from '@vben/common-ui';

import { permissionSchema } from './permission';

export const roleSchema = z.object({
  created_at: z.string().nullable(),
  description: z.string().nullable(),
  id: z.string(),
  name: z.string(),
  updated_at: z.string().nullable(),
});

export const roleWithPermissionsSchema = roleSchema.extend({
  permissions: z.array(permissionSchema),
});

export const createRolePayloadSchema = roleSchema
  .pick({ name: true })
  .extend({
    description: z.string().nullable().optional(),
    permission_ids: z.array(z.string().uuid()).optional(),
  })
  .strict();

export const updateRolePayloadSchema = createRolePayloadSchema
  .partial()
  .strict()
  .refine((value) => Object.keys(value).length > 0);

export type Role = z.infer<typeof roleWithPermissionsSchema>;
export type CreateRolePayload = z.input<typeof createRolePayloadSchema>;
export type UpdateRolePayload = z.input<typeof updateRolePayloadSchema>;
