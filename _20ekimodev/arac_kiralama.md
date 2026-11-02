Flutter Araç Kiralama Uygulaması — Proje Gereksinimleri
1. Amaç ve kapsam
    Flutter ile basit, çalışır, yalnızca frontend bir araç kiralama mobil uygulaması geliştir. Backend, API, Firebase, veritabanı, kimlik doğrulama servisi ve bildirim sistemi kullanma. Proje eğitim amaçlı bir prototiptir; gerçek ödeme veya gerçek araç kiralama yapılmaz.

2. Zorunlu ders kazanımları
    Temel Flutter UI elemanları, butonlar ve etkileşimler (Scaffold, Card, ListView, ElevatedButton, IconButton, Text, TextField, DropdownButtonFormField vb.).
    Form yönetimi, Form, TextFormField, GlobalKey<FormState> ve validasyonlar; kullanıcı giriş bilgileri yalnızca form üzerinden alınır, gerçek giriş/üyelik sistemi kurulmaz.
    Material Design 3 ve açık/koyu tema (ThemeData(useMaterial3: true), ThemeMode).
    Diyaloglar ve bottom sheet (AlertDialog, showDialog, showModalBottomSheet) ile onay, hata ve seçim akışları.
    Bildirimler hariçtir: push, yerel bildirim, bildirim izni veya bildirim paketi ekleme.
3. Teknik sınırlar
    Flutter/Dart, mümkün olduğunca Flutter'ın yerleşik widget'ları.
    Backend ve veritabanı yok. Ağ isteği, sunucu, bulut depolama yok.
    Veriler ChangeNotifier + Provider gibi ek paket gerektirmeyen ChangeNotifier/InheritedNotifier veya sade ValueNotifier ile uygulama belleğinde tutulabilir. Basitlik için tek bir AppState extends ChangeNotifier kullan; AnimatedBuilder/ListenableBuilder ile ekranları güncelle. Gereksiz state management paketleri ekleme.
    Uygulama ilk açıldığında 6–8 örnek araç belleğe yüklensin. Yeni araçlar, favoriler ve rezervasyonlar uygulama açıkken diğer ekranlara anında yansısın. Uygulama yeniden başlatıldığında verilerin sıfırlanması kabul edilir; kalıcı saklama zorunlu değildir.
    Gerçek giriş ekranı ve kullanıcı hesabı yok. Profilde demo kullanıcı adı-soyadı gösterilir. Rezervasyonda ad-soyad girilir.
    Para birimi TL, dil Türkçe, tarih/saat 24 saat biçimi.
    Platform hedefi öncelikle iOS simülatörü; Android'de de çalışabilmeli.
4. Alt navigasyon
    Ekranın altında her zaman sabit NavigationBar (Material 3) bulunur. Dört sekme:

    Ana Sayfa
    Filtreleme
    Araç Ekle
    Profil
    Alt bar sekme değiştirirken sabit kalmalı. Profil alt sayfalarına ve rezervasyon ekranına geçildiğinde uygun Navigator kullan; kullanıcı geri dönebilmeli.

