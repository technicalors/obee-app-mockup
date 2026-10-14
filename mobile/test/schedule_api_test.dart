import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/core/network/api_client.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_api.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_enums.dart';
import 'package:obee_mobile/src/features/schedule/data/schedule_models.dart';

void main() {
  test(
    'fetchSchedules loads event occurrences without calendar filters',
    () async {
      late RequestOptions capturedOptions;
      final api = _scheduleApi((options) {
        capturedOptions = options;
        return Future.value(
          _jsonResponse([
            {
              'id': 'regenerated-schedule',
              'event_id': 'event-1',
              'start': '2026-06-10T09:00:00+07:00',
              'end': '2026-06-10T10:00:00+07:00',
              'one_day': true,
              'remind_at': null,
              'event': _eventJson(),
            },
          ]),
        );
      });

      final schedules = await api.fetchSchedules(
        eventId: 'event-1',
        visibility: ScheduleVisibilityFilter.all,
      );

      expect(capturedOptions.method, 'GET');
      expect(capturedOptions.path, '/schedules');
      expect(capturedOptions.queryParameters, {
        'event_id': 'event-1',
        'visibility': 'all',
      });
      expect(schedules.single.id, 'regenerated-schedule');
      expect(schedules.single.event.id, 'event-1');
    },
  );

  // This test protects the month-loading contract that drives the whole page.
  test(
    'fetchSchedules hits the schedule endpoint with visible-range filters',
    () async {
      late RequestOptions capturedOptions;
      final api = _scheduleApi((options) {
        capturedOptions = options;

        return Future.value(
          _jsonResponse([
            {
              'id': 'schedule-1',
              'event_id': 'event-1',
              'start': '2026-06-10T09:00:00+07:00',
              'end': '2026-06-10T10:00:00+07:00',
              'one_day': true,
              'remind_at': null,
              'event': _eventJson(),
            },
          ]),
        );
      });

      final schedules = await api.fetchSchedules(
        endFrom: DateTime(2026, 6, 1),
        startTo: DateTime(2026, 7, 5),
        visibility: ScheduleVisibilityFilter.participated,
      );

      expect(capturedOptions.method, 'GET');
      expect(capturedOptions.path, '/schedules');
      expect(capturedOptions.queryParameters, {
        'end_from': '2026-06-01',
        'start_to': '2026-07-05',
        'visibility': 'participated',
      });
      expect(schedules.single.event.title, 'Planning Meeting');
      expect(schedules.single.start, DateTime(2026, 6, 10, 9));
      expect(schedules.single.event.startDate, DateTime(2026, 6, 10));
    },
  );

  test(
    'fetchSchedules forwards a selected user filter through user_ids',
    () async {
      late RequestOptions capturedOptions;
      final api = _scheduleApi((options) {
        capturedOptions = options;

        return Future.value(
          _jsonResponse([
            {
              'id': 'schedule-1',
              'event_id': 'event-1',
              'start': '2026-06-10T09:00:00+07:00',
              'end': '2026-06-10T10:00:00+07:00',
              'one_day': true,
              'remind_at': null,
              'event': _eventJson(),
            },
          ]),
        );
      });

      await api.fetchSchedules(
        endFrom: DateTime(2026, 6, 1),
        startTo: DateTime(2026, 7, 5),
        userIds: 'user-2',
        visibility: ScheduleVisibilityFilter.all,
      );

      expect(capturedOptions.queryParameters, {
        'end_from': '2026-06-01',
        'start_to': '2026-07-05',
        'user_ids': 'user-2',
        'visibility': 'all',
      });
    },
  );

  // Creation is verified at the raw request layer so accidental field renames
  // or missing payload keys are caught before widget tests need to debug them.
  test('createSchedule posts the raw schedule payload', () async {
    late RequestOptions capturedOptions;
    final api = _scheduleApi((options) {
      capturedOptions = options;
      return Future.value(ResponseBody.fromString('', 204));
    });

    await api.createSchedule(
      ScheduleDraft.forCreate(
        currentUserId: 'user-1',
        selectedDate: DateTime(2026, 6, 10),
      ),
    );

    expect(capturedOptions.method, 'POST');
    expect(capturedOptions.path, '/schedule-events');
    expect(capturedOptions.data, containsPair('schedule_type', 'ordinary'));
    expect(capturedOptions.data, containsPair('start_date', '2026-06-10'));
    expect(capturedOptions.data, containsPair('end_date', '2026-06-10'));
    expect(capturedOptions.data, containsPair('participants', ['user-1']));
  });

  test(
    'createSchedule posts repeat pattern integers for repeat schedules',
    () async {
      late RequestOptions capturedOptions;
      final api = _scheduleApi((options) {
        capturedOptions = options;
        return Future.value(ResponseBody.fromString('', 204));
      });

      await api.createSchedule(
        ScheduleDraft(
          title: 'Weekly planning',
          type: ScheduleEventType.meeting,
          scheduleType: ScheduleEventScheduleType.repeat,
          startDate: DateTime(2026, 6, 10, 8),
          endDate: DateTime(2026, 6, 30, 17),
          repeatType: ScheduleEventRepeatType.weekly,
          repeatPattern: const [1, 3, 5],
          startTime: '08:00',
          endTime: '17:00',
          note: null,
          physicalAddress: 'HQ',
          privacy: ScheduleEventPrivacy.public,
          isGeneral: false,
          remindRange: null,
          remindValue: null,
          participants: const ['user-1'],
          observers: const [],
        ),
      );

      expect(capturedOptions.data, containsPair('repeat_type', 'weekly'));
      expect(capturedOptions.data, containsPair('repeat_pattern', [1, 3, 5]));
    },
  );
}

/// Builds the real API class on top of a fake adapter so the tests exercise the
/// production request code without network access.
MobileScheduleApi _scheduleApi(
  Future<ResponseBody> Function(RequestOptions options) handle,
) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
  dio.httpClientAdapter = _FakeAdapter(handle);

  return MobileScheduleApi(ApiClient(dio));
}

/// Produces a minimal JSON response body with the content-type Dio expects for
/// automatic decoding.
ResponseBody _jsonResponse(Object body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

/// Canonical schedule event fixture shared by the request/parse assertions.
Map<String, Object?> _eventJson() {
  return {
    'id': 'event-1',
    'title': 'Planning Meeting',
    'type': 'meeting',
    'schedule_type': 'ordinary',
    'start_date': '2026-06-10',
    'end_date': '2026-06-10',
    'repeat_type': null,
    'repeat_pattern': null,
    'start_time': '09:00',
    'end_time': '10:00',
    'note': null,
    'physical_address': 'HQ',
    'privacy': 'public',
    'is_general': false,
    'remind_range': null,
    'remind_value': null,
    'created_by': 'user-1',
    'updated_by': null,
    'created_at': '2026-06-01T00:00:00+07:00',
    'updated_at': '2026-06-01T00:00:00+07:00',
    'participants': [
      {'id': 'user-1', 'name': 'Lan', 'avatar': null, 'email': null},
    ],
    'observers': [],
  };
}

/// Tiny adapter seam that captures outbound requests and returns canned
/// responses synchronously.
final class _FakeAdapter implements HttpClientAdapter {
  const _FakeAdapter(this.handle);

  final Future<ResponseBody> Function(RequestOptions options) handle;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handle(options);
  }
}
