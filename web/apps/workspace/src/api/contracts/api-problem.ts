import { z } from '@vben/common-ui';

export const apiProblemSchema = z.object({
  detail: z.string(),
  instance: z.string().optional(),
  status: z.number(),
  title: z.string(),
  type: z.string(),
});

export type ApiProblem = z.infer<typeof apiProblemSchema>;
