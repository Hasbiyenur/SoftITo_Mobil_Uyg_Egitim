# Girişimci Rehberi — Basit Flutter Mobil Uygulama Planı

## 1. Projenin Amacı
Girişimcilik yolculuğuna yeni başlayan kişilerin temel bilgilere tek yerden ulaşmasını sağlayan, backend içermeyen, basit bir Flutter mobil uygulaması geliştirilecektir. Uygulama bilgi ve örnek profil gösterir; gerçek danışmanlık, randevu veya başvuru hizmeti sunmaz.
Bu bir öğrenci ödevidir. Öncelik: anlaşılır arayüz, dört bölüm arasında sorunsuz gezinme ve temiz, kolay okunur kod.

## 2. Teknoloji ve Kapsam
- Flutter + Dart kullanılacak.
- Backend, API, Firebase, veritabanı, kullanıcı hesabı, giriş/kayıt sistemi olmayacak.
- Tüm içerikler uygulama içinde sabit örnek veriler olarak tutulacak.
- Canlı mesajlaşma, gerçek mentor/avukat eşleştirmesi, ödeme, randevu ve başvuru işlemleri olmayacak.
- Ek paketler yalnızca gerçekten gerekirse eklenecek; başlangıçta Flutter'ın kendi Material bileşenleri yeterli.
- Android ve iOS hedeflenebilir; ilk geliştirme aşamasında tek platformda çalıştırmak yeterli.

## 3. Dört Ana Bölüm
### 3.1 Girişimcilik Rehberi
- Girişimcilik nedir?
- İş fikri oluşturma
- Basit iş planı
- Şirket kurmaya genel bakış
- Bilgi kartlarına dokunulduğunda kısa açıklama gösterilsin.

### 3.2 Mentorlar
- 3–5 adet tamamen kurgusal, demo mentor profili.
- Ad, uzmanlık alanı, kısa tanıtım.
- Profil detayları görüntülenebilsin.
- Gerçek iletişim veya talep gönderme özelliği olmasın.

### 3.3 Hukuki Destek
- Şirket türleri, sözleşmeler, marka tescili hakkında kısa genel bilgiler.
- 2–3 adet kurgusal, demo avukat profili gösterilebilir.
- İçerik hukuki tavsiye olarak sunulmasın; gerçek avukatlık hizmeti sağlandığı izlenimi verilmesin.

### 3.4 Destek ve Teşvikler
- KOSGEB ve TÜBİTAK gibi kurumlar hakkında kısa tanıtım kartları.
- İlgili kurumların resmi web sayfalarına bağlantı verilebilir.
- Tutar, uygunluk ve son başvuru tarihi gibi değişken bilgiler sabit ve güncelmiş gibi gösterilmesin.
- Uygulama içinden başvuru yapılmasın.

## 4. Ekranlar ve Gezinme
- **Ana ekran:** Uygulama başlığı, kısa açıklama ve dört kategori kartı.
- **Rehber ekranı:** Bilgi kartları.
- **Mentorlar ekranı:** Demo mentor listesi.
- **Hukuki destek ekranı:** Bilgiler ve demo avukat listesi.
- **Destekler ekranı:** Kurum/program tanıtımları.
- Gerekli detaylar için basit detay sayfası veya açılır panel kullanılabilir.
- Navigator ile temel sayfa geçişi yeterlidir; karmaşık yönlendirme paketi gerekmez.

## 5. Klasör ve Dosya Yapısı
```text
girisimcilik/
├── lib/
│   ├── main.dart             # Uygulamanın başlangıcı ve tema
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── guide_screen.dart
│   │   ├── mentors_screen.dart
│   │   ├── legal_screen.dart
│   │   └── supports_screen.dart
│   ├── data/
│   │   └── sample_data.dart  # Sabit rehber, mentor, avukat ve destek verileri
│   └── widgets/
│       └── info_card.dart    # Tekrarlanan basit kart bileşeni
├── reference/
│   └── project_overview.md   # Bu planın/proje kapsamının kopyası
├── test/                     # Flutter test klasörü
├── pubspec.yaml
└── README.md
```

## 6. Tasarım Beklentileri
- Türkçe arayüz.
- Sade, modern, açık renkli Material tasarım.
- Okunabilir metinler, büyük dokunma alanları, tutarlı boşluklar.
- Dört kategori için ayırt edilebilir ikon ve kartlar.
- Küçük ekranlarda taşma olmamalı.
- Gösterişli animasyonlar veya karmaşık görsel efektler gerekli değil.

## 7. Tamamlanma Kriterleri
- Uygulama hatasız açılır.
- Ana ekrandan dört bölüme gidilir ve geri dönülür.
- Her bölümde anlamlı örnek içerik gösterilir.
- Herhangi bir backend veya internet bağlantısı olmadan temel ekranlar çalışır.
- Demo profillerin gerçek kişi olmadığı anlaşılır.
- Kod sade ve dosyalar görevlerine göre ayrılmıştır.
