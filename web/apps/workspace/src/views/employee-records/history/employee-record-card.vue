<script setup lang="ts">
import type { User } from '#/api';

import { ref } from 'vue';

import { IconifyIcon } from '@vben/icons';

import {
  Card,
  Descriptions,
  DescriptionsItem,
  Table,
  Tabs,
} from 'ant-design-vue';

import { $t } from '#/locales';

defineProps<{ user: User }>();

const activeTab = ref('work-history');

const workHistoryColumns = [
  {
    dataIndex: 'date',
    key: 'date',
    title: $t('page.employeeHistory.columns.date'),
    width: 130,
  },
  {
    dataIndex: 'positionDepartment',
    key: 'positionDepartment',
    title: $t('page.employeeHistory.columns.positionDepartment'),
  },
  {
    dataIndex: 'position',
    key: 'position',
    title: $t('page.employeeHistory.columns.position'),
    width: 160,
  },
  {
    dataIndex: 'note',
    key: 'note',
    title: $t('page.employeeHistory.columns.note'),
    width: 160,
  },
];

const educationHistoryColumns = [
  {
    dataIndex: 'date',
    key: 'date',
    title: $t('page.employeeHistory.columns.date'),
    width: 130,
  },
  {
    dataIndex: 'content',
    key: 'content',
    title: $t('page.employeeHistory.columns.content'),
  },
  {
    dataIndex: 'level',
    key: 'level',
    title: $t('page.employeeHistory.columns.level'),
    width: 160,
  },
  {
    dataIndex: 'note',
    key: 'note',
    title: $t('page.employeeHistory.columns.note'),
    width: 160,
  },
];

const achievementsColumns = [
  {
    dataIndex: 'date',
    key: 'date',
    title: $t('page.employeeHistory.columns.date'),
    width: 130,
  },
  {
    dataIndex: 'award',
    key: 'award',
    title: $t('page.employeeHistory.columns.award'),
  },
  {
    dataIndex: 'note',
    key: 'note',
    title: $t('page.employeeHistory.columns.note'),
    width: 160,
  },
];

const hrNotesColumns = [
  {
    dataIndex: 'date',
    key: 'date',
    title: $t('page.employeeHistory.columns.date'),
    width: 130,
  },
  {
    dataIndex: 'content',
    key: 'content',
    title: $t('page.employeeHistory.columns.content'),
  },
  {
    dataIndex: 'note',
    key: 'note',
    title: $t('page.employeeHistory.columns.note'),
    width: 160,
  },
];

const historySections = [
  {
    columns: workHistoryColumns,
    emptyDescription: $t('page.employeeHistory.emptyHistory.workHistoryDesc'),
    emptyTitle: $t('page.employeeHistory.emptyHistory.workHistory'),
    icon: 'lucide:briefcase',
    key: 'work-history',
    rows: [],
    title: $t('page.employeeHistory.sections.workHistory'),
  },
  {
    columns: educationHistoryColumns,
    emptyDescription: $t(
      'page.employeeHistory.emptyHistory.educationHistoryDesc',
    ),
    emptyTitle: $t('page.employeeHistory.emptyHistory.educationHistory'),
    icon: 'lucide:graduation-cap',
    key: 'education-history',
    rows: [],
    title: $t('page.employeeHistory.sections.educationHistory'),
  },
  {
    columns: achievementsColumns,
    emptyDescription: $t('page.employeeHistory.emptyHistory.achievementsDesc'),
    emptyTitle: $t('page.employeeHistory.emptyHistory.achievements'),
    icon: 'lucide:award',
    key: 'achievements',
    rows: [],
    title: $t('page.employeeHistory.sections.achievements'),
  },
  {
    columns: hrNotesColumns,
    emptyDescription: $t('page.employeeHistory.emptyHistory.hrNotesDesc'),
    emptyTitle: $t('page.employeeHistory.emptyHistory.hrNotes'),
    icon: 'lucide:file-text',
    key: 'hr-notes',
    rows: [],
    title: $t('page.employeeHistory.sections.hrNotes'),
  },
];

function genderLabel(sex: null | string): string {
  if (sex === 'male') return $t('page.users.gender.male');
  if (sex === 'female') return $t('page.users.gender.female');
  return $t('common.notProvided');
}

function educationLabel(level: null | string): string {
  if (!level) return $t('common.notProvided');
  return $t(`page.users.educationLevels.${level}`);
}
</script>

