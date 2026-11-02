enum TaskCategory { study, exercise, personal }

extension TaskCategoryLabel on TaskCategory {
  String get label => switch (this) {
    TaskCategory.study => 'Ders',
    TaskCategory.exercise => 'Spor',
    TaskCategory.personal => 'Kişisel',
  };
}

enum TaskPriority { normal, high }

class Task {
  final String id;
  final String title;
  final TaskCategory category;
  final DateTime scheduledAt;
  final TaskPriority priority;
  final String note;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.category,
    required this.scheduledAt,
    this.priority = TaskPriority.normal,
    this.note = '',
    this.isCompleted = false,
  });

  bool isOn(DateTime day) =>
      scheduledAt.year == day.year &&
      scheduledAt.month == day.month &&
      scheduledAt.day == day.day;

  String get timeLabel =>
      '${scheduledAt.hour.toString().padLeft(2, '0')}:${scheduledAt.minute.toString().padLeft(2, '0')}';
  String get dateLabel =>
      '${scheduledAt.day.toString().padLeft(2, '0')}.${scheduledAt.month.toString().padLeft(2, '0')}.${scheduledAt.year}';
}
