# Günlüğüm - Flutter Basit Günlük Uygulaması

Bu doküman, **Günlüğüm** projesinin kapsamını, mimari kararlarını, yazım kurallarını ve geliştirme prensiplerini tanımlar. Proje, başlangıç seviyesine uygun, sade, anlaşılır ve sadece bellek içi (in-memory) durum yönetimine dayalı bir Flutter uygulamasıdır.

---

## 1. Proje Özeti ve Amacı

- **Uygulama Adı:** Günlüğüm
- **Platform:** Flutter (Mobil, Web ve Masaüstü uyumlu)
- **Arayüz Dili:** Türkçe
- **Temel Amaç:** Kullanıcının takvim üzerinden tarih seçerek o güne ait günlük notları yazmasını, düzenlemesini, geçmiş günlükleri listelemesini ve açık/koyu tema desteğiyle sade bir deneyim yaşamasını sağlamak.
- **Tasarım Felsefesi:** Gereksiz mimari katmanlardan, harici paketlerden ve kalıcı veri depolama bağımlılıklarından arındırılmış yalın kod tabanı.

---

## 2. Temel Prensipler ve Kısıtlamalar

1. **Yalnızca Bellek İçi Saklama (In-Memory Only):**
   - Veritabanı (SQLite, Hive, Isar vb.), uzak API, dosya sistemi veya `SharedPreferences` kesinlikle kullanılmaz.
   - Uygulama tamamen kapatılıp yeniden başlatıldığında tüm kayıtlar sıfırlanmalıdır.
   - Sekme geçişlerinde (`NavigationBar`) ve tema değişimlerinde (`ThemeMode`) veriler ve kaydedilmemiş taslak metinler asla kaybolmamalıdır.
2. **Yalın Durum Yönetimi:**
   - Harici durum yönetimi paketleri (Bloc, Riverpod, Provider vb.) kullanılmaz.
   - Durum takibi Flutter'ın yerleşik `ValueNotifier` ve `ValueListenableBuilder` sınıfları ile gerçekleştirilir.
3. **Sorumlulukların Ayrımı (Separation of Concerns):**
   - Modeller (`models/`), İş Mantığı / Denetleyiciler (`controllers/`), Ekranlar (`views/`) ve Yeniden Kullanılabilir Parçalar (`widgets/`) kesin sınırlarla ayrılır.
4. **Performans ve Kod Standartları:**
   - Mümkün olan tüm widget'larda `const` kurucular kullanılır.
   - Controller nesneleri `build()` metodunda tekrar oluşturulmaz; kök widget'ın `initState` metodunda yaratılır ve `dispose` anında serbest bırakılır.
   - `TextEditingController` nesneleri ait olduğu stateful widget içerisinde yaşam döngüsüne uygun yönetilir.
5. **Duyarlı (Responsive) Tasarım:**
   - Geniş ekranlarda takvim sol panelde sabit, günlük yazma alanı sağ panelde yer alır.
   - Dar ekranlarda (mobil) takvim üstte, günlük yazma alanı altta dikey sıralanır.
   - Klavye açıldığında taşma (`RenderFlex overflowed`) olmaması için kaydırılabilir (`SingleChildScrollView`) yapılar kullanılır.

---

## 3. Klasör ve Dosya Mimarisi

Proje dizin yapısı özellik odaklı (feature-first) olarak kurgulanmıştır:

```text
lib/
├── main.dart                          # Uygulama başlangıç noktası
├── app.dart                           # MaterialApp ve tema notifier yönetimi
└── features/
    └── diary/
        ├── models/
        │   └── diary_entry.dart       # Günlük veri modeli
        ├── controllers/
        │   └── diary_controller.dart  # Tarih seçimi ve kayıt yönetimi
        ├── views/
        │   ├── diary_home_view.dart   # Ana iskelet, NavigationBar ve sekme yönlendirmesi
        │   ├── diary_editor_view.dart # Günlük yazma / düzenleme ekranı (responsive)
        │   └── diary_list_view.dart   # Kaydedilen günlüklerin listesi
        └── widgets/
            ├── diary_calendar.dart    # Takvim bileşeni
            └── app_logo.dart          # Logo ve başlık bileşeni
```

---

## 4. Veri Modeli Standartları

Günlük modeli JSON serileştirme veya harici kütüphane bağımlılığı içermez. Yalnızca temel alanları ve değişmez (`immutable`) yapıyı temsil eder:

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

- **Tarih Formatlama Prensibi:** Karşılaştırma ve harita (Map) anahtarlama işlemlerinin güvenliği için tarihler saat/dakika/saniye bilgisi sıfırlanmış olarak (`DateUtilsHelper.dayOnly`) saklanır.

---

## 5. Durum Yönetimi (State Management)

### DiaryController Yapısı
- `selectedDate`: Aktif seçili tarihi temsil eden `ValueNotifier<DateTime>`.
- `entries`: Tarih bazlı kayıtları barındıran `ValueNotifier<Map<DateTime, DiaryEntry>>`.
- `drafts`: Kullanıcının kaydet butonuna basmadan önce yazdığı ancak başka tarihe veya sekmeye geçtiğinde kaybolmaması gereken taslak metinleri tutan `Map<DateTime, String>` bellek önbelleği.

### Tema Yönetimi
- `themeMode`: Kök widget düzeyinde `ValueNotifier<ThemeMode>` ile tutulur.
- Açık (`ThemeMode.light`) ve Koyu (`ThemeMode.dark`) mod geçişi üst uygulama çubuğundaki (AppBar) eylem düğmesi ile tetiklenir.

---

## 6. Ekranlar ve Kullanıcı Deneyimi

### Sekme 1: Günlük Yaz (Editor)
- **Tarih Seçimi:** Takvim widget'ı üzerinden gün seçilir.
- **İçerik Yükleme:** Seçili tarihe ait daha önce kaydedilmiş bir günlük varsa `TextField` içine doldurulur; yoksa varsa ilgili tarihin taslak metni yüklenir.
- **Doğrulama:** Boş veya yalnızca boşluktan oluşan metinlerin kaydedilmesine izin verilmez.
- **Bildirim:** Başarılı kayıtlarda `SnackBar` ile "Günlük başarıyla kaydedildi" bildirimi gösterilir.
- **Duyarlılık:** Genişlik eşiği (örn. 600dp) üzerinden yatay veya dikey bölme uygulanır.

### Sekme 2: Günlüklerim (List View)
- Kaydedilen tüm günlükler en yeni tarihten en eskiye doğru (`entries.values.toList()..sort(...)`) sıralı listelenir.
- Her kartta biçimlendirilmiş tarih ve 2 satırlık metin önizlemesi bulunur.
- Bir karta tıklandığında controller üzerinden seçili tarih güncellenir ve kullanıcı doğrudan "Günlük Yaz" sekmesine yönlendirilir.
- Liste boşken ortalanmış ikon ve "Henüz günlük yazmadınız" bilgilendirmesi yer alır.

---

## 7. Kalite ve Test Kontrol Listesi

- [ ] `flutter analyze` çalıştırıldığında sıfır uyarı ve hata vermeli.
- [ ] Bellek yönetimi: Bütün `ValueNotifier` ve `TextEditingController` nesneleri `dispose` edilmeli.
- [ ] Ekran rotasyonunda ve küçük boyutlu ekranlarda taşma olmamalı.
- [ ] Uygulama yeniden başlatıldığında verilerin temizlendiği doğrulanmalı.
- [ ] Sekmeler veya tema değiştirildiğinde verilerin korunduğu doğrulanmalı.
