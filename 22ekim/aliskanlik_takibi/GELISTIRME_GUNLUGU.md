# Alışkanlık Takibi — Geliştirme Günlüğü

Bu belge, projenin adım adım geliştirilme sürecini ve yapılan tüm işlemleri takip etmek amacıyla tutulmuştur.

## Proje Durumu Özeti
- **Tarih:** 21 Ekim 2026
- **Hedef:** Türkçe, soft renkli Material 3 temalı, çevrimdışı yerel depolama kullanan, eksiksiz çalışan bir Alışkanlık Takibi Flutter uygulaması.
- **Durum:** ✅ Başarıyla Tamamlandı (10/10 Test Başarılı, `flutter analyze` 0 hata/uyarı, macOS hedefinde derlenip çalıştırıldı).

---

### [x] Başlangıç ve Yapılandırma
- Proje dizini incelendi; iç içe proje oluşturmadan doğrudan mevcut kökte `flutter create --project-name aliskanlik_takibi .` ile Flutter projesi başlatıldı.
- `pubspec.yaml` dosyasına gerekli paketler eklendi:
  - `provider: ^6.1.5+1`
  - `shared_preferences: ^2.5.6`
  - `intl: ^0.20.3`
  - `cryptography: ^2.9.0`
  - `crypto: ^3.0.7`
  - `flutter_localizations` (SDK)
  - `shared_preferences_platform_interface: ^2.4.2` (testler için)
- `TASKS.md` oluşturuldu.

---

### [x] Aşama 1: Temel Mimari, Tema ve Gezinme İskeleti
- Soft, pastel, neon içermeyen Material 3 renk paleti (`lib/core/theme/app_colors.dart`) ve teması (`lib/core/theme/app_theme.dart`) hazırlandı.
- Vektörel, hafif ve bağımsız Flutter uygulama logosu (`lib/core/widgets/app_logo.dart`) kodlandı.
- Ortak metin giriş alanı (`app_text_field.dart`), butonlar (`primary_button.dart`) ve simge sağlayıcı (`app_icons.dart`) oluşturuldu.
- Takvim günü anahtarı yardımcı sınıfı (`date_key.dart` - "yyyy-MM-dd" formatında UTC gün bileşenleri farkı) ve cihaz saati soyutlaması (`app_clock.dart`) kodlandı.
- 3 sekmeli sabit alt menü kabuğu (`lib/app/main_shell.dart`) kuruldu.

---

### [x] Aşama 2: Veri Modelleri, Yerel Depolama ve Demo Kimlik Akışı
- Şema sürümü 1 olan `StoreDocument` (`store_document.dart`) ve `SharedPreferencesAsync` kullanan `LocalStore` (`local_store.dart`) geliştirildi.
- PBKDF2-HMAC-SHA256 ve 16 baytlık kriptografik rastgele tuz (salt) kullanan güvenli `DemoPasswordService` oluşturuldu. Parolalar hiçbir zaman açık metin saklanmaz.
- Kullanıcı modeli (`AppUser`), `AuthRepository` ve `LocalAuthRepository` geliştirildi.
- `AuthController` ile oturum yönetimi, bellek içi 6 haneli demo şifre sıfırlama kodu (5 dakika geçerli) ve 10 dakikalık tek kullanımlık yetki oturumu kodlandı.
- Giriş (`login_screen.dart`), Kaydol (`register_screen.dart`), Şifremi Unuttum (`forgot_password_screen.dart`), Yeni Şifre Oluştur (`reset_password_screen.dart`) ekranları tamamlandı.
- Varsayılan hazır demo tohumu (`demo_seed.dart`) ile `Hasbiyenur Kaya` (`demo@aliskanlik.com` / `demo1234`) ve geçmiş kayıtları eklendi.

---

### [x] Aşama 3: Görev Modelleri, Tekrar Planı ve Görev Yönetimi
- `Habit`, `HabitSchedule`, `HabitEntry` modelleri oluşturuldu.
- `ScheduleService`: Takvim gününe göre N günde bir planlama, başlangıç tarihi ve kaldırma tarihi kısıtları uygulandı.
- `HabitRepository` ve `LocalHabitRepository` ile kullanıcı izolasyonlu veri erişimi sağlandı.
- `HabitController`: Görev ekleme, düzenleme (geçmiş kayıtları olan görevlerde plan değişikliklerinin yarından itibaren geçerli yeni sürüm olarak saklanması) ve mantıksal kaldırma (geçmişi koruyan arşivleme) bağlandı.
- `HabitsScreen`: Aktif görevler listesi, kart detayları, "Düzenle" seçim modu ve çoklu seçimli onay pencereli "Kaldır" modu kodlandı.
- `HabitFormScreen`: Tik atma veya bar doldurma (miktar, birim, adım), başlangıç tarihi, sonraki 3 planlı gün önizlemesi, hedef saati, hatırlatma tercihi, simge ve renk seçici ile eksiksiz form bağlandı.

---

### [x] Aşama 4: Günlük Tamamlama, Ana Sayfa ve Bildirimler
- `HomeScreen`:
  - Cihazın yerel saatine göre Türkçe selamlama (Günaydın / İyi günler / İyi akşamlar / İyi geceler) ve kullanıcının adı.
  - Günün tarihi (`21 Ekim 2026, Çarşamba` biçiminde).
  - Günlük özet çubuğu (% ve oran).
  - **Bugün Yapılacaklar:** Hedef saatine göre artan sırada sıralanan bugün planlı görevler.
  - **Yapılanlar:** Tamamlanan görevler, en son tamamlanan en üstte olacak şekilde; başlıkta tek çizgi ve soluk kart yüzeyi.
  - Tik atma ve miktar sayacı artırma/azaltma ile tamamlama ve aynı gün geri alma (undo).
