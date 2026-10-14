import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obee_mobile/src/features/auth/state/auth_controller.dart';
import 'package:obee_mobile/src/features/requests/data/request_api.dart';
import 'package:obee_mobile/src/features/requests/data/request_enums.dart';
import 'package:obee_mobile/src/features/requests/data/request_models.dart';
import 'package:obee_mobile/src/features/requests/logic/request_formatters.dart';
import 'package:obee_mobile/src/features/requests/state/request_list_controller.dart';

@immutable
class CreateTripRequestState {
  const CreateTripRequestState({
    this.editRequestId,
    this.editRequestStatus,
    this.reviewerId,
    this.startDateTime,
    this.endDateTime,
    this.reason = '',
    this.address = '',
    this.isSubmitting = false,
    this.isLoadingExisting = false,
    this.errorMessage,
  });

  final String? editRequestId;
  final AbsenceRequestStatus? editRequestStatus;
  final String? reviewerId;
  final DateTime? startDateTime;
  final DateTime? endDateTime;
  final String reason;
  final String address;
  final bool isSubmitting;
  final bool isLoadingExisting;
  final String? errorMessage;

  bool get isEditing => editRequestId != null;

  bool get isValid =>
      reviewerId != null &&
      reviewerId!.isNotEmpty &&
      startDateTime != null &&
      endDateTime != null &&
      reason.trim().isNotEmpty &&
      address.trim().isNotEmpty;

  CreateTripRequestState copyWith({
    String? editRequestId,
    AbsenceRequestStatus? editRequestStatus,
    String? reviewerId,
    bool clearReviewer = false,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? reason,
    String? address,
    bool? isSubmitting,
    bool? isLoadingExisting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CreateTripRequestState(
      editRequestId: editRequestId ?? this.editRequestId,
      editRequestStatus: editRequestStatus ?? this.editRequestStatus,
      reviewerId: clearReviewer ? null : (reviewerId ?? this.reviewerId),
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      reason: reason ?? this.reason,
      address: address ?? this.address,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoadingExisting: isLoadingExisting ?? this.isLoadingExisting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final createTripRequestControllerProvider =
    NotifierProvider.autoDispose<
      CreateTripRequestController,
      CreateTripRequestState
    >(CreateTripRequestController.new);

class CreateTripRequestController extends Notifier<CreateTripRequestState> {
  late RequestApi _api;

  @override
  CreateTripRequestState build() {
    _api = ref.watch(requestApiProvider);
    return const CreateTripRequestState();
  }

  void setReviewer(String? reviewerId) {
    state = state.copyWith(
      reviewerId: reviewerId,
      clearReviewer: reviewerId == null,
      clearError: true,
    );
  }

  void setStartDateTime(DateTime dt) {
    state = state.copyWith(startDateTime: dt, clearError: true);
  }

  void setEndDateTime(DateTime dt) {
    state = state.copyWith(endDateTime: dt, clearError: true);
  }

  void setReason(String reason) {
    state = state.copyWith(reason: reason, clearError: true);
  }

  void setAddress(String address) {
    state = state.copyWith(address: address, clearError: true);
  }

  Future<void> initForRequest(String requestId) async {
    state = state.copyWith(isLoadingExisting: true);
    try {
      final req = await _api.fetchRequestDetail(requestId);
      if (!ref.mounted) return;
      final start = parseRequestDateTime(req.startAt);
      final end = parseRequestDateTime(req.endAt);
      state = state.copyWith(
        editRequestId: req.id,
        editRequestStatus: req.requestStatus,
        reviewerId: req.reviewerId,
        startDateTime: start,
        endDateTime: end,
        reason: req.reason,
        address: req.address ?? '',
        isLoadingExisting: false,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoadingExisting: false,
        errorMessage: 'Không thể tải thông tin yêu cầu cần chỉnh sửa.',
      );
    }
  }

  void reset() {
    state = const CreateTripRequestState();
  }

  Future<bool> submit() async {
    if (state.reviewerId == null || state.reviewerId!.isEmpty) {
      state = state.copyWith(errorMessage: 'Vui lòng chọn người duyệt.');
      return false;
    }
    if (state.startDateTime == null) {
      state = state.copyWith(errorMessage: 'Vui lòng chọn thời điểm bắt đầu.');
      return false;
    }
    if (state.endDateTime == null) {
      state = state.copyWith(errorMessage: 'Vui lòng chọn thời điểm kết thúc.');
      return false;
    }
    if (state.endDateTime!.isBefore(state.startDateTime!)) {
      state = state.copyWith(
        errorMessage: 'Thời điểm kết thúc phải sau thời điểm bắt đầu.',
      );
      return false;
    }
    if (state.reason.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Vui lòng nhập lý do yêu cầu.');
      return false;
    }
    if (state.address.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Vui lòng nhập địa điểm công tác.');
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final auth = ref.read(authControllerProvider);
      final rootOrgId = auth.user?.rootOrganizationId;
      if (rootOrgId == null) {
        throw StateError('Tài khoản chưa có tổ chức gốc.');
      }

      String fmt(DateTime dt) {
        return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:00';
      }

      final draft = CreateRequestDraft(
        rootOrganizationId: rootOrgId,
        reviewerId: state.reviewerId!,
        leaveType: LeaveTypeEnum.businessTrip,
        startAt: fmt(state.startDateTime!),
        endAt: fmt(state.endDateTime!),
        reason: state.reason.trim(),
        address: state.address.trim(),
      );

      if (state.editRequestId != null &&
          state.editRequestStatus == AbsenceRequestStatus.returned) {
        await _api.updateRequest(state.editRequestId!, draft);
      } else {
        await _api.createRequest(draft);
      }

      if (!ref.mounted) return true;

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
