import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

bool isArabic(BuildContext context) {
  try {
    return context.locale.languageCode == 'ar';
  } catch (_) {
    return Localizations.maybeLocaleOf(context)?.languageCode == 'ar';
  }
}
