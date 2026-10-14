import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';
import 'package:obee_mobile/src/features/requests/data/request_api.dart';
import 'package:obee_mobile/src/features/requests/data/request_enums.dart';
import 'package:obee_mobile/src/features/requests/data/request_models.dart';
import 'package:obee_mobile/src/features/requests/logic/request_formatters.dart';
import 'package:obee_mobile/src/features/requests/state/request_list_controller.dart';

@immutable
class CreateLeaveRequestState {
  const CreateLeaveRequestState({
    this.editRequestId,
    this.editRequestStatus,
    this.reviewerId,
    this.leaveType = LeaveTypeEnum.annual,
    this.leaveBalance = const AsyncLoading(),
    this.leaveDate,
    this.selectedPeriodKey,
    this.assignedShifts = const AsyncData([]),
    this.startAt,
    this.endAt,
    this.reason = '',
    this.isSubmitting = false,
    this.isLoadingExisting = false,
    this.errorMessage,
    this.isCustomRange = false,
    this.coveragePreview = const AsyncData(null),
  });

  final String? editRequestId;
  final AbsenceRequestStatus? editRequestStatus;
  final String? reviewerId;
  final LeaveTypeEnum leaveType;
  final AsyncValue<LeaveBalanceModel> leaveBalance;
  final DateTime? leaveDate;
  final String? selectedPeriodKey;
  final AsyncValue<List<WorkUserShiftModel>> assignedShifts;
  final String? startAt;
  final String? endAt;
  final String reason;
  final bool isSubmitting;
  final bool isLoadingExisting;
  final String? errorMessage;
  final bool isCustomRange;
  final AsyncValue<LeaveCoveragePreviewModel?> coveragePreview;

  Object get _scalarValues => (
    editRequestId,
    editRequestStatus,
    reviewerId,
    leaveType,
    leaveBalance,
    leaveDate,
    selectedPeriodKey,
    startAt,
    endAt,
    reason,
    isSubmitting,
    isLoadingExisting,
    errorMessage,
    isCustomRange,
    assignedShifts.isLoading,
    assignedShifts.error,
    assignedShifts.stackTrace,
    coveragePreview.isLoading,
    coveragePreview.error,
    coveragePreview.asData?.value,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateLeaveRequestState &&
          _scalarValues == other._scalarValues &&
          listEquals(
            assignedShifts.asData?.value,
            other.assignedShifts.asData?.value,
          );

  @override
  int get hashCode => Object.hash(
    _scalarValues,
    Object.hashAll(
      assignedShifts.asData?.value ?? const <WorkUserShiftModel>[],
    ),
  );

  bool get isEditing => editRequestId != null;

  bool get isValid =>
      reviewerId != null &&
      reviewerId!.isNotEmpty &&
      (isCustomRange || leaveDate != null) &&
      startAt != null &&
      endAt != null &&
      (isCustomRange ||
          (!assignedShifts.isLoading &&
              !assignedShifts.hasError &&
              (assignedShifts.asData?.value.isNotEmpty ?? false))) &&
      reason.trim().isNotEmpty;

  CreateLeaveRequestState copyWith({
    String? editRequestId,
    AbsenceRequestStatus? editRequestStatus,
    String? reviewerId,
    LeaveTypeEnum? leaveType,
    AsyncValue<LeaveBalanceModel>? leaveBalance,
    DateTime? leaveDate,
    String? selectedPeriodKey,
    AsyncValue<List<WorkUserShiftModel>>? assignedShifts,
    String? startAt,
    String? endAt,
    bool clearInterval = false,
    bool clearWorkShift = false,
    bool clearReviewer = false,
    String? reason,
    bool? isSubmitting,
    bool? isLoadingExisting,
    String? errorMessage,
    bool clearError = false,
    bool? isCustomRange,
    AsyncValue<LeaveCoveragePreviewModel?>? coveragePreview,
  }) {
    return CreateLeaveRequestState(
      editRequestId: editRequestId ?? this.editRequestId,
      editRequestStatus: editRequestStatus ?? this.editRequestStatus,
      reviewerId: clearReviewer ? null : (reviewerId ?? this.reviewerId),
      leaveType: leaveType ?? this.leaveType,
      leaveBalance: leaveBalance ?? this.leaveBalance,
      leaveDate: leaveDate ?? this.leaveDate,
      selectedPeriodKey: clearWorkShift
          ? null
          : (selectedPeriodKey ?? this.selectedPeriodKey),
      assignedShifts: assignedShifts ?? this.assignedShifts,
      startAt: clearInterval ? null : (startAt ?? this.startAt),
      endAt: clearInterval ? null : (endAt ?? this.endAt),
      reason: reason ?? this.reason,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoadingExisting: isLoadingExisting ?? this.isLoadingExisting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isCustomRange: isCustomRange ?? this.isCustomRange,
      coveragePreview: coveragePreview ?? this.coveragePreview,
    );
  }
}

final createLeaveRequestControllerProvider =
    NotifierProvider.autoDispose<
      CreateLeaveRequestController,
      CreateLeaveRequestState
    >(CreateLeaveRequestController.new);

class CreateLeaveRequestController extends Notifier<CreateLeaveRequestState> {
  late RequestApi _api;
  int _balanceGeneration = 0;
  int _assignmentGeneration = 0;
  int _coverageGeneration = 0;

