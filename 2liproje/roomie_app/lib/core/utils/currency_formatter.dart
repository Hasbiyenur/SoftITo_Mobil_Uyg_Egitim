import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 0,
  );

  static String format(num amount) {
    return _formatter.format(amount).trim();
  }

  static String formatMonthly(num amount) {
    return '${format(amount)} / ay';
  }

  static String formatDaily(num amount) {
    return '${format(amount)} / gün';
  }
}
