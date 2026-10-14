import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obee_mobile/src/core/network/api_client.dart';
import 'package:obee_mobile/src/core/network/api_resource.dart';

void main() {
  test('getAll fetches a collection from the resource endpoint', () async {
    late RequestOptions capturedOptions;
    final resource = _sampleResource((options) {
      capturedOptions = options;

      return Future.value(
        _jsonResponse([
          {'id': '1', 'name': 'Alpha'},
          {'id': '2', 'name': 'Beta'},
        ]),
      );
    });

    final samples = await resource.getAll(queryParameters: {'active': true});

    expect(capturedOptions.method, 'GET');
    expect(capturedOptions.path, '/samples');
    expect(capturedOptions.queryParameters, {'active': true});
    expect(samples.map((sample) => sample.name), ['Alpha', 'Beta']);
  });

  test('findById fetches a single resource', () async {
    late RequestOptions capturedOptions;
    final resource = _sampleResource((options) {
      capturedOptions = options;

      return Future.value(_jsonResponse({'id': '1', 'name': 'Alpha'}));
    });

    final sample = await resource.findById('1');

    expect(capturedOptions.method, 'GET');
    expect(capturedOptions.path, '/samples/1');
    expect(sample.name, 'Alpha');
  });

  test('create posts a resource body', () async {
    late RequestOptions capturedOptions;
    final resource = _sampleResource((options) {
      capturedOptions = options;

      return Future.value(_jsonResponse({'id': '1', 'name': 'Alpha'}));
    });

    final sample = await resource.create({'name': 'Alpha'});

    expect(capturedOptions.method, 'POST');
    expect(capturedOptions.path, '/samples');
    expect(capturedOptions.data, {'name': 'Alpha'});
    expect(sample.id, '1');
  });

  test('update puts a resource body', () async {
    late RequestOptions capturedOptions;
    final resource = _sampleResource((options) {
      capturedOptions = options;

      return Future.value(_jsonResponse({'id': '1', 'name': 'Updated'}));
    });

    final sample = await resource.update('1', {'name': 'Updated'});

    expect(capturedOptions.method, 'PUT');
    expect(capturedOptions.path, '/samples/1');
    expect(capturedOptions.data, {'name': 'Updated'});
    expect(sample.name, 'Updated');
  });

  test('deleteById deletes a resource', () async {
    late RequestOptions capturedOptions;
    final resource = _sampleResource((options) {
      capturedOptions = options;

      return Future.value(ResponseBody.fromString('', 204));
    });

    await resource.deleteById('1');

    expect(capturedOptions.method, 'DELETE');
    expect(capturedOptions.path, '/samples/1');
  });
}

ApiResource<_Sample> _sampleResource(
  Future<ResponseBody> Function(RequestOptions options) handle,
) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
  dio.httpClientAdapter = _FakeAdapter(handle);

  return ApiResource<_Sample>(
    api: ApiClient(dio),
    endpoint: '/samples',
    fromJson: _Sample.fromJson,
  );
}

ResponseBody _jsonResponse(Object body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

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

final class _Sample {
  const _Sample({required this.id, required this.name});

  factory _Sample.fromJson(JsonObject json) {
    return _Sample(id: json['id'] as String, name: json['name'] as String);
  }

  final String id;
  final String name;
}
