import 'package:elite/core/constants/end_points.dart';
import 'package:elite/core/data/models/localized_text_model.dart';
import 'package:elite/features/login/data/models/login_success_model.dart';

class RegisterSuccessModel {
  final bool? status;
  final LocalizedText? message;
  final String token;
  final AuthUserModel? user;

  RegisterSuccessModel({
    this.status,
    this.message,
    required this.token,
    this.user,
  });

  factory RegisterSuccessModel.fromJson(Map<String, dynamic> json) {
    LocalizedText? parsedMessage;
    if (json[ApiKey.message] is Map<String, dynamic>) {
      parsedMessage = LocalizedText.fromJson(json[ApiKey.message]);
    } else if (json[ApiKey.message] is String) {
      parsedMessage = LocalizedText(
        ar: json[ApiKey.message],
        en: json[ApiKey.message],
      );
    }

    return RegisterSuccessModel(
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
