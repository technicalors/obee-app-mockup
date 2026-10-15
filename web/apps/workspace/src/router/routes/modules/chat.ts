import type { RouteRecordRaw } from 'vue-router';

import { $t } from '#/locales';

const routes: RouteRecordRaw[] = [
  {
    component: () => import('#/views/chat/index.vue'),
    meta: {
      icon: 'lucide:messages-square',
      order: 25,
      title: $t('chat.title'),
    },
    name: 'Chat',
    path: '/chat',
  },
];

export default routes;
