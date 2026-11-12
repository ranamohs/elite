import '../../../../core/constants/end_points.dart';

class CatalogItem {
  final int id;
  final Map<String, dynamic> name, description;
  final double price;
  final String priceLabel, currency, image;
  final int? stock;
  final bool isProduct;

  const CatalogItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.priceLabel,
    required this.currency,
    required this.image,
    required this.isProduct,
    this.stock,
  });

  String get key => '${isProduct ? 'product' : 'service'}:$id';
  String localized(Map<String, dynamic> value, bool ar) =>
      (value[ar ? 'ar' : 'en'] ?? value[ar ? 'en' : 'ar'] ?? '').toString();
  String title(bool ar) => localized(name, ar);
  String details(bool ar) => localized(description, ar)
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  factory CatalogItem.fromJson(
      Map<String, dynamic> json, {
        required bool isProduct,
      }) {
    final price = json['price'] as Map<String, dynamic>? ?? {};
    final label = price['label'];
    final rawImage = (json['image'] ?? json['thumbnail'] ?? '').toString();
    Map<String, dynamic> localized(dynamic value) => value is Map
        ? Map<String, dynamic>.from(value)
        : {'ar': value ?? '', 'en': value ?? ''};
    return CatalogItem(
      id: (json['id'] as num).toInt(),
      name: localized(json['name']),
      description: localized(json['description']),
      price: double.tryParse('${price['value']}') ?? 0,
      priceLabel: label is Map
          ? '${label['original'] ?? price['value']} ${label['currency'] ?? ''}'
          .trim()
          : '${label ?? price['value'] ?? ''}',
      currency: label is Map
          ? '${label['currency'] ?? ''}'
          : (label?.toString().replaceFirst(RegExp(r'^[\d.,\s]+'), '').trim() ??
          ''),
      image: rawImage.isEmpty
          ? ''
          : Uri.parse(EndPoints.IMAGE_BASE_URL).resolve(rawImage).toString(),
      stock: json['stock'] == null ? null : int.tryParse('${json['stock']}'),
      isProduct: isProduct,
    );
  }
}

class CatalogPage {
  final List<CatalogItem> items;
  final int currentPage, lastPage, total;
  const CatalogPage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
  factory CatalogPage.fromJson(
      Map<String, dynamic> json, {
        required bool isProduct,
      }) {
    final items = (json['data'] as List)
        .map(
          (e) => CatalogItem.fromJson(
        Map<String, dynamic>.from(e as Map),
        isProduct: isProduct,
      ),
    )
        .toList();
    final meta = json['meta'] as Map?;
    return CatalogPage(
      items: items,
      currentPage: (meta?['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (meta?['last_page'] as num?)?.toInt() ?? 1,
      total: (meta?['total'] as num?)?.toInt() ?? items.length,
    );
  }
}
