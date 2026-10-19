import 'package:flutter/material.dart';
import '../controllers/water_tracker_controller.dart';
import '../models/water_tracker_model.dart';
import '../widgets/water_tracker_card.dart';
import '../widgets/quick_water_buttons.dart';
import '../widgets/water_history_list.dart';
import '../widgets/hydration_tip_card.dart';

class WaterTrackerView extends StatelessWidget {
  final WaterTrackerController controller;

  const WaterTrackerView({
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
          // Reaktif Su Gösterge Kartı
          ValueListenableBuilder<int>(
            valueListenable: controller.dailyGoal,
            builder: (context, goal, _) {
              return ValueListenableBuilder<int>(
                valueListenable: controller.currentWater,
                builder: (context, current, _) {
                  return WaterTrackerCard(
                    currentWater: current,
                    dailyGoal: goal,
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20),

          // Hızlı Su Ekleme Butonları
          QuickWaterButtons(
            onAdd: controller.addWater,
            onReset: controller.resetWater,
          ),
          const SizedBox(height: 20),

          // Bilgi Kartı
          const HydrationTipCard(),
          const SizedBox(height: 20),

          // Tüketim Geçmişi
          ValueListenableBuilder<List<WaterRecordModel>>(
            valueListenable: controller.records,
            builder: (context, recordsList, _) {
              return WaterHistoryList(
                records: recordsList,
                onDelete: controller.removeRecord,
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
