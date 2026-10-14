import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:obee_mobile/src/core/time/business_time.dart';
import 'package:obee_mobile/src/core/time/clock_provider.dart';
import 'package:obee_mobile/src/features/auth/data/user_tree_selection_user.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';
import 'package:obee_mobile/src/features/requests/data/request_api.dart';
import 'package:obee_mobile/src/features/requests/data/request_enums.dart';
import 'package:obee_mobile/src/features/requests/data/request_models.dart';
import 'package:obee_mobile/src/features/requests/logic/request_formatters.dart';

enum RequestFilterTab {
  pending('Yêu cầu'),
  approved('Chấp thuận'),
  rejected('Từ chối');

  const RequestFilterTab(this.label);

  final String label;
}

@immutable
class RequestListState {
  const RequestListState({
    required this.items,
    required this.isLoading,
    this.errorMessage,
    required this.selectedTab,
    this.selectedLeaveType,
    this.selectedRequesterId,
    this.selectedReviewerId,
    this.selectedDateRange,
    this.reviewers = const [],
    this.employees = const [],
    this.customPendingCount,
    this.customApprovedCount,
    this.customRejectedCount,
  });

  final List<AbsenceRequestModel> items;
  final bool isLoading;
  final String? errorMessage;
  final RequestFilterTab selectedTab;
  final LeaveTypeEnum? selectedLeaveType;
  final String? selectedRequesterId;
  final String? selectedReviewerId;
  final DateTimeRange? selectedDateRange;
  final List<UserTreeSelectionUser> reviewers;
  final List<UserTreeSelectionUser> employees;

  // Optional mock counter overrides
  final int? customPendingCount;
  final int? customApprovedCount;
  final int? customRejectedCount;

  String get createdDateRangeLabel {
    final range = selectedDateRange;
    if (range == null) return 'Ngày tạo';
    final format = DateFormat('dd/MM/yyyy');
    return 'Ngày tạo: ${format.format(range.start)} - ${format.format(range.end)}';
  }

  bool _matchesDateRange(AbsenceRequestModel item, DateTimeRange? range) {
    if (range == null) return true;
    final created = parseRequestDateTime(item.createdAt);
    if (created == null) return false;
    final start = DateUtils.dateOnly(range.start);
    final endExclusive = DateTime(
      range.end.year,
      range.end.month,
      range.end.day + 1,
    );
    return !created.isBefore(start) && created.isBefore(endExclusive);
  }

  bool itemMatchesFilters(AbsenceRequestModel item) {
    if (selectedLeaveType != null && item.leaveType != selectedLeaveType) {
      return false;
    }
    if (selectedRequesterId != null && item.userId != selectedRequesterId) {
      return false;
    }
    if (selectedReviewerId != null && item.reviewerId != selectedReviewerId) {
      return false;
    }
    if (!_matchesDateRange(item, selectedDateRange)) {
      return false;
    }
    return true;
  }

  int get pendingCount =>
      customPendingCount ??
      items
          .where(
            (i) =>
                itemMatchesFilters(i) &&
                i.requestStatus == AbsenceRequestStatus.pending,
          )
          .length;

  int get approvedCount =>
      customApprovedCount ??
      items
          .where(
            (i) =>
                itemMatchesFilters(i) &&
                i.requestStatus == AbsenceRequestStatus.approved,
          )
          .length;

  int get rejectedCount =>
      customRejectedCount ??
      items
          .where(
            (i) =>
                itemMatchesFilters(i) &&
                (i.requestStatus == AbsenceRequestStatus.rejected ||
                    i.requestStatus == AbsenceRequestStatus.returned),
          )
          .length;

  List<AbsenceRequestModel> get filteredItems {
    return items.where((item) {
      if (selectedTab == RequestFilterTab.pending &&
          item.requestStatus != AbsenceRequestStatus.pending) {
        return false;
      }
      if (selectedTab == RequestFilterTab.approved &&
          item.requestStatus != AbsenceRequestStatus.approved) {
        return false;
      }
      if (selectedTab == RequestFilterTab.rejected &&
          item.requestStatus != AbsenceRequestStatus.rejected &&
          item.requestStatus != AbsenceRequestStatus.returned) {
        return false;
      }

      return itemMatchesFilters(item);
    }).toList();
  }

  RequestListState copyWith({
    List<AbsenceRequestModel>? items,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    RequestFilterTab? selectedTab,
    LeaveTypeEnum? selectedLeaveType,
    bool clearLeaveType = false,
    String? selectedRequesterId,
    bool clearRequesterId = false,
    String? selectedReviewerId,
    bool clearReviewerId = false,
    DateTimeRange? selectedDateRange,
    bool clearDateRange = false,
    List<UserTreeSelectionUser>? reviewers,
    List<UserTreeSelectionUser>? employees,
    int? customPendingCount,
    int? customApprovedCount,
    int? customRejectedCount,
  }) {
    return RequestListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedTab: selectedTab ?? this.selectedTab,
      selectedLeaveType: clearLeaveType
          ? null
          : (selectedLeaveType ?? this.selectedLeaveType),
      selectedRequesterId: clearRequesterId
          ? null
          : (selectedRequesterId ?? this.selectedRequesterId),
      selectedReviewerId: clearReviewerId
          ? null
          : (selectedReviewerId ?? this.selectedReviewerId),
      selectedDateRange: clearDateRange
          ? null
          : (selectedDateRange ?? this.selectedDateRange),
      reviewers: reviewers ?? this.reviewers,
      employees: employees ?? this.employees,
      customPendingCount: customPendingCount ?? this.customPendingCount,
      customApprovedCount: customApprovedCount ?? this.customApprovedCount,
      customRejectedCount: customRejectedCount ?? this.customRejectedCount,
    );
  }
}

