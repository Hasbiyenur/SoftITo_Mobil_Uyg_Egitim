# Roomio — Proje Mimarisi, Dosya Yapısı ve Kod Dokümantasyonu

Bu belge, **Roomio (Ev & Oda Arkadaşı Bulma Uygulaması)** için geliştirilen tüm mimari katmanları, dosyaları, sınıfları, fonksiyonları ve iş mantığı kurallarını detaylı olarak açıklamaktadır.

Proje, **Clean Architecture** (Temiz Mimari) ilkeleri gözetilerek; **BLoC (Business Logic Component)** durum yönetimi, **Hive** yerel veri saklama mekanizması ve **Material Design 3** tasarım standartlarına tam uyumlu olarak inşa edilmiştir.

---

## 📑 İçindekiler
1. [Proje Mimarisi ve Dizin Ağacı](#1-proje-mimarisi-ve-dizin-ağacı)
2. [Yapılandırma ve Örnek Veri Dosyaları](#2-yapılandırma-ve-örnek-veri-dosyaları)
3. [Çekirdek Katman (Core Layer)](#3-çekirdek-katman-core-layer)
4. [Domain Katmanı (İş Mantığı ve Sözleşmeler)](#4-domain-katmanı-iş-mantığı-ve-sözleşmeler)
5. [Data Katmanı (Veri Modelleri ve Yerel Depolama)](#5-data-katmanı-veri-modelleri-ve-yerel-depolama)
6. [Presentation Katmanı — Durum Yönetimi (BLoC / Cubit)](#6-presentation-katmanı--durum-yönetimi-bloc--cubit)
7. [Presentation Katmanı — Ortak Bileşenler (Widgets)](#7-presentation-katmanı--ortak-bileşenler-widgets)
8. [Presentation Katmanı — Ekranlar (Screens)](#8-presentation-katmanı--ekranlar-screens)
9. [Uygulama Giriş Noktası (main.dart)](#9-uygulama-giriş-noktası-maindart)
10. [Test Katmanı](#10-test-katmanı)

---

## 1. Proje Mimarisi ve Dizin Ağacı

Clean Architecture gereği iş kuralları kullanıcı arayüzünden (UI) ve dış bağımlılıklardan tamamen izole edilmiştir:

```text
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   └── app_theme.dart
│   └── utils/
│       └── price_calculator.dart
├── domain/
│   ├── entities/
│   │   ├── user_entity.dart
│   │   ├── listing_entity.dart
│   │   ├── rental_entity.dart
│   │   └── chat_entity.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── listing_repository.dart
│   │   ├── rental_repository.dart
│   │   └── chat_repository.dart
│   └── usecases/
│       ├── auth_usecases.dart
│       ├── listing_usecases.dart
│       ├── rental_usecases.dart
│       └── chat_usecases.dart
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── listing_model.dart
│   │   ├── rental_model.dart
│   │   └── chat_model.dart
│   └── repositories/
│       ├── auth_repository_impl.dart
│       ├── listing_repository_impl.dart
│       ├── rental_repository_impl.dart
│       └── chat_repository_impl.dart
├── presentation/
│   ├── bloc/
│   │   ├── theme/theme_cubit.dart
│   │   ├── auth/ (auth_bloc.dart, auth_event.dart, auth_state.dart)
│   │   ├── listing/ (listing_bloc.dart, listing_event.dart, listing_state.dart)
│   │   ├── rental/ (rental_bloc.dart, rental_event.dart, rental_state.dart)
│   │   └── chat/ (chat_bloc.dart, chat_event.dart, chat_state.dart)
│   ├── widgets/
│   │   ├── app_logo.dart
│   │   ├── campaign_carousel.dart
│   │   ├── listing_card.dart
│   │   ├── listing_filter_bottom_sheet.dart
│   │   └── rental_booking_bottom_sheet.dart
│   └── screen/
│       ├── splash/splash_screen.dart
│       ├── onboarding/onboarding_screen.dart
│       ├── auth/login_screen.dart & register_screen.dart
│       ├── main_navigation_screen.dart
│       ├── home/home_screen.dart
│       ├── detail/listing_detail_screen.dart
│       ├── favorites/favorites_screen.dart
│       ├── rentals/active_rentals_screen.dart
│       ├── create_listing/create_listing_screen.dart
│       ├── chat/chat_list_screen.dart & chat_conversation_screen.dart
│       └── profile/profile_screen.dart
└── main.dart
```

---

## 2. Yapılandırma ve Örnek Veri Dosyaları

### 📄 [pubspec.yaml](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/pubspec.yaml)
* **Amaç:** Proje bağımlılıklarını ve asset dizinlerini yönetir.
* **Kullanılan Temel Paketler:**
  * `flutter_bloc` & `bloc`: UI ve iş mantığını ayırmak için durum yönetimi.
  * `hive` & `hive_flutter`: NoSQL tabanlı, hızlı yerel anahtar-değer veri saklama motoru.
  * `intl`: Türkçe tarih (`DateFormat`) ve para birimi (`NumberFormat`) biçimlendirmeleri.
  * `uuid`: Eşsiz model ID'leri oluşturma.
* **Tanımlı Varlıklar:** `assets/` klasörü aktif edilmiştir.

### 📄 [assets/roommates.json](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/assets/roommates.json)
* **Amaç:** Uygulama ilk açıldığında sunucu gerekmeksizin keşfet sayfasını besleyen örnek ev ve oda ilanları veritabanı.
* **İçerik:** İstanbul (Kadıköy, Beşiktaş, Şişli), Ankara (Çankaya) ve İzmir (Karşıyaka, Bornova) gibi büyükşehirlerden; ev sahibi bilgileri, bütçeler, alışkanlıklar ve fotoğraflar içeren 6 adet zengin örnek kayıt.

---

## 3. Çekirdek Katman (Core Layer)

### 📄 [lib/core/theme/app_colors.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/core/theme/app_colors.dart)
* **Amaç:** `design.md` belgesinde tanımlanan renk paletini statik sabitler olarak merkezileştirir.
* **Sınıf:** `AppColors`
  * `primaryLight` (`#E06A3B`): Açık tema ana turuncusu.
  * `secondaryLight` (`#F39C12`): İkincil turuncu/amber tonu.
  * `backgroundLight` (`#FCF9F5`): Yumuşak bej arka plan.
  * `surfaceLight` (`#FFFFFF`): Kart ve yüzey rengi.
  * `textLightPrimary` (`#2C3E50`) & `textLightSecondary` (`#2C2C2C`): Okunabilir editoryal metin renkleri.
  * `primaryDark` (`#D35400`) & `secondaryDark` (`#A04000`): Koyu tema turuncuları.
  * `backgroundDark` (`#1A120B`) & `surfaceDark` (`#2D1F16`): Kontrastı koruyan sıcak koyu tonlar.
  * `success` (`#27AE60`), `warning` (`#F1AC0D`), `error` (`#B03A2E`): Durum renkleri.

### 📄 [lib/core/theme/app_theme.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/core/theme/app_theme.dart)
* **Amaç:** Material 3 uyumlu açık ve koyu tema yapılandırmalarını sunar.
* **Sınıf:** `AppTheme`
  * `ThemeData get lightTheme`: Açık tema için `ColorScheme`, `CardTheme` (16px radius), `ElevatedButtonTheme` (12px radius, 48px yükseklik), `InputDecorationTheme` ve `BottomSheetTheme` (20px üst radius).
  * `ThemeData get darkTheme`: Koyu tema için renk tersine çevirmeden öte, göz yormayan editoryal kontrast dengesine sahip koyu yapılandırma.

### 📄 [lib/core/utils/price_calculator.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/core/utils/price_calculator.dart)
* **Amaç:** `screen.md`'de belirtilen kiralama hesap formülünü ve indirim kurallarını hesaplar.
* **Sınıflar ve Fonksiyonlar:**
  * `PriceCalculationResult`: Taban fiyat (`basePrice`), indirim tutarı (`discountAmount`), nihai ödenecek tutar (`finalPrice`), indirim açıklaması (`discountReason`) ve gün sayısı (`days`) nesnesi.
  * `PriceCalculator.calculate(...)`:
    * Formül: `(monthlyRent / 30.0) * days`
    * Öğrenci İndirimi: `isStudent == true` ise otomatik **%20** indirim.
    * Kış Sezonu İndirimi: Öğrenci değilse; Kasım (11), Aralık (12) veya Ocak (1) aylarında İstanbul, Ankara veya İzmir'deki ilanlarda otomatik **%20** sezon indirimi.

---

## 4. Domain Katmanı (İş Mantığı ve Sözleşmeler)

Herhangi bir dış kütüphaneye veya Flutter UI bileşenine bağımlı olmayan saf Dart katmanıdır.

### 📄 [lib/domain/entities/user_entity.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/domain/entities/user_entity.dart)
* **Amaç:** Kullanıcı profilinin çekirdek veri tanımı.
* **Alanlar:** `id`, `name`, `email`, `phone`, `password`, `avatarUrl`, `age`, `gender`, `occupation`, `isStudent`, `smoking`, `hasPet`, `sleepSchedule`, `cleaningSensitivity`, `languages`, `city`, `district`, `preferredHouseType`, `savedAddresses`, `savedPaymentCard`.
* **Metot:** `copyWith(...)`: Değişmez (immutable) nesne kopyalama.

### 📄 [lib/domain/entities/listing_entity.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/domain/entities/listing_entity.dart)
* **Amaç:** Ev/oda ilanlarının çekirdek tanımı.
* **Sınıflar:**
  * `OwnerInfo`: İlan sahibinin adı, fotoğrafı, mesleği ve öğrenci durumu.
  * `ListingPreferences`: Sigara, evcil hayvan, uyku düzeni, temizlik hassasiyeti ve tercih edilen oda arkadaşı kriterleri.
  * `ListingEntity`: İlan başlığı, açıklaması, fotoğrafı, aylık kirası, konumu, kış indirimi uygunluğu ve kullanıcının oluşturup oluşturmadığı bilgisi (`isUserCreated`, `isActive`).

### 📄 [lib/domain/entities/rental_entity.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/domain/entities/rental_entity.dart)
* **Amaç:** Kiralama rezervasyonlarının çekirdek modeli.
* **Metot:** `int get remainingDays`: Çıkış tarihine (`checkOutDate`) kalan gün sayısını anlık olarak hesaplar.

### 📄 [lib/domain/entities/chat_entity.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/domain/entities/chat_entity.dart)
* **Amaç:** Mesajlaşma varlıkları.
* **Sınıflar:**
  * `ChatMessageEntity`: Tekil mesaj balonu (`id`, `senderId`, `receiverId`, `text`, `imageUrl`, `timestamp`, `isMe`).
  * `ChatConversationEntity`: Konuşma listesi öğesi (`peerId`, `peerName`, `peerAvatarUrl`, `lastMessage`, `lastMessageTime`).

### 📄 Repositories (Soyut Arayüzler)
* [auth_repository.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/domain/repositories/auth_repository.dart): `getCurrentUser()`, `login()`, `register()`, `updateProfile()`, `logout()`, `deleteAccount()`.
* [listing_repository.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/domain/repositories/listing_repository.dart): `getAllListings()`, `addListing()`, `getFavoriteIds()`, `toggleFavorite()`, `getUserListings()`, `toggleListingActive()`.
* [rental_repository.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/domain/repositories/rental_repository.dart): `createRental()`, `getMyActiveStay()`, `getMyGivenRentals()`, `checkoutActiveStay()`.
* [chat_repository.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/domain/repositories/chat_repository.dart): `getConversations()`, `getMessages()`, `sendMessage()`.

### 📄 UseCases (Kullanım Senaryoları)
* [auth_usecases.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/domain/usecases/auth_usecases.dart): `GetCurrentUserUseCase`, `LoginUseCase`, `RegisterUseCase`, `UpdateProfileUseCase`, `LogoutUseCase`, `DeleteAccountUseCase`.
* [listing_usecases.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/domain/usecases/listing_usecases.dart): `GetAllListingsUseCase`, `AddListingUseCase`, `ToggleFavoriteUseCase`, `GetFavoriteIdsUseCase`, `ToggleListingActiveUseCase`.
* [rental_usecases.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/domain/usecases/rental_usecases.dart): `CreateRentalUseCase`, `GetMyActiveStayUseCase`, `GetMyGivenRentalsUseCase`, `CheckoutActiveStayUseCase`.
* [chat_usecases.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/domain/usecases/chat_usecases.dart): `GetConversationsUseCase`, `GetMessagesUseCase`, `SendMessageUseCase`.

---

## 5. Data Katmanı (Veri Modelleri ve Yerel Depolama)

### 📄 Data Modelleri
JSON ve Map dönüşümleri domain nesnelerini extend ederek gerçekleştirilmiştir:
* [user_model.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/data/models/user_model.dart): `fromJson`, `toJson`, `fromEntity`.
* [listing_model.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/data/models/listing_model.dart): `fromJson`, `toJson`, `fromEntity`.
* [rental_model.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/data/models/rental_model.dart): `fromJson`, `toJson`, `fromEntity`.
* [chat_model.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/data/models/chat_model.dart): `fromJson`, `toJson`.

### 📄 Repository Uygulamaları (Data Repositories)

#### [auth_repository_impl.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/data/repositories/auth_repository_impl.dart)
* **Kullanılan Kutu:** `auth_box`
* **İşlevler:**
  * `getCurrentUser()`: Oturumu kayıtlı kullanıcıyı döner. Eğer henüz kullanıcı yoksa uygulamanın boş kalmaması için varsayılan örnek kullanıcıyı (`Betül Yılmaz`) oluşturup oturumu açar.
  * `login(emailOrUsername, password)`: Şifre ve e-posta kontrolü yapar.
  * `register(user)` & `updateProfile(user)`: Kullanıcıyı Hive'a kaydeder ve günceller.
  * `logout()` & `deleteAccount()`: Oturum anahtarını siler veya hesabı tamamen kaldırır.

#### [listing_repository_impl.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/data/repositories/listing_repository_impl.dart)
* **Kullanılan Kutular:** `user_listings_box`, `favorites_box`
* **İşlevler:**
  * `getAllListings()`: İlk önce `assets/roommates.json` dosyasındaki örnek verileri okur; ardından kullanıcının Hive'da oluşturduğu ilanları ekleyerek birleşik listeyi sunar (kullanıcı verileri asset verileri tarafından ezilmez).
  * `toggleFavorite(id)` & `getFavoriteIds()`: Favori ilan ID setini Hive kutusunda saklar.
  * `addListing(listing)`: Yeni verilen ilanı `user_listings_box` içine yazar.

#### [rental_repository_impl.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/data/repositories/rental_repository_impl.dart)
* **Kullanılan Kutu:** `rentals_box`
* **İşlevler:**
  * `getMyActiveStay(userId)`: Kullanıcının henüz çıkış yapmadığı (`!isCompleted`) aktif konaklamasını döner. İlk açılışta ekranın boş kalmaması için örnek aktif rezervasyon tohumlaması yapar.
  * `getMyGivenRentals(hostId)`: Kullanıcının ev sahibi olarak kiraya verdiği odaları listeler.
  * `checkoutActiveStay(rentalId)`: İlgili kiralamayı `isCompleted = true` yaparak sonlandırır.

#### [chat_repository_impl.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/data/repositories/chat_repository_impl.dart)
* **Kullanılan Kutu:** `chats_box`
* **İşlevler:**
  * `getConversations(currentUserId)`: Mesajları muhatap kişi bazında gruplar ve en son mesaja göre sıralar.
  * `getMessages(...)` & `sendMessage(...)`: Sohbet mesajlarını kronolojik sırayla getirir ve kaydeder.

---

## 6. Presentation Katmanı — Durum Yönetimi (BLoC / Cubit)

### 📄 [theme_cubit.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/presentation/bloc/theme/theme_cubit.dart)
* **Durum:** `ThemeMode` (`light` / `dark`)
* **İşlev:** Kullanıcının tema tercihini Hive `settings_box` kutusuna kaydeder ve `toggleTheme()` fonksiyonu ile anlık değiştirir.

### 📄 Auth BLoC ([auth_bloc.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/presentation/bloc/auth/auth_bloc.dart))
* **Eventler:** `CheckAuthSessionEvent`, `LoginSubmittedEvent`, `RegisterSubmittedEvent`, `UpdateProfileEvent`, `LogoutEvent`, `DeleteAccountEvent`.
* **State'ler:** `AuthInitialState`, `AuthLoadingState`, `AuthenticatedState(user)`, `UnauthenticatedState`, `AuthErrorState(message)`.
* **İş Mantığı:** Giriş ve kayıtta form doğrulaması, yüklenme animasyon gecikmesi ve hata mesajı yönetimi.

### 📄 Listing BLoC ([listing_bloc.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/presentation/bloc/listing/listing_bloc.dart))
* **Eventler:**
  * `LoadListingsEvent`: Tüm ilanları ve favorileri yükler.
  * `SearchListingsEvent(query)`: Başlık, açıklama, il ve ilçe alanlarında gerçek zamanlı arama yapar.
  * `ApplyFilterEvent(filters)`: Fiyat aralığı, şehir, evcil hayvan, sigara, uyku düzeni, temizlik ve dil kriterlerini filtreler.
  * `ClearFilterEvent`: Filtreleri sıfırlar.
  * `ToggleFavoriteEvent(id)`: Favori durumunu tersine çevirir.
  * `AddNewListingEvent(listing)`: Yeni ilanı listeye ve yerel belleğe ekler.
* **State'ler:** `ListingLoadedState` (`allListings`, `filteredListings`, `favoriteIds`, `searchQuery`, `filters`).

### 📄 Rental BLoC ([rental_bloc.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/presentation/bloc/rental/rental_bloc.dart))
* **Eventler:** `LoadRentalsEvent`, `CreateRentalBookingEvent`, `CheckoutActiveRentalEvent`.
* **Önemli İş Kuralı Koruması:**
  * `_onCreateRentalBooking`: Kullanıcının halihazırda çıkış yapmadığı aktif bir konaklaması varsa (`hasActiveStay == true`), yeni kiralama yapmasını engeller ve açıklayıcı hata fırlatır:
    > *"Zaten aktif bir oda/ev kiralamanız bulunmaktadır. Yeni bir kiralama yapabilmek için önce mevcut kiralamanızdan çıkış yapmalısınız."*
  * `_onCheckoutActiveRental`: Evden çıkış yapıldığında aktif rezervasyonu kapatarak kullanıcının yeniden kiralama yapabilmesinin önünü açar.

### 📄 Chat BLoC ([chat_bloc.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/presentation/bloc/chat/chat_bloc.dart))
* **Eventler:** `LoadConversationsEvent`, `LoadMessagesEvent`, `SendChatMessageEvent`.
* **İş Mantığı:** Mesaj gönderildiğinde anlık olarak konuşma ekranını ve mesaj listesini günceller.

---

## 7. Presentation Katmanı — Ortak Bileşenler (Widgets)

### 📄 [lib/presentation/widgets/app_logo.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/presentation/widgets/app_logo.dart)
* **Amaç:** Gradient çatılı logo simgesi, Roomio tipografisi ve sloganı.

### 📄 [lib/presentation/widgets/campaign_carousel.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/presentation/widgets/campaign_carousel.dart)
* **Amaç:** 5 saniyede bir otomatik kayan indirim ve kampanya banner'ları.
* **Kampanyalar:**
  1. **%20 Öğrenci İndirimi:** Öğrencilere özel kiralama desteği.
  2. **%0 Komisyon:** Yeni ev sahiplerinin ilk ilanlarına komisyonsuz kiralama.
  3. **Kış Sezonu %20 İndirimi:** Kasım-Ocak aylarında büyükşehir ilanlarında indirim.

### 📄 [lib/presentation/widgets/listing_card.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/presentation/widgets/listing_card.dart)
* **Amaç:** Keşfet ve Favoriler ekranlarında kullanılan 2 sütunlu grid kartı.
* **Özellikler:**
  * Fotoğraf üstünde konum etiketi ve favorileme butonu.
  * Eğer indirim tanımlıysa (öğrenci veya kış indirimi) eski fiyatın üzeri çizili gösterilir (`TextDecoration.lineThrough`) ve indirimli tutar belirgin vurgulanır.
  * "İncele" ve "Kirala" butonları.

### 📄 [lib/presentation/widgets/listing_filter_bottom_sheet.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/presentation/widgets/listing_filter_bottom_sheet.dart)
* **Amaç:** Keşfet ekranında alttan açılan çok kriterli filtreleme paneli.
* **Bileşenler:** `RangeSlider` ile fiyat seçimi, şehir `ChoiceChip`'leri, kurallar için `FilterChip`'ler ve temizleme butonu.

### 📄 [lib/presentation/widgets/rental_booking_bottom_sheet.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/presentation/widgets/rental_booking_bottom_sheet.dart)
* **Amaç:** Takvim üzerinden rezervasyon oluşturma ve simüle edilmiş kartla ödeme bottomsheet'i.
* **Bileşenler:**
  * `showDateRangePicker` ile giriş/çıkış tarihi seçimi ve gün sayısı hesabı.
  * Kişi sayısı stepper'ı.
  * Taban fiyat, uygulanan indirim açıklaması ve toplam tutar tablosu.
  * Kredi kartı girdi alanları (Kart No, Kart Sahibi, SKT, CVV).
  * "Öde ve Kirala" onay butonu.

---

## 8. Presentation Katmanı — Ekranlar (Screens)

### 📄 [splash_screen.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/presentation/screen/splash/splash_screen.dart)
* Animasyonlu logo geçişi. Oturum durumuna göre `MainNavigationScreen` veya `OnboardingScreen`'e yönlendirme yapar.

### 📄 [onboarding_screen.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/presentation/screen/onboarding/onboarding_screen.dart)
* 3 adımlı tanıtım slaytları, sayfa gösterge noktaları, "Giriş Yap" ve "Hesap Oluştur" yönlendirme butonları.

### 📄 [login_screen.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/presentation/screen/auth/login_screen.dart)
* Logo, e-posta/kullanıcı adı ve şifre girdi alanları, şifre gizle/göster ikonu, validasyon kontrolü, yüklenme animasyonu ve "Kayıt Ol" geçiş bağlantısı.

### 📄 [register_screen.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/presentation/screen/auth/register_screen.dart)
* **3 Aşamalı Sihirbaz Yapısı:**
  * **1. Aşama (Kişisel Bilgiler):** İsim, e-posta, telefon, şifre, şifre tekrar, yaş, cinsiyet (Kadın/Erkek seçmeli), okul/meslek adı, profil fotoğrafı URL'si.
  * **2. Aşama (Alışkanlıklar):** Sigara kullanımı, öğrenci durumu, evcil hayvan, uyku düzeni (gece/sabah/yok), temizlik hassasiyeti (az/orta/çok), diller.
  * **3. Aşama (Lokasyon):** İl ve İlçe seçimi için dinamik açılır menüler (`DropdownButtonFormField`).
* İlerleme çubuğu, "Geri" ve "Sonraki Aşama" butonları, boş alan bırakıldığında uyarı mesajı.

### 📄 [main_navigation_screen.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/presentation/screen/main_navigation_screen.dart)
* `NavigationBar` ile 5 sekmeli ana çatı:
  1. Keşfet
  2. Favoriler
  3. Kiralamalar
  4. Mesajlar
  5. Profil

### 📄 [home_screen.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/presentation/screen/home/home_screen.dart)
* Başlıkta logo, arama çubuğu, filtreleme butonu, kampanya carousel'i ve ilan grid listesi. Sağ üstte "Yeni İlan Ver" kısayolu.

### 📄 [listing_detail_screen.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/presentation/screen/detail/listing_detail_screen.dart)
* `SliverAppBar` ile büyük görsel, favorileme butonu, indirimli fiyat alanı, ev sahibi kartı, "İletişime Geç" butonu, ev kuralları etiketleri ve alt kısımda sabit "Mesaj Gönder" & "Kirala" butonları.

### 📄 [favorites_screen.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/presentation/screen/favorites/favorites_screen.dart)
* Kullanıcının favorilediği ilanları listeler; hızlı inceleme ve kiralama seçenekleri sunar.

### 📄 [active_rentals_screen.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/presentation/screen/rentals/active_rentals_screen.dart)
* **Segmented Tab:**
  * **Kiralık Tutulanlar:** Kullanıcının aktif misafir olduğu odayı tek bir tam ekran kartında gösterir. Çıkışa kaç gün kaldığı, ödenen miktar, ev sahibiyle sohbet başlatma ve **"Evden / Odadan Çıkış Yap"** butonu yer alır.
  * **Kiraya Verilenler:** Kullanıcının kiraya verdiği ilanlar, kiracı bilgileri (adı, mesleği, fotoğrafı), aktif/pasif durum rozeti ve kiracıya mesaj gönderme butonu.

### 📄 [create_listing_screen.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/presentation/screen/create_listing/create_listing_screen.dart)
* Başlık, açıklama, kira bedeli, fotoğraf linki, şehir/ilçe seçimi ve aranan kiracı kriterlerini içeren yeni ilan ekleme formu.

### 📄 [chat_list_screen.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/presentation/screen/chat/chat_list_screen.dart) & [chat_conversation_screen.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/presentation/screen/chat/chat_conversation_screen.dart)
* Konuşma listesinde yuvarlak avatarlar, kişi adı, son mesaj ve saat bilgisi.
* Sohbet ekranında sağda kullanıcı mesajları, solda karşı tarafın mesajları; mesaj gönderildiğinde otomatik alta kaydırma; emoji ve fotoğraf gönderme butonları.

### 📄 [profile_screen.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/presentation/screen/profile/profile_screen.dart)
* Kullanıcı profil kartı (öğrenci rozeti ile), alışkanlıkları ve adresleri düzenleme bottomsheet'leri, kayıtlı kredi kartı yönetimi, geliştiriciye geri bildirim gönderme kutusu, açık/koyu tema anahtarı, çıkış yapma ve hesap silme diyalogları.

---

## 9. Uygulama Giriş Noktası (main.dart)

### 📄 [lib/main.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/lib/main.dart)
* `WidgetsFlutterBinding.ensureInitialized()` çağrısı.
* Hive motorunun başlatılması ve 6 ana kutunun açılması:
  * `auth_box`, `user_listings_box`, `favorites_box`, `rentals_box`, `chats_box`, `settings_box`.
* Bağımlılık Enjeksiyonu (Clean Architecture Repository ve UseCase örneklemeleri).
* `MultiBlocProvider` ile global BLoC'ların (`ThemeCubit`, `AuthBloc`, `ListingBloc`, `RentalBloc`, `ChatBloc`) uygulamaya enjekte edilmesi.
* Tema moduna dinamik bağlanan `MaterialApp` ve başlangıç ekranı olarak `SplashScreen`.

---

## 10. Test Katmanı

### 📄 [test/widget_test.dart](file:///c:/Users/Betul/Desktop/ev-oda-bulma-uyg/test/widget_test.dart)
* **Kapsam:**
  1. `PriceCalculator Tests`:
     * Günlük baz fiyat formülünün doğrulanması `(Aylık / 30 * Gün)`.
     * Öğrenci profiline uygulanan %20 indirimin doğrulanması.
     * Büyükşehirlerde kış aylarındaki %20 kış sezonu indiriminin doğrulanması.
  2. `RentalEntity Tests`:
     * Çıkış tarihine kalan gün sayısı hesaplayıcısının doğrulanması.
  3. `ListingFilterCriteria Tests`:
     * Filtre aktiflik durumunun doğrulanması.

---

## 🔍 Kalite Güvencesi ve Doğrulama Raporu

Projede yapılan geliştirmelerin ardından `skill.md` standartları uyarınca test ve statik analizler yürütülmüştür:

* **Statik Kod Analizi:**
  ```bash
  flutter analyze
  # Çıktı: No issues found! (0 warnings, 0 errors)
  ```
* **Birim Testleri:**
  ```bash
  flutter test
  # Çıktı: All tests passed! (6 passed)
  ```
