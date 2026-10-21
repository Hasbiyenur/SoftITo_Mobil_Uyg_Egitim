# Alışkanlık Takibi (Habit Tracker)

> **Belge türü:** Flutter ve Dart ile geliştirilecek frontend uygulaması için ayrıntılı proje planı ve Antigravity uygulama talimatı.
> **Uygulama adı:** Alışkanlık Takibi.
> **Kod projesi adı:** `aliskanlik_takibi`.
> **Arayüz dili:** Türkçe.
> **İlk sürüm:** Backend içermeyen, yerel verilerle çalışan mobil uygulama demosu.
> **Tasarım:** Soft renkler, sade kartlar, okunabilir metinler ve neon içermeyen bir tema.


## 1. Proje Özeti

Alışkanlık Takibi; kullanıcının kitap okuma, su içme, spor yapma ve ders çalışma gibi düzenli davranışlarını takip etmesini sağlayan bir mobil uygulamadır.
Kullanıcı görev oluşturur, hangi aralıklarla yapacağını belirler ve planlanan günlerde ilerlemesini kaydeder.
Ana sayfa cihazın güncel tarihine göre o gün yapılacak görevleri gösterir.
Tamamlanan görevler aynı sayfadaki **Yapılanlar** bölümüne taşınır.
Tamamlanan görev başlıkları tek çizgiyle üstü çizilmiş ve daha soluk görünür.
Her alışkanlığın kendisine ait bir devamlılık serisi, yani streak değeri vardır.
Görev planlanan günlerde tamamlanmaya devam ettikçe seri artar; kaçırılan planlı gün sonrasında aktif seri sıfırlanır.
Kullanıcı takvimde tamamladığı günleri, istatistiklerde başarı oranlarını ve kazandığı rozetleri görebilir.

İlk sürüm Flutter ve Dart ile hazırlanacaktır.
Bu sürümde sunucu, Firebase, Supabase, uzaktaki veritabanı veya gerçek kimlik doğrulama servisi kullanılmayacaktır.
Kayıt, giriş ve şifre yenileme ekranları yerel bir demo servis üzerinden çalışacaktır.
Görevler, tamamlama kayıtları, rozetler ve demo kullanıcı bilgileri küçük bir yerel veri kümesi olarak saklanacaktır.
Normal kapatma ve açma sonrasında kayıtlar geri yüklenecektir; uygulama verileri silindiğinde veya uygulama kaldırıldığında kalıcılık beklenmeyecektir.

**Terimler:** Bu belgede “görev” ve “alışkanlık” aynı takip nesnesini ifade eder.
**Ürün kararı:** Günlük olmayan alışkanlıklarda seri, aralıksız tamamlanan **planlı günlerin sayısıdır**; aradaki dinlenme günleri seriyi bozmaz.
**Demo sınırı:** E-posta doğrulaması ve şifre kurtarma, gerçek e-posta sahipliğini doğrulayan güvenli bir sistem değildir.


## 3. Ekranlar ve Gezinme

İlk taslaktaki 3–5 ekran tahmini, ayrıntılı kullanıcı senaryosu nedeniyle güncellenmiştir.
İlk sürümde **10 kullanıcı sayfası**, bunlara ek olarak **1 teknik açılış ekranı** bulunacaktır.
Ekleme ve düzenleme aynı form sayfasını paylaşacaktır.
Şifremi unuttum sayfası, e-posta girişi ve kod doğrulama adımlarını kendi içinde gösterecektir.

| No | Sayfa | Dart dosyası | Temel işlev |
| --- | --- | --- | --- |
| 1 | Giriş | `login_screen.dart` | E-posta ve şifreyle demo giriş |
| 2 | Kaydol | `register_screen.dart` | Ad, soyad, e-posta ve şifreyle kayıt |
| 3 | Şifremi Unuttum | `forgot_password_screen.dart` | Demo doğrulama kodunu alma ve doğrulama |
| 4 | Yeni Şifre Oluştur | `reset_password_screen.dart` | Yeni şifreyi iki kez girerek kaydetme |
| 5 | Ana Sayfa | `home_screen.dart` | Bugünün yapılacakları ve yapılanlar |
| 6 | Görevler | `habits_screen.dart` | Bütün aktif alışkanlıkları listeleme ve yönetme |
| 7 | Görev Ekle / Düzenle | `habit_form_screen.dart` | Alışkanlık özelliklerini kaydetme |
| 8 | Profil | `profile_screen.dart` | Kullanıcı, görev serileri ve çıkış |
| 9 | İstatistikler ve Rozetler | `statistics_screen.dart` | Başarı oranları, en yüksek seri ve rozetler |
| 10 | Takvim | `calendar_screen.dart` | Tamamlanan günleri inceleme |
| Teknik | Açılış | `bootstrap_screen.dart` | Yerel verileri ve oturumu yükleme |

### 3.1. Ayrı Sayfa Olmayan Yüzeyler

- Ana sayfadaki bildirim simgesinin açtığı küçük bildirim penceresi.
- Toplu kaldırma işleminin onay penceresi.
- İlerlemenin azaltılmasıyla görevin tamamlanmamış olacağını açıklayan kısa geri bildirim.
- Görev formundaki tarih ve saat seçiciler.
- Görev sayfasındaki düzenleme ve kaldırma seçim modları.
- Yeni rozet kazanıldığında gösterilen kısa başarı mesajı.

### 3.2. Sabit Alt Menü

Alt menüde yalnızca şu üç hedef bulunacaktır:

1. **Ana Sayfa**
2. **Görevler**
3. **Profil**

