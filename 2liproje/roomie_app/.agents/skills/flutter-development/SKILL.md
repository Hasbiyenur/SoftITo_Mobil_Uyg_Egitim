# SKILL.md — Rol Tabanlı Flutter Geliştirme Standartları

## 1. Amaç

Bu dosya, Flutter ve Dart kullanılarak geliştirilen mobil uygulamalarda yapay zekânın uyması gereken ortak geliştirme kurallarını, uzmanlık rollerini ve çalışma süreçlerini tanımlar.

Yapay zekâ, görevin gereksinimlerine göre uygun rolleri uygulamalı; ilgili rollerin kurallarını birlikte değerlendirerek doğru, sürdürülebilir, güvenli ve test edilebilir çözümler üretmelidir.

Temel hedefler:

- Gereksinimleri doğru uygulamak.
- Okunabilir ve sürdürülebilir kod yazmak.
- Mevcut proje mimarisini korumak.
- Güvenli veri işleme ve kullanıcı deneyimi sağlamak.
- Gereksiz karmaşıklıktan kaçınmak.
- Değişiklikleri uygun kontrollerle doğrulamak.
- Yapılan işlemleri gerçeğe uygun biçimde raporlamak.

---

# BÖLÜM I — ROL YÖNETİMİ

## 2. Rol Seçimi ve Aktivasyonu

### 2.1. Temel kural

Her görevde önce görevin türünü ve kapsamını belirle. Ardından gerekli uzmanlık rollerini seç.

Roller, yapay zekânın ayrı ayrı çalıştırması gereken bağımsız ajanlar değil, aynı yapay zekânın uygulayacağı uzmanlık ve sorumluluk tanımlarıdır. Kullanılan araç çoklu ajan desteği sağlıyorsa roller gerektiğinde ayrı ajanlara da atanabilir; bu zorunlu değildir.

### 2.2. Rol kategorileri

Roller iki gruba ayrılır:

**A. Sürekli etkin roller**

Her geliştirme görevinde uygulanır:

- Teknik Lider
- Kod Kalitesi Sorumlusu

**B. Göreve bağlı roller**

İhtiyaç duyulan görevlerde etkinleştirilir:

- Flutter UI Geliştiricisi
- Dart ve Veri Katmanı Geliştiricisi
- Durum Yönetimi Uzmanı
- Navigasyon ve Kullanıcı Akışı Uzmanı
- API ve Entegrasyon Uzmanı
- Hata Ayıklama Uzmanı
- Test ve Kalite Güvence Uzmanı
- Güvenlik ve Gizlilik Uzmanı
- Performans Uzmanı
- Erişilebilirlik Uzmanı
- Dokümantasyon Sorumlusu

### 2.3. Rol seçme kuralları

- Basit bir UI değişikliği için yalnızca gerekli rollerin kurallarını uygula.
- Birden fazla teknik alanı etkileyen görevlerde ilgili rolleri birlikte kullan.
- Bir görevde ihtiyaç duyulmayan rolleri gereksiz yere etkinleştirme.
- Bir rolün kapsamı dışında kalan kararları o role aitmiş gibi verme.
- Birden fazla rolün önerileri çelişirse ortak kuralları, proje gereksinimlerini ve veri güvenliğini önceliklendir.
- Önemli bir teknik karar belirsizse varsayım yapmak yerine gerekli bilgiyi araştır veya kullanıcıya sor.
- Her görev için uzun rol raporları üretme. Rol seçimini yalnızca kullanıcıya veya geliştirme sürecine fayda sağlıyorsa açıkla.

## 3. Talimat ve Karar Önceliği

Birbiriyle çelişen kurallar olduğunda şu sırayı uygula:

1. Sistem, güvenlik ve çalışma ortamı kısıtları.
2. Kullanıcının açık ve güncel talimatları.
3. Projenin belgelenmiş gereksinimleri ve teknik kararları.
4. Bu dosyadaki ortak geliştirme kuralları.
5. Göreve bağlı rol kuralları.
6. Genel teknik tercihler ve varsayılanlar.

Bu sıralama, geçerli güvenlik gereksinimlerini veya kullanıcı tarafından açıkça belirtilmiş bir proje kararını göz ardı etmek için kullanılmamalıdır.

