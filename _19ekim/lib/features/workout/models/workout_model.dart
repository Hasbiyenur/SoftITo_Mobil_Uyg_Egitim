enum WorkoutType {
  running(label: 'Koşu', iconName: 'directions_run', caloriesPerMinute: 11),
  cycling(label: 'Bisiklet', iconName: 'directions_bike', caloriesPerMinute: 9),
  weightlifting(label: 'Ağırlık', iconName: 'fitness_center', caloriesPerMinute: 7),
  swimming(label: 'Yüzme', iconName: 'pool', caloriesPerMinute: 10),
  hiit(label: 'HIIT', iconName: 'flash_on', caloriesPerMinute: 13),
  walking(label: 'Yürüyüş', iconName: 'directions_walk', caloriesPerMinute: 5);

  const WorkoutType({
    required this.label,
    required this.iconName,
    required this.caloriesPerMinute,
  });

  final String label;
  final String iconName;
  final int caloriesPerMinute;
}

class WorkoutModel {
  const WorkoutModel({
    required this.id,
    required this.type,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.timestamp,
  });

  final String id;
  final WorkoutType type;
  final int durationMinutes;
  final int caloriesBurned;
  final DateTime timestamp;
}
