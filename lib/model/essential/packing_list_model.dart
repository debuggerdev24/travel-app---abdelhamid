class PackingListResponse {
  final List<PackingCategory> categories;

  PackingListResponse({required this.categories});

  factory PackingListResponse.fromJson(Map<String, dynamic> json) {
    // Backend returns: { packingList: { categories: [...] } }
    final packingList = (json['packingList'] as Map?)?.cast<String, dynamic>();
    final rawCategories =
        (packingList?['categories'] as List?)?.cast<dynamic>() ?? const [];

    return PackingListResponse(
      categories: rawCategories
          .whereType<Map>()
          .map((e) => PackingCategory.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }
}

class PackingCategory {
  final String id;
  final String title;
  final List<PackingItem> items;

  PackingCategory({
    required this.id,
    required this.title,
    required this.items,
  });

  factory PackingCategory.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List?)?.cast<dynamic>() ?? const [];
    final items = rawItems
        .whereType<Map>()
        .map((e) => PackingItem.fromJson(e.cast<String, dynamic>()))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return PackingCategory(
      id: (json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      items: items,
    );
  }
}

class PackingItem {
  final String id;
  final String name;
  final int order;

  PackingItem({
    required this.id,
    required this.name,
    required this.order,
  });

  factory PackingItem.fromJson(Map<String, dynamic> json) {
    return PackingItem(
      id: (json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      order: (json['order'] is int)
          ? json['order'] as int
          : int.tryParse((json['order'] ?? '0').toString()) ?? 0,
    );
  }
}