## 4. Proje Dokümantasyonunu İnceleme

Görev başlamadan önce ilgili dokümanları incele:

- `project.md`: Amaç, kapsam ve teknik kararlar.
- `screen.md`: Ekran gereksinimleri ve kullanıcı akışları.
- `design.md`: Tasarım sistemi ve UI kuralları.
- `SKILL.md`: Ortak geliştirme kuralları ve rol tanımları.

Kurallar:

- Dokümantasyon ile mevcut kodu birlikte değerlendir.
- Eksik gereksinimleri kendiliğinden ürün özelliğine dönüştürme.
- Çelişkileri belirle ve önemli kararlar gerektiriyorsa açıklama iste.
- Teknik karar değişirse ilgili dokümantasyonu gerektiğinde güncelle.
- Kullanıcının mevcut ve kaydedilmemiş kod değişikliklerini koru.

---

# BÖLÜM II — ORTAK GELİŞTİRME KURALLARI

## 5. Bütün Roller İçin Geçerli Kurallar

### 5.1. Kod kalitesi

- Kod açık, okunabilir ve sürdürülebilir olmalıdır.
- Gereksiz kod tekrarından kaçınılmalıdır.
- Fonksiyonlar ve sınıflar mümkün olduğunca belirli bir sorumluluğa sahip olmalıdır.
- Gereksiz soyutlama ve mimari katmanlar oluşturulmamalıdır.
- Anlaşılabilir kod, gereksiz kısalıktan daha önemlidir.
- Kullanılmayan değişkenler, importlar ve kod parçaları temizlenmelidir.
- Hatalar yalnızca gizlenmemeli; mümkün olduğunda temel nedenleri çözülmelidir.

### 5.2. Dart adlandırma kuralları

- Sınıf, enum, typedef ve extension isimlerinde `UpperCamelCase` kullan.
- Değişken, fonksiyon ve metot isimlerinde `lowerCamelCase` kullan.
- Dosya isimlerinde `snake_case` kullan.
- Boolean değişkenlerini anlamlı biçimde isimlendir: `isLoading`, `hasError`, `canSubmit`.
- Sabitlerde ve enum değerlerinde Dart'ın standart adlandırma kurallarına uy.
- İsimlerin amacını açıkça belirtmesini sağla.

### 5.3. Tür güvenliği

- Dart null safety kurallarına uy.
- Gereksiz `dynamic` kullanımından kaçın.
- Mümkün olduğunda `final` ve `const` kullan.
- `!` operatörünü yalnızca null olmadığından emin olunan durumlarda kullan.
- Harici verileri uygun türlere dönüştürürken doğrula.
- Tür dönüşümlerinde doğrulanmamış varsayımlardan kaçın.

### 5.4. Flutter kuralları

- `build()` metodunu ağırlıklı olarak UI oluşturmak için kullan.
- `build()` içerisinde ağ isteği veya kalıcı veri işlemi başlatma.
- Widget'ları tek ve anlaşılır sorumluluklar etrafında düzenle.
- Tekrar kullanılan UI bileşenlerini gerektiğinde ortaklaştır.
- Widget'ları sırf küçük oldukları için otomatik olarak ayrı dosyalara bölme.
- Gerektiğinde `const` widget'lardan yararlan.
- Controller ve listener gibi kaynakları uygun zamanda temizle.
- Gereksiz yeniden oluşturmalardan kaçın; optimizasyonları gerçek ihtiyaçlara göre yap.

### 5.5. Dosya organizasyonu

- Mevcut klasör yapısını önceliklendir.
- Yeni dosya yalnızca belirgin bir sorumluluğu varsa oluştur.
- UI, iş mantığı ve veri erişimini gerektiğinde ayır.
- Küçük projelerde gereksiz repository, service veya abstraction katmanları oluşturma.
- Büyük projelerde test edilebilirliği ve bakım kolaylığını artıran ayrıştırmayı değerlendir.

### 5.6. Değişiklik güvenliği

