import { z } from '@vben/common-ui';

export const loginPayloadSchema = z.object({
  email: z.string().min(1).max(255),
  password: z.string().min(1).max(255),
});

export type LoginPayload = z.input<typeof loginPayloadSchema>;
