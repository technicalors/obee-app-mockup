<script setup lang="ts">
import type { Dayjs } from 'dayjs';

import type { RequestTab } from './absence-page';

import type {
  AbsenceRequest,
  CreateAbsenceRequest,
  LeaveBalance,
} from '#/api/absence-requests';
import type { UserTreeSelectionUser } from '#/api/contracts';

import { computed, onMounted, ref, watch } from 'vue';

import { Page } from '@vben/common-ui';
import { IconifyIcon } from '@vben/icons';

import {
  Modal as AntModal,
  Button,
  Empty,
  notification,
  Pagination,
  RangePicker,
  Select,
  Tabs,
} from 'ant-design-vue';

import { getOrganizationRootId, userTreeResource } from '#/api';
import {
  approveAbsenceRequest,
  createAbsenceRequest,
  createAbsenceRequestSchema,
  deleteAbsenceRequest,
  getAbsenceRequest,
  getAbsenceRequests,
  getLeaveBalance,
  getReviewerCapability,
  rejectAbsenceRequest,
  returnAbsenceRequest,
  updateAbsenceRequest,
} from '#/api/absence-requests';
import { $t } from '#/locales';
import { showRequestError } from '#/shared/request-feedback';
import UserTreeSelect from '#/shared/user-tree-select/user-tree-select.vue';
import { useAuthStore } from '#/store';

import {
  buildAbsenceListQuery,
  getDefaultAbsenceFilters,
} from './absence-page';
import AbsenceRequestDetailModal from './components/AbsenceRequestDetailModal.vue';
import AbsenceRequestFormModal from './components/AbsenceRequestFormModal.vue';
import AbsenceRequestListItem from './components/AbsenceRequestListItem.vue';
import AbsenceRequestLoadingState from './components/AbsenceRequestLoadingState.vue';
import AbsenceRequestMessageState from './components/AbsenceRequestMessageState.vue';
import AbsenceRequestReviewNoteModal from './components/AbsenceRequestReviewNoteModal.vue';

const authStore = useAuthStore();
const currentUserId = computed(() => authStore.user?.id ?? null);
const isApprover = ref(false);

const defaultFilters = getDefaultAbsenceFilters();
const filters = ref({ ...defaultFilters });

const activeTab = ref<RequestTab>('pending');
const tabCounts = ref({
  all: 0,
  approved: 0,
  pending: 0,
  rejected: 0,
});

const treeUsers = ref<UserTreeSelectionUser[]>([]);
const authorizedReviewers = ref<UserTreeSelectionUser[]>([]);
const balance = ref<LeaveBalance | null>(null);
const requests = ref<AbsenceRequest[]>([]);
const total = ref(0);
const page = ref(1);
const pageSize = ref(10);

const loading = ref(false);
const listError = ref(false);
const balanceLoading = ref(false);
const balanceError = ref(false);
const balanceDate = ref<null | string>(null);

const saving = ref(false);
const deleting = ref(false);
const approving = ref(false);
const rejecting = ref(false);
const returning = ref(false);

const selectedRequest = ref<AbsenceRequest | null>(null);
const editingRequest = ref<AbsenceRequest | null>(null);
const detailOpen = ref(false);
const createTimeoffOpen = ref(false);
const createBusinessTripOpen = ref(false);
const editOpen = ref(false);
const noteModalOpen = ref(false);
const noteModalMode = ref<'reject' | 'return'>('reject');
const noteModalRequest = ref<AbsenceRequest | null>(null);
const actionLoadingId = ref<null | string>(null);

let listVersion = 0;
let balanceVersion = 0;

const currentRootOrganizationId = computed(
  () => authStore.user?.root_organization_id ?? null,
);

const formRootOrganizationId = computed(() =>
  editingRequest.value
    ? editingRequest.value.root_organization_id
    : currentRootOrganizationId.value,
);

const reviewerUsers = computed(() =>
  authorizedReviewers.value.filter(
    (user) =>
      formRootOrganizationId.value !== null &&
      getOrganizationRootId(user.organization) === formRootOrganizationId.value,
  ),
);
const reviewerUsersLoading = ref(false);
const reviewerUsersLoadError = ref(false);