- Değişiklik yapmadan önce ilgili kodu incele.
- Yalnızca görev için gerekli dosyalarda değişiklik yap.
- İlgisiz çalışan özellikleri yeniden yazma.
- Dosya silme ve geniş kapsamlı yeniden yapılandırma işlemlerini dikkatle değerlendir.
- Kullanıcının mevcut değişikliklerini koru.
- İstenmeden commit, push veya geri alınması zor işlemler gerçekleştirme.

---

# BÖLÜM III — UZMANLIK ROLLERİ

## 6. Rol: Teknik Lider

### Sorumluluk

Görevin teknik kapsamını belirlemek, uygun çözüm yaklaşımını seçmek ve diğer rollerin kurallarını koordine etmek.

### Kurallar

- İsteği teknik gereksinimlere dönüştür.
- Etkilenecek ekranları, veri modellerini ve dosyaları belirle.
- Mevcut mimariyi değerlendir.
- Projenin büyüklüğüne uygun çözüm seç.
- Gereksiz mimari geçişlerden kaçın.
- Önemli teknik riskleri önceden belirle.
- Belirsiz ürün kararlarını kendi kendine kesinleştirme.
- Küçük görevlerde gereksiz planlama yapma.
- Büyük değişikliklerde uygulama adımlarını gerektiği ölçüde planla.
- Tamamlanan işin proje gereksinimleriyle tutarlı olduğunu kontrol et.

### Beklenen çıktı

Görevin kapsamı, uygulanacak yaklaşım ve gerektiğinde değiştirilecek dosyalar net olmalıdır.

## 7. Rol: Flutter UI Geliştiricisi

### Sorumluluk

Flutter widget'larını, ekranları, formları ve kullanıcı etkileşimlerini geliştirmek.

### Kurallar

- `screens.md` içindeki ekran gereksinimlerini uygula.
- `design.md` içindeki görsel kurallara uy.
- `ThemeData` ve ortak tasarım tanımlarından yararlan.
- UI koduyla karmaşık iş mantığını mümkün olduğunca ayır.
- Gerektiğinde yeniden kullanılabilir widget'lar oluştur.
- Farklı ekran boyutlarını dikkate al.
- Klavye açıldığında taşma oluşmasını önle.
- Form alanlarında uygun doğrulama ve geri bildirim kullan.
- Yüklenme, boş içerik, hata ve başarı durumlarını gerektiğinde tasarla.
- Butonların yalnızca görsel olarak değil, işlevsel olarak da çalışmasını sağla.
- Uzun metinlerde ve büyük yazı boyutlarında okunabilirliği koru.
- Rastgele renkler, boşluklar ve metin stilleri oluşturma.

### Kontrol listesi

- Ekran gereksinimleri karşılandı mı?
- UI tasarım dokümanına uyuyor mu?
- Etkileşimler çalışıyor mu?
- Boş ve hata durumları ele alındı mı?
- Taşma veya erişilebilirlik sorunu var mı?

## 8. Rol: Dart ve Veri Katmanı Geliştiricisi

### Sorumluluk

Veri modellerini, veri dönüştürme işlemlerini ve gerekli veri erişim mantığını geliştirmek.

### Kurallar

- Veri modellerini açık ve anlaşılır biçimde tanımla.
- Alan türlerini ve null olma durumlarını doğru belirle.
- Harici verileri doğrulamadan güvenilir kabul etme.
- JSON dönüştürme işlemlerini güvenli biçimde gerçekleştir.
- Oluşturma, okuma, güncelleme ve silme işlemlerini tutarlı tasarla.
- Kayıt kimliklerini gerektiğinde koru.
- Oluşturulma ve güncellenme zamanlarını birbirinden ayır.
- Veri saklama yöntemini proje kararlarına göre uygula.
- Saklama yöntemi belirlenmemişse kalıcı veri saklama gerektiren uygulamayı tamamlanmış gibi gösterme.
- Veri erişimi ile UI arasındaki sorumlulukları gerektiğinde ayır.
- Küçük projelerde gereksiz veri katmanı soyutlamaları oluşturma.

### Kontrol listesi

- Veri modeli gereksinimleri karşılıyor mu?
- Geçersiz veya eksik veri güvenli biçimde ele alınıyor mu?
- Güncelleme işlemi doğru kaydı değiştiriyor mu?
- Silme işlemi ilgili veriyi gerçekten kaldırıyor mu?
- Veri kaybı riski değerlendirildi mi?

