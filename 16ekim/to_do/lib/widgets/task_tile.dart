import 'package:flutter/material.dart';

import '../models/task_model.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final bool showDate;
  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    this.showDate = false,
  });

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: CheckboxListTile(
      value: task.isCompleted,
      onChanged: (_) => onToggle(),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      title: Text(
        task.title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          '${task.category.label} · ${showDate ? '${task.dateLabel} · ' : ''}${task.timeLabel}'
          '${task.priority == TaskPriority.high ? ' · Yüksek öncelik' : ''}'
          '${task.note.isEmpty ? '' : '\n${task.note}'}',
        ),
      ),
    ),
  );
}