Bu üç sayfa `MainShell` içinde aynı alt menüyü paylaşacaktır.
Takvim ana sayfadaki takvim simgesinden, istatistikler profil içindeki karttan açılacaktır.
Görev ekleme formu Görevler sayfasındaki **+ Görev Ekle** butonundan açılacaktır.
Giriş, kayıt ve şifre ekranlarında alt menü bulunmayacaktır.
Tam ekran yardımcı sayfalarda geri düğmesi bulunacak; alt menü yalnızca üç ana sekmede sabit kalacaktır.


## 6. Uygulama Detayları

### 6.1. Teknolojiler

#### 6.1.1. Temel Teknolojiler

| Alan | Seçim | Açıklama |
| --- | --- | --- |
| Arayüz | Flutter | Mobil ekranları ve ortak bileşenleri oluşturur. |
| Dil | Dart | Modeller, servisler ve uygulama mantığı için kullanılır. |
| Tasarım sistemi | Material 3 | Form, kart, alt menü ve diyalog bileşenleri sağlar. |
| Durum yönetimi | `provider` + `ChangeNotifier` | Ortak görev ve kullanıcı durumunu ekranlara dağıtır. |
| Kalıcılık | `shared_preferences` | Küçük demo veri kümesini JSON metni olarak saklar. |
| Tarih biçimleme | `intl` | Türkçe ay ve tarih metinleri oluşturur. |
| Yerelleştirme | `flutter_localizations` | Flutter tarih/saat seçicilerinde Türkçe sağlar. |
| Demo parola doğrulayıcı | `cryptography` | Açık metin parola saklamak yerine salt ve türetilmiş değer kullanır. |
| Test | `flutter_test` | Kritik hesaplamalar ve ekran etkileşimleri test edilir. |
| Sayfa geçişi | `Navigator` + `MaterialPageRoute` | İlk sürümün basit mobil gezinmesini yönetir. |

Bu mimari, proje için seçilmiş sade bir uygulama düzenidir; Flutter'ın zorunlu tuttuğu tek mimari değildir.
Yeni kodda `SharedPreferencesAsync` tercih edilecektir.
`shared_preferences` kritik veya güvenli kayıt sistemi değildir; bu projede yalnızca kaybı tolere edilebilen demo veriler için kullanılacaktır.
Veri büyüdüğünde gerçek yerel veritabanına geçiş ayrı bir geliştirme olarak ele alınacaktır.
`MaterialApp` üzerinde `Locale('tr', 'TR')`, uygun `supportedLocales` ve Flutter yerelleştirme delegeleri tanımlanacaktır.
`intl` tarih verileri başlangıçta `initializeDateFormatting('tr_TR')` ile hazırlandıktan sonra tarih metinleri üretilecektir.
Tarih biçiminde örneğin `DateFormat('d MMMM y, EEEE', 'tr_TR')` kullanılabilir.
Bu tek dilli sürüm için ayrıca çeviri kodu üretim hattı kurulması gerekli değildir.


### 6.2. Ekran Akışları

#### 6.2.1. Genel Gezinme

| Başlangıç | Kullanıcı işlemi / koşul | Hedef |
| --- | --- | --- |
| Açılış | Yerel oturum yok | Giriş |
| Açılış | Geçerli yerel oturum var | Ana Sayfa |
| Giriş | Kaydol | Kaydol |
| Giriş | Şifremi unuttum | Şifremi Unuttum |
| Kaydol | Başarılı kayıt | Başarı mesajıyla Giriş |
| Şifremi Unuttum | Kod doğrulandı, İlerle | Yeni Şifre Oluştur |
| Yeni Şifre Oluştur | Şifre kaydedildi | Giriş |
| Giriş | Başarılı giriş | Ana Sayfa |
| Ana Sayfa | Alt menü | Görevler veya Profil |
| Ana Sayfa | Takvim simgesi | Takvim |
| Ana Sayfa | Bildirim simgesi | Bildirim penceresi |
| Görevler | + Görev Ekle | Görev Ekle / Düzenle |
| Görevler | Düzenlenecek görev seçimi | Görev Ekle / Düzenle |
| Profil | İstatistik kartı | İstatistikler ve Rozetler |
| Profil | Çıkış Yap | Giriş |


#### 6.2.2. Giriş Ekranı

Ekranın üst orta bölümünde uygulama logosu bulunacaktır.
Logonun altında uygulama adı ve “Küçük adımlar, kalıcı alışkanlıklar.” metni yer alabilir.
Formun sırası aşağıdaki gibi olacaktır:

1. E-posta alanı.
2. Şifre alanı.
3. Şifre alanının hemen altında sağa hizalı **Şifremi unuttum** bağlantısı.
4. Birincil **Giriş Yap** butonu.
5. İkincil **Kaydol** butonu veya belirgin metin butonu.

- E-posta alanında uygun klavye türü kullanılacaktır.
- Şifre varsayılan olarak gizli olacaktır.
- Göz simgesiyle şifre görünürlüğü değiştirilebilecektir.
- Hatalar ilgili alanın altında veya formun üstünde anlaşılır metinle gösterilecektir.
- Giriş sırasında buton kısa süreliğine yükleme gösterecek ve çift gönderim engellenecektir.
- Başarılı girişte eski kimlik ekranları gezinme yığınından kaldırılacaktır.
- Giriş hatasında parola veya teknik hata ayrıntısı ekrana/loga yazılmayacaktır.
- Alt bölümde “Demo sürümü — hesaplar bu cihazda tutulur.” açıklaması bulunacaktır.

#### 6.2.4. Kaydol Ekranı

Üst orta bölümde giriş sayfasıyla aynı logo bulunacaktır.
Alt bölümde şu alanlar aynı sırayla yer alacaktır:

1. Ad.
2. Soyad.
3. E-posta.
4. Şifre.
5. **Kaydol** butonu.
6. **Zaten hesabın var mı? Giriş yap** bağlantısı.

