import 'package:flutter/foundation.dart';

/// Takvim günü anahtarı yardımcı sınıfı ("yyyy-MM-dd").
/// Gün farkı hesaplamaları saat/yaz saati oynamalarından etkilenmemek için
/// her zaman DateTime.utc(yıl, ay, gün) üzerinden yapılır.
@immutable
class DateKey {
  final String value;

  const DateKey(this.value);

  factory DateKey.fromDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return DateKey('$y-$m-$d');
  }

  factory DateKey.today([DateTime? now]) {
    return DateKey.fromDate(now ?? DateTime.now());
  }

  static String format(DateTime dt) => DateKey.fromDate(dt).value;

  DateTime toDateTimeUtc() {
    final parts = value.split('-');
    if (parts.length != 3) {
      return DateTime.utc(2000, 1, 1);
    }
    final y = int.tryParse(parts[0]) ?? 2000;
    final m = int.tryParse(parts[1]) ?? 1;
    final d = int.tryParse(parts[2]) ?? 1;
    return DateTime.utc(y, m, d);
  }

  DateTime toLocalMidnight() {
    final parts = value.split('-');
    if (parts.length != 3) {
      return DateTime(2000, 1, 1);
    }
    final y = int.tryParse(parts[0]) ?? 2000;
    final m = int.tryParse(parts[1]) ?? 1;
    final d = int.tryParse(parts[2]) ?? 1;
    return DateTime(y, m, d);
  }

  /// [fromKey] ile [toKey] arasındaki takvim günü farkı (to - from).
  static int daysBetween(String fromKey, String toKey) {
    final dtFrom = DateKey(fromKey).toDateTimeUtc();
    final dtTo = DateKey(toKey).toDateTimeUtc();
    return dtTo.difference(dtFrom).inDays;
  }

  /// [baseKey] tarihine [days] gün ekler.
  static String addDays(String baseKey, int days) {
    final dt = DateKey(baseKey).toDateTimeUtc();
    final next = dt.add(Duration(days: days));
    return DateKey.fromDate(next).value;
  }

  /// Karşılaştırma: this < other ise negatif, eşitse 0, this > other ise pozitif.
  int compareTo(DateKey other) => value.compareTo(other.value);

  bool isBefore(DateKey other) => value.compareTo(other.value) < 0;
  bool isAfter(DateKey other) => value.compareTo(other.value) > 0;
  bool isSameDay(DateKey other) => value == other.value;

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is DateKey && other.value == value);

  @override
  int get hashCode => value.hashCode;
}
