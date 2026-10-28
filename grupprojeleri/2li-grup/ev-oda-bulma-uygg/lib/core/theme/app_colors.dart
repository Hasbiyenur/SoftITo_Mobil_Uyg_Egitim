import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılan renk paletini tanımlayan yardımcı sınıf.
/// Aydınlık (Light) ve Karanlık (Dark) temalar için uyumlu, modern renk tonlarını barındırır.
class AppColors {
  // ================= AYDINLIK TEMA RENKLERİ (LIGHT THEME) =================
  /// Ana marka rengi: Canlı ve sıcak kiremit/turuncu tonu
  static const Color primaryLight = Color(0xFFE06A3B);

  /// İkincil vurgu rengi: Sıcak sarı/kehribar tonu
  static const Color secondaryLight = Color(0xFFF39C12);

  /// Aydınlık mod arka plan rengi: Gözü yormayan sıcak kırık beyaz / bej
  static const Color backgroundLight = Color(0xFFFCF9F5);

  /// Kart ve yüzey bileşenleri arka plan rengi
  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// Birincil metin ve başlık rengi: Koyu lacivert/antrasit
  static const Color textLightPrimary = Color(0xFF2C3E50);

  /// İkincil metin ve açıklama rengi: Nötr koyu gri
  static const Color textLightSecondary = Color(0xFF2C2C2C);

  /// Vurgulu bej rengi: Kart ve etiket arka planlarında kullanılır
  static const Color accentBeige = Color(0xFFF5EBE1);

  // ================= KARANLIK TEMA RENKLERİ (DARK THEME) =================
  /// Karanlık mod için ana marka rengi: Daha derin pas/turuncu tonu
  static const Color primaryDark = Color(0xFFD35400);

  /// Karanlık mod ikincil vurgu rengi: Koyu kehribar
  static const Color secondaryDark = Color(0xFFA04000);

  /// Karanlık mod genel arka plan rengi: Çok koyu sıcak kahve-siyah
  static const Color backgroundDark = Color(0xFF1A120B);

  /// Karanlık mod kart ve yüzey rengi: Koyu antrasit-kahverengi
  static const Color surfaceDark = Color(0xFF2D1F16);

  /// Karanlık mod metin rengi: Yumuşak açık bej-gri
  static const Color textDark = Color(0xFFE0DCD3);

  // ================= DURUM VE BİLDİRİM RENKLERİ (STATUS COLORS) =================
  /// Başarılı işlemler ve onay durumları için yeşil tonu
  static const Color success = Color(0xFF27AE60);

  /// Uyarı, dikkat gerektiren durumlar için sarı/turuncu tonu
  static const Color warning = Color(0xFFF1AC0D);

  /// Hata, iptal ve silme durumları için kırmızı tonu
  static const Color error = Color(0xFFB03A2E);
}