- `ReminderService` ve `NotificationController`:
  - Hedef saatinden 1 saat önce uygulama içi hatırlatma üretimi (`rem_habitId_todayKey`).
  - Ana sayfadaki bildirim simgesinden modal liste ile bildirimleri görüntüleme ve okundu işaretleme.

---

### [x] Aşama 5: Seri (Streak), Takvim, İstatistik ve Rozetler
- `StreakService`:
  - Seri yalnızca art arda tamamlanan planlı günlere göre artırılır.
  - 2 günde bir vb. alışkanlıklarda ara dinlenme günleri seriyi bozmaz.
  - Bugün henüz tamamlanmadıysa gün kapanmadan seri bozulmaz; gün atlandığında sıfırlanır.
- `AchievementService`:
  - Tek bir alışkanlığın kesintisiz serisine göre 10 (Bronz Başlangıç), 25 (Gümüş Devamlılık) ve 50 (Altın İstikrar) rozetleri otomatik kazanılır.
  - Aynı gün geri alma işlemi yapılırsa o seriyi sağlayan tek koşul bozulduğunda yeni rozet uzlaştırılarak geri alınır; kalıcı meşru rozetler korunur.
- `ProfileScreen`: Kullanıcı adı, e-posta, seriler, en yüksek rekor özeti, istatistik kartı ve çıkış butonu.
- `StatisticsScreen`: Bu Hafta / Bu Ay segmented seçimi, başarı yüzdesi, 7 günlük başarı grafiği, tüm zamanların rekoru ve rozet vitrini.
- `CalendarScreen`: Pazartesi başlayan aylık ızgara, tüm alışkanlıklar veya tek alışkanlık filtresi, tamamlanan günlerin vurgulanması, seçilen günün detaylı görev listesi.

---

### [x] Aşama 6: Doğrulama, Testler, Kod Formatı ve Belgelendirme
- `test/schedule_service_test.dart` (Tekrar planı hesaplamaları)
- `test/streak_service_test.dart` (Seri, ara günler, gün kapanışı ve sıfırlanma testleri)
- `test/habit_flow_test.dart` (Tikleme, geri alma, miktar sayacı, arşivleme testleri)
- `dart format .`: Tüm dosyalar hatasız biçimlendirildi.
- `flutter analyze`: **0 issue** (sıfır hata, sıfır uyarı).
- `flutter test`: **16/16 test başarılı**.
- `flutter run -d macos`: Uygulama macOS masaüstü platformunda derlendi, başarıyla açıldı ve sync sağlandı.
- `README.md` kurulum, çalıştırma, hazır demo hesap ve demo kısıtlarıyla yazıldı.

---

### [x] Düzeltme: Kimlik (Giriş, Kayıt, Şifremi Unuttum) Ekranları ve Akış Hatalarının Çözümü
- **Sorun:** Açılışta kalıcı depoda (`habit_tracker_store_v1`) önceden oturum açmış kullanıcı kimliği (`activeUserId: user_demo_default`) kaldığı için `BootstrapScreen` doğrudan `MainShell`'e yönlendiriyor ve kullanıcı Giriş/Kayıt/Şifre ekranlarını göremiyordu.
- **Çözüm 1 (Kalıcı Oturum Sıfırlama):** Yerel depodaki `activeUserId` null değerine sıfırlandı; uygulama açılışında doğrudan hazır demo kimlik bilgileriyle `LoginScreen` açılması sağlandı.
- **Çözüm 2 (Giriş Sonrası Veri Yükleme):** `LoginScreen._handleLogin` içinde giriş başarılı olduktan sonra `HabitController.loadUserData`, `NotificationController.loadReminders` ve `checkAndGenerate` fonksiyonları çağrılarak oturum açan kullanıcının alışkanlık ve hatırlatma verilerinin eksiksiz yüklenmesi sağlandı.
- **Çözüm 3 (Şifre Sıfırlama Başarı Mesajı):** `auth_controller.dart` dosyasındaki `resetPassword` metodunda `resetForgotState()` çağrısı `_successMessage` atamasından önceye alındı; böylece sıfırlama sonrası Giriş ekranına dönüldüğünde yeşil başarı bilgi kartı görüntülenebilir hale getirildi.
- **Çözüm 4 (Güvenli Gezinme):** `RegisterScreen`, `ForgotPasswordScreen` ve `ResetPasswordScreen` ekranlarında `canPop()` kontrolüyle geri dönüşler güvenceye alındı; doğrudan rota açılışlarında kullanıcıların takılması engellendi. `ForgotPasswordScreen` içinde demo koda dokunarak tek tıkla kopyalama özelliği eklendi.
- **Çözüm 5 (Adlandırılmış Rotalar):** `app.dart` içerisine `/`, `/login`, `/register`, `/forgot-password`, `/reset-password`, `/main` rotaları ve `onGenerateRoute` eklendi.
- **Çözüm 6 (Testler):** `test/auth_flow_test.dart` yazılarak tüm kimlik akışları ve arayüz etkileşimleri 6 yeni testle (toplam 16/16 test) doğrulandı.
