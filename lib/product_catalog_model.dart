class ProductCatalogItem {
  const ProductCatalogItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.priceLabel,
    required this.icon,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final String priceLabel;
  final String icon;

  factory ProductCatalogItem.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    if (rawId == null) {
      throw const FormatException('A product must have an id.');
    }
    final rawPrice = json['price'];
    final rawType = json['type'];
    final rawCategory = (json['category']?.toString() ?? 'Product')
        .replaceAll('Products', 'Product')
        .replaceAll('Items', 'Item')
        .replaceAll('Services', 'Service');

    return ProductCatalogItem(
      id: rawId.toString(),
      name: json['name'] as String,
      description: json['description'] as String,
      category: rawCategory,
      priceLabel:
          json['priceLabel']?.toString() ??
          (rawPrice is num
              ? '\$${rawPrice.toStringAsFixed(2)}'
              : rawType?.toString() ?? 'Included'),
      icon: json['icon'] as String? ?? _iconForCategory(rawCategory),
    );
  }

  static String _iconForCategory(String category) {
    switch (category) {
      case 'Item':
        return 'controller';
      case 'Service':
        return 'support_agent';
      default:
        return 'workspace_premium';
    }
  }
}
