export type ItemKind = 'goods' | 'service';

export interface CatalogItem {
  id: string;
  code: string;
  name: string;
  kind: ItemKind;
  unit: string;
  status: 'active' | 'inactive';
}

export interface Unit {
  id: string;
  name: string;
}

export interface Purpose {
  id: string;
  name: string;
}

export interface Supplier {
  id: string;
  code: string;
  name: string;
  taxCode: string;
  contact: string;
  phone: string;
  status: 'active' | 'inactive';
}

export type ApprovalRole = 'ceo' | 'dept' | 'finance' | 'purchasing';

export interface ApprovalStep {
  role: ApprovalRole;
  approverName: string;
  /** Người tạo giữ vai trò ở cấp này → cây duyệt bỏ qua cấp này. */
  skipped?: boolean;
}

export interface ApprovalHistoryItem {
  action:
    | 'approved'
    | 'recalled'
    | 'rejected'
    | 'return_edit'
    | 'submitted'
    | 'system';
  actorName: string;
  role: string;
  comment?: string;
  timestamp: string;
}

export interface SupplierQuote {
  id: string;
  supplierId: string;
  supplierName: string;
  isNewSupplier?: boolean;
  unitPrice: number;
  quoteFile?: string;
}

export interface RequestLine {
  id: string;
  itemId: string;
  itemName: string;
  kind: ItemKind;
  spec: string;
  quantity: number;
  unit: string;
  purpose: string;
  neededDate: string;
  quotes: SupplierQuote[];
  /** Purchasing chọn ở bước duyệt. */
  selectedQuoteId?: string;
}

export type RequestStatus =
  | 'approved'
  | 'completed'
  | 'draft'
  | 'pending'
  | 'purchasing'
  | 'recalled'
  | 'rejected'
  | 'return_edit';

export interface PurchaseRequest {
  id: string;
  code: string;
  note: string;
  requesterName: string;
  department: string;
  createdAt: string;
  status: RequestStatus;
  /** Chỉ số bước đang chờ duyệt trong approvalSteps (khi status = pending). */
  currentStep: number;
  approvalSteps: ApprovalStep[];
  needContract: boolean;
  /** Purchasing đánh dấu ở bước duyệt, áp dụng cho cả phiếu. */
  requireInspection: boolean;
  attachments: string[];
  lines: RequestLine[];
  history: ApprovalHistoryItem[];
  returnReason?: string;
}

export interface OrderLine {
  id: string;
  requestLineId: string;
  itemName: string;
  kind: ItemKind;
  spec: string;
  unit: string;
  quantity: number;
  unitPrice: number;
  receivedQty: number;
  /** Đang có yêu cầu bổ sung chờ duyệt → tạm dừng giao nhận. */
  onHold?: boolean;
}

export interface OrderVersion {
  version: number;
  at: string;
  by: string;
  note: string;
}

export type PaymentKind = 'advance' | 'payment';

export interface OrderPayment {
  id: string;
  kind: PaymentKind;
  amount: number;
  createdAt: string;
  createdBy: string;
  note: string;
  /** Liên kết đề xuất bên Quỹ tiền mặt (mock). */
  cashProposalId?: string;
  cashProposalCode: string;
  /** Trạng thái tĩnh cho dữ liệu mẫu không liên kết Quỹ tiền mặt. */
  staticStatus?: PaymentStatus;
  rejectReason?: string;
}

export type PaymentStatus = 'completed' | 'pending' | 'rejected';

export interface PurchaseOrder {
  id: string;
  code: string;
  version: number;
  requestId: string;
  requestCode: string;
  supplierId: string;
  supplierName: string;
  requesterName: string;
  department: string;
  createdAt: string;
  issuedAt?: string;
  parentOrderCode?: string;
  lines: OrderLine[];
  payments: OrderPayment[];
  versions: OrderVersion[];
}

export type OrderStatus =
  | 'awaiting_payment'
  | 'completed'
  | 'in_progress'
  | 'not_issued';

export type DeliveryStatus =
  | 'confirmed'
  | 'purchasing_check'
  | 'reported_issue'
  | 'requester_check';

export interface DeliveryLine {
  orderLineId: string;
  itemName: string;
  unit: string;
  deliveredQty: number;
  /** Số lượng đạt sau kiểm tra của Purchasing (nếu có). */
  passedQty?: number;
  /** Số lượng Người đề xuất xác nhận nhận. */
  acceptedQty?: number;
}

export interface DeliveryEvent {
  actorName: string;
  role: string;
  action: string;
  comment?: string;
  timestamp: string;
}

export interface DeliveryBatch {
  id: string;
  code: string;
  orderId: string;
  orderCode: string;
  requestId: string;
  supplierName: string;
  requesterName: string;
  deliveredAt: string;
  documents: string[];
  status: DeliveryStatus;
  lines: DeliveryLine[];
  events: DeliveryEvent[];
}

export type ChangeKind = 'add' | 'quantity' | 'supplier';

export interface ChangeLine {
  id: string;
  kind: ChangeKind;
  orderLineId?: string;
  itemName: string;
  unit: string;
  currentQty: number;
  newQty: number;
  currentSupplier: string;
  newSupplierId?: string;
  newSupplierName?: string;
  unitPrice: number;
}

export type ChangeStatus = 'approved' | 'pending' | 'rejected' | 'return_edit';

export interface ChangeRequest {
  id: string;
  code: string;
  orderId: string;
  orderCode: string;
  requestId: string;
  requestCode: string;
  requesterName: string;
  department: string;
  createdAt: string;
  reason: string;
  status: ChangeStatus;
  currentStep: number;
  approvalSteps: ApprovalStep[];
  lines: ChangeLine[];
  history: ApprovalHistoryItem[];
}
