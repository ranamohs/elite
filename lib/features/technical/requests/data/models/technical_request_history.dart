import 'assigned_requests_model.dart';

enum TechnicalRequestSource { received, started, unpaid, all }

enum TechnicalRequestTab { upcoming, completed, canceled }

class TechnicalHistoryEntry {
  final AssignedRequest request;
  final TechnicalRequestSource source;
  const TechnicalHistoryEntry(this.request, this.source);
  String get status => request.statusValue.trim().toLowerCase();
  bool get canceled => const {
    'declined_by_technical',
    'canceled',
    'cancelled',
    'rejected',
    'cancelled_by_customer',
    'canceled_by_customer',
  }.contains(status);
  bool get unpaid =>
      status == 'completed_unpaid' ||
          (status.isEmpty && source == TechnicalRequestSource.unpaid);
  bool get started =>
      status == 'started_by_technical' ||
          (status.isEmpty && source == TechnicalRequestSource.started);
  TechnicalRequestTab get tab => canceled
      ? TechnicalRequestTab.canceled
      : unpaid ||
      const {
        'completed',
        'complete',
        'completed_paid',
        'paid',
        'finished',
        'closed',
      }.contains(status)
      ? TechnicalRequestTab.completed
      : TechnicalRequestTab.upcoming;
  DateTime? get appointmentDate =>
      technicalAppointmentDate(request.customerDate);
}

List<TechnicalHistoryEntry> mergeTechnicalHistory(
    Map<TechnicalRequestSource, AssignedRequestsModel> pages,
    ) {
  final entries = <int, TechnicalHistoryEntry>{};
  // The all-orders feed supplies explicit statuses; dedicated feeds supply context
  // when their status fields are null. Never turn null into an invented status.
  for (final source in [
    TechnicalRequestSource.received,
    TechnicalRequestSource.started,
    TechnicalRequestSource.unpaid,
    TechnicalRequestSource.all,
  ]) {
    for (final request in pages[source]?.requests ?? <AssignedRequest>[]) {
      final old = entries[request.id];
      if (source == TechnicalRequestSource.all &&
          old != null &&
          request.statusValue.trim().isEmpty)
        continue;
      if (source == TechnicalRequestSource.all &&
          old != null &&
          request.statusValue == old.request.statusValue) {
        entries[request.id] = TechnicalHistoryEntry(request, old.source);
      } else {
        entries[request.id] = TechnicalHistoryEntry(request, source);
      }
    }
  }
  final result = entries.values.toList();
  result.sort((a, b) {
    final da = a.appointmentDate, db = b.appointmentDate;
    if (da == null)
      return db == null ? b.request.id.compareTo(a.request.id) : 1;
    if (db == null) return -1;
    final order = da.compareTo(db);
    return order == 0 ? b.request.id.compareTo(a.request.id) : order;
  });
  return result;
}

DateTime? technicalAppointmentDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final value = raw.replaceAllMapped(RegExp('[٠-٩۰-۹]'), (m) {
    final code = m[0]!.codeUnitAt(0);
    return '${code - (code >= 0x6f0 ? 0x6f0 : 0x660)}';
  });
  final iso = DateTime.tryParse(value);
  if (iso != null) return DateTime(iso.year, iso.month, iso.day);
  const months = {
    'يناير': 1,
    'فبراير': 2,
    'مارس': 3,
    'أبريل': 4,
    'ابريل': 4,
    'مايو': 5,
    'يونيو': 6,
    'يوليو': 7,
    'أغسطس': 8,
    'اغسطس': 8,
    'سبتمبر': 9,
    'أكتوبر': 10,
    'اكتوبر': 10,
    'نوفمبر': 11,
    'ديسمبر': 12,
  };
  final match = RegExp(r'(\d{1,2})\s+([^\s,،]+)\s+(\d{4})').firstMatch(value);
  if (match == null) return null;
  final month = months[match[2]],
      day = int.tryParse(match[1]!),
      year = int.tryParse(match[3]!);
  if (month == null || day == null || year == null) return null;
  final date = DateTime(year, month, day);
  return date.year == year && date.month == month && date.day == day
      ? date
      : null;
}
