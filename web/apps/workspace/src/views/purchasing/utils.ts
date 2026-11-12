import type {
  ApprovalHistoryItem,
  ApprovalRole,
  ChangeKind,
  ChangeStatus,
  DeliveryStatus,
  ItemKind,
  OrderStatus,
  PaymentKind,
  PaymentStatus,
  RequestStatus,
} from './types';

export interface TagMeta {
  color: string;
  text: string;
}

export const ROLE_LABELS: Record<ApprovalRole, string> = {
  ceo: 'CEO',
  dept: 'Trưởng bộ phận',
  finance: 'Tài chính',
  purchasing: 'Purchasing',
};

export const ROLE_ORDER: ApprovalRole[] = [
  'dept',
  'purchasing',
  'finance',
  'ceo',
];

export const REQUEST_STATUS: Record<RequestStatus, TagMeta> = {
  approved: { color: 'cyan', text: 'Đã duyệt' },
  completed: { color: 'success', text: 'Hoàn thành' },
  draft: { color: 'default', text: 'Nháp' },
  pending: { color: 'processing', text: 'Chờ duyệt' },
  purchasing: { color: 'blue', text: 'Đang mua hàng' },
  recalled: { color: 'default', text: 'Đã thu hồi' },
  rejected: { color: 'error', text: 'Từ chối' },
  return_edit: { color: 'warning', text: 'Yêu cầu điều chỉnh' },
};

export const ORDER_STATUS: Record<OrderStatus, TagMeta> = {
  awaiting_payment: { color: 'orange', text: 'Chờ thanh toán' },
  completed: { color: 'success', text: 'Hoàn thành' },
  in_progress: { color: 'processing', text: 'Đang thực hiện' },
  not_issued: { color: 'default', text: 'Chờ phát hành' },
};

export const DELIVERY_STATUS: Record<DeliveryStatus, TagMeta> = {
  confirmed: { color: 'success', text: 'Đã xác nhận nhận' },
  purchasing_check: { color: 'purple', text: 'Chờ Purchasing kiểm tra' },
  reported_issue: { color: 'error', text: 'Báo lỗi - trả NCC' },
  requester_check: { color: 'processing', text: 'Chờ người đề xuất kiểm tra' },
};

export const CHANGE_STATUS: Record<ChangeStatus, TagMeta> = {
  approved: { color: 'success', text: 'Đã duyệt' },
  pending: { color: 'processing', text: 'Chờ duyệt' },
  rejected: { color: 'error', text: 'Từ chối' },
  return_edit: { color: 'warning', text: 'Yêu cầu điều chỉnh' },
};

export const CHANGE_KIND: Record<ChangeKind, string> = {
  add: 'Thêm mặt hàng',
  quantity: 'Đổi số lượng',
  supplier: 'Đổi NCC phần còn lại',
};

export const PAYMENT_STATUS: Record<PaymentStatus, TagMeta> = {
  completed: { color: 'success', text: 'Đã thanh toán' },
  pending: { color: 'processing', text: 'Đang xử lý tại Quỹ' },
  rejected: { color: 'error', text: 'Bị từ chối' },
};

export const PAYMENT_KIND: Record<PaymentKind, string> = {
  advance: 'Ứng trước',
  payment: 'Thanh toán',
};

export const KIND_LABELS: Record<ItemKind, string> = {
  goods: 'Hàng hóa',
  service: 'Dịch vụ',
};

export const HISTORY_COLOR: Record<ApprovalHistoryItem['action'], string> = {
  approved: 'green',
  recalled: 'gray',
  rejected: 'red',
  return_edit: 'orange',
  submitted: 'blue',
  system: 'gray',
};

export const HISTORY_LABEL: Record<ApprovalHistoryItem['action'], string> = {
  approved: 'Duyệt',
  recalled: 'Thu hồi',
  rejected: 'Từ chối',
  return_edit: 'Yêu cầu điều chỉnh',
  submitted: 'Gửi duyệt',
  system: 'Hệ thống',
};

export function money(value: number) {
  return `${Math.round(value).toLocaleString('vi-VN')} ₫`;
}

export function num(value: number) {
  return value.toLocaleString('vi-VN');
}

export function nowText() {
  const d = new Date();
  const pad = (n: number) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

export function todayText() {
  return nowText().slice(0, 10);
}
