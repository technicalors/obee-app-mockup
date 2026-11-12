import type { RouteRecordRaw } from 'vue-router';

import { $t } from '#/locales';

const routes: RouteRecordRaw[] = [
  {
    children: [
      {
        component: () => import('#/views/purchasing/requests/index.vue'),
        meta: {
          icon: 'lucide:clipboard-list',
          title: $t('purchasing.menu.requests'),
        },
        name: 'PurchasingRequests',
        path: 'requests',
      },
      {
        component: () => import('#/views/purchasing/approvals/index.vue'),
        meta: {
          icon: 'lucide:check-square',
          title: $t('purchasing.menu.approvals'),
        },
        name: 'PurchasingApprovals',
        path: 'approvals',
      },
      {
        component: () => import('#/views/purchasing/orders/index.vue'),
        meta: {
          icon: 'lucide:file-box',
          title: $t('purchasing.menu.orders'),
        },
        name: 'PurchasingOrders',
        path: 'orders',
      },
      {
        component: () => import('#/views/purchasing/reports/index.vue'),
        meta: {
          icon: 'lucide:chart-no-axes-combined',
          title: $t('purchasing.menu.reports'),
        },
        name: 'PurchasingReports',
        path: 'reports',
      },
    ],
    meta: {
      icon: 'lucide:shopping-cart',
      order: 16,
      title: $t('purchasing.routeTitle'),
    },
    name: 'Purchasing',
    path: '/purchasing',
  },
];

export default routes;