5. Ekranlar ve davranışlar
    ## Ana Sayfa
        Araç kartları: görsel/yer tutucu ikon, tür, marka, model, renk, konum, km, saatlik ücret (TL/saat) ve uygunluk.
        Her kartın altında Favorile (kalp ikonu, aç/kapat) ve Rezervasyon Yap butonları.
        Favorileme anında profil > Favoriler'e yansır.
        Rezervasyon Yap seçilen aracın bilgileriyle rezervasyon ekranını açar.
        Araç Ekle bölümünden eklenen araçlar anında listede görünür.
        Rezervasyon sırasında çakışan zaman aralığında müsait olmayan araç için uyarı göster.
    ## Filtreleme
        Alanlar: araç türü, marka, model, konum, en yüksek saatlik fiyat, renk.
        Boş alanlar tüm değerleri kapsar; birden fazla aktif filtre VE (AND) mantığıyla birlikte uygulanır.
        Filtrele ve Temizle butonları.
        Aynı sekmede Filtrelenen Araçlar başlığı altında sonuç listesi gösterilir.
        Sonuç kartlarında Favorile ve Rezervasyon Yap çalışır.
        Sonuç yoksa açıklayıcı boş durum mesajı göster.
    ## Araç Ekle
        Zorunlu form alanları: araç sahibinin adı, soyadı, tür, marka, model, renk, saatlik fiyat (TL), kilometre (km).
        Filtrelemede konum kullanılacağı için ayrıca konum alanı ekle.
        Validasyon: boş alan yok; fiyat > 0; km >= 0; sayısal alanlarda geçersiz karakter yok; ad-soyad yalnızca boşluklardan oluşamaz.
        Kaydet basıldığında araç bellekteki listeye eklenir, sahibine demo kullanıcı kimliği atanır, başarı SnackBar/diyalog gösterilir, form temizlenir.
        Kaydedilen araç Ana Sayfa ve Profil > Eklenen Araçlar ekranında görünür.
        Görsel yükleme zorunlu değildir; araç türüne göre yerel ikon/renkli görsel yer tutucu kullan.
    ## Profil
        Demo profil görseli/ikonu ve ad-soyad.
        Butonlar: Favoriler, Eklenen Araçlar, Kiralanan Araçlarım, Araçlarımın Kiralamaları.
        Açık/Koyu tema değiştirme kontrolü.
        Profildeki başlıklar birbirinden farklı anlam taşır:
        Kiralanan Araçlarım: benim başkasından rezervasyon yapıp kiraladığım araçlar.
        Araçlarımın Kiralamaları: sahibi olduğum araçlara başkalarının yaptığı rezervasyonlar.
    ## Favoriler
        Kalp ile işaretlenen araçlar listelenir.
        Favoriden çıkarma ve rezervasyon ekranına gitme mümkündür.
    ## Eklenen Araçlar
        Demo kullanıcı tarafından eklenen araçlar listelenir.
        Araç silme butonu ve silmeden önce AlertDialog ile onay bulunur.
        Silinen aracı favorilerden de çıkar; ilgili rezervasyonları silmek yerine geçmiş kayıtlarında araç adıyla koru veya silmeyi mevcut rezervasyon varsa engelle. Tercih edilen basit kural: rezervasyonu bulunan araç silinemez, kullanıcıya açıklama göster.
    ## Kiralanan Araçlarım
        Kullanıcının yaptığı rezervasyonlar listelenir.
        Araç adı, başlangıç/bitiş tarihi ve saati, toplam süre, saatlik fiyat, toplam ücret ve rezervasyon durumu görünür.
        İsteğe bağlı rezervasyon iptali: onay diyaloğundan sonra iptal edildi durumuna geçir; iptal edilen rezervasyon artık zaman çakışması hesabına katılmaz.
    ## Araçlarımın Kiralamaları
        Kullanıcının eklediği araçlar için başkalarının yaptığı rezervasyonlar listelenir.
        Araç, kiralayan kişinin adı-soyadı, başlangıç/bitiş, toplam süre ve tutar görünür.
        Backend olmadığı için demo veri kullan: uygulama başlangıcında kullanıcıya ait örnek bir araç ve bu araca ait başka bir demo kiracı rezervasyonu bulunabilir. Aynı demo kullanıcının kendi aracını kiralamasına izin verme.
        Bu ekrandaki kayıtlar ownerId == currentUserId ve renterId != currentUserId şartıyla ayrıştırılır.
    ## Rezervasyon Yap
        Seçilen aracın özeti ve saatlik fiyatı üstte gösterilir.
        Zorunlu ad, soyad ve başlangıç tarihi-saati alanları.
        İki seçenekli SegmentedButton veya Radio ile kiralama hesaplama modu:
            Bütçeme Göre: Kullanıcı bütçe (TL) girer; saatlik ücret üzerinden kiralayabileceği tam saat sayısı floor(bütçe / saatlikÜcret) ile hesaplanır. En az 1 saat gereklidir. Bitiş tarihi-saati başlangıca hesaplanan saat eklenerek gösterilir. Harcanacak tutar = saat sayısı × saatlik ücret; kalan bütçe ayrıca gösterilebilir.
            Süreye Göre: Kullanıcı kiralama süresini tam saat cinsinden girer; toplam tutar = saat sayısı × saatlik ücret. Bitiş tarihi-saati hesaplanır.
        Modlar arasında geçişte önceki moda ait hesaplamalar yanlışlıkla kullanılmamalıdır.
        Başlangıç geçmişte olamaz; saat sayısı pozitif tam sayı; bütçe en az bir saatlik ücret kadar olmalıdır.
        Aynı araç için aktif rezervasyonlarla çakışma kontrolü: yeniBaşlangıç < mevcutBitiş && yeniBitiş > mevcutBaşlangıç. Çakışırsa rezervasyon oluşturma.
        Rezervasyonu Onayla öncesi özet AlertDialog göster; onaydan sonra rezervasyon belleğe eklenir ve Profil > Kiralanan Araçlarım bölümünde görünür.
        Kullanıcının kendi eklediği araca rezervasyon yapmasını engelle.
        Gerçek ödeme veya ödeme ekranı yoktur.
