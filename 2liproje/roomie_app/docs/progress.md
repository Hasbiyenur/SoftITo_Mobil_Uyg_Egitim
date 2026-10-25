# Roomio Geliştirme İlerleme Takibi (progress.md)

## 1. Ortam ve Uyumluluk Doğrulaması
- [x] Flutter ve Dart sürüm kontrolü (Flutter 3.47.7, Dart 3.13.5 stabil kanal).
- [x] Flutter proje altyapısı bu klasörde (`c:\Users\hasbi\Desktop\roomie_app`) iç içe klasör oluşturulmadan kuruldu.
- [x] Bağımlılıklar eklendi ve doğrulandı: `flutter_bloc (9.1.1)`, `equatable (3.0.0)`, `hive (2.2.3)`, `hive_flutter (1.1.0)`, `path_provider`, `intl`, `uuid`, `image_picker`, `url_launcher`, `google_fonts`.

## 2. Netleştirilen İş Mantığı ve Kurallar
- [x] **Kira Dönemi ve Ücret**: İlanlarda aylık kira belirtilecek; kiralama süresine göre gün bazlı formül `(Aylık Kira / 30) * Gün Sayısı` ile hesaplanacak.
- [x] **Ödeme Zamanı**: Kiralama bottomsheet'inde giriş/çıkış tarihleri ve kişi sayısı belirlenip rezervasyon anında peşin demo kart ile ödenecek; aktif kiralama oluşacak.
- [x] **Erken Çıkış**: Erken çıkışta fiili kalınan günlerin ücreti kesilecek, kalan sürenin tutarı demo iade simülasyonu olarak kullanıcıya gösterilecek. Evin çıkış fotoğrafı yüklenmesi zorunlu olacak ve kiralama "Daha Önce Kiraladıklarım" geçmişine aktarılacak.
- [x] **Kampanyalar**: Öğrenci profili olanlara sepette/ödemede otomatik %20 öğrenci indirimi, seçili şehirlerde kış sezon indirimi (%20) uygulanacak. Şeffaf döküm sunulacak.

## 3. Mimari ve Katman Planı (Clean Architecture + BLoC + Hive)
- [x] Katman yapısı planlandı (`core/`, `data/`, `domain/`, `presentation/`).
- [ ] Core Katmanı:
  - [ ] Tema ve Renkler (`design.md` paletine uygun açık ve koyu tema: #E06A3B, #F39C12, #FCF9F5, #2C3E50 vs.).
  - [ ] Tipografi ve Boşluk Tokenları (4px ölçek, Outfit / Inter modern fontlar).
  - [ ] Routing ve Navigasyon.
  - [ ] Hive depolama servisleri ve kutu yöneticileri (doğrudan UI'dan erişilmeyecek, repository üzerinden yönetilecek).
- [ ] Data Katmanı:
  - [ ] Modeller (`UserModel`, `ListingModel`, `RentalModel`, `ChatModel`, `ChatMessageModel`, `FeedbackModel`).
  - [ ] Hive adapter/JSON serileştiriciler.
  - [ ] Başlangıç verileri (`assets/roommates.json`) yükleme ve ilk açılışta yerel veriyle harmanlama (kullanıcı verilerini ezmeme garantisi).
  - [ ] Repository uygulamaları (`AuthRepository`, `ListingRepository`, `RentalRepository`, `ChatRepository`, `FeedbackRepository`).
- [ ] BLoC Durum Yönetimi:
  - [ ] `AuthBloc` (Giriş, 3 aşamalı kayıt, profil güncelleme, adresler, ödeme yöntemi, hesap silme, oturum kapatma).
  - [ ] `ThemeCubit` (Açık/Koyu tema yönetimi, Hive kalıcı).
  - [ ] `ListingBloc` (Keşfet listeleme, arama, filtreleme, favorileme, yeni ilan ekleme).
  - [ ] `RentalBloc` (Peşin rezervasyon, aktif kiralama kuralı [tek aktif kiralama limiti], erken çıkış hesabı, çıkış fotoğrafı, geçmişe aktarım).
  - [ ] `ChatBloc` (Mesajlaşma listesi, sohbet içi mesaj gönderimi, otomatik yanıt simülasyonu, emoji ve fotoğraf gönderimi).
- [ ] Sunum (Presentation) Katmanı:
  - [ ] Splash & Onboarding ekranları.
  - [ ] Login Ekranı (demo doğrulama, yüklenme hissi).
  - [ ] 3 Aşamalı Kayıt Ol Ekranı (Kişisel -> Alışkanlıklar -> Lokasyon + Adli sicil/Öğrenci belgesi dış bağlantı simülasyonu).
  - [ ] Ana İskelet (Bottom Navigation Bar ile Keşfet, Favoriler, Aktif Kiralamalar, Mesajlar, Profil).
  - [ ] Keşfet (Arama çubuğu, Kampanya banner carousel, İlan grid'i, Filtreleme bottomsheet, İlan detay geçişi, İlan oluştur butonu).
  - [ ] İlan Detay Ekranı (Görsel, İlan ve Ev Sahibi bilgileri, Favorileme, İletişime geç [chat], Kiralama bottomsheet [tarih aralığı, kişi sayısı, kampanya indirimi dökümü, demo kart ödemesi]).
  - [ ] Favoriler Ekranı (Favori grid'i, kaldırma, inceleme, kiralama).
  - [ ] Aktif Kiralamalar Ekranı (Segmented tab: "Kiralık Tuttuklarım" tek kart detay ekranı + "Kiraya Verdiklerim" listesi; Çıkış yap akışı + zorunlu çıkış fotoğrafı yükleme + erken çıkış iade simülasyonu).
  - [ ] İlan Verme Ekranı (Başlık, açıklama, fotoğraf ekleme, kira, konum, kiracı tercihleri).
  - [ ] Chat Ekranları (Sohbet listesi ve sohbet detay ekranı, sağ/sol konuşma baloncukları, emoji, fotoğraf).
  - [ ] Profil Ekranı (Profil detay kartı, alışkanlıklar düzenleme, adreslerim bottomsheet, kayıtlı kart bottomsheet, daha önce kiraladıklarım geçmişi, feedback bottomsheet, tema değiştirme, çıkış yap, hesap sil).
  - [ ] Daha Önce Kiraladıklarım Ekranı (Geçmiş listesi ve çıkış fotoğrafı dahil detay diyaloğu/sayfası).

## 4. Test ve Doğrulama
- [ ] Unit & Bloc testleri (Tek aktif kiralama kuralı, kira ve indirim hesaplama, erken çıkış iade mantığı, favorileme).
- [ ] Widget & akış testleri.
- [ ] `dart format .`, `flutter analyze` ve `flutter test` çalıştırma.
- [ ] Final durum değerlendirmesi.
