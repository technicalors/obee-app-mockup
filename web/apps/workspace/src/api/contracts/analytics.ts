import { z } from '@vben/common-ui';

export const analyticsOverviewSchema = z.object({
  date: z.string(),
  employee_count: z.number().int(),
  checked_in_count: z.number().int(),
  not_checked_in_count: z.number().int(),
  leave_request_count: z.number().int(),
});

export type AnalyticsOverview = z.infer<typeof analyticsOverviewSchema>;
