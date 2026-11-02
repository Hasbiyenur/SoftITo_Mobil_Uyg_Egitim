import 'package:flutter/material.dart';
import '../controllers/workout_controller.dart';
import '../models/workout_model.dart';
import '../widgets/calorie_summary_card.dart';
import '../widgets/workout_card.dart';
import '../widgets/workout_history_list.dart';

class WorkoutView extends StatelessWidget {
  final WorkoutController controller;

  const WorkoutView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reaktif Kalori ve Aktivite Özeti
          ValueListenableBuilder<int>(
            valueListenable: controller.dailyCalorieGoal,
            builder: (context, goal, _) {
              return ValueListenableBuilder<int>(
                valueListenable: controller.totalCaloriesBurned,
                builder: (context, totalCalories, _) {
                  return ValueListenableBuilder<List<WorkoutModel>>(
                    valueListenable: controller.workouts,
                    builder: (context, workoutsList, _) {
                      final totalMinutes = workoutsList.fold<int>(
                        0,
                        (sum, item) => sum + item.durationMinutes,
                      );

                      return CalorieSummaryCard(
                        totalCalories: totalCalories,
                        goalCalories: goal,
                        totalMinutes: totalMinutes,
                      );
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20),

          // Aktivite Ekleme Kartları
          WorkoutCard(
            onAddWorkout: controller.addWorkout,
            onReset: controller.resetWorkout,
          ),
          const SizedBox(height: 20),

          // Egzersiz Geçmişi
          ValueListenableBuilder<List<WorkoutModel>>(
            valueListenable: controller.workouts,
            builder: (context, workoutsList, _) {
              return WorkoutHistoryList(
                workouts: workoutsList,
                onDelete: controller.removeWorkout,
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
