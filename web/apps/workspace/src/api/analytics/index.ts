import type { AnalyticsOverview } from '../contracts';

import { requestClient } from '#/api/request';

import { analyticsOverviewSchema } from '../contracts';

export async function getAnalyticsOverview(): Promise<AnalyticsOverview> {
  const payload = await requestClient.get<unknown>('/analytics/overview');

  return analyticsOverviewSchema.parse(payload);
}