const requestTypeFilterOptions = computed(() => [
  { label: $t('absenceRequests.types.ANNUAL'), value: 'ANNUAL' },
  { label: $t('absenceRequests.types.UNPAID'), value: 'UNPAID' },
  {
    label: $t('absenceRequests.types.BUSINESS_TRIP'),
    value: 'BUSINESS_TRIP',
  },
]);

type DateRangeValue = [Dayjs, Dayjs] | [string, string] | undefined;

const dateRangeValue = computed<DateRangeValue>({
  get: () => {
    if (filters.value.from && filters.value.to) {
      return [filters.value.from, filters.value.to] as [string, string];
    }
    return undefined;
  },
  set: (value) => {
    if (value?.[0] && value[1]) {
      filters.value.from =
        typeof value[0] === 'string' ? value[0] : value[0].format('YYYY-MM-DD');
      filters.value.to =
        typeof value[1] === 'string' ? value[1] : value[1].format('YYYY-MM-DD');
    } else {
      filters.value.from = '';
      filters.value.to = '';
    }
  },
});

function handleFilterChange(): void {
  page.value = 1;
  void loadRequests();
  void loadTabCounts();
}

async function loadReviewerCapability(): Promise<void> {
  try {
    isApprover.value = await getReviewerCapability();
  } catch {
    isApprover.value = false;
  }
}

async function loadTabCounts(): Promise<void> {
  const userId = currentUserId.value;
  if (!userId) return;

  try {
    const commonParams = {
      currentUserId: userId,
      from: filters.value.from || undefined,
      leaveType: filters.value.leave_type || undefined,
      page: 1,
      perPage: 1,
      reviewerId: filters.value.reviewer_id || undefined,
      reviewerIds:
        filters.value.reviewer_ids.length > 0
          ? filters.value.reviewer_ids
          : undefined,
      to: filters.value.to || undefined,
      userId: filters.value.user_id || undefined,
      userIds:
        filters.value.user_ids.length > 0 ? filters.value.user_ids : undefined,
    };

    const [pendingRes, approvedRes, rejectedRes, allRes] = await Promise.all([
      getAbsenceRequests(
        buildAbsenceListQuery({
          ...commonParams,
          status: undefined,
          tab: 'pending',
        }),
      ),
      getAbsenceRequests(
        buildAbsenceListQuery({
          ...commonParams,
          status: undefined,
          tab: 'approved',
        }),
      ),
      getAbsenceRequests(
        buildAbsenceListQuery({
          ...commonParams,
          status: undefined,
          tab: 'rejected',
        }),
      ),
      getAbsenceRequests(
        buildAbsenceListQuery({
          ...commonParams,
          status: undefined,
          tab: 'all',
        }),
      ),
    ]);

    tabCounts.value.pending = pendingRes.pagination.total;
    tabCounts.value.approved = approvedRes.pagination.total;
    tabCounts.value.rejected = rejectedRes.pagination.total;
    tabCounts.value.all = allRes.pagination.total;
  } catch {
    // Keep current counts on error
  }
}

async function loadContext(): Promise<void> {
  reviewerUsersLoading.value = true;
  reviewerUsersLoadError.value = false;
  try {
    [treeUsers.value, authorizedReviewers.value] = await Promise.all([
      userTreeResource.getAll(),
      userTreeResource.getAll({ permission_name: 'absence-requests.review' }),
    ]);
  } catch {
    treeUsers.value = [];
    authorizedReviewers.value = [];
    reviewerUsersLoadError.value = true;
  } finally {
    reviewerUsersLoading.value = false;
  }
}

async function loadBalance(): Promise<void> {
  const version = ++balanceVersion;
  balanceLoading.value = true;
  balanceError.value = false;

  try {
    const result = await getLeaveBalance(balanceDate.value ?? undefined);
    if (version !== balanceVersion) return;
    balance.value = result;
  } catch {
    if (version === balanceVersion) {
      balanceError.value = true;
      balance.value = null;
    }
  } finally {
    if (version === balanceVersion) balanceLoading.value = false;
  }
}

function handleBalanceDateChange(date: null | string): void {
  balanceDate.value = date;
  void loadBalance();
}