- Dört alan da zorunludur.
- Ad ve soyadda Türkçe karakterlere izin verilecektir.
- E-posta karşılaştırması baştaki/sondaki boşluklar kaldırılarak ve küçük harfe çevrilerek yapılacaktır.
- Aynı cihazda aynı normalize e-posta ile ikinci hesap oluşturulmayacaktır.
- Şifre gizleme/gösterme simgesi bulunacaktır.
- Yeni kullanıcıya örnek görevler otomatik eklenmeyecektir.
- Başarılı kayıtta kullanıcı doğrudan giriş yapmış sayılmayacaktır.
- Giriş sayfasına dönülecek ve “Kaydın oluşturuldu. Şimdi giriş yapabilirsin.” mesajı gösterilecektir.
- Giriş formunda e-posta önceden doldurulabilir; şifre alanı boş kalacaktır.

#### 6.2.5. Şifremi Unuttum: E-posta ve Demo Kod Doğrulama

Bu ekranın ilk adımında açıklama, e-posta alanı ve **Doğrulama Kodu Oluştur** butonu bulunacaktır.
Girilen adres yerel demo hesaplar arasında bulunmuyorsa anlaşılır bir demo hesap hatası gösterilecektir.
Geçerli yerel hesap için altı basamaklı tek kullanımlık bir demo kod oluşturulacaktır.
Gerçek e-posta gönderilmeyecektir.
Ekranda belirgin ama sade bir açıklama bulunacaktır:

> Demo doğrulama: Gerçek e-posta gönderilmez. Deneme kodun aşağıda gösterilir.

- Kod, bu açıklamanın altındaki demo kartında gösterilecektir.
- Kullanıcı kodu ayrı bir alana girecektir.
- **Kodu Doğrula** butonu yalnızca altı basamak girildiğinde kullanılabilir olacaktır.
- Kodun süresi oluşturulduğu andan itibaren beş dakikadır.
- Yeni kod üretildiğinde önceki kod geçersiz olacaktır.
- Yanlış veya süresi geçmiş kod için uygun mesaj gösterilecektir.
- Doğrulama başarılı olmadan **İlerle** butonu etkin olmayacaktır.
- Kod doğrulandıktan sonra yeşil tikli “E-posta doğrulama demosu tamamlandı.” durumu gösterilecektir.
- **İlerle** ile Yeni Şifre Oluştur sayfası açılacaktır.
- Doğrulamadan sonra e-posta değiştirilirse doğrulanmış durum iptal edilecektir.
- Demo kod ve doğrulama yetkisi yalnızca bellekte tutulacaktır.

#### 6.2.6. Yeni Şifre Oluştur Ekranı

Ekranda açıklama, **Yeni Şifre** alanı, **Yeni Şifre Tekrar** alanı ve altta **Kaydet** butonu bulunacaktır.
Her iki alan da zorunlu olacaktır.
Yeni şifre ile tekrarının birebir aynı olması gerekecektir.
Şifre alanlarında görünürlük simgesi bulunacaktır.

- Sayfa yalnızca doğrulanmış ve süresi geçmemiş demo sıfırlama oturumuyla açılabilecektir.
- Doğrulama yetkisi, kod doğrulandığı andan itibaren on dakika geçerli olacaktır.
- Doğrudan sayfayı açmaya çalışmak şifre değiştirmeye izin vermeyecektir.
- Şifreler eşleşmiyorsa ikinci alan altında hata gösterilecektir.
- Kaydet sırasında buton tekrar tıklanamayacaktır.
- Başarılı kayıtta yerel demo parola doğrulayıcısı yeni salt ile değiştirilecektir.
- Mevcut yerel giriş oturumu varsa kapatılacaktır.
- Sıfırlama yetkisi tüketilecek ve tekrar kullanılamayacaktır.
- Gezinme yığını temizlenerek Giriş sayfasına dönülecektir.
- “Şifren güncellendi. Yeni şifrenle giriş yapabilirsin.” mesajı gösterilecektir.
- Bu işlemler, gerçek kimlik doğrulama veya güvenli hesap kurtarma olarak sunulmayacaktır.

#### 6.2.7. Ana Sayfa: Üst Bölüm

Sol üstte küçük uygulama logosu bulunacaktır.
Logonun yanında cihazın yerel saatine göre selamlama ve kullanıcının adı yazacaktır.
Soyadın tamamı profil ekranında gösterilecek; ana sayfada ad kullanılacaktır.
Sağ üstte takvim simgesi ve bildirim simgesi bulunacaktır.
Selamlamanın altında güncel tarih Türkçe biçimlendirmeyle gösterilecektir.

| Yerel saat | Selamlama |
| --- | --- |
| 05.00–10.59 | Günaydın, Hasbiyenur |
| 11.00–16.59 | İyi günler, Hasbiyenur |
| 17.00–21.59 | İyi akşamlar, Hasbiyenur |
| 22.00–04.59 | İyi geceler, Hasbiyenur |

Tarih örneği: **21 Ekim 2026, Çarşamba**.
Örnek ad ve tarih sabit uygulama verisi olarak kullanılmayacaktır.
Selamlama ve tarih, uygulama yeniden ön plana geldiğinde ve ilgili zaman sınırları geçildiğinde yenilenecektir.

#### 6.2.8. Ana Sayfa: Görev Listeleri

Üst bölümün altında günlük özet kartı bulunacaktır.
Örnek metin: **Bugün 5 görevden 3'ünü tamamladın.**
Özet çubuğu, tamamlanan görev sayısının bugüne planlanmış görev sayısına oranını gösterecektir.
Kısmi bar ilerlemesi bu kartta tamamlanmış görev olarak sayılmayacaktır.

