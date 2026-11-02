import 'package:flutter/foundation.dart';
import '../models/diary_entry.dart';

/// Günlük durumunu ve bellek içi kayıtları yöneten denetleyici.
class DiaryController {
  /// Aktif olarak seçilen gün (saat sıfırlı).
  final selectedDate = ValueNotifier<DateTime>(
    DateUtilsHelper.dayOnly(DateTime.now()),
  );

  /// Kayıtlı günlükler haritası (Tarih -> Günlük Kaydı).
  final entries = ValueNotifier<Map<DateTime, DiaryEntry>>({});

  /// Henüz kaydedilmemiş taslak metinlerin bellek havuzu.
  final Map<DateTime, String> _drafts = {};

  /// Seçili tarihi günceller (saat bilgisini sıfırlar).
  void selectDate(DateTime date) {
    selectedDate.value = DateUtilsHelper.dayOnly(date);
  }

  /// Belirtilen tarihe ait kayıtlı günlüğü döner (varsa).
  DiaryEntry? getEntry(DateTime date) {
    final normalized = DateUtilsHelper.dayOnly(date);
    return entries.value[normalized];
  }

  /// Belirtilen tarihe ait kaydedilmemiş taslak metni döner.
  String getDraft(DateTime date) {
    final normalized = DateUtilsHelper.dayOnly(date);
    return _drafts[normalized] ?? '';
  }

  /// Belirtilen tarihe ait taslak metni günceller.
  void updateDraft(DateTime date, String text) {
    final normalized = DateUtilsHelper.dayOnly(date);
    if (text.trim().isEmpty) {
      _drafts.remove(normalized);
    } else {
      _drafts[normalized] = text;
    }
  }

  /// Günlüğü kaydeder. Başarılı ise true, metin boşsa false döner.
  bool saveEntry(String content) {
    final text = content.trim();
    if (text.isEmpty) return false;

    final date = selectedDate.value;

    // Değişmez harita kopyalaması ile reaktif güncelleme
    entries.value = {
      ...entries.value,
      date: DiaryEntry(date: date, content: text),
    };

    // Kayıt tamamlandığında bu tarihin taslağını temizle
    _drafts.remove(date);
    return true;
  }

  /// Notifier nesnelerini serbest bırakır.
  void dispose() {
    selectedDate.dispose();
    entries.dispose();
  }
}

/// Tarih işlemleri için yardımcı sınıf.
class DateUtilsHelper {
  /// Tarihi saat, dakika ve saniyeden arındırarak yalnızca gün olarak döndürür.
  static DateTime dayOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Tarihi Türkçe formatta metne çevirir (örn: 19 Ekim 2026).
  static String formatDate(DateTime date) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
