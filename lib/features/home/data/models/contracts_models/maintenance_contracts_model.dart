import '../../../../../core/constants/end_points.dart';

class MaintenanceContractsModel {
  final bool status;
  final ContractLocalizedText message;
  final List<MaintenanceContract> data;
  final ContractLinks? links;
  final ContractMeta? meta;

  MaintenanceContractsModel({
    required this.status,
    required this.message,
    required this.data,
    this.links,
    this.meta,
  });

  factory MaintenanceContractsModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceContractsModel(
      status: json[ApiKey.status] ?? true,
      message: json[ApiKey.message] != null
          ? ContractLocalizedText.fromJson(json[ApiKey.message])
          : ContractLocalizedText(ar: '', en: ''),
      data: json[ApiKey.data] != null
          ? List<MaintenanceContract>.from(
        json[ApiKey.data].map((x) => MaintenanceContract.fromJson(x)),
      )
          : [],
      links: json[ApiKey.links] != null
          ? ContractLinks.fromJson(json[ApiKey.links])
          : null,
      meta: json[ApiKey.meta] != null
          ? ContractMeta.fromJson(json[ApiKey.meta])
          : null,
    );
  }
}

class MaintenanceContract {
  final int id;
  final ContractLocalizedText name;
  final ContractLocalizedText description;
  final String? image;
  final ContractPrice price;
  final ContractDuration? duration;
  final List<ContractLocalizedText> features;

  MaintenanceContract({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    required this.price,
    this.duration,
    this.features = const [],
  });

  factory MaintenanceContract.fromJson(Map<String, dynamic> json) {
    return MaintenanceContract(
      id: json[ApiKey.id] ?? 0,
      name: json[ApiKey.name] != null
          ? ContractLocalizedText.fromJson(json[ApiKey.name])
          : ContractLocalizedText(ar: '', en: ''),
      description: json[ApiKey.description] != null
          ? ContractLocalizedText.fromJson(json[ApiKey.description])
          : ContractLocalizedText(ar: '', en: ''),
      image: _resolveImage(json[ApiKey.image]?.toString()),
      price: json[ApiKey.price] != null
          ? ContractPrice.fromJson(json[ApiKey.price])
          : ContractPrice.empty(),
      duration: json[ApiKey.duration] != null
          ? ContractDuration.fromJson(json[ApiKey.duration])
          : null,
      features: json[ApiKey.features] != null
          ? List<ContractLocalizedText>.from(
        (json[ApiKey.features] as List)
            .map((x) => ContractLocalizedText.fromJson(x)),
      )
          : const [],
    );
  }

  static String? _resolveImage(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    return '${EndPoints.IMAGE_BASE_URL}$raw';
  }
}

class ContractLocalizedText {
  final String ar;
  final String en;

  ContractLocalizedText({required this.ar, required this.en});

  factory ContractLocalizedText.fromJson(Map<String, dynamic> json) {
    return ContractLocalizedText(
      ar: json[ApiKey.ar]?.toString() ?? '',
      en: json[ApiKey.en]?.toString() ?? '',
    );
  }
}

class ContractPrice {
  final ContractPriceLabel label;
  final String value;

  ContractPrice({required this.label, required this.value});

  factory ContractPrice.empty() => ContractPrice(
    label: ContractPriceLabel(original: '', currency: ''),
    value: '',
  );

  factory ContractPrice.fromJson(Map<String, dynamic> json) {
    return ContractPrice(
      label: json[ApiKey.label] != null
          ? ContractPriceLabel.fromJson(json[ApiKey.label])
          : ContractPriceLabel(original: '', currency: ''),
      value: json[ApiKey.value]?.toString() ?? '',
    );
  }
}

class ContractPriceLabel {
  final String original;
  final String currency;

  ContractPriceLabel({required this.original, required this.currency});

  factory ContractPriceLabel.fromJson(Map<String, dynamic> json) {
    return ContractPriceLabel(
      original: json[ApiKey.original]?.toString() ?? '',
      currency: json[ApiKey.currency]?.toString() ?? '',
    );
  }
}

class ContractDuration {
  final num value;
  final String unit;

  ContractDuration({required this.value, required this.unit});

  factory ContractDuration.fromJson(Map<String, dynamic> json) {
    return ContractDuration(
      value: json[ApiKey.value] ?? 0,
      unit: json[ApiKey.unit]?.toString() ?? '',
    );
  }
}

class ContractLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  ContractLinks({this.first, this.last, this.prev, this.next});

  factory ContractLinks.fromJson(Map<String, dynamic> json) {
    return ContractLinks(
      first: json[ApiKey.first],
      last: json[ApiKey.last],
      prev: json[ApiKey.prev],
      next: json[ApiKey.next],
    );
  }
}

class ContractMeta {
  final int currentPage;
  final int? from;
  final int lastPage;
  final int perPage;
  final int? to;
  final int total;

  ContractMeta({
    required this.currentPage,
    this.from,
    required this.lastPage,
    required this.perPage,
    this.to,
    required this.total,
  });

  factory ContractMeta.fromJson(Map<String, dynamic> json) {
    return ContractMeta(
      currentPage: json[ApiKey.currentPage] ?? 1,
      from: json[ApiKey.from],
      lastPage: json[ApiKey.lastPage] ?? 1,
      perPage: json[ApiKey.perPage] ?? 10,
      to: json[ApiKey.to],
      total: json[ApiKey.total] ?? 0,
    );
  }
}
