import type {
  ApprovalRole,
  ApprovalStep,
  CatalogItem,
  ChangeLine,
  ChangeRequest,
  DeliveryBatch,
  OrderPayment,
  OrderStatus,
  PaymentKind,
  PaymentStatus,
  PurchaseOrder,
  PurchaseRequest,
  Purpose,
  RequestLine,
  RequestStatus,
  Supplier,
  Unit,
} from './types';

import { computed, ref } from 'vue';

import { useCashFund } from '../cash-fund/store';
import {
  CURRENT_USER,
  initialApproverPools,
  initialCatalog,
  initialChangeRequests,
  initialDeliveries,
  initialOrders,
  initialPurposes,
  initialRequests,
  initialSuppliers,
  initialUnits,
} from './mock-data';
import { nowText, ROLE_LABELS } from './utils';

function clone<T>(value: T): T {
  return JSON.parse(JSON.stringify(value)) as T;
}

const requests = ref<PurchaseRequest[]>(clone(initialRequests));
const orders = ref<PurchaseOrder[]>(clone(initialOrders));
const deliveries = ref<DeliveryBatch[]>(clone(initialDeliveries));
const changeRequests = ref<ChangeRequest[]>(clone(initialChangeRequests));
const catalog = ref<CatalogItem[]>(clone(initialCatalog));
const units = ref<Unit[]>(clone(initialUnits));
const purposes = ref<Purpose[]>(clone(initialPurposes));
const suppliers = ref<Supplier[]>(clone(initialSuppliers));
const approverPools = ref<Record<ApprovalRole, string[]>>(
  clone(initialApproverPools),
);

/** Số chứng từ: <TIỀN TỐ>-<năm>-<5 chữ số>, bộ đếm riêng theo loại và chạy lại mỗi năm. */
function nextCode(prefix: string, existing: string[]) {
  const year = new Date().getFullYear();
  const head = `${prefix}-${year}-`;
  let max = 0;
  for (const code of existing) {
    if (code.startsWith(head))
      max = Math.max(max, Number(code.slice(head.length)) || 0);
  }
  return `${head}${String(max + 1).padStart(5, '0')}`;
}

function uid(prefix: string) {
  return `${prefix}-${Date.now()}-${Math.random().toString(36).slice(2, 7)}`;
}

export function selectedQuote(line: RequestLine) {
  return (
    line.quotes.find((q) => q.id === line.selectedQuoteId) ?? line.quotes[0]
  );
}

export function requestTotal(request: PurchaseRequest) {
  return request.lines.reduce(
    (sum, line) => sum + line.quantity * (selectedQuote(line)?.unitPrice ?? 0),
    0,
  );
}

export function orderTotal(order: PurchaseOrder) {
  return order.lines.reduce(
    (sum, line) => sum + line.quantity * line.unitPrice,
    0,
  );
}

