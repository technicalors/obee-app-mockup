import type { RouteRecordRaw } from 'vue-router';

import { $t } from '#/locales';

const routes: RouteRecordRaw[] = [
  {
    meta: {
      icon: 'lucide:settings',
      order: 30,
      title: $t('system.routeTitle'),
    },
    name: 'System',
    path: '/system',
    children: [
      {
        component: () => import('#/views/system/http-mutation-logs/index.vue'),
        meta: {
          authority: ['http-mutation-logs.viewAny'],
          icon: 'lucide:scroll-text',
          title: $t('mutationLogs.routeTitle'),
        },
        name: 'SystemHttpMutationLogs',
        path: 'http-mutation-logs',
      },
    ],
  },
];

export default routes;
