import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/core/network/api_client.dart';
import 'package:obee_mobile/src/features/requests/data/request_api.dart';
import 'package:obee_mobile/src/features/requests/data/request_enums.dart';
import 'package:obee_mobile/src/features/requests/data/request_models.dart';

import 'support/request_fixtures.dart';

void main() {
  test('empty server result stays empty after a populated fetch', () async {
    var empty = false;
    final api = _api(
      (_) async => _response(empty ? [] : [initialDemoRequests.first.toJson()]),
    );
    expect(await api.fetchRequests(), hasLength(1));
    empty = true;
    expect(await api.fetchRequests(), isEmpty);
  });

  test(
    'malformed list fails instead of becoming an empty or demo list',
    () async {
      final api = _api((_) async => _response({'unexpected': []}));
      await expectLater(api.fetchRequests(), throwsA(isA<DioException>()));
    },
  );

  for (final failure in ['timeout', 'forbidden', 'validation']) {
    test(
      'all live operations propagate $failure without fabricating data',
      () async {
        final api = _api((options) async {
          if (failure == 'timeout') {
            throw DioException(
              requestOptions: options,
              type: DioExceptionType.receiveTimeout,
            );
          }
          return _response({
            'message': failure,
          }, status: failure == 'forbidden' ? 403 : 422);
        });
        final operations = <Future<Object?> Function()>[
          () => api.fetchMyWorkShifts(from: '2026-10-10', to: '2026-10-10'),
          () => api.fetchRequests(),
          () => api.fetchRequestDetail('req-1'),
          () => api.fetchLeaveBalance(asOf: '2026-10-06'),
          () => api.createRequest(_draft),
          () => api.updateRequest('req-1', _draft),
          () => api.approveRequest('req-1'),
          () => api.rejectRequest('req-1'),
          () => api.returnRequest('req-1', note: 'Bổ sung thông tin'),
          () => api.cancelRequest('req-1'),
          () => api.fetchReviewers(
            rootOrganizationId: 'org-root',
            requesterId: 'user-huu',
          ),
          () => api.fetchEmployees(rootOrganizationId: 'org-root'),
        ];
        for (final operation in operations) {
          await expectLater(operation(), throwsA(isA<DioException>()));
        }
      },
    );
  }

  test(
    'reviewers use permission filter and exclude requester; employees remain unfiltered',
    () async {
      final requests = <RequestOptions>[];
      final api = _api((options) async {
        requests.add(options);
        return _response(demoReviewers.map((user) => user.toJson()).toList());
      });
      final reviewers = await api.fetchReviewers(
        rootOrganizationId: 'org-root',
        requesterId: 'user-huu',
      );
      expect(reviewers.map((user) => user.id), ['user-loan', 'user-huynh']);
      expect(requests.first.queryParameters, {
        'root_organization_id': 'org-root',
        'permission_name': 'absence-requests.review',
      });
      final employees = await api.fetchEmployees(
        rootOrganizationId: 'org-root',
      );
      expect(employees.map((user) => user.id), contains('user-huu'));
      expect(requests.last.queryParameters, {
        'root_organization_id': 'org-root',
      });
    },
  );

  test('empty eligible reviewer result remains empty', () async {
    final api = _api((_) async => _response([]));
    expect(
      await api.fetchReviewers(
        rootOrganizationId: 'org-root',
        requesterId: 'user-huu',
      ),
      isEmpty,
    );
  });

  test(
    'balance forwards selected date and preserves authoritative values',
    () async {
      late RequestOptions request;
      final api = _api((options) async {
        request = options;
        return _response({
          'entitlement': 12,
          'used': 3.5,
          'remaining': 8.5,
          'cycle_start': '2026-01-01',
          'cycle_end': '2026-12-31',
        });
      });
      final balance = await api.fetchLeaveBalance(asOf: '2026-10-06');
      expect(request.queryParameters, {'as_of': '2026-10-06'});
      expect(balance.remaining, 8.5);
    },
  );

  test('revision note is required at the API boundary', () {
    final api = _api((_) async => _response({}));
    expect(
      () => api.returnRequest('req-1', note: ' \n '),
      throwsFormatException,
    );
  });
}

const _draft = CreateRequestDraft(
  rootOrganizationId: 'org-root',
  reviewerId: 'user-huu',
  leaveType: LeaveTypeEnum.annual,
  startAt: '2026-10-06 10:00:00',
  endAt: '2026-10-06 12:00:00',
  reason: 'Lý do nghỉ',
);

MobileRequestApi _api(Future<ResponseBody> Function(RequestOptions) handler) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'));
  dio.httpClientAdapter = _Adapter(handler);
  addTearDown(() => dio.close(force: true));
  return MobileRequestApi(ApiClient(dio));
}

ResponseBody _response(Object body, {int status = 200}) =>
    ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler);
  final Future<ResponseBody> Function(RequestOptions) handler;
  @override
  void close({bool force = false}) {}
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => handler(options);
}
