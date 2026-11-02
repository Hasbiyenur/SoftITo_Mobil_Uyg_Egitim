import 'package:flutter/foundation.dart';
import '../models/water_tracker_model.dart';

class WaterTrackerController {
  final ValueNotifier<int> currentWater = ValueNotifier<int>(1250);
  final ValueNotifier<int> dailyGoal = ValueNotifier<int>(2500);
  final ValueNotifier<List<WaterRecordModel>> records =
      ValueNotifier<List<WaterRecordModel>>([
    WaterRecordModel(
      id: '1',
      amountMl: 250,
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      label: 'Sabah Suyu',
    ),
    WaterRecordModel(
      id: '2',
      amountMl: 500,
      timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
      label: 'Matara',
    ),
    WaterRecordModel(
      id: '3',
      amountMl: 500,
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      label: 'Öğle Suyu',
    ),
  ]);

  void addWater(int amount, [String label = 'Su']) {
    currentWater.value += amount;

    final newRecord = WaterRecordModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amountMl: amount,
      timestamp: DateTime.now(),
      label: label,
    );

    records.value = [newRecord, ...records.value];
  }

  void removeRecord(String id) {
    final recordToRemove = records.value.cast<WaterRecordModel?>().firstWhere(
          (r) => r?.id == id,
          orElse: () => null,
        );

    if (recordToRemove != null) {
      currentWater.value =
          (currentWater.value - recordToRemove.amountMl).clamp(0, 99999);
      records.value = records.value.where((r) => r.id != id).toList();
    }
  }

  void resetWater() {
    currentWater.value = 0;
    records.value = [];
  }

  void updateDailyGoal(int newGoal) {
    if (newGoal > 0) {
      dailyGoal.value = newGoal;
    }
  }

  void dispose() {
    currentWater.dispose();
    dailyGoal.dispose();
    records.dispose();
  }
}
