# Araç Kiralama Mobil Uygulaması — Geliştirme ve Takip Raporu (`yapilanlar.md`)

Bu doküman, `arac_kiralama.md` dosyasında yer alan tüm gereksinimlerin adım adım nasıl karşılandığını, geliştirilen mimariyi, veri modellerini, ekranları ve yapılan doğrulamaları açıklamaktadır.

---

## 1. Proje Özeti ve Kapsam

- **Teknoloji:** Flutter 3.47+ / Dart 3.13+, Material Design 3 (`useMaterial3: true`).
- **Mimari:** Ekstra paket yükü olmadan, temiz ve performanslı Flutter yerleşik durum yönetimi (`ChangeNotifier` + `InheritedNotifier<AppState>`).
- **Veri / Ağ:** Backend, veritabanı, Firebase, harici API ve bildirim sistemleri kullanılmamış; tüm veriler uygulama belleğinde (in-memory) yönetilmektedir.
- **Hedef Platform:** iOS Simülatörü ve Android / Desktop ortamlarında hatasız çalışma.

---

## 2. Klasör ve Dosya Mimarisi

Uygulama, `arac_kiralama.md` kılavuzunda belirtilen klasör yapısına %100 sadık kalınarak oluşturulmuştur:

```
lib/
├── main.dart                       # Uygulama başlangıç noktası, AppState başlatma
├── app.dart                        # MaterialApp, tema, Rento başlığı ve açılış rotası
├── models/
│   ├── vehicle.dart                # Vehicle (Araç) veri modeli
│   └── booking.dart                # Booking (Rezervasyon) veri modeli
├── data/
│   └── sample_data.dart            # Başlangıç 8 adet örnek araç ve demo rezervasyonlar
├── state/
│   └── app_state.dart              # Uygulama durum yönetimi (AppState & AppStateScope)
├── screens/
│   ├── splash_screen.dart          # Rento logolu animasyonlu açılış ekranı (Splash Screen)
│   ├── main_shell.dart             # Sabit alt NavigationBar (4 Sekme) & IndexedStack
│   ├── home_screen.dart            # Sol üst köşede Rento logosu ve ismi, araç listesi
│   ├── filter_screen.dart          # Çoklu kriterli filtreleme & sonuç listesi
│   ├── add_vehicle_screen.dart     # Zorunlu alanlar ve validasyonlu araç ekleme formu
│   ├── profile_screen.dart         # Demo profil, tema değiştirici ve alt menü yönlendirmeleri
│   ├── favorites_screen.dart       # Favoriye alınan araçların listesi
│   ├── my_vehicles_screen.dart     # Kullanıcının eklediği araçlar ve güvenli silme
│   ├── my_rentals_screen.dart      # Kullanıcının kiraladığı araçlar ve iptal akışı
│   ├── my_vehicle_bookings_screen.dart # Kullanıcının araçlarına yapılan rezervasyonlar
│   └── reservation_screen.dart     # Bütçeme göre / Süreye göre kiralama ve çakışma kontrolü
├── widgets/
│   ├── rento_logo.dart             # Rento özel vektörel/dinamik marka amblemi ve tipografisi
│   ├── vehicle_card.dart           # Zengin görsel, rozetler, favorileme ve rezervasyon butonu
│   ├── empty_state.dart            # Listeler boş olduğunda gösterilen modern boş durum widget'ı
│   └── common_text_field.dart      # Formlar için standartlaştırılmış giriş alanı
└── theme/
    └── app_theme.dart              # Açık/Koyu Material 3 temaları ve tarih/saat/para formatlayıcılar
```

---

## 3. Veri Modelleri ve Bellek Durumu (`AppState`)

### Modeller
- **`Vehicle`**: `id`, `ownerId`, `ownerFirstName`, `ownerLastName`, `type`, `brand`, `model`, `color`, `location`, `hourlyPrice`, `kilometers`.
- **`Booking`**: `id`, `vehicleId`, `vehicleTitleSnapshot`, `ownerId`, `renterId`, `renterFirstName`, `renterLastName`, `startAt`, `endAt`, `durationHours`, `hourlyPriceSnapshot`, `totalPrice`, `isCancelled`.

### Durum Yönetimi (`AppState`)
- **Tekil Sorumluluk:** Tek bir `AppState extends ChangeNotifier` sınıfı ile tüm listeler (`vehicles`, `bookings`, `favoriteVehicleIds`) tutulur.
- **`AppStateScope`:** Flutter'ın yerel `InheritedNotifier` yapısı kullanılarak, alt bileşenlerin `AppStateScope.of(context)` ile duruma erişmesi ve değişikliklerde otomatik yeniden çizilmesi sağlandı.
- **Ayrıştırma Kuralları:**
  - *Kiralanan Araçlarım:* `renterId == currentUserId`
  - *Araçlarımın Kiralamaları:* `ownerId == currentUserId && renterId != currentUserId`
  - *Kendi Aracını Kiralama Engeli:* `ownerId == currentUserId` olan araca rezervasyon yapılamaz.

---

## 4. Ekranlar ve Kullanıcı Akışları

### 1. Ana Sayfa (`HomeScreen`)
- Müsait araç sayısı ve aktif kiralama sayısını gösteren modern karşılama banner'ı.
- Kategori filtreleme çipleri (Tümü, Sedan, SUV, Elektrikli, Hatchback, Spor, Ticari).
- Her araç kartında: Araç türü ikonu, renk rozeti, konum, kilometre, saatlik ücret, favori kalp butonu ve "Rezervasyon Yap" butonu.
- Favorileme anında Profil > Favoriler ekranına yansır.
- Kullanıcının kendi eklediği araçlarda "Aracınız" rozeti gösterilir ve kiralama butonu bilgilendirici olarak pasife alınır.

