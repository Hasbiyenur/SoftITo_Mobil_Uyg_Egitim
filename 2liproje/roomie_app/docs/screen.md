# screen.md — Ekran Gereksinimleri

## 1. Genel Kurallar

- Uygulama altı temel ekrandan oluşur.
- Ekranların görsel kuralları `design.md` dosyasında tanımlanır.
- Her ekranın yalnızca kendi sorumluluğuyla ilgili işlemleri gerçekleştirmesi beklenir.
- Ekranlar arasında gezinme tutarlı olmalıdır.
- Kullanıcı işlemleri yalnızca görsel değişiklikle sınırlı kalmamalı; ilgili davranışı gerçekten gerçekleştirmelidir.

## 2. Login Ekranı 

### Amaç

Kullanıcının hesabı varsa uygulamaya giriş yapmasını, yoksa kaydolmasını sağlamak.

### İçerik

- Uygulama Logosu
- Kullanıcının giriş yapması için gereken mail/kullanıcı adı ve şifre input alanları
- Giriş yap butonu
- Giriş yap butonunun hemen üstünde "Hesabın yok mu?" yazısı ve yanında "Kayıt Ol" linki

### Etkileşimler

- E-mail ve şifre alanları geçerli formatta doldurulmalıdır.
- Giriş yap butonu yalnızca geçerli giriş bilgileriyle etkinleştirilmelidir.
- Kayıt ol linkine tıklandığında Kayıt Ol ekranına geçilmelidir.
- Başarılı giriş sonrasında kullanıcı ana ekrana yönlendirilir.
- Hatalı girişlerde uygun hata mesajları gösterilmelidir.
- Giriş yapılırken kısa süreli splash ekranı ile yükleme hissi verilmelidir.

### Durumlar

- Başarılı giriş
- Hatalı giriş
- Giriş sırasında yüklenme
- Doğrulama hatası


## 3. Kayıt Ol Ekranı
### Amaç
Kullanıcının yeni hesap oluşturmasını sağlamak. Bu sayfa kullanıcı bilgileri, alışkanlıklar, lokasyon olmak üzere 3 aşamadan (kullanıcı bilgileri -> alışkanlıklar -> lokasyon) oluşur.Kullanıcı her aşamayı tamamladıktan sonra sonraki butonu ile diğer aşamaya geçer.

### İçerik
 
- Kullanıcı Bilgileri Input Alanları: isim-soy isim, mail adresi, telefon numarası, şifre, şifre tekrar, Profil fotoğrafı (isteğe bağlı), yaş, cinsiyet (kadın/erkek), meslek/okul adı

- Alışkanlıklar Input Alanları: Sigara kullanımı (evet/hayır), Evcil hayvan durumu (evet/hayır), uyku düzeni (gece/sabah/yok), temizlik hassasiyeti (yok, az, orta, çok), konuştuğu diller (Türkçe, İngilizce, Almanca, vb.)

- Lokasyon Input Alanları: İl, ilçe

- Uygulamanın Kullanıcıdan İstediği zorunlu adli sicil belgesi yükleme butonu.


### Etkileşimler

- Kullanıcı input alanlarına bilgilerini girip sonraki butonu ile diğer aşamaya geçer.
- Bir önceki aşamaya geri dönmek için geri butonu kullanılabilir.
- input alanlarından yanında parantez olanlar çoktan seçmeli (örneğin cinsiyet için kadın/erkek), diğerleri serbest metin alanlarıdır.
- Son aşamadaki il ve ilçe seçimleri drop down ile yapılmalıdır.
- input alanlarından biri boş bırakıldığında “Lütfen tüm alanları doldurun.” mesajı gösterilmelidir.
- Son aşamada “Kayıt Ol” butonuna tıklandığında kullanıcı kaydedilip ana ekrana yönlendirilmelidir.
- Giriş yapılırken kısa süreli splash ekranı ile yükleme hissi verilmelidir.
- Kullanıcı adli sicil belgesi yüklemek zorundadır. Bu butona tıklandığında e devlet sayfası harici sayfada açılmalıdır.
- Kullanıcı eğer öğrenci olduğu bilgisine evet derse , kullanıcıdan zorunlu öğrenci belgesi istenmelidir. Yine kullanıcı harici sayfaya yönlendirilmelidir.

