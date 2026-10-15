import { z } from '@vben/common-ui';

export const trashedFilterSchema = z.enum(['with', 'only']);

export type TrashedFilter = z.infer<typeof trashedFilterSchema>;