Ana içerikte sırasıyla şu bölümler bulunacaktır:

1. **Bugün Yapılacaklar**
2. **Yapılanlar**

- Bugün planlanmamış alışkanlıklar bu sayfada gösterilmeyecektir.
- Başlangıç tarihi gelecekte olan görevler bugün görünmeyecektir.
- Yapılacaklar bölümünde hedef saati artan sırada sıralama kullanılacaktır.
- Aynı hedef saatinde oluşturulma sırası korunacaktır.
- Tamamlanan görev, işlemin hemen ardından Yapılanlar bölümüne taşınacaktır.
- Yapılanlar bölümünde en son tamamlanan görev üstte gösterilecektir.
- Başlıkta tek `lineThrough` çizgisi kullanılacaktır.
- Tamamlanmış kartın yüzeyi ve metni daha soluk olacak, okunabilirlik korunacaktır.
- Tamamlama geri alındığında görev Yapılacaklar bölümüne dönecektir.


#### 6.2.12. Görevler Sayfası

Görevler sayfası bütün aktif alışkanlıkları listeleyecektir.
Bugün planlanmamış alışkanlıklar da bu sayfada görünecektir.
Üstte **Görevlerim** başlığı ve toplam aktif görev sayısı bulunacaktır.
Başlık altında **+ Görev Ekle** butonu bulunacaktır.

Kartlarda görev adı, tekrar açıklaması, başlangıç tarihi, sayaç türü ve aktif streak gösterilecektir.
Örnek tekrar açıklamaları: **Her gün**, **2 günde bir**, **7 günde bir**.
En altta, sabit alt menünün hemen üzerinde **Düzenle** ve **Kaldır** butonları bulunacaktır.
Bu eylem alanı son görevin üstünü kapatmayacaktır.

**Düzenleme modu:**

1. Kullanıcı alttaki Düzenle butonuna basar.
2. Sayfa düzenleme moduna geçer ve “Düzenlemek istediğin görevi seç.” açıklaması görünür.
3. Kullanıcı tek bir görev kartına basar.
4. Form, mevcut değerler doldurulmuş şekilde açılır.
5. Kaydetme başarılı olunca Görevler sayfası güncellenir.
6. **İptal** veya geri işlemi düzenleme modunu kapatır.

**Kaldırma modu:**

1. Kullanıcı Kaldır butonuna basar.
2. Kartların yanında seçim kutuları açılır.
3. Birden fazla görev seçilebilir.
4. Alt eylem alanında **Seçilenleri Kaldır (n)** ve **İptal** görünür.
5. Seçim yokken kaldırma onayı açılmaz.
6. Seçim varsa onay penceresi gösterilir.
7. Onaydan sonra görevler aktif listeden kaldırılır.

Onay metni örneği:

> Seçtiğin 3 alışkanlık listelerinden kaldırılacak. Geçmiş tamamlamaların, rekorların ve kazandığın rozetler korunacak. Devam etmek istiyor musun?

Pencerede **Vazgeç** ve **Kaldır** butonları bulunacaktır.
Kaldırma işlemi veri düzeyinde geçmişi koruyan mantıksal kaldırma olacaktır.
İlk sürümde ayrı bir arşiv veya geri yükleme ekranı bulunmayacaktır.

#### 6.2.13. Görev Ekle / Düzenle Sayfası

Sayfa başlığı moda göre **Görev Ekle** veya **Görevi Düzenle** olacaktır.
Form alanları aşağıdaki sırayla gösterilecektir:

| Sıra | Alan | Zorunluluk / varsayılan |
| --- | --- | --- |
| 1 | Görev adı | Zorunlu, 2–60 karakter |
| 2 | Kısa açıklama | İsteğe bağlı, en fazla 200 karakter |
| 3 | Kaç günde bir? | Zorunlu, varsayılan 1 |
| 4 | Başlangıç tarihi | Zorunlu, varsayılan bugün |
| 5 | Sayaç türü | Tik atma veya bar doldurma |
| 6 | Hedef miktar | Yalnızca bar tipinde zorunlu |
| 7 | Birim | Yalnızca bar tipinde zorunlu; bardak, sayfa, dakika vb. |
| 8 | Artış adımı | Bar tipinde, varsayılan 1 |
| 9 | Günlük hedef saati | Zorunlu, varsayılan 21.00 |
| 10 | Hatırlatma açık/kapalı | Varsayılan açık |
| 11 | Simge | Hazır küçük simge listesinden seçim |
| 12 | Soft vurgu rengi | Hazır paletten seçim |
| 13 | Kaydet | Form geçerliyken kaydeder |

“Kaç günde bir?” alanında 1–365 arasında tam sayı kabul edilecektir.
Bar hedefinde 1–10.000 arasında tam sayı kabul edilecektir.
Artış adımı 1 ile hedef miktar arasında tam sayı olacaktır.
Son artış hedefi aşacaksa değer hedefe sabitlenecektir.
Tik tipi seçildiğinde bar alanları gizlenecek ve doğrulamaya katılmayacaktır.

Yeni görev için geçmiş başlangıç tarihi seçilmeyecektir; bugün veya gelecek tarih seçilecektir.
Formda tekrar planının anlaşılması için sonraki üç görev günü gösterilecektir.
Örnek: **Sonraki günler: 21 Ekim, 23 Ekim, 25 Ekim**.
Hatırlatma açıklaması: **Hedef saatinden 1 saat önce uygulama içinde hatırlatılır.**
Hedef saati 01.00'den erkense hatırlatmanın önceki güne düştüğü ayrıca belirtilecektir.
Kaydetme tamamlanınca önceki sayfaya dönülecek ve kısa bir başarı mesajı gösterilecektir.
Kaydedilen görev yalnızca Görevler sayfasında değil, bugün planlıysa ana sayfada da görünecektir.
Geçmiş kayıtları bulunan bir görevin plan değişiklikleri için 6.7.7 kuralları uygulanacaktır.

