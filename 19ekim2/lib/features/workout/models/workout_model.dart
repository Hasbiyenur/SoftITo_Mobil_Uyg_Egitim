class WorkoutModel {
  final String id;
  final String activityName;
  final int durationMinutes;
  final int caloriesBurned;
  final DateTime timestamp;
  final String iconType;

  const WorkoutModel({
    required this.id,
    required this.activityName,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.timestamp,
    required this.iconType,
  });

  WorkoutModel copyWith({
    String? id,
    String? activityName,
    int? durationMinutes,
    int? caloriesBurned,
    DateTime? timestamp,
    String? iconType,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      activityName: activityName ?? this.activityName,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      timestamp: timestamp ?? this.timestamp,
      iconType: iconType ?? this.iconType,
    );
  }

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'] as String? ?? '',
      activityName: json['activityName'] as String? ?? '',
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      caloriesBurned: json['caloriesBurned'] as int? ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      iconType: json['iconType'] as String? ?? 'run',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activityName': activityName,
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'timestamp': timestamp.toIso8601String(),
      'iconType': iconType,
    };
  }
}
