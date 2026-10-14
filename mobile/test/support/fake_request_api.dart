import 'dart:async';

import 'package:obee_mobile/src/features/auth/data/user_tree_selection_user.dart';
import 'package:obee_mobile/src/features/requests/data/request_api.dart';
import 'package:obee_mobile/src/features/requests/data/request_models.dart';

import 'request_fixtures.dart';

class FakeRequestApi implements RequestApi {
  List<WorkUserShiftModel> assignedShifts = [];
  Future<List<WorkUserShiftModel>> Function(String date)? shiftsHandler;

  @override
  Future<List<WorkUserShiftModel>> fetchMyWorkShifts({
    required String from,
    required String to,
  }) async {
    final handler = shiftsHandler;
    return handler == null
        ? assignedShifts
              .where(
                (row) =>
                    row.workDate.compareTo(from) >= 0 &&
                    row.workDate.compareTo(to) <= 0,
              )
              .toList()
        : await handler(from);
  }

  List<AbsenceRequestModel> items = List.of(initialDemoRequests);
  Object? mutationError;
  Object? fetchError;
  Completer<AbsenceRequestModel>? detailCompleter;
  CreateRequestDraft? lastDraft;
  String? lastRevisionNote;
  int mutationCalls = 0;
  final balanceDates = <String?>[];
  final balanceResponses = <String, Completer<LeaveBalanceModel>>{};

  @override
  Future<List<AbsenceRequestModel>> fetchRequests({
    String? status,
    String? leaveType,
    String? from,
    String? to,
    String? reviewerId,
  }) async {
    if (fetchError != null) throw fetchError!;
    return List.of(items);
  }

  @override
  Future<AbsenceRequestModel> fetchRequestDetail(String id) async {
    if (detailCompleter != null) return detailCompleter!.future;
    if (fetchError != null) throw fetchError!;
    return items.firstWhere((item) => item.id == id);
  }

  @override
  Future<LeaveBalanceModel> fetchLeaveBalance({String? asOf}) async {
    balanceDates.add(asOf);
    if (asOf != null && balanceResponses.containsKey(asOf)) {
      return balanceResponses[asOf]!.future;
    }
    if (fetchError != null) throw fetchError!;
    return const LeaveBalanceModel(entitlement: 12, used: 2, remaining: 10);
  }

  LeaveCoveragePreviewModel? coveragePreviewResponse;
  Object? coveragePreviewError;

  @override
  Future<LeaveCoveragePreviewModel> previewLeaveCoverage({
    required String rootOrganizationId,
    required String leaveType,
    required String startAt,
    required String endAt,
  }) async {
    if (coveragePreviewError != null) throw coveragePreviewError!;
    if (coveragePreviewResponse != null) return coveragePreviewResponse!;
    return LeaveCoveragePreviewModel(
      totalDays: 1.0,
      workingDays: 1,
      holidayDays: 0,
      offDays: 0,
      items: [
        LeaveCoverageItemModel(
          date: startAt.split('T').first.split(' ').first,
          status: 'covered',
          workShiftId: 'shift',
          hours: 8.0,
          days: 1.0,
          note: 'Ca làm việc',
        ),
      ],
    );
  }

  @override
  Future<AbsenceRequestModel> createRequest(CreateRequestDraft draft) async {
    mutationCalls++;
    if (mutationError != null) throw mutationError!;
    lastDraft = draft;
    final created = initialDemoRequests.first.copyWith(
      id: 'created',
      startAt: draft.startAt,
      endAt: draft.endAt,
      reason: draft.reason,
    );
    items.add(created);
    return created;
  }

  @override
  Future<AbsenceRequestModel> updateRequest(
    String id,
    CreateRequestDraft draft,
  ) async {
    mutationCalls++;
    if (mutationError != null) throw mutationError!;
    lastDraft = draft;
    final updated = items
        .firstWhere((item) => item.id == id)
        .copyWith(
          startAt: draft.startAt,
          endAt: draft.endAt,
          reason: draft.reason,
          status: 'pending',
        );
    items = items.map((item) => item.id == id ? updated : item).toList();
    return updated;
  }

  @override
  Future<void> approveRequest(String id, {String? note}) async {
    mutationCalls++;
    if (mutationError != null) throw mutationError!;
    items = items
        .map(
          (item) => item.id == id
              ? item.copyWith(
                  status: 'approved',
                  approvalNote: note,
                  approvedAt: '2026-10-06T02:00:00Z',
                )
              : item,
        )
        .toList();
  }

  @override
  Future<void> rejectRequest(String id, {String? note}) async {
    mutationCalls++;
    if (mutationError != null) throw mutationError!;
    items = items
        .map(
          (item) => item.id == id
              ? item.copyWith(status: 'rejected', approvalNote: note)
              : item,
        )
        .toList();
  }

  @override
  Future<void> returnRequest(String id, {required String note}) async {
    mutationCalls++;
    if (mutationError != null) throw mutationError!;
    lastRevisionNote = note;
    items = items
        .map(
          (item) => item.id == id
              ? item.copyWith(status: 'returned', approvalNote: note)
              : item,
        )
        .toList();
  }

  @override
  Future<void> cancelRequest(String id) async {
    mutationCalls++;
    if (mutationError != null) throw mutationError!;
    items = items.where((item) => item.id != id).toList();
  }

  @override
  Future<List<UserTreeSelectionUser>> fetchReviewers({
    required String rootOrganizationId,
    required String requesterId,
  }) async => demoReviewers.where((user) => user.id != requesterId).toList();

  @override
  Future<List<UserTreeSelectionUser>> fetchEmployees({
    required String rootOrganizationId,
  }) async => demoReviewers;
}
