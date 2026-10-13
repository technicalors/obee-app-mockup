import type { RouteRecordRaw } from 'vue-router';

import { $t } from '#/locales';

const routes: RouteRecordRaw[] = [
  {
    meta: {
      icon: 'lucide:database',
      order: 20,
      title: $t('page.masterData.routeTitle'),
    },
    name: 'MasterData',
    path: '/master-data',
    children: [
      {
        component: () => import('#/views/departments/index.vue'),
        meta: {
          authority: ['departments.viewAny'],
          icon: 'lucide:building-2',
          title: $t('page.departments.routeTitle'),
        },
        name: 'MasterDataDepartments',
        path: 'departments',
      },
      {
        component: () => import('#/views/departments/tree.vue'),
        meta: {
          authority: ['departments.viewAny'],
          hideInMenu: true,
          title: $t('page.departments.tree.title'),
        },
        name: 'MasterDataDepartmentTree',
        path: 'departments/tree',
      },
      {
        component: () => import('#/views/users/index.vue'),
        meta: {
          authority: ['users.viewAny'],
          icon: 'lucide:users',
          title: $t('page.users.routeTitle'),
        },
        name: 'MasterDataUsers',
        path: 'users',
      },
      {
        component: () => import('#/views/positions/index.vue'),
        meta: {
          authority: ['positions.viewAny'],
          icon: 'lucide:briefcase-business',
          title: $t('page.positions.routeTitle'),
        },
        name: 'MasterDataPositions',
        path: 'positions',
      },
      {
        component: () => import('#/views/roles/index.vue'),
        meta: {
          authority: ['roles.viewAny'],
          icon: 'lucide:shield-check',
          title: $t('page.roles.routeTitle'),
        },
        name: 'MasterDataRoles',
        path: 'roles',
      },
      {
        component: () => import('#/views/equipments/index.vue'),
        meta: {
          authority: ['equipments.viewAny'],
          icon: 'lucide:package',
          title: $t('page.equipment.routeTitle'),
        },
        name: 'MasterDataEquipment',
        path: 'equipments',
      },
      {
        component: () => import('#/views/attendance-locations/index.vue'),
        meta: {
          authority: ['attendance-locations.viewAny'],
          icon: 'lucide:map-pin',
          title: $t('page.attendanceLocations.routeTitle'),
        },
        name: 'MasterDataAttendanceLocations',
        path: 'attendance-locations',
      },
      {
        component: () => import('#/views/attendance-locations/create.vue'),
        meta: {
          authority: ['attendance-locations.create'],
          hideInMenu: true,
          title: $t('page.attendanceLocations.create.title'),
        },
        name: 'MasterDataAttendanceLocationsCreate',
        path: 'attendance-locations/create',
      },
      {
        component: () => import('#/views/attendance-locations/edit.vue'),
        meta: {
          authority: ['attendance-locations.update'],
          hideInMenu: true,
          title: $t('page.attendanceLocations.edit.title'),
        },
        name: 'MasterDataAttendanceLocationsEdit',
        path: 'attendance-locations/:id/edit',
      },
      {
        component: () => import('#/views/attendance-locations/view.vue'),
        meta: {
          authority: ['attendance-locations.viewAny'],
          hideInMenu: true,
          title: $t('page.attendanceLocations.detail.title'),
        },
        name: 'MasterDataAttendanceLocationsView',
        path: 'attendance-locations/:id',
      },
    ],
  },
];

export default routes;
