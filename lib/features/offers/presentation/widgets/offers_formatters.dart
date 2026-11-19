import '../../data/models/offers_model.dart';

String offerTitle(OfferItem item, bool isAr) =>
    isAr ? item.name.ar : item.name.en;

String offerDescription(OfferItem item, bool isAr) =>
    stripOfferHtml(isAr ? item.description.ar : item.description.en);

String offerCategoryName(OfferItem item, bool isAr) {
  final category = item.category;
  if (category == null) return '';
  final name = isAr ? category.name.ar : category.name.en;
  if (name.trim().isNotEmpty) return name;
  final main = category.subcategory?.maincategory;
  if (main == null) return '';
  return isAr ? main.name.ar : main.name.en;
}

String stripOfferHtml(String value) => value
    .replaceAll(RegExp(r'<[^>]*>'), ' ')
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&amp;', '&')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

String offerPriceText(OfferItem item) {
  final label = item.price?.label;
  if (label == null) return '';
  final original = label.original.trim();
  final currency = label.currency.trim();
  if (original.isEmpty) return '';
  return currency.isEmpty ? original : '$original $currency';
}

String offerFinalPriceText(OfferItem item) {
  final label = item.price?.label;
  if (label == null) return '';
  final after = label.afterDiscount;
  final currency = label.currency.trim();
  if (label.hasDiscount && after != null) {
    final text = _formatNumber(after);
    return currency.isEmpty ? text : '$text $currency';
  }
  return offerPriceText(item);
}

bool offerHasDiscount(OfferItem item) {
  final label = item.price?.label;
  return item.hasActiveDiscount && (label?.hasDiscount ?? false);
}

String offerDiscountBadge(OfferItem item, bool isAr) {
  final discount = item.discount;
  if (discount == null || !discount.isActive) return '';
  if (discount.type == 'percentage') {
    return '${_formatNumber(discount.value)}%';
  }
  return isAr ? 'خصم' : 'OFF';
}

String offerStockText(OfferItem item, bool isAr) {
  final stock = item.stock;
  if (stock == null) return '';
  return stock > 0
      ? (isAr ? '$stock متوفر' : '$stock in stock')
      : (isAr ? 'غير متوفر' : 'Out of stock');
}

bool offerInStock(OfferItem item) => (item.stock ?? 1) > 0;

String _formatNumber(num value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toString();
}
