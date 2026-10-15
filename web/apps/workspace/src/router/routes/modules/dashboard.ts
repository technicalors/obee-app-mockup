import type { RouteRecordRaw } from 'vue-router';

import { $t } from '#/locales';

const hiddenRedirect = {
  hideInBreadcrumb: true,
  hideInMenu: true,
  hideInTab: true,
  title: $t('dashboard.title'),
} as const;

const routes: RouteRecordRaw[] = [
  {
    name: 'Overview',
    path: '/overview',
    component: () => import('#/views/dashboard/analytics/index.vue'),
    meta: {
      affixTab: true,
      icon: 'lucide:layout-dashboard',
      order: -1,
      title: $t('dashboard.title'),
    },
  },
  {
    name: 'LegacyDashboardRedirect',
    path: '/dashboard',
    redirect: '/overview',
    meta: hiddenRedirect,
  },
  {
    name: 'LegacyAnalyticsRedirect',
    path: '/analytics',
    redirect: '/overview',
    meta: hiddenRedirect,
  },
  {
    name: 'LegacyWorkspaceRedirect',
    path: '/workspace',
    redirect: '/overview',
    meta: hiddenRedirect,
  },
];

export default routes;