  @override
  CreateLeaveRequestState build() {
    _api = ref.watch(requestApiProvider);
    Future.microtask(_loadBalance);
    return const CreateLeaveRequestState();
  }

  Future<void> _loadBalance() async {
    if (!ref.mounted) return;
    final generation = ++_balanceGeneration;
    final startAt = state.startAt;
    final date = startAt == null
        ? state.leaveDate
        : parseRequestDateTime(startAt)!;
    state = state.copyWith(leaveBalance: const AsyncLoading());
    try {
      final balance = await _api.fetchLeaveBalance(
        asOf: date == null ? null : DateFormat('yyyy-MM-dd').format(date),
      );
      if (!ref.mounted || generation != _balanceGeneration) return;
      state = state.copyWith(leaveBalance: AsyncData(balance));
    } catch (error, stack) {
      if (!ref.mounted || generation != _balanceGeneration) return;
      state = state.copyWith(leaveBalance: AsyncError(error, stack));
    }
  }

  Future<void> _loadCoveragePreview() async {
    final startAt = state.startAt;
    final endAt = state.endAt;
    final rootId = ref.read(authControllerProvider).user?.rootOrganizationId;
    if (startAt == null || endAt == null || rootId == null) {
      state = state.copyWith(coveragePreview: const AsyncData(null));
      return;
    }
    final generation = ++_coverageGeneration;
    state = state.copyWith(coveragePreview: const AsyncLoading());
    try {
      final preview = await _api.previewLeaveCoverage(
        rootOrganizationId: rootId,
        leaveType: state.leaveType.wireValue,
        startAt: startAt,
        endAt: endAt,
      );
      if (!ref.mounted || generation != _coverageGeneration) return;
      state = state.copyWith(coveragePreview: AsyncData(preview));
    } catch (error, stack) {
      if (!ref.mounted || generation != _coverageGeneration) return;
      state = state.copyWith(coveragePreview: AsyncError(error, stack));
    }
  }

  void retryCoveragePreview() {
    unawaited(_loadCoveragePreview());
  }

  void setReviewer(String? reviewerId) {
    state = state.copyWith(
      reviewerId: reviewerId,
      clearReviewer: reviewerId == null,
      clearError: true,
    );
  }

  void setLeaveType(LeaveTypeEnum type) {
    state = state.copyWith(leaveType: type, clearError: true);
    unawaited(_loadCoveragePreview());
  }

  void setIsCustomRange(bool isCustom) {
    if (state.isCustomRange == isCustom) return;
    state = state.copyWith(
      isCustomRange: isCustom,
      clearInterval: true,
      clearWorkShift: true,
      clearError: true,
      coveragePreview: const AsyncData(null),
    );
    if (!isCustom && state.leaveDate != null) {
      unawaited(_loadAssignments(state.leaveDate!));
    }
  }

