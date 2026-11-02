# Girişimcilik Uygulaması — Geliştirme ve Takip Raporu (yapilanlar.md)

Bu dosya, `rehber_plani.md` ve güncellenen `reference/girisimci_rehberi_proje_plani.md` isterleri doğrultusunda **Girişimcilik** mobil uygulamasının adım adım geliştirme sürecini ve tamamlanan işlemleri anlık olarak kayıt altına alır.

---

## 📌 Proje Özeti
- **Uygulama Adı:** Girişimcilik
- **Platform:** Flutter / Dart (iOS, Android ve Web uyumlu)
- **Mimari:** Sade, backend gerektirmeyen, Material 3 tabanlı mobil öğrenci ve rehberlik projesi.
- **Tema:** Açık ve Koyu Mod (Light & Dark Theme) desteği.

---

## 📋 Yapılan İşlemler ve Aşama Takibi

### [Adım 1] - 2026-10-20: Proje Planının Tespiti ve Hazırlık
- **Durum:** ✅ Tamamlandı
- **Açıklama:**
  - `rehber_plani.md` planı doğrulandı ve kalıcı referans olarak projeye işlendi.
  - Çalışma alanı incelendi, Flutter sürümü ve ortam bağımlılıkları kontrol edildi.

---

### [Adım 2] - 2026-10-20: Flutter Projesinin Oluşturulması
- **Durum:** ✅ Tamamlandı
- **Açıklama:**
  - `flutter create --project-name girisimcilik .` komutu ile Flutter altyapısı doğrudan `20ekim` dizininde kuruldu.
  - `pubspec.yaml` yapılandırması tamamlandı.

---

