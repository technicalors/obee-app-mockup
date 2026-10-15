<script setup lang="ts">
import {
  Button,
  DatePicker,
  Descriptions,
  DescriptionsItem,
  Drawer,
  Input,
  InputNumber,
  Select,
  Spin,
} from 'ant-design-vue';

import { $t } from '#/locales';
import { ResourceListPage } from '#/shared/resource-table';

import { useHttpMutationLogsPage } from './use-http-mutation-logs-page';

const {
  actionOptions,
  applyFilters,
  clearFilters,
  closeDetail,
  copyMarkdown,
  detail,
  detailLoading,
  detailOpen,
  draft,
  filtersOpen,
  Grid,
  loadActionSuggestions,
  loadUserSuggestions,
  userOptions,
} = useHttpMutationLogsPage();

const errorOptions = [
  { label: $t('mutationLogs.filters.errors'), value: 1 },
  { label: $t('mutationLogs.filters.successes'), value: 0 },
];
const rangeOptions = [
  { label: $t('mutationLogs.filters.twoMinutes'), value: '2m' },
  { label: $t('mutationLogs.filters.fiveMinutes'), value: '5m' },
  { label: $t('mutationLogs.filters.fifteenMinutes'), value: '15m' },
  { label: $t('mutationLogs.filters.oneHour'), value: '1h' },
  { label: $t('mutationLogs.filters.oneDay'), value: '1d' },
];
</script>

