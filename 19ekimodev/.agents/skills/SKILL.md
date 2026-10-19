---
name: flutter-diary-scaffold
description: Flutter ile takvimden tarih seçilerek günlük yazılan, kayıtları bellekte tutan ve açık/koyu tema destekleyen basit bir günlük uygulaması geliştirir.
---

# Flutter Günlük Uygulaması

Başlangıç seviyesine uygun, sade bir günlük uygulaması oluştur. Kodları anlaşılır tut ve gereksiz mimari katmanlar ekleme.

## Temel Kurallar

- Arayüz dili Türkçe, uygulama adı **Günlüğüm** olsun.
- Veritabanı, API, dosya veya SharedPreferences kullanma.
- Günlükler yalnızca bellekte tutulsun; uygulama tamamen kapatılıp yeniden açılınca sıfırlansın.
- Sekme ve tema değişikliklerinde kayıtlar korunsun.
- Durum yönetiminde `ValueNotifier` ve `ValueListenableBuilder` kullan.
- Model, controller ve ekran dosyalarını ayır.
- Mümkün olan widget’larda `const` kullan.
- Gereksiz paketler, oturum açma veya ek özellikler ekleme.

## 1. Klasör Yapısı

```text
lib/
  main.dart
  app.dart
  features/
    diary/
      models/
        diary_entry.dart
      controllers/
        diary_controller.dart
      views/
        diary_home_view.dart
        diary_editor_view.dart
        diary_list_view.dart
      widgets/
        diary_calendar.dart
        app_logo.dart
```

## 2. Günlük Modeli

Her tarih için bir günlük kaydı tut. Basit bir model yeterlidir:

```dart
class DiaryEntry {
  final DateTime date;
  final String content;

  const DiaryEntry({
    required this.date,
    required this.content,
  });
}
```

Kalıcı depolama olmadığı için JSON dönüşüm metotları ekleme.

## 3. Controller

Seçili tarihi ve günlük kayıtlarını controller içinde yönet. Tarihleri saat bilgisi olmadan sakla. Aynı tarihe tekrar kaydedildiğinde mevcut kaydı güncelle.

```dart
import 'package:flutter/foundation.dart';
import '../models/diary_entry.dart';

class DiaryController {
  final selectedDate = ValueNotifier<DateTime>(
    DateUtilsHelper.dayOnly(DateTime.now()),
  );

  final entries = ValueNotifier<Map<DateTime, DiaryEntry>>({});

  void selectDate(DateTime date) {
    selectedDate.value = DateUtilsHelper.dayOnly(date);
  }

  bool saveEntry(String content) {
    final text = content.trim();
    if (text.isEmpty) return false;

    final date = selectedDate.value;

    entries.value = {
      ...entries.value,
      date: DiaryEntry(date: date, content: text),
    };
    return true;
  }

  void dispose() {
    selectedDate.dispose();
    entries.dispose();
  }
}

class DateUtilsHelper {
  static DateTime dayOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
```

Controller’ı kök widget’ın `initState` metodunda bir kez oluştur, ekranlara parametre olarak aktar ve kök widget’ın `dispose` metodunda kapat. `build` içinde yeniden oluşturma.

## 4. Ekranlar

`NavigationBar` ile iki sekme oluştur:

### Günlük Yaz

- Takvimden gün seçilsin.
- Geniş ekranda takvim solda sabit kalsın, yazma alanı sağda açılsın.
- Dar ekranda takvim üstte, yazma alanı altta yer alsın.
- Yazma alanında seçilen tarih, çok satırlı `TextField` ve “Kaydet” düğmesi bulunsun.
- Kayıtlı gün seçildiğinde mevcut günlük metni yüklensin.
- Boş metin kaydedilmesin.
- Kaydetme sonucunu `SnackBar` ile bildir.
- Kaydedilmemiş metinleri tarih bazında bellekte tut; tarih veya sekme değişiminde kaybolmasın.

Controller’daki kayıt değişikliklerini dinlemek için:

```dart
ValueListenableBuilder<Map<DateTime, DiaryEntry>>(
  valueListenable: controller.entries,
  builder: (context, entries, child) {
    return Text('${entries.length} günlük kaydedildi');
  },
)
```

Metin alanı için kullanılan `TextEditingController` nesnesini ilgili widget içinde oluştur ve `dispose` ile kapat. Tarih değiştiğinde metni güncelle; her `build` çağrısında sıfırlama.

### Günlüklerim

- Kaydedilen günlükleri `ListView` ile göster.
- Her öğede tarih ve kısa metin ön izlemesi bulunsun.
- Günlükleri en yeni tarihten başlayarak sırala.
- Bir kayda basıldığında ilgili tarihi yazma sekmesinde aç.
- Liste boşsa “Henüz günlük yazmadınız” mesajını göster.

## 5. Açık/Koyu Tema ve Logo

Tema tercihini bellekte bir `ValueNotifier<ThemeMode>` ile tut. Değişiklikleri `ValueListenableBuilder` ile `MaterialApp` üzerine uygula:

```dart
final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);

void toggleTheme() {
  themeMode.value = themeMode.value == ThemeMode.light
      ? ThemeMode.dark
      : ThemeMode.light;
}
```

`MaterialApp` içinde `ThemeData.light()`, `ThemeData.dark()` ve seçilen `themeMode` değerini kullan. Tema notifier’ını da kökte bir kez oluştur ve kullanım sonunda kapat.

Üst çubuğa tema değiştirme düğmesi ekle. Basit logo için `Icons.auto_stories_rounded` simgesini “Günlüğüm” yazısıyla birlikte kullan.

## 6. Kontroller

- Tarih seçme, günlük kaydetme ve kayıt güncelleme çalışmalı.
- Sekme veya tema değişince günlükler korunmalı.
- Uygulama yeniden başlatılınca veriler sıfırlanmalı.
- Küçük ekranda ve klavye açıldığında taşma olmamalı.
- `flutter analyze` ile hataları kontrol et.

Varsa `project.md` ve `reference/state_flow.md` dosyalarını incele. `examples/sample_screen.dart` dosyasını örnek olarak kullan; bu basit projeye uygun olmayan ek yapıları taşıma. Yeni özellik veya bileşen iskeleti oluşturmak için `script/generate_feature.sh` betiğini kullan.