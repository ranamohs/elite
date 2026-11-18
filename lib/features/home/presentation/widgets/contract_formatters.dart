import '../../data/models/contracts_models/maintenance_contracts_model.dart';

String contractPriceText(MaintenanceContract contract) {
  final original = contract.price.label.original.trim();
  final currency = contract.price.label.currency.trim();
  if (original.isEmpty) {
    return contract.price.value.trim();
  }
  return currency.isEmpty ? original : '$original $currency';
}

String contractDurationText(ContractDuration? duration, bool isAr) {
  if (duration == null) return '';
  final unit = _durationUnit(duration.unit, duration.value, isAr);
  if (unit.isEmpty) return '';
  return '${_formatNumber(duration.value)} $unit';
}

String contractFeatureText(ContractLocalizedText feature, bool isAr) {
  return isAr ? feature.ar : feature.en;
}

String _durationUnit(String unit, num value, bool isAr) {
  final normalized = unit.toLowerCase();
  if (isAr) {
    switch (normalized) {
      case 'day':
        return value == 1 ? 'يوم' : (value == 2 ? 'يومين' : 'أيام');
      case 'week':
        return value == 1 ? 'أسبوع' : (value == 2 ? 'أسبوعين' : 'أسابيع');
      case 'month':
        return value == 1 ? 'شهر' : (value == 2 ? 'شهرين' : 'أشهر');
      case 'year':
        return value == 1 ? 'سنة' : (value == 2 ? 'سنتين' : 'سنوات');
      default:
        return unit;
    }
  }

  final plural = value == 1 ? normalized : '${normalized}s';
  return plural;
}

String _formatNumber(num value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toString();
}
