import 'package:flutter_test/flutter_test.dart';
import 'package:susadim/features/workout/controllers/workout_controller.dart';

void main() {
  group('WorkoutController Birim Testleri', () {
    late WorkoutController controller;

    setUp(() {
      controller = WorkoutController(dailyCalorieGoal: 500);
    });

    tearDown(() {
      controller.dispose();
    });

    test('Başlangıç değerleri sıfır olmalıdır', () {
      expect(controller.totalCaloriesBurned.value, 0);
      expect(controller.totalDurationMinutes.value, 0);
      expect(controller.activityList.value.isEmpty, true);
    });

    test('addWorkout() çağrıldığında kalori, süre ve aktivite eklenmelidir', () {
      controller.addWorkout(
        name: 'Koşu',
        durationMinutes: 30,
        caloriesBurned: 250,
      );
      expect(controller.totalCaloriesBurned.value, 250);
      expect(controller.totalDurationMinutes.value, 30);
      expect(controller.activityList.value.length, 1);
    });

    test('reset() çağrıldığında tüm değerler sıfırlanmalıdır', () {
      controller.addWorkout(
        name: 'Bisiklet',
        durationMinutes: 20,
        caloriesBurned: 150,
      );
      controller.reset();
      expect(controller.totalCaloriesBurned.value, 0);
      expect(controller.totalDurationMinutes.value, 0);
      expect(controller.activityList.value.isEmpty, true);
    });
  });
}