<template>
  <div class="employee-record-card" data-testid="employee-record-card">
    <Card class="employee-record-section" :bordered="true">
      <template #title>
        <div class="flex items-center gap-2.5">
          <div class="h-4 w-1 rounded-full bg-primary"></div>
          <h2 class="employee-record-section-title">
            {{ $t('page.employeeHistory.sections.personalInfo') }}
          </h2>
        </div>
      </template>

      <Descriptions
        bordered
        size="small"
        :column="{ lg: 2, md: 2, sm: 1, xl: 2, xs: 1 }"
      >
        <DescriptionsItem
          :label="$t('page.employeeHistory.fields.fullName')"
          :span="2"
        >
          {{ user.name }}
        </DescriptionsItem>
        <DescriptionsItem :label="$t('page.employeeHistory.fields.gender')">
          {{ genderLabel(user.profile?.sex ?? null) }}
        </DescriptionsItem>
        <DescriptionsItem
          :label="$t('page.employeeHistory.fields.employeeCode')"
        >
          {{ user.profile?.code ?? $t('common.notProvided') }}
        </DescriptionsItem>
        <DescriptionsItem
          :label="$t('page.employeeHistory.fields.dateOfBirth')"
        >
          {{ user.profile?.birthday ?? $t('common.notProvided') }}
        </DescriptionsItem>
        <DescriptionsItem :label="$t('page.employeeHistory.fields.age')">
          {{ user.profile?.age ?? $t('common.notProvided') }}
        </DescriptionsItem>
        <DescriptionsItem :label="$t('page.employeeHistory.fields.joinedAt')">
          {{ user.profile?.joined_at ?? $t('common.notProvided') }}
        </DescriptionsItem>
        <DescriptionsItem :label="$t('page.employeeHistory.fields.seniority')">
          {{ user.profile?.seniority ?? $t('common.notProvided') }}
        </DescriptionsItem>
        <DescriptionsItem :label="$t('page.employeeHistory.fields.workUnit')">
          {{
            user.departments.length === 0
              ? $t('common.notProvided')
              : user.departments
                  .map((department) => department.name)
                  .join(' > ')
          }}
        </DescriptionsItem>
        <DescriptionsItem
          :label="$t('page.employeeHistory.fields.currentPosition')"
        >
          {{ user.profile?.position?.name ?? $t('common.notProvided') }}
        </DescriptionsItem>
        <DescriptionsItem
          :label="$t('page.employeeHistory.fields.address')"
          :span="2"
        >
          {{ user.profile?.address ?? $t('common.notProvided') }}
        </DescriptionsItem>
        <DescriptionsItem :label="$t('page.employeeHistory.fields.email')">
          {{ user.email ?? $t('common.notProvided') }}
        </DescriptionsItem>
        <DescriptionsItem :label="$t('page.employeeHistory.fields.phone')">
          {{ user.profile?.phone_number ?? $t('common.notProvided') }}
        </DescriptionsItem>
        <DescriptionsItem :label="$t('page.employeeHistory.fields.citizenId')">
          {{
            user.profile?.citizen_identification_card ??
            $t('common.notProvided')
          }}
        </DescriptionsItem>
        <DescriptionsItem
          :label="$t('page.employeeHistory.fields.socialInsurance')"
        >
          {{
            user.profile?.social_insurance_number ?? $t('common.notProvided')
          }}
        </DescriptionsItem>
        <DescriptionsItem
          :label="$t('page.employeeHistory.fields.healthInsurance')"
        >
          {{
            user.profile?.health_insurance_card_number ??
            $t('common.notProvided')
          }}
        </DescriptionsItem>
        <DescriptionsItem
          :label="$t('page.employeeHistory.fields.educationLevel')"
        >
          {{ educationLabel(user.profile?.education_level ?? null) }}
        </DescriptionsItem>
        <DescriptionsItem
          :label="$t('page.employeeHistory.fields.personalTaxId')"
        >
          {{
            user.profile?.personal_tax_identification_number ??
            $t('common.notProvided')
          }}
        </DescriptionsItem>
        <DescriptionsItem
          :label="$t('page.employeeHistory.fields.dependentTaxId')"
        >
          {{
            user.profile?.dependent_tax_identification_number ??
            $t('common.notProvided')
          }}
        </DescriptionsItem>
      </Descriptions>
    </Card>

    <Card class="employee-record-section" :bordered="true">
      <Tabs v-model:active-key="activeTab" class="employee-history-tabs">
        <Tabs.TabPane
          v-for="section in historySections"
          :key="section.key"
          :tab="section.title"
        >
          <div v-if="section.rows.length > 0" class="employee-history-table">
            <Table
              :columns="section.columns"
              :data-source="section.rows"
              :pagination="false"
              :scroll="{ x: 'max-content' }"
              size="small"
            />
          </div>
          <div
            v-else
            class="employee-history-section-empty flex flex-col items-center justify-center px-4 py-12 text-center"
          >
            <div
              class="mb-3.5 flex size-14 items-center justify-center rounded-full bg-muted/60 text-muted-foreground"
            >
              <IconifyIcon :icon="section.icon" class="size-6" />
            </div>
            <p class="mb-1 text-sm font-medium text-foreground">
              {{ section.emptyTitle }}
            </p>
            <p class="m-0 max-w-md text-xs text-muted-foreground">
              {{ section.emptyDescription }}
            </p>
          </div>
        </Tabs.TabPane>
      </Tabs>
    </Card>
  </div>
</template>

<style scoped>
.employee-record-card {
  display: flex;
  flex-direction: column;
  gap: 16px;
  min-width: 0;
}

.employee-record-section {
  min-width: 0;
  overflow: hidden;
  background: hsl(var(--card));
  border-radius: 8px;
}

.employee-record-section-title {
  margin: 0;
  font-size: 15px;
  font-weight: 600;
  line-height: 24px;
  color: hsl(var(--foreground));
}

.employee-history-tabs :deep(.ant-tabs-nav) {
  margin-bottom: 12px;
}

.employee-history-table {
  min-width: 0;
  overflow-x: auto;
}

.employee-history-section-empty {
  min-height: 180px;
}

@media (max-width: 767px) {
  .employee-record-section :deep(.ant-card-body) {
    padding: 16px;
  }
}
</style>
