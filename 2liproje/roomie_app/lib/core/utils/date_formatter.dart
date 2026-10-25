import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy', 'tr_TR').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('d MMM yyyy', 'tr_TR').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatRange(DateTime start, DateTime end) {
    return '${DateFormat('d MMM', 'tr_TR').format(start)} - ${formatShortDate(end)}';
  }
}
