<script lang="ts" setup>
import type {
  WorkbenchProjectItem,
  WorkbenchQuickNavItem,
  WorkbenchTodoItem,
  WorkbenchTrendItem,
} from '@vben/common-ui';

import { computed } from 'vue';
import { useRouter } from 'vue-router';

import {
  AnalysisChartCard,
  WorkbenchHeader,
  WorkbenchProject,
  WorkbenchQuickNav,
  WorkbenchTodo,
  WorkbenchTrends,
} from '@vben/common-ui';
import { preferences } from '@vben/preferences';
import { useUserStore } from '@vben/stores';
import { openWindow } from '@vben/utils';

import { $t } from '#/locales';

import AnalyticsVisitsSource from '../analytics/analytics-visits-source.vue';

const userStore = useUserStore();

const projectItems = computed((): WorkbenchProjectItem[] => [
  {
    color: '',
    content: $t('page.dashboard.workspacePage.project1Content'),
    date: '2021-04-01',
    group: $t('page.dashboard.workspacePage.project1Group'),
    icon: 'carbon:logo-github',
    title: 'Github',
    url: 'https://github.com',
  },
  {
    color: '#3fb27f',
    content: $t('page.dashboard.workspacePage.project2Content'),
    date: '2021-04-01',
    group: $t('page.dashboard.workspacePage.project2Group'),
    icon: 'ion:logo-vue',
    title: 'Vue',
    url: 'https://vuejs.org',
  },
  {
    color: '#e18525',
    content: $t('page.dashboard.workspacePage.project3Content'),
    date: '2021-04-01',
    group: $t('page.dashboard.workspacePage.project3Group'),
    icon: 'ion:logo-html5',
    title: 'Html5',
    url: 'https://developer.mozilla.org/zh-CN/docs/Web/HTML',
  },
  {
    color: '#bf0c2c',
    content: $t('page.dashboard.workspacePage.project4Content'),
    date: '2021-04-01',
    group: 'UI',
    icon: 'ion:logo-angular',
    title: 'Angular',
    url: 'https://angular.io',
  },
  {
    color: '#00d8ff',
    content: $t('page.dashboard.workspacePage.project5Content'),
    date: '2021-04-01',
    group: $t('page.dashboard.workspacePage.project5Group'),
    icon: 'bx:bxl-react',
    title: 'React',
    url: 'https://reactjs.org',
  },
  {
    color: '#EBD94E',
    content: $t('page.dashboard.workspacePage.project6Content'),
    date: '2021-04-01',
    group: $t('page.dashboard.workspacePage.project6Group'),
    icon: 'ion:logo-javascript',
    title: 'Js',
    url: 'https://developer.mozilla.org/zh-CN/docs/Web/JavaScript',
  },
]);

const quickNavItems = computed((): WorkbenchQuickNavItem[] => [
  {
    color: '#1fdaca',
    icon: 'ion:home-outline',
    title: $t('page.dashboard.workspacePage.navHome'),
    url: '/',
  },
  {
    color: '#bf0c2c',
    icon: 'ion:grid-outline',
    title: $t('page.dashboard.workspacePage.navDashboard'),
    url: '/dashboard',
  },
  {
    color: '#e18525',
    icon: 'ion:layers-outline',
    title: $t('page.dashboard.workspacePage.navComponents'),
    url: '/demos/features/icons',
  },
  {
    color: '#3fb27f',
    icon: 'ion:settings-outline',
    title: $t('page.dashboard.workspacePage.navSystem'),
    url: '/demos/features/login-expired',
  },
  {
    color: '#4daf1bc9',
    icon: 'ion:key-outline',
    title: $t('page.dashboard.workspacePage.navAccess'),
    url: '/demos/access/page-control',
  },
  {
    color: '#00d8ff',
    icon: 'ion:bar-chart-outline',
    title: $t('page.dashboard.workspacePage.navCharts'),
    url: '/analytics',
  },
]);

const todoItems = computed<WorkbenchTodoItem[]>(() => [
  {
    completed: false,
    content: $t('page.dashboard.workspacePage.todo1Content'),
    date: '2024-07-30 11:00:00',
    title: $t('page.dashboard.workspacePage.todo1Title'),
  },
  {
    completed: true,
    content: $t('page.dashboard.workspacePage.todo2Content'),
    date: '2024-07-30 11:00:00',
    title: $t('page.dashboard.workspacePage.todo2Title'),
  },
  {
    completed: false,
    content: $t('page.dashboard.workspacePage.todo3Content'),
    date: '2024-07-30 11:00:00',
    title: $t('page.dashboard.workspacePage.todo3Title'),
  },
  {
    completed: false,
    content: $t('page.dashboard.workspacePage.todo4Content'),
    date: '2024-07-30 11:00:00',
    title: $t('page.dashboard.workspacePage.todo4Title'),
  },
  {
    completed: false,
    content: $t('page.dashboard.workspacePage.todo5Content'),
    date: '2024-07-30 11:00:00',
    title: $t('page.dashboard.workspacePage.todo5Title'),
  },
]);

