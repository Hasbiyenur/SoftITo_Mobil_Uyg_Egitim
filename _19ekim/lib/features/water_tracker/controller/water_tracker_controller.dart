import 'package:flutter/foundation.dart';
import '../models/water_log_model.dart';

class WaterTrackerController extends ChangeNotifier {
  WaterTrackerController({int initialGoal = 2500}) : _dailyGoalMl = initialGoal;

  int _dailyGoalMl;
  final List<WaterLogModel> _logs = [];

  int get dailyGoalMl => _dailyGoalMl;
  List<WaterLogModel> get logs => List.unmodifiable(_logs);

  int get totalConsumedMl =>
      _logs.fold(0, (sum, item) => sum + item.amountInMl);

  double get progressRatio {
    if (_dailyGoalMl <= 0) return 0.0;
    return (totalConsumedMl / _dailyGoalMl).clamp(0.0, 1.0);
  }

  int get remainingMl =>
      (_dailyGoalMl - totalConsumedMl).clamp(0, _dailyGoalMl);

  void addWater(int amountInMl, {String containerName = 'Bardak'}) {
    if (amountInMl <= 0) return;
    final log = WaterLogModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      amountInMl: amountInMl,
      timestamp: DateTime.now(),
      containerName: containerName,
    );
    _logs.insert(0, log);
    notifyListeners();
  }

  void removeLog(String id) {
    _logs.removeWhere((log) => log.id == id);
    notifyListeners();
  }

  void updateDailyGoal(int newGoal) {
    if (newGoal <= 0) return;
    _dailyGoalMl = newGoal;
    notifyListeners();
  }

  void resetToday() {
    _logs.clear();
    notifyListeners();
  }
}
