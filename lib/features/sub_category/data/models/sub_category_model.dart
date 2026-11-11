class SubCategoryModel {
  final bool status;
  final SubCategoryMessage message;
  final List<SubCategoryItem> data;
  final SubCategoryLinks? links;
  final SubCategoryMeta? meta;

  SubCategoryModel({
    required this.status,
    required this.message,
    required this.data,
    this.links,
    this.meta,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      status: json['status'] ?? true,
      message: json['message'] != null
          ? SubCategoryMessage.fromJson(json['message'])
          : SubCategoryMessage(ar: '', en: ''),
      data: json['data'] != null
          ? List<SubCategoryItem>.from(
        json['data'].map((x) => SubCategoryItem.fromJson(x)),
      )
          : [],
      links: json['links'] != null
          ? SubCategoryLinks.fromJson(json['links'])
          : null,
      meta: json['meta'] != null
          ? SubCategoryMeta.fromJson(json['meta'])
          : null,
    );
  }
}

class SubCategoryMessage {
  final String ar;
  final String en;

  SubCategoryMessage({required this.ar, required this.en});

  factory SubCategoryMessage.fromJson(Map<String, dynamic> json) {
    return SubCategoryMessage(
      ar: json['ar'] ?? '',
      en: json['en'] ?? '',
    );
  }
}

class SubCategoryItem {
  final int id;
  final SubCategoryName name;
  final String? image;
  final SubCategoryDetail? subcategory;
  final String? description;
  final int? servicesCount;
  final int? productsCount;

  SubCategoryItem({
    required this.id,
    required this.name,
    this.image,
    this.subcategory,
    this.description,
    this.servicesCount,
    this.productsCount,
  });

  factory SubCategoryItem.fromJson(Map<String, dynamic> json) {
    return SubCategoryItem(
      id: json['id'] ?? 0,
      name: json['name'] != null
          ? SubCategoryName.fromJson(json['name'])
          : SubCategoryName(ar: '', en: ''),
      image: json['image'],
      subcategory: json['subcategory'] != null
          ? SubCategoryDetail.fromJson(json['subcategory'])
          : null,
      description: json['description']?.toString(),
      servicesCount: json['services_count'] ?? json['servicesCount'],
      productsCount: json['products_count'] ?? json['productsCount'],
    );
  }
}

class SubCategoryName {
  final String ar;
  final String en;

  SubCategoryName({required this.ar, required this.en});

  factory SubCategoryName.fromJson(Map<String, dynamic> json) {
    return SubCategoryName(
      ar: json['ar'] ?? '',
      en: json['en'] ?? '',
    );
  }
}

class SubCategoryDetail {
  final int id;
  final SubCategoryName name;
  final String? image;
  final dynamic maincategory;

  SubCategoryDetail({
    required this.id,
    required this.name,
    this.image,
    this.maincategory,
  });

  factory SubCategoryDetail.fromJson(Map<String, dynamic> json) {
    return SubCategoryDetail(
      id: json['id'] ?? 0,
      name: json['name'] != null
          ? SubCategoryName.fromJson(json['name'])
          : SubCategoryName(ar: '', en: ''),
      image: json['image'],
      maincategory: json['maincategory'],
    );
  }
}

class SubCategoryLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  SubCategoryLinks({this.first, this.last, this.prev, this.next});

  factory SubCategoryLinks.fromJson(Map<String, dynamic> json) {
    return SubCategoryLinks(
      first: json['first'],
      last: json['last'],
      prev: json['prev'],
      next: json['next'],
    );
  }
}

class SubCategoryMeta {
  final int currentPage;
  final int? from;
  final int lastPage;
  final int perPage;
  final int? to;
  final int total;

  SubCategoryMeta({
    required this.currentPage,
    this.from,
    required this.lastPage,
    required this.perPage,
    this.to,
    required this.total,
  });

  factory SubCategoryMeta.fromJson(Map<String, dynamic> json) {
    return SubCategoryMeta(
      currentPage: json['current_page'] ?? 1,
      from: json['from'],
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      to: json['to'],
      total: json['total'] ?? 0,
    );
  }
}
