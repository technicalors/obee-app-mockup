<script setup lang="ts">
import type { Proposal } from '../../types';

import { computed } from 'vue';

import { IconifyIcon } from '@vben/icons';

import {
  Button,
  Card,
  Descriptions,
  Modal,
  Table,
  Tag,
  Timeline,
} from 'ant-design-vue';

import { $t } from '#/locales';

const props = defineProps<{
  open: boolean;
  proposal: null | Proposal;
}>();

const emit = defineEmits<{
  (e: 'update:open', val: boolean): void;
}>();

const visible = computed({
  get: () => props.open,
  set: (val) => emit('update:open', val),
});

function getStatusTag(status: string) {
  switch (status) {
    case 'completed': {
      return { color: 'success', text: $t('cashFund.proposals.statusLabels.completed') };
    }
    case 'approved': {
      return { color: 'processing', text: $t('cashFund.proposals.statusLabels.approved') };
    }
    case 'voucher_issued': {
      return { color: 'cyan', text: $t('cashFund.proposals.statusLabels.voucher_issued') };
    }
    case 'return_edit': {
      return { color: 'warning', text: $t('cashFund.proposals.statusLabels.return_edit') };
    }
    case 'rejected': {
      return { color: 'error', text: $t('cashFund.proposals.statusLabels.rejected') };
    }
    case 'canceled': {
      return { color: 'default', text: $t('cashFund.proposals.statusLabels.canceled') };
    }
    case 'draft': {
      return { color: 'default', text: $t('cashFund.proposals.statusLabels.draft') };
    }
    default: {
      return {
        color: 'processing',
        text: $t(`cashFund.proposals.statusLabels.${status}`) || status,
      };
    }
  }
}

function getTypeTag(type: string) {
  switch (type) {
    case 'advance': {
      return { color: '', text: $t('cashFund.proposals.types.advance') };
    }
    case 'payment': {
      return { color: '', text: $t('cashFund.proposals.types.payment') };
    }
    case 'receipt': {
      return { color: '', text: $t('cashFund.proposals.types.receipt') };
    }
    case 'settlement': {
      return { color: '', text: $t('cashFund.proposals.types.settlement') };
    }
    default: {
      return { color: '', text: type };
    }
  }
}

const hasForeignCurrency = computed(() => {
  return props.proposal?.items.some((i) => i.currency && i.currency !== 'VND');
});

const itemColumns = computed(() => {
  const isSettlement = props.proposal?.type === 'settlement';
  const hasFx = hasForeignCurrency.value;

  const cols: any[] = [
    {
      title: 'STT',
      key: 'index',
      width: 48,
      align: 'center' as const,
      customRender: ({ index }: { index: number }) => index + 1,
    },
    {
      title: 'Khoản thu / chi',
      dataIndex: 'categoryName',
      key: 'categoryName',
      width: 170,
    },
    {
      title: 'Lý do / Diễn giải',
      dataIndex: 'reason',
      key: 'reason',
      minWidth: 320,
    },
    {
      title: 'Ngày mong muốn',
      dataIndex: 'expectedDate',
      key: 'expectedDate',
      width: 120,
    },
    {
      title: 'Số tiền',
      dataIndex: 'amount',
      key: 'amount',
      width: 130,
      align: 'right' as const,
      customRender: ({ text }: any) => text?.toLocaleString(),
    },
    {
      title: 'Loại tiền',
      dataIndex: 'currency',
      key: 'currency',
      width: 85,
      align: 'center' as const,
      customRender: ({ text, record }: any) => text || record.currency || props.proposal?.currency || 'VND',
    },
  ];

  if (hasFx) {
    cols.push({
      title: 'Tỷ giá',
      key: 'exchangeRate',
      width: 95,
      align: 'right' as const,
    });
  }

  if (isSettlement) {
    cols.push({
      title: 'Tiền thực tế',
      dataIndex: 'actualAmount',
      key: 'actualAmount',
      width: 130,
      align: 'right' as const,
    });
  }

  cols.push({
    title: 'Chứng từ',
    key: 'attachment',
    width: 140,
  });

  return cols;
});

function handlePrint() {
  window.print();
}
</script>

