class TechnicalRegistrationFailure {
  final Map<String, String> messages;
  final Map<String, List<String>> fieldErrors;
  const TechnicalRegistrationFailure({
    required this.messages,
    this.fieldErrors = const {},
  });
  factory TechnicalRegistrationFailure.fromJson(dynamic response) {
    if (response is! Map)
      return const TechnicalRegistrationFailure(
        messages: {
          'ar': 'تعذر الاتصال بالخادم',
          'en': 'Could not connect to the server',
        },
      );
    final rawErrors = response['errors'];
    final raw =
        response['message'] ?? (rawErrors is Map ? rawErrors['message'] : null);
    final errors = rawErrors is Map && rawErrors['errors'] is Map
        ? rawErrors['errors']
        : rawErrors;
    return TechnicalRegistrationFailure(
      messages: raw is Map
          ? raw.map((k, v) => MapEntry('$k', '$v'))
          : {
        'ar': '${raw ?? 'تعذر إرسال الطلب'}',
        'en': '${raw ?? 'Could not submit registration'}',
      },
      fieldErrors: errors is Map
          ? errors.map(
            (k, v) => MapEntry(
          '$k',
          v is List ? v.map((e) => '$e').toList() : ['$v'],
        ),
      )
          : {},
    );
  }
  String localizedMessage(bool ar) {
    final errors = fieldErrors.values.expand((e) => e).toList();
    if (errors.isNotEmpty) return errors.first;
    return messages[ar ? 'ar' : 'en'] ?? messages[ar ? 'en' : 'ar'] ?? '';
  }
}
