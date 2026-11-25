import '../../../../../core/constants/end_points.dart';

Map<String, dynamic> _map(dynamic value) =>
    Map<String, dynamic>.from(value as Map);

class OffersModel {
  final bool status;
  final OfferLocalizedText message;
  final OffersData data;

  OffersModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory OffersModel.fromJson(Map<String, dynamic> json) {
    return OffersModel(
      status: json[ApiKey.status] ?? true,
      message: json[ApiKey.message] != null
          ? OfferLocalizedText.fromJson(_map(json[ApiKey.message]))
          : OfferLocalizedText(ar: '', en: ''),
      data: json[ApiKey.data] != null
          ? OffersData.fromJson(_map(json[ApiKey.data]))
          : OffersData.empty(),
    );
  }
}

class OffersData {
  final OffersSection products;
  final OffersSection services;

  OffersData({required this.products, required this.services});

  factory OffersData.empty() => OffersData(
    products: OffersSection.empty(),
    services: OffersSection.empty(),
  );

  factory OffersData.fromJson(Map<String, dynamic> json) {
    return OffersData(
      products: json['products'] != null
          ? OffersSection.fromJson(_map(json['products']))
          : OffersSection.empty(),
      services: json['services'] != null
          ? OffersSection.fromJson(_map(json['services']))
          : OffersSection.empty(),
    );
  }
}

class OffersSection {
  final List<OfferItem> data;
  final OffersMeta meta;

  OffersSection({required this.data, required this.meta});

  factory OffersSection.empty() =>
      OffersSection(data: const [], meta: OffersMeta.empty());

  factory OffersSection.fromJson(Map<String, dynamic> json) {
    return OffersSection(
      data: json[ApiKey.data] != null
          ? List<OfferItem>.from(
        (json[ApiKey.data] as List).map(
              (x) => OfferItem.fromJson(_map(x)),
        ),
      )
          : const [],
      meta: json[ApiKey.meta] != null
          ? OffersMeta.fromJson(_map(json[ApiKey.meta]))
          : OffersMeta.empty(),
    );
  }
}

class OfferItem {
  final int id;
  final OfferLocalizedText name;
  final OfferLocalizedText description;
  final String? productCode;
  final String? image;
  final List<OfferGalleryItem> gallery;
  final OfferDiscount? discount;
  final OfferPrice? price;
  final OfferCategoryInfo? category;
  final bool freeShipping;
  final bool hasMaintenance;
  final int? guarantee;
  final int? maintenanceIntervalDays;
  final int? stock;

  OfferItem({
    required this.id,
    required this.name,
    required this.description,
    this.productCode,
    this.image,
    this.gallery = const [],
    this.discount,
    this.price,
    this.category,
    this.freeShipping = false,
    this.hasMaintenance = false,
    this.guarantee,
    this.maintenanceIntervalDays,
    this.stock,
  });

  bool get hasActiveDiscount => discount?.isActive ?? false;

  factory OfferItem.fromJson(Map<String, dynamic> json) {
    return OfferItem(
      id: json[ApiKey.id] ?? 0,
      name: json[ApiKey.name] != null
          ? OfferLocalizedText.fromJson(_map(json[ApiKey.name]))
          : OfferLocalizedText(ar: '', en: ''),
      description: json[ApiKey.description] != null
          ? OfferLocalizedText.fromJson(_map(json[ApiKey.description]))
          : OfferLocalizedText(ar: '', en: ''),
      productCode: json['product_code']?.toString(),
      image: _resolveImage(json[ApiKey.image]?.toString()),
      gallery: json['gallery'] != null
          ? List<OfferGalleryItem>.from(
        (json['gallery'] as List).map(
              (x) => OfferGalleryItem.fromJson(_map(x)),
        ),
      )
          : const [],
      discount: json['discount'] != null
          ? OfferDiscount.fromJson(_map(json['discount']))
          : null,
      price: json[ApiKey.price] != null
          ? OfferPrice.fromJson(_map(json[ApiKey.price]))
          : null,
      category: json['category'] != null
          ? OfferCategoryInfo.fromJson(_map(json['category']))
          : null,
      freeShipping: json['free_shipping'] == true,
      hasMaintenance: json['has_maintenance'] == true,
      guarantee: _toInt(json['guarantee']),
      maintenanceIntervalDays: _toInt(json['maintenance_interval_days']),
      stock: _toInt(json['stock']),
    );
  }

