import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obee_mobile/src/features/requests/data/request_api.dart';
import 'package:obee_mobile/src/features/requests/data/request_models.dart';
import 'package:obee_mobile/src/features/requests/state/request_list_controller.dart';

@immutable
class RequestDetailState {
  const RequestDetailState({
    this.request,
    this.isLoading = false,
    this.errorMessage,
  });

  final AbsenceRequestModel? request;
  final bool isLoading;
  final String? errorMessage;

  RequestDetailState copyWith({
    AbsenceRequestModel? request,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RequestDetailState(
      request: request ?? this.request,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final requestDetailControllerProvider = NotifierProvider.autoDispose
    .family<RequestDetailController, RequestDetailState, String>(
      RequestDetailController.new,
    );

class RequestDetailController extends Notifier<RequestDetailState> {
  RequestDetailController(this.id);

  final String id;
  late RequestApi _api;

  @override
  RequestDetailState build() {
    _api = ref.watch(requestApiProvider);
    Future.microtask(loadDetail);
    return const RequestDetailState(isLoading: true);
  }

  Future<void> loadDetail() async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final model = await _api.fetchRequestDetail(id);
      if (!ref.mounted) return;
      state = state.copyWith(request: model, isLoading: false);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải chi tiết yêu cầu.',
      );
    }
  }

  Future<bool> approve({String? note}) async {
    state = state.copyWith(clearError: true);
    try {
      await _api.approveRequest(id, note: note);
      if (!ref.mounted) return true;
      await loadDetail();
      if (!ref.mounted) return true;
      unawaited(ref.read(requestListControllerProvider.notifier).refresh());
      return true;
    } catch (_) {
      if (ref.mounted) {
        state = state.copyWith(errorMessage: 'Không thể chấp thuận yêu cầu.');
      }
      return false;
    }
  }

  Future<bool> reject({String? note}) async {
    state = state.copyWith(clearError: true);
    try {
      await _api.rejectRequest(id, note: note);
      if (!ref.mounted) return true;
      await loadDetail();
      if (!ref.mounted) return true;
      unawaited(ref.read(requestListControllerProvider.notifier).refresh());
      return true;
    } catch (_) {
      if (ref.mounted) {
        state = state.copyWith(errorMessage: 'Không thể từ chối yêu cầu.');
      }
      return false;
    }
  }

  Future<bool> returnForRevision({required String note}) async {
    state = state.copyWith(clearError: true);
    try {
      await _api.returnRequest(id, note: note);
      if (!ref.mounted) return true;
      await loadDetail();
      if (!ref.mounted) return true;
      unawaited(ref.read(requestListControllerProvider.notifier).refresh());
      return true;
    } catch (_) {
      if (ref.mounted) {
        state = state.copyWith(errorMessage: 'Không thể yêu cầu điều chỉnh.');
      }
      return false;
    }
  }

  Future<bool> cancel() async {
    state = state.copyWith(clearError: true);
    try {
      await _api.cancelRequest(id);
      if (!ref.mounted) return true;
      unawaited(ref.read(requestListControllerProvider.notifier).refresh());
      return true;
    } catch (_) {
      if (ref.mounted) {
        state = state.copyWith(errorMessage: 'Không thể hủy yêu cầu.');
      }
      return false;
    }
  }
}
