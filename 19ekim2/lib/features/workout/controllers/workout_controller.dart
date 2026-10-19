import 'package:flutter/foundation.dart';
import '../models/workout_model.dart';

class WorkoutController {
  final ValueNotifier<int> totalCaloriesBurned = ValueNotifier<int>(380);
  final ValueNotifier<int> dailyCalorieGoal = ValueNotifier<int>(600);
  final ValueNotifier<List<WorkoutModel>> workouts =
      ValueNotifier<List<WorkoutModel>>([
    WorkoutModel(
      id: 'w1',
      activityName: 'Sabah Koşusu',
      durationMinutes: 25,
      caloriesBurned: 240,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      iconType: 'run',
    ),
    WorkoutModel(
      id: 'w2',
      activityName: 'Tempolu Yürüyüş',
      durationMinutes: 20,
      caloriesBurned: 140,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      iconType: 'walk',
    ),
  ]);

  void addWorkout({
    required String activityName,
    required int durationMinutes,
    required int caloriesBurned,
    required String iconType,
  }) {
    totalCaloriesBurned.value += caloriesBurned;

    final newWorkout = WorkoutModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      activityName: activityName,
      durationMinutes: durationMinutes,
      caloriesBurned: caloriesBurned,
      timestamp: DateTime.now(),
      iconType: iconType,
    );

    workouts.value = [newWorkout, ...workouts.value];
  }

  void removeWorkout(String id) {
    final toRemove = workouts.value.cast<WorkoutModel?>().firstWhere(
          (w) => w?.id == id,
          orElse: () => null,
        );

    if (toRemove != null) {
      totalCaloriesBurned.value =
          (totalCaloriesBurned.value - toRemove.caloriesBurned).clamp(0, 99999);
      workouts.value = workouts.value.where((w) => w.id != id).toList();
    }
  }

  void resetWorkout() {
    totalCaloriesBurned.value = 0;
    workouts.value = [];
  }

  void updateCalorieGoal(int newGoal) {
    if (newGoal > 0) {
      dailyCalorieGoal.value = newGoal;
    }
  }

  void dispose() {
    totalCaloriesBurned.dispose();
    dailyCalorieGoal.dispose();
    workouts.dispose();
  }
}
