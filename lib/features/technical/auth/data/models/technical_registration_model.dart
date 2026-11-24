import '../../../../../core/auth/account_access.dart';

class TechnicalRegistrationModel {
  final String token;
  final Map<String, dynamic> user, message;
  const TechnicalRegistrationModel({
    required this.token,
    required this.user,
    required this.message,
  });
  AccountAccess get access => AccountAccess(
    accountType: '${user['account_type'] ?? ''}',
    isActive: user['is_active'] is bool ? user['is_active'] as bool : null,
    registrationStatus: user['registration_status']?.toString(),
  );
  factory TechnicalRegistrationModel.fromJson(Map<String, dynamic> json) {
    final token = json['token']?.toString().trim() ?? '';
    if (json['status'] != true || token.isEmpty || json['user'] is! Map)
      throw const FormatException('Invalid technician registration');
    final user = Map<String, dynamic>.from(json['user'] as Map);
    if (user['account_type'] != 'technical' ||
        int.tryParse('${user['id']}') == null)
      throw const FormatException('Invalid technical account');
    final message = json['message'];
    return TechnicalRegistrationModel(
      token: token,
      user: user,
      message: message is Map
          ? Map<String, dynamic>.from(message)
          : {'ar': message?.toString() ?? '', 'en': message?.toString() ?? ''},
    );
  }
  String localizedMessage(bool ar) =>
      '${message[ar ? 'ar' : 'en'] ?? message[ar ? 'en' : 'ar'] ?? ''}';
}