6. Veri modelleri
Önerilen modeller:

```dart
class Vehicle {
  final String id;
  final String ownerId;
  final String ownerFirstName;
  final String ownerLastName;
  final String type;
  final String brand;
  final String model;
  final String color;
  final String location;
  final double hourlyPrice;
  final int kilometers;
}

class Booking {
  final String id;
  final String vehicleId;
  final String vehicleTitleSnapshot;
  final String ownerId;
  final String renterId;
  final String renterFirstName;
  final String renterLastName;
  final DateTime startAt;
  final DateTime endAt;
  final int durationHours;
  final double hourlyPriceSnapshot;
  final double totalPrice;
  final bool isCancelled;
}
```
AppState: vehicles, bookings, favoriteVehicleIds, currentUserId, themeMode; araç ekleme/silme, favori değişimi, filtreleme, rezervasyon ekleme/iptal, çakışma kontrolü ve tema değiştirme metotları.

7. Önerilen klasör yapısı
lib/
  main.dart
  app.dart
  models/
    vehicle.dart
    booking.dart
  data/
    sample_data.dart
  state/
    app_state.dart
  screens/
    main_shell.dart
    home_screen.dart
    filter_screen.dart
    add_vehicle_screen.dart
    profile_screen.dart
    favorites_screen.dart
    my_vehicles_screen.dart
    my_rentals_screen.dart
    my_vehicle_bookings_screen.dart
    reservation_screen.dart
  widgets/
    vehicle_card.dart
    empty_state.dart
    common_text_field.dart
  theme/
    app_theme.dart

    Basitlik için gereksiz repository, service, API, Firebase, authentication, database, notification ve generated-code klasörleri oluşturma.

8. Kullanıcı akışları ve kabul kriterleri
    Uygulama hatasız açılır, alt menüde dört sekme vardır.
    Başlangıçta örnek araçlar görünür; favorileme Favoriler'e yansır.
    Birden fazla filtre birlikte çalışır; temizleme tüm filtreleri sıfırlar.
    Geçerli form ile eklenen araç Ana Sayfa ve Eklenen Araçlar'da anında görünür.
    Boş/yanlış form kaydedilemez, kullanıcıya Türkçe hata mesajı verilir.
    Bütçe 550 TL, saatlik ücret 200 TL ise 2 saat, 400 TL harcama, 150 TL kalan bütçe gösterilir.
    Süre 3 saat, saatlik ücret 200 TL ise 600 TL gösterilir.
    Rezervasyon onaylanınca Kiralanan Araçlarım'a düşer; tarih ve saatler görünür.
    Aynı araca çakışan iki aktif rezervasyon yapılamaz.
    Başka demo kiracının benim aracıma yaptığı rezervasyon Araçlarımın Kiralamaları'nda görünür; benim yaptığım rezervasyon orada görünmez.
    Dark/Light tema tüm ekranlara uygulanır.
    Diyaloglar, formlar ve butonlar çalışır; bildirim özelliği bulunmaz.
    iOS simülatöründe ve Android'de derlenebilir; gerçek internet bağlantısı gerekmez.
9. AI kod üretim talimatı
    Bu belgeye göre Flutter uygulamasını dosya dosya eksiksiz kodlayıp çalışır hale getir. Önce gerekli klasörleri oluştur, sonra modelleri, örnek verileri, AppState'i, tema ve ekranları geliştir. Sade, anlaşılır, null-safe Dart kodu kullan. pubspec.yaml bağımlılıklarını minimum tut. Material 3 kullan. Yalnızca frontend üret; backend, veritabanı, Firebase, API, giriş servisi ve bildirim ekleme. Ekranları yalnızca çizmekle kalma; tüm butonlar, formlar, filtreler, favoriler ve rezervasyon hesaplamaları gerçek şekilde uygulama belleğinde çalışsın. Kodları oluşturduktan sonra flutter pub get ve flutter analyze çalıştır; hataları düzelt. Mevcut Flutter proje iskeletini ve platform dosyalarını gereksiz yere değiştirme. Performans için ağır görsel paketleri veya gereksiz bağımlılıklar kullanma.