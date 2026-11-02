Girişimci Rehberi — Basit Flutter Mobil Uygulama Planı
1. Projenin amacı
Girişimcilik yolculuğuna yeni başlayan kişilerin temel bilgilere tek yerden ulaşmasını sağlayan, backend içermeyen, basit bir Flutter mobil uygulaması geliştirilecektir. Uygulama bilgi ve örnek profil gösterir; gerçek danışmanlık, randevu veya başvuru hizmeti sunmaz.
Bu bir öğrenci ödevidir. Öncelik: anlaşılır arayüz, dört bölüm arasında sorunsuz gezinme ve temiz, kolay okunur kod.
2. Teknoloji ve kapsam
Flutter + Dart kullanılacak.
Backend, API, Firebase, veritabanı, kullanıcı hesabı, giriş/kayıt sistemi olmayacak.
Tüm içerikler uygulama içinde sabit örnek veriler olarak tutulacak.
Canlı mesajlaşma, gerçek mentor/avukat eşleştirmesi, ödeme, randevu ve başvuru işlemleri olmayacak.
Ek paketler yalnızca gerçekten gerekirse eklenecek; başlangıçta Flutter'ın kendi Material bileşenleri yeterli.
Android ve iOS hedeflenebilir; ilk geliştirme aşamasında tek platformda çalıştırmak yeterli.
3. Dört ana bölüm
3.1 Girişimcilik Rehberi
Girişimcilik nedir?
İş fikri oluşturma
Basit iş planı
Şirket kurmaya genel bakış
Bilgi kartlarına dokunulduğunda kısa açıklama gösterilsin.
3.2 Mentorlar
3–5 adet tamamen kurgusal, demo mentor profili.
Ad, uzmanlık alanı, kısa tanıtım.
Profil detayları görüntülenebilsin.
Gerçek iletişim veya talep gönderme özelliği olmasın.
3.3 Hukuki Destek
Şirket türleri, sözleşmeler, marka tescili hakkında kısa genel bilgiler.
2–3 adet kurgusal, demo avukat profili gösterilebilir.
İçerik hukuki tavsiye olarak sunulmasın; gerçek avukatlık hizmeti sağlandığı izlenimi verilmesin.
3.4 Destek, Teşvik ve Yatırımcılar
KOSGEB ve TÜBİTAK gibi kurumlar hakkında kısa tanıtım kartları.
İlgili kurumların resmi web sayfalarına bağlantı verilebilir.
Tutar, uygunluk ve son başvuru tarihi gibi değişken bilgiler sabit ve güncelmiş gibi gösterilmesin.
Uygulama içinden başvuru yapılmasın.
Yatırımcılar alt kategorisi (aynı dördüncü bölüm içinde):
“Devlet Destekleri” ve “Yatırımcılar” olmak üzere iki basit sekme veya kategori kartı gösterilsin.
Melek yatırımcı, girişim sermayesi ve yatırımcı sunumu (pitch deck) kavramlarını kısa, anlaşılır bilgi kartlarıyla açıkla.
3 adet tamamen kurgusal ve “Demo Profil” etiketli yatırımcı profili göster: ad, ilgi alanı, yatırım aşaması ve kısa açıklama.
Bir profile dokunulduğunda detayları açılsın; gerçek eşleştirme, iletişim, yatırım talebi veya para transferi olmasın.
Devlet desteği ile öz sermaye yatırımı arasındaki fark kısaca açıklansın.
İnternet bağlantısı, API veya veritabanı gerektirmesin.
4. Ekranlar ve gezinme
Ana ekran: Uygulama başlığı, kısa açıklama ve dört kategori kartı.
Rehber ekranı: Bilgi kartları.
Mentorlar ekranı: Demo mentor listesi.
Hukuki destek ekranı: Bilgiler ve demo avukat listesi.
Destekler ekranı: Kurum/program tanıtımları ve aynı ekran içindeki Yatırımcılar alt kategorisi.
Gerekli detaylar için basit detay sayfası veya açılır panel kullanılabilir.
Navigator ile temel sayfa geçişi yeterlidir; karmaşık yönlendirme paketi gerekmez.
5. Klasör ve dosya yapısı
Aşağıdaki yapı proje kök dizini içindir. android/, ios/, test/ gibi Flutter'ın otomatik oluşturduğu klasörler ayrıca bulunabilir; bunları elle oluşturmayın.
girisimci_rehberi/
├── lib/
│ ├── main.dart # Uygulamanın başlangıcı ve tema
│ ├── screens/
│ │ ├── home_screen.dart
│ │ ├── guide_screen.dart
│ │ ├── mentors_screen.dart
│ │ ├── legal_screen.dart
│ │ └── supports_screen.dart # Devlet destekleri + yatırımcılar alt kategorisi
│ ├── data/
│ │ └── sample_data.dart # Sabit rehber, mentor, avukat, destek ve yatırımcı verileri
│ └── widgets/
│ └── info_card.dart # Tekrarlanan basit kart bileşeni
├── reference/
│ └── project_overview.md # Bu planın/proje kapsamının kopyası
├── test/ # Flutter'ın oluşturduğu test klasörü
├── pubspec.yaml
└── README.md
Başlangıçta gerekli olmayan klasörler: .agents/, examples/, scripts/, services/, repositories/, models/ ve assets/. İleride gerçek ihtiyaç oluşursa eklenebilir. Antigravity'ye özel kural veya iş akışı gerekiyorsa .agents/ ancak aracın desteklediği yapıya uygun olarak oluşturulmalıdır.
6. Tasarım beklentileri
Türkçe arayüz.
Sade, modern, açık renkli Material tasarım.
Okunabilir metinler, büyük dokunma alanları, tutarlı boşluklar.
Dört kategori için ayırt edilebilir ikon ve kartlar.
Küçük ekranlarda taşma olmamalı.
Gösterişli animasyonlar veya karmaşık görsel efektler gerekli değil.
7. Geliştirme sırası
flutter create girisimci_rehberi komutuyla projeyi oluştur.
lib/screens, lib/data, lib/widgets, reference klasörlerini ekle.
main.dart ve ana ekranı oluştur.
Dört kategori ekranını oluştur ve geçişleri çalıştır.
sample_data.dart içine örnek içerikleri ekle.
Liste/kart arayüzlerini ve basit detay görünümünü tamamla.
Android veya iOS simülatöründe açılış, gezinme ve ekran taşmalarını test et.
8. Tamamlanma kriterleri
Uygulama hatasız açılır.
Ana ekrandan dört bölüme gidilir ve geri dönülür.
Her bölümde anlamlı örnek içerik gösterilir.
Destekler bölümünde hem devlet destekleri hem de demo yatırımcı profilleri görülebilir.
Herhangi bir backend veya internet bağlantısı olmadan temel ekranlar çalışır.
Demo profillerin gerçek kişi olmadığı anlaşılır.
Kod sade ve dosyalar görevlerine göre ayrılmıştır.
9. Yapay zekâ geliştirme aracına talimat
Bu plana uygun, minimum kapsamlı bir Flutter öğrenci projesi geliştir. Önce çalışan ekranları ve gezinmeyi tamamla. Backend, veritabanı, Firebase, oturum açma, canlı sohbet, ödeme veya karmaşık mimari ekleme. Gereksiz klasör, paket ve özellik oluşturma. Verileri sample_data.dart içinde sabit tut. Dördüncü bölümde devlet desteklerine ek olarak yatırımcılar alt kategorisi ve kurgusal yatırımcı profilleri yer alsın; beşinci ana bölüm oluşturma. Tüm arayüz Türkçe olsun. Bir özellik bu planda belirtilmemişse kendiliğinden kapsamı büyütme.
Not: Dört bölüm ve içerikleri, konuşulan fikirlerden türetilmiş öneri kapsamıdır; proje sahibinin kesin gereksinimleri henüz doğrulanmamıştır.