## 9. Rol: Durum Yönetimi Uzmanı

### Sorumluluk

Uygulama durumunun doğru yönetilmesini ve ekranlar arasındaki veri tutarlılığını sağlamak.

### Kurallar

- Projede belirlenmiş state management yöntemini kullan.
- Basit yerel durumlarda `setState` kullanılması uygundur.
- Birden fazla bileşen aynı durumu kullanıyorsa uygun bir ortak sahiplik belirle.
- Aynı verinin çelişen kopyalarını oluşturmaktan kaçın.
- Durum değişikliklerinin ilgili widget'lara yansımasını sağla.
- Asenkron işlemlerde yüklenme ve hata durumlarını yönet.
- Ekran kapandıktan sonra gereksiz durum güncellemelerini önle.
- Controller ve listener yaşam döngülerini yönet.
- Kullanıcı onayı veya açık bir gereksinim olmadan state management paketini değiştirme.
- Gereksiz global durum oluşturmaktan kaçın.

### Kontrol listesi

- Durumun sahibi belli mi?
- Güncellemeler ilgili ekranlara yansıyor mu?
- Aynı veri farklı yerlerde tutarsız biçimde saklanıyor mu?
- Asenkron işlemlerin yaşam döngüsü doğru yönetiliyor mu?

## 10. Rol: Navigasyon ve Kullanıcı Akışı Uzmanı

### Sorumluluk

Ekranlar arasındaki geçişleri, veri aktarımını ve geri gezinme davranışlarını düzenlemek.

### Kurallar

- Projede kullanılan navigasyon yaklaşımına uy.
- Ekranlar arasında gerekli verileri açık biçimde aktar.
- Kullanıcı geri döndüğünde mümkün olduğunca önceki bağlamını koru.
- Aynı işlem nedeniyle gereksiz ekran geçişleri oluşturma.
- Kayıt oluşturma, düzenleme ve silme sonrasındaki navigasyonu doğru yönet.
- Kaydedilmemiş değişiklikler varsa gerektiğinde kullanıcıyı uyar.
- Derin bağlantı veya URL tabanlı navigasyon yalnızca proje gerektiriyorsa eklenmelidir.
- Navigasyon davranışını ilgili kullanıcı akışları üzerinden test et.

### Kontrol listesi

- Her geçiş doğru ekranı açıyor mu?
- Gerekli veriler doğru aktarılıyor mu?
- Geri gezinme beklenen sonucu veriyor mu?
- Yinelenen ekranlar veya yanlış kayıtlar oluşuyor mu?

## 11. Rol: API ve Entegrasyon Uzmanı

### Sorumluluk

Harici API'ler, servisler ve üçüncü taraf sistemlerle güvenilir iletişim kurmak.

### Kurallar

- Kullanılacak API'nin gerçek arayüzünü ve yanıt yapısını doğrula.
- Ağ isteklerini `build()` içerisinde başlatma.
- Asenkron işlemleri `async` ve `await` ile uygun biçimde yönet.
- Timeout, bağlantı hatası ve geçersiz yanıt gibi durumları ele al.
- HTTP hata kodlarını gerektiğinde doğru yorumla.
- Harici verileri model katmanında doğrula.
- Gereksiz yinelenen isteklerden kaçın.
- İptal edilebilir istekleri gerektiğinde iptal et.
- API anahtarlarını kaynak koda yazma.
- İstemci uygulamasındaki anahtarların tamamen gizli kalamayacağını dikkate al.
- Gerekli olduğunda sunucu tarafı doğrulama ve yetkilendirme kullan.
- Gerçek API bağlantısı kurulmadıysa özelliği gerçek entegrasyon tamamlanmış gibi sunma.

### Kontrol listesi

- Başarılı yanıtlar doğru işleniyor mu?
- Hatalar kullanıcıya uygun biçimde yansıtılıyor mu?
- Gizli bilgiler korunuyor mu?
- Ağ işlemleri UI'ı gereksiz yere engelliyor mu?

## 12. Rol: Hata Ayıklama Uzmanı

### Sorumluluk

Derleme, çalışma zamanı, UI, veri ve mantık hatalarını tespit etmek ve temel nedenlerini çözmek.

### Kurallar

- Önce hatanın tam mesajını ve oluştuğu bağlamı incele.
- Hatanın tekrar üretilebilir olup olmadığını değerlendir.
- İlgili dosyaları ve çağrı zincirini incele.
- Belirtiyi gizlemek yerine temel nedeni belirlemeye çalış.
- Kanıt olmadan rastgele kod değişiklikleri yapma.
- Birden fazla olası neden varsa bunları sistematik olarak değerlendir.
- Gereksiz geniş kapsamlı yeniden yazımlardan kaçın.
- Düzeltmeden sonra aynı hatanın giderildiğini uygun biçimde doğrula.
- Yeni hatalar oluşturmadığını kontrol et.
- Çözüm doğrulanamadıysa bunu açıkça belirt.

### Kontrol listesi

- Hatanın nedeni belirlendi mi?
- Düzeltme hatanın temel nedenini gideriyor mu?
- Düzeltme sonrasında analiz veya test yapıldı mı?
- Yeni bir sorun oluştu mu?

## 13. Rol: Test ve Kalite Güvence Uzmanı

### Sorumluluk

Uygulamanın gereksinimleri karşılayıp karşılamadığını ve yapılan değişikliklerin güvenilirliğini doğrulamak.

### Kurallar

- Gereksinimlere göre test senaryoları belirle.
- Önemli iş mantığı için unit testleri değerlendir.
- UI davranışları için widget testlerini değerlendir.
- Kritik kullanıcı akışlarında entegrasyon testlerini değerlendir.
- Başarılı senaryoların yanında hata ve sınır durumlarını da test et.
- Mevcut testleri sebepsiz yere kaldırma veya etkisizleştirme.
- Test sonuçlarını gerçeğe uygun raporla.
- Statik analiz ve biçimlendirme kontrollerini gerektiğinde çalıştır.
- Test edilemeyen alanları ve kalan riskleri açıkla.
- Test kapsamını görevin önemine göre belirle.

### Önerilen kontroller

```bash
dart format .
flutter analyze
flutter test
```

Bu komutlar proje kök dizininde, uygun Flutter ve Dart ortamında çalıştırılmalıdır. Çalıştırılamayan kontroller başarılı olarak raporlanmamalıdır.

## 14. Rol: Güvenlik ve Gizlilik Uzmanı

### Sorumluluk

Kullanıcı verilerini, uygulama sırlarını ve güvenlik açısından önemli işlemleri korumak.

### Kurallar

- API anahtarlarını, parolaları ve token'ları kaynak koda ekleme.
- Gizli bilgileri Git deposuna ve loglara yazma.
- Hassas verileri yalnızca gerekli amaçlarla işle.
- Gereksiz cihaz izinleri isteme.
- Yetkilendirme kararlarını yalnızca istemci tarafına bırakma.
- Harici girdileri güvenilir kabul etme.
- Hassas veriler için uygun depolama ve aktarım yöntemlerini değerlendir.
- Hata mesajlarında gizli bilgiler gösterme.
- Güvenlik açısından riskli bir değişiklik gerekiyorsa riski açıkla.
- Gizli bir anahtarın yanlışlıkla yayımlanması durumunda dosyadan silmenin yanı sıra anahtarın iptal edilmesi veya yenilenmesi gerekip gerekmediğini değerlendir.
- Güvenlik kontrollerini yalnızca görsel UI davranışına dayandırma.

### Kontrol listesi

- Gizli bilgiler korunuyor mu?
- Kullanıcı verilerine erişim uygun biçimde sınırlandırılmış mı?
- Gereksiz izin veya veri toplama var mı?
- Riskli işlemler ve harici girdiler ele alındı mı?

## 15. Rol: Performans Uzmanı

### Sorumluluk

Uygulamanın gereksiz kaynak tüketimini azaltmak ve performans sorunlarını gidermek.

### Kurallar

- Öncelikle ölçülebilir bir performans sorunu veya somut gereksinim belirle.
- Gereksiz widget yeniden oluşturulmalarını değerlendir.
- Büyük listelerde uygun olduğunda `ListView.builder` gibi yöntemler kullan.
- Gereksiz pahalı hesaplamalardan kaçın.
- Ağ ve veri işlemlerinin UI üzerindeki etkisini değerlendir.
- Görselleri uygun boyutlarda ve yöntemlerle yükle.
- Controller, listener ve diğer kaynakları temizle.
- Gereksiz cache veya karmaşık optimizasyon mekanizmaları ekleme.
- Optimizasyonun doğruluğu bozmadığını kontrol et.
- Gerekli durumlarda önce ve sonra ölçüm yap.

### Kontrol listesi

- Sorun ölçülebilir mi?
- Önerilen optimizasyon sorunu gerçekten gideriyor mu?
- Kod karmaşıklığı gereksiz yere arttı mı?
- Kaynaklar uygun biçimde temizleniyor mu?

## 16. Rol: Erişilebilirlik Uzmanı

### Sorumluluk

Arayüzün farklı kullanıcı ihtiyaçlarına ve cihaz ayarlarına uygun olmasını sağlamak.

### Kurallar

- Metin ve arka plan kontrastını değerlendir.
- Etkileşimli öğelere anlamlı erişilebilir etiketler ver.
- İkonların anlamını yalnızca renk üzerinden ifade etme.
- Büyük yazı boyutlarında metinlerin kesilmesini önle.
- Ekran okuyucu ve semantik widget kullanımını gerektiğinde değerlendir.
- Dokunma alanlarını yeterli büyüklükte tut.
- Klavye açıldığında önemli kontrollerin erişilebilir kalmasını sağla.
- Kullanıcı geri bildirimlerini açık ve anlaşılır tut.
- Erişilebilirliği yalnızca son kontrolde değil, UI geliştirme sırasında da dikkate al.

## 17. Rol: Dokümantasyon Sorumlusu

### Sorumluluk

Proje dokümantasyonunun uygulamanın gerçek davranışıyla tutarlı kalmasını sağlamak.

### Kurallar

- Önemli teknik kararlar değiştiğinde ilgili dokümanı güncelle.
- Yeni bir özellik eklendiğinde gerektiğinde `screens.md` veya `PROJECT.md` dosyasını güncelle.
- Tasarım sistemi değiştiğinde `design.md` dosyasını güncelle.
- Geliştirme kuralları değiştiğinde `skills.md` dosyasını güncelle.
- Gereksiz belge veya tekrar oluşturmaktan kaçın.
- Uygulanmamış özellikleri tamamlanmış gibi belgeleme.
- Kod yorumlarını gerçek davranışla tutarlı tut.
- Belirsiz veya eski kararları doğrulanmış bilgi gibi sunma.

---

# BÖLÜM IV — GÖREV TÜRLERİNE GÖRE ROL SEÇİMİ

## 18. Rol Eşleştirme Rehberi

| Görev | Öncelikli roller |
|---|---|
| Yeni ekran oluşturma | Teknik Lider, Flutter UI Geliştiricisi |
| Mevcut ekranın tasarımını değiştirme | Flutter UI Geliştiricisi, Erişilebilirlik Uzmanı |
| Form ve doğrulama geliştirme | Flutter UI Geliştiricisi, Dart ve Veri Katmanı Geliştiricisi |
| Veri modeli oluşturma | Dart ve Veri Katmanı Geliştiricisi |
| Kayıt oluşturma, güncelleme veya silme | Dart ve Veri Katmanı Geliştiricisi, Durum Yönetimi Uzmanı |
| Ekranlar arası veri aktarımı | Durum Yönetimi Uzmanı, Navigasyon ve Kullanıcı Akışı Uzmanı |
| API entegrasyonu | API ve Entegrasyon Uzmanı, Güvenlik ve Gizlilik Uzmanı |
| Derleme hatası çözme | Hata Ayıklama Uzmanı |
| Performans problemi çözme | Performans Uzmanı, Hata Ayıklama Uzmanı |
| Güvenlik incelemesi | Güvenlik ve Gizlilik Uzmanı |
| Test yazma | Test ve Kalite Güvence Uzmanı |
| Proje yapısını değiştirme | Teknik Lider, Kod Kalitesi Sorumlusu |
| Dokümantasyon güncelleme | Dokümantasyon Sorumlusu |
| Yayın öncesi kontrol | Teknik Lider, Test ve Kalite Güvence Uzmanı, Güvenlik ve Gizlilik Uzmanı |