### 2. Filtreleme (`FilterScreen`)
- Alanlar: Araç türü (Dropdown), marka, model, konum, en yüksek saatlik fiyat, renk.
- **VE (AND) Mantığı:** Birden fazla filtre aynı anda çalışır. Boş bırakılan alanlar tüm araçları kapsar.
- "Filtrele" ve "Temizle" butonları.
- Sonuçlar aynı sekmede "Filtrelenen Araçlar" başlığı altında listelenir.
- Eşleşen araç olmadığında açıklayıcı `EmptyState` mesajı gösterilir.

### 3. Araç Ekle (`AddVehicleScreen`)
- Form validasyonları:
  - Ad ve soyad boşluklardan ibaret olamaz.
  - Tür, marka, model, renk, konum boş bırakılamaz.
  - Saatlik fiyat > 0 kontrolü.
  - Kilometre >= 0 kontrolü ve sadece rakam kabulü.
- Kaydet'e basıldığında araç listeye en başa eklenir, demo kullanıcı kimliği (`currentUserId`) atanır, başarı diyaloğu gösterilir ve form temizlenir.
- Eklenen araç hemen Ana Sayfa ve Profil > Eklenen Araçlar ekranında görünür.

### 4. Profil (`ProfileScreen`)
- Demo kullanıcı avatarı ve ad-soyad ("Ahmet Yılmaz", `user_demo_1`).
- **Açık/Koyu Tema Desteği:** Switch ile tüm uygulama genelinde anında tema geçişi.
- Butonlar ve Sayaç Rozetleri:
  - Favoriler
  - Eklenen Araçlar
  - Kiralanan Araçlarım
  - Araçlarımın Kiralamaları
- Sayfa altında kiralama kavramlarının farkını anlatan açıklama kartı.

### 5. Favoriler (`FavoritesScreen`)
- Kullanıcının kalp ile favorilediği araçlar listelenir.
- Kalbe tekrar dokunarak favoriden çıkarma ve doğrudan rezervasyona gitme mümkündür.

### 6. Eklenen Araçlar (`MyVehiclesScreen`)
- Kullanıcının eklediği araçlar listelenir.
- **Güvenli Silme Kuralı:** Rezervasyonu bulunan araçlar silinemez. Kullanıcıya "Bu araca ait rezervasyon kayıtları bulunduğu için silinemez" uyarısı gösterilir. Rezervasyonu olmayan araçlar için onay diyaloğu sonrasında silme gerçekleştirilir ve araç favorilerden de temizlenir.

### 7. Kiralanan Araçlarım (`MyRentalsScreen`)
- Kullanıcının kiraladığı araçların listesi.
- Başlangıç ve bitiş tarih-saatleri 24 saat biçiminde (`21.10.2026, 14:00`), toplam süre, saatlik fiyat, toplam tutar ve durum rozeti (Aktif, Tamamlandı, İptal Edildi) gösterilir.
- İsteğe bağlı rezervasyon iptali: Onay diyaloğunun ardından rezervasyon iptal edilir ve artık zaman çakışması hesabına dahil edilmez.

### 8. Araçlarımın Kiralamaları (`MyVehicleBookingsScreen`)
- Kullanıcının sahip olduğu araçlara başkalarının yaptığı rezervasyonlar listelenir.
- Demo başlangıç verisinde Zeynep Akın'ın kullanıcının aracına yaptığı örnek bir rezervasyon yer alır.
- Kiralayan müşteri adı, tarih/saat aralıkları ve toplam gelir gösterilir.

### 9. Rezervasyon Yap (`ReservationScreen`)
- Seçilen aracın özeti ve saatlik fiyatı üstte yer alır.
- Ad, Soyad, Başlangıç Tarihi ve Saati (24 saat biçimi) seçimi. Başlangıç zamanı geçmişte olamaz.
- **İki Seçenekli SegmentedButton:**
  - **Bütçeme Göre:** Bütçe girilir. `floor(bütçe / saatlikÜcret)` ile tam saat hesaplanır. Minimum 1 saatlik kiralama tutarı gereklidir. Harcanan tutar ve kalan bütçe canlı olarak hesaplanır.
  - **Süreye Göre:** Saat cinsinden tam sayı girilir. `saat × saatlikÜcret` ile toplam tutar hesaplanır.
- **Zaman Çakışması Kontrolü:**
  - Formül: `yeniBaşlangıç < mevcutBitiş && yeniBitiş > mevcutBaşlangıç`
  - Çakışma varsa rezervasyon engellenir ve kullanıcıya net hata uyarısı verilir.
- **Özet Onay Diyaloğu:** Rezervasyonu Onayla butonuna basıldığında tüm detaylar (araç, kiralayan, başlangıç, bitiş, toplam saat, ödenecek tutar) onay için sunulur. Onaylandığında rezervasyon kaydedilir ve Kiralanan Araçlarım ekranına eklenir.

---

## 5. Doğrulama ve Test Adımları

1. **Statik Kod Analizi (`flutter analyze`):**
   - Sonuç: `No issues found! (ran in 3.1s)`
   - 0 hata, 0 uyarı, 0 lint sorunu.

2. **Birim / Widget Testleri (`flutter test`):**
   - Sonuç: `All tests passed!`
   - Temel duman ve sekme render testleri başarıyla tamamlandı.

3. **Derleme Doğrulaması (`flutter build ios`):**
   - iOS Simülatör derlemesi başarıyla test edildi.
