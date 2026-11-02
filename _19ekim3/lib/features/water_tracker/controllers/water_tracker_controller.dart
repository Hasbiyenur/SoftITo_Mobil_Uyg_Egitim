import 'package:flutter/foundation.dart';
import '../models/water_tracker_model.dart';

/// Reaktif ValueNotifier tabanlı Su Takip durum yöneticisi.
class WaterTrackerController {
  final int dailyGoalWater;

  /// Anlık tüketilen toplam su miktarı (ml)
  final ValueNotifier<int> currentWater = ValueNotifier<int>(0);

  /// Gün içindeki tüketim kayıtları listesi
  final ValueNotifier<List<WaterLogItem>> logList =
      ValueNotifier<List<WaterLogItem>>([]);

  /// İşlem yüklenme durumu
  final ValueNotifier<bool> isProcessing = ValueNotifier<bool>(false);

  WaterTrackerController({this.dailyGoalWater = 2500});

  /// Su ekleme işlemi
  void addWater(int amount) {
    if (amount <= 0) return;

    final newLog = WaterLogItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amountMl: amount,
      timestamp: DateTime.now(),
    );

    currentWater.value += amount;
    logList.value = [newLog, ...logList.value];
  }

  /// Belirli bir tüketim kaydını silme
  void removeLog(String id) {
    final targetIndex = logList.value.indexWhere((item) => item.id == id);
    if (targetIndex == -1) return;

    final targetItem = logList.value[targetIndex];
    currentWater.value = (currentWater.value - targetItem.amountMl).clamp(
      0,
      99999,
    );

    final updated = List<WaterLogItem>.from(logList.value)
      ..removeAt(targetIndex);
    logList.value = updated;
  }

  /// Tüm veriyi sıfırlama
  void reset() {
    currentWater.value = 0;
    logList.value = const [];
  }

  /// Bellek sızıntılarını önlemek için dinleyicileri serbest bırak
  void dispose() {
    currentWater.dispose();
    logList.dispose();
    isProcessing.dispose();
  }
}
