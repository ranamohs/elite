import 'package:elite/core/constants/end_points.dart';
import 'package:elite/core/data/models/localized_text_model.dart';

class AuthUserModel {
  final int? id;
  final String? name;
  final String? avatar;
  final String? email;
  final String? phone;
  final dynamic latitude;
  final dynamic longitude;
  final String? pushNotificationsToken;
  final dynamic accountType;
  final bool? isActive;
  final String? registrationStatus;

  AuthUserModel({
    this.id,
    this.name,
    this.avatar,
    this.email,
    this.phone,
    this.latitude,
    this.longitude,
    this.pushNotificationsToken,
    this.accountType,
    this.isActive,
    this.registrationStatus,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json[ApiKey.id] is int
          ? json[ApiKey.id]
          : int.tryParse(json[ApiKey.id]?.toString() ?? ''),
      name: json[ApiKey.name] as String?,
      avatar: json[ApiKey.avatar] as String?,
      email: json[ApiKey.email] as String?,
      phone: (json[ApiKey.phone] ?? json[ApiKey.phoneNumber]) as String?,
      latitude: json['latitude'],
      longitude: json['longitude'],
      pushNotificationsToken: json['push_notifications_token'] as String?,
      accountType: json['account_type'],
      isActive: json['is_active'] is bool
          ? json['is_active'] as bool
          : json['is_active'] == 1
          ? true
          : json['is_active'] == 0
          ? false
          : null,
      registrationStatus: json['registration_status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) ApiKey.id: id,
      ApiKey.name: name,
      ApiKey.avatar: avatar,
      ApiKey.email: email,
      ApiKey.phone: phone,
      'latitude': latitude,
      'longitude': longitude,
      'push_notifications_token': pushNotificationsToken,
      'account_type': accountType,
      'is_active': isActive,
      'registration_status': registrationStatus,
    };
  }
}

class LoginSuccessModel {
  final bool? status;
  final LocalizedText? message;
  final String token;
  final AuthUserModel? user;

  LoginSuccessModel({
    this.status,
    this.message,
    required this.token,
    this.user,
  });

  factory LoginSuccessModel.fromJson(Map<String, dynamic> json) {
    LocalizedText? parsedMessage;
    if (json[ApiKey.message] is Map<String, dynamic>) {
      parsedMessage = LocalizedText.fromJson(json[ApiKey.message]);
    } else if (json[ApiKey.message] is String) {
      parsedMessage = LocalizedText(
        ar: json[ApiKey.message],
        en: json[ApiKey.message],
      );
    }

    return LoginSuccessModel(
      status: json[ApiKey.status] as bool?,
      message: parsedMessage,
      token: (json[ApiKey.token] ?? '') as String,
      user: json[ApiKey.user] is Map<String, dynamic>
          ? AuthUserModel.fromJson(json[ApiKey.user] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (status != null) ApiKey.status: status,
      if (message != null) ApiKey.message: message!.toJson(),
      ApiKey.token: token,
      if (user != null) ApiKey.user: user!.toJson(),
    };
  }
}
