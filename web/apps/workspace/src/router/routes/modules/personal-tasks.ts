import type { RouteRecordRaw } from 'vue-router';

import { $t } from '#/locales';

const routes: RouteRecordRaw[] = [
  {
    component: () => import('#/views/personal-tasks/index.vue'),
    meta: {
      icon: 'lucide:list-checks',
      title: $t('personalTasks.routeTitle'),
    },
    name: 'PersonalTasks',
    path: '/personal-tasks',
  },
];

export default routes;
