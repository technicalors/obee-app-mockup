<script setup lang="ts">
import type { CashTransaction } from '../../types';

import { computed } from 'vue';

import {
  Badge,
  Button,
  Descriptions,
  Modal,
  Table,
  Tag,
} from 'ant-design-vue';

import { $t } from '#/locales';

const props = defineProps<{
  open: boolean;
  transaction: CashTransaction | null;
}>();

const emit = defineEmits<{
  (e: 'update:open', val: boolean): void;
}>();

const visible = computed({
  get: () => props.open,
  set: (val) => emit('update:open', val),
});

const itemColumns = [
  {
    title: 'STT',
    key: 'index',
    width: 48,
    align: 'center' as const,
    customRender: ({ index }: { index: number }) => index + 1,
  },
  {
    title: 'Khoản mục',
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
    title: 'Số tiền',
    dataIndex: 'amount',
    key: 'amount',
    width: 150,
    align: 'right' as const,
  },
];
</script>

<template>
  <Modal
    v-model:open="visible"
    :title="$t('cashFund.transactions.detailTitle')"
    width="980px"
    destroy-on-close
    :footer="null"
  >
    <div v-if="transaction" class="flex flex-col gap-5 py-2">
      <!-- Voucher Header -->
      <div class="flex flex-wrap items-center justify-between gap-4 rounded-lg bg-muted/20 p-4 border border-border">
        <div class="flex flex-col gap-1">
          <div class="flex items-center gap-2">
            <Tag class="font-medium">
              {{ transaction.type === 'expense' ? 'PHIẾU CHI' : 'PHIẾU THU' }}
            </Tag>
            <span class="font-mono text-base font-bold text-foreground">{{ transaction.code }}</span>
          </div>
          <p class="m-0 text-xs text-muted-foreground">
            Mã đề xuất liên kết: <strong class="font-mono text-foreground">{{ transaction.proposalCode }}</strong>
          </p>
        </div>

        <div class="text-right">
          <div class="text-xs text-muted-foreground">Số tiền giao dịch</div>
          <div class="text-2xl font-semibold text-foreground">
            {{ transaction.amount.toLocaleString() }} {{ transaction.currency }}
          </div>
        </div>
      </div>

      <!-- Information Descriptions -->
      <Descriptions bordered size="small" :column="{ xs: 1, sm: 2 }">
        <Descriptions.Item label="Nguồn tiền">
          <span class="font-medium text-foreground">{{ transaction.sourceName }}</span>
        </Descriptions.Item>
        <Descriptions.Item :label="transaction.type === 'expense' ? 'Người nhận tiền' : 'Người nộp tiền'">
          <span class="font-medium text-foreground">{{ transaction.counterpartName }}</span>
        </Descriptions.Item>
        <Descriptions.Item label="Ngày phát sinh">
          {{ transaction.issuedDate }}
        </Descriptions.Item>
        <Descriptions.Item label="Trạng thái">
          <Badge
            :status="transaction.status === 'completed' ? 'success' : transaction.status === 'pending' ? 'processing' : 'default'"
            :text="transaction.status === 'completed' ? 'Đã thực hiện' : transaction.status === 'pending' ? 'Chờ thực hiện' : 'Đã hủy'"
          />
        </Descriptions.Item>
        <Descriptions.Item label="Phương thức">
          {{ transaction.paymentMethod === 'cash' ? 'Tiền mặt' : 'Chuyển khoản nội bộ quỹ' }}
        </Descriptions.Item>
        <Descriptions.Item label="Ngày thực hiện">
          {{ transaction.completedDate || 'Chưa thực hiện' }}
        </Descriptions.Item>
        <Descriptions.Item label="Thủ quỹ thực hiện">
          {{ transaction.performedBy || 'Chưa thực hiện' }}
        </Descriptions.Item>
        <Descriptions.Item label="Người ký xác nhận">
          {{ transaction.signedBy || 'Chưa ký' }}
        </Descriptions.Item>
        <Descriptions.Item label="Nội dung diễn giải" :span="2">
          {{ transaction.description }}
        </Descriptions.Item>
      </Descriptions>

      <!-- Items Table -->
      <div v-if="transaction.items && transaction.items.length > 0">
        <div class="text-xs font-semibold uppercase tracking-wider text-muted-foreground mb-2">
          Chi tiết các khoản của chứng từ
        </div>
        <Table
          :data-source="transaction.items"
          :columns="itemColumns"
          :pagination="false"
          :scroll="{ x: 750 }"
          size="small"
          row-key="id"
        >
          <template #bodyCell="{ column, record }">
            <template v-if="column.key === 'amount'">
              <span class="font-medium text-foreground">
                {{ record.amount.toLocaleString() }} {{ record.currency }}
              </span>
            </template>
          </template>
        </Table>
      </div>

      <div class="flex justify-end pt-2">
        <Button @click="visible = false">
          {{ $t('cashFund.proposals.modal.close') }}
        </Button>
      </div>
    </div>
  </Modal>
</template>
