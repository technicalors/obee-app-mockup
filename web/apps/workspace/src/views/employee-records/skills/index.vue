<script setup lang="ts">
import { Fallback } from '@vben/common-ui';

import { $t } from '#/locales';
</script>

<template>
  <Fallback
    status="coming-soon"
    :title="$t('employeeRecord.developmentNotice')"
  />
</template>
