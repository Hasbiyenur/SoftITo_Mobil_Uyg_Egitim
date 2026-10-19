import 'package:flutter/foundation.dart';
import '../models/workout_model.dart';

class WorkoutController {
  final int dailyCalorieGoal;

  /// Yakılan toplam kalori
  final ValueNotifier<int> totalCaloriesBurned = ValueNotifier<int>(0);

  /// Toplam egzersiz süresi (dakika)
  final ValueNotifier<int> totalDurationMinutes = ValueNotifier<int>(0);

  /// Tamamlanan egzersiz listesi
  final ValueNotifier<List<WorkoutActivity>> activityList =
      ValueNotifier<List<WorkoutActivity>>([]);

  WorkoutController({this.dailyCalorieGoal = 500});

  /// Hızlı egzersiz ekleme
  void addWorkout({
    required String name,
    required int durationMinutes,
    required int caloriesBurned,
  }) {
    final activity = WorkoutActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      durationMinutes: durationMinutes,
      caloriesBurned: caloriesBurned,
      timestamp: DateTime.now(),
    );

    totalCaloriesBurned.value += caloriesBurned;
    totalDurationMinutes.value += durationMinutes;
    activityList.value = [activity, ...activityList.value];
  }

  /// Egzersiz kaydını silme
  void removeWorkout(String id) {
    final index = activityList.value.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final item = activityList.value[index];
    totalCaloriesBurned.value =
        (totalCaloriesBurned.value - item.caloriesBurned).clamp(0, 99999);
    totalDurationMinutes.value =
        (totalDurationMinutes.value - item.durationMinutes).clamp(0, 99999);

    final updated = List<WorkoutActivity>.from(activityList.value)
      ..removeAt(index);
    activityList.value = updated;
  }

  /// Sıfırlama
  void reset() {
    totalCaloriesBurned.value = 0;
    totalDurationMinutes.value = 0;
    activityList.value = const [];
  }

  void dispose() {
    totalCaloriesBurned.dispose();
    totalDurationMinutes.dispose();
    activityList.dispose();
  }
}
