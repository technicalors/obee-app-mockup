import 'package:dio/dio.dart';
import 'package:obee_mobile/src/features/auth/data/user_tree_selection_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obee_mobile/src/core/network/api_client.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';

/// Exposes the schedule feature's transport layer through Riverpod so the UI
/// can stay focused on state and rendering.
final scheduleApiProvider = Provider<ScheduleApi>((ref) {
  return MobileScheduleApi(ref.watch(apiClientProvider));
});

/// Declares the mobile-facing schedule operations without leaking Dio details
/// into widgets or tests.
abstract interface class ScheduleApi {
  Future<List<UserTreeSelectionUser>> fetchUsers({
    required String rootOrganizationId,
  });

  Future<List<ScheduleModel>> fetchSchedules({
    CancelToken? cancelToken,
    DateTime? endTo,
    DateTime? endFrom,
    String? eventId,
    DateTime? startFrom,
    DateTime? startTo,
    String? userIds,
    required ScheduleVisibilityFilter visibility,
  });

  Future<ScheduleModel> fetchScheduleDetail(String scheduleId);

  Future<void> createSchedule(ScheduleDraft draft);

  Future<void> updateSchedule({
    required String scheduleEventId,
    required ScheduleDraft draft,
  });

  Future<void> deleteSchedule(String scheduleEventId);

  Future<void> joinSchedule(String scheduleEventId);

  Future<void> leaveSchedule(String scheduleEventId);
}

/// Concrete implementation that mirrors the existing backend routes exactly.
/// Every method forwards raw field names from the models so the mobile layer
/// does not invent a second contract.
final class MobileScheduleApi implements ScheduleApi {
  const MobileScheduleApi(this._api);

  final ApiClient _api;

  @override
  Future<void> createSchedule(ScheduleDraft draft) {
    // Create and update share the same serialized draft shape, so all request
    // contract decisions live in [ScheduleDraft.toJson].
    return _api.postVoid('/schedule-events', data: draft.toRequestJson());
  }

  @override
  Future<void> deleteSchedule(String scheduleEventId) {
    return _api.delete('/schedule-events/$scheduleEventId');
  }

  @override
  Future<ScheduleModel> fetchScheduleDetail(String scheduleId) async {
    // The backend detail endpoint returns a single normalized schedule row
    // including its nested event metadata.
    final body = await _api.get<Map<String, dynamic>>('/schedules/$scheduleId');

    return ScheduleModel.fromJson(body);
  }

  @override
  Future<List<ScheduleModel>> fetchSchedules({
    CancelToken? cancelToken,
    DateTime? endTo,
    DateTime? endFrom,
    String? eventId,
    DateTime? startFrom,
    DateTime? startTo,
    String? userIds,
    required ScheduleVisibilityFilter visibility,
  }) async {
    final queryParameters = <String, Object>{
      'visibility': visibility.wireValue,
    };

    if (endFrom != null) {
      queryParameters['end_from'] = _formatScheduleQueryDate(endFrom);
    }

    if (startTo != null) {
      queryParameters['start_to'] = _formatScheduleQueryDate(startTo);
    }

    if (eventId != null) {
      queryParameters['event_id'] = eventId;
    }

    if (startFrom != null) {
      queryParameters['start_from'] = _formatScheduleQueryDate(startFrom);
    }

    if (endTo != null) {
      queryParameters['end_to'] = _formatScheduleQueryDate(endTo);
    }

    if (userIds != null) {
      queryParameters['user_ids'] = userIds;
    }

    final body = await _api.get<List<dynamic>>(
      '/schedules',
      cancelToken: cancelToken,
      queryParameters: queryParameters,
    );

    return body
        .cast<Map<String, Object?>>()
        .map(ScheduleModel.fromJson)
        .toList(growable: false);
  }

  @override
  Future<List<UserTreeSelectionUser>> fetchUsers({
    required String rootOrganizationId,
  }) async {
    // User selection follows the same scoped tree contract as the web.
    final body = await _api.get<List<dynamic>>(
      '/users/tree',
      queryParameters: {'root_organization_id': rootOrganizationId},
    );

    return body
        .cast<Map<String, dynamic>>()
        .map(UserTreeSelectionUser.fromJson)
        .toList(growable: false);
  }

  @override
  Future<void> joinSchedule(String scheduleEventId) {
    return _api.postVoid('/schedule-events/$scheduleEventId/join');
  }

  @override
  Future<void> leaveSchedule(String scheduleEventId) {
    return _api.postVoid('/schedule-events/$scheduleEventId/leave');
  }

  @override
  Future<void> updateSchedule({
    required String scheduleEventId,
    required ScheduleDraft draft,
  }) {
    // ApiClient originally had POST and DELETE void helpers, so schedule edit
    // added the symmetrical PUT variant and uses it here.
    return _api.putVoid(
      '/schedule-events/$scheduleEventId',
      data: draft.toRequestJson(),
    );
  }
}

String _formatScheduleQueryDate(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
