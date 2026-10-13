import type { RouteRecordRaw } from 'vue-router';

import { $t } from '#/locales';

const routes: RouteRecordRaw[] = [
  {
    component: () => import('#/views/attendance/index.vue'),
    meta: {
      icon: 'lucide:fingerprint',
      order: 15,
      title: $t('page.attendance.routeTitle'),
    },
    name: 'Attendance',
    path: '/attendance',
  },
];

export default routes;