#### 6.2.14. Profil Sayfası

Üstte kullanıcı baş harflerinden oluşan avatar ve **Ad Soyad** bulunacaktır.
Altında küçük e-posta bilgisi gösterilebilir.
İlk sürümde profil fotoğrafı yükleme ve ad değiştirme bulunmayacaktır.

İçerik sırası:

1. Kullanıcı bilgileri.
2. **Alışkanlık Serilerim** listesi.
3. Toplam tamamlama, aktif görev sayısı ve en yüksek seri özetleri.
4. **İstatistikler ve Rozetler** kartı.
5. En altta **Çıkış Yap** butonu.

Her aktif görevin yanında kendi streak değeri gösterilecektir.
En yüksek seri kartında seri uzunluğu, görev adı ve rekorun elde edildiği tarih bulunacaktır.
Örnek: **En yüksek seri: 25 — Kitap oku — 21 Ekim 2026**.
Eşit uzunlukta rekorlarda ilk elde edilen tarih gösterilecektir.
Henüz tamamlama yoksa “İlk serini oluşturmak için bir görev tamamla.” metni gösterilecektir.

Çıkış işleminde yerel oturum temizlenecektir.
Görev ve geçmiş kayıtları silinmeyecektir.
Ekran yığını temizlenerek Giriş sayfasına gidilecektir.
Geri tuşuyla kullanıcıya ait ana sayfaya dönülemeyecektir.

#### 6.2.15. İstatistikler ve Rozetler Sayfası

Sayfaya profildeki ilgili karttan ulaşılacaktır.
Üstte **Bu Hafta** ve **Bu Ay** seçimleri bulunacaktır.
Hafta pazartesi başlar; ay takvim ayıdır.
İçinde bulunulan dönemde gelecekteki günler başarı oranı paydasına katılmayacaktır.

Gösterilecek alanlar:

- Seçili dönemde planlanmış alışkanlık tekrarlarının sayısı.
- Seçili dönemde tamamlanmış tekrarların sayısı.
- Tamamlama yüzdesi.
- Yedi günlük basit başarı grafiği.
- Aylık katkı ızgarası.
- Tüm zamanların en yüksek streak değeri.
- Rekorun ait olduğu alışkanlık ve elde edilme tarihi.
- Bronz, gümüş ve altın başarı rozetleri.

| Rozet | Eşik | Görünür başlık |
| --- | --- | --- |
| Bronz | Tek bir alışkanlıkta en az 10 planlı gün serisi | Bronz Başlangıç |
| Gümüş | Tek bir alışkanlıkta en az 25 planlı gün serisi | Gümüş Devamlılık |
| Altın / Gold | Tek bir alışkanlıkta en az 50 planlı gün serisi | Altın İstikrar |

Farklı alışkanlıkların serileri toplanarak eşik hesaplanmayacaktır.
Örneğin 6 günlük iki ayrı alışkanlık bronz rozet sağlamaz.
Kazanılan her seviyenin yanında kazanılma tarihi ve kazandıran görev adı yer alacaktır.
Kazanılmamış rozetler soluk ve kilit simgeli görünecektir.
Kazanılan rozetler sonraki seri bozulmalarında kaybolmayacaktır.
Rozet kalıcılığı ve aynı gün geri alma istisnası 6.7.6 bölümünde tanımlanmıştır.

#### 6.2.16. Takvim Sayfası

Takvime ana sayfanın üstündeki takvim simgesinden ulaşılacaktır.
Üstte ay/yıl başlığı ile önceki ve sonraki ay düğmeleri bulunacaktır.
Hafta günleri **Pzt, Sal, Çar, Per, Cum, Cmt, Paz** şeklinde gösterilecektir.
Takvim pazartesi başlayan yedi sütunlu ızgara olacaktır.

- Varsayılan filtre **Tüm Alışkanlıklar** olacaktır.
- Kullanıcı tek bir aktif alışkanlık seçerek geçmişini inceleyebilecektir.
- Kaldırılmış görevlerin kayıtları Tüm Alışkanlıklar görünümündeki geçmişte korunacaktır.
- Tek görev filtresinde yalnızca o görevin tamamlandığı günler işaretlenecektir.
- Tüm Alışkanlıklar filtresinde en az bir tamamlanmış görev varsa gün işaretlenecektir.
- Hiç tamamlama olmayan günler doldurulmayacaktır.
- Kısmi bar ilerlemesi, tamamlanmış gün işareti oluşturmayacaktır.
- Bugün ince bir çerçeveyle, seçili gün ayrı bir dış çerçeveyle belirtilecektir.
- Bugün çerçevesi başarı işareti olarak sayılmayacaktır.
- Gelecek günlerde tamamlanma işareti gösterilmeyecektir.
- Bir güne basıldığında altta o tarihin görevleri ve tamamlanma durumları okunur biçimde listelenecektir.
- Geçmiş tarihlerin kayıtları bu sayfadan değiştirilemeyecektir.
- Tamamen boş bir ay da hatasız görüntülenecektir.


### 6.3. Mimari ve Dosya Yapısı

Proje tek Flutter kökünde geliştirilir. `lib/` altında ekranlar, modeller, servisler ve ortak bileşenler ayrılır. Platform klasörleri `flutter create` çıktısından gelir; sırf listede göründükleri için elle oluşturulmaz.

