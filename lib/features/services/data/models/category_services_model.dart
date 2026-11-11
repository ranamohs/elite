class CategoryServicesModel {
  final bool status;
  final LocalizedMessage message;
  final List<CategoryServiceItem> data;
  final CategoryServicesLinks? links;
  final CategoryServicesMeta? meta;

  CategoryServicesModel({
    required this.status,
    required this.message,
    required this.data,
    this.links,
    this.meta,
  });

  factory CategoryServicesModel.fromJson(Map<String, dynamic> json) {
    return CategoryServicesModel(
      status: json['status'] ?? true,
      message: json['message'] != null
          ? LocalizedMessage.fromJson(json['message'])
          : LocalizedMessage(ar: '', en: ''),
      data: json['data'] != null
          ? List<CategoryServiceItem>.from(
        json['data'].map((x) => CategoryServiceItem.fromJson(x)),
      )
          : [],
      links: json['links'] != null
          ? CategoryServicesLinks.fromJson(json['links'])
          : null,
      meta: json['meta'] != null
          ? CategoryServicesMeta.fromJson(json['meta'])
          : null,
    );
  }
}

class LocalizedMessage {
  final String ar;
  final String en;

  LocalizedMessage({required this.ar, required this.en});

  factory LocalizedMessage.fromJson(Map<String, dynamic> json) {
    return LocalizedMessage(
      ar: json['ar'] ?? '',
      en: json['en'] ?? '',
    );
  }
}

class CategoryServiceItem {
  final int id;
  final ServiceLocalizedText name;
  final ServiceLocalizedText description;
  final ServicePrice? price;
  final String? image;
  final String? thumbnail;
  final List<ServiceGalleryItem> gallery;
  final ServiceCategoryInfo? category;

  CategoryServiceItem({
    required this.id,
    required this.name,
    required this.description,
    this.price,
    this.image,
    this.thumbnail,
    required this.gallery,
    this.category,
  });

  factory CategoryServiceItem.fromJson(Map<String, dynamic> json) {
    final image = json['image']?.toString();
    final thumbnail = json['thumbnail']?.toString() ?? image;

    return CategoryServiceItem(
      id: json['id'] ?? 0,
      name: json['name'] != null
          ? ServiceLocalizedText.fromJson(json['name'])
          : ServiceLocalizedText(ar: '', en: ''),
      description: json['description'] != null
          ? ServiceLocalizedText.fromJson(json['description'])
          : ServiceLocalizedText(ar: '', en: ''),
      price: json['price'] != null ? ServicePrice.fromJson(json['price']) : null,
      image: image,
      thumbnail: thumbnail,
      gallery: json['gallery'] != null
          ? List<ServiceGalleryItem>.from(
        json['gallery'].map((x) => ServiceGalleryItem.fromJson(x)),
      )
          : [],
      category: json['category'] != null
          ? ServiceCategoryInfo.fromJson(json['category'])
          : null,
    );
  }
}

class ServiceLocalizedText {
  final String ar;
  final String en;

  ServiceLocalizedText({required this.ar, required this.en});

  factory ServiceLocalizedText.fromJson(Map<String, dynamic> json) {
    return ServiceLocalizedText(
      ar: json['ar'] ?? '',
      en: json['en'] ?? '',
    );
  }
}

class ServicePrice {
  final String label;
  final String value;

  ServicePrice({required this.label, required this.value});

  factory ServicePrice.fromJson(Map<String, dynamic> json) {
    return ServicePrice(
      label: json['label']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }
}

class ServiceGalleryItem {
  final int id;
  final String? url;

  ServiceGalleryItem({required this.id, this.url});

  factory ServiceGalleryItem.fromJson(Map<String, dynamic> json) {
    return ServiceGalleryItem(
      id: json['id'] ?? 0,
      url: json['url'],
    );
  }
}

class ServiceCategoryInfo {
  final int id;
  final ServiceLocalizedText name;
  final String? image;

  ServiceCategoryInfo({
    required this.id,
    required this.name,
    this.image,
  });

  factory ServiceCategoryInfo.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryInfo(
      id: json['id'] ?? 0,
      name: json['name'] != null
          ? ServiceLocalizedText.fromJson(json['name'])
          : ServiceLocalizedText(ar: '', en: ''),
      image: json['image'],
    );
  }
}

class CategoryServicesLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  CategoryServicesLinks({this.first, this.last, this.prev, this.next});

  factory CategoryServicesLinks.fromJson(Map<String, dynamic> json) {
    return CategoryServicesLinks(
      first: json['first'],
      last: json['last'],
      prev: json['prev'],
      next: json['next'],
    );
  }
}

class CategoryServicesMeta {
  final int currentPage;
  final int? from;
  final int lastPage;
  final int perPage;
  final int? to;
  final int total;

  CategoryServicesMeta({
    required this.currentPage,
    this.from,
    required this.lastPage,
    required this.perPage,
    this.to,
    required this.total,
  });

  factory CategoryServicesMeta.fromJson(Map<String, dynamic> json) {
    return CategoryServicesMeta(
      currentPage: json['current_page'] ?? 1,
      from: json['from'],
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      to: json['to'],
      total: json['total'] ?? 0,
    );
  }
}
