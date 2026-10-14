final class PaginationMeta {
  const PaginationMeta({
    required this.page,
    required this.perPage,
    required this.total,
    required this.hasNext,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    final page = json['page'];
    final perPage = json['per_page'];
    final total = json['total'];
    final hasNext = json['has_next'];
    if (page is! int || perPage is! int || total is! int || hasNext is! bool) {
      throw const FormatException('Invalid pagination metadata.');
    }
    return PaginationMeta(
      page: page,
      perPage: perPage,
      total: total,
      hasNext: hasNext,
    );
  }

  final int page;
  final int perPage;
  final int total;
  final bool hasNext;
}

final class PaginatedList<T> {
  const PaginatedList({required this.items, required this.pagination});

  factory PaginatedList.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parseItem,
  ) {
    final items = json['items'];
    final pagination = json['pagination'];
    if (items is! List || pagination is! Map<String, dynamic>) {
      throw const FormatException('Expected items and pagination.');
    }
    return PaginatedList(
      items: items
          .cast<Map<String, dynamic>>()
          .map(parseItem)
          .toList(growable: false),
      pagination: PaginationMeta.fromJson(pagination),
    );
  }

  final List<T> items;
  final PaginationMeta pagination;
}