<template>
  <ResourceListPage>
    <form
      v-show="filtersOpen"
      class="mb-3 max-h-[45vh] shrink-0 overflow-y-auto rounded border border-border bg-background p-4"
      @submit.prevent="applyFilters"
    >
      <div class="mb-3">
        <h2 class="m-0 text-base font-semibold">
          {{ $t('mutationLogs.listTitle') }}
        </h2>
        <p class="m-0 text-xs text-muted-foreground">
          {{ $t('mutationLogs.listDescription') }}
        </p>
      </div>
      <div class="grid gap-3 md:grid-cols-2 xl:grid-cols-4">
        <label class="flex min-w-0 flex-col gap-1 text-xs">
          {{ $t('mutationLogs.filters.search') }}
          <Input
            v-model:value="draft.search"
            allow-clear
            :placeholder="$t('mutationLogs.filters.searchPlaceholder')"
          />
        </label>
        <label class="flex min-w-0 flex-col gap-1 text-xs">
          {{ $t('mutationLogs.filters.action') }}
          <Select
            v-model:value="draft.action"
            allow-clear
            :filter-option="false"
            :options="actionOptions"
            :placeholder="$t('mutationLogs.filters.actionPlaceholder')"
            show-search
            @focus="loadActionSuggestions('')"
            @search="loadActionSuggestions"
          />
        </label>
        <label class="flex min-w-0 flex-col gap-1 text-xs">
          {{ $t('mutationLogs.filters.requestedBy') }}
          <Select
            v-model:value="draft.requested_by"
            allow-clear
            :filter-option="false"
            :options="userOptions"
            :placeholder="$t('mutationLogs.filters.requestedByPlaceholder')"
            show-search
            @focus="loadUserSuggestions('')"
            @search="loadUserSuggestions"
          />
        </label>
        <label class="flex min-w-0 flex-col gap-1 text-xs">
          {{ $t('mutationLogs.filters.status') }}
          <InputNumber
            :value="draft.response_status"
            style="width: 100%"
            :placeholder="$t('mutationLogs.filters.statusPlaceholder')"
            @update:value="
              draft.response_status =
                $event == null ? undefined : Number($event)
            "
            :min="100"
            :max="599"
          />
        </label>
        <label class="flex min-w-0 flex-col gap-1 text-xs">
          {{ $t('mutationLogs.filters.error') }}
          <Select
            v-model:value="draft.is_error"
            allow-clear
            :options="errorOptions"
            :placeholder="$t('mutationLogs.filters.all')"
          />
        </label>
        <label class="flex min-w-0 flex-col gap-1 text-xs">
          {{ $t('mutationLogs.filters.range') }}
          <Select
            v-model:value="draft.range"
            allow-clear
            :options="rangeOptions"
            :placeholder="$t('mutationLogs.filters.all')"
          />
        </label>
        <label class="flex min-w-0 flex-col gap-1 text-xs">
          {{ $t('mutationLogs.filters.from') }}
          <DatePicker
            :value="draft.from"
            allow-clear
            class="w-full"
            format="YYYY-MM-DD HH:mm"
            :placeholder="$t('mutationLogs.filters.datePlaceholder')"
            show-time
            value-format="YYYY-MM-DDTHH:mm:ssZ"
            @update:value="
              draft.from = typeof $event === 'string' ? $event : undefined
            "
          />
        </label>
        <label class="flex min-w-0 flex-col gap-1 text-xs">
          {{ $t('mutationLogs.filters.to') }}
          <DatePicker
            :value="draft.to"
            allow-clear
            class="w-full"
            format="YYYY-MM-DD HH:mm"
            :placeholder="$t('mutationLogs.filters.datePlaceholder')"
            show-time
            value-format="YYYY-MM-DDTHH:mm:ssZ"
            @update:value="
              draft.to = typeof $event === 'string' ? $event : undefined
            "
          />
        </label>
      </div>
      <div class="mt-3 flex justify-end gap-2">
        <Button html-type="button" @click="clearFilters">
          {{ $t('mutationLogs.actions.clear') }}
        </Button>
        <Button html-type="submit" type="primary">
          {{ $t('mutationLogs.actions.search') }}
        </Button>
      </div>
    </form>

    <Grid />

    <Drawer
      :open="detailOpen"
      :title="$t('mutationLogs.detail.title')"
      :width="800"
      @close="closeDetail"
    >
      <div v-if="detailLoading" class="flex justify-center p-8">
        <Spin />
      </div>
      <div v-else-if="detail !== null" class="space-y-5">
        <div class="flex justify-end">
          <Button @click="copyMarkdown">
            {{ $t('mutationLogs.actions.copyMarkdown') }}
          </Button>
        </div>
        <Descriptions :column="1" bordered size="small">
          <DescriptionsItem :label="$t('mutationLogs.columns.code')">
            {{ detail.code }}
          </DescriptionsItem>
          <DescriptionsItem :label="$t('mutationLogs.columns.loggedAt')">
            {{ detail.logged_at }}
          </DescriptionsItem>
          <DescriptionsItem :label="$t('mutationLogs.columns.uri')">
            {{ detail.uri }}
          </DescriptionsItem>
          <DescriptionsItem :label="$t('mutationLogs.columns.action')">
            {{ detail.action }}
          </DescriptionsItem>
          <DescriptionsItem :label="$t('mutationLogs.columns.status')">
            {{ detail.response_status }}
          </DescriptionsItem>
          <DescriptionsItem :label="$t('mutationLogs.filters.error')">
            {{
              detail.is_error
                ? $t('mutationLogs.filters.errors')
                : $t('mutationLogs.filters.successes')
            }}
          </DescriptionsItem>
          <DescriptionsItem :label="$t('mutationLogs.filters.instanceId')">
            {{ detail.instance_id ?? $t('common.notProvided') }}
          </DescriptionsItem>
          <DescriptionsItem :label="$t('mutationLogs.filters.requestedBy')">
            {{ detail.requested_by_user?.username ?? $t('common.notProvided') }}
          </DescriptionsItem>
          <DescriptionsItem :label="$t('mutationLogs.detail.appUrl')">
            {{ detail.app_url }}
          </DescriptionsItem>
          <DescriptionsItem :label="$t('mutationLogs.detail.gitSha')">
            {{ detail.git_sha_1 }}
          </DescriptionsItem>
        </Descriptions>
        <section>
          <h3 class="mb-2 font-semibold">
            {{ $t('mutationLogs.detail.payload') }}
          </h3>
          <pre
            class="max-h-64 overflow-auto rounded bg-muted p-3 text-xs whitespace-pre-wrap break-all"
          >
            {{ detail.payload ?? $t('common.notProvided') }}
          </pre>
        </section>
        <section>
          <h3 class="mb-2 font-semibold">
            {{ $t('mutationLogs.detail.response') }}
          </h3>
          <pre
            class="max-h-64 overflow-auto rounded bg-muted p-3 text-xs whitespace-pre-wrap break-all"
          >
            {{ detail.response ?? $t('common.notProvided') }}
          </pre>
        </section>
        <section>
          <h3 class="mb-2 font-semibold">
            {{ $t('mutationLogs.detail.codeSnippet') }}
          </h3>
          <pre
            class="max-h-64 overflow-auto rounded bg-muted p-3 text-xs whitespace-pre-wrap break-all"
          >
            {{ detail.code_snippet ?? $t('common.notProvided') }}
          </pre>
        </section>
        <section>
          <h3 class="mb-2 font-semibold">
            {{ $t('mutationLogs.detail.trace') }}
          </h3>
          <pre
            class="max-h-64 overflow-auto rounded bg-muted p-3 text-xs whitespace-pre-wrap break-all"
            >{{
              detail.trace === null
                ? $t('common.notProvided')
                : JSON.stringify(detail.trace, null, 2)
            }}
          </pre>
        </section>
      </div>
    </Drawer>
  </ResourceListPage>
</template>
