import type { RouteRecordRaw } from 'vue-router';

import { $t } from '#/locales';

const routes: RouteRecordRaw[] = [
  {
    component: () => import('#/views/schedules/index.vue'),
    meta: {
      icon: 'lucide:calendar-days',
      order: 10,
      title: $t('page.schedules.routeTitle'),
    },
    name: 'Schedules',
    path: '/schedules',
  },
];

export default routes;
