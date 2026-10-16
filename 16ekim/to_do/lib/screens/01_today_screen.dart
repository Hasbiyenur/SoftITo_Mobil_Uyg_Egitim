import 'package:flutter/material.dart';

import '../models/task_model.dart';
import '../widgets/task_tile.dart';

class TodayScreen extends StatelessWidget {
  final List<Task> tasks;
  final ValueChanged<Task> onToggle;
  final VoidCallback onAdd;
  const TodayScreen({
    super.key,
    required this.tasks,
    required this.onToggle,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final daily = tasks.where((task) => task.isOn(today)).toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    final completed = daily.where((task) => task.isCompleted).length;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          MaterialLocalizations.of(context).formatFullDate(today),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Gününü küçük adımlarla planla.',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BUGÜNKÜ İLERLEMEN',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Text(
                '$completed / ${daily.length} görev tamamlandı',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: daily.isEmpty ? 0 : completed / daily.length,
                color: Colors.white,
                backgroundColor: Colors.white24,
                minHeight: 8,
              ),
              const SizedBox(height: 12),
              Text(
                '${daily.length - completed} görev kaldı',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            Chip(label: Text('Toplam: ${daily.length}')),
            Chip(label: Text('Tamamlanan: $completed')),
            Chip(label: Text('Bekleyen: ${daily.length - completed}')),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Bugünün görevleri',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (daily.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Bugün için görev yok. İlk görevini ekleyebilirsin.'),
          ),
        ...daily.map(
          (task) => TaskTile(task: task, onToggle: () => onToggle(task)),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: const Text('Yeni görev ekle'),
        ),
      ],
    );
  }
}
