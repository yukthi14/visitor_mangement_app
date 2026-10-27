import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _displayDateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _displayDateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');

  /// Format as "Today, 16 Oct 2026" or "16 Oct 2026"
  static String formatHeaderDate(DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final dateStr = _displayDateFormat.format(date);
    return isToday ? 'Today, $dateStr' : dateStr;
  }

  /// Format ISO string to "16 Oct 2026, 09:15 AM"
  static String formatDateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '--';
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return _displayDateTimeFormat.format(dateTime);
    } catch (_) {
      return isoString;
    }
  }

  /// Format ISO string to "16 Oct 2026"
  static String formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '--';
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return _displayDateFormat.format(dateTime);
    } catch (_) {
      return isoString;
    }
  }

  /// Generate current timestamp in ISO 8601 format
  static String currentIsoTimestamp() {
    return DateTime.now().toIso8601String();
  }

  /// Check if an ISO date string matches a given DateTime's date (ignoring time)
  static bool isSameDate(String? isoString, DateTime targetDate) {
    if (isoString == null || isoString.isEmpty) return false;
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return dateTime.year == targetDate.year &&
          dateTime.month == targetDate.month &&
          dateTime.day == targetDate.day;
    } catch (_) {
      return false;
    }
  }
}
