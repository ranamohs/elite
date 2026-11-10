import 'package:elite/core/constants/end_points.dart';

class RegisterDataModel {
  final String name;
  final String phoneNumber;
  final String? email;
  final String password;
  final String confirmPassword;
  final dynamic latitude;
  final dynamic longitude;
  final String? address;
  final int? isPledge;

  RegisterDataModel({
    required this.name,
    required this.phoneNumber,
    this.email,
    required this.password,
    required this.confirmPassword,
    this.latitude,
    this.longitude,
    this.address,
    this.isPledge,
  });

  Map<String, dynamic> toJson() {
    return {
      ApiKey.name: name,
      ApiKey.phoneNumber: phoneNumber,
      if (email != null && email!.isNotEmpty) ApiKey.email: email,
      ApiKey.password: password,
      ApiKey.passwordConfirmation: confirmPassword,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (address != null && address!.isNotEmpty) 'address': address,
      if (isPledge != null) 'is_pledge': isPledge,
    };
  }

  factory RegisterDataModel.fromJson(Map<String, dynamic> json) {
    return RegisterDataModel(
      name: json[ApiKey.name] ?? '',
      phoneNumber: json[ApiKey.phoneNumber] ?? json[ApiKey.phone] ?? '',
      email: json[ApiKey.email],
      password: json[ApiKey.password] ?? '',
      confirmPassword: json[ApiKey.passwordConfirmation] ?? '',
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      isPledge: json['is_pledge'] is int
          ? json['is_pledge']
          : int.tryParse(json['is_pledge']?.toString() ?? ''),
    );
  }
}