### Durumlar

- Başarılı kayıt
- Eksik bilgi hatası
- Kayıt sırasında yüklenme


## 4. Keşfet - Home Page

### Amaç

Kullanıcıların ev veya oda arama, ilan verme ve ilanlara göz atma işlemlerini gerçekleştirmelerini sağlamak. İndirim ve kampanyalardan kullanıcıları haberdar etmek. 

### İçerik

- Grid yapısı içerisinde mevcut ilanlar listesi.
- Her ilan kartında ilan görseli, başlık, fiyat, konum, açıklama gibi temel bilgiler yer almalıdır. Ayrıca kart üzerinde favorileme butonu olmalıdır. 
- Filtreleme butonu ile filtreleme ekranına geçiş. Kart üzerinde incele butonu da olmalıdır.
- Arama çubuğu. 
- İlan verme butonu ile ilan verme ekranına geçiş. 
- İndirim ve kampanyaların kaydırılabilir carousel yapısında gösterilmesi. (Banner'lar)
- keşfette listenen ilanlarda eğer indirim varsa üzeri çizili şekilde indirimli fiyatının yazılı olduğu görsellik sunulmalıdır.

### Etkileşimler

- Kullanıcı arama çubuğuna metin yazarak arama sonuçlarını filtreleyebilir. Filtreleme sonuçları grid yapısı içerisinde gösterilmelidir.
- Kullanıcı filtreleme butonu ile filtreleme ekranına geçebilir. Filtreler bottomsheet olarak açılmalı ve fiyat aralığı, konum, evcil hayvana uygunluk, sigara kullanımı, uyku düzeni, temizlik hassasiyeti, konuştuğu diller gibi filtreler içermelidir.
- Kullanıcı ilan verme butonu ile ilan verme ekranına geçebilir. İlan verme ekranı ile yeni ilan oluşturabilir.
- Kullanıcı ilan kartındaki favorileme butonuna tıklayarak ilanı favorilerine ekleyebilir. Favori ilanlar ayrı bir sayfada gösterilmelidir.
- Kullanıcı ilan kartındaki incele butonuna tıklayarak ilanın detay sayfasına geçebilir.
- İndirim bannerlarında öğrenci indirimi, yeni kullanıcı indirimi ve kış sezon indirimi örneği dönmelidir.
    * öğrenci indirimi: öğrenci olduğu bilinen kullanıcıların (`isStudent == true`) kiralama ödemesinde otomatik %20 indirim uygulanır (uygulama tarafından ev/oda sahibine karşılanır).
    * yeni kullanıcı indirimi: yeni kayıt olan kullanıcıların kendi evlerini/odalarını ilk kiralamalarında uygulama ev/oda sahibinden komisyon almaz.
    * kış sezon indirimi: kasım-ocak arasında seçili büyükşehirlerde (İstanbul, Ankara, İzmir) listelenen ilanlarda kira ücretine %20 indirim uygulanır.
    * Kiralama Fiyat Hesabı: İlanlarda aylık kira bedeli yer alır. Rezervasyon süresine göre gün bazlı formül `(Aylık Kira / 30) * Kalınacak Gün Sayısı` üzerinden toplam tutar hesaplanır ve indirimler net olarak dökülür.


## 5. İlan Detay Sayfası

### Amaç

İlanı detaylı görüntülemek ve ilan sahibi ile iletişime geçmek.

### İçerik

- İlan başlığı
- İlan sahibi bilgileri
- İlan görseli
- İlan açıklaması
- İlan sahibi ile iletişime geçme butonu
- Favorileme butonu
- Kiralama butonu

### Etkileşimler

- Kullanıcı ilan sahibi ile iletişime geçme butonuna tıklayarak ilan sahibine mesaj gönderebilir.
- Kullanıcı favorileme butonuna tıklayarak ilanı favorilerine ekleyebilir. Favori ilanlar ayrı bir sayfada gösterilmelidir.
- Kullanıcı kiralama butonuna tıklayarak kiralama yapabilir. Kiralama işlemi kiralama butonuna tıklandıktan sonra aşağıdan açılan bottomsheet üzerinde kalınacak gün sayısı(takvim üzerinden, giriş çıkış tarihi seçerek) ve kişi sayısı seçilip ödeme yap butonuna tıklayarak gerçekleştirilecektir. Ödeme yapmak için aynı bottomsheet üzerinde kullanıcıdan kart bilgileri alınacaktır.

## 6. Favori İlanlar Sayfası

### Amaç

Kullanıcın keşfetteki ilanlardan seçtiği(favorilediği) ilanları görüntülemek. 

### İçerik

- Grid yapısı ile favori ilanlar listesi.
- Her ilan kartında ilan görseli, başlık, fiyat, konum gibi temel bilgiler yer almalıdır. Ayrıca kart üzerinde favorileme butonu olmalıdır. Bu buton işaretli olmalıdır.Kullanıcı isterse ilanı favorilerden kaldırabili.

### Etkileşimler

- Kullanıcı favori ilan kartındaki favorileme butonuna tıklayarak ilanı favorilerden kaldırabilir. 
- Kullanıcı favori ilan kartındaki incele butonuna tıklayarak ilanın detay sayfasına geçebilir.
- Kullanıcı favori ilan kartındaki kiralama butonuna tıklayarak kiralama yapabilir. Kiralama işlemi kiralama butonuna tıklandıktan sonra aşağıdan açılan bottomsheet üzerinde kalınacak gün sayısı(takvim üzerinden, giriş çıkış tarihi seçerek) ve kişi sayısı seçilip ödeme yap butonuna tıklayarak gerçekleştirilecektir. Ödeme yapmak için aynı bottomsheet üzerinde kullanıcıdan kart bilgileri alınacaktır.

## 7. Aktif Kiralamalar Sayfası

### Amaç
Kullanıcının aktif olarak kiralık tuttuğu veya kiraya verdiği ev/oda bilgilerini görmektir.

### İçerik

- Kiralık tutulanlar ve kiraya verilenler segmented tab ile ayrılmış bir üst bar şeklindedir.
- Kiralık tutulanlarda tüm sayfada gözükecek tek bir ekran, kiraya verilenlerde ise liste şeklinde ilanlar gözükmelidir.
- Kiralık tutulanlar kısmında kaç gün sonra çıkış yapılacağı ve ödenecek miktar yazmalıdır. Yine kiralık tutulan evin/odanın detaylı bilgileri yer almalıdır.
- Kiralık tutulanlar sayfasında evden/odadan çıkış yap butonu yer almalıdır.
- Kiraya verilenler listesindeki kartlarda kiraya verilen oda/ev ismi ve kiracının genel bilgileri yazmalıdır.


### Etkileşimler

- Kullanıcı kiralık tutulanlar ve kiraya verilenler segmented tabına tıklayarak ilgili sekmeye geçebilir.
- Kullanıcı kiralık tutulanlardaki aktif evin/odanın tüm bilgilerini (ev/oda bilgileri, kiraya veren bilgileri, ödenen ve kalan tutar, yaklaşan çıkış tarihi ve ev/oda sahibi ile iletişime geç butonu) sayfanın tamamında görmelidir. İletişime geç derse chat sayfasına yönlendirilmelidir.
- Kiralık tutulanlar sayfasındaki aktif kiralama sonlanmadan kullanıcı keşfetten yeni bir kiralama yapamaz (iş mantığı katmanında engellenir).
- Kiralık tutulanlar sayfasındaki aktif ilanın çıkış zamanı gelmediyse ama kullanıcı erken çıkış yapmak istiyorsa kullanıcıya onay diyaloğu gösterilir. Onaylandığında fiili kalınan gün sayısı kadar ücret kesilir, erken çıkılan günlerin tutarı demo iade simülasyonu olarak yansıtılır.
- Kiralık tutulanlar sayfasındaki aktif ilan, kullanıcı çıkış yapmadan önce evin son halinin fotoğrafını yüklemeden kaldırılamaz. Evin son halinin fotoğrafını yüklemek zorunludur.
- Çıkış fotoğrafı yüklendikten ve çıkış işlemi tamamlandıktan sonra kiralama kaydı "Daha Önce Kiraladıklarım" (geçmiş) sayfasına arşivlenir ve aktif kiralama durumu temizlenir.
- Kiraya verilenler listesindeki kartlarda kullanıcı kiracı bilgilerini (kiracının adı soyadı, cinsiyeti, fotosu vb. genel bilgileri) görüntülemelidir. Kullanıcı isterse kiracıya mesaj gönderebilir (Chat sayfasına yönlendirilir).
- Kiraya verilenler sayfasındaki listeden memnun olunmayan bir kiracı olursa kiracıya otomatik mesaj gönderilerek erken çıkış yapması istenilebilir.
- Keşfetten bir ilan kiralandığında aktif kiralananlar sayfasında ilgili ilan görünür olmalıdır.
- Kiraya yeni bir ilan verildiğinde bu ilan da kiraya verdiklerim kısmına eklenmelidir.
- Kiraya verilenler sayfasındaki ilanlar aktif ve pasif olarak kategorize edilmelidir. Ev/odasını kiraya veren kullanıcı bu aktiflik durumuna göre evinin durumunu takip edebilmelidir.


## 8. İlan Verme Ekranı

### Amaç
Kullanıcı sahip olduğu evi/odayı kiraya vermek ve paylaşmak istiyorsa bilgilerini doldurarak ilan koyabilir.

### İçerik

- İlan başlığı
- İlan görseli
- İlan açıklaması
- İlan sahibi bilgileri
- Tercih edilen kiracı özellikleri (yaş, cinsiyet, alışkanlıklar vb)
- Kira ücreti
- Ev/oda lokasyon bilgileri

### Etkileşimler

- Kiraya verilecek ev/odanın fotoğrafları eklenmelidir.
- Kiraya verilecek ev/odanın tüm bilgileri eksiksik girilmelidir.
- İlan verildikten sonra kiraya verdiklerim kısmına eklenmelidir.
- İlan verildikten sonra keşfetteki ilanlar arasında gözükmelidir.


## 9. Chat Sayfası

### Amaç
Kullanıcıların birbirleriyle mesajlaşmasını sağlamak. Kiracı ile ev/oda sahibi arasındaki iletişimi sağlamak.

### İçerik

- Daha önce yapılan sohbetler mesaj listesi şeklinde gözükmelidir. Her mesaj listesinde konuşan kişilerin fotoğrafları, isimleri ve son mesajları yer almalıdır. 
- Sohbet ekranında mesajlaşma ekranı bulunmalıdır. Bu ekranda mesajlar baloncuklar şeklinde gözükmelidir. Mesajlar sağda ve solda olmak üzere iki renkte gösterilmelidir.
- Mesaj kutusunun sağında emoji butonu bulunmalıdır.
- Mesaj kutusunun sağında fotoğraf gönderme butonu bulunmalıdır. Bu buton ile kullanıcı fotoğraf gönderebilir.

### Etkileşimler

- Kullanıcı konuşan kişilerin fotoğrafları, isimleri ve son mesajları ile mesaj listesini görüntüleyebilir. Konuşan kişilerin fotoğrafları yuvarlak ve ortalanmış olmalıdır. İsimleri fotoğrafın yanında üstte, son mesajları ise isimlerinin altında, birbirlerine daha yakın şekilde, fotoğraflardan biraz daha küçük punto ile yazılmalıdır. Mesajlar güncellendiğinde sohbet mesaj listesi otomatik olarak yenilenmelidir.
- Kullanıcı mesajlaşma ekranında mesaj gönderebilir. Gönderilen mesajlar sağda, diğer mesajlar solda gözükmelidir. Mesajların arka plan rengi farklı olmalıdır. Mesajlar baloncuk şeklinde gözükmelidir. Mesajlaşma ekranında mesaj gönderdikten sonra ekran aşağı kaydırılmalıdır.
- Mesaj yazarken sağdaki emoji butonuna tıklayarak emojiler açılabilir ve gönderilebilir. Emojiler de diğer mesajlar gibi konuşan kişiye göre sağda veya solda görünmelidir.
- Mesaj yazarken sağdaki fotoğraf gönderme butonuna tıklayarak fotoğraf gönderilebilir veya mesaja eklenebilir. Gönderilen fotoğraf, mesaj balonu içerisinde gözükmelidir.

## 10. Profil Sayfası

### Amaç
Kullanıcının kendi bilgilerini görebileceği ve düzenleyebileceği sayfa.

### İçerik
- Kullanıcı profil kartı 
- Kullanıcı profil kartı içerisinde kullanıcıya ait genel bilgiler yer almalıdır. Kullanıcının profil fotoğrafı(varsa), kullanıcı adı, mail adresi, öğrenci olup olmama durumu yer almalıdır.
- Kullanıcıya ait alışkanlıklar ve tercihler yer almalıdır. Bu bilgiler uyku alışkanlıkları, temizlik alışkanlıkları, sigara kullanımı, evcil hayvan sahibi olup olmama durumu, tercih edilen ev tipi vb. bilgilerdir. 
- Adreslerim seçeneği
- Daha önce kiralananlar seçeneği (kullanıcının daha önce kiraladığı ve çıkış yaptığı yani daha önce kullandığı evler/odalar)
- Kayıtlı ödeme yöntemi seçeneği (kredi kartı şeklinde)
- Uygulama yapımcısına gönderebilmek için bottomsheet olarak açılan feedback kutusu
- Açık/Koyu Tema geçiş butonu
- Çıkış yap butonu
- Hesabımı sil Butonu

### Etkileşimler
- Kullanıcı özet bilgilerinin yazdığı profil kartına bastığında detaylı bilgilerini görmelidir.
- Kullanıcı alışkanlıklarım ve tercihlerim seçeneğine tıkladığında detaylı tercih ve alışkanlıklarını görebilmeli ve isterse bunları düzenleyip kaydedebilmelidir.
- Kullanıcı adreslerim seçeneğine tıkladığında kayıtlı adreslerini görmeli (bottomsheet ile) ve isterse bunları düzenleyip kaydedebilmelidir.
- Kullanıcı daha önce kiralananlar seçeneğine tıkladığında daha önce kiraladığı evleri/odaları liste şeklinde görmelidir.
- Kullanıcı kayıtlı ödeme yöntemi seçeneğine tıkladığında kayıtlı kredi kartını görmeli (bottomsheet ile) ve isterse bunları düzenleyip kaydedebilmelidir.
- Kullanıcı feedback kutusuna tıkladığında feedback kutusu açılmalı(bottomsheet) ve kullanıcı feedbackini yazıp gönderebilmelidir. Gönderilen feedbackler anında alt sekmeye düşmelidir.
- Kullanıcı çıkış yap butonuna tıkladığında çıkış yapmalı ve giriş sayfasına yönlendirilmelidir.
- Kullanıcı hesabımı sil butonuna tıkladığında hesabı silinmeli ve giriş sayfasına yönlendirilmelidir.
- Kullanıcı tema değiştirme butonu ile uygulamayı açık veya koyu tema olarak ayarlayabilmeli

## 11. Daha Önce Kiraladıklarım Sayfası

## Amaç
Kullanıcının daha önce kullandığı ev/odaları liste şeklinde görebileceği ve listedeki bir elemana tıkladığında detaylı bilgilerine ulaşabileceği sayfa.

### İçerik

- Kullanıcının daha önce kiraladığı ve ödemesini yapıp çıkışını verdiği yani önceden kaldığı ama artık kalmadığı ev/odaların listesi. 
- Listelenen ev/odaların her biri için:
    - Ev/oda fotoğrafı (sol üstte)
    - Ev/oda başlığı (fotoğrafın sağ üstte)
    - Ev/oda sahibi bilgileri (ad soyad- telefon numarası)
    - Ev/oda konumu
    - Ev/oda ödeme bilgileri (ödenen ücret)
    - Ev/oda çıkış bilgileri (çıkış yapılan tarih ve kaç gün kalındığı)

### Etkileşimler

- Kullanıcı listeden bir kayda tıkladığında daha önceki işlemi için detaylı bilgilere ulaşmalıdır (ev/oda bilgileri, çıkış bilgileri, ücret bilgileri, kullanıcının evden çıkarken yüklediği fotoğraf)



