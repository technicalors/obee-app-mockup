import { ref } from 'vue';

import {
  initialAdjustments,
  initialCategories,
  initialCurrencies,
  initialFundSources,
  initialProposals,
  initialTransactions,
} from './mock-data';
import type {
  CashTransaction,
  Currency,
  FundAdjustment,
  FundSource,
  MasterCategory,
  Proposal,
  ProposalItem,
  ProposalStatus,
  ProposalType,
} from './types';

const proposals = ref<Proposal[]>(JSON.parse(JSON.stringify(initialProposals)));
const transactions = ref<CashTransaction[]>(
  JSON.parse(JSON.stringify(initialTransactions)),
);
const adjustments = ref<FundAdjustment[]>(
  JSON.parse(JSON.stringify(initialAdjustments)),
);
const categories = ref<MasterCategory[]>(
  JSON.parse(JSON.stringify(initialCategories)),
);
const fundSources = ref<FundSource[]>(
  JSON.parse(JSON.stringify(initialFundSources)),
);
const currencies = ref<Currency[]>(
  JSON.parse(JSON.stringify(initialCurrencies)),
);

export function useCashFund() {
  function getProposalById(id: string) {
    return proposals.value.find((p) => p.id === id);
  }

  function getTransactionById(id: string) {
    return transactions.value.find((t) => t.id === id);
  }

  function getAdjustmentById(id: string) {
    return adjustments.value.find((a) => a.id === id);
  }

  function generateCode(prefix: string) {
    const today = new Date();
    const yyyymm = `${today.getFullYear()}${String(today.getMonth() + 1).padStart(2, '0')}`;
    const random = Math.floor(100 + Math.random() * 900);
    return `${prefix}-${yyyymm}-${random}`;
  }

  function addProposal(payload: {
    advanceProposalId?: string;
    items: ProposalItem[];
    status?: ProposalStatus;
    title: string;
    type: ProposalType;
  }) {
    const code = generateCode('DX');
    const firstCurr = payload.items[0]?.currency || 'VND';
    const isMixed = payload.items.some((i) => i.currency !== firstCurr);
    const propCurrency = isMixed ? 'VND' : firstCurr;
    const total = payload.items.reduce((sum, item) => {
      const rate = item.currency === 'VND' ? 1 : item.exchangeRate || 1;
      return sum + (isMixed ? (item.amount || 0) * rate : item.amount || 0);
    }, 0);
    const now = new Date().toISOString().replace('T', ' ').substring(0, 16);

    let advanceOriginalAmount: number | undefined;
    let settlementDifference: number | undefined;

    if (payload.type === 'settlement' && payload.advanceProposalId) {
      const orig = proposals.value.find((p) => p.id === payload.advanceProposalId);
      if (orig) {
        advanceOriginalAmount = orig.totalAmount;
        const totalActual = payload.items.reduce(
          (sum, i) => sum + (i.actualAmount !== undefined ? i.actualAmount : i.amount),
          0,
        );
        settlementDifference = totalActual - advanceOriginalAmount;
      }
    }

    const newProposal: Proposal = {
      advanceOriginalAmount,
      advanceProposalId: payload.advanceProposalId,
      applicantId: 'user-curr',
      applicantName: 'Nguyễn Văn Nam',
      company: 'Công ty Cổ phần Obee Tech',
      createdAt: now,
      currency: propCurrency,
      currentApprover:
        payload.status === 'draft' ? 'Chưa gửi' : 'Trần Minh Đức (Trưởng BP)',
      department: 'Phòng Phát triển Kinh doanh',
      id: `prop-${Date.now()}`,
      items: payload.items,
      settlementDifference,
      status: payload.status || 'pending_dept',
      title: payload.title,
      totalAmount: total,
      type: payload.type,
      code,
      approvalHistory:
        payload.status === 'draft'
          ? []
          : [
              {
                action: 'submitted',
                actionLabel: 'Gửi phê duyệt',
                approverName: 'Nguyễn Văn Nam',
                role: 'Người đề nghị',
                step: 1,
                timestamp: now,
              },
            ],
    };

    proposals.value.unshift(newProposal);
    return newProposal;
  }

  function resubmitProposal(
    id: string,
    payload: { items: ProposalItem[]; title: string },
  ) {
    const proposal = proposals.value.find((p) => p.id === id);
    if (!proposal) return;

    const now = new Date().toISOString().replace('T', ' ').substring(0, 16);
    const total = payload.items.reduce((sum, item) => sum + (item.amount || 0), 0);

    proposal.title = payload.title;
    proposal.items = payload.items;
    proposal.totalAmount = total;
    proposal.status = 'pending_dept';
    proposal.currentApprover = 'Trần Minh Đức (Trưởng BP)';
    proposal.returnReason = undefined;
    proposal.returnedBy = undefined;
    proposal.returnedAt = undefined;

    proposal.approvalHistory.push({
      action: 'submitted',
      actionLabel: 'Gửi lại phê duyệt (Khởi động lại luồng)',
      approverName: proposal.applicantName,
      comment: 'Đã hoàn thiện hồ sơ và gửi lại duyệt từ đầu theo yêu cầu.',
      role: 'Người đề nghị',
      step: proposal.approvalHistory.length + 1,
      timestamp: now,
    });
  }

  function approveProposal(id: string, comment = '') {
    const proposal = proposals.value.find((p) => p.id === id);
    if (!proposal) return;

    const now = new Date().toISOString().replace('T', ' ').substring(0, 16);
    const step = proposal.approvalHistory.length + 1;

    if (proposal.status === 'pending_dept') {
      proposal.status = 'pending_accountant';
      proposal.currentApprover = 'Lê Thu Hà (Kế toán)';
      proposal.approvalHistory.push({
        action: 'approved',
        actionLabel: 'Trưởng BP phê duyệt',
        approverName: 'Trần Minh Đức',
        comment: comment || 'Đồng ý đề xuất của nhân viên.',
        role: 'Trưởng bộ phận',
        step,
        timestamp: now,
      });
    } else if (proposal.status === 'pending_accountant') {
      proposal.status = 'pending_cfo';
      proposal.currentApprover = 'Nguyễn Thị Bích (CFO)';
      proposal.approvalHistory.push({
        action: 'approved',
        actionLabel: 'Kế toán xác nhận',
        approverName: 'Lê Thu Hà',
        comment: comment || 'Hồ sơ đầy đủ chứng từ hợp lệ, chọn nguồn Quỹ tiền mặt VP.',
        role: 'Kế toán thanh toán',
        step,
        timestamp: now,
      });
    } else if (proposal.status === 'pending_cfo') {
      // CFO approves -> moves to voucher issued
      proposal.status = 'voucher_issued';
      proposal.currentApprover = 'Đỗ Thị Lan (Thủ quỹ)';
      proposal.approvalHistory.push({
        action: 'approved',
        actionLabel: 'CFO phê duyệt',
        approverName: 'Nguyễn Thị Bích',
        comment: comment || 'Phê duyệt giải ngân / thu quỹ theo quy định.',
        role: 'CFO',
        step,
        timestamp: now,
      });

      // Automatically issue cash voucher
      issueVoucherForProposal(proposal);
    }
  }

  function issueVoucherForProposal(proposal: Proposal) {
    const now = new Date().toISOString().replace('T', ' ').substring(0, 16);
    let vType: 'expense' | 'receipt' = 'expense';
    let vAmount = proposal.totalAmount;

    if (proposal.type === 'receipt') {
      vType = 'receipt';
    } else if (proposal.type === 'settlement') {
      const diff = proposal.settlementDifference ?? 0;
      if (diff > 0) {
        vType = 'expense';
        vAmount = diff;
      } else if (diff < 0) {
        vType = 'receipt';
        vAmount = Math.abs(diff);
      } else {
        // Balanced settlement: mark proposal completed directly
        proposal.status = 'completed';
        proposal.currentApprover = 'Đã hoàn tất';
        return;
      }
    }

    const code = generateCode(vType === 'expense' ? 'PC' : 'PT');
    const newTx: CashTransaction = {
      actualAmount: vAmount,
      amount: vAmount,
      counterpartName: proposal.applicantName,
      counterpartType: 'internal',
      currency: proposal.currency,
      description: `${vType === 'expense' ? 'Chi' : 'Thu'} theo đề xuất ${proposal.code}: ${proposal.title}`,
      id: `tx-${Date.now()}`,
      issuedDate: now,
      items: proposal.items,
      paymentMethod: 'cash',
      proposalCode: proposal.code,
      proposalId: proposal.id,
      sourceId: 'src-01',
      sourceName: 'Quỹ tiền mặt VP Hà Nội',
      status: 'pending',
      type: vType,
      code,
    };

    transactions.value.unshift(newTx);
  }

  function returnEditProposal(id: string, reason: string) {
    const proposal = proposals.value.find((p) => p.id === id);
    if (!proposal) return;

    const now = new Date().toISOString().replace('T', ' ').substring(0, 16);
    proposal.status = 'return_edit';
    proposal.returnReason = reason;
    proposal.returnedBy = 'Người phê duyệt hiện tại';
    proposal.returnedAt = now;
    proposal.currentApprover = `${proposal.applicantName} (Cần chỉnh sửa)`;

    proposal.approvalHistory.push({
      action: 'return_edit',
      actionLabel: 'Yêu cầu chỉnh sửa',
      approverName: 'Lê Thu Hà (Kế toán)',
      comment: reason,
      role: 'Người phê duyệt',
      step: proposal.approvalHistory.length + 1,
      timestamp: now,
    });
  }

  function rejectProposal(id: string, reason: string) {
    const proposal = proposals.value.find((p) => p.id === id);
    if (!proposal) return;

    const now = new Date().toISOString().replace('T', ' ').substring(0, 16);
    proposal.status = 'rejected';
    proposal.returnReason = reason;
    proposal.currentApprover = 'Đã kết thúc';

    proposal.approvalHistory.push({
      action: 'rejected',
      actionLabel: 'Từ chối đề xuất',
      approverName: 'Trần Minh Đức',
      comment: reason,
      role: 'Người phê duyệt',
      step: proposal.approvalHistory.length + 1,
      timestamp: now,
    });
  }

  function cancelProposal(id: string) {
    const proposal = proposals.value.find((p) => p.id === id);
    if (!proposal) return;
    proposal.status = 'canceled';
    proposal.currentApprover = 'Đã hủy';
  }

  function confirmTransaction(payload: {
    actualAmount: number;
    paymentMethod: 'cash' | 'internal_transfer';
    performedBy: string;
    signedBy: string;
    transactionId: string;
  }) {
    const tx = transactions.value.find((t) => t.id === payload.transactionId);
    if (!tx) return;

    const now = new Date().toISOString().replace('T', ' ').substring(0, 16);
    tx.status = 'completed';
    tx.actualAmount = payload.actualAmount;
    tx.paymentMethod = payload.paymentMethod;
    tx.performedBy = payload.performedBy;
    tx.signedBy = payload.signedBy;
    tx.completedDate = now;

    // Update fund source balance
    const source = fundSources.value.find((s) => s.id === tx.sourceId);
    if (source) {
      if (tx.type === 'receipt') {
        source.currentBalance += payload.actualAmount;
      } else {
        source.currentBalance -= payload.actualAmount;
      }
    }

    // Update linked proposal status to completed
    const proposal = proposals.value.find((p) => p.id === tx.proposalId);
    if (proposal) {
      proposal.status = 'completed';
      proposal.currentApprover = 'Đã hoàn tất';
      proposal.approvalHistory.push({
        action: 'completed',
        actionLabel: tx.type === 'expense' ? 'Đã chi tiền mặt' : 'Đã thu vào quỹ',
        approverName: payload.performedBy,
        comment: `Giao dịch hoàn tất. Số tiền: ${payload.actualAmount.toLocaleString()} ${tx.currency}. Ký nhận: ${payload.signedBy}.`,
        role: 'Thủ quỹ',
        step: proposal.approvalHistory.length + 1,
        timestamp: now,
      });
    }
  }

  function createAdjustment(payload: {
    amount: number;
    attachmentName: string;
    effectiveDate: string;
    fromSourceId: string;
    reason: string;
    toSourceId: string;
  }) {
    const fromSrc = fundSources.value.find((s) => s.id === payload.fromSourceId);
    const toSrc = fundSources.value.find((s) => s.id === payload.toSourceId);
    if (!fromSrc || !toSrc) return;

    const now = new Date().toISOString().replace('T', ' ').substring(0, 16);
    const code = generateCode('DC');

    const newAdj: FundAdjustment = {
      amount: payload.amount,
      attachmentName: payload.attachmentName,
      attachmentSize: '1.2 MB',
      currentApprover: 'Lê Thu Hà (Kế toán trưởng)',
      currentStep: 'Kế toán trưởng duyệt',
      currency: fromSrc.currency,
      effectiveDate: payload.effectiveDate,
      fromCompany: fromSrc.company,
      fromSourceId: fromSrc.id,
      fromSourceName: fromSrc.name,
      id: `adj-${Date.now()}`,
      reason: payload.reason,
      requestDate: now.substring(0, 10),
      status: 'pending_accountant',
      toCompany: toSrc.company,
      toSourceId: toSrc.id,
      toSourceName: toSrc.name,
      code,
      approvalHistory: [
        {
          action: 'submitted',
          actionLabel: 'Tạo yêu cầu điều chỉnh quỹ',
          approverName: 'Lê Thu Hà',
          role: 'Phòng Tài chính',
          step: 1,
          timestamp: now,
        },
      ],
    };

    adjustments.value.unshift(newAdj);
    return newAdj;
  }

  function approveAdjustment(id: string, comment = '') {
    const adj = adjustments.value.find((a) => a.id === id);
    if (!adj) return;

    const now = new Date().toISOString().replace('T', ' ').substring(0, 16);
    const step = adj.approvalHistory.length + 1;

    if (adj.status === 'pending_accountant') {
      adj.status = 'pending_cfo';
      adj.currentStep = 'CFO duyệt';
      adj.currentApprover = 'Nguyễn Thị Bích (CFO)';
      adj.approvalHistory.push({
        action: 'approved',
        actionLabel: 'Kế toán trưởng phê duyệt',
        approverName: 'Lê Thu Hà',
        comment: comment || 'Đồng ý chuyển nguồn.',
        role: 'Kế toán trưởng',
        step,
        timestamp: now,
      });
    } else if (adj.status === 'pending_cfo') {
      adj.status = 'pending_source_ceo';
      adj.currentStep = 'TGĐ công ty nguồn duyệt';
      adj.currentApprover = 'Trần Anh Tuấn (TGĐ)';
      adj.approvalHistory.push({
        action: 'approved',
        actionLabel: 'CFO phê duyệt tài chính',
        approverName: 'Nguyễn Thị Bích',
        comment: comment || 'Duyệt điều chuyển nội bộ.',
        role: 'CFO',
        step,
        timestamp: now,
      });
    } else if (adj.status === 'pending_source_ceo') {
      adj.status = 'completed';
      adj.currentStep = 'Hoàn tất';
      adj.currentApprover = 'Đã duyệt';
      adj.approvalHistory.push({
        action: 'completed',
        actionLabel: 'TGĐ phê duyệt hoàn tất',
        approverName: 'Trần Anh Tuấn',
        comment: comment || 'Đã duyệt điều chuyển.',
        role: 'Tổng Giám đốc',
        step,
        timestamp: now,
      });

      // Execute transfer between sources
      const from = fundSources.value.find((s) => s.id === adj.fromSourceId);
      const to = fundSources.value.find((s) => s.id === adj.toSourceId);
      if (from && to) {
        from.currentBalance -= adj.amount;
        to.currentBalance += adj.amount;
      }
    }
  }

  function rejectAdjustment(id: string, reason: string) {
    const adj = adjustments.value.find((a) => a.id === id);
    if (!adj) return;
    const now = new Date().toISOString().replace('T', ' ').substring(0, 16);
    adj.status = 'rejected';
    adj.currentStep = 'Từ chối';
    adj.currentApprover = 'Đã kết thúc';
    adj.approvalHistory.push({
      action: 'rejected',
      actionLabel: 'Từ chối điều chuyển',
      approverName: 'Người phê duyệt',
      comment: reason,
      role: 'Cấp phê duyệt',
      step: adj.approvalHistory.length + 1,
      timestamp: now,
    });
  }

  function toggleCategoryStatus(id: string) {
    const cat = categories.value.find((c) => c.id === id);
    if (cat) {
      cat.status = cat.status === 'active' ? 'inactive' : 'active';
    }
  }

  function addCategory(payload: Omit<MasterCategory, 'createdAt' | 'id'>) {
    const newCat: MasterCategory = {
      ...payload,
      createdAt: new Date().toISOString().substring(0, 10),
      id: `cat-${Date.now()}`,
    };
    categories.value.push(newCat);
    return newCat;
  }

  function updateCategory(id: string, payload: Partial<MasterCategory>) {
    const cat = categories.value.find((c) => c.id === id);
    if (cat) {
      Object.assign(cat, payload);
    }
  }

  function addFundSource(payload: Omit<FundSource, 'id'>) {
    const newSrc: FundSource = {
      ...payload,
      id: `src-${Date.now()}`,
    };
    fundSources.value.push(newSrc);
    return newSrc;
  }

  function updateFundSource(id: string, payload: Partial<FundSource>) {
    const src = fundSources.value.find((s) => s.id === id);
    if (src) {
      Object.assign(src, payload);
    }
  }

  return {
    addCategory,
    addFundSource,
    addProposal,
    adjustments,
    approveAdjustment,
    approveProposal,
    cancelProposal,
    categories,
    confirmTransaction,
    createAdjustment,
    currencies,
    fundSources,
    getAdjustmentById,
    getProposalById,
    getTransactionById,
    proposals,
    rejectAdjustment,
    rejectProposal,
    resubmitProposal,
    returnEditProposal,
    toggleCategoryStatus,
    transactions,
    updateCategory,
    updateFundSource,
  };
}