### [Adım 3] - 2026-10-20: Proje Kapsamı ve Referans Dokümanları
- **Durum:** ✅ Tamamlandı
- **Açıklama:**
  - [project_overview.md](file:///Users/d1-12/Documents/GitHub/SoftITo_Mobil_Uyg_Egitim/20ekim/reference/project_overview.md) ve [girisimci_rehberi_proje_plani.md](file:///Users/d1-12/Documents/GitHub/SoftITo_Mobil_Uyg_Egitim/20ekim/reference/girisimci_rehberi_proje_plani.md) oluşturuldu ve proje isterleri arşivlendi.

---

### [Adım 4] - 2026-10-20: Logo ve Görsel Varlıkların Üretimi
- **Durum:** ✅ Tamamlandı
- **Açıklama:**
  - Girişimcilik ve startup ruhunu simgeleyen, fırlayan roket ve fikir ampulü sentezinden oluşan modern bir logo üretildi.
  - Logo [logo.png](file:///Users/d1-12/Documents/GitHub/SoftITo_Mobil_Uyg_Egitim/20ekim/assets/images/logo.png) olarak kaydedildi ve `pubspec.yaml` varlıklarına eklendi.
  - iOS uygulama simgesi (`ios/Runner/Assets.xcassets/AppIcon.appiconset/`) için tüm çözünürlüklerde `sips` motoru ile ikonlar üretildi.
  - `ios/Runner/Info.plist` dosyasına `CFBundleDisplayName` değeri "Girişimcilik" olarak tanımlandı.

---

### [Adım 5] - 2026-10-20: Sabit Örnek Veri Seti (`sample_data.dart`)
- **Durum:** ✅ Tamamlandı
- **Açıklama:**
  - [sample_data.dart](file:///Users/d1-12/Documents/GitHub/SoftITo_Mobil_Uyg_Egitim/20ekim/lib/data/sample_data.dart) oluşturuldu ve zenginleştirildi:
    - **Rehber Adımları:** Girişimcilik nedir, iş fikri oluşturma, yalın kanvas ve şirket kurma aşamaları.
    - **Demo Mentorlar:** Kurgusal 4 mentor profili, uzmanlık alanları, kurgusal biyografileri ve stratejik tavsiyeleri.
    - **Hukuki Destek:** Şirket türleri karşılaştırması, ortaklık ve gizlilik sözleşmeleri, marka tescili ve 2 kurgusal avukat profili.
    - **Devlet Destekleri:** KOSGEB, TÜBİTAK ve teknokent destek mekanizmaları ile resmi web sitesi bağlantıları.
    - **Yatırımcılık Konuları:** Melek Yatırımcı, Girişim Sermayesi (VC), Pitch Deck ve Hibe vs. Yatırım Farkı modelleri.
    - **Demo Yatırımcı Profilleri:** 3 adet kurgusal yatırımcı (Kerem Aras, Aylin Çetin, Bora Tan).

---

### [Adım 6] - 2026-10-20: Ortak Bileşenler (`info_card.dart`)
- **Durum:** ✅ Tamamlandı
- **Açıklama:**
  - [info_card.dart](file:///Users/d1-12/Documents/GitHub/SoftITo_Mobil_Uyg_Egitim/20ekim/lib/widgets/info_card.dart) oluşturuldu.
  - `InfoCard` ve `NoticeBanner` bileşenleri hem açık hem koyu temaya duyarlı hale getirildi.

---

### [Adım 7] - 2026-10-20: Ekranların Geliştirilmesi ve Yatırımcılar Sekmesi
- **Durum:** ✅ Tamamlandı
- **Açıklama:**
  - [home_screen.dart](file:///Users/d1-12/Documents/GitHub/SoftITo_Mobil_Uyg_Egitim/20ekim/lib/screens/home_screen.dart): Logo, karşılama kutusu, tema değiştirme butonu ve 4 ana kategori yönlendirme kartı içeren ana ekran.
  - [guide_screen.dart](file:///Users/d1-12/Documents/GitHub/SoftITo_Mobil_Uyg_Egitim/20ekim/lib/screens/guide_screen.dart): Girişimcilik rehberi ve detay panelleri.
  - [mentors_screen.dart](file:///Users/d1-12/Documents/GitHub/SoftITo_Mobil_Uyg_Egitim/20ekim/lib/screens/mentors_screen.dart): Kurgusal mentor profilleri ve detay modalı.
  - [legal_screen.dart](file:///Users/d1-12/Documents/GitHub/SoftITo_Mobil_Uyg_Egitim/20ekim/lib/screens/legal_screen.dart): Hukuki genel bilgiler, yasal uyarı ve demo avukatlar.
  - [supports_screen.dart](file:///Users/d1-12/Documents/GitHub/SoftITo_Mobil_Uyg_Egitim/20ekim/lib/screens/supports_screen.dart): `TabBar` ile iki alt kategoriye (Devlet Destekleri & Yatırımcılar) ayrıldı.

---

### [Adım 8] - 2026-10-20: Karanlık / Aydınlık Mod (ThemeMode) Entegrasyonu
- **Durum:** ✅ Tamamlandı
- **Açıklama:**
  - [main.dart](file:///Users/d1-12/Documents/GitHub/SoftITo_Mobil_Uyg_Egitim/20ekim/lib/main.dart) içerisinde `themeModeNotifier` (`ValueNotifier<ThemeMode>`) tanımlandı.
  - Material 3 uyumlu hem açık (`ThemeData.light()`) hem koyu (`ThemeData.dark()`) renk paletleri ve AppBar, Card temaları yapılandırıldı.
  - [home_screen.dart](file:///Users/d1-12/Documents/GitHub/SoftITo_Mobil_Uyg_Egitim/20ekim/lib/screens/home_screen.dart) üst çubuğuna (AppBar) tek dokunuşla çalışan dinamik tema geçiş düğmesi (`Icons.dark_mode_outlined` / `Icons.light_mode_outlined`) yerleştirildi.
  - Tüm ekranlardaki kartlar, kutular ve alt açılır paneller koyu modda kusursuz okunabilirlik için uyarlandı.

---

### [Adım 9] - 2026-10-20: Statik Kod Analizi ve Test Doğrulaması
- **Durum:** ✅ Tamamlandı
- **Açıklama:**
  - `flutter analyze` çalıştırıldı: **0 hata, 0 uyarı (No issues found)**.
  - [widget_test.dart](file:///Users/d1-12/Documents/GitHub/SoftITo_Mobil_Uyg_Egitim/20ekim/test/widget_test.dart) güncellenerek tema modu geçişi, sekmeler ve gezinme akışları test edildi: **All tests passed!**