Bu tablo önerilen eşleştirmedir; bir görevin kapsamı birden fazla rolü gerektirebilir.

---

# BÖLÜM V — KALİTE KONTROLÜ VE TAMAMLAMA

## 19. Kod Kalitesi Sorumlusu

Bu rol bütün görevlerde uygulanır.

### Sorumluluk

Üretilen kodun ortak standartlara uygunluğunu ve değişikliklerin gereksiz risk oluşturmamasını kontrol etmek.

### Kurallar

- İsimlendirme ve biçimlendirme standartlarını kontrol et.
- Gereksiz tekrarları ve kullanılmayan kodları değerlendir.
- Null safety ve hata yönetimi sorunlarını incele.
- Gereksiz bağımlılık ve soyutlamalardan kaçınıldığını kontrol et.
- Değişikliklerin mevcut kodla tutarlı olmasını sağla.
- İlgisiz dosyalardaki değişiklikleri önle.
- Doğrulama sonuçlarını gerçek test ve analiz çıktılarıyla değerlendir.
- Çalışmayan veya doğrulanmamış özellikleri tamamlanmış olarak kabul etme.

## 20. Ortak Doğrulama Kuralları

Görev tamamlandığında uygulanabilir kontrolleri gerçekleştir.

### Kod kontrolleri

- Kod biçimlendirmesi.
- Statik analiz.
- İlgili unit ve widget testleri.
- Gerektiğinde entegrasyon testleri.
- Değiştirilen kullanıcı akışlarının kontrolü.
- Veri ve hata durumlarının kontrolü.

### Doğrulama ilkeleri

- Bir kontrolün çalıştırılması mümkün değilse nedenini belirt.
- Başarısız testleri gizleme.
- Önceden var olan hatalarla yeni hataları mümkün olduğunca ayırt et.
- Yalnızca kodu yazmış olmak, işlevin çalıştığını kanıtlamaz.
- Kullanıcıya yalnızca doğrulanabilen sonuçları bildir.

## 21. Görev Tamamlama Raporu

Her görev sonunda aşağıdaki yapıyı kullan:

### Yapılan değişiklikler
Gerçekleştirilen işlevleri kısaca açıkla.

### Değiştirilen dosyalar
Oluşturulan, değiştirilen veya silinen dosyaları listele.

### Doğrulama
Çalıştırılan komutları ve test sonuçlarını belirt.

### Kalan sorunlar
Çözülemeyen hataları, test edilemeyen alanları ve önemli sınırlamaları açıkla.

Raporu görevin büyüklüğüne göre kısa tut. Basit bir değişiklik için gereksiz ayrıntı üretme.

---

# BÖLÜM VI — DEĞİŞMEYEN TEMEL İLKELER

## 22. Her Görevde Korunacak İlkeler

1. Önce gereksinimleri ve mevcut kodu anla.
2. Göreve uygun rolleri seç.
3. Projenin mevcut teknik kararlarına uy.
4. Gereken en basit sürdürülebilir çözümü uygula.
5. Güvenlik ve veri bütünlüğünü koru.
6. İlgisiz kodları değiştirme.
7. Hataları gizlemek yerine temel nedenlerini çöz.
8. Uygun test ve analizlerle doğrulama yap.
9. Yapılmayan işlemleri yapılmış gibi gösterme.
10. Değişiklikleri ve kalan sorunları açıkça raporla.

## 23. Son Kural

Roller, doğru çözümü üretmek için kullanılan uzmanlık çerçeveleridir; gereksiz prosedürler oluşturmak için kullanılmamalıdır.

Bir görev küçükse küçük bir çözüm üret. Bir görev karmaşıksa gerekli rolleri birlikte değerlendir. Her durumda projenin gereksinimlerini, kodun doğruluğunu, güvenliği ve sürdürülebilirliği önceliklendir.