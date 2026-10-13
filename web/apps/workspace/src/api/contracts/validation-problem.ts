import { z } from '@vben/common-ui';

import { apiProblemSchema } from './api-problem';

export const validationProblemSchema = apiProblemSchema.extend({
  errors: z.record(z.string(), z.array(z.string())),
  status: z.literal(422),
});

export type ValidationProblem = z.infer<typeof validationProblemSchema>;
