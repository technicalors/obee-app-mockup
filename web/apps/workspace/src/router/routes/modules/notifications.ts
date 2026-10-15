import type { RouteRecordRaw } from 'vue-router';

import { $t } from '#/locales';

const routes: RouteRecordRaw[] = [
  {
    component: () => import('#/views/notifications/index.vue'),
    meta: {
      icon: 'lucide:bell',
      hideInMenu: true,
      title: $t('notifications.routeTitle'),
    },
    name: 'Notifications',
    path: '/notifications',
  },
];

export default routes;
