import { z } from '@vben/common-ui';

export const companySchema = z.object({
  created_at: z.string(),
  id: z.string(),
  name: z.string(),
  tax_identification_number: z.string().nullable(),
  updated_at: z.string(),
});

export type Company = z.infer<typeof companySchema>;
