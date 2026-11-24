class TechnicalRegistrationRequest {
  static const documentKeys = [
    'national_id_front',
    'national_id_back',
    'personal_photo',
    'criminal_record',
    'experience_certificate',
  ];
  static const dayCodes = ['sat', 'sun', 'mon', 'tue', 'wed', 'thu', 'fri'];
  final String name,
      email,
      phone,
      password,
      passwordConfirmation,
      nationalId,
      experience,
      city;
  final List<int> categoryIds;
  final List<String> workDays, workAreas;
  final Map<String, String> documents;
  final bool acceptTerms;
  TechnicalRegistrationRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
    required this.nationalId,
    required this.experience,
    required this.city,
    required List<int> categoryIds,
    required List<String> workDays,
    required List<String> workAreas,
    required Map<String, String> documents,
    required this.acceptTerms,
  }) : categoryIds = List.unmodifiable(categoryIds),
        workDays = List.unmodifiable(workDays),
        workAreas = List.unmodifiable(
          workAreas.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet(),
        ),
        documents = Map.unmodifiable(documents);
  bool get isValid =>
      name.trim().isNotEmpty &&
          name.trim().length <= 255 &&
          phone.trim().isNotEmpty &&
          phone.trim().length <= 255 &&
          RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email.trim()) &&
          password.isNotEmpty &&
          password == passwordConfirmation &&
          nationalId.trim().isNotEmpty &&
          experience.trim().isNotEmpty &&
          city.trim().isNotEmpty &&
          categoryIds.isNotEmpty &&
          categoryIds.length <= 20 &&
          categoryIds.toSet().length == categoryIds.length &&
          categoryIds.every((e) => e > 0) &&
          workDays.isNotEmpty &&
          workDays.toSet().length == workDays.length &&
          workDays.every(dayCodes.contains) &&
          workAreas.isNotEmpty &&
          acceptTerms &&
          documentKeys.every((key) => documents[key]?.trim().isNotEmpty == true);
  Map<String, String> get fields => {
    'name': name.trim(),
    'email': email.trim(),
    'phone': phone.trim(),
    'password': password,
    'password_confirmation': passwordConfirmation,
    'national_id': nationalId.trim(),
    'experience': experience.trim(),
    'city': city.trim(),
    'accept_terms': acceptTerms ? '1' : '0',
  };
  List<MapEntry<String, String>> get arrayFields => [
    ...categoryIds.map((id) => MapEntry('main_category_ids[]', '$id')),
    ...workDays.map((day) => MapEntry('work_days[]', day)),
    ...workAreas.map((area) => MapEntry('work_areas[]', area)),
  ];
}
