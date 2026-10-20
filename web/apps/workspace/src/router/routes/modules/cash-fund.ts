import type { RouteRecordRaw } from 'vue-router';

import { $t } from '#/locales';

const routes: RouteRecordRaw[] = [
  {
    children: [
      {
        component: () => import('#/views/cash-fund/proposals/index.vue'),
        meta: {
          icon: 'lucide:file-text',
          title: $t('cashFund.proposals.title'),
        },
        name: 'CashFundProposals',
        path: 'proposals',
      },
      {
        component: () => import('#/views/cash-fund/approvals/index.vue'),
        meta: {
          icon: 'lucide:check-square',
          title: $t('cashFund.approvals.title'),
        },
        name: 'CashFundApprovals',
        path: 'approvals',
      },
      {
        component: () => import('#/views/cash-fund/transactions/index.vue'),
        meta: {
          icon: 'lucide:receipt',
          title: $t('cashFund.transactions.title'),
        },
        name: 'CashFundTransactions',
        path: 'transactions',
      },
      {
        component: () => import('#/views/cash-fund/adjustments/index.vue'),
        meta: {
          icon: 'lucide:arrow-left-right',
          title: $t('cashFund.adjustments.title'),
        },
        name: 'CashFundAdjustments',
        path: 'adjustments',
      },
      {
        component: () => import('#/views/cash-fund/reports/index.vue'),
        meta: {
          icon: 'lucide:bar-chart-3',
          title: $t('cashFund.reports.title'),
        },
        name: 'CashFundReports',
        path: 'reports',
      },
    ],
    meta: {
      icon: 'lucide:wallet',
      order: 15,
      title: $t('cashFund.routeTitle'),
    },
    name: 'CashFund',
    path: '/cash-fund',
  },
];

export default routes;
