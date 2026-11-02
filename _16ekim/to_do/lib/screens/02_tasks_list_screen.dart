import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../widgets/task_tile.dart';

class TasksListScreen extends StatefulWidget {
  final List<Task> tasks;
  final ValueChanged<Task> onToggle;
  const TasksListScreen({
    super.key,
    required this.tasks,
    required this.onToggle,
  });
  @override
  State<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends State<TasksListScreen> {
  TaskCategory? _category;
  int _status = 0;
  @override
  Widget build(BuildContext context) {
    final filtered =
        widget.tasks
            .where(
              (task) =>
                  (_category == null || task.category == _category) &&
                  (_status == 0 || (_status == 2) == task.isCompleted),
            )
            .toList()
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Planın burada.',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text('Görevlerini filtrele, bitirdiklerini işaretle.'),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Tüm kategoriler'),
              selected: _category == null,
              onSelected: (_) => setState(() => _category = null),
            ),
            ...TaskCategory.values.map(
              (category) => ChoiceChip(
                label: Text(category.label),
                selected: _category == category,
                onSelected: (_) => setState(() => _category = category),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            3,
            (index) => ChoiceChip(
              label: Text(['Hepsi', 'Bekleyen', 'Tamamlanan'][index]),
              selected: _status == index,
              onSelected: (_) => setState(() => _status = index),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '${filtered.length} görev',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Bu filtrelere uygun görev bulunamadı.'),
          ),
        ...filtered.map(
          (task) => TaskTile(
            task: task,
            showDate: true,
            onToggle: () => widget.onToggle(task),
          ),
        ),
      ],
    );
  }
}