export function usePurchasing() {
  const cash = useCashFund();

  function paymentStatus(payment: OrderPayment): PaymentStatus {
    if (payment.cashProposalId) {
      const proposal = cash.getProposalById(payment.cashProposalId);
      if (!proposal) return 'pending';
      if (proposal.status === 'completed') return 'completed';
      if (proposal.status === 'rejected' || proposal.status === 'canceled')
        return 'rejected';
      return 'pending';
    }
    return payment.staticStatus ?? 'pending';
  }

  function orderPaid(order: PurchaseOrder) {
    return order.payments
      .filter((p) => paymentStatus(p) === 'completed')
      .reduce((sum, p) => sum + p.amount, 0);
  }

  function orderCommitted(order: PurchaseOrder) {
    return order.payments
      .filter((p) => paymentStatus(p) !== 'rejected')
      .reduce((sum, p) => sum + p.amount, 0);
  }

  function orderReceivedAll(order: PurchaseOrder) {
    return order.lines.every((line) => line.receivedQty >= line.quantity);
  }

  function orderStatus(order: PurchaseOrder): OrderStatus {
    if (!order.issuedAt) return 'not_issued';
    if (!orderReceivedAll(order)) return 'in_progress';
    if (orderPaid(order) < orderTotal(order)) return 'awaiting_payment';
    return 'completed';
  }

  function ordersOfRequest(requestId: string) {
    return orders.value.filter((o) => o.requestId === requestId);
  }

  /** Trạng thái phiếu sau khi duyệt được suy ra từ các PO (Đã duyệt → Đang mua hàng → Hoàn thành). */
  function requestStatus(request: PurchaseRequest): RequestStatus {
    if (
      request.status !== 'approved' &&
      request.status !== 'purchasing' &&
      request.status !== 'completed'
    ) {
      return request.status;
    }
    const list = ordersOfRequest(request.id);
    if (list.length === 0) return request.status;
    if (list.every((o) => orderStatus(o) === 'completed')) return 'completed';
    if (list.some((o) => o.issuedAt)) return 'purchasing';
    return 'approved';
  }

  function currentApprover(steps: ApprovalStep[], index: number) {
    const step = steps[index];
    return step ? `${step.approverName} (${ROLE_LABELS[step.role]})` : '';
  }

  function nextActiveStep(steps: ApprovalStep[], from: number) {
    let index = from;
    while (index < steps.length && steps[index]?.skipped) index++;
    return index;
  }

  // ---------- Đề nghị mua hàng ----------
  function saveRequest(
    id: null | string,
    payload: Pick<
      PurchaseRequest,
      'approvalSteps' | 'attachments' | 'lines' | 'needContract' | 'note'
    >,
    submit: boolean,
  ) {
    const time = nowText();
    let request = id ? requests.value.find((r) => r.id === id) : undefined;
    if (request) {
      Object.assign(request, payload);
    } else {
      request = {
        ...payload,
        code: nextCode(
          'DNMH',
          requests.value.map((r) => r.code),
        ),
        createdAt: time,
        currentStep: 0,
        department: CURRENT_USER.department,
        history: [],
        id: uid('req'),
        requesterName: CURRENT_USER.name,
        requireInspection: false,
        status: 'draft',
      };
      requests.value.unshift(request);
    }
    if (submit) {
      request.status = 'pending';
      request.returnReason = undefined;
      request.currentStep = nextActiveStep(request.approvalSteps, 0);
      request.history.push({
        action: 'submitted',
        actorName: request.requesterName,
        role: 'Người đề xuất',
        timestamp: time,
      });
      if (request.currentStep >= request.approvalSteps.length) {
        finishRequestApproval(request);
      }
    }
    return request;
  }

  function recallRequest(id: string) {
    const request = requests.value.find((r) => r.id === id);
    if (!request) return;
    request.status = 'recalled';
    request.history.push({
      action: 'recalled',
      actorName: request.requesterName,
      role: 'Người đề xuất',
      timestamp: nowText(),
    });
  }

  function finishRequestApproval(request: PurchaseRequest) {
    request.status = 'approved';
    request.currentStep = request.approvalSteps.length;
    generateOrders(request);
    request.history.push({
      action: 'system',
      actorName: 'Hệ thống',
      comment: `Sinh ${ordersOfRequest(request.id).length} PO theo NCC đã chọn.`,
      role: 'Hệ thống',
      timestamp: nowText(),
    });
  }

  function addSupplierIfNew(id: string, name: string) {
    if (suppliers.value.some((s) => s.id === id)) return id;
    const created: Supplier = {
      code: `NCC-${String(suppliers.value.length + 1).padStart(3, '0')}`,
      contact: '',
      id: uid('sup'),
      name,
      phone: '',
      status: 'active',
      taxCode: '',
    };
    suppliers.value.push(created);
    return created.id;
  }

  function approveRequest(
    id: string,
    options: {
      comment: string;
      requireInspection?: boolean;
      selections?: Record<string, string>;
    },
  ) {
    const request = requests.value.find((r) => r.id === id);
    if (!request || request.status !== 'pending') return;
    const step = request.approvalSteps[request.currentStep];
    if (!step) return;
    if (step.role === 'purchasing') {
      for (const line of request.lines) {
        const quoteId = options.selections?.[line.id] ?? line.quotes[0]?.id;
        line.selectedQuoteId = quoteId;
        const quote = line.quotes.find((q) => q.id === quoteId);
        if (quote?.isNewSupplier) {
          quote.supplierId = addSupplierIfNew(
            quote.supplierId,
            quote.supplierName,
          );
          quote.isNewSupplier = false;
        }
      }
      request.requireInspection = Boolean(options.requireInspection);
    }
    request.history.push({
      action: 'approved',
      actorName: step.approverName,
      comment: options.comment || undefined,
      role: ROLE_LABELS[step.role],
      timestamp: nowText(),
    });
    request.currentStep = nextActiveStep(
      request.approvalSteps,
      request.currentStep + 1,
    );
    if (request.currentStep >= request.approvalSteps.length) {
      finishRequestApproval(request);
    }
  }

  function returnRequest(id: string, reason: string) {
    const request = requests.value.find((r) => r.id === id);
    const step = request?.approvalSteps[request.currentStep];
    if (!request || !step) return;
    request.status = 'return_edit';
    request.returnReason = reason;
    request.history.push({
      action: 'return_edit',
      actorName: step.approverName,
      comment: reason,
      role: ROLE_LABELS[step.role],
      timestamp: nowText(),
    });
  }

  function rejectRequest(id: string, reason: string) {
    const request = requests.value.find((r) => r.id === id);
    const step = request?.approvalSteps[request.currentStep];
    if (!request || !step) return;
    request.status = 'rejected';
    request.history.push({
      action: 'rejected',
      actorName: step.approverName,
      comment: reason,
      role: ROLE_LABELS[step.role],
      timestamp: nowText(),
    });
  }

  /** Gộp các dòng cùng NCC thành một PO. */
  function generateOrders(request: PurchaseRequest) {
    const groups = new Map<string, { lines: RequestLine[]; name: string }>();
    for (const line of request.lines) {
      const quote = selectedQuote(line);
      if (!quote) continue;
      const group = groups.get(quote.supplierId) ?? {
        lines: [],
        name: quote.supplierName,
      };
      group.lines.push(line);
      groups.set(quote.supplierId, group);
    }
    const time = nowText();
    for (const [supplierId, group] of groups) {
      orders.value.unshift({
        code: nextCode(
          'PO',
          orders.value.map((o) => o.code),
        ),
        createdAt: time,
        department: request.department,
        id: uid('po'),
        lines: group.lines.map((line) => ({
          id: uid('pl'),
          itemName: line.itemName,
          kind: line.kind,
          quantity: line.quantity,
          receivedQty: 0,
          requestLineId: line.id,
          spec: line.spec,
          unit: line.unit,
          unitPrice: selectedQuote(line)?.unitPrice ?? 0,
        })),
        payments: [],
        requestCode: request.code,
        requestId: request.id,
        requesterName: request.requesterName,
        supplierId,
        supplierName: group.name,
        version: 1,
        versions: [
          {
            at: time,
            by: 'Hệ thống',
            note: 'Sinh PO sau khi CEO duyệt',
            version: 1,
          },
        ],
      });
    }
  }

  // ---------- PO ----------
  function issueOrder(id: string) {
    const order = orders.value.find((o) => o.id === id);
    if (order && !order.issuedAt) order.issuedAt = nowText();
  }

  function recordDelivery(
    orderId: string,
    payload: {
      deliveredAt: string;
      documents: string[];
      quantities: Record<string, number>;
    },
  ) {
    const order = orders.value.find((o) => o.id === orderId);
    const request =
      order && requests.value.find((r) => r.id === order.requestId);
    if (!order || !request) return;
    const lines = order.lines
      .filter((line) => (payload.quantities[line.id] ?? 0) > 0)
      .map((line) => ({
        deliveredQty: payload.quantities[line.id] ?? 0,
        itemName: line.itemName,
        orderLineId: line.id,
        unit: line.unit,
      }));
    if (lines.length === 0) return;
    const batch: DeliveryBatch = {
      code: nextCode(
        'GH',
        deliveries.value.map((d) => d.code),
      ),
      deliveredAt: payload.deliveredAt,
      documents: payload.documents,
      events: [
        {
          action: 'Ghi nhận giao hàng',
          actorName: request.approvalSteps[1]?.approverName ?? 'Purchasing',
          role: 'Purchasing',
          timestamp: nowText(),
        },
      ],
      id: uid('dl'),
      lines,
      orderCode: order.code,
      orderId: order.id,
      requestId: request.id,
      requesterName: order.requesterName,
      status: request.requireInspection
        ? 'purchasing_check'
        : 'requester_check',
      supplierName: order.supplierName,
    };
    deliveries.value.unshift(batch);
    return batch;
  }

  function purchasingCheck(
    batchId: string,
    passed: Record<string, number>,
    comment: string,
  ) {
    const batch = deliveries.value.find((d) => d.id === batchId);
    if (!batch) return;
    let total = 0;
    for (const line of batch.lines) {
      line.passedQty = Math.min(
        passed[line.orderLineId] ?? 0,
        line.deliveredQty,
      );
      total += line.passedQty;
    }
    const failed = batch.lines.some((l) => (l.passedQty ?? 0) < l.deliveredQty);
    let action = 'Kiểm tra đạt';
    if (total === 0) action = 'Kiểm tra không đạt - trả NCC';
    else if (failed) action = 'Kiểm tra đạt một phần';
    batch.events.push({
      action,
      actorName: 'Phạm Quốc Huy',
      comment: comment || undefined,
      role: 'Purchasing',
      timestamp: nowText(),
    });
    batch.status = total === 0 ? 'reported_issue' : 'requester_check';
  }

  function requesterConfirm(
    batchId: string,
    accepted: Record<string, number>,
    comment: string,
  ) {
    const batch = deliveries.value.find((d) => d.id === batchId);
    const order = batch && orders.value.find((o) => o.id === batch.orderId);
    if (!batch || !order) return;
    for (const line of batch.lines) {
      const max = line.passedQty ?? line.deliveredQty;
      line.acceptedQty = Math.min(accepted[line.orderLineId] ?? 0, max);
      const orderLine = order.lines.find((l) => l.id === line.orderLineId);
      if (orderLine)
        orderLine.receivedQty = Math.min(
          orderLine.quantity,
          orderLine.receivedQty + line.acceptedQty,
        );
    }
    batch.status = 'confirmed';
    batch.events.push({
      action: 'Xác nhận nhận hàng',
      actorName: batch.requesterName,
      comment: comment || undefined,
      role: 'Người đề xuất',
      timestamp: nowText(),
    });
  }

  function requesterReport(batchId: string, reason: string) {
    const batch = deliveries.value.find((d) => d.id === batchId);
    if (!batch) return;
    batch.status = 'reported_issue';
    batch.events.push({
      action: 'Báo lỗi - trả về Purchasing',
      actorName: batch.requesterName,
      comment: reason,
      role: 'Người đề xuất',
      timestamp: nowText(),
    });
  }

  // ---------- Yêu cầu bổ sung/chỉnh sửa ----------
  function createChangeRequest(
    orderId: string,
    payload: { lines: ChangeLine[]; reason: string },
  ) {
    const order = orders.value.find((o) => o.id === orderId);
    const request =
      order && requests.value.find((r) => r.id === order.requestId);
    if (!order || !request) return;
    const steps = clone(request.approvalSteps);
    const change: ChangeRequest = {
      approvalSteps: steps,
      code: nextCode(
        'BS',
        changeRequests.value.map((c) => c.code),
      ),
      createdAt: nowText(),
      currentStep: nextActiveStep(steps, 0),
      department: request.department,
      history: [
        {
          action: 'submitted',
          actorName: request.requesterName,
          role: 'Người đề xuất',
          timestamp: nowText(),
        },
      ],
      id: uid('cr'),
      lines: payload.lines,
      orderCode: order.code,
      orderId: order.id,
      reason: payload.reason,
      requestCode: request.code,
      requestId: request.id,
      requesterName: request.requesterName,
      status: 'pending',
    };
    changeRequests.value.unshift(change);
    setHold(change, true);
    return change;
  }

  function setHold(change: ChangeRequest, hold: boolean) {
    const order = orders.value.find((o) => o.id === change.orderId);
    if (!order) return;
    for (const cl of change.lines) {
      const line = order.lines.find((l) => l.id === cl.orderLineId);
      if (line) line.onHold = hold;
    }
  }

  function approveChange(id: string, comment: string) {
    const change = changeRequests.value.find((c) => c.id === id);
    if (!change || change.status !== 'pending') return;
    const step = change.approvalSteps[change.currentStep];
    if (!step) return;
    change.history.push({
      action: 'approved',
      actorName: step.approverName,
      comment: comment || undefined,
      role: ROLE_LABELS[step.role],
      timestamp: nowText(),
    });
    change.currentStep = nextActiveStep(
      change.approvalSteps,
      change.currentStep + 1,
    );
    if (change.currentStep >= change.approvalSteps.length) applyChange(change);
  }

  function applyChange(change: ChangeRequest) {
    const order = orders.value.find((o) => o.id === change.orderId);
    if (!order) return;
    change.status = 'approved';
    setHold(change, false);
    const time = nowText();
    let modified = false;
    const newOrders = new Map<string, PurchaseOrder>();
    for (const cl of change.lines) {
      if (cl.kind === 'quantity') {
        const line = order.lines.find((l) => l.id === cl.orderLineId);
        if (line) {
          line.quantity = cl.newQty;
          modified = true;
        }
        continue;
      }
      const supplierId = cl.newSupplierId ?? order.supplierId;
      if (cl.kind === 'add' && supplierId === order.supplierId) {
        order.lines.push({
          id: uid('pl'),
          itemName: cl.itemName,
          kind: 'goods',
          quantity: cl.newQty,
          receivedQty: 0,
          requestLineId: '',
          spec: '',
          unit: cl.unit,
          unitPrice: cl.unitPrice,
        });
        modified = true;
        continue;
      }
      let target = newOrders.get(supplierId);
      if (!target) {
        target = {
          code: nextCode('PO', [
            ...orders.value.map((o) => o.code),
            ...[...newOrders.values()].map((o) => o.code),
          ]),
          createdAt: time,
          department: order.department,
          id: uid('po'),
          lines: [],
          parentOrderCode: order.code,
          payments: [],
          requestCode: order.requestCode,
          requestId: order.requestId,
          requesterName: order.requesterName,
          supplierId,
          supplierName: cl.newSupplierName ?? order.supplierName,
          version: 1,
          versions: [
            {
              at: time,
              by: 'Hệ thống',
              note: `Sinh từ ${change.code} (tham chiếu ${order.code})`,
              version: 1,
            },
          ],
        };
        newOrders.set(supplierId, target);
      }
      target.lines.push({
        id: uid('pl'),
        itemName: cl.itemName,
        kind: 'goods',
        quantity: cl.newQty,
        receivedQty: 0,
        requestLineId: '',
        spec: '',
        unit: cl.unit,
        unitPrice: cl.unitPrice,
      });
    }
    orders.value.unshift(...newOrders.values());
    if (modified) {
      order.version += 1;
      order.versions.push({
        at: time,
        by: 'Hệ thống',
        note: `Cập nhật theo ${change.code}`,
        version: order.version,
      });
    }
    change.history.push({
      action: 'system',
      actorName: 'Hệ thống',
      comment: [
        modified ? `${order.code} lên v${order.version}` : '',
        newOrders.size > 0 ? `sinh ${newOrders.size} PO mới` : '',
      ]
        .filter(Boolean)
        .join(', '),
      role: 'Hệ thống',
      timestamp: time,
    });
  }

  function returnChange(id: string, reason: string) {
    const change = changeRequests.value.find((c) => c.id === id);
    const step = change?.approvalSteps[change.currentStep];
    if (!change || !step) return;
    change.status = 'return_edit';
    change.history.push({
      action: 'return_edit',
      actorName: step.approverName,
      comment: reason,
      role: ROLE_LABELS[step.role],
      timestamp: nowText(),
    });
  }

  function rejectChange(id: string, reason: string) {
    const change = changeRequests.value.find((c) => c.id === id);
    const step = change?.approvalSteps[change.currentStep];
    if (!change || !step) return;
    change.status = 'rejected';
    setHold(change, false);
    change.history.push({
      action: 'rejected',
      actorName: step.approverName,
      comment: reason,
      role: ROLE_LABELS[step.role],
      timestamp: nowText(),
    });
  }

  // ---------- Thanh toán (chuyển sang Quỹ tiền mặt) ----------
  function createPayment(
    orderId: string,
    payload: { amount: number; kind: PaymentKind; note: string },
  ) {
    const order = orders.value.find((o) => o.id === orderId);
    if (!order) return;
    const kindText = payload.kind === 'advance' ? 'Ứng trước' : 'Thanh toán';
    const proposal = cash.addProposal({
      items: [
        {
          amount: payload.amount,
          categoryId: 'cat-chi-004',
          categoryName: 'Thiết bị & Công cụ CNTT',
          categoryType: 'expense',
          currency: 'VND',
          exchangeRate: 1,
          expectedDate: nowText().slice(0, 10),
          id: uid('cash-item'),
          reason: `${kindText} ${order.code} - ${order.supplierName}${payload.note ? `: ${payload.note}` : ''}`,
        },
      ],
      status: 'pending_dept',
      title: `${kindText} đơn hàng ${order.code}`,
      type: 'payment',
    });
    order.payments.push({
      amount: payload.amount,
      cashProposalCode: proposal.code,
      cashProposalId: proposal.id,
      createdAt: nowText(),
      createdBy: 'Phạm Quốc Huy',
      id: uid('pay'),
      kind: payload.kind,
      note: payload.note,
    });
    return proposal;
  }

  // ---------- Danh mục ----------
  function upsertCatalogItem(item: CatalogItem) {
    const found = catalog.value.find((c) => c.id === item.id);
    if (found) Object.assign(found, item);
    else catalog.value.push({ ...item, id: uid('item') });
  }

  function upsertSupplier(supplier: Supplier) {
    const found = suppliers.value.find((s) => s.id === supplier.id);
    if (found) Object.assign(found, supplier);
    else suppliers.value.push({ ...supplier, id: uid('sup') });
  }

  const pendingApprovalCount = computed(
    () =>
      requests.value.filter((r) => r.status === 'pending').length +
      changeRequests.value.filter((c) => c.status === 'pending').length,
  );

  return {
    addSupplierIfNew,
    approveChange,
    approveRequest,
    approverPools,
    catalog,
    changeRequests,
    createChangeRequest,
    createPayment,
    currentApprover,
    deliveries,
    issueOrder,
    nextCode,
    orderCommitted,
    orderPaid,
    orders,
    ordersOfRequest,
    orderStatus,
    paymentStatus,
    pendingApprovalCount,
    purchasingCheck,
    purposes,
    recallRequest,
    recordDelivery,
    rejectChange,
    rejectRequest,
    requesterConfirm,
    requesterReport,
    requests,
    requestStatus,
    returnChange,
    returnRequest,
    saveRequest,
    suppliers,
    units,
    upsertCatalogItem,
    upsertSupplier,
  };
}
