<script lang="ts" setup>
import type { EchartsUIType } from '@vben/plugins/echarts';

import { onMounted, ref } from 'vue';

import { EchartsUI, useEcharts } from '@vben/plugins/echarts';

import { $t } from '#/locales';

const chartRef = ref<EchartsUIType>();
const { renderEcharts } = useEcharts(chartRef);

onMounted(() => {
  renderEcharts({
    series: [
      {
        animationDelay() {
          return Math.random() * 400;
        },
        animationEasing: 'exponentialInOut',
        animationType: 'scale',
        center: ['50%', '50%'],
        color: ['#5ab1ef', '#b6a2de', '#67e0e3', '#2ec7c9'],
        data: [
          { name: $t('page.dashboard.analyticsPage.outsourcing'), value: 500 },
          { name: $t('page.dashboard.analyticsPage.custom'), value: 310 },
          { name: $t('page.dashboard.analyticsPage.techSupport'), value: 274 },
          { name: $t('page.dashboard.analyticsPage.remote'), value: 400 },
        ].toSorted((a, b) => {
          return a.value - b.value;
        }),
        name: $t('page.dashboard.analyticsPage.businessShare'),
        radius: '80%',
        roseType: 'radius',
        type: 'pie',
      },
    ],

    tooltip: {
      trigger: 'item',
    },
  });
});
</script>

<template>
  <EchartsUI ref="chartRef" />
</template>
