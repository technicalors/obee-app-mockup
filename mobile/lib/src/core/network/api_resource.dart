import 'package:obee_mobile/src/core/network/paginated_list.dart';
import 'package:obee_mobile/src/core/network/api_client.dart';

typedef JsonObject = Map<String, dynamic>;
typedef FromJson<T> = T Function(JsonObject json);

final class ApiResource<T> {
  const ApiResource({
    required this.api,
    required this.endpoint,
    required this.fromJson,
  });

  final ApiClient api;
  final String endpoint;
  final FromJson<T> fromJson;

  Future<List<T>> getAll({Map<String, Object?>? queryParameters}) async {
    final body = await api.get<List<dynamic>>(
      endpoint,
      queryParameters: queryParameters,
    );

    return body.cast<JsonObject>().map(fromJson).toList(growable: false);
  }

  Future<PaginatedList<T>> getPage({
    required int page,
    required int perPage,
    Map<String, Object?>? queryParameters,
  }) async {
    final body = await api.get<JsonObject>(
      endpoint,
      queryParameters: {...?queryParameters, 'page': page, 'per_page': perPage},
    );
    return PaginatedList.fromJson(body, fromJson);
  }

  Future<T> findById(String id) async {
    final body = await api.get<JsonObject>('$endpoint/$id');

    return fromJson(body);
  }

  Future<T> create(Object body) async {
    final response = await api.post<JsonObject>(endpoint, data: body);

    return fromJson(response);
  }

  Future<T> update(String id, Object body) async {
    final response = await api.put<JsonObject>('$endpoint/$id', data: body);

    return fromJson(response);
  }

  Future<void> deleteById(String id) {
    return api.delete('$endpoint/$id');
  }
}
