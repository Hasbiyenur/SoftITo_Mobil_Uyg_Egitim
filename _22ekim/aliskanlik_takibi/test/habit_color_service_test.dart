import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aliskanlik_takibi/core/theme/habit_color_service.dart';
import 'package:aliskanlik_takibi/data/models/habit.dart';
import 'package:aliskanlik_takibi/data/models/habit_schedule.dart';

void main() {
  group('HabitColorService Testleri', () {
    test('Palette en az 10 soft ve pastel renk barındırır', () {
      expect(HabitColorService.palette.length, greaterThanOrEqualTo(10));
    });

    test('Hex dönüşümleri doğru çalışır', () {
      const color = Color(0xFF3B6E52);
      final hex = HabitColorService.toHex(color);
      expect(hex, '#3B6E52');

      final fromHex = HabitColorService.fromHex(hex);
      expect(fromHex.toARGB32(), color.toARGB32());
    });

    test('Kullanılmayan ilk rengi otomatik önerir', () {
      final h1 = Habit(
        id: 'h1',
        userId: 'u1',
        title: 'Görev 1',
        iconCodePoint: 1,
        colorValue: HabitColorService.palette[0].toARGB32(),
        createdAtUtc: '2026-10-22T00:00:00Z',
        schedules: [
          const HabitSchedule(
            id: 's1',
            habitId: 'h1',
            intervalDays: 1,
            anchorDateKey: '2026-10-22',
            effectiveFromDateKey: '2026-10-22',
            counterType: 'check',
            targetValue: 1,
          ),
        ],
      );

      final suggested = HabitColorService.suggestNextColor([h1]);
      expect(suggested.toARGB32(), HabitColorService.palette[1].toARGB32());
    });

    test('Renk çakışmalarını benzersiz renklerle giderir', () {
      const duplicateColor = 0xFF3B6E52;

      final h1 = Habit(
        id: 'h1',
        userId: 'u1',
        title: 'Görev 1',
        iconCodePoint: 1,
        colorValue: duplicateColor,
        createdAtUtc: '2026-10-22T00:00:00Z',
        schedules: [],
      );

      final h2 = Habit(
        id: 'h2',
        userId: 'u1',
        title: 'Görev 2',
        iconCodePoint: 2,
        colorValue: duplicateColor,
        createdAtUtc: '2026-10-22T00:00:00Z',
        schedules: [],
      );

      final resolved = HabitColorService.resolveColorCollisions([h1, h2]);
      expect(resolved.length, 2);
      expect(resolved[0].colorValue, isNot(equals(resolved[1].colorValue)));
    });
  });
}
