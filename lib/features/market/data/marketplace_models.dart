enum MarketplaceCategory {
  seeds('seeds', 'Seeds'),
  fertilizers('fertilizers', 'Fertilizers'),
  heavyMachinery('heavy_machinery', 'Machinery'),
  tools('tools', 'Tools'),
  herbicides('herbicides', 'Herbicides'),
  pesticides('pesticides', 'Pesticides'),
  other('other', 'Other');

  final String value;
  final String label;
  const MarketplaceCategory(this.value, this.label);

  static MarketplaceCategory? fromValue(String value) {
    for (final category in MarketplaceCategory.values) {
      if (category.value == value) return category;
    }
    return null;
  }
}

class MarketplaceProduct {
  final String id;
  final String name;
  final String description;
  final MarketplaceCategory? category;
  final List<String> problemKeywords;
  final double price;
  final String currency;
  final String affiliateUrl;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MarketplaceProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.problemKeywords,
    required this.price,
    required this.currency,
    required this.affiliateUrl,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory MarketplaceProduct.fromJson(Map<String, dynamic> json) {
    return MarketplaceProduct(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: MarketplaceCategory.fromValue(json['category']?.toString() ?? ''),
      problemKeywords: (json['problemKeywords'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? '',
      affiliateUrl: json['affiliateUrl']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  String get formattedPrice {
    switch (currency.toUpperCase()) {
      case 'GBP':
        return '£${price.toStringAsFixed(2)}';
      case 'USD':
        return '\$${price.toStringAsFixed(2)}';
      case 'EUR':
        return '€${price.toStringAsFixed(2)}';
      case 'INR':
        return '₹${price.toStringAsFixed(2)}';
      default:
        return '$currency ${price.toStringAsFixed(2)}';
    }
  }
}

class MarketplacePagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const MarketplacePagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory MarketplacePagination.fromJson(Map<String, dynamic> json) {
    return MarketplacePagination(
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
    );
  }
}

class MarketplaceProductPage {
  final List<MarketplaceProduct> items;
  final MarketplacePagination pagination;

  const MarketplaceProductPage({
    required this.items,
    required this.pagination,
  });

  factory MarketplaceProductPage.fromJson(Map<String, dynamic> json) {
    return MarketplaceProductPage(
      items: (json['items'] as List<dynamic>? ?? []).map((item) => MarketplaceProduct.fromJson(Map<String, dynamic>.from(item as Map))).toList(),
      pagination: MarketplacePagination.fromJson(Map<String, dynamic>.from(json['pagination'] as Map? ?? {})),
    );
  }
}