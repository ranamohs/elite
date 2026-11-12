import '../../../category_catalog/data/models/catalog_model.dart';

void check(bool condition, String message) {
  if (!condition) throw StateError(message);
}

void main() {
  final product = CatalogPage.fromJson({
    'data': [
      {
        'id': 1,
        'name': {'ar': 'سخان', 'en': 'Heater'},
        'description': {'en': '<p>Vertical model</p><p>&nbsp;</p>'},
        'price': {
          'label': {'original': '1,500', 'currency': 'ر.ع'},
          'value': 1500,
        },
        'image': '/media/heater.webp',
        'stock': 0,
      },
    ],
  }, isProduct: true);
  final item = product.items.single;
  check(item.price == 1500 && item.priceLabel == '1,500 ر.ع', 'Product price');
  check(item.details(false) == 'Vertical model', 'HTML description');
  check(
    item.image == 'http://elitefm-eg.online/media/heater.webp',
    'Relative image URL',
  );
  check(
    item.stock == 0 && product.total == 1 && product.lastPage == 1,
    'Stock and unpaginated products',
  );
  final services = CatalogPage.fromJson({
    'data': [
      {
        'id': 1,
        'name': {'ar': 'تركيب'},
        'description': {'ar': 'مصنعية فقط'},
        'price': {'label': '600.000 ر.ع', 'value': '600.000'},
        'thumbnail': '/media/service.webp',
      },
    ],
    'meta': {'current_page': 2, 'last_page': 3, 'total': 25},
  }, isProduct: false);
  final service = services.items.single;
  check(service.price == 600 && service.currency == 'ر.ع', 'Service price');
  check(service.title(false) == 'تركيب', 'Missing locale fallback');
  check(
    service.key != item.key,
    'Product and service IDs must remain distinct',
  );
  check(
    services.currentPage == 2 && services.lastPage == 3 && services.total == 25,
    'Pagination',
  );
  print('Passed 8 catalog model checks.');
}