  static String? _resolveImage(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    return '${EndPoints.imageBaseUrl}$raw';
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

class OfferLocalizedText {
  final String ar;
  final String en;

  OfferLocalizedText({required this.ar, required this.en});

  factory OfferLocalizedText.fromJson(Map<String, dynamic> json) {
    return OfferLocalizedText(
      ar: json[ApiKey.ar]?.toString() ?? '',
      en: json[ApiKey.en]?.toString() ?? '',
    );
  }
}

class OfferGalleryItem {
  final int id;
  final String? url;
  final String? name;

  OfferGalleryItem({required this.id, this.url, this.name});

  factory OfferGalleryItem.fromJson(Map<String, dynamic> json) {
    return OfferGalleryItem(
      id: json[ApiKey.id] ?? 0,
      url: json[ApiKey.url]?.toString(),
      name: json[ApiKey.name]?.toString(),
    );
  }
}

class OfferDiscount {
  final bool isActive;
  final String type;
  final num value;
  final num? amount;
  final String? startsAt;
  final String? endsAt;

  OfferDiscount({
    required this.isActive,
    required this.type,
    required this.value,
    this.amount,
    this.startsAt,
    this.endsAt,
  });

  factory OfferDiscount.fromJson(Map<String, dynamic> json) {
    return OfferDiscount(
      isActive: json['is_active'] == true,
      type: json['type']?.toString() ?? '',
      value: json[ApiKey.value] is num ? json[ApiKey.value] as num : 0,
      amount: json['amount'] is num ? json['amount'] as num : null,
      startsAt: json['starts_at']?.toString(),
      endsAt: json['ends_at']?.toString(),
    );
  }
}

class OfferPrice {
  final OfferPriceLabel label;
  final num value;
  final num? originalValue;
  final num? finalValue;

  OfferPrice({
    required this.label,
    required this.value,
    this.originalValue,
    this.finalValue,
  });

  factory OfferPrice.fromJson(Map<String, dynamic> json) {
    return OfferPrice(
      label: json[ApiKey.label] != null
          ? OfferPriceLabel.fromJson(_map(json[ApiKey.label]))
          : OfferPriceLabel.empty(),
      value: json[ApiKey.value] is num ? json[ApiKey.value] as num : 0,
      originalValue: json['original_value'] is num
          ? json['original_value'] as num
          : null,
      finalValue: json['final_value'] is num
          ? json['final_value'] as num
          : null,
    );
  }
}

class OfferPriceLabel {
  final String original;
  final String currency;
  final bool hasDiscount;
  final String? discountType;
  final num? discountValue;
  final num? afterDiscount;

  OfferPriceLabel({
    required this.original,
    required this.currency,
    this.hasDiscount = false,
    this.discountType,
    this.discountValue,
    this.afterDiscount,
  });

  factory OfferPriceLabel.empty() =>
      OfferPriceLabel(original: '', currency: '');

  factory OfferPriceLabel.fromJson(Map<String, dynamic> json) {
    return OfferPriceLabel(
      original: json[ApiKey.original]?.toString() ?? '',
      currency: json[ApiKey.currency]?.toString() ?? '',
      hasDiscount: json['has_discount'] == true,
      discountType: json['discount_type']?.toString(),
      discountValue: json['discount_value'] is num
          ? json['discount_value'] as num
          : null,
      afterDiscount: json['after_discount'] is num
          ? json['after_discount'] as num
          : null,
    );
  }
}

class OfferCategoryInfo {
  final int id;
  final OfferLocalizedText name;
  final String? image;
  final OfferSubcategoryInfo? subcategory;

  OfferCategoryInfo({
    required this.id,
    required this.name,
    this.image,
    this.subcategory,
  });

  factory OfferCategoryInfo.fromJson(Map<String, dynamic> json) {
    return OfferCategoryInfo(
      id: json[ApiKey.id] ?? 0,
      name: json[ApiKey.name] != null
          ? OfferLocalizedText.fromJson(json[ApiKey.name])
          : OfferLocalizedText(ar: '', en: ''),
      image: json[ApiKey.image]?.toString(),
      subcategory: json['subcategory'] != null
          ? OfferSubcategoryInfo.fromJson(_map(json['subcategory']))
          : null,
    );
  }
}

class OfferSubcategoryInfo {
  final int id;
  final OfferLocalizedText name;
  final String? image;
  final OfferMainCategoryInfo? maincategory;

  OfferSubcategoryInfo({
    required this.id,
    required this.name,
    this.image,
    this.maincategory,
  });

  factory OfferSubcategoryInfo.fromJson(Map<String, dynamic> json) {
    return OfferSubcategoryInfo(
      id: json[ApiKey.id] ?? 0,
      name: json[ApiKey.name] != null
          ? OfferLocalizedText.fromJson(json[ApiKey.name])
          : OfferLocalizedText(ar: '', en: ''),
      image: json[ApiKey.image]?.toString(),
      maincategory: json['maincategory'] != null
          ? OfferMainCategoryInfo.fromJson(_map(json['maincategory']))
          : null,
    );
  }
}

class OfferMainCategoryInfo {
  final int id;
  final OfferLocalizedText name;
  final String? image;

  OfferMainCategoryInfo({required this.id, required this.name, this.image});

  factory OfferMainCategoryInfo.fromJson(Map<String, dynamic> json) {
    return OfferMainCategoryInfo(
      id: json[ApiKey.id] ?? 0,
      name: json[ApiKey.name] != null
          ? OfferLocalizedText.fromJson(json[ApiKey.name])
          : OfferLocalizedText(ar: '', en: ''),
      image: json[ApiKey.image]?.toString(),
    );
  }
}

class OffersMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  OffersMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory OffersMeta.empty() =>
      OffersMeta(currentPage: 1, lastPage: 1, perPage: 15, total: 0);

  factory OffersMeta.fromJson(Map<String, dynamic> json) {
    return OffersMeta(
      currentPage: json[ApiKey.currentPage] ?? 1,
      lastPage: json[ApiKey.lastPage] ?? 1,
      perPage: json[ApiKey.perPage] ?? 15,
      total: json[ApiKey.total] ?? 0,
    );
  }
}