const trendItems = computed<WorkbenchTrendItem[]>(() => [
  {
    avatar: 'svg:avatar-1',
    content: $t('page.dashboard.workspacePage.trend1Content'),
    date: $t('page.dashboard.workspacePage.trend1Date'),
    title: $t('page.dashboard.workspacePage.trend1Name'),
  },
  {
    avatar: 'svg:avatar-2',
    content: $t('page.dashboard.workspacePage.trend2Content'),
    date: $t('page.dashboard.workspacePage.trend2Date'),
    title: $t('page.dashboard.workspacePage.trend2Name'),
  },
  {
    avatar: 'svg:avatar-3',
    content: $t('page.dashboard.workspacePage.trend3Content'),
    date: $t('page.dashboard.workspacePage.trend3Date'),
    title: $t('page.dashboard.workspacePage.trend3Name'),
  },
  {
    avatar: 'svg:avatar-4',
    content: $t('page.dashboard.workspacePage.trend4Content'),
    date: $t('page.dashboard.workspacePage.trend4Date'),
    title: 'Vben',
  },
  {
    avatar: 'svg:avatar-1',
    content: $t('page.dashboard.workspacePage.trend5Content'),
    date: $t('page.dashboard.workspacePage.trend5Date'),
    title: $t('page.dashboard.workspacePage.trend5Name'),
  },
  {
    avatar: 'svg:avatar-2',
    content: $t('page.dashboard.workspacePage.trend6Content'),
    date: $t('page.dashboard.workspacePage.trend6Date'),
    title: $t('page.dashboard.workspacePage.trend6Name'),
  },
  {
    avatar: 'svg:avatar-3',
    content: $t('page.dashboard.workspacePage.trend7Content'),
    date: $t('page.dashboard.workspacePage.trend7Date'),
    title: $t('page.dashboard.workspacePage.trend7Name'),
  },
  {
    avatar: 'svg:avatar-4',
    content: $t('page.dashboard.workspacePage.trend8Content'),
    date: $t('page.dashboard.workspacePage.trend8Date'),
    title: $t('page.dashboard.workspacePage.trend8Name'),
  },
  {
    avatar: 'svg:avatar-4',
    content: $t('page.dashboard.workspacePage.trend9Content'),
    date: $t('page.dashboard.workspacePage.trend9Date'),
    title: 'Vben',
  },
]);

const router = useRouter();

function navTo(nav: WorkbenchProjectItem | WorkbenchQuickNavItem) {
  if (nav.url?.startsWith('http')) {
    openWindow(nav.url);
    return;
  }
  if (nav.url?.startsWith('/')) {
    router.push(nav.url).catch((error) => {
      console.error('Navigation failed:', error);
    });
  } else {
    console.warn(`Unknown URL for navigation item: ${nav.title} -> ${nav.url}`);
  }
}
</script>

<template>
  <div class="p-5">
    <WorkbenchHeader
      :avatar="userStore.userInfo?.avatar || preferences.app.defaultAvatar"
    >
      <template #title>
        {{
          $t('page.dashboard.workspacePage.greeting', {
            name: userStore.userInfo?.realName,
          })
        }}
      </template>
      <template #description>
        {{ $t('page.dashboard.workspacePage.weatherDesc') }}
      </template>
    </WorkbenchHeader>

    <div class="flex flex-col lg:flex-row">
      <div class="mr-4 w-full lg:w-3/5">
        <WorkbenchProject
          :items="projectItems"
          :title="$t('page.dashboard.workspacePage.projectSection')"
          @click="navTo"
        />
        <WorkbenchTrends
          :items="trendItems"
          class="mt-5"
          :title="$t('page.dashboard.workspacePage.latestActivity')"
        />
      </div>
      <div class="w-full lg:w-2/5">
        <WorkbenchQuickNav
          :items="quickNavItems"
          class="lg:mt-0"
          :title="$t('page.dashboard.workspacePage.quickNavSection')"
          @click="navTo"
        />
        <WorkbenchTodo
          :items="todoItems"
          class="mt-5"
          :title="$t('page.dashboard.workspacePage.todoSection')"
        />
        <AnalysisChartCard
          class="mt-5"
          :title="$t('page.dashboard.workspacePage.visitSource')"
        >
          <AnalyticsVisitsSource />
        </AnalysisChartCard>
      </div>
    </div>
  </div>
</template>