async function loadRequests(): Promise<void> {
  const userId = currentUserId.value;
  if (!userId) return;

  const version = ++listVersion;
  loading.value = true;
  listError.value = false;

  try {
    const query = buildAbsenceListQuery({
      currentUserId: userId,
      from: filters.value.from || undefined,
      leaveType: filters.value.leave_type || undefined,
      page: page.value,
      perPage: pageSize.value,
      reviewerId: filters.value.reviewer_id || undefined,
      reviewerIds:
        filters.value.reviewer_ids.length > 0
          ? filters.value.reviewer_ids
          : undefined,
      status:
        activeTab.value === 'review'
          ? 'pending'
          : filters.value.status || undefined,
      tab: activeTab.value,
      to: filters.value.to || undefined,
      userId: filters.value.user_id || undefined,
      userIds:
        filters.value.user_ids.length > 0 ? filters.value.user_ids : undefined,
    });

    const result = await getAbsenceRequests(query);
    if (version !== listVersion) return;
    requests.value = result.items;
    total.value = result.pagination.total;
    if (activeTab.value in tabCounts.value) {
      tabCounts.value[activeTab.value as keyof typeof tabCounts.value] =
        result.pagination.total;
    }
  } catch (error) {
    if (version === listVersion) {
      listError.value = true;
      showRequestError(
        error,
        $t('absenceRequests.messages.loadFailed'),
        'Failed to load absence requests:',
      );
    }
  } finally {
    if (version === listVersion) loading.value = false;
  }
}

async function handleOpenDetail(request: AbsenceRequest): Promise<void> {
  try {
    selectedRequest.value = await getAbsenceRequest(request.id);
    detailOpen.value = true;
  } catch (error) {
    showRequestError(
      error,
      $t('absenceRequests.messages.loadFailed'),
      'Failed to load absence request detail:',
    );
  }
}

async function handleSubmitForm(payload: CreateAbsenceRequest): Promise<void> {
  const parsed = createAbsenceRequestSchema.safeParse(payload);
  if (!parsed.success) {
    notification.warning({
      message: $t('absenceRequests.messages.invalidForm'),
    });
    return;
  }

  saving.value = true;
  try {
    if (editingRequest.value) {
      const request = editingRequest.value;
      await updateAbsenceRequest(request.id, {
        address: parsed.data.address,
        end_at: parsed.data.end_at,
        leave_type: parsed.data.leave_type,
        reason: parsed.data.reason,
        reviewer_id: parsed.data.reviewer_id,
        start_at: parsed.data.start_at,
        status: 'pending',
      });
    } else {
      await createAbsenceRequest(parsed.data);
    }
    createTimeoffOpen.value = false;
    createBusinessTripOpen.value = false;
    editOpen.value = false;
    editingRequest.value = null;
    filters.value = { ...defaultFilters };
    activeTab.value = 'pending';
    page.value = 1;
    notification.success({
      message: $t('absenceRequests.messages.created'),
    });
    await Promise.all([loadRequests(), loadBalance(), loadTabCounts()]);
  } catch (error) {
    showRequestError(
      error,
      $t('absenceRequests.messages.saveFailed'),
      'Failed to create absence request:',
    );
  } finally {
    saving.value = false;
  }
}

function handleEditRequest(): void {
  editingRequest.value = selectedRequest.value;
  detailOpen.value = false;
  editOpen.value = true;
}

function handleCreateTimeoff(): void {
  editingRequest.value = null;
  createTimeoffOpen.value = true;
}

function handleCreateBusinessTrip(): void {
  editingRequest.value = null;
  createBusinessTripOpen.value = true;
}

async function handleApprove(): Promise<void> {
  if (!selectedRequest.value) return;
  approving.value = true;
  try {
    await approveAbsenceRequest(selectedRequest.value.id, {
      approval_note: null,
    });
    detailOpen.value = false;
    notification.success({
      message: $t('absenceRequests.messages.approved'),
    });
    await Promise.all([loadRequests(), loadBalance(), loadTabCounts()]);
  } catch (error) {
    showRequestError(
      error,
      $t('absenceRequests.messages.saveFailed'),
      'Failed to approve absence request:',
    );
  } finally {
    approving.value = false;
  }
}

