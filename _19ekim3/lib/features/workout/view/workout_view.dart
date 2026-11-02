import 'package:flutter/material.dart';
import '../controllers/workout_controller.dart';
import '../models/workout_model.dart';
import '../widgets/workout_card.dart';
import '../../../core/theme.dart';

class WorkoutView extends StatelessWidget {
  final WorkoutController controller;

  const WorkoutView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.fitness_center, color: AppTheme.neonLime),
            SizedBox(width: 8),
            Text('Egzersiz & Kalori'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sıfırla',
            icon: const Icon(Icons.refresh, color: AppTheme.textSecondary),
            onPressed: controller.reset,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Atomik Reaktif Kalori ve Süre İlerleme Kartı
              AnimatedBuilder(
                animation: Listenable.merge([
                  controller.totalCaloriesBurned,
                  controller.totalDurationMinutes,
                ]),
                builder: (context, _) {
                  return WorkoutProgressCard(
                    burnedCalories: controller.totalCaloriesBurned.value,
                    goalCalories: controller.dailyCalorieGoal,
                    totalMinutes: controller.totalDurationMinutes.value,
                  );
                },
              ),
              const SizedBox(height: 24),

              // Hızlı Aktivite Ekleme Butonları
              WorkoutQuickActions(
                onAdd: (name, duration, calories) => controller.addWorkout(
                  name: name,
                  durationMinutes: duration,
                  caloriesBurned: calories,
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Bugünkü Egzersizler',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),

              // Reaktif Egzersiz Geçmişi
              ValueListenableBuilder<List<WorkoutActivity>>(
                valueListenable: controller.activityList,
                builder: (context, list, _) {
                  if (list.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: const Text(
                        'Henüz bir egzersiz kaydedilmedi.',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return WorkoutLogTile(
                        key: ValueKey(item.id),
                        item: item,
                        onDelete: () => controller.removeWorkout(item.id),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
