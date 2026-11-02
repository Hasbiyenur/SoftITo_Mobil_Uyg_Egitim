import 'date_key.dart';

/// Testlerde saati taklit edebilmek veya cihaz saatini standartlaştırmak için
/// saat soyutlaması.
class AppClock {
  final DateTime Function() _nowProvider;

  AppClock([DateTime Function()? nowProvider])
    : _nowProvider = nowProvider ?? DateTime.now;

  DateTime now() => _nowProvider();

  String todayKey() => DateKey.today(now()).value;

  /// Saat aralığına göre Türkçe selamlama metni
  /// 05.00–10.59: Günaydın
  /// 11.00–16.59: İyi günler
  /// 17.00–21.59: İyi akşamlar
  /// 22.00–04.59: İyi geceler
  String greeting() {
    final current = now();
    final hour = current.hour;
    if (hour >= 5 && hour < 11) {
      return 'Günaydın';
    } else if (hour >= 11 && hour < 17) {
      return 'İyi günler';
    } else if (hour >= 17 && hour < 22) {
      return 'İyi akşamlar';
    } else {
      return 'İyi geceler';
    }
  }
}
