import type { RouteRecordRaw } from 'vue-router';

import { $t } from '#/locales';

const routes: RouteRecordRaw[] = [
  {
    meta: {
      icon: 'lucide:database',
      order: 20,
      title: $t('masterData.routeTitle'),
    },
    name: 'MasterData',
    path: '/master-data',
    children: [
      {
        component: () => import('#/views/organizations/index.vue'),
        meta: {
          authority: ['organizations.viewAny'],
          icon: 'lucide:building-2',
          title: $t('organizations.routeTitle'),
        },
        name: 'MasterDataOrganizations',
        path: 'organizations',
      },
      {
        component: () => import('#/views/organizations/tree.vue'),
        meta: {
          authority: ['organizations.viewAny'],
          hideInMenu: true,
          title: $t('organizations.tree.title'),
        },
        name: 'MasterDataOrganizationTree',
        path: 'organizations/tree',
      },
      {
        component: () => import('#/views/users/index.vue'),
        meta: {
          authority: ['users.viewAny'],
          icon: 'lucide:users',
          title: $t('users.routeTitle'),
        },
        name: 'MasterDataUsers',
        path: 'users',
      },
      {
        component: () => import('#/views/positions/index.vue'),
        meta: {
          authority: ['positions.viewAny'],
          icon: 'lucide:briefcase-business',
          title: $t('positions.routeTitle'),
        },
        name: 'MasterDataPositions',
        path: 'positions',
      },
      {
        component: () => import('#/views/roles/index.vue'),
        meta: {
          authority: ['roles.viewAny'],
          icon: 'lucide:shield-check',
          title: $t('roles.routeTitle'),
        },
        name: 'MasterDataRoles',
        path: 'roles',
      },
      {
        component: () => import('#/views/facility-resources/index.vue'),
        meta: {
          authority: ['facility-resources.viewAny'],
          icon: 'lucide:package',
          title: $t('facilityResource.routeTitle'),
        },
        name: 'MasterDataFacilityResource',
        path: 'facility-resources',
      },
      {
        component: () => import('#/views/attendance-locations/index.vue'),
        meta: {
          authority: ['attendance-locations.viewAny'],
          icon: 'lucide:map-pin',
          title: $t('attendanceLocations.routeTitle'),
        },
        name: 'MasterDataAttendanceLocations',
        path: 'attendance-locations',
      },
      {
        component: () => import('#/views/attendance-locations/create.vue'),
        meta: {
          authority: ['attendance-locations.create'],
          hideInMenu: true,
          title: $t('attendanceLocations.create.title'),
        },
        name: 'MasterDataAttendanceLocationsCreate',
        path: 'attendance-locations/create',
      },
      {
        component: () => import('#/views/attendance-locations/edit.vue'),
        meta: {
          authority: ['attendance-locations.update'],
          hideInMenu: true,
          title: $t('attendanceLocations.edit.title'),
        },
        name: 'MasterDataAttendanceLocationsEdit',
        path: 'attendance-locations/:id/edit',
      },
      {
        component: () => import('#/views/attendance-locations/view.vue'),
        meta: {
          authority: ['attendance-locations.viewAny'],
          hideInMenu: true,
          title: $t('attendanceLocations.detail.title'),
        },
        name: 'MasterDataAttendanceLocationsView',
        path: 'attendance-locations/:id',
      },
    ],
  },
];

export default routes;