final requestListControllerProvider =
    NotifierProvider<RequestListController, RequestListState>(
      RequestListController.new,
    );

class RequestListController extends Notifier<RequestListState> {
  late RequestApi _api;

  @override
  RequestListState build() {
    _api = ref.watch(requestApiProvider);
    ref.watch(authControllerProvider.select((auth) => auth.user));
    Future.microtask(bootstrap);

    return RequestListState(
      items: const [],
      isLoading: true,
      selectedTab: RequestFilterTab.pending,
      selectedDateRange: defaultDateRange,
    );
  }

  DateTimeRange get defaultDateRange {
    final today = DateUtils.dateOnly(
      businessWallTime(ref.read(clockProvider).now()),
    );
    return DateTimeRange(
      start: DateTime(today.year, today.month, today.day - 30),
      end: today,
    );
  }

  Future<void> bootstrap() async {
    if (!ref.mounted) return;
    await Future.wait([loadRequests(), loadReviewers()]);
  }

  Future<void> loadRequests() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _api.fetchRequests();
      if (!ref.mounted) return;
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải danh sách yêu cầu.',
      );
    }
  }

  Future<void> loadReviewers() async {
    try {
      final user = ref.read(authControllerProvider).user;
      if (user == null || user.rootOrganizationId == null) return;
      final results = await Future.wait([
        _api.fetchReviewers(
          rootOrganizationId: user.rootOrganizationId!,
          requesterId: user.id,
        ),
        _api.fetchEmployees(rootOrganizationId: user.rootOrganizationId!),
      ]);
      if (!ref.mounted) return;
      state = state.copyWith(reviewers: results[0], employees: results[1]);
    } catch (_) {
      if (!ref.mounted) return;
      state = state.copyWith(
        errorMessage: 'Không thể tải danh sách nhân viên và người duyệt.',
      );
    }
  }

  void selectTab(RequestFilterTab tab) {
    state = state.copyWith(selectedTab: tab);
  }

  void selectLeaveType(LeaveTypeEnum? type) {
    if (type == null) {
      state = state.copyWith(clearLeaveType: true);
    } else {
      state = state.copyWith(selectedLeaveType: type);
    }
  }

  void selectRequester(String? requesterId) {
    if (requesterId == null) {
      state = state.copyWith(clearRequesterId: true);
    } else {
      state = state.copyWith(selectedRequesterId: requesterId);
    }
  }

  void selectReviewer(String? reviewerId) {
    if (reviewerId == null) {
      state = state.copyWith(clearReviewerId: true);
    } else {
      state = state.copyWith(selectedReviewerId: reviewerId);
    }
  }

  void selectDateRange(DateTimeRange? range) {
    if (range == null) {
      state = state.copyWith(clearDateRange: true);
    } else {
      state = state.copyWith(selectedDateRange: range);
    }
  }

  Future<bool> approveRequest(String id, {String? note}) async {
    try {
      await _api.approveRequest(id, note: note);
      if (!ref.mounted) return true;
      await loadRequests();
      return true;
    } catch (_) {
      if (!ref.mounted) return false;
      state = state.copyWith(errorMessage: 'Không thể chấp thuận yêu cầu.');
      return false;
    }
  }

  Future<bool> rejectRequest(String id, {String? note}) async {
    try {
      await _api.rejectRequest(id, note: note);
      if (!ref.mounted) return true;
      await loadRequests();
      return true;
    } catch (_) {
      if (!ref.mounted) return false;
      state = state.copyWith(errorMessage: 'Không thể từ chối yêu cầu.');
      return false;
    }
  }

  Future<bool> returnRequest(String id, {required String note}) async {
    try {
      await _api.returnRequest(id, note: note);
      if (!ref.mounted) return true;
      await loadRequests();
      return true;
    } catch (_) {
      if (!ref.mounted) return false;
      state = state.copyWith(errorMessage: 'Không thể yêu cầu điều chỉnh.');
      return false;
    }
  }

  Future<bool> cancelRequest(String id) async {
    try {
      await _api.cancelRequest(id);
      if (!ref.mounted) return true;
      await loadRequests();
      return true;
    } catch (_) {
      if (!ref.mounted) return false;
      state = state.copyWith(errorMessage: 'Không thể hủy yêu cầu.');
      return false;
    }
  }

  Future<void> refresh() async {
    await loadRequests();
  }
}
