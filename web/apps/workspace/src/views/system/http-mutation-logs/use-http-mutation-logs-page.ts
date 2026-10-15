import type { HttpMutationLogFilters } from './query';

import type { HttpMutationLog } from '#/api';

import { reactive, ref } from 'vue';

import { useAccess } from '@vben/access';

import { notification } from 'ant-design-vue';

import {
  getHttpMutationLogApi,
  getHttpMutationLogMarkdownApi,
  httpMutationLogsResource,
  suggestHttpMutationLogActionsApi,
  suggestHttpMutationLogUsersApi,
} from '#/api';
import { httpMutationLogIndexQuerySchema } from '#/api/contracts';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';
import { useResourceTable } from '#/shared/resource-table';
import { useAuthStore } from '#/store';

import { createHttpMutationLogIndexQuery } from './query';
import { createHttpMutationLogTableColumns } from './schema';

export function useHttpMutationLogsPage() {
  const authStore = useAuthStore();
  const { hasAccessByCodes } = useAccess();
  const draft = ref<HttpMutationLogFilters>({});
  const applied = ref<HttpMutationLogFilters>({});
  const actionOptions = ref<Array<{ label: string; value: string }>>([]);
  const userOptions = ref<Array<{ label: string; value: string }>>([]);
  const detail = ref<HttpMutationLog | null>(null);
  const detailOpen = ref(false);
  const detailLoading = ref(false);
  const filtersOpen = ref(false);
  const filterTool = reactive({
    circle: true,
    code: 'mutation-log-filters',
    icon: 'vxe-icon-search',
    status: undefined as 'primary' | undefined,
    title: $t('mutationLogs.actions.toggleFilters'),
  });
  let actionSearchId = 0;
  let userSearchId = 0;
  let detailLoadId = 0;

  const [Grid, table] = useResourceTable<
    HttpMutationLog,
    ReturnType<typeof createHttpMutationLogIndexQuery>
  >({
    buildQuery: (pagination) =>
      createHttpMutationLogIndexQuery(pagination, applied.value),
    enabled: () => authStore.hasSession,
    errorMessage: $t('mutationLogs.messages.loadFailed'),
    gridEvents: {
      toolbarToolClick: ({ code }: { code: string }) => {
        if (code === 'mutation-log-filters') {
          filtersOpen.value = !filtersOpen.value;
          filterTool.status = filtersOpen.value ? 'primary' : undefined;
        }
      },
    },
    gridOptions: {
      border: true,
      columns: createHttpMutationLogTableColumns(hasAccessByCodes, (row) => {
        void openDetail(row);
      }),
      rowConfig: { keyField: 'id' },
      toolbarConfig: {
        tools: [filterTool],
      },
    },
    resource: httpMutationLogsResource,
    tableTitle: $t('mutationLogs.listTitle'),
  });

  async function applyFilters(): Promise<void> {
    try {
      httpMutationLogIndexQuerySchema.parse(
        createHttpMutationLogIndexQuery({ page: 1, per_page: 10 }, draft.value),
      );
      if (draft.value.from || draft.value.to) {
        draft.value.range = undefined;
      }
      applied.value = { ...draft.value };
    } catch (error) {
      showRequestError(
        error,
        $t('mutationLogs.messages.invalidFilters'),
        'Invalid HTTP mutation-log filters:',
      );
      return;
    }
    await table.reload();
  }

  async function clearFilters(): Promise<void> {
    draft.value = {};
    applied.value = {};
    await table.reload();
  }

  async function loadActionSuggestions(q: string): Promise<void> {
    const searchId = ++actionSearchId;
    try {
      const actions = await suggestHttpMutationLogActionsApi(q);
      if (searchId !== actionSearchId) return;
      actionOptions.value = actions.map((action) => ({
        label: action,
        value: action,
      }));
      if (draft.value.action && !actions.includes(draft.value.action)) {
        actionOptions.value.unshift({
          label: draft.value.action,
          value: draft.value.action,
        });
      }
    } catch (error) {
      showRequestError(
        error,
        $t('mutationLogs.messages.suggestFailed'),
        'HTTP mutation-log action suggestions failed:',
      );
    }
  }

  async function loadUserSuggestions(q: string): Promise<void> {
    const searchId = ++userSearchId;
    try {
      const users = await suggestHttpMutationLogUsersApi(q);
      if (searchId !== userSearchId) return;
      const selectedOption = userOptions.value.find(
        (option) => option.value === draft.value.requested_by,
      );
      userOptions.value = users.map((user) => ({
        label: `${user.username} (${user.name})`,
        value: user.id,
      }));
      if (
        selectedOption &&
        !userOptions.value.some(
          (option) => option.value === selectedOption.value,
        )
      ) {
        userOptions.value.unshift(selectedOption);
      }
    } catch (error) {
      showRequestError(
        error,
        $t('mutationLogs.messages.suggestFailed'),
        'HTTP mutation-log user suggestions failed:',
      );
    }
  }

  async function openDetail(row: HttpMutationLog): Promise<void> {
    if (!hasAccessByCodes(['http-mutation-logs.view'])) return;
    const loadId = ++detailLoadId;
    detailLoading.value = true;
    detail.value = null;
    detailOpen.value = true;
    try {
      const result = await getHttpMutationLogApi(row.id);
      if (loadId !== detailLoadId) return;
      detail.value = result;
    } catch (error) {
      detailOpen.value = false;
      showRequestError(
        error,
        $t('mutationLogs.messages.detailFailed'),
        'HTTP mutation-log detail failed:',
      );
    } finally {
      if (loadId === detailLoadId) detailLoading.value = false;
    }
  }

  function closeDetail(): void {
    ++detailLoadId;
    detailOpen.value = false;
    detail.value = null;
    detailLoading.value = false;
  }

  async function copyMarkdown(): Promise<void> {
    if (detail.value === null) return;
    try {
      await navigator.clipboard.writeText(
        await getHttpMutationLogMarkdownApi(detail.value.id),
      );
      notification.success({
        message: $t('mutationLogs.messages.copied'),
      });
    } catch (error) {
      showRequestError(
        error,
        $t('mutationLogs.messages.copyFailed'),
        'HTTP mutation-log Markdown copy failed:',
      );
    }
  }

  return {
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
    openDetail,
    userOptions,
  };
}
