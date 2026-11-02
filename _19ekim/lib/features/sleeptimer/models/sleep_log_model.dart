class SleepLogModel {
  const SleepLogModel({
    required this.id,
    required this.sleepTime,
    required this.wakeTime,
    this.quality = 'Dinlendirici',
  });

  final String id;
  final DateTime sleepTime;
  final DateTime wakeTime;
  final String quality;

  Duration get duration {
    if (wakeTime.isAfter(sleepTime)) {
      return wakeTime.difference(sleepTime);
    }
    // Gece yarısı geçişleri için (örn: 23:00'da yatıp ertesi gün 07:00'da uyanma)
    return wakeTime.add(const Duration(days: 1)).difference(sleepTime);
  }

  int get totalMinutes => duration.inMinutes;
  int get hours => duration.inHours;
  int get minutesRemainder => duration.inMinutes.remainder(60);
}
