import 'package:flutter/foundation.dart';
import '../models/workout_model.dart';

class WorkoutController extends ChangeNotifier {
  final List<WorkoutModel> _workouts = [];

  List<WorkoutModel> get workouts => List.unmodifiable(_workouts);

  int get totalCaloriesBurned =>
      _workouts.fold(0, (sum, item) => sum + item.caloriesBurned);

  int get totalDurationMinutes =>
      _workouts.fold(0, (sum, item) => sum + item.durationMinutes);

  void addWorkout({
    required WorkoutType type,
    required int durationMinutes,
  }) {
    if (durationMinutes <= 0) return;
    final calories = type.caloriesPerMinute * durationMinutes;
    final workout = WorkoutModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: type,
      durationMinutes: durationMinutes,
      caloriesBurned: calories,
      timestamp: DateTime.now(),
    );
    _workouts.insert(0, workout);
    notifyListeners();
  }

  void removeWorkout(String id) {
    _workouts.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void resetToday() {
    _workouts.clear();
    notifyListeners();
  }
}