<template>
  <Modal
    v-model:open="visible"
    :title="$t('cashFund.proposals.modal.detailTitle')"
    width="1050px"
    :footer="null"
    destroy-on-close
  >
    <div v-if="proposal" class="flex flex-col gap-6 py-2">
      <!-- Header Banner -->
      <div
        class="flex flex-wrap items-center justify-between gap-4 rounded-lg bg-muted/40 p-4 border border-border"
      >
        <div class="flex flex-col gap-1">
          <div class="flex items-center gap-2">
            <span class="text-xs font-semibold text-muted-foreground uppercase tracking-wider">
              {{ $t('cashFund.proposals.code') }}:
            </span>
            <span class="text-base font-bold text-foreground font-mono">
              {{ proposal.code }}
            </span>
            <Tag :color="getTypeTag(proposal.type).color">
              {{ getTypeTag(proposal.type).text }}
            </Tag>
          </div>
          <h3 class="m-0 text-base font-medium text-foreground">
            {{ proposal.title }}
          </h3>
        </div>

        <div class="flex flex-col items-end gap-1">
          <Tag :color="getStatusTag(proposal.status).color" class="m-0 font-normal">
            {{ getStatusTag(proposal.status).text }}
          </Tag>
          <div class="text-xl font-bold text-primary">
            {{ proposal.totalAmount.toLocaleString() }} {{ proposal.currency }}
          </div>
        </div>
      </div>

      <!-- Return Edit Alert if applicable -->
      <div
        v-if="proposal.status === 'return_edit' && proposal.returnReason"
        class="rounded-lg border border-border bg-muted/30 p-3.5"
      >
        <div class="flex items-start gap-2.5">
          <IconifyIcon icon="lucide:alert-circle" class="size-4 text-muted-foreground mt-0.5 shrink-0" />
          <div class="flex flex-col gap-1 text-xs">
            <span class="font-semibold text-foreground">
              Yêu cầu chỉnh sửa từ {{ proposal.returnedBy || 'Người phê duyệt' }} ({{ proposal.returnedAt }})
            </span>
            <p class="m-0 text-muted-foreground">
              {{ proposal.returnReason }}
            </p>
          </div>
        </div>
      </div>

      <!-- General Info -->
      <Card size="small" :title="$t('cashFund.proposals.modal.generalInfo')" :bordered="false" class="bg-muted/10 border border-border">
        <Descriptions :column="{ xs: 1, sm: 2, md: 3 }" size="small">
          <Descriptions.Item :label="$t('cashFund.proposals.applicant')">
            <span class="font-medium text-foreground">{{ proposal.applicantName }}</span>
          </Descriptions.Item>
          <Descriptions.Item :label="$t('cashFund.proposals.department')">
            {{ proposal.department }}
          </Descriptions.Item>
          <Descriptions.Item label="Công ty">
            {{ proposal.company }}
          </Descriptions.Item>
          <Descriptions.Item :label="$t('cashFund.proposals.createdAt')">
            {{ proposal.createdAt }}
          </Descriptions.Item>
          <Descriptions.Item label="Người xử lý hiện tại">
            <span class="font-medium text-primary">{{ proposal.currentApprover }}</span>
          </Descriptions.Item>
          <Descriptions.Item :label="$t('cashFund.proposals.currency')">
            {{ proposal.currency }}
          </Descriptions.Item>
        </Descriptions>

        <!-- Settlement specific info -->
        <div
          v-if="proposal.type === 'settlement'"
          class="mt-4 rounded-md border border-border bg-muted/20 p-3 text-xs"
        >
          <div class="grid grid-cols-1 gap-3 sm:grid-cols-3">
            <div>
              <span class="text-muted-foreground block">
                {{ $t('cashFund.proposals.modal.originalAdvanceAmount') }}:
              </span>
              <span class="font-semibold text-foreground">
                {{ (proposal.advanceOriginalAmount ?? 0).toLocaleString() }} {{ proposal.currency }}
              </span>
            </div>
            <div>
              <span class="text-muted-foreground block">
                {{ $t('cashFund.proposals.modal.actualExpense') }}:
              </span>
              <span class="font-semibold text-foreground">
                {{ proposal.totalAmount.toLocaleString() }} {{ proposal.currency }}
              </span>
            </div>
            <div>
              <span class="text-muted-foreground block">
                {{ $t('cashFund.proposals.modal.difference') }}:
              </span>
              <span class="font-semibold text-foreground">
                {{ (proposal.settlementDifference ?? 0) > 0 ? '+' : '' }}
                {{ (proposal.settlementDifference ?? 0).toLocaleString() }} {{ proposal.currency }}
                <span class="font-normal text-muted-foreground ml-1">
                  ({{
                    (proposal.settlementDifference ?? 0) > 0
                      ? $t('cashFund.proposals.modal.additionalAdvice')
                      : (proposal.settlementDifference ?? 0) < 0
                        ? $t('cashFund.proposals.modal.refundAdvice')
                        : $t('cashFund.proposals.modal.balancedAdvice')
                  }})
                </span>
              </span>
            </div>
          </div>
        </div>
      </Card>

      <!-- Line Items Table -->
      <Card size="small" :title="$t('cashFund.proposals.modal.itemDetails')" :bordered="false" class="border border-border">
        <Table
          :data-source="proposal.items"
          :columns="itemColumns"
          :pagination="false"
          :scroll="{ x: 950 }"
          size="middle"
          row-key="id"
        >
          <template #bodyCell="{ column, record }">
            <template v-if="column.key === 'exchangeRate'">
              <span v-if="record.currency && record.currency !== 'VND' && record.exchangeRate" class="font-mono text-xs">
                {{ record.exchangeRate.toLocaleString() }}
              </span>
              <span v-else class="text-muted-foreground text-xs">-</span>
            </template>
            <template v-else-if="column.key === 'actualAmount'">
              <span class="font-medium text-foreground">
                {{ record.actualAmount !== undefined ? record.actualAmount.toLocaleString() : '-' }}
              </span>
            </template>
            <template v-else-if="column.key === 'attachment'">
              <div v-if="record.attachmentName" class="flex items-center gap-1.5 text-xs text-primary cursor-pointer hover:underline">
                <IconifyIcon icon="lucide:file-text" class="size-3.5 shrink-0" />
                <span class="truncate max-w-[120px]" :title="record.attachmentName">
                  {{ record.attachmentName }}
                </span>
              </div>
              <span v-else class="text-muted-foreground text-xs italic">Không có</span>
            </template>
          </template>

          <template #summary>
            <Table.Summary fixed>
              <Table.Summary.Row class="bg-muted/30 font-semibold">
                <Table.Summary.Cell :index="0" :col-span="4" align="right">
                  Tổng cộng:
                </Table.Summary.Cell>
                <Table.Summary.Cell :index="1" align="right">
                  <span class="text-foreground">
                    {{ proposal.totalAmount.toLocaleString() }}
                  </span>
                </Table.Summary.Cell>
                <Table.Summary.Cell :index="2" align="center">
                  <span class="text-foreground">
                    {{ proposal.currency }}
                  </span>
                </Table.Summary.Cell>
                <Table.Summary.Cell v-if="hasForeignCurrency" :index="3" align="right">
                  -
                </Table.Summary.Cell>
                <Table.Summary.Cell v-if="proposal.type === 'settlement'" :index="4" align="right">
                  <span class="text-foreground font-semibold">
                    {{
                      proposal.items
                        .reduce((acc: number, i: any) => acc + (i.actualAmount ?? i.amount), 0)
                        .toLocaleString()
                    }}
                  </span>
                </Table.Summary.Cell>
                <Table.Summary.Cell :index="5" />
              </Table.Summary.Row>
            </Table.Summary>
          </template>
        </Table>
      </Card>

      <!-- Approval History Timeline -->
      <Card size="small" :title="$t('cashFund.proposals.modal.approvalHistory')" :bordered="false" class="border border-border">
        <div v-if="proposal.approvalHistory.length === 0" class="py-4 text-center text-sm text-muted-foreground">
          Chưa có lịch sử phê duyệt (Hồ sơ ở trạng thái nháp).
        </div>
        <Timeline v-else class="mt-2 pl-2">
          <Timeline.Item
            v-for="(hist, idx) in proposal.approvalHistory"
            :key="idx"
            :color="
              hist.action === 'approved' || hist.action === 'completed'
                ? 'green'
                : hist.action === 'return_edit'
                  ? 'orange'
                  : hist.action === 'rejected'
                    ? 'red'
                    : 'blue'
            "
          >
            <div class="flex flex-col gap-1">
              <div class="flex flex-wrap items-center gap-2">
                <span class="font-semibold text-foreground text-sm">
                  {{ hist.approverName }}
                </span>
                <Tag class="text-xs font-normal">
                  {{ hist.role }}
                </Tag>
                <Tag
                  :color="
                    hist.action === 'approved' || hist.action === 'completed'
                      ? 'success'
                      : hist.action === 'return_edit'
                        ? 'warning'
                        : hist.action === 'rejected'
                          ? 'error'
                          : 'processing'
                  "
                >
                  {{ hist.actionLabel }}
                </Tag>
                <span class="text-xs text-muted-foreground font-mono ml-auto">
                  {{ hist.timestamp }}
                </span>
              </div>
              <p v-if="hist.comment" class="m-0 text-xs text-muted-foreground bg-muted/40 rounded p-2 border border-border/50">
                "{{ hist.comment }}"
              </p>
            </div>
          </Timeline.Item>
        </Timeline>
      </Card>

      <div class="flex items-center justify-end gap-2 pt-2 border-t border-border">
        <Button @click="handlePrint">
          <template #icon>
            <IconifyIcon icon="lucide:printer" class="size-4" />
          </template>
          In đề xuất
        </Button>
        <Button @click="visible = false">
          {{ $t('cashFund.proposals.modal.close') }}
        </Button>
      </div>
    </div>
  </Modal>
</template>
