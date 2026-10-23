# Alışkanlık Takibi (Habit Tracker)

> **Proje:** `aliskanlik_takibi` — Flutter ve Dart ile geliştirilecek Türkçe mobil frontend uygulaması.
> **Kapsam:** Backend olmadan çalışan yerel demo; görevler ve ilerleme cihazda saklanır.
> **Tasarım:** Soft renkler, sade kartlar, açık/koyu tema ve neon içermeyen bir arayüz.
> **Kullanım:** Bu belge Antigravity için ekran, iş kuralı ve uygulama planıdır.

## İçindekiler

1. [Proje Özeti](#1-proje-özeti)
2. [Proje Amacı](#2-proje-amacı)
3. [Ekran ve Sayfa Sayısı](#3-tahmini-ekran-ve-sayfa-sayısı)
4. [Temel Özellikler](#4-temel-özellikler)
5. [Hedef Kitle ve Kapsam](#5-hedef-kitle-ve-kapsam)
6. [Öğrenci Çalışma ve Detay Alanı](#6-öğrenci-çalışma-ve-detay-alanı)
   - [6.1. Teknolojiler](#61-kullanılacak-teknolojiler-ve-kütüphaneler)
   - [6.2. Ekranlar ve Akışlar](#62-sayfa-hiyerarşisi-ve-akış-planı)
   - [6.3. Veri Modelleri](#63-veri-modeli-ve-bileşen-tasarımı)
   - [6.4. Geliştirme Aşamaları](#64-proje-takvimi-ve-teslim-aşamaları)
   - [6.5. Notlar ve Zorluklar](#65-notlar-ve-karşılaşılabilecek-zorluklar)
   - [6.6. Dosya Yapısı](#66-mimari-klasörler-ve-dosya-sorumlulukları)
   - [6.7. Tarih ve Streak](#67-tarih-tekrar-tamamlama-ve-streak-kuralları)
   - [6.8. Yerel Veri](#68-yerel-veri-saklama-ve-oturum-yönetimi)
   - [6.9. Tema](#69-tema-ve-görsel-tasarım)
   - [6.10. Hatırlatmalar](#610-uygulama-içi-hatırlatmalar)
   - [6.11. Form Kuralları](#611-form-doğrulamaları)
   - [6.12. Demo Veriler](#612-örnek-veriler-ve-demo-senaryosu)
   - [6.13. Kullanılabilirlik](#613-erişilebilirlik-performans-ve-platformlar)
   - [6.14. Testler](#614-test-planı)
   - [6.15. Teslim Kontrolü](#615-teslim-kontrol-listesi)
7. [Antigravity Talimatı](#7-antigravity-için-uygulama-talimatı)
8. [Gelecek Özellikler](#8-ileride-eklenebilecek-özellikler)
9. [Teknik Kaynaklar](#9-teknik-kaynaklar)

---

## 1. Proje Özeti

Alışkanlık Takibi; kitap okuma, su içme, spor ve ders çalışma gibi davranışları düzenli takip etmeyi sağlar. Kullanıcı bir görev oluşturur, hangi aralıklarla yapılacağını belirler ve planlanan günlerde ilerlemesini kaydeder.

Ana sayfa cihazın güncel tarihine göre bugünün görevlerini gösterir. Tamamlananlar, başlıkları tek çizgiyle çizilmiş ve daha soluk biçimde **Yapılanlar** bölümüne taşınır. Her alışkanlığın ayrı streak değeri ve takvim rengi bulunur. Alt menünün üstündeki maskot belirli aralıklarla motivasyon cümleleri gösterir; görev tamamlandığında kısa bir mesaj veya görsel efektle kullanıcı cesaretlendirilir. Takvim, istatistikler ve başarı rozetleri ilerlemeyi görünür kılar.

Geri alınan görev bütün ekranlarda tamamlanmamış hâle döner ve yeniden tamamlandığında kutlama tekrar çalışır. Görev düzenlemek seriyi sıfırlamaz. Ana sayfadaki avatar Profil'e, profilin sağ üstündeki ayarlar simgesi Ayarlar'a götürür. Alt menünün üçüncü sekmesi çalışma ve mola döngüsü ile geçmiş sunan **Pomodoro** ekranıdır.

İlk sürümde backend bulunmaz. Kayıt, giriş ve şifre yenileme yerel demo akışlarıdır; gerçek e-posta gönderilmez. Görevler ve geçmiş normal yeniden açılışta korunur; uygulama verileri silindiğinde kaybolabilir.

**Terimler:** “Görev” ve “alışkanlık” aynı nesnedir. Streak, aralıksız tamamlanan **planlı günlerin sayısıdır**; günlük olmayan görevlerde ara günler seriyi bozmaz.

## 2. Proje Amacı

- Günlük alışkanlıkları tek ekranda toplamak ve tamamlamayı kolaylaştırmak.
- Küçük hedeflerle düzenli davranış geliştirmeyi desteklemek.
- Streak, motive edici hatırlatma ve rozetlerle devamlılığı görünür kılmak.
- Takvim ve haftalık/aylık istatistiklerle ilerlemeyi göstermek.
- Flutter'da ekran yönetimi, form doğrulama, ortak durum ve yerel veri saklama pratiği yapmak.

**Başarı ölçütü:** Kullanıcı giriş yapabilmeli, görev oluşturup tamamlayabilmeli ve aynı sonucu ana sayfa, profil, takvim ve istatistiklerde görebilmelidir. Aynı görev aynı gün iki kez sayılmamalıdır.

## 3. Tahmini Ekran ve Sayfa Sayısı

Senaryoya göre **12 kullanıcı sayfası ve 1 teknik açılış ekranı** bulunacaktır. Ekleme ve düzenleme aynı formu paylaşır; e-posta ve kod doğrulama tek sayfada iki adımdır. Şifre değiştirme ve hazır avatar seçimi Ayarlar sayfasında, süre düzenleme Pomodoro sayfasında yapılır; bunlar ek sayfa sayılmaz.

| Sayfa | Dosya | İşlev |
| --- | --- | --- |
| Giriş | `login_screen.dart` | E-posta ve şifreyle giriş |
| Kaydol | `register_screen.dart` | Yerel demo hesap oluşturma |
| Şifremi Unuttum | `forgot_password_screen.dart` | E-posta ve demo kod doğrulama |
| Yeni Şifre | `reset_password_screen.dart` | Şifreyi iki kez girerek kaydetme |
| Ana Sayfa | `home_screen.dart` | Bugünün görevleri ve yapılanlar |
| Görevler | `habits_screen.dart` | Listeleme, düzenleme ve kaldırma |
| Görev Ekle / Düzenle | `habit_form_screen.dart` | Görev bilgilerini kaydetme |
| Profil | `profile_screen.dart` | Seçili avatar, kullanıcı, seriler, Ayarlar erişimi ve çıkış |
| Ayarlar | `settings_screen.dart` | Avatar seçimi, açık/koyu tema, şifre değiştirme ve motivasyon tercihleri |
| Pomodoro | `pomodoro_screen.dart` | Çalışma/mola zamanlayıcısı ve oturum geçmişi |
| İstatistikler ve Rozetler | `statistics_screen.dart` | Oranlar, rekor ve başarılar |
| Takvim | `calendar_screen.dart` | Tamamlanan günler |
| Teknik açılış | `bootstrap_screen.dart` | Yerel verileri ve oturumu yükleme |

Bildirim listesi ve kaldırma onayı ayrı sayfa değil, pencere olacaktır. Maskot, konuşma balonu ve tamamlama kutlaması mevcut ekranların üzerinde gösterilen bileşenlerdir; yeni sayfa gerektirmez.

**Sabit alt menü:** Ana Sayfa — Görevler — Pomodoro. Üçüncü sekmede zamanlayıcı ikonu ve **Pomodoro** etiketi bulunur; alt menüde Profil yer almaz. Üç sekme `MainShell` içinde açılır. Ana sayfanın sağ üstünde soldan sağa **Takvim — Bildirim — Profil Avatarı** sıralaması kullanılır. Avatar Profil'i, profilin sağ üstündeki dişli Ayarlar'ı açar. İstatistikler profilden, görev formu Görevler sayfasından açılır. Kimlik ekranlarında alt menü bulunmaz; Profil, Ayarlar ve diğer yardımcı sayfalarda geri düğmesi kullanılır.

## 4. Temel Özellikler

- Yerel kayıt, giriş, çıkış ve demo şifre yenileme.
- Saat dilimine göre selamlama ve kullanıcı adı.
- Başlangıç tarihi ve tekrar aralığına göre günlük görevler.
- Tik veya miktar/bar ile tamamlama ve aynı gün geri alma.
- Geri almada kart, takvim ve istatistiklerin birlikte düzelmesi; yeniden tamamlamada efektin yeniden çalışması.
- Görev başına aktif seri ve tüm zamanların en yüksek serisi.
- Görev düzenlenirken mevcut streak ve geçmişin korunması.
- Görev ekleme, düzenleme ve onaylı çoklu kaldırma.
- Hedef saatinden bir saat önce uygulama içi hatırlatma.
- Profil, takvim, haftalık/aylık istatistikler ve 10/25/50 seri rozetleri.
- Takvimde her görevin kendine ait farklı soft renkle gösterilmesi.
- Sağ altta, alt menünün üstünde belirli aralıklarla motivasyon veren maskot.
- Görev tamamlandığında üstten kısa mesaj veya kısa süreli parıltı/alev efekti.
- İsteğe bağlı Hugging Face mesaj kaynağı ve çevrimdışı motivasyon havuzu.
- Cihazda kalıcı demo verileri ve soft renkli arayüz.
- Profil üzerinden açılan, seçenekleri alt alta yerleştirilmiş Ayarlar sayfası.
- Kalıcı açık/koyu tema, oturum içinden şifre değiştirme ve ayarlara taşınmış motivasyon tercihleri.
- Ayarlar üzerinden sınırlı sayıdaki çizgi film tarzı insan/hayvan avatarından seçim ve ana sayfadan profile erişim.
- Pomodoro sayfasında kişiselleştirilebilir çalışma, kısa mola ve uzun mola süreleri; zamanlayıcı kontrolleri ve aşağı kaydırıldığında görülen çalışma geçmişi.

Gerçek e-posta doğrulaması, cihazlar arası senkronizasyon ve uygulama kapalıyken sistem bildirimi bu sürümün kapsamı dışındadır.

## 5. Hedef Kitle ve Kapsam

Hedef kitle; öğrenciler, düzenli çalışma alışkanlığı edinmek isteyenler ve kişisel hedeflerini basit bir uygulamayla takip etmek isteyen kullanıcılardır.

İlk sürümde sosyal ağ, arkadaş sistemi, ödeme, abonelik, reklam ve kamera/konum izinleri bulunmaz. Geçmiş günlere sonradan tamamlama eklenmez; yalnızca bugünün ilerlemesi değiştirilebilir. Kaldırılan görevlerin geçmiş tamamlamaları, rekorları ve rozetleri korunur.

---

## 6. Öğrenci Çalışma ve Detay Alanı

### 6.1. Kullanılacak Teknolojiler ve Kütüphaneler

| Alan | Seçim |
| --- | --- |
| Dil ve arayüz | Dart, Flutter, Material 3 |
| Durum yönetimi | `provider` + `ChangeNotifier` |
| Yerel veri | `shared_preferences` üzerinden `SharedPreferencesAsync` ve JSON |
| Türkçe tarih | `intl` ve `flutter_localizations` |
| Demo parola doğrulayıcı | `cryptography` |
| Gezinme | `Navigator` + `MaterialPageRoute` |
| Test | `flutter_test` |
| Maskot ve kutlama | Flutter `Stack`, `Overlay`, `AnimationController` ve gerektiğinde `CustomPainter` |
| Tema ve avatar | `ThemeData`, `ThemeMode` ve yerel hazır avatar kataloğu |
| Pomodoro | `AppClock`, kalıcı bitiş zamanı ve ekran yenilemesi için hafif zamanlayıcı |
| İsteğe bağlı mesaj kaynağı | Hugging Face üzerindeki herkese açık metin verisine erişim için `http` |

Kurulu Flutter SDK ile uyumlu paketler kullanılacak ve çözümlenen sürümler `pubspec.lock` ile korunacaktır. Mevcut projedeki bağımlılıklar gereksiz yere yükseltilmeyecektir.

```bash
flutter pub add provider shared_preferences intl cryptography
flutter pub add flutter_localizations --sdk=flutter
flutter pub get
```

- Uygulama Türkçe locale ve yerelleştirme delegeleriyle açılır; tarih biçimleri için `tr_TR` verileri hazırlanır.
- Logo, rozet, takvim ve basit grafikler Flutter bileşenleriyle oluşturulur; çalışma anında font/görsel indirilmez.
- Firebase, Supabase, özel backend, ikinci durum yönetimi veya kod üretim aracı eklenmez. Yalnızca isteğe bağlı motivasyon verisi indirmesi için HTTP istemcisi kullanılabilir; uygulamanın temel işlevleri buna bağlı olmaz.
- `http` paketi sadece Hugging Face veri kaynağı uygulanırsa eklenir. Maskot ve efektler için ağır animasyon paketi zorunlu değildir.
- `shared_preferences` yalnızca küçük, kaybı tolere edilebilir demo veri kümesi içindir; güvenli veya kritik kayıt sistemi değildir.

### 6.2. Sayfa Hiyerarşisi ve Akış Planı

#### 6.2.1. Açılış ve Gezinme

| İşlem | Sonuç |
| --- | --- |
| Açılış, oturum yok | Giriş |
| Açılış, geçerli yerel oturum var | Ana Sayfa |
| Kaydol başarılı | Giriş; otomatik oturum açılmaz |
| Şifremi Unuttum, kod doğrulandı ve İlerle seçildi | Yeni Şifre |
| Yeni şifre kaydedildi | Giriş |
| Giriş başarılı | Ana Sayfa; kimlik sayfaları yığından çıkarılır |
| Ana sayfa sağ üst avatar | Profil |
| Profil sağ üst dişli | Ayarlar |
| Alt menü zamanlayıcı ikonu | Pomodoro |
| Ayarlar geri / Profil geri | Sırasıyla Profil / Ana Sayfa |
| Çıkış | Giriş; korumalı ekranlara geri dönülemez |

Açılışta veriler yüklenirken logo ve küçük yükleme göstergesi bulunur. Okuma hatasında tekrar deneme sunulur; veri sessizce sıfırlanmaz.

#### 6.2.2. Giriş Ekranı

Üst ortada logo, altında uygulama adı ve kısa bir motivasyon metni bulunur. Form sırası:

1. E-posta.
2. Şifre ve görünürlük simgesi.
3. Şifrenin altında sağa hizalı **Şifremi unuttum**.
4. **Giriş Yap**.
5. **Kaydol**.

Alan hataları anlaşılır gösterilir. İşlem sürerken buton yükleme durumuna geçer ve çift gönderim engellenir. Alt açıklama: **Demo sürümü — hesaplar bu cihazda tutulur. Yalnızca deneme parolası kullan.**

#### 6.2.3. Kaydol Ekranı

Üstte aynı logo; altında zorunlu **Ad, Soyad, E-posta, Şifre** alanları ve **Kaydol** butonu bulunur. Ayrıca Giriş sayfasına dönüş bağlantısı yer alır.

- Türkçe karakterler ve birleşik soyadları kabul edilir.
- E-posta boşlukları temizlenip küçük harfe çevrilerek karşılaştırılır; aynı adresle ikinci yerel hesap açılmaz.
- Şifre gizlenebilir/gösterilebilir.
- Başarılı kayıt Giriş sayfasına döner: “Kaydın oluşturuldu. Şimdi giriş yapabilirsin.”
- E-posta önceden doldurulabilir; şifre boş kalır. Yeni hesap örnek görevlerle doldurulmaz.

#### 6.2.4. Şifremi Unuttum

1. Kullanıcı yerel hesabına ait e-postayı girer.
2. **Doğrulama Kodu Oluştur** ile altı basamaklı demo kod üretilir.
3. Kod ekrandaki demo kartında gösterilir; gerçek e-posta gönderilmez.
4. Kullanıcı kodu girip **Kodu Doğrula** seçer.
5. Doğrulama başarılı olduğunda **İlerle** etkinleşir ve Yeni Şifre sayfasını açar.

Açıklama: **Demo doğrulama: Gerçek e-posta gönderilmez. Deneme kodun aşağıda gösterilir.**

Kod beş dakika geçerlidir. Yeni kod eskisini iptal eder; e-posta değişirse doğrulanmış durum temizlenir. Yanlış/süresi geçmiş kodla ilerlenemez. Kod ve doğrulama yetkisi yalnızca bellekte tutulur.

#### 6.2.5. Yeni Şifre Oluştur

**Yeni Şifre**, **Yeni Şifre Tekrar** ve **Kaydet** bulunur. İki alan da zorunludur ve birebir eşleşmelidir.

- Ekran yalnızca doğrulanmış demo sıfırlama oturumuyla kullanılabilir; bu yetki on dakika geçerlidir.
- Kaydet, yerel parola doğrulayıcısını yeni salt ile değiştirir; mevcut oturumu kapatır ve sıfırlama yetkisini tüketir.
- Başarılı işlemden sonra yığın temizlenir, Giriş açılır ve başarı mesajı gösterilir.
- Akış iptal edilirse veya uygulama kapanırsa doğrulamaya yeniden başlanır.

#### 6.2.6. Ana Sayfa

Sol üstte logo, yanında saate uygun selamlama ve kullanıcının adı bulunur. Sağ üstte soldan sağa **takvim simgesi, bildirim simgesi, seçili profil avatarı** yer alır. Avatar yaklaşık 32–40 px görünür, dokunma alanı en az 48 px olur; basıldığında Profil açılır. Ayarlar üzerinden avatar değiştiğinde burası ve Profil anında güncellenir. Altında güncel tarih Türkçe gösterilir.

| Yerel saat | Selamlama |
| --- | --- |
| 05.00–10.59 | Günaydın, [Ad] |
| 11.00–16.59 | İyi günler, [Ad] |
| 17.00–21.59 | İyi akşamlar, [Ad] |
| 22.00–04.59 | İyi geceler, [Ad] |

Günlük özet kartı **Bugün 5 görevden 3'ünü tamamladın** biçiminde bilgi ve oran çubuğu gösterir. Altında **Bugün Yapılacaklar**, ardından **Yapılanlar** bulunur.

- Yalnızca bugüne planlanmış görevler gösterilir; yapılacaklar hedef saatine göre sıralanır.
- Tamamlanan kart alta taşınır; başlık tek çizgiyle çizilir ve kart daha soluk görünür.
- Yapılanlarda en son tamamlanan üstte olur. Geri alınan görev yapılacaklara işaretsiz, üstü çizilmemiş ve normal renkte döner; Görevler sayfasındaki bugünkü durumu da tamamlanmamış olur.
- Kartta simge, başlık, varsa açıklama, hedef saati, sayaç kontrolü ve streak simgesi/sayısı bulunur.
- Tik görevinde checkbox; bar görevinde **− / +**, mevcut/hedef miktar ve ilerleme çubuğu kullanılır.
- Bar hedefe ulaşınca otomatik tamamlanır; azaltılınca tamamlanmamış hâle döner.
- Kısmi bar ilerlemesi günlük özette tamamlanmış görev sayılmaz.
- Tamamlama başarıyla kaydedildiğinde 6.2.14'teki mesaj/efekt tetiklenir; kayıt başarısızsa kutlama gösterilmez.
- Geri alma yalnızca kartı taşımaz: günlük kaydı, takvim işaretini, günlük özeti ve seri hesabını birlikte günceller. Aynı görev yeniden tamamlanınca seçili efekt/mesaj yeniden çalışır; günlük toplam yine tek tamamlamadır.

Boş durumlar ayrı ele alınır: hiç görev yok, bugün planlı görev yok, yapılanlar boş veya bugünün tamamı bitmiş. Uygun yerde **Görev Ekle** bağlantısı bulunur.

#### 6.2.7. Bildirim Penceresi

Zil simgesi küçük, kaydırılabilir bir pencere açar. Satırlarda görev adı, motive edici mesaj, zaman ve okunma durumu bulunur. Okunmamış sayı zil üzerinde gösterilir.

Pencere açıldığında gösterilen bildirimler okundu olur. Satıra basmak ilgili göreve götürür; yarının erken saatli görevi için Görevler sayfasındaki kart açılabilir. Boşsa “Şimdilik yeni bildirimin yok.” yazılır. Zamanlama ayrıntıları 6.10'dadır.

#### 6.2.8. Görevler Sayfası

Bütün aktif alışkanlıklar, bugün planlı olmasalar da listelenir. Üstte **Görevlerim**, görev sayısı ve **+ Görev Ekle** bulunur. Kartlar başlık, tekrar aralığı, başlangıç, sayaç türü ve streak gösterir.

Alt menünün hemen üstünde **Düzenle** ve **Kaldır** eylemleri yer alır; listenin son kartını kapatmaz.

- **Düzenle:** Seçim moduna girilir, kullanıcı tek görev seçer ve dolu form açılır. İptal modu kapatır.
- **Kaldır:** Çoklu seçim kutuları açılır. Alt eylemler **Seçilenleri Kaldır (n)** ve **İptal** olur.
- Seçim olmadan kaldırma yapılamaz. Onay penceresinde **Vazgeç** ve **Kaldır** bulunur.
- Onaylanan görevler aktif listelerden kaldırılır; geçmiş kayıtlar korunur. İlk sürümde arşiv/geri yükleme ekranı yoktur.

Onay metni: **Seçtiğin alışkanlıklar listelerinden kaldırılacak. Geçmiş tamamlamaların, rekorların ve rozetlerin korunacak. Devam etmek istiyor musun?**

#### 6.2.9. Görev Ekle / Düzenle

Aynı form kullanılır; düzenlemede mevcut değerler doldurulur.

| Sıra | Alan | Varsayılan / kural |
| --- | --- | --- |
| 1 | Görev adı | Zorunlu |
| 2 | Açıklama | İsteğe bağlı |
| 3 | Kaç günde bir? | 1; 1–365 arası tam sayı |
| 4 | Başlangıç tarihi | Bugün; yeni görevde geçmiş seçilemez |
| 5 | Sayaç türü | Tik atma veya bar doldurma |
| 6 | Hedef miktar | Yalnızca bar tipinde zorunlu |
| 7 | Birim | Bar tipinde bardak/sayfa/dakika vb. |
| 8 | Artış adımı | Bar tipinde varsayılan 1 |
| 9 | Günlük hedef saati | 21.00 |
| 10 | Hatırlatma | Varsayılan açık |
| 11 | Simge ve soft renk | Simge seçilir; kullanılmayan farklı soft renk otomatik atanır, uygun seçeneklerle değiştirilebilir |
| 12 | Kaydet | Doğrulama sonrası kaydeder |

Tik seçildiğinde bar alanları gizlenir. Son artış hedefi aşarsa miktar hedefe sabitlenir. Form, sonraki üç planlı tarihi gösterir.

Hatırlatma açıklaması: **Hedef saatinden 1 saat önce uygulama içinde hatırlatılır.** Saat 01.00'den erkense uyarının önceki güne düşeceği belirtilir.

Kaydetme sonrası liste güncellenir ve önceki sayfaya dönülür. Görev bugün planlıysa ana sayfada da görünür. Geçmişi olan görevlerin plan değişikliği 6.7'deki sürüm kuralına uyar.

#### 6.2.10. Profil

Profil ana sayfanın sağ üstündeki avatarla açılır. Üst başlığın sağında **Ayarlar** dişli butonu bulunur ve ayrı Ayarlar sayfasına gider. İçerik sırası: seçili avatar, **Ad Soyad**, e-posta, **Alışkanlık Serilerim**, özet istatistikler, **İstatistikler ve Rozetler** kartı ve en altta **Çıkış Yap**. Motivasyon tercihleri Ayarlar sayfasında yer alır.

Profil fotoğrafı burada yalnızca gösterilir; avatar seçim ızgarası Profil sayfasında bulunmaz. Kullanıcı sağ üstteki Ayarlar düğmesinden **Profil Fotoğrafı** bölümüne ulaşır.

Her aktif görevin streak değeri görünür. Rekor kartı seri uzunluğu, görev adı ve elde edilme tarihini gösterir. Eşit rekorlarda ilk elde edilen tarih seçilir. Tamamlama yoksa açıklayıcı boş durum kullanılır.

Çıkış, görevleri silmeden oturumu kapatır ve Giriş'e döner; geri tuşuyla korumalı ekrana dönülemez. Çalışan Pomodoro varsa önce kalan süresi kullanıcıya özel kaydedilerek duraklatılır. Avatar seçimi Ayarlar üzerinden yapılır; ad/e-posta düzenleme bu sürümde yoktur.

#### 6.2.11. İstatistikler ve Rozetler

**Bu Hafta / Bu Ay** seçimi; planlı tekrar sayısı, tamamlanan sayı, yüzde, yedi günlük grafik, aylık katkı ızgarası, tüm zaman rekoru ve rozetler bulunur. Hafta pazartesi başlar; gelecek günler başarı oranına katılmaz.

| Rozet | Eşik | Başlık |
| --- | --- | --- |
| Bronz | Tek alışkanlıkta 10 planlı gün serisi | Bronz Başlangıç |
| Gümüş | Tek alışkanlıkta 25 planlı gün serisi | Gümüş Devamlılık |
| Altın / Gold | Tek alışkanlıkta 50 planlı gün serisi | Altın İstikrar |

Farklı görevlerin serileri toplanmaz. Kazanılan rozet tarih ve görev adıyla, kazanılmayan rozet soluk/kilitli gösterilir. Seri sonradan bozulduğunda kazanılmış rozet korunur; aynı gün yanlış tamamlamayı geri alma istisnası 6.7'dedir.

#### 6.2.12. Takvim

Ay/yıl başlığı, önceki/sonraki ay düğmeleri ve pazartesi başlayan yedi sütunlu ızgara bulunur. Varsayılan filtre **Tüm Alışkanlıklar**; ek seçenek tek aktif alışkanlıktır.

- Her görev kalıcı, kendine ait farklı bir soft renge sahiptir. Tek görev filtresinde tamamlandığı günler kendi rengiyle işaretlenir.
- Tüm görevlerde aynı gün tamamlanan her görev için kendi renginde ayrı nokta veya kısa şerit gösterilir; gün tek bir görev rengine boyanmaz. Kaldırılmış görevlerin geçmiş renkleri de korunur.
- Gün hücresinde en fazla üç renkli işaret ve kalanlar için **+n** görünür. Güne basıldığında bütün görevler ad, simge ve renkleriyle listelenir.
- Takvimin altında ilgili ayda görünen görevler için **renk — görev adı** açıklama listesi bulunur; renk tek ayırt edici unsur olmaz.
- Renkler liste sırasından üretilmez; sıralama, yeniden açılış ve görev kaldırma diğer görevlerin rengini değiştirmez. Kullanıcı renk değiştirirse aynı görevin geçmiş işaretleri de yeni rengi kullanır.
- Boş ve kısmen ilerlenmiş günlere başarı işareti konmaz.
- Bir görev geri alındığında o güne ait yalnızca o görevin renkli tamamlanma işareti kaldırılır. Başka tamamlanmış görev varsa onların renkleri kalır; hiçbiri kalmadıysa günün başarı işareti temizlenir. Yeniden tamamlanınca işaret geri gelir.
- Bugün ve seçili tarih ayrı çerçeveyle belirtilir; bu çerçeveler başarı anlamına gelmez.
- Güne basınca alt bölümde o tarihin görevleri/durumları gösterilir; geçmiş değiştirilemez.
- Gelecekte tamamlanma gösterilmez; boş aylar hatasız açılır.

#### 6.2.13. Motivasyon Maskotu

`MainShell` içindeki Ana Sayfa, Görevler ve Pomodoro ekranlarının sağ alt köşesinde, alt menünün hemen üzerinde küçük bir maskot bulunur. Pomodoro odaklanması çalışırken veya duraklatılmışken maskot ve periyodik mesajlar gizlenir/duraklatılır; boş durumda ve molalarda gösterilebilir. Varsayılan görünüm soft yeşil tonlarda sevimli bir filiz karakteridir; Flutter ile çizilebilir veya projeye eklenmiş yerel bir görsel kullanılabilir.

- Yaklaşık 64 × 64 px boyutunda, sağdan ve alt menünün üstünden en az 12 px boşlukla konumlanır. Liste/kontrol alanı gerekli boşluğu bırakır; maskot butonları kapatmaz.
- Konuşma balonu maskotun üstüne/soluna açılır; kısa, Türkçe ve destekleyici bir cümle yaklaşık 6 saniye görünür, dokunarak kapatılabilir.
- İlk mesaj, ana sekmeler görünürken 15 saniye sonra; sonraki mesajlar varsayılan 5 dakikalık etkin kullanım aralıklarında gösterilir. Sekme değişimi sayacı baştan başlatmaz.
- Maskota dokunmak yeni bir cümle gösterir; tekrar dokunmalarda en az 10 saniye bekleme uygulanır. Son beş cümle mümkün olduğunca tekrarlanmaz.
- Klavye, diyalog veya yardımcı sayfa açıkken mesaj/maskot gizlenir ve süre duraklar. Arka planda süre işlemez; dönüşte birikmiş mesajlar arka arkaya gösterilmez.
- Çıkışta zamanlayıcı durdurulur. Maskot gizlenmişse periyodik motivasyon gösterilmez; görev tamamlama tercihi ayrı çalışır.
- Cümleler yazılı gösterilir; sesli okuma veya sistem bildirimi gerekmez. Kullanıcı adı ve günün tamamlanan sayısı yalnızca cihazda metne eklenebilir.
- En az 20 yerel cümle hazır bulunur: “Küçük bir adım da ilerlemedir.”, “Kendi hızında devam et.”, “Bugün kendin için güzel bir şey yapabilirsin.”

#### 6.2.14. Görev Tamamlama Mesajı ve Efekti

Tik işaretlendiğinde veya bar hedefin altından hedefe ulaştığında, başarılı kayıt sonrasında kullanıcının seçtiği **tek** geri bildirim biçimi gösterilir:

| Seçenek | Davranış |
| --- | --- |
| Üstten mesaj — varsayılan | Güvenli alanın altından kayan küçük bant yaklaşık 2,5 saniye görünür: “Bir adım daha attın, harika!” |
| Parıltı | Tamamlanan kartın veya maskotun çevresinde yaklaşık 1–1,5 saniyelik yumuşak yıldız/parıltı animasyonu |
| Alev | Streak simgesi veya maskot yanında yaklaşık 1–1,5 saniyelik sıcak pastel tonlu küçük alev animasyonu |
| Kapalı | İlerleme kaydedilir; kutlama gösterilmez |

- Kutlama işletim sistemi bildirimi değildir; ekranı kaplamaz, dokunmaları engellemez ve ses çıkarmaz.
- Yalnızca tamamlanmamış → tamamlanmış geçişinde çalışır; kısmi ilerleme, ekran yenileme, seed veya eski veriyi yükleme kutlama üretmez.
- Her başarılı **tamamlanmamış → tamamlanmış** geçişinde bir kez gösterilir. Tamamla → geri al → yeniden tamamla akışında ikinci gerçek tamamlama yeni kutlama üretir. Zaten tamamlanmış göreve tekrar kaydetmek, çift dokunma veya ekranı yeniden çizmek ek kutlama üretmez.
- Hızlı tamamlamalarda aynı anda tek kutlama gösterilir; bekleyen olaylar en fazla bir kısa birleşik mesaja/efekte indirilir. Kutlama sırasında maskotun periyodik balonu ertelenir.
- Neon, hızlı yanıp sönme ve yoğun tam ekran parçacık kullanılmaz. Sistem hareket azaltmayı istiyorsa animasyon yerine kısa sabit başarı metni gösterilir.
- Kayıt başarısızsa efekt gösterilmez; kutlama katmanı kayıt, takvim ve streak mantığını değiştirmez.

#### 6.2.15. Ayarlar

Profilin sağ üstündeki dişliyle açılır. Başlık **Ayarlar**, sol üstte Profil'e dönen geri düğmesi bulunur. Aşağıdaki bölümler tek kaydırılabilir sütunda **alt alta** sıralanır; yan yana ayar panelleri veya ayrı sekmeler kullanılmaz.

1. **Profil Fotoğrafı:** Seçili avatarın önizlemesi ve aşağıdaki hazır avatar kataloğu.
2. **Görünüm:** Açık Tema ve Koyu Tema seçenekleri. Varsayılan açık temadır; seçim bütün ekranlara anında uygulanır ve kullanıcıya özel saklanır.
3. **Şifre Değiştir:** Mevcut Şifre, Yeni Şifre, Yeni Şifre Tekrar alanları ve **Şifreyi Güncelle** butonu aynı sayfada alt alta bulunur.
4. **Motivasyon Tercihleri:** Maskotu göster/gizle; 3/5/10 dakikalık mesaj aralığı; üstten mesaj/parıltı/alev/kapalı tamamlama tercihi; isteğe bağlı çevrimiçi mesaj kaynağı.

**Profil Fotoğrafı / Avatarını Seç:** Ayarlar sayfasındaki alan, sınırlı bir ızgarada toplam **8 hazır avatar** sunar: 4 çizgi film/animasyon tarzında insan ve 4 hayvan (kedi, köpek, tilki, panda). Kullanıcı yalnızca bu katalogdan seçim yapar; galeri, kamera ve dış URL'den fotoğraf yükleme bulunmaz.

- Avatarlar uygulamayla gelen yerel görseller veya Flutter çizimleridir; internet gerektirmez.
- Seçili avatar çerçeve/tik ile belirtilir. Dokununca seçim kaydedilir ve hem Profil hem ana sayfa avatarı güncellenir.
- Seçimde kısa, yumuşak bir büyüme/selamlama animasyonu kullanılabilir; sürekli oynayan animasyon zorunlu değildir. Hareket azaltma tercihinde sabit görünür.
- Varsayılan avatar tilkidir. Her avatarın kalıcı bir `avatarId` değeri vardır; kullanıcı tercihi yeniden açılışta korunur, bilinmeyen kimlik varsayılana döner.

Avatar, tema ve motivasyon seçimleri ayrı genel Kaydet butonu gerektirmeden kaydedilir; yazma başarısızsa seçim önceki hâline döner ve hata gösterilir. Önceki motivasyon tercihleri buraya taşınırken değerleri korunur. Varsayılan mesaj aralığı 5 dakika, kutlama üstten mesaj, uzak kaynak kapalıdır; doğrulanmış kaynak yoksa uzak seçenek etkinleştirilemez.

Şifre değiştirmede üç alan zorunludur. Mevcut parola etkin yerel hesapla doğrulanır; yeni parola kurallara uymalı, tekrar alanıyla eşleşmeli ve mevcut paroladan farklı olmalıdır. Başarılı işlem yeni salt/doğrulayıcıyı kaydeder, alanları temizler ve başarı mesajı gösterir. Mevcut oturum açık kalır; sonraki girişte eski parola reddedilir, yeni parola geçer. Bu akış, giriş öncesindeki demo “Şifremi Unuttum” akışından ayrıdır. Form gönderilirken çift işlem engellenir; parola loga yazılmaz.

#### 6.2.16. Pomodoro ve Çalışma Geçmişi

Alt menünün üçüncü öğesindeki zamanlayıcı ikonuna basıldığında açılır. Sayfa, Pomodoro düzenine göre odaklanma ve mola sağlar. Varsayılan düzen **25 dakika çalışma, 5 dakika kısa mola, her dört tamamlanmış çalışma sonrası 15 dakika uzun mola** olur. Kullanıcı aynı sayfadaki **Süre Ayarları** bölümünden çalışma ve mola sürelerini değiştirebilir. Dört çalışma sonrası uzun mola kuralı korunur; süreler sabit değildir.

| Bölüm | İçerik |
| --- | --- |
| Üst alan | Pomodoro başlığı ve kısa kullanım açıklaması |
| Süre Ayarları | Çalışma, kısa mola ve uzun mola dakika alanları; Süreleri Kaydet ve Varsayılana Döndür |
| Çalışma hedefi | İsteğe bağlı görev seçimi veya kısa çalışma başlığı; boşsa “Odaklanma” |
| Sayaç | Seçili süreye göre `MM:SS` biçimi (varsayılan `25:00`), dairesel ilerleme ve Odaklanma/Kısa Mola/Uzun Mola etiketi |
| Döngü | Tamamlanan çalışma sayısı: 0/4, 1/4, 2/4, 3/4, 4/4 |
| Kontroller | Başlat, Duraklat, Devam Et ve Oturumu Bitir; duruma uygun olanlar gösterilir |
| Günlük özet | Bugün tamamlanan Pomodoro sayısı ve tamamlanmış odak dakikası |
| Alt alan | Aşağı kaydırıldığında görülen **Pomodoro Geçmişim** listesi |

**Süre ayarları:** Sayfanın üst bölümünde, sayacın üzerinde üç alan alt alta bulunur. Çalışma süresi 1–180 dakika, kısa mola 1–60 dakika, uzun mola 1–120 dakika arasında tam sayı olmalıdır. Uzun mola kısa moladan daha kısa olamaz. Alanlar sayısal giriş ve artır/azalt kontrolleriyle düzenlenebilir; boş, sıfır, negatif, ondalık ve sınır dışı değerler kaydedilmez.

- **Süreleri Kaydet** geçerli değerleri kullanıcıya özel saklar; hata varsa alan altında açıklar. Yazma hatasında kayıtlı tercihler korunur; başarı mesajı verilmez.
- **Varsayılana Döndür** alanları 25/5/15 olarak doldurur; değişiklik Süreleri Kaydet ile uygulanır. Diğer kullanıcı ayarları ve geçmiş etkilenmez.
- Hazır ve henüz başlamamış aşamada kaydetme, sayacı o aşamanın yeni süresine günceller. Çalışan veya duraklatılmış aşama süre anlık kopyasını korur; mevcut kalan süre, bitiş zamanı ve döngü sayısı değişmez.
- Devam eden aşamada ayar değiştirildiğinde “Yeni süreler sonraki aşamalarda kullanılacak.” açıklaması gösterilir. Sonraki çalışma/mola hazırlanırken en son kaydedilen süre kullanılır; geçmiş oturum süreleri yeniden yazılmaz.
- Tercihler sekme değişimi, çıkış/giriş ve yeniden açılışta korunur. Süre ayarlarının yeri Pomodoro sayfasıdır; genel Ayarlar'da ikinci bir süre formu bulunmaz.

**Çalışma akışı:**

- Kullanıcı bir çalışma hedefi seçip **Başlat** der. Çalışma boyunca hedef değişmez; sıradaki oturum için değiştirilebilir.
- Süre bittiğinde odak oturumu bir kez tamamlanır ve geçmişe yazılır. İlk üç tamamlamadan sonra kısa, dördüncüden sonra uzun mola önerilir.
- Sonraki aşama **Molayı Başlat** veya **Çalışmayı Başlat** ile kullanıcı tarafından başlatılır; arka planda zincirleme yeni oturum üretilmez. Uzun mola tamamlandığında döngü sayacı 0'a döner.
- Duraklatmak kalan süreyi sabitler; Devam Et o süreden sürdürür. Duraklama zamanı odak süresine katılmaz. Bu, uygulamanın kullanım kolaylığı seçeneğidir.
- **Oturumu Bitir** onay ister. Yarım kalan çalışma “Yarıda bırakıldı” olarak kaydedilir; tamamlanmış Pomodoro veya döngü sayısı artmaz. Mola erken bitirilirse tamamlandı sayılmaz; sıradaki aşama hazır hâle gelir. Uzun mola sonlandırıldığında yeni döngü hazırlanır.
- Çalışma iptalinden sonra kayıtlı çalışma süresinde yeni bir çalışma hazır olur; önceki tamamlanmış döngü sayısı korunur. Kısa molanın bitişi/sonlandırılması da aynı sayıyla çalışmaya döner; uzun molanın bitişi/sonlandırılması sayacı 0 yapar.
- Sayfa/sekme değiştirmek çalışan sayacı sıfırlamaz. Tek controller, kullanıcı başına en fazla bir etkin aşama yönetir.
- Çalışan aşamanın bitiş zamanı saklanır; uygulama yeniden açıldığında kalan süre bundan hesaplanır. Süre geçmişse yalnızca mevcut aşama tamamlanır, kaydı tekrar oluşturulmaz ve sonraki aşama kullanıcıyı bekler. Uygulama kapalıyken sistem alarmı garantisi verilmez.
- Tamamlanan odak süresi alışkanlığı otomatik tamamlamaz ve streak'i otomatik artırmaz. Görev seçimi çalışma bağlamını belirtir; alışkanlık takibi ayrı kalır.
- Süre bitince sade “Çalışma tamamlandı, mola zamanı.” mesajı gösterilir. Odaklanma sırasında periyodik maskot mesajları dikkati bölmez.

**Geçmiş:** Aynı sayfanın alt bölümünde en yeni kayıt üstte, günlere göre gruplanmış liste bulunur. Her çalışma kaydı tarih, başlangıç/bitiş saati, çalışma/görev adı, planlanan süre, duraklamalar hariç geçen süre ve **Tamamlandı / Yarıda bırakıldı** durumunu gösterir. Molalar odak geçmişine veya odak dakikasına katılmaz. Günlük özette yalnızca tamamlanmış çalışma süreleri sayılır; yarım çalışmalar listede görünür ama tamamlanmış toplamını artırmaz.

Geçmiş boşsa “İlk Pomodoro oturumunu başlatarak odaklanmaya başlayabilirsin.” yazılır. Liste ve sayaç aynı sayfada doğal biçimde kaydırılır; uzun liste tembel çizilir. Kayıtlar kullanıcıya özeldir ve yeniden açılışta korunur. İlişkili görev sonradan kaldırılırsa geçmişteki başlık kopyası korunur.

Geçmiş grubu ve günlük özet, oturumun bittiği yerel gün üzerinden hesaplanır. Gece yarısını geçen oturum ikiye bölünmez; tek kayıt olarak bitiş gününde görünür.

Günlük odak dakikası tamamlanmış oturumların `focusedSeconds` toplamından hesaplanır; oturum sayısı sabit 25 dakika ile çarpılmaz. Özel süreyle tamamlanan her çalışma bir Pomodoro ve döngüde bir adım sayılır.

### 6.3. Veri Modeli ve Bileşen Tasarımı

Modeller UI bağımlılığı içermez. Saklanan modellerde `toJson`, `fromJson` ve gerektiğinde `copyWith` bulunur. Tarihler yerel `YYYY-MM-DD`, olay zamanları UTC ISO 8601 olarak saklanır. Renk için HEX metni, simge için anahtar kullanılır.

#### 6.3.1. Temel Modeller

| Model | Alanlar |
| --- | --- |
| `AppUser` | `id`, `firstName`, `lastName`, `email`, `avatarId`, `createdAtUtc`, `credential` |
| `DemoCredential` | `algorithm`, `iterations`, `saltBase64`, `verifierBase64` |
| `DemoResetSession` | `userId`, `normalizedEmail`, `code`, `issuedAtUtc`, `verifiedAtUtc`, `consumed` |
| `Habit` | `id`, `userId`, `title`, `description`, `iconKey`, `colorHex`, `createdAtUtc`, `archivedAtUtc`, `archivedOnDateKey`, `schedules` |
| `HabitSchedule` | `id`, `effectiveFromDateKey`, `anchorDateKey`, `intervalDays`, `counterType`, `targetValue`, `unitLabel`, `stepValue`, `dueMinutes`, `reminderEnabled` |
| `HabitEntry` | `id`, `userId`, `habitId`, `scheduleId`, `dateKey`, `progressValue`, `completedAtUtc`, `completionRevision`, `lastCelebratedRevision`, `updatedAtUtc` |
| `Achievement` | `id`, `userId`, `type`, `threshold`, `habitId`, `habitTitleSnapshot`, `earnedOnDateKey`, `earnedAtUtc` |
| `HabitReminder` | `id`, `userId`, `habitId`, `scheduleId`, `targetDateKey`, `dueAtUtc`, `remindAtUtc`, `message`, `createdAtUtc`, `readAtUtc` |
| `MotivationPreferences` | `userId`, `mascotEnabled`, `intervalMinutes`, `completionFeedbackMode`, `remoteSourceEnabled` |
| `MotivationMessage` | `id`, `text`, `language`, `category`, `source`, `sourceUrl`, `license` |
| `AppSettings` | `userId`, `themeMode` (`light` / `dark`) |
| `PomodoroPreferences` | `userId`, `focusMinutes`, `shortBreakMinutes`, `longBreakMinutes` — varsayılan 25/5/15 |
| `AvatarOption` | `id`, `label`, `kind`, `assetPath` — sabit yerel katalog |
| `PomodoroState` | `userId`, `phase`, `status`, `cycleCompletedCount`, `activeSessionId`, `taskId`, `titleSnapshot`, `plannedSeconds`, `remainingSeconds`, `startedAtUtc`, `lastResumedAtUtc`, `endsAtUtc`, `accumulatedActiveSeconds` |
| `PomodoroSession` | `id`, `userId`, `taskId`, `titleSnapshot`, `startedAtUtc`, `endedAtUtc`, `endedOnDateKey`, `plannedSeconds`, `focusedSeconds`, `status` |

- Kimlikler benzersiz `String`; miktar, aralık ve dakika değerleri `int`; tercihler `bool` olur.
- Açıklama, kaldırma, okunma ve tamamlanma zamanları uygun olduğunda nullable olur.
- `CounterType`: `check`, `progress`; `BadgeType`: `bronze`, `silver`, `gold`.
- `Habit.schedules`, eski planları koruyan `List<HabitSchedule>` alanıdır.
- `dueMinutes`, gece yarısından itibaren 0–1439 arasındaki yerel dakikadır.
- Her `habitId + dateKey` için tek günlük kayıt bulunur; kayıt yoksa ilerleme sıfırdır.
- Tamamlanma ayrı ve çelişebilen bir bayrak yerine ilgili hedef ve ilerlemeden hesaplanır.
- Hedef altına düşülünce `completedAtUtc` temizlenir; tekrar ulaşılınca güncellenir.
- Her kullanıcı/rozet türü tekildir. Hatırlatma kimliği kullanıcı, görev, plan sürümü ve hedef günü içerir.
- `DemoResetSession` yalnızca bellektedir, JSON'a yazılmaz.
- `colorHex`, örneğin `#86A99A`, kullanıcının diğer görevlerinden farklı seçilir. Hazır palet bitince soft ton çeşitleri üretilir; arşivlenmiş görev renkleri de hesaba katılır. Benzer tonlar her zaman simge ve adla desteklenir.
- `CompletionFeedbackMode`: `message`, `sparkle`, `flame`, `off`. `completionRevision` başlangıçta 0'dır; yalnızca tamamlanmamış durumdan tamamlanmış duruma başarılı geçişte artar. `lastCelebratedRevision` son işlenen geçişi tutar; kutlama kapalıysa da olay tüketilir. Yükleme ve yeniden çizim olay üretmez.
- `avatarId` katalogdaki sekiz kimlikten biridir; varsayılan `fox` olur. Avatar kataloğu kullanıcı başına kopyalanmaz.
- Pomodoro aşaması `focus`, `shortBreak`, `longBreak`; zamanlayıcı durumu `ready`, `running`, `paused`; geçmiş durumu `completed`, `cancelled` olur. `taskId` serbest çalışmada null olabilir.
- Pomodoro tercihleri dakika, etkin aşama ve geçmiş süreleri saniye olarak tutulur. Aşama hazırlanırken ilgili tercih × 60 ile `plannedSeconds` belirlenir; çalışan/duraklatılmış aşama yeni tercihlerle değiştirilmez.
- Pomodoro geçmişi oturum kimliğiyle tekildir. Süreler saniye olarak saklanır; çalışma başlığı anlık kopyası, görev sonradan düzenlense/kaldırılsa da korunur.
- Mesaj kategorileri `general` ve `completion`; uzak veri ve cache kullanıcı adı, e-posta veya görev içeriği içermez.

#### 6.3.2. Demo Parola ve Türetilen Veriler

Parola açık metin saklanmaz. Demo için PBKDF2-HMAC-SHA256, en az 16 bayt rastgele salt, 32 bayt çıktı ve yapılandırılabilir 600.000 iterasyon kullanılır. Türetme mobil/masaüstünde arayüzü kilitlemeyen worker/isolate; web'de desteklenen asenkron uygulama üzerinden yürütülür. Bu yerel mekanizma gerçek hesap güvenliği veya e-posta sahipliği sağlamaz.

Günlük özet, aktif/en yüksek seri, dönem istatistikleri ve takvim hücreleri aynı görev/kayıt kümesinden hesaplanır; bağımsız ve çelişen sayaçlar saklanmaz.

#### 6.3.3. Ortak Bileşenler

`AppLogo`, `AppTextField`, `PrimaryButton`, `EmptyState`, `ConfirmationDialog`, `HabitCard`, `ProgressCounter`, `StreakChip`, `NotificationDialog`, `BadgeCard`, `CalendarGrid` ve `WeeklyChart` tekrar kullanılabilir bileşenlerdir. Ek bileşenler: `CalendarLegend`, `MotivationMascot`, `MotivationBubble`, `CompletionBanner`, `CompletionEffect`, `UserAvatar`, `AvatarPicker`, `ChangePasswordForm`, `PomodoroTimer`, `PomodoroControls`, `PomodoroDurationForm` ve `PomodoroHistoryList`.

### 6.4. Proje Takvimi ve Teslim Aşamaları

Süreler örnektir; öğrenme ve hata çözme süresine göre değişebilir.

| Aşama | Süre | Çıktı ve tamamlanma ölçütü |
| --- | --- | --- |
| 1. Tasarım ve Wireframe | 1 gün | Tema, logo, ekran iskeletleri ve çalışan alt menü |
| 2. Veri ve Kimlik Akışı | 1–2 gün | Modeller, yerel kayıt, giriş/kayıt/şifre demosu |
| 3. Temel Fonksiyonlar | 2 gün | Görev ekle/düzenle/kaldır, bugünün listesi ve kalıcı ilerleme |
| 4. Streak ve Hatırlatma | 1–2 gün | Doğru seri hesabı ve kopyasız uygulama içi uyarılar |
| 5. Profil, Analiz ve Motivasyon | 2–3 gün | Renkli takvim, istatistik, rozet, maskot; geri alma ve yeniden kutlama tutarlılığı |
| 6. Ayarlar ve Avatarlar | 1–2 gün | Yeni gezinme, avatar kataloğu, açık/koyu tema, şifre ve motivasyon tercihleri |
| 7. Pomodoro | 1–2 gün | Kişisel süre ayarları, çalışma/mola döngüsü, kalıcı zamanlayıcı ve oturum geçmişi |
| 8. Test ve İyileştirme | 1–2 gün | Veri geçişi, kritik testler, küçük ekran ve büyük yazı kontrolü |
| 9. Final Teslim | Yarım gün | Çalışan demo ve kurulum/çalıştırma README'si |

Her aşama çalışır durumda doğrulandıktan sonra sonraki aşamaya geçilir. README; demo hesap bilgilerini, mock sınırlarını ve doğrulanamayan platformları açıklar.

### 6.5. Notlar ve Karşılaşılabilecek Zorluklar

| Risk | Çözüm |
| --- | --- |
| Gece yarısında dünkü listenin kalması | Merkezi saat servisi ve ön plana dönüşte yenileme |
| Yaz/kış saati veya ara günlerde yanlış seri | Takvim günü hesabı; yalnızca planlı günleri değerlendirme |
| Çift tamamlama/bildirim | Tekil kayıt kimlikleri |
| Düzenlemeyle geçmişin değişmesi / serinin sıfırlanması | Geçmiş planları koruma; sürümler boyunca aynı görev kimliğiyle seri hesabı |
| Geri alınan görevin takvimde tamamlanmış kalması | Tek günlük kayıt kaynağı; ilgili bütün görünüm ve hesapların birlikte yenilenmesi |
| Kullanıcı verilerinin karışması | Repository düzeyinde kullanıcı sahipliği kontrolü |
| Hızlı dokunuşlarda eski kaydın yeniyi ezmesi | Sıralı bellek değişikliği ve yazı kuyruğu |
| Bozuk yerel verinin kaybolması | Hata/tekrar deneme; sıfırlamadan önce açık onay |
| Arayüz donması veya okunaksız soft tema | Ağır işi UI dışına alma; yeterli kontrast |
| Maskotun kontrol kapatması / tekrarlı kutlama | Güvenli yerleşim, tek zamanlayıcı ve tamamlama geçişi bazında olay kimliği |
| Pomodoro'nun sekme değişiminde sıfırlanması | Ekrandan bağımsız tek controller ve kalıcı bitiş zamanı |
| Yeniden açılışta çift oturum geçmişi | Tekil oturum kimliği; geçmiş ve aşama geçişini tek kayıt işleminde saklama |
| Uzak mesaj kaynağının çalışmaması | Süre aşımı, cache ve yerel cümle havuzu |

Sorunlar README'ye tarih, gözlenen durum ve çözümle not edilebilir. Platform klasörleri derleme yavaş diye silinmez; hata çıktısı incelenir. Gerçek parola veya API anahtarı kaynak koda konmaz.

### 6.6. Mimari, Klasörler ve Dosya Sorumlulukları

Akış **Widget → Controller → Servis/Repository → Yerel Depo** olacaktır. Tarih ve streak mantığı widget `build` içine, depolama çağrıları ekran dosyalarına yazılmaz. Repository sınırı, ileride veri kaynağının değiştirilmesini kolaylaştırır; her küçük işlem için ek katman kurulmaz.

Aşağıdaki yollar proje köküne göredir; aynı satırdaki dosyalar belirtilen klasörün içinde bulunur.

| Klasör | Dosyalar |
| --- | --- |
| Proje kökü | `README.md`, `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml` |
| `lib/` | `main.dart` |
| `lib/app/` | `app.dart`, `bootstrap_screen.dart`, `main_shell.dart`, `app_navigation.dart`, `app_providers.dart` |
| `lib/core/theme/` | `app_colors.dart`, `app_theme.dart`, `app_spacing.dart` |
| `lib/core/theme/` | `habit_color_service.dart` — görev renklerinin atanması ve çakışma kontrolü |
| `lib/core/time/` | `app_clock.dart`, `date_key.dart` |
| `lib/core/storage/` | `local_store.dart`, `store_document.dart` |
| `lib/core/security/` | `demo_password_service.dart` |
| `lib/core/utils/` | `validators.dart`, `id_generator.dart` |
| `lib/core/widgets/` | `app_logo.dart`, `app_text_field.dart`, `primary_button.dart`, `empty_state.dart`, `confirmation_dialog.dart` |
| `lib/data/models/` | `app_user.dart`, `demo_credential.dart`, `demo_reset_session.dart`, `habit.dart`, `habit_schedule.dart`, `habit_entry.dart`, `achievement.dart`, `habit_reminder.dart`, `tracking_enums.dart` |
| `lib/data/models/` | `motivation_preferences.dart`, `motivation_message.dart` |
| `lib/data/models/` | `app_settings.dart`, `avatar_option.dart`, `pomodoro_preferences.dart`, `pomodoro_state.dart`, `pomodoro_session.dart` |
| `lib/data/avatars/` | `avatar_catalog.dart` |
| `lib/core/widgets/` | `user_avatar.dart` |
| `lib/data/motivation/` | `local_motivation_messages.dart`, `motivation_repository.dart`, `hugging_face_motivation_source.dart` (isteğe bağlı) |
| `lib/data/repositories/` | `auth_repository.dart`, `habit_repository.dart`, `local_auth_repository.dart`, `local_habit_repository.dart` |
| `lib/data/demo/` | `demo_seed.dart` |
| `lib/features/auth/` | `auth_controller.dart` |
| `lib/features/auth/screens/` | `login_screen.dart`, `register_screen.dart`, `forgot_password_screen.dart`, `reset_password_screen.dart` |
| `lib/features/habits/` | `habit_controller.dart` |
| `lib/features/habits/services/` | `schedule_service.dart`, `streak_service.dart` |
| `lib/features/habits/screens/` | `habits_screen.dart`, `habit_form_screen.dart` |
| `lib/features/habits/widgets/` | `habit_card.dart`, `progress_counter.dart`, `streak_chip.dart` |
| `lib/features/home/screens/` | `home_screen.dart` |
| `lib/features/home/widgets/` | `greeting_header.dart`, `daily_summary_card.dart` |
| `lib/features/notifications/` | `notification_controller.dart`, `reminder_service.dart` |
| `lib/features/notifications/widgets/` | `notification_dialog.dart` |
| `lib/features/profile/screens/` | `profile_screen.dart` |
| `lib/features/profile/` | `profile_controller.dart` |
| `lib/features/settings/widgets/` | `avatar_picker.dart` |
| `lib/features/settings/` | `settings_controller.dart` |
| `lib/features/settings/screens/` | `settings_screen.dart` |
| `lib/features/settings/widgets/` | `change_password_form.dart` |
| `lib/features/pomodoro/` | `pomodoro_controller.dart` |
| `lib/features/pomodoro/services/` | `pomodoro_service.dart` |
| `lib/features/pomodoro/screens/` | `pomodoro_screen.dart` |
| `lib/features/pomodoro/widgets/` | `pomodoro_timer.dart`, `pomodoro_controls.dart`, `pomodoro_duration_form.dart`, `pomodoro_history_list.dart` |
| `lib/data/repositories/` | `pomodoro_repository.dart`, `local_pomodoro_repository.dart` |
| `assets/avatars/` | `human_01.png`–`human_04.png`, `cat.png`, `dog.png`, `fox.png`, `panda.png` |
| `lib/features/statistics/` | `statistics_service.dart`, `achievement_service.dart`, `statistics_models.dart` |
| `lib/features/statistics/screens/` | `statistics_screen.dart` |
| `lib/features/statistics/widgets/` | `badge_card.dart`, `weekly_chart.dart`, `monthly_heatmap.dart` |
| `lib/features/calendar/screens/` | `calendar_screen.dart` |
| `lib/features/calendar/widgets/` | `calendar_grid.dart` |
| `lib/features/calendar/widgets/` | `calendar_legend.dart` |
| `lib/features/motivation/` | `motivation_controller.dart`, `completion_feedback_controller.dart` |
| `lib/features/motivation/widgets/` | `motivation_mascot.dart`, `motivation_bubble.dart`, `completion_banner.dart`, `completion_effect.dart`, `motivation_preferences_panel.dart` |
| `test/helpers/` | `fake_clock.dart`, `memory_local_store.dart` |
| `test/services/` | `schedule_service_test.dart`, `streak_service_test.dart`, `achievement_service_test.dart`, `reminder_service_test.dart`, `statistics_service_test.dart` |
| `test/repositories/` | `local_repositories_test.dart` |
| `test/widgets/` | `auth_flow_test.dart`, `habit_completion_test.dart`, `habit_form_test.dart` |
| `test/services/` | `habit_color_service_test.dart`, `motivation_controller_test.dart`, `motivation_repository_test.dart` |
| `test/widgets/` | `calendar_colors_test.dart`, `completion_feedback_test.dart`, `motivation_mascot_test.dart` |
| `test/services/` | `schedule_edit_streak_test.dart`, `pomodoro_service_test.dart`, `store_migration_test.dart` |
| `test/widgets/` | `undo_completion_test.dart`, `settings_avatar_test.dart`, `pomodoro_history_test.dart` |

Flutter'ın ürettiği mevcut platform klasörleri korunur; kullanılmayan platform klasörleri elle eklenmez. Koddan çizilen logo için görsel dosyası gerekmez.

Avatar dosyaları gerçekten projeye eklenip `pubspec.yaml` içinde tanımlanır; bozuk asset yolları bırakılmaz. Flutter ile çizilen yerel avatarlar tercih edilirse aynı katalog kimlikleri korunarak dosya yolu yerine çizim bileşeni kullanılabilir.

**Sorumluluklar:** `AuthController` oturumu, `HabitController` görev/ilerlemeyi, `NotificationController` bildirim ve okunmayı yönetir. `ScheduleService` planı, `StreakService` serileri, `StatisticsService` özetleri, `AchievementService` rozetleri hesaplar. `LocalStore` JSON ve yazı kuyruğunu; `AppClock` saat ve gün değişimini yönetir.

`MotivationController` görünür kullanım süresini, mesaj sırasını ve maskot balonunu yönetir. `CompletionFeedbackController` yalnızca başarılı tamamlama olaylarını dinler; `build` içinden kutlama tetiklemez. `MotivationRepository` yerel/cache/isteğe bağlı uzak mesaj seçimini yapar. `MainShell` tek maskot ve kutlama katmanı barındırır; her sekme ayrı zamanlayıcı oluşturmaz.

`SettingsController` avatar, tema ve motivasyon tercihlerini ortak kullanıcı durumuna yazar; `ProfileController` seçili avatarı gösterir. Avatar değiştirme işlemi Ayarlar ekranına aittir. Ayarlar'daki parola formu mevcut `AuthRepository` üzerinden doğrulama/değiştirme yapar. `PomodoroController` kullanıcı oturumu boyunca tek örnektir; süre tercihlerini ve form doğrulamasını yönetir; süre ve aşamaları `PomodoroService`, geçmişi ve tercih kalıcılığını repository yönetir. Ekran açıp kapatmak, sekme veya tema değiştirmek zamanlayıcıyı yeniden başlatmaz.

Provider'lar her çizimde yeniden oluşturulmaz. Form alanları, parola görünürlüğü ve seçili takvim günü gibi geçici durumlar widget'ta kalabilir. Çıkışta kullanıcıya bağlı controller verileri ve seçimler temizlenir.

### 6.7. Tarih, Tekrar, Tamamlama ve Streak Kuralları

#### 6.7.1. Tekrar Planı

Bir görev, başlangıç gününden itibaren her N takvim gününde bir planlanır:

```text
Geçerli planı seç.
Tarih başlangıçtan önceyse planlı değildir.
Gün farkını UTC yıl/ay/gün bileşenleriyle hesapla.
günFarkı % intervalDays == 0 ise planlıdır.
Sürüm sınırını ve kaldırma iptalini uygula.
```

21 Ekim'de başlayan, iki günde bir yapılan görev **21, 23, 25, 27 Ekim** tarihlerinde görünür. Geç saatte tamamlama sonraki tarihi kaydırmaz. Yerel saatlerde geçen 24 saatleri saymak yerine takvim günü farkı kullanılır.

#### 6.7.2. Günlük İlerleme

- Yalnızca bugün planlı ve aktif görevde ilerleme değiştirilebilir.
- Gün yerel gece yarısında kapanır. Hedef saati hatırlatma/sıralama içindir; gün bitene kadar tamamlanabilir.
- Kaçırılan tekrar ertesi güne taşınmaz. Yeni günün ilerlemesi sıfırdan başlar.
- Tik değerleri 0/1; bar miktarı 0–hedef arasında tutulur.
- Aynı tamamlanmış durumu tekrar kaydetmek ikinci tamamlama veya efekt üretmez.
- **Geri Al** tik ve bar için ilerlemeyi 0 yapar, `completedAtUtc` alanını temizler. Barı elle hedefin altına azaltmak da tamamlanmayı kaldırır; bu durumda kullanıcının seçtiği kısmi miktar korunur.
- Ana sayfa, Görevler listesi, takvim, profil, özet, seri ve rozetler aynı güncel `HabitEntry` verisinden birlikte yenilenir. Kart normale döner, tik kalkar; takvimde yalnızca ilgili görevin başarı işareti silinir. Diğer görevlerin işaretleri korunur.
- Günlük kaydın var olması tamamlanma anlamına gelmez. `isCompleted`, o gün geçerli hedef ile güncel ilerlemeden türetilir; ekranlarda ayrı tamamlanma bayrakları tutulmaz.
- Geri alma sonrası yeniden hedefe ulaşmak yeni bir tamamlanma geçişidir: `completionRevision` artar ve seçili kutlama yeniden gösterilir. Önceki revizyon geri almada azaltılmaz; olay kimliği `habitId + dateKey + completionRevision` olur.
- Aynı günün günlük kaydı güncellenir; ikinci kayıt, ikinci istatistik katkısı veya fazladan streak artışı oluşturulmaz. Net sonuç bir tamamlamadır.
- İlerleme değişikliği, ilgili rozet güncellemesi ve olayın tüketilme bilgisi sıralı tek kayıt işlemiyle tutarlı saklanır. Çift dokunuşlar aynı geçişi çoğaltmaz. Yazma başarısızsa tüm görünümler önceki başarılı duruma döner, kutlama çıkmaz.
- Yeniden açılış, veri geçişi, sayfa çizimi ve tema değişikliği geçmiş tamamlama olaylarını tekrar oynatmaz.
- Geçmiş ve gelecek tarihe kullanıcı tarafından tamamlama yazılmaz.

#### 6.7.3. Aktif Seri ve Rekor

Seri, **aynı görev kimliğinin bütün plan sürümleri boyunca** art arda tamamlanan planlı günlerini sayar. Her tarihte o tarihin geçerli planı kullanılır; sürüm sınırı seriyi kesmez. Ara günler dikkate alınmaz. Bugün tamamlanmamış olsa bile gün kapanmadan önceki seri korunur; kapanmış bir planlı gün kaçırıldıysa seri sıfırdır. Sonraki tamamlama 1'den başlatır.

| Durum | Sonuç |
| --- | --- |
| Üç planlı gün tamamlandı | Seri 3 |
| Dördüncü gün henüz bitmedi | Önceki seri 3 olarak korunur |
| Dördüncü gün tamamlandı | Seri 4 |
| Dördüncü gün kaçırılıp beşinci güne geçildi | Seri 0 |
| Beşinci gün tamamlandı | Yeni seri 1 |
| İki günlük planda ara günler boş | Seri bozulmaz |
| Seri 8 iken görev veya tekrar planı düzenlendi | Seri 8 olarak devam eder |
| Düzenleme sonrası sıradaki planlı gün tamamlandı | Arada kaçırılan planlı gün yoksa seri 9 |

Aktif seri için bütün sürümlerin geçerlilik aralıklarından tek kronolojik planlı gün dizisi oluşturulur; aynı tarih iki kez sayılmaz. Bu dizi geriye doğru taranır; bugün eksikse kapanmış önceki planlı günden başlanır. İlk eksik kapanmış günde sayma durur. Uygulama kapalı kaldığında da açılışta doğru sonuç yeniden hesaplanır.

Rekor, bu birleşik dizideki en uzun tamamlanma serisidir. Yalnızca kaçırılmış planlı gün diziyi keser; görev düzenleme veya sürüm değişikliği kesmez. Rekorun başlangıç/bitiş tarihleri tutulur; eşit uzunluklarda ilk elde edilen seçilir. Kaldırılmış görevlerin geçmişi rekora katılır.

#### 6.7.4. Rozetler

- Tek bir alışkanlıkta 10/25/50 seri bronz/gümüş/altın kazandırır; görevler arası toplama yapılmaz.
- Yeni seviye önceki rozeti gizlemez; her seviyenin ilk geçerli kazanılma tarihi saklanır.
- Seri sonradan bozulduğunda veya görev kaldırıldığında geçmiş başarı korunur, rozet kaybolmaz.
- Aynı günkü tamamlama geri alınıp eşiği karşılayan tek dizi ortadan kalkarsa yeni rozet geri alınır; başka geçerli eski dizi varsa korunur.
- Rozetler sabit sayılarla değil, kayıtları değerlendiren servisle oluşturulur.

#### 6.7.5. Düzenleme ve Kaldırma

Başlık, açıklama, ikon ve renk hemen değişebilir. Tekrar, başlangıç, sayaç, hedef, birim, adım, saat ve hatırlatma plan alanlarıdır.

Geçmişi başlamış görevde plan değişirse **yarından itibaren geçerli yeni sürüm** oluşturulur. Yeni başlangıç daha ilerideyse sürüm yarın yürürlüğe girer, ilk görev seçilen başlangıçta görünür. Bugün eski planla devam eder; **aktif seri kaldığı yerden sürer**. Aynı güne ait bekleyen sürüm yeniden düzenlendiğinde kopyalanmaz, güncellenir. Yeni planın başlangıcına kadar planlanmamış günler seriyi bozmaz.

Form açıklaması: **Plan değişikliklerin yarından itibaren geçerli olur. Geçmiş kayıtların ve alışkanlık serin korunur.** Henüz geçmiş planlı günü ve kaydı olmayan görevde ilk plan doğrudan değiştirilebilir.

Düzenleme aynı `habitId` üzerinde yapılır; silip yeni görev oluşturulmaz, günlük kayıtlar ve kazanılmış rozetler temizlenmez. Eski kayıtların hedef/sayaç anlamı kendi `scheduleId` değeriyle korunur. Geçmişte gerçekten kaçırılmış bir gün düzenlemeyle silinemez; sonradan değiştirmek önceden bozulmuş seriyi geri getirmez. Düzenleme kendi başına kutlama üretmez.

Kaldırmada tarih/saat kaydedilir ve görev aktif listeden çıkar. Önceki günler korunur. Kaldırıldığı gün tamamlanmışsa başarı korunur; tamamlanmamış/kısmi tekrar iptal edilip o günün paydasından çıkarılır. Sonraki günlerde yeni tekrar oluşmaz; eski kayıtlar fiziksel silinmez.

#### 6.7.6. İstatistik Formülleri

```text
Dönem yüzdesi = tamamlanan planlı tekrar / uygun planlı tekrar × 100
Günlük özet = bugün tamamlanan görev / bugün planlı görev × 100
Bar yüzdesi = mevcut miktar / hedef miktar × 100
```

Payda sıfırsa 0 ve açıklayıcı boş durum gösterilir. Bugünün görevleri paydaya girer; gelecek günler girmez. Kısmi bar tamamlanmış sayılmaz. Dönem oranı günlük yüzdelerin ortalamasından değil, toplam sayılardan hesaplanır. Aylık hücre yoğunluğu günlük orana göre değişebilir; sıfır tamamlamada başarı dolgusu olmaz.

Yoğunluk gösterimi istatistikteki aylık katkı ızgarasına aittir. Takvim sayfasında görevlerin ayrı renkli işaretleri kullanılır; oranı göstermek için bu renkler tek renge dönüştürülmez.

### 6.8. Yerel Veri Saklama ve Oturum Yönetimi

`habit_tracker_store_v1` anahtarında tek JSON dokümanı tutulur:

```json
{
  "schemaVersion": 4,
  "activeUserId": null,
  "demoSeedVersion": 0,
  "users": [],
  "habits": [],
  "entries": [],
  "achievements": [],
  "reminders": [],
  "appSettingsByUser": {},
  "pomodoroPreferencesByUser": {},
  "pomodoroStatesByUser": {},
  "pomodoroSessions": [],
  "motivationPreferencesByUser": {},
  "motivationCache": {"messages": [], "fetchedAtUtc": null}
}
```

- Açılışta yüklenir; her widget çiziminde tekrar okunmaz.
- İlerleme ve ilgili rozetler tutarlı tek anlık görüntüyle, sıralı yazı kuyruğundan kaydedilir.
- Yazma hatasında başarı mesajı verilmez; bellek son başarılı duruma döner ve tekrar deneme sunulur.
- Tanınmayan şema/bozuk veri sessizce ezilmez; sıfırlama onay ister.
- Her okuma/yazmada `userId` sahipliği repository katmanında kontrol edilir.
- Başarılı giriş `activeUserId` kaydeder; geçerli oturum sonraki açılışta sürer.
- Kayıt otomatik oturum açmaz. Çıkış yalnızca oturum ve bellekteki kullanıcı durumunu temizler; depo için genel `clear()` kullanılmaz.
- Çoklu süreç/sekme eşzamanlı düzenleme, kritik veri dayanıklılığı ve cihazlar arası senkronizasyon desteklenmez.

Depo anahtarı aynı kalır. Sürüm 1 → 2 geçişinde `colorKey` değerleri `colorHex` alanına dönüştürülür, renk çakışmaları kalıcı soft tonlarla giderilir ve eksik motivasyon tercihleri eklenir. Ardından **2 → 3** geçişi uygulanır:

- Kullanıcının eksik `avatarId` alanı `fox`, eksik tema tercihi `light` olur. Mevcut seçimler korunur; Pomodoro durumu hazır çalışma, geçmişi boş olarak başlatılır.
- Motivasyon seçenekleri Profil'den Ayarlar'a taşınırken saklama anahtarı ve kullanıcı tercihleri korunur; kullanıcıya yeniden varsayılan değerler atanmaz.
- Eski `celebrationShownAtUtc` günlük kilidi kaldırılır. Tamamlanmış eski kayıtlarda `completionRevision = 1`, `lastCelebratedRevision = 1`; tamamlanmamışlarda 0/null atanır. Geçiş geçmiş kutlamaları oynatmaz.
- İlerleme ve tarihindeki hedef temel alınarak tamamlanma tekrar türetilir; tamamlanmamış kaydın tamamlanma zamanı temizlenir. Eski ekran önbellekleri yeniden hesaplanır; kayıt varlığı başarı sayılmaz.
- Görev kimlikleri, plan sürümleri, geçmiş, renkler ve rozet dayanakları korunur. Seri ve rekorlar sürüm sınırında kesilmeyen güncel kuralla yeniden hesaplanır; demo verileri tekrar eklenmez.
- Başarılı veri geçişi bütünüyle kaydedilir. Hata varsa eski doküman korunur; sessizce boş depo oluşturulmaz.

**Sürüm 3 → 4:** `pomodoroPreferencesByUser` eklenir; yalnızca tercihi olmayan kullanıcıya 25/5/15 varsayılanları atanır. Var olan geçerli tercihler, etkin/duraklatılmış aşamanın süreleri, döngü sayısı ve oturum geçmişi korunur. Avatar seçiminin ekranı değişir; mevcut `avatarId` değiştirilmez. Tema ve motivasyon tercihleri sıfırlanmaz. Daha eski depolar önce önceki geçişlerden geçirilir; sürüm 4 tekrar açıldığında migration yeniden varsayılan atamaz.

**Pomodoro kalıcılığı:** Çalışan aşamada `endsAtUtc` tutulur; ekran her saniye bu zamana göre kalan süreyi gösterir. Duraklatmada geçen etkin süre biriktirilir, kalan saniye saklanır ve bitiş zamanı temizlenir. Devamda yeni bitiş zamanı şimdi + kalan süre olur; duraklama süresi çalışmaya eklenmez.

Ön plana dönüşte/yeniden açılışta bitiş zamanı geçmişse yalnızca o aşama bir kez tamamlanır. Çalışma geçmişi aynı `activeSessionId` ile tekil yazılır; geçmiş kaydı, döngü sayacı ve sıradaki hazır aşama tek işlemde kaydedilir. Arka planda otomatik çalışma/mola zinciri üretilmez. İptalde etkin çalışma saniyesi planlanan süreyle sınırlandırılır; hazır ve hiç başlamamış aşamaya geçmiş yazılmaz.

Çıkıştan önce süre durumu güncellenir; zaten bitmiş aşama tamamlanır, hâlâ çalışan aşama duraklatılır. Tema, avatar, tercihler, zamanlayıcı ve geçmiş kullanıcıya özeldir. Girişte ilgili kullanıcıya ait tema ve durum yüklenir; oturumsuz kimlik ekranları varsayılan açık temayı kullanır.

### 6.9. Tema ve Görsel Tasarım

**Açık tema (varsayılan):**

| Kullanım | Hex |
| --- | --- |
| Kırık beyaz arka plan | `#F7F8F5` |
| Beyaz kart | `#FFFFFF` |
| Koyu adaçayı birincil renk | `#4F6F52` |
| Açık adaçayı / lavanta / mavi yüzey | `#E4EDDF` / `#ECE8F3` / `#E5EEF4` |
| Ana / ikincil metin | `#26332D` / `#56645C` |
| Kenarlık | `#DCE3DC` |
| Hata-kaldırma / uyarı metni | `#8F4942` / `#775528` |

**Koyu tema:**

| Kullanım | Hex |
| --- | --- |
| Arka plan / kart | `#18201D` / `#242D29` |
| Birincil renk | `#AEC9A5` |
| Ana / ikincil metin | `#EEF3EF` / `#B7C5BC` |
| Kenarlık | `#3C4A42` |
| Hata / uyarı metni | `#E9ADA5` / `#E3C18D` |

`MaterialApp` içinde `theme`, `darkTheme` ve kayıtlı `ThemeMode` kullanılır. Ayarlar'da seçim anında uygulanır ve kalıcı saklanır. Bütün ekranlar, takvim, menüler, formlar ve uyarı pencereleri ortak tema renklerini kullanır. **Koyu temada uygulama zemini ve kart yüzeyleri koyu; başlıklar, gövde metinleri, alan girişleri, etiketler ve ikonlar açık renkli olmalıdır.** Yalnızca arka planı değiştirmek yeterli değildir. `TextTheme`, `ColorScheme`, form/menü/diyalog temaları birlikte tanımlanır; bileşenlerde sabit siyah yazı veya sabit beyaz kart bırakılmaz. İkincil, ipucu, devre dışı ve üstü çizili metinler de okunabilir açık tonlarla gösterilir. Açık renkli vurgu düğmesi gibi özel yüzeylerde yazı rengi yüzey kontrastına göre seçilir. Tema değiştirmek oturumu, ilerlemeyi, form durumunu veya Pomodoro'yu sıfırlamaz.

Görevlerin kalıcı renk kimliği iki temada aynıdır; okunurluk için kontrastlı kenarlık/zemin ve simge kullanılır. Avatar ve maskot koyu arka planda da seçilir. Açılışta kullanıcı teması yüklenmeden ana içerik çizilmez.

Sayfa kenarı yaklaşık 20 px, kart içi 16 px, bölüm aralığı 20–24 px ve köşeler 16–20 px olur. Butonlar en az 48 px yüksekliğindedir. Sistem fontu, hafif gölge ve temaya uygun okunaklı metin kullanılır.

Logo yumuşak yeşil zeminde yaprak/tik fikrini kullanabilir; girişte 72–88 px, ana sayfada 36–40 px olur. Tüm ekranlar aynı `AppLogo` bileşenini kullanır. Neon, yoğun ışık efekti ve okunaksız pastel metin kullanılmaz.

Görev renkleri adaçayı, lavanta, pastel mavi, gül kurusu, şeftali ve sıcak sarı gibi ayrışan soft tonlardan seçilir. Maskot aynı tasarım dilini kullanır. Kısa kutlama parıltısı/alevi bu sade temaya uygun tutulur; sürekli yanıp sönme yapılmaz.

### 6.10. Uygulama İçi Hatırlatmalar

Hedef anı, planlı tarih ve yerel hedef saatinden oluşturulur. Hatırlatma 60 dakika öncedir. 00.30 hedefi için önceki gün 23.30 kontrol edilir; bu nedenle bugünün ve yarının erken saatli görevleri taranır.

```text
Hatırlatma açık + görev geçerli ve tamamlanmamış
+ hatırlatmaAnı <= şimdi < hedefAnı
+ aynı kimlik daha önce oluşturulmamış
→ bir bildirim oluştur.
```

Uygulama 20.20'de açıldığında 21.00 hedefi için hatırlatma oluşturulabilir; kalan süre 40 dakika olarak yazılır. Hedef geçtikten sonra yeni uyarı oluşturulmaz.

Açılış, ön plana dönüş, görev değişiklikleri ve ön planda dakikada bir kontrol yeterlidir. Tamamlanan, kaldırılan veya hedef anı geçen görevlerin bildirimleri aktif listeden çıkarılır. Geri alma aynı pencere içindeyse mevcut bildirim yeniden uygun olabilir; kopya oluşturulmaz ve okunma bilgisi korunur.

Örnek: **Kitap okuma hedefin yaklaşıyor. Küçük bir adım için güzel bir zaman.** Mesaj bir kez seçilip saklanır. Eski bildirimler 30 gün sonra temizlenebilir.

İşletim sistemi bildirim izni istenmez. Uygulama kapalıyken/askıdayken uyarı garantisi yoktur; özellik açıkça **uygulama içi hatırlatma** olarak adlandırılır.

#### 6.10.1. Motivasyon Mesajları ve Hugging Face Seçeneği

Maskot mesajları süreye, kutlama mesajları tamamlama olayına bağlıdır; bir saat kala üretilen görev hatırlatmalarından ayrı yönetilir ve bildirim kutusuna eklenmez.

- İlk sürüm yerel Türkçe cümle havuzuyla eksiksiz çalışır. İsteğe bağlı olarak Hugging Face'teki herkese açık, kullanım koşulları uygun bir veri kümesinin küçük JSON/CSV metin dosyası okunabilir.
- Kaynak uygulanırken gerçek veri kümesi URL'si, dosya/revision bilgisi, Türkçe içerik ve alan eşlemesi doğrulanıp yapılandırmaya yazılır; var olmayan model veya veri kümesi adı uydurulmaz. Uygun kaynak bulunmazsa uzak özellik kapalı kalır.
- İndirme en fazla 1 MB/100 uygun cümleyle sınırlandırılır. Mesajlar Türkçe, kısa (en fazla 120 karakter), destekleyici ve suçlayıcı olmayan içerikten seçilir; geçersiz/boş kayıtlar elenir. Kaynak ve lisans bilgisi korunur.
- Çevrimiçi tercih açıksa açılışta cache 24 saatten eski olduğunda tek indirme denenir. Beş saniyelik süre aşımı, ağ/CORS/servis hatası veya uygun içerik yokluğunda cache/yerel havuz kullanılır; maskot her konuştuğunda ağ isteği yapılmaz. Başarısız istek en erken 30 dakika sonra yeniden denenir.
- Kullanıcının adı, e-postası, görevleri ve alışkanlık geçmişi dış servise gönderilmez; kişiselleştirme cihazda yapılır. Veri indirmek, yapay zekâyla anlık cümle üretmek olarak sunulmaz.
- Hugging Face Inference Providers ile canlı metin üretimi kimlik doğrulama tokenı gerektirir. Gizli token Flutter koduna veya uygulamayla dağıtılan `.env` dosyasına konmaz; canlı üretim istenirse ileride tokenı sunucuda tutan ayrı entegrasyon yapılır. Bu sürüme bunun için backend eklenmez.

Hugging Face bağlantısı isteğe bağlıdır; zorunlu olan maskotun ve tamamlama mesajlarının çevrimdışı da çalışmasıdır.

### 6.11. Form Doğrulamaları

| Alan | Kural |
| --- | --- |
| Ad / soyad | Zorunlu, en fazla 50 karakter; Türkçe karakter kabul edilir |
| E-posta | Zorunlu, temel biçim kontrolü ve yerel hesap tekilliği |
| Yeni parola | 8–128 karakter, en az bir harf ve rakam |
| Parola tekrarı | Birebir eşleşme |
| Ayarlar'da mevcut parola | Aktif kullanıcının kayıtlı parolasıyla doğrulanır; yeni parola eskisinden farklı olmalıdır |
| Avatar | Yalnızca hazır katalogdaki kimliklerden biri |
| Pomodoro çalışma başlığı | Serbest çalışmada boşsa “Odaklanma”; girilmişse en fazla 60 karakter |
| Çalışma / kısa mola / uzun mola | Sırasıyla 1–180 / 1–60 / 1–120 dakika; zorunlu tam sayı; uzun mola ≥ kısa mola |
| Demo kod | Altı basamak ve süre kontrolü |
| Görev adı / açıklama | 2–60 / en fazla 200 karakter |
| Tekrar | 1–365 arası tam sayı |
| Yeni başlangıç | Bugün veya gelecek |
| Bar hedefi / adımı | Hedef 1–10.000; adım 1–hedef arası tam sayı |
| Birim | Bar tipinde zorunlu, 1–20 karakter |

Parola boşlukları sessizce kesilmez. Hatalar ilgili alan altında açık metinle, başarılar kısa mesajla gösterilir. Teknik istisna/stack trace kullanıcıya gösterilmez. E-posta biçim kontrolü gerçek adres doğrulaması sayılmaz.

### 6.12. Örnek Veriler ve Demo Senaryosu

İlk boş depoda bir kez **Demo Kullanıcı / demo@example.com / Demo1234!** hesabı oluşturulur. Demo olduğu belirtilir; seed sürümü sayesinde tekrar eklenmez ve kaldırılan görevler yeniden yaratılmaz. Yeni hesaplar boş başlar.

| Görev | Plan / sayaç | Örnek geçmiş |
| --- | --- | --- |
| Kitap oku | Günlük, tik, 21.00 | Önceki 12 gün tamamlanmış |
| Su iç | Günlük, 8 bardak, 20.30 | Önceki 6 gün tamamlanmış; bugün 5/8 |
| Yürüyüş yap | 2 günde bir, tik, 18.00 | −8, −6, −4 gün tamamlanmış; −2 kaçırılmış |
| İngilizce çalış | Günlük, 20 dakika, 19.30 | Önceki 54 gün tamamlanmış |

Seed tarihleri bugünden geriye doğru hesaplanır; geleceğe veya bugüne sahte tamamlanma yazılmaz. Geçmiş başlangıç yasağı kullanıcı formu içindir; kontrollü seed istisnadır. Rozetler aynı hesaplama servisinden üretilir.

Sunum akışı: giriş → su miktarını tamamla → kartın aşağı taşınmasını göster → tik tamamla/geri al → görev ekle/düzenle/kaldır → takvim ve rozetleri göster → çıkış/giriş ile kalıcılığı kontrol et.

Demo görevlerine farklı renkler atanır. Sunumda aynı gün iki görevi tamamlayıp takvimde iki renk göster; maskota dokunarak cümleyi, tercihlerden mesaj/parıltı/alev seçeneklerini dene. İnternetsiz çalışmada yerel motivasyon devam etmelidir.

Ek sunum: tamamlanmış görevi geri al → listede tikin ve takvim işaretinin kalktığını göster → yeniden tamamlayıp tekrar kutlama göster → serisi olan görevi düzenleyip serinin korunduğunu göster. Ana sayfa avatarından Profil'e, ardından Ayarlar'a geç; hazır avatar seç, tema ve motivasyon tercihlerini değiştir. Pomodoro'yu başlat/duraklat/devam ettir; sekme değiştirerek süreyi doğrula ve aşağıdaki geçmişi göster. Süreli testlerde `FakeClock` kullan; süreleri yalnızca görünür Süre Ayarları üzerinden değiştir ve sahte oturum geçmişi üretme. Örneğin 40/10/20 kaydet, sonraki aşamaların bu değerleri kullandığını ve eski kayıtların sürelerinin değişmediğini göster. Koyu temada ana sayfa, Profil, Ayarlar, Pomodoro, takvim ve diyaloglarda koyu zemin/açık metin görünümünü kontrol et.

### 6.13. Erişilebilirlik, Performans ve Platformlar

- İkonlarda Türkçe erişilebilir ad, kontrollerde durum açıklaması ve yaklaşık 48 × 48 px dokunma alanı bulunur.
- Durum yalnızca renkle anlatılmaz; normal metinde en az 4.5:1 kontrast hedeflenir.
- Küçük ekran, büyük yazı, uzun görev adı ve klavye açılması taşma yaratmaz.
- Uzun listeler tembel çizilir; hesaplamalar her `build` içinde tekrar yapılmaz.
- Cache görev/gün değişiminde yenilenir; timer ve controller'lar kapatılır.
- Öncelik Android/iOS; Chrome geliştirme kontrolü, macOS isteğe bağlı hedeftir.
- Geniş ekranda içerik yaklaşık 720 px ile sınırlandırılabilir; güvenli alanlar korunur.
- Ön plana dönüşte saat ve gün yenilenir. Saat dilimi değişince gelecek hedef/hatırlatmalar yeniden hesaplanır; eski kayıtların `dateKey` değeri değişmez.
- Elle değiştirilen cihaz saatine karşı güvenilir koruma bu frontend demonun kapsamı dışındadır.
- Maskot ve kutlama katmanları alt menüyü, son kartı ve form kontrollerini kapatmaz. Animasyonlar kısa tutulur; hareket azaltma tercihinde sabit metin kullanılır. Widget kapanınca timer, animasyon ve overlay temizlenir.
- Pomodoro süre mantığı ekran widget'ından bağımsız yaşar; yalnızca görünüm timer'ı ekran kapanınca durur. Controller kullanıcı oturumu kapanırken temizlenir ve kayıtlı durum korunur.
- Ana sayfanın takvim/bildirim/avatar sırası küçük ekranda korunur; selamlama gerektiğinde kısalır. Ayarlar tek sütun hâlinde kayar; Pomodoro geçmişine aşağı kaydırarak ulaşılır.
- Ekran okuyucuya her saniye geri sayım okutulmaz; aşama değişimi, duraklama ve tamamlanma duyurulur. Avatar seçimi yalnızca renk çerçevesiyle anlatılmaz.

### 6.14. Test Planı

Tarih testlerinde gerçek zaman beklenmez; `FakeClock` kullanılır. Repository testleri bellek deposuyla yürütülür. Öncelik kritik davranışlardır:

| Senaryo | Beklenen |
| --- | --- |
| Başlangıç öncesi, N günlük aralık, ay/yıl geçişi | Doğru günlerde görev görünür |
| Bugün henüz eksik / kapanmış gün kaçırılmış | Seri sırasıyla korunur / sıfırlanır |
| Günlük olmayan görevde ara gün | Seri bozulmaz |
| Aynı gün tekrar tamamlama | Tek kayıt ve tek artış |
| Bar hedefe ulaşır / azaltılır | Tamamlanır / geri alınır; ekranlar eşleşir |
| 9–10, 24–25, 49–50 eşikleri | Doğru rozet; farklı görevler toplanmaz |
| Seri bozulur / eşik tamamlaması geri alınır | Tarihî rozet korunur / dayanak yoksa geri alınır |
| Plan değiştirme ve kaldırma | Geçmiş korunur; iptal edilmiş tekrar paydadan çıkar |
| Hedefe bir saat kala, geç açılış ve gece yarısı | Doğru ve kopyasız bildirim |
| Kod doğrulanmamış / yetki süresi geçmiş | Yeni şifre kaydedilemez |
| A hesabından B'ye geçiş ve çıkış sonrası geri | Veri sızmaz; korumalı ekran açılmaz |
| Yazma hatası ve normal yeniden açma | Hata gizlenmez; başarılı kayıt geri gelir |
| Boş dönem, gelecek gün ve kısmi bar | Oran doğru, sıfıra bölme yok |
| Aynı gün farklı görevler / üçten fazla tamamlama | Ayrı renkler, +n ve ayrıntıda bütün görevler |
| Yeniden açılış, sıralama, kaldırma ve eski veri geçişi | Görev renkleri kalıcı; önceki kayıtlar korunur |
| Maskot aralığı, sekme değişimi ve arka plan | Tek timer; yalnızca görünür etkin sürede mesaj |
| Tamamlama → geri alma → yeniden tamamlama | İlk ve ikinci gerçek tamamlamada kutlama; net bir günlük kayıt ve tek seri katkısı |
| Geri alma sonrası Ana Sayfa, Görevler ve Takvim | Tik/çizgi/solukluk kalkar; ilgili renk işareti silinir, diğer görevler korunur |
| Barı hedef altına düşürme ve tekrar doldurma | Tamamlanma zamanı temizlenir; yeniden hedefte kutlama çalışır |
| Tamamlanmış durumu tekrar kaydetme / yeniden açma | İkinci efekt ve geçmiş kutlaması yok |
| Seri 8 iken ad/renk/tekrar/hedef düzenleme | Seri 8 kalır; sıradaki planlı tamamlama 9 yapar |
| Plan sürümü sınırı, ara gün ve eski kaçırma | Sürüm/ara gün seriyi kesmez; gerçek eski kaçırma silinmez |
| Ana sayfa üst menüsü ve alt menü | Takvim–Bildirim–Avatar; Ana Sayfa–Görevler–Pomodoro |
| Profil → Ayarlar → Profil Fotoğrafı | Seçim yalnızca Ayarlar’da; 8 seçenek; ana sayfa ve profil anında eşleşir |
| Tema ve motivasyon tercihleri, yeniden açılış | Alt alta ayarlar; seçimler kullanıcıya özel korunur |
| Şifre değiştirme | Yanlış mevcut parola/eşleşmeyen tekrar reddedilir; doğru değişimde eski parola çalışmaz, yeni parola çalışır; oturum ve veriler korunur |
| Varsayılan Pomodoro dört çalışma döngüsü | 25 dakika çalışma, ilk üçünde 5 dakika mola, dördüncüde 15 dakika mola; sonraki aşama elle başlar |
| Özel 40/10/20 süreleri ve yeniden açılış | Çalışma/kısa/uzun mola seçilen sürelerde; tercihler kullanıcıya özel korunur |
| Geçersiz süre veya uzun mola < kısa mola | Alan hatası gösterilir, kayıtlı ayarlar değişmez |
| Çalışan/duraklatılmış aşamada süre değiştirme | Mevcut süre/bitiş değişmez; sonraki aşama yeni tercihi kullanır |
| Hazır aşamada süre değiştirme / varsayılana dönme | Kaydet sonrası sayaç güncellenir; geçmiş ve döngü korunur |
| Özel sürede geçmiş ve günlük toplam | Oturumun gerçek planlanan/etkin süresi kullanılır; oturum sayısı × 25 yapılmaz |
| Koyu temada tüm ekran ve diyaloglar | Koyu zemin, açık ve okunur metin; form, alt menü ve geri sayımda kontrast korunur |
| Duraklat/devam et, sekme ve tema değişimi | Duraklama süreye katılmaz; kalan süre sıfırlanmaz |
| Arka planda bitiş ve tekrar açılış | En fazla mevcut aşama tamamlanır; tek geçmiş kaydı; otomatik yeni oturum yok |
| Tamamlanan/iptal edilen çalışma ve molalar | Tamamlanan ve iptal edilen çalışma geçmişte görünür; yalnızca tamamlananlar özet sayısına/süresine katılır; molalar geçmişe yazılmaz |
| Görev düzenleme/kaldırma sonrası Pomodoro geçmişi | Başlık kopyası ve geçmiş korunur; alışkanlık otomatik tamamlanmaz |
| Şema 2 → 3 → 4, kullanıcı değişimi ve çıkış | Eski veriler/tercihler korunur; avatar/tema/Pomodoro kullanıcılar arasında karışmaz |
| Hızlı çoklu tamamlama / başarısız kayıt | Kutlamalar üst üste binmez; başarısız kayıtta kutlama yok |
| Hugging Face kapalı, ağ hatası veya uygunsuz yanıt | Yerel/cache mesajlarla devam; tekrar istek sınırı korunur |
| Küçük ekran ve hareket azaltma | Kontroller açık; animasyon yerine okunur metin |

Form hataları, kaldırmada Vazgeç, boş ekranlar, küçük ekran ve büyük yazı ayrıca kontrol edilir. Komutlar `pubspec.yaml` bulunan proje kökünde çalıştırılır:

```bash
dart format lib test
flutter analyze
flutter test
flutter devices
flutter run -d chrome
```

Mobil cihaz için `flutter run -d CIHAZ_KIMLIGI` kullanılır; kimlik `flutter devices` çıktısından alınır. iOS simülatörü macOS/Xcode ortamı gerektirir. Denenemeyen hedef denenmiş gibi raporlanmaz.

### 6.15. Teslim Kontrol Listesi

- [ ] Logo, kimlik ekranları ve demo doğrulama/yeni şifre akışı tamam.
- [ ] Saatli selamlama, bugünün listesi ve Ana Sayfa–Görevler–Pomodoro alt menüsü çalışıyor.
- [ ] Tik/bar, yapılanlara taşıma, soluk/üstü çizili görünüm ve geri alma çalışıyor.
- [ ] Ekle/düzenle ve onaylı çoklu kaldırma tamam.
- [ ] Düzenlenen görev aynı kimlik ve geçmişle devam ediyor; plan değişikliği seriyi sıfırlamıyor.
- [ ] Geri alınan görev tüm listelerde tamamlanmamış; takvimde ilgili başarı işareti kaldırılmış.
- [ ] Streak, 10/25/50 rozetleri, tarihli rekor ve takvim tutarlı.
- [ ] Bildirim penceresi zamanına uygun ve kopyasız çalışıyor.
- [ ] Takvimde görevler ayrı kalıcı renklerle, renk açıklaması ve +n ayrıntısıyla görünüyor.
- [ ] Sağ alttaki maskot alt menünün üstünde; mesaj aralığı ve kullanıcı tercihleri çalışıyor.
- [ ] Üstten mesaj/parıltı/alev her başarılı tamamlama geçişinde bir kez; geri alma sonrası yeniden tamamlamada tekrar gösteriliyor.
- [ ] Ana sayfa sağ üstte takvim, bildirim ve avatar var; avatar Profil'i açıyor.
- [ ] Ayarlar’da 8 hazır insan/hayvan avatarı seçilebiliyor; Profil’de seçim ızgarası yok, seçili avatar iki ekranda ortak ve kalıcı.
- [ ] Profilin sağ üst dişlisi Ayarlar'ı açıyor; avatar, tema, şifre ve motivasyon seçenekleri alt alta.
- [ ] Açık/koyu tema bütün ekranlarda çalışıyor; şifre değişimi mevcut parola doğrulamasıyla tamamlanıyor.
- [ ] Pomodoro 25/5/15 varsayılanları ve kullanıcı tarafından ayarlanan çalışma/kısa/uzun mola süreleri çalışıyor.
- [ ] Süre değişikliği etkin aşamayı veya eski geçmişi değiştirmiyor; sonraki aşamaya uygulanıyor.
- [ ] Koyu temada tüm yüzeyler koyu, metinler ve kontroller okunur açık tonlarda.
- [ ] Pomodoro sayfasının altında tarihli oturum geçmişi var; iptaller ve tamamlanmalar doğru ayrılıyor.
- [ ] İnternet/Hugging Face yokken yerel motivasyon devam ediyor; token uygulamaya gömülmemiş.
- [ ] İki soft tema, okunabilirlik, boş/yüklenen/hata durumları tamam.
- [ ] Yerel kalıcılık, kullanıcı ayrımı ve güvenli gezinme temizliği doğrulandı.
- [ ] Backend eklenmedi; demo sınırları açık, boş işlevli buton yok.
- [ ] Kritik testler ve analiz başarılı; README kurulum/çalıştırmayı açıklıyor.

---

## 7. Antigravity İçin Uygulama Talimatı

Dosyayı proje köküne koyup aşağıdaki talimatı kullan:

```text
ALISKANLIK_TAKIBI_PROJE_PLANI.md dosyasının tamamını ve mevcut projeyi oku.
Mevcut Flutter kökünü kullan; iç içe proje oluşturma. Klasör boşsa projeyi burada oluştur.
Bu şartnamedeki Flutter/Dart frontend uygulamasını çalışır şekilde geliştir.
Backend, Firebase, Supabase ve gerçek e-posta servisi ekleme.
Türkçe, Material 3, soft açık/koyu tema ve hafif yerel bileşenler kullan.
provider + ChangeNotifier ve SharedPreferencesAsync ile ortak durum/yerel veri yönet.
Giriş, kayıt ve şifre yenilemeyi açıkça etiketlenmiş yerel demo olarak uygula.
Parolaları açık metin kaydetme; ağır türetme işlemi arayüzü kilitlemesin.
12 kullanıcı sayfasını, açılış ekranını ve üç sekmeli MainShell'i tamamla.
Alt menü Ana Sayfa–Görevler–Pomodoro olsun; eski Profil sekmesini kaldır.
Ana sayfa sağ üstte Takvim–Bildirim–Avatar sırasını uygula; avatar Profil'i açsın.
Avatar seçimini Profil'den Ayarlar'daki Profil Fotoğrafı bölümüne taşı; 8 hazır insan/hayvan seçeneğini ve mevcut seçimi koru.
Seçili avatar Profil ve ana sayfada anında güncellensin; Profil'de seçim ızgarası kalmasın.
Profil sağ üst dişlisi ayrı Ayarlar sayfasını açsın.
Ayarlar'da avatar, açık/koyu tema, mevcut/yeni/tekrar parola ve motivasyon tercihleri alt alta bulunsun.
Koyu temada bütün ekranlar, kartlar ve pencereler koyu; metinler, alanlar ve ikonlar okunaklı açık renkli olsun.
Motivasyon tercihlerini Profil'den Ayarlar'a taşı; mevcut seçimleri koru.
Şifre değişiminde mevcut parolayı doğrula, yeni parolayı güvenli yerel yöntemle kaydet; oturumu koru.
Görevleri gerçek yerel tarihten hesapla; tik/bar ve aynı gün geri almayı bağla.
Geri almada ilerleme ve completedAtUtc güncellensin; bütün listeler, takvim ve istatistikler aynı kaydı kullansın.
Geri alınan kart normal ve tamamlanmamış görünsün; takvimde yalnızca ilgili görevin işareti kalksın.
Tamamlananları soluk, tek çizgiyle çizilmiş biçimde Yapılanlar'a taşı.
Streak'i planlı günlere göre hesapla; ara günlerde bozma, aynı günü iki kez sayma.
Düzenleme ve kaldırmada geçmişi koruyan kuralları uygula.
Görev düzenleme aynı habitId üzerinde yapılsın; seri plan sürümleri boyunca devam etsin, sıfırlanmasın.
Takvim, profil, rozet ve istatistikleri aynı kayıtlardan üret.
Takvimde her görevi farklı kalıcı soft renkle göster; çoklu gün işaretlerini ve renk açıklamasını ekle.
MainShell'in sağ altına, alt menünün üstüne motivasyon maskotu ve konuşma balonu yerleştir.
Maskotun etkin kullanım aralığını ve Ayarlar'daki tercihleri 6.2.13–6.2.15'e göre uygula.
Başarılı tamamlamada seçilen üstten mesaj/parıltı/alev biçimini her gerçek geçişte bir kez göster.
Aynı gün geri alıp yeniden tamamlamak yeniden efekt üretsin; günlük sayı ve streak çift artmasın.
Eski günlük kutlama kilidini completionRevision olaylarıyla değiştir; yüklemede efekt oynatma.
Pomodoro'da 25/5/15 varsayılanlarını koru; sayfadaki Süre Ayarları ile çalışma, kısa mola ve uzun molayı değiştirilebilir yap.
Süreleri doğrula ve kullanıcıya özel sakla; çalışan/duraklatılmış aşama ve geçmiş korunarak yeni süreleri sonraki aşamalara uygula.
Başlat/duraklat/devam/bitir kontrollerini ve aşağı kaydırılan oturum geçmişini uygula.
Tek controller ve kayıtlı bitiş zamanı kullan; sekme/tema değişiminde süre sıfırlanmasın.
Yeniden açılışta mevcut aşamayı en fazla bir kez tamamla; sıradaki aşamayı kullanıcı başlatsın.
Pomodoro geçmişi kullanıcıya özel olsun; molalar çalışma sayılmasın, alışkanlık otomatik tamamlanmasın.
Odaklanma sırasında maskotun periyodik mesajlarını durdur.
Yerel Türkçe mesaj havuzunu zorunlu, doğrulanmış Hugging Face veri kaynağını isteğe bağlı yap.
Uzak kaynak başarısızsa yerel/cache mesajı kullan; gizli tokenı istemciye koyma, backend ekleme.
Eski kayıtları sürüm 4'e veri kaybetmeden taşı; görevleri, geçmişi, renkleri ve tercihleri koru.
Hatırlatmaları uygulama içinde, belirtilen zaman penceresinde ve kopyasız oluştur.
6.6'daki dosya düzenini ve 6.4'teki aşama sırasını izle.
Gereksiz paket ekleme; boş işlevli buton veya sabit sahte istatistik bırakma.
Kritik testleri, biçimlendirmeyi ve flutter analyze kontrolünü çalıştır.
Ulaşılabilen hedefte ana akışı dene; denemediğin platformu açıkça belirt.
README'ye kurulum, demo hesap, çalıştırma ve demo sınırlarını yaz.
```

## 8. İleride Eklenebilecek Özellikler

Gerçek kimlik doğrulama/backend, cihazlar arası senkronizasyon, SQLite, işletim sistemi bildirimleri, haftanın günlerine göre tekrar, ad/e-posta düzenleme, yedekleme ve arşiv geri yükleme ileriki sürümlerde ele alınabilir. İlk sürüme kendiliğinden eklenmez. Açık/koyu tema, Ayarlar üzerinden hazır avatar seçimi ve kişiselleştirilebilir Pomodoro süreleri bu belgenin mevcut kapsamındadır.

## 9. Teknik Kaynaklar

- [Flutter durum yönetimi](https://docs.flutter.dev/data-and-backend/state-mgmt/simple)
- [Flutter gezinme](https://docs.flutter.dev/ui/navigation)
- [Flutter yerelleştirme](https://docs.flutter.dev/ui/internationalization)
- [Flutter test yaklaşımı](https://docs.flutter.dev/testing/overview)
- [provider](https://pub.dev/packages/provider) ve [shared_preferences](https://pub.dev/packages/shared_preferences)
- [intl](https://pub.dev/packages/intl) ve [cryptography PBKDF2](https://pub.dev/documentation/cryptography/latest/cryptography/Pbkdf2-class.html)
- [Hugging Face — Veri kümesi indirme](https://huggingface.co/docs/hub/datasets-downloading)
- [Hugging Face — Inference Providers ve kimlik doğrulama](https://huggingface.co/docs/inference-providers/index)
- [Pomodoro — Resmî klasik zamanlayıcı](https://www.pomodorotechnique.com/solutions/pomodoro-classic-timer/)

