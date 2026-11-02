import 'package:flutter/foundation.dart';
import '../models/sleep_log_model.dart';

class SleepController extends ChangeNotifier {
  SleepController({int initialTargetHours = 8})
      : _targetHours = initialTargetHours;

  int _targetHours;
  final List<SleepLogModel> _logs = [];

  int get targetHours => _targetHours;
  List<SleepLogModel> get logs => List.unmodifiable(_logs);

  int get totalMinutesToday =>
      _logs.fold(0, (sum, item) => sum + item.totalMinutes);

  int get totalHoursToday => totalMinutesToday ~/ 60;
  int get remainingMinutesToday => totalMinutesToday % 60;

  double get progressRatio {
    if (_targetHours <= 0) return 0.0;
    return (totalMinutesToday / (_targetHours * 60)).clamp(0.0, 1.0);
  }

  void addSleepLog({
    required DateTime sleepTime,
    required DateTime wakeTime,
    String quality = 'Dinlendirici',
  }) {
    final log = SleepLogModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      sleepTime: sleepTime,
      wakeTime: wakeTime,
      quality: quality,
    );
    _logs.insert(0, log);
    notifyListeners();
  }

  void removeLog(String id) {
    _logs.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void updateTargetHours(int hours) {
    if (hours <= 0) return;
    _targetHours = hours;
    notifyListeners();
  }

  void resetToday() {
    _logs.clear();
    notifyListeners();
  }
}