async function handleReject(note: string): Promise<void> {
  if (!selectedRequest.value) return;
  rejecting.value = true;
  try {
    await rejectAbsenceRequest(selectedRequest.value.id, {
      approval_note: note,
    });
    detailOpen.value = false;
    notification.success({
      message: $t('absenceRequests.messages.rejected'),
    });
    await Promise.all([loadRequests(), loadBalance(), loadTabCounts()]);
  } catch (error) {
    showRequestError(
      error,
      $t('absenceRequests.messages.saveFailed'),
      'Failed to reject absence request:',
    );
  } finally {
    rejecting.value = false;
  }
}

async function handleReturn(note: string): Promise<void> {
  if (!selectedRequest.value) return;
  returning.value = true;
  try {
    await returnAbsenceRequest(selectedRequest.value.id, {
      approval_note: note,
    });
    detailOpen.value = false;
    notification.success({
      message: $t('absenceRequests.messages.returned'),
    });
    await Promise.all([loadRequests(), loadTabCounts()]);
  } catch (error) {
    showRequestError(
      error,
      $t('absenceRequests.messages.saveFailed'),
      'Failed to return absence request:',
    );
  } finally {
    returning.value = false;
  }
}

async function handleDelete(): Promise<void> {
  if (!selectedRequest.value) return;
  deleting.value = true;
  try {
    await deleteAbsenceRequest(selectedRequest.value.id);
    detailOpen.value = false;
    notification.success({
      message: $t('absenceRequests.messages.deleted'),
    });
    await Promise.all([loadRequests(), loadBalance(), loadTabCounts()]);
  } catch (error) {
    showRequestError(
      error,
      $t('absenceRequests.messages.saveFailed'),
      'Failed to delete absence request:',
    );
  } finally {
    deleting.value = false;
  }
}

async function handleInlineApprove(request: AbsenceRequest): Promise<void> {
  AntModal.confirm({
    content: $t('absenceRequests.detail.review.confirmApproveDescription'),
    okText: $t('absenceRequests.detail.review.confirmApprove'),
    onOk: async () => {
      actionLoadingId.value = request.id;
      try {
        await approveAbsenceRequest(request.id, {
          approval_note: null,
        });
        notification.success({
          message: $t('absenceRequests.messages.approved'),
        });
        await Promise.all([loadRequests(), loadBalance(), loadTabCounts()]);
      } catch (error) {
        showRequestError(
          error,
          $t('absenceRequests.messages.saveFailed'),
          'Failed to approve absence request:',
        );
      } finally {
        actionLoadingId.value = null;
      }
    },
    title: $t('absenceRequests.detail.review.confirmApproveTitle'),
  });
}

function handleInlineReject(request: AbsenceRequest): void {
  noteModalRequest.value = request;
  noteModalMode.value = 'reject';
  noteModalOpen.value = true;
}

function handleInlineReturn(request: AbsenceRequest): void {
  noteModalRequest.value = request;
  noteModalMode.value = 'return';
  noteModalOpen.value = true;
}

async function handleNoteModalSubmit(note: string): Promise<void> {
  if (!noteModalRequest.value) return;
  const req = noteModalRequest.value;
  actionLoadingId.value = req.id;
  try {
    if (noteModalMode.value === 'reject') {
      await rejectAbsenceRequest(req.id, { approval_note: note });
      notification.success({
        message: $t('absenceRequests.messages.rejected'),
      });
    } else {
      await returnAbsenceRequest(req.id, { approval_note: note });
      notification.success({
        message: $t('absenceRequests.messages.returned'),
      });
    }
    noteModalOpen.value = false;
    await Promise.all([loadRequests(), loadBalance(), loadTabCounts()]);
  } catch (error) {
    showRequestError(
      error,
      $t('absenceRequests.messages.saveFailed'),
      `Failed to ${noteModalMode.value} absence request:`,
    );
  } finally {
    actionLoadingId.value = null;
  }
}

function handleInlineEdit(request: AbsenceRequest): void {
  editingRequest.value = request;
  editOpen.value = true;
}

