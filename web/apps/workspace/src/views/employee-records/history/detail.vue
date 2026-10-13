<script setup lang="ts">
import { onMounted, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';

import { Page } from '@vben/common-ui';
import { IconifyIcon } from '@vben/icons';

import { Button, Spin } from 'ant-design-vue';

import { $t } from '#/locales';

import EmployeeRecordCard from './employee-record-card.vue';
import EmployeeSummaryCard from './employee-summary-card.vue';
import { useEmployeeHistoryPage } from './use-employee-history-page';

const route = useRoute();
const router = useRouter();

const { clearUser, isLoading, selectUser, selectedUser } =
  useEmployeeHistoryPage();

async function syncUserFromRoute(): Promise<void> {
  const userId = route.params.user;
  if (typeof userId === 'string' && userId.length > 0) {
    await selectUser(userId);
  } else {
    clearUser();
  }
}

onMounted(async () => {
  await syncUserFromRoute();
});

watch(
  () => route.params.user,
  async () => {
    await syncUserFromRoute();
  },
);

function goBack(): void {
  router.push('/employee-records/history');
}
</script>

<template>
  <Page auto-content-height content-class="overflow-auto">
    <div class="employee-history-page">
      <Spin :spinning="isLoading" class="block">
        <div
          v-if="selectedUser"
          class="employee-history-layout"
          data-testid="employee-history-layout"
        >
          <EmployeeSummaryCard
            :user="selectedUser"
            @avatar-updated="selectedUser = $event"
          />
          <EmployeeRecordCard :user="selectedUser" />
        </div>

        <div
          v-else
          class="employee-history-empty-card rounded-lg border border-border bg-card p-8 text-center"
          data-testid="employee-history-empty"
        >
          <div
            class="mx-auto flex max-w-sm flex-col items-center justify-center"
          >
            <div
              class="mb-4 flex size-16 items-center justify-center rounded-full bg-muted/70 text-muted-foreground"
            >
              <IconifyIcon icon="lucide:user-x" class="size-8" />
            </div>
            <h3 class="mb-1.5 text-base font-semibold text-foreground">
              {{ $t('page.employeeHistory.emptyHistory.noEmployeeFound') }}
            </h3>
            <p class="mb-5 text-sm text-muted-foreground">
              {{ $t('page.employeeHistory.emptyHistory.noEmployeeFoundDesc') }}
            </p>
            <Button type="primary" @click="goBack">
              {{ $t('page.employeeHistory.actions.backToList') }}
            </Button>
          </div>
        </div>
      </Spin>
    </div>
  </Page>
</template>

<style scoped>
.employee-history-page {
  display: flex;
  flex-direction: column;
  gap: 16px;
  min-height: 100%;
}

.employee-history-layout {
  display: grid;
  grid-template-columns: minmax(260px, 300px) minmax(0, 1fr);
  gap: 16px;
  align-items: start;
}

.employee-history-empty-card {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: min(420px, 60vh);
  padding: 32px 16px;
}

@media (max-width: 1023px) {
  .employee-history-layout {
    grid-template-columns: minmax(220px, 260px) minmax(0, 1fr);
  }
}

@media (max-width: 767px) {
  .employee-history-layout {
    grid-template-columns: 1fr;
  }
}
</style>
