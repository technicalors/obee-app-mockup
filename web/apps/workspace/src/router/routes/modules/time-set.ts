import type { RouteRecordRaw } from 'vue-router';

import { $t } from '#/locales';

const routes: RouteRecordRaw[] = [
  {
    children: [
      {
        component: () => import('#/views/schedules/index.vue'),
        meta: {
          fullPathKey: false,
          icon: 'lucide:calendar-days',
          title: $t('schedules.routeTitle'),
        },
        name: 'Schedules',
        path: '/schedules',
      },
      {
        component: () => import('#/views/attendance/index.vue'),
        meta: {
          icon: 'lucide:fingerprint',
          title: $t('attendance.routeTitle'),
        },
        name: 'Attendance',
        path: '/attendance',
      },
      {
        component: () => import('#/views/work-user-shifts/index.vue'),
        meta: {
          authority: ['work-user-shifts.viewAny'],
          icon: 'lucide:calendar-range',
          title: $t('workUserShifts.routeTitle'),
        },
        name: 'EmployeeRecordWorkUserShifts',
        path: '/employee-records/work-user-shifts',
      },
      {
        component: () => import('#/views/absence-requests/index.vue'),
        meta: {
          icon: 'lucide:clipboard-check',
          title: $t('absenceRequests.routeTitle'),
        },
        name: 'EmployeeRecordAbsenceRequests',
        path: '/employee-records/absence-requests',
      },
    ],
    meta: {
      icon: 'lucide:clock-3',
      order: 10,
      title: $t('timeSet.routeTitle'),
    },
    name: 'TimeSet',
    path: '/time-set',
  },
];

export default routes;
