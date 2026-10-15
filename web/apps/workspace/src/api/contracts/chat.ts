import { z } from '@vben/common-ui';

export const matrixCredentialsSchema = z.object({
  access_token: z.string().min(1),
  device_id: z.string().min(1),
  homeserver_url: z.string().url(),
  matrix_user_id: z.string().min(1),
});

export type MatrixCredentials = z.infer<typeof matrixCredentialsSchema>;