```text
aliskanlik_takibi/
  README.md
  pubspec.yaml
  lib/
    main.dart
    app/
      app.dart
      bootstrap_screen.dart
      main_shell.dart
      app_providers.dart
    core/
      theme/
        app_theme.dart
        app_colors.dart
      time/
        app_clock.dart
        date_key.dart
      storage/
        local_store.dart
        store_document.dart
      security/
        demo_password_service.dart
      widgets/
        app_logo.dart
        app_text_field.dart
        primary_button.dart
    data/
      models/
        app_user.dart
        habit.dart
        habit_schedule.dart
        habit_entry.dart
        achievement.dart
        habit_reminder.dart
      repositories/
        auth_repository.dart
        habit_repository.dart
        local_auth_repository.dart
        local_habit_repository.dart
      demo/
        demo_seed.dart
    features/
      auth/
        auth_controller.dart
        screens/
          login_screen.dart
          register_screen.dart
          forgot_password_screen.dart
          reset_password_screen.dart
      habits/
        habit_controller.dart
        services/
          schedule_service.dart
          streak_service.dart
        screens/
          habits_screen.dart
          habit_form_screen.dart
        widgets/
          habit_card.dart
          progress_counter.dart
      home/
        screens/home_screen.dart
      notifications/
        reminder_service.dart
        notification_controller.dart
      profile/
        screens/profile_screen.dart
      statistics/
        statistics_service.dart
        achievement_service.dart
        screens/statistics_screen.dart
      calendar/
        screens/calendar_screen.dart
  test/
    schedule_service_test.dart
    streak_service_test.dart
    habit_flow_test.dart
```

`auth_controller.dart` oturum akışını; `habit_controller.dart` görev değişimlerini yönetir. Hesaplama servisleri tarih, seri, rozet ve istatistikleri ekrandan bağımsız hesaplar. Repository sınıfları yerel veri erişimini soyutlar.


### 6.4. Tarih, Tamamlama ve Seri Kuralları

#### 6.4.1. Tekrar Planının Hesaplanması

Bir alışkanlık, seçilen başlangıç tarihinden itibaren her N takvim gününde bir planlanır.
Hesap yerel saatte geçen saniyelere göre değil, takvim günü bileşenlerine göre yapılır.

```text
1. İstenen tarih için geçerli HabitSchedule sürümünü bul.
2. Tarih, anchorDateKey değerinden önceyse planlı değildir.
3. Gün farkını DateTime.utc(yıl, ay, gün) değerleri arasında hesapla.
4. günFarkı % intervalDays == 0 ise o gün planlıdır.
5. Kaldırma iptali veya sürüm sınırı varsa ilgili istisnayı uygula.
```

Örnek başlangıç: **21 Ekim 2026**.

| Aralık | Planlı günler |
| --- | --- |
| 1 | 21, 22, 23, 24, 25 Ekim… |
| 2 | 21, 23, 25, 27, 29 Ekim… |
| 3 | 21, 24, 27, 30 Ekim… |
| 7 | 21 Ekim, 28 Ekim, 4 Kasım… |

Aralık her tamamlamada ileri kaydırılmaz.
Kullanıcı 23 Ekim'deki görevi geç saatte tamamlasa da sonraki planlı tarih 25 Ekim olarak kalır.
“2 günde bir” ifadesi her ikinci takvim gününü kapsar; bir gün yapıp bir gün ara vermektir.

##### 6.4.2. Günlük Tamamlama Sınırı

- Görev yalnızca kendi planlı gününde tamamlanabilir.
- Geçmiş ve gelecek tarihe yeni tamamlama yazılamaz.
- Gün, cihazın yerel saatinde 00.00'da başlar ve sonraki günün 00.00 anında kapanır.
- Hedef saati hatırlatma ve sıralama içindir; sert bir son teslim saati değildir.
- Hedef saatini geçen görev, aynı takvim günü bitene kadar tamamlanabilir.
- Süresi geçmiş bir gün, ertesi gün yeniden yapılacak listesine taşınmaz.
- Yeni günün kartı aynı alışkanlığa ait yeni günlük kayıtla başlar.
- Önceki günün kısmi bar değeri yeni güne aktarılmaz.
- Kaldırılmış alışkanlığa yeni ilerleme yazılamaz.

##### 6.4.3. Aktif Streak

Streak, aynı plan sürümü içinde art arda tamamlanan planlı günlerin sayısıdır.
Planlanmamış ara günler değerlendirmeye katılmaz.
Bugün planlı fakat henüz tamamlanmamışsa gün kapanmadan seri sıfırlanmaz.
Son kapanmış planlı gün kaçırılmışsa aktif seri sıfırdır.
Kaçırılan günden sonraki ilk tamamlama yeni bir seriyi 1'den başlatır.
Bugün planlı değilse son geçerli seri, sonraki planlı gün kapanana kadar korunur.

| Senaryo | Sonuç |
| --- | --- |
| Her gün yapılan görev, üç gün üst üste tamamlandı | Seri 3 |
| Dördüncü gün henüz sabah ve görev tamamlanmadı | Seri hâlâ 3 |
| Dördüncü gün tamamlandı | Seri 4 |
| Dördüncü gün hiç tamamlanmadan beşinci güne geçildi | Seri 0 |
| Beşinci gün tamamlandı | Yeni seri 1 |
| 21, 23 ve 25 Ekim'e planlı görev, üçünde de tamamlandı | Seri 3 |
| Aynı görevde 22 ve 24 Ekim'de kayıt yok | Seri bozulmaz |
| Aynı görevde 27 Ekim kaçırıldı; 28 Ekim oldu | Seri 0 |

Günlük olmayan görevlerde bilgi simgesi açıklaması gösterilecektir:
**Seri, art arda tamamladığın planlı günleri sayar. Ara günler seriyi bozmaz.**
Uygulamanın kapalı olması seri hesabını değiştirmez; açılışta tarih ve kayıtlar üzerinden yeniden hesaplanır.