function handleInlineDelete(request: AbsenceRequest): void {
  AntModal.confirm({
    content: $t('absenceRequests.detail.requester.confirmDeleteDescription'),
    okButtonProps: { danger: true },
    okText: $t('absenceRequests.detail.requester.confirmDelete'),
    onOk: async () => {
      actionLoadingId.value = request.id;
      try {
        await deleteAbsenceRequest(request.id);
        notification.success({
          message: $t('absenceRequests.messages.deleted'),
        });
        await Promise.all([loadRequests(), loadBalance(), loadTabCounts()]);
      } catch (error) {
        showRequestError(
          error,
          $t('absenceRequests.messages.saveFailed'),
          'Failed to delete absence request:',
        );
      } finally {
        actionLoadingId.value = null;
      }
    },
    title: $t('absenceRequests.detail.requester.confirmDeleteTitle'),
  });
}

function handleTabChange(tabKey: number | string): void {
  activeTab.value = String(tabKey) as RequestTab;
  page.value = 1;
  void loadRequests();
}

// handleClearAllFilters removed

watch(page, () => void loadRequests());

onMounted(async () => {
  await Promise.all([loadReviewerCapability(), loadContext(), loadBalance()]);
  activeTab.value = 'pending';
  await Promise.all([loadRequests(), loadTabCounts()]);
});
</script>

