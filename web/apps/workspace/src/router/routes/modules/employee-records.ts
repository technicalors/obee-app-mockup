import type { RouteRecordRaw } from 'vue-router';

import { $t } from '#/locales';

const routes: RouteRecordRaw[] = [
  {
    children: [
      {
        component: () => import('#/views/employee-records/history/index.vue'),
        meta: {
          icon: 'lucide:history',
          title: $t('employeeRecord.history.routeTitle'),
        },
        name: 'EmployeeRecordHistory',
        path: 'history',
      },
      {
        component: () => import('#/views/employee-records/history/detail.vue'),
        meta: {
          hideInMenu: true,
          title: $t('employeeHistory.pageTitle'),
        },
        name: 'EmployeeRecordHistoryDetail',
        path: 'history/:user',
      },
      {
        component: () =>
          import('#/views/employee-records/evaluation/index.vue'),
        meta: {
          icon: 'lucide:award',
          title: $t('employeeRecord.evaluation.routeTitle'),
        },
        name: 'EmployeeRecordEvaluation',
        path: 'evaluation',
      },
      {
        component: () => import('#/views/employee-records/skills/index.vue'),
        meta: {
          icon: 'lucide:sparkles',
          title: $t('employeeRecord.skills.routeTitle'),
        },
        name: 'EmployeeRecordSkills',
        path: 'skills',
      },
    ],
    meta: {
      icon: 'lucide:id-card',
      order: 18,
      title: $t('employeeRecord.routeTitle'),
    },
    name: 'EmployeeRecord',
    path: '/employee-records',
    redirect: '/employee-records/history',
  },
];

export default routes;
