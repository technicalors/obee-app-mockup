export type ProposalType = 'advance' | 'payment' | 'receipt' | 'settlement';

export type ProposalStatus =
  | 'draft'
  | 'pending'
  | 'pending_dept'
  | 'pending_accountant'
  | 'pending_cfo'
  | 'pending_ceo'
  | 'approved'
  | 'voucher_issued'
  | 'pending_sign'
  | 'completed'
  | 'return_edit'
  | 'rejected'
  | 'canceled';

export interface ProposalItem {
  id: string;
  categoryId: string;
  categoryName: string;
  categoryType: 'expense' | 'receipt';
  reason: string;
  expectedDate: string;
  amount: number;
  actualAmount?: number;
  currency: string;
  exchangeRate?: number;
  attachmentName?: string;
  attachmentUrl?: string;
  attachmentSize?: string;
}

export interface ApprovalHistoryItem {
  step: number;
  role: string;
  approverName: string;
  action:
    | 'approved'
    | 'completed'
    | 'rejected'
    | 'return_edit'
    | 'signed'
    | 'submitted';
  actionLabel: string;
  comment?: string;
  timestamp: string;
}

export interface Proposal {
  id: string;
  code: string;
  type: ProposalType;
  title: string;
  applicantId: string;
  applicantName: string;
  applicantAvatar?: string;
  department: string;
  company: string;
  createdAt: string;
  totalAmount: number;
  currency: string;
  status: ProposalStatus;
  currentApprover: string;
  advanceProposalId?: string;
  advanceOriginalAmount?: number;
  settlementDifference?: number;
  returnReason?: string;
  returnedBy?: string;
  returnedAt?: string;
  items: ProposalItem[];
  approvalHistory: ApprovalHistoryItem[];
}

export type VoucherType = 'expense' | 'receipt';
export type VoucherStatus = 'canceled' | 'completed' | 'pending';

export interface CashTransaction {
  id: string;
  code: string;
  proposalId: string;
  proposalCode: string;
  type: VoucherType;
  sourceId: string;
  sourceName: string;
  counterpartName: string;
  counterpartType: 'external' | 'internal';
  amount: number;
  actualAmount: number;
  currency: string;
  issuedDate: string;
  completedDate?: string;
  status: VoucherStatus;
  description: string;
  performedBy?: string;
  signedBy?: string;
  paymentMethod: 'cash' | 'internal_transfer';
  items: ProposalItem[];
}

export type AdjustmentStatus =
  | 'approved'
  | 'completed'
  | 'pending'
  | 'pending_accountant'
  | 'pending_cfo'
  | 'pending_final_ceo'
  | 'pending_source_ceo'
  | 'rejected'
  | 'return_edit';

export interface FundAdjustment {
  id: string;
  code: string;
  fromSourceId: string;
  fromSourceName: string;
  fromCompany: string;
  toSourceId: string;
  toSourceName: string;
  toCompany: string;
  amount: number;
  currency: string;
  status: AdjustmentStatus;
  requestDate: string;
  effectiveDate: string;
  reason: string;
  attachmentName: string;
  attachmentSize?: string;
  currentStep: string;
  currentApprover: string;
  approvalHistory: ApprovalHistoryItem[];
}

export interface MasterCategory {
  id: string;
  code: string;
  name: string;
  type: 'expense' | 'receipt';
  group: string;
  description: string;
  createdAt: string;
  status: 'active' | 'inactive';
}

export interface FundSource {
  id: string;
  code: string;
  name: string;
  company: string;
  currency: string;
  initialBalance: number;
  currentBalance: number;
  status: 'active' | 'inactive' | 'locked';
}

export interface Currency {
  code: string;
  name: string;
  symbol: string;
  exchangeRate: number;
  isDefault: boolean;
  status: 'active' | 'inactive';
}