  void setLeaveDate(DateTime date) {
    state = state.copyWith(
      leaveDate: date,
      clearInterval: true,
      clearWorkShift: true,
      clearError: true,
      assignedShifts: const AsyncLoading(),
      coveragePreview: const AsyncData(null),
    );
    unawaited(_loadBalance());
    unawaited(_loadAssignments(date));
  }

  void retryLoadAssignments() {
    final date = state.leaveDate;
    if (date != null) {
      state = state.copyWith(
        assignedShifts: const AsyncLoading(),
        clearError: true,
      );
      unawaited(_loadAssignments(date));
    }
  }

  Future<void> _loadAssignments(
    DateTime date, {
    bool selectFullShift = true,
  }) async {
    final generation = ++_assignmentGeneration;
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    try {
      final rows = await _api.fetchMyWorkShifts(
        from: dateString,
        to: dateString,
      );
      if (!ref.mounted || generation != _assignmentGeneration) return;
      final rootId = ref.read(authControllerProvider).user?.rootOrganizationId;
      final assignments = rows
          .where((row) => row.rootOrganizationId == rootId)
          .toList(growable: false);
      state = state.copyWith(
        assignedShifts: AsyncData(List.unmodifiable(assignments)),
      );
      if (selectFullShift &&
          !state.isCustomRange &&
          state.selectedPeriodKey == null &&
          assignments.isNotEmpty) {
        setWorkShift('all');
      }
    } catch (error, stack) {
      if (!ref.mounted || generation != _assignmentGeneration) return;
      state = state.copyWith(
        assignedShifts: AsyncError(error, stack),
        errorMessage: 'Không thể tải ca đã phân.',
      );
    }
  }

  List<LeavePeriodOption> get workShiftOptions {
    final rows = state.assignedShifts.asData?.value;
    if (rows == null || rows.isEmpty) return const [];
    final assignment = rows.single;
    final startDt = parseRequestDateTime(assignment.startAt);
    final endDt = parseRequestDateTime(assignment.endAt);
    final isOvernight =
        startDt != null &&
        endDt != null &&
        !DateUtils.isSameDay(startDt, endDt);

    final fullLabel = isOvernight
        ? '${assignment.workShift.name} (${formatRequestRange(assignment.startAt, assignment.endAt, separator: ' → ')} hôm sau)'
        : '${assignment.workShift.name} (${formatRequestRange(assignment.startAt, assignment.endAt, separator: ' → ')})';

    return [
      LeavePeriodOption(
        key: 'all',
        label: fullLabel,
        startAt: assignment.startAt,
        endAt: assignment.endAt,
      ),
      for (final (index, period) in assignment.workPeriods.indexed) ...[
        () {
          final pStart = parseRequestDateTime(period.startAt);
          final pEnd = parseRequestDateTime(period.endAt);
          final pOvernight =
              pStart != null &&
              pEnd != null &&
              !DateUtils.isSameDay(pStart, pEnd);
          final periodLabel = pOvernight
              ? 'Khoảng ${index + 1}: ${formatRequestRange(period.startAt, period.endAt, separator: ' → ')} (hôm sau)'
              : 'Khoảng ${index + 1}: ${formatRequestRange(period.startAt, period.endAt, separator: ' → ')}';
          return LeavePeriodOption(
            key: '$index',
            label: periodLabel,
            startAt: period.startAt,
            endAt: period.endAt,
          );
        }(),
      ],
    ];
  }

  void setWorkShift(String key) {
    if (key == 'custom') {
      final date = state.leaveDate ?? DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final startAt = state.startAt ?? '$dateStr 08:00:00';
      final endAt = state.endAt ?? '$dateStr 17:30:00';
      state = state.copyWith(
        selectedPeriodKey: 'custom',
        isCustomRange: true,
        startAt: startAt,
        endAt: endAt,
        clearError: true,
      );
      unawaited(_loadBalance());
      unawaited(_loadCoveragePreview());
      return;
    }
    final option = workShiftOptions.firstWhere((option) => option.key == key);
    state = state.copyWith(
      selectedPeriodKey: key,
      isCustomRange: false,
      startAt: option.startAt,
      endAt: option.endAt,
      clearError: true,
    );
    unawaited(_loadBalance());
    unawaited(_loadCoveragePreview());
  }