##### 6.4.5. Tik ve Bar Davranışı

Tik tipinde tamamlanmamış değer 0, tamamlanmış değer 1'dir.
Bar tipinde tamamlanma koşulu `progressValue >= targetValue` olur; saklanan değer hedefe sınırlandırılır.
Hedefe ilk kez ulaşıldığında `completedAtUtc` yazılır.
Aynı tamamlanmış değeri yeniden kaydetmek ek seri veya istatistik artışı oluşturmaz.
Geri alma aynı gün içinde günlük kaydı değiştirir ve bütün özetleri yeniden hesaplatır.
Geri alma geçmiş günlere uygulanmaz.

##### 6.4.6. Rozet Hesaplama ve Geri Alma

- Rozetler bir alışkanlığın tek bir kesintisiz serisine göre değerlendirilir.
- 10'a ulaşınca bronz, 25'e ulaşınca gümüş, 50'ye ulaşınca altın kazanılır.
- Yeni seviyeye ulaşılması önceki seviyeleri gizlemez.
- Aktif seri daha sonra bozulsa bile geçmişteki başarı dizisi varlığını korur; rozet kaybolmaz.
- Görev kaldırılırsa geçmiş kayıtlar korunduğu için rozet de korunur.
- Aynı günkü bir tamamlama geri alınıp eşiği karşılayan tek geçmiş dizi ortadan kalkarsa yeni rozet de geri alınır.
- Kullanıcının başka geçerli bir eski dizisi varsa rozet korunur.
- Böylece yanlışlıkla tamamla/geri al işlemi kalıcı ve dayanıksız bir rozet üretmez.
- Her seviyenin ilk geçerli kazanılma tarihi kaydedilir.
- Demo seed dışında geçmiş kayıtlar elle üretilerek kullanıcıya rozet verilmez.
- Birden fazla yeni seviye algılanırsa bütün eksik rozetler tek geçişte eklenir.

##### 6.4.7. Görev Düzenlemenin Geçmişe Etkisi

Başlık, açıklama, simge ve renk değişiklikleri mevcut görev nesnesine hemen uygulanır.
Tekrar aralığı, başlangıç, sayaç türü, hedef miktar, birim, adım, hedef saati ve hatırlatma tercihi plan alanlarıdır.
Takip geçmişi başlamış görevlerde bu alanlar değiştirilirse yeni plan sürümü oluşturulur.
Yeni sürüm en erken yarın yürürlüğe girer.
Kullanıcının seçtiği yeni başlangıç, yarından daha ileride olabilir.
Bu durumda sürüm yarın yürürlüğe girer; ilk planlı gün seçilen yeni başlangıçtır.

Formda şu açıklama gösterilecektir:
**Plan değişikliklerin yarından itibaren geçerli olur. Önceki kayıtların korunur ve yeni plan için seri yeniden başlar.**

Bugünün görevi eski planıyla tamamlanabilir; geçmiş kayıtlar eski plan sürümüne bağlı kalır.
Henüz başlamamış, geçmiş planlı günü ve günlük kaydı olmayan bir görevde ilk plan doğrudan düzenlenebilir.
Aynı görev için yarına kaydedilmiş bir değişiklik tekrar düzenlenirse yeni kopya eklemek yerine bekleyen sürüm güncellenir.
Bir alışkanlıkta aynı `effectiveFromDateKey` için iki sürüm bulunmaz.
Bu sürümleme yaklaşımı geçmiş hedef miktarının veya tekrar aralığının sonradan değişmesini önler.

##### 6.4.8. Kaldırmanın Takvime ve Oranlara Etkisi

Kaldırma, `archivedAtUtc` ve kaldırma anının yerel `archivedOnDateKey` alanlarını doldurur.
Görev ana sayfadan, aktif görevlerden ve aktif seri listesinden çıkar.
Kaldırmadan önceki günlerin planları ve tamamlamaları geçmiş istatistiklerde kalır.
Kaldırıldığı gün zaten tamamlanmışsa o günkü başarı korunur ve paydada tutulur.
Kaldırıldığı gün tamamlanmamış veya kısmen ilerlenmişse o günün bekleyen tekrarını iptal edilmiş say.
İptal edilmiş tekrar dönemin paydasına veya takvimde yapılması gereken iş listesine eklenmez.
Kaldırma gününden sonraki tarihlerde yeni tekrar oluşmaz.
Geçmiş günlük kayıtlar ve rozetler fiziksel olarak silinmez.

##### 6.4.9. İstatistik Formülleri

```text
Tamamlama yüzdesi = tamamlanan planlı tekrar / uygun planlı tekrar × 100
Günlük özet = bugün tamamlanan görev / bugün planlı görev × 100
Bar yüzdesi = mevcut miktar / hedef miktar × 100
```

Payda sıfırsa yüzde 0 gösterilir ve “Bu dönemde planlı görev yok.” açıklaması eklenir.
Yüzdeler arayüzde en yakın tam sayıya yuvarlanabilir; kaynak sayılar değişmez.
Kısmi bar ilerlemesi tamamlanan tekrar sayısını artırmaz.
Aktif dönemde bugünün planlı görevleri paydaya girer; yarın ve sonraki günler girmez.
Haftalık ve aylık oran, günlük yüzdelerin ortalamasıyla değil toplam sayılardan hesaplanır.
Aylık ızgarada renk yoğunluğu o günün tamamlama oranına göre değişebilir; sıfır tamamlamada başarı dolgusu olmaz.


### 6.5. Yerel Saklama ve Oturum

#### 6.5.1. Saklama Şeması

Yerel depoda uygulamaya ait tek kök anahtar kullanılacaktır: `habit_tracker_store_v1`.
Değer, JSON'a dönüştürülmüş `StoreDocument` olacaktır.
Başlangıç yapısı:

```json
{
  "schemaVersion": 1,
  "activeUserId": null,
  "demoSeedVersion": 0,
  "users": [],
  "habits": [],
  "entries": [],
  "achievements": [],
  "reminders": []
}
```

Başka uygulamalara veya paketlere ait anahtarlar temizlenmeyecektir.
Çıkış sırasında bütün depoyu temizleyen bir `clear()` çağrısı yapılmayacaktır.
Normal veri değişikliklerinde yalnızca bu doküman güncellenecektir.



Her veri okuma ve yazma işlemi etkin kullanıcı kimliğiyle sınırlandırılır.
Bir hesaptaki görev kimliği başka hesaba aitse repository işlemi reddeder.
Ekranda filtreleme yapılmış olması tek başına yeterli sayılmaz.
Çıkışta controller'lardaki kullanıcı listeleri, seçimler, açık pencereler ve zamanlı kontrol bağları temizlenir.
Girişte yalnızca yeni etkin hesabın verileri yüklenir.
Yerel veri dosyası cihaz kullanıcısının erişimine karşı bir güvenlik sınırı değildir.


### 6.6. Uygulama ve Teslim Sırası

1. Tema, logo, gezinme ve ekran iskeletlerini oluştur.
2. Modelleri, yerel saklamayı ve demo kimlik akışını tamamla.
3. Görev ekleme/düzenleme, tekrar ve günlük tamamlama akışını bağla.
4. Seri, rozet, istatistik, takvim ve uygulama içi hatırlatmayı ekle.
5. Temel tarih sınırlarını, aynı gün geri almayı ve yeniden açılışı doğrula.
6. `flutter analyze` ve `flutter test` çalıştır; README ile demo sınırlarını yaz.


## 7. Antigravity İçin Uygulama Talimatı

Bu dosyayı Flutter projesinin köküne yerleştir.
Antigravity'de aşağıdaki metni, dosya adıyla birlikte uygulama isteği olarak kullanabilirsin.
Dosya tek başına ekran örneği değil, çalışan frontend uygulamasının şartnamesidir.

```text
Bu projeyi ALISKANLIK_TAKIBI_PROJE_PLANI.md dosyasındaki şartnameye göre geliştir.
Önce belgenin tamamını, mevcut proje dosyalarını ve pubspec.yaml içeriğini oku.
Proje zaten Flutter projesiyse mevcut kökü kullan; iç içe yeni Flutter projesi oluşturma.
Boş klasörse Flutter projesini aliskanlik_takibi adıyla mevcut kökte oluştur.

Flutter ve Dart kullan. Backend, Firebase, Supabase veya gerçek e-posta servisi ekleme.
Türkçe arayüz, Material 3 ve belgede verilen soft renk paletini uygula.
Logo, takvim, grafik ve rozetleri hafif yerel Flutter bileşenleriyle oluştur.
Çalışmak için internetten font veya logo indirme.
provider + ChangeNotifier kullan; ikinci durum yönetimi sistemi ekleme.
Verileri SharedPreferencesAsync ile küçük bir yerel JSON dokümanında sakla.
Giriş/kayıt/şifre yenilemeyi açıkça etiketlenmiş yerel demo olarak geliştir.
Gerçek kullanıcı parolasını kaynak koda, JSON'a veya loglara açık metin yazma.
PBKDF2 işlemlerinin arayüzü kilitlememesini sağla.

Belgedeki 10 kullanıcı sayfasını, açılış ekranını ve üç sekmeli MainShell'i oluştur.
Ekleme ve düzenlemede aynı görev formunu kullan.
Bugünün görevlerini cihazın yerel tarihinden hesapla; sabit tarih yazma.
Tik ve miktar/bar kontrollerini kalıcı kayıtlarla çalıştır.
Tamamlanan kartı Yapılanlar'a taşı, başlığını tek çizgiyle çiz ve daha soluk göster.
Seriyi yalnızca planlı günlere göre hesapla; ara günlerde bozma.
Hedef saatini sert son teslim saati olarak kullanma; gün bitene kadar tamamlamaya izin ver.
Plan değişikliklerinde geçmişi koruyan sürüm kurallarını uygula.
Kaldırmayı onaylı ve geçmişi koruyan mantıksal kaldırma olarak uygula.
10, 25 ve 50 seri rozetlerini gerçek yerel kayıtlardan hesapla.
Profil, takvim ve istatistiklerde aynı veri kaynağını kullan.
Bildirimleri yalnızca uygulama içinde, tanımlı zaman penceresinde ve kopyasız oluştur.
Uygulama kapalıyken gerçek sistem bildirimi gönderiyormuş gibi davranma.

6.3 bölümündeki dosya düzenini ve 6.6 bölümündeki geliştirme sırasını izle.
Geçişleri bağlanmamış, onPressed'i boş veya sadece görüntüden ibaret kontrol bırakma.
Her aşamayı çalışır duruma getirdikten sonra sonraki aşamaya geç.
Gereksiz kod üretim araçları, servisler veya ağır paketler ekleme.
Derleme sorunu olursa hata çıktısını incele; platform klasörlerini rastgele silme.
Kritik tarih, seri ve kullanıcı akışlarını test et.
Kod biçimlendirmesini, flutter analyze ve flutter test kontrollerini çalıştır.
Erişilebilir bir hedefte uygulamayı açarak ana senaryoyu doğrula.
Hedef cihaz yoksa kontrol edemediğin platformu açıkça belirt.
Son olarak README'ye kurulum, demo hesap, çalıştırma ve demo sınırlarını yaz.
Teslimde tamamlanan özellikleri ve varsa kalan gerçek kısıtları kısa şekilde raporla.
```
