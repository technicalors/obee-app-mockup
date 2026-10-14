import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obee_mobile/src/core/network/api_client.dart';
import 'package:obee_mobile/src/features/auth/data/user_tree_selection_user.dart';
import 'package:obee_mobile/src/features/requests/data/request_models.dart';

final requestApiProvider = Provider<RequestApi>((ref) {
  return MobileRequestApi(ref.watch(apiClientProvider));
});

abstract interface class RequestApi {
  Future<List<WorkUserShiftModel>> fetchMyWorkShifts({
    required String from,
    required String to,
  });

  Future<List<AbsenceRequestModel>> fetchRequests({
    String? status,
    String? leaveType,
    String? from,
    String? to,
    String? reviewerId,
  });

  Future<AbsenceRequestModel> fetchRequestDetail(String id);

  Future<LeaveBalanceModel> fetchLeaveBalance({String? asOf});

  Future<LeaveCoveragePreviewModel> previewLeaveCoverage({
    required String rootOrganizationId,
    required String leaveType,
    required String startAt,
    required String endAt,
  });

  Future<AbsenceRequestModel> createRequest(CreateRequestDraft draft);

  Future<AbsenceRequestModel> updateRequest(
    String id,
    CreateRequestDraft draft,
  );

  Future<void> approveRequest(String id, {String? note});

  Future<void> rejectRequest(String id, {String? note});

  Future<void> returnRequest(String id, {required String note});

  Future<void> cancelRequest(String id);

  Future<List<UserTreeSelectionUser>> fetchReviewers({
    required String rootOrganizationId,
    required String requesterId,
  });

  Future<List<UserTreeSelectionUser>> fetchEmployees({
    required String rootOrganizationId,
  });
}

final class MobileRequestApi implements RequestApi {
  MobileRequestApi(this._api);

  final ApiClient _api;

  @override
  Future<List<WorkUserShiftModel>> fetchMyWorkShifts({
    required String from,
    required String to,
  }) async {
    final body = await _api.get<List<dynamic>>(
      '/work-user-shifts/mine',
      queryParameters: {'from': from, 'to': to},
    );
    return body
        .cast<Map<String, dynamic>>()
        .map(WorkUserShiftModel.fromJson)
        .toList(growable: false);
  }

  @override
  Future<List<AbsenceRequestModel>> fetchRequests({
    String? status,
    String? leaveType,
    String? from,
    String? to,
    String? reviewerId,
  }) async {
    final body = await _api.get<List<dynamic>>(
      '/absence-requests',
      queryParameters: {
        'status': ?status,
        'leave_type': ?leaveType,
        'from': ?from,
        'to': ?to,
        'reviewer_id': ?reviewerId,
      },
    );
    return body
        .cast<Map<String, dynamic>>()
        .map(AbsenceRequestModel.fromJson)
        .toList(growable: false);
  }

  @override
  Future<AbsenceRequestModel> fetchRequestDetail(String id) async {
    return AbsenceRequestModel.fromJson(
      await _api.get<Map<String, dynamic>>('/absence-requests/$id'),
    );
  }

  @override
  Future<LeaveBalanceModel> fetchLeaveBalance({String? asOf}) async {
    return LeaveBalanceModel.fromJson(
      await _api.get<Map<String, dynamic>>(
        '/absence-requests/leave-balance',
        queryParameters: {'as_of': ?asOf},
      ),
    );
  }

  @override
  Future<LeaveCoveragePreviewModel> previewLeaveCoverage({
    required String rootOrganizationId,
    required String leaveType,
    required String startAt,
    required String endAt,
  }) async {
    final body = await _api.get<Map<String, dynamic>>(
      '/absence-requests/preview-coverage',
      queryParameters: {
        'root_organization_id': rootOrganizationId,
        'leave_type': leaveType,
        'start_at': startAt,
        'end_at': endAt,
      },
    );
    return LeaveCoveragePreviewModel.fromJson(body);
  }

  @override
  Future<AbsenceRequestModel> createRequest(CreateRequestDraft draft) async {
    return AbsenceRequestModel.fromJson(
      await _api.post<Map<String, dynamic>>(
        '/absence-requests',
        data: draft.toJson(),
      ),
    );
  }

  @override
  Future<AbsenceRequestModel> updateRequest(
    String id,
    CreateRequestDraft draft,
  ) async {
    return AbsenceRequestModel.fromJson(
      await _api.put<Map<String, dynamic>>(
        '/absence-requests/$id',
        data: draft.toUpdateJson(),
      ),
    );
  }

  @override
  Future<void> approveRequest(String id, {String? note}) {
    return _api.postVoid(
      '/absence-requests/$id/approve',
      data: {'approval_note': ?note},
    );
  }

  @override
  Future<void> rejectRequest(String id, {String? note}) {
    return _api.postVoid(
      '/absence-requests/$id/reject',
      data: {'approval_note': ?note},
    );
  }

  @override
  Future<void> returnRequest(String id, {required String note}) {
    if (note.trim().isEmpty) {
      throw const FormatException(
        'Nội dung cần điều chỉnh không được để trống.',
      );
    }
    return _api.postVoid(
      '/absence-requests/$id/return',
      data: {'approval_note': note.trim()},
    );
  }

  @override
  Future<void> cancelRequest(String id) => _api.delete('/absence-requests/$id');

  @override
  Future<List<UserTreeSelectionUser>> fetchReviewers({
    required String rootOrganizationId,
    required String requesterId,
  }) async {
    final body = await _api.get<List<dynamic>>(
      '/users/tree',
      queryParameters: {
        'root_organization_id': rootOrganizationId,
        'permission_name': 'absence-requests.review',
      },
    );
    return body
        .cast<Map<String, dynamic>>()
        .map(UserTreeSelectionUser.fromJson)
        .where((user) => user.id != requesterId)
        .toList(growable: false);
  }

  @override
  Future<List<UserTreeSelectionUser>> fetchEmployees({
    required String rootOrganizationId,
  }) async {
    final body = await _api.get<List<dynamic>>(
      '/users/tree',
      queryParameters: {'root_organization_id': rootOrganizationId},
    );
    return body
        .cast<Map<String, dynamic>>()
        .map(UserTreeSelectionUser.fromJson)
        .toList(growable: false);
  }
}
