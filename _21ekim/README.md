# Alışkanlık Takibi (Habit Tracker)

Flutter ve Dart ile geliştirilmiş; Türkçe arayüzlü, soft pastel tonlarda Material 3 temasına sahip, tamamen çevrimdışı ve yerel verilerle çalışan modern bir alışkanlık takibi mobil uygulamasıdır.

---

## 🌟 Temel Özellikler

- **Soft Renk Paleti ve Material 3 Tasarım:** Göz yormayan pastel adaçayı yeşili, arduvaz mavisi ve yumuşak vurgu renkleri.
- **3 Sekmeli Sabit Alt Menü (`MainShell`):**
  - **Ana Sayfa:** Cihaz saatine göre Türkçe selamlama (örn. "Günaydın, Hasbiyenur"), günün tarihi, günlük tamamlama özet çubuğu, "Bugün Yapılacaklar" ve "Yapılanlar" bölümleri.
  - **Görevler:** Tüm aktif alışkanlıkların listesi, kart detayları (tekrar sıklığı, başlangıç tarihi, sayaç türü, aktif streak), form ile görev ekleme/düzenleme, seçimli ve onaylı mantıksal kaldırma.
  - **Profil:** Kullanıcı bilgileri, aktif alışkanlık serileri, özet istatistikler, tüm zamanların en yüksek rekoru, istatistik/rozet sayfasına erişim ve güvenli çıkış yapma.
- **Alışkanlık Ekleme ve Düzenleme:**
  - Tekrar aralığı ("Kaç günde bir?": 1-365 gün).
  - Başlangıç tarihi seçimi ve sonraki 3 planlı takvim günü önizlemesi.
  - İki farklı takip türü: **Tik Atma** (tek tıkla tamamlama/geri alma) ve **Bar Doldurma** (hedef miktar, birim ve artış adımıyla miktar sayacı).
  - Günlük hedef saati ve uygulama içi hatırlatma ayarı.
  - Zengin simge ve soft vurgu rengi paleti.
  - Plan değişikliklerinde geçmiş kayıtları koruyan sürümleme (`effectiveFromDateKey`).
- **Gelişmiş Seri (Streak) ve Rozet Hesaplamaları:**
  - Seri yalnızca planlanan günlerin kesintisiz tamamlanmasına göre hesaplanır. Ara dinlenme günleri (örn. 2 günde bir olan görevde boş günler) seriyi bozmaz!
  - Bugün henüz tamamlanmadıysa gün kapanana kadar seri bozulmaz; gün atlandığında seri sıfırlanır.
  - 10 (Bronz Başlangıç), 25 (Gümüş Devamlılık) ve 50 (Altın İstikrar) planlı gün serileri için otomatik rozet kazanımı.
  - Aynı gün geri alma işlemi yapılırsa geçersizleşen rozetler geri alınır, eski meşru rozetler korunur.
- **Takvim ve İstatistikler:**
  - Pazartesi başlayan aylık takvim ızgarası, alışkanlık bazlı veya genel filtreleme, seçilen günün detaylı görev dökümü.
  - Haftalık ve aylık başarı yüzdeleri, 7 günlük başarı grafiği.
- **Uygulama İçi Hatırlatmalar:**
  - Hedef saatinden 1 saat önce uygulama içinde hatırlatma bildirimi oluşturulur.
  - Ana sayfadaki bildirim simgesinden modal pencere ile okunabilir ve yönetilebilir.

---

## 🚀 Kurulum ve Çalıştırma

### Gereksinimler
- Flutter SDK 3.47+ / Dart 3.13+
- macOS, iOS Simülatörü, Android Emülatörü veya Chrome

### Kurulum
Proje kök dizininde bağımlılıkları yükleyin:
```bash
flutter pub get
```

### Uygulamayı Çalıştırma
Bağlı cihazları listelemek için:
```bash
flutter devices
```

İstediğiniz hedefte çalıştırmak için:
```bash
# macOS Masaüstü
flutter run -d macos

# Chrome (Web)
flutter run -d chrome

# iOS Simülatörü
flutter run -d apple_ios_simulator
```

---

## 👤 Hazır Demo Hesap

Uygulama ilk kez açıldığında yerel bir demo tohumu otomatik olarak yüklenir:

- **E-posta:** `demo@aliskanlik.com`
- **Şifre:** `demo1234`
- **Kullanıcı:** Hasbiyenur Kaya

*Not: "Kayıt Ol" ekranından dilediğiniz ad, soyad ve e-posta ile yeni ve tertemiz bir yerel hesap da oluşturabilirsiniz.*

---

## 🔒 Güvenlik ve Demo Sınırları

1. **Backend / Servis Bağımsızlığı:** Uygulamada Firebase, Supabase, uzak sunucu veya harici kimlik doğrulama servisi bulunmaz. Tüm veriler `SharedPreferencesAsync` kullanılarak `StoreDocument` formatında cihazda saklanır.
2. **Açık Metin Şifre Saklanmaz:** Parolalar PBKDF2-HMAC-SHA256 ve 16 baytlık kriptografik rastgele tuz (salt) kullanılarak türetilir. Parolalar kaynak koda, JSON verilerine veya loglara asla açık metin olarak yazılmaz.
3. **Demo Şifre Kurtarma:** Şifremi unuttum akışında gerçek e-posta gönderimi yapılmaz. 6 haneli deneme kodu ekrandaki demo kartında gösterilir. Kod 5 dakika geçerlidir ve doğrulandıktan sonra 10 dakikalık tek kullanımlık yeni şifre oluşturma yetkisi açılır.
4. **Uygulama İçi Bildirimler:** Hatırlatmalar sadece uygulama içi arayüzde çalışır. Uygulama tamamen kapalıyken işletim sistemi bildirimi gönderme iddiasında bulunulmaz.

---

## 🧪 Testler ve Kod Doğrulama

Tüm testleri ve kod analizi kontrollerini çalıştırmak için:

```bash
# Kod biçimlendirme
dart format .

# Statik analiz (0 hata / 0 uyarı)
flutter analyze

# Birim ve akış testleri (10/10 test başarılı)
flutter test
```