  void setCustomInterval(String startAt, String endAt) {
    final start = parseRequestDateTime(startAt);
    final end = parseRequestDateTime(endAt);
    if (start == null || end == null || !end.isAfter(start)) {
      state = state.copyWith(
        errorMessage: 'Khoảng thời gian nghỉ không hợp lệ.',
      );
      return;
    }
    state = state.copyWith(
      startAt: startAt,
      endAt: endAt,
      isCustomRange: true,
      selectedPeriodKey: 'custom',
      clearError: true,
    );
    unawaited(_loadBalance());
    unawaited(_loadCoveragePreview());
  }

  void setReason(String reason) {
    state = state.copyWith(reason: reason, clearError: true);
  }

  Future<void> initForRequest(String requestId) async {
    state = state.copyWith(isLoadingExisting: true);
    try {
      final req = await _api.fetchRequestDetail(requestId);
      if (!ref.mounted) return;
      final start = parseRequestDateTime(req.startAt);
      final end = parseRequestDateTime(req.endAt);
      if (start == null || end == null) {
        throw const FormatException('Khoảng thời gian nghỉ không hợp lệ.');
      }

      state = state.copyWith(
        editRequestId: req.id,
        editRequestStatus: req.requestStatus,
        reviewerId: req.reviewerId,
        leaveType: req.leaveType,
        leaveDate: start,
        isCustomRange: true,
        clearWorkShift: true,
        startAt: req.startAt,
        endAt: req.endAt,
        reason: req.reason,
        isLoadingExisting: false,
      );
      await _loadAssignments(start, selectFullShift: false);
      if (!ref.mounted) return;
      await _loadBalance();
      await _loadCoveragePreview();
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoadingExisting: false,
        errorMessage: 'Không thể tải thông tin yêu cầu cần chỉnh sửa.',
      );
    }
  }

  void reset() {
    ++_assignmentGeneration;
    state = const CreateLeaveRequestState();
    unawaited(_loadBalance());
  }

  Future<bool> submit() async {
    if (state.reviewerId == null || state.reviewerId!.isEmpty) {
      state = state.copyWith(errorMessage: 'Vui lòng chọn người duyệt.');
      return false;
    }
    if (!state.isCustomRange && state.leaveDate == null) {
      state = state.copyWith(errorMessage: 'Vui lòng chọn ngày nghỉ.');
      return false;
    }
    if (state.reason.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Vui lòng nhập lý do nghỉ.');
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final auth = ref.read(authControllerProvider);
      final rootOrgId = auth.user?.rootOrganizationId;
      if (rootOrgId == null) {
        throw StateError('Tài khoản chưa có tổ chức gốc.');
      }
      final startAt = state.startAt;
      final endAt = state.endAt;
      if (startAt == null ||
          endAt == null ||
          (!state.isCustomRange &&
              (state.assignedShifts.isLoading ||
                  state.assignedShifts.hasError ||
                  (state.assignedShifts.asData?.value.isEmpty ?? true)))) {
        throw StateError('Vui lòng chọn khoảng thời gian nghỉ từ ca đã phân.');
      }

      final draft = CreateRequestDraft(
        rootOrganizationId: rootOrgId,
        reviewerId: state.reviewerId!,
        leaveType: state.leaveType,
        startAt: startAt,
        endAt: endAt,
        reason: state.reason.trim(),
      );

      if (state.editRequestId != null &&
          state.editRequestStatus == AbsenceRequestStatus.returned) {
        await _api.updateRequest(state.editRequestId!, draft);
      } else {
        await _api.createRequest(draft);
      }

      if (!ref.mounted) return true;

      // Refresh or prepend list
      unawaited(ref.read(requestListControllerProvider.notifier).refresh());
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      if (!ref.mounted) return false;
      final msg = e.toString().replaceFirst('Exception: ', '').trim();
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: msg.isNotEmpty
            ? msg
            : 'Gửi yêu cầu thất bại. Vui lòng thử lại.',
      );
      return false;
    }
  }
}

@immutable
final class LeavePeriodOption {
  const LeavePeriodOption({
    required this.key,
    required this.label,
    required this.startAt,
    required this.endAt,
  });
  final String key;
  final String label;
  final String startAt;
  final String endAt;
}
