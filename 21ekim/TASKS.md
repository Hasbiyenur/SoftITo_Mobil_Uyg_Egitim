# Alışkanlık Takibi — Görev Listesi (TASKS)

Uygulama geliştirme sırası:

- [x] **Aşama 1: Temel Mimari, Tema ve Gezinme İskeleti**
  - Soft renk paleti (`app_colors.dart`), Material 3 teması (`app_theme.dart`).
  - Uygulama logosu (`app_logo.dart`) ve ortak UI bileşenleri.
  - Açılış ekranı (`bootstrap_screen.dart`), 3 sekmeli sabit alt menü (`main_shell.dart`), ekran iskeletleri.
  - Saat ve tarih anahtarı yardımcıları (`app_clock.dart`, `date_key.dart`).

- [x] **Aşama 2: Veri Modelleri, Yerel Depolama ve Demo Kimlik Akışı**
  - `StoreDocument`, `LocalStore` (`SharedPreferencesAsync` tabanlı JSON kalıcılığı).
  - Güvenli demo şifre doğrulama (`demo_password_service.dart`, PBKDF2/SHA256 salt & hash, açık metin yok).
  - Kullanıcı modeli (`AppUser`), `AuthRepository` ve `AuthController`.
  - Giriş (`login_screen.dart`), Kayıt (`register_screen.dart`), Şifremi Unuttum (`forgot_password_screen.dart`), Yeni Şifre Oluştur (`reset_password_screen.dart`), Çıkış akışları.

- [x] **Aşama 3: Görev Modelleri, Tekrar Planı ve Görev Yönetimi**
  - `Habit`, `HabitSchedule`, `HabitEntry` modelleri.
  - `ScheduleService` (takvim gününe göre N günde bir planlama).
  - `HabitRepository` ve `HabitController`.
  - Görevler listesi (`habits_screen.dart`) ve düzenleme/kaldırma modları.
  - Görev Ekle / Düzenle formu (`habit_form_screen.dart`): tik ve bar seçenekleri, sürümleme kuralları.

- [x] **Aşama 4: Günlük Tamamlama, Ana Sayfa ve Bildirimler**
  - Ana sayfa (`home_screen.dart`): Günün selamlaması, tarihi, günlük özet kartı.
  - Bugün Yapılacaklar ve Yapılanlar bölümleri.
  - Tikleme ve miktar artırma/azaltma, tamamlanınca soluk/çizgili Yapılanlar'a geçiş, aynı gün geri alma.
  - Uygulama içi hatırlatmalar (`reminder_service.dart`, `notification_controller.dart`).

- [x] **Aşama 5: Seri (Streak), Takvim, İstatistik ve Rozetler**
  - `StreakService`: Yalnızca planlı ardışık günler, dinlenme günleri seriyi bozmaz.
  - `StatisticsService` ve `AchievementService`: 10 (Bronz), 25 (Gümüş), 50 (Altın) rozetleri; aynı gün geri alma uzlaştırması.
  - Profil ekranı (`profile_screen.dart`): Seriler, rekor, çıkış.
  - İstatistikler ekranı (`statistics_screen.dart`): Hafta/Ay tamamlama oranları, rozet vitrini, grafikler.
  - Takvim ekranı (`calendar_screen.dart`): Ay ızgarası, tamamlama filtreleri, gün detayları.

- [x] **Aşama 6: Doğrulama, Testler, Kod Formatı ve Belgelendirme**
  - Birim ve akış testleri (`schedule_service_test.dart`, `streak_service_test.dart`, `habit_flow_test.dart`).
  - `dart format .`, `flutter analyze` ve `flutter test` kontrolleri (Tümü sıfır hatayla geçti).
  - macOS derleme ve çalıştırma doğrulandı (`flutter run -d macos`).
  - `README.md` kurulum, çalıştırma, demo hesaplar ve demo sınırlarıyla tamamlandı.
