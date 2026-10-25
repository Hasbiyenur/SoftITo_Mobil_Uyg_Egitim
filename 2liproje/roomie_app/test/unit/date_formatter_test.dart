import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:roomie_app/core/utils/date_formatter.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('tr_TR');
  });

  group('DateFormatter tr_TR Tests', () {
    test('formatDate formats date in Turkish (d MMMM yyyy)', () {
      final date = DateTime(2026, 10, 25);
      final formatted = DateFormatter.formatDate(date);
      expect(formatted, equals('25 Ekim 2026'));
    });

    test('formatShortDate formats date in Turkish (d MMM yyyy)', () {
      final date = DateTime(2026, 1, 15);
      final formatted = DateFormatter.formatShortDate(date);
      expect(formatted, equals('15 Oca 2026'));
    });

    test('formatRange formats date range in Turkish', () {
      final start = DateTime(2026, 5, 1);
      final end = DateTime(2026, 6, 1);
      final formatted = DateFormatter.formatRange(start, end);
      expect(formatted, equals('1 May - 1 Haz 2026'));
    });

    test('formatTime formats time properly (HH:mm)', () {
      final time = DateTime(2026, 10, 25, 14, 30);
      final formatted = DateFormatter.formatTime(time);
      expect(formatted, equals('14:30'));
    });
  });
}