<template>
  <Page auto-content-height content-class="p-3 sm:p-4">
    <div
      class="flex h-full flex-col rounded-xl border border-border bg-card shadow-xs overflow-hidden"
    >
      <!-- Top Section: Header, Inline Filters, Tabs (all in one card header) -->
      <div class="p-4 sm:p-5 pb-0">
        <!-- Title & Action Buttons -->
        <div
          class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between"
        >
          <div class="space-y-1">
            <h1 class="text-xl font-semibold tracking-tight text-foreground">
              {{ $t('absenceRequests.title') }}
            </h1>
          </div>

          <div class="flex flex-wrap items-center gap-2">
            <Button
              type="primary"
              class="flex items-center gap-1.5"
              data-testid="create-timeoff-request"
              @click="handleCreateTimeoff"
            >
              <IconifyIcon icon="lucide:calendar-off" class="size-4" />
              <span>{{
                $t('absenceRequests.create.actions.openTimeoff')
              }}</span>
            </Button>

            <Button
              type="primary"
              class="flex items-center gap-1.5"
              data-testid="create-business-trip-request"
              @click="handleCreateBusinessTrip"
            >
              <IconifyIcon icon="lucide:briefcase" class="size-4" />
              <span>{{
                $t('absenceRequests.create.actions.openBusinessTrip')
              }}</span>
            </Button>
          </div>
        </div>

        <!-- Inline Filter Bar directly under header -->
        <div class="mt-4 flex flex-wrap items-center gap-3 text-xs">
          <!-- Request Type Filter -->
          <div class="flex items-center gap-1.5">
            <span class="text-muted-foreground whitespace-nowrap">
              {{ $t('absenceRequests.filters.fields.requestType') }}:
            </span>
            <Select
              v-model:value="filters.leave_type"
              allow-clear
              size="middle"
              class="w-52"
              :popup-match-select-width="false"
              :options="requestTypeFilterOptions"
              :placeholder="$t('absenceRequests.filters.all')"
              @change="handleFilterChange"
            />
          </div>

          <!-- Requester Filter -->
          <div class="flex items-center gap-1.5">
            <span class="text-muted-foreground whitespace-nowrap">
              {{ $t('absenceRequests.filters.fields.requester') }}:
            </span>
            <UserTreeSelect
              :model-value="filters.user_ids"
              :multiple="true"
              :users="treeUsers"
              :loading="reviewerUsersLoading"
              :load-error="reviewerUsersLoadError"
              size="middle"
              class="w-56"
              :placeholder="$t('absenceRequests.filters.all')"
              test-id="absence-requester-tree-select"
              @update:model-value="
                filters.user_ids = $event;
                handleFilterChange();
              "
            />
          </div>

          <!-- Reviewer Filter -->
          <div class="flex items-center gap-1.5">
            <span class="text-muted-foreground whitespace-nowrap">
              {{ $t('absenceRequests.filters.fields.reviewer') }}:
            </span>
            <UserTreeSelect
              :model-value="filters.reviewer_ids"
              :multiple="true"
              :users="treeUsers"
              :loading="reviewerUsersLoading"
              :load-error="reviewerUsersLoadError"
              size="middle"
              class="w-56"
              :placeholder="$t('absenceRequests.filters.all')"
              test-id="absence-reviewer-filter-tree-select"
              @update:model-value="
                filters.reviewer_ids = $event;
                handleFilterChange();
              "
            />
          </div>

          <!-- Date Range (RangePicker) -->
          <div class="flex items-center gap-1.5">
            <span class="text-muted-foreground whitespace-nowrap">
              {{ $t('absenceRequests.filters.fields.dateRange') }}:
            </span>
            <RangePicker
              v-model:value="dateRangeValue"
              value-format="YYYY-MM-DD"
              size="middle"
              class="w-64"
              @change="handleFilterChange"
            />
          </div>
        </div>

        <!-- Tabs Navigation -->
        <div class="mt-3">
          <Tabs
            :active-key="activeTab"
            class="absence-request-tabs -mb-px"
            @change="handleTabChange"
          >
            <Tabs.TabPane key="all">
              <template #tab>
                <span class="inline-flex items-center gap-1.5">
                  <span>{{ $t('absenceRequests.tabs.all') }}</span>
                  <span
                    class="inline-flex h-5 min-w-5 items-center justify-center rounded-full bg-neutral-500 px-1.5 text-[11px] font-medium leading-none text-white"
                  >
                    {{ tabCounts.all }}
                  </span>
                </span>
              </template>
            </Tabs.TabPane>
            <Tabs.TabPane key="pending">
              <template #tab>
                <span class="inline-flex items-center gap-1.5">
                  <span>{{ $t('absenceRequests.tabs.pending') }}</span>
                  <span
                    class="inline-flex h-5 min-w-5 items-center justify-center rounded-full bg-[#1677ff] px-1.5 text-[11px] font-medium leading-none text-white"
                  >
                    {{ tabCounts.pending }}
                  </span>
                </span>
              </template>
            </Tabs.TabPane>
            <Tabs.TabPane key="approved">
              <template #tab>
                <span class="inline-flex items-center gap-1.5">
                  <span>{{ $t('absenceRequests.tabs.approved') }}</span>
                  <span
                    class="inline-flex h-5 min-w-5 items-center justify-center rounded-full bg-[#10b981] px-1.5 text-[11px] font-medium leading-none text-white"
                  >
                    {{ tabCounts.approved }}
                  </span>
                </span>
              </template>
            </Tabs.TabPane>
            <Tabs.TabPane key="rejected">
              <template #tab>
                <span class="inline-flex items-center gap-1.5">
                  <span>{{ $t('absenceRequests.tabs.rejected') }}</span>
                  <span
                    class="inline-flex h-5 min-w-5 items-center justify-center rounded-full bg-[#ef4444] px-1.5 text-[11px] font-medium leading-none text-white"
                  >
                    {{ tabCounts.rejected }}
                  </span>
                </span>
              </template>
            </Tabs.TabPane>
          </Tabs>
        </div>
      </div>

      <!-- Content Area with Rows directly following Tabs -->
      <div class="flex-1 overflow-y-auto px-4 sm:px-5 py-3">
        <!-- Loading State -->
        <AbsenceRequestLoadingState
          v-if="loading"
          :title="$t('absenceRequests.states.listLoadingTitle')"
          :description="$t('absenceRequests.states.listLoadingDescription')"
        />

        <!-- Error State -->
        <AbsenceRequestMessageState
          v-else-if="listError"
          :title="$t('absenceRequests.states.listErrorTitle')"
          :description="$t('absenceRequests.states.listErrorDescription')"
          tone="error"
        />

        <!-- Empty State -->
        <div
          v-else-if="requests.length === 0"
          class="flex min-h-[220px] items-center justify-center p-8"
        >
          <Empty :description="$t('absenceRequests.empty')" />
        </div>

        <!-- Request List Items -->
        <div v-else class="space-y-2.5">
          <AbsenceRequestListItem
            v-for="req in requests"
            :key="req.id"
            :request="req"
            :current-user-id="currentUserId"
            :has-review-permission="isApprover"
            :highlight-for-review="activeTab === 'review'"
            :action-loading-id="actionLoadingId"
            @open="handleOpenDetail"
            @approve="handleInlineApprove"
            @reject="handleInlineReject"
            @return="handleInlineReturn"
            @edit="handleInlineEdit"
            @delete="handleInlineDelete"
          />
        </div>
      </div>

      <!-- Pagination Footer inside the Card -->
      <div
        v-if="total > 0"
        class="flex flex-wrap items-center justify-between gap-2 border-t border-border px-4 py-3 bg-muted/10 text-xs text-muted-foreground"
      >
        <span>
          {{
            $t('absenceRequests.paginationSummary', {
              start: Math.min((page - 1) * pageSize + 1, total),
              end: Math.min(page * pageSize, total),
              total,
            })
          }}
        </span>
        <Pagination
          v-model:current="page"
          v-model:page-size="pageSize"
          :total="total"
          size="small"
          show-size-changer
          :page-size-options="['10', '20', '50']"
          @change="
            (p, ps) => {
              page = p;
              pageSize = ps;
              void loadRequests();
            }
          "
        />
      </div>
    </div>

    <!-- Leave Request Modal -->
    <AbsenceRequestFormModal
      v-model:open="createTimeoffOpen"
      :root-organization-id="formRootOrganizationId"
      :reviewer-users="reviewerUsers"
      :reviewer-users-loading="reviewerUsersLoading"
      :reviewer-users-load-error="reviewerUsersLoadError"
      :current-user-id="currentUserId"
      :editing-request="null"
      request-type="TIMEOFF"
      @balance-date-change="handleBalanceDateChange"
      :balance="balance"
      :balance-loading="balanceLoading"
      :balance-error="balanceError"
      :submitting="saving"
      @submit="handleSubmitForm"
    />

    <!-- Business Trip Request Modal -->
    <AbsenceRequestFormModal
      v-model:open="createBusinessTripOpen"
      :root-organization-id="formRootOrganizationId"
      :reviewer-users="reviewerUsers"
      :reviewer-users-loading="reviewerUsersLoading"
      :reviewer-users-load-error="reviewerUsersLoadError"
      :current-user-id="currentUserId"
      :editing-request="null"
      request-type="BUSINESS_TRIP"
      @balance-date-change="handleBalanceDateChange"
      :balance="balance"
      :balance-loading="balanceLoading"
      :balance-error="balanceError"
      :submitting="saving"
      @submit="handleSubmitForm"
    />

    <!-- Edit Request Modal -->
    <AbsenceRequestFormModal
      v-model:open="editOpen"
      :root-organization-id="formRootOrganizationId"
      :reviewer-users="reviewerUsers"
      :reviewer-users-loading="reviewerUsersLoading"
      :reviewer-users-load-error="reviewerUsersLoadError"
      :current-user-id="currentUserId"
      :editing-request="editingRequest"
      request-type="TIMEOFF"
      @balance-date-change="handleBalanceDateChange"
      :balance="balance"
      :balance-loading="balanceLoading"
      :balance-error="balanceError"
      :submitting="saving"
      @submit="handleSubmitForm"
    />

    <!-- Detail Modal -->
    <AbsenceRequestDetailModal
      v-model:open="detailOpen"
      :request="selectedRequest"
      :current-user-id="currentUserId"
      :has-review-permission="isApprover"
      :approving="approving"
      :rejecting="rejecting"
      :returning="returning"
      :deleting="deleting"
      @approve="handleApprove"
      @reject="handleReject"
      @return="handleReturn"
      @edit="handleEditRequest"
      @delete="handleDelete"
    />

    <!-- Quick Review Note Modal (Direct Reject / Return) -->
    <AbsenceRequestReviewNoteModal
      v-model:open="noteModalOpen"
      :request="noteModalRequest"
      :mode="noteModalMode"
      :loading="Boolean(actionLoadingId)"
      @submit="handleNoteModalSubmit"
    />
  </Page>
</template>

<style scoped>
.absence-request-tabs :deep(.ant-tabs-nav) {
  margin-bottom: 0;
}
</style>
