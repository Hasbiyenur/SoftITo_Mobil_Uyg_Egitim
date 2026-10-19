import 'package:flutter/foundation.dart';

@immutable
class WorkoutActivity {
  final String id;
  final String name;
  final int durationMinutes;
  final int caloriesBurned;
  final DateTime timestamp;

  const WorkoutActivity({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.timestamp,
  });

  WorkoutActivity copyWith({
    String? id,
    String? name,
    int? durationMinutes,
    int? caloriesBurned,
    DateTime? timestamp,
  }) {
    return WorkoutActivity(
      id: id ?? this.id,
      name: name ?? this.name,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory WorkoutActivity.fromJson(Map<String, dynamic> json) {
    return WorkoutActivity(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      caloriesBurned: json['caloriesBurned'] as int? ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'WorkoutActivity(id: $id, name: $name, calories: $caloriesBurned)';
}
