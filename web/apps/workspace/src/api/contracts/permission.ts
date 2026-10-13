import { z } from '@vben/common-ui';

export const permissionSchema = z.object({
  created_at: z.string().nullable(),
  description: z.string().nullable(),
  id: z.string(),
  name: z.string(),
  updated_at: z.string().nullable(),
});

export type Permission = z.infer<typeof permissionSchema>;
