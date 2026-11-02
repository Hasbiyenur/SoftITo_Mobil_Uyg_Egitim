## 1. Sözleşmeler, SOLID prensipleri § OOP Mimarisi
### 1.1 `interface` (arayüz/sözleşme)
***Sözlük anlamı:** iki bağımsız sistemin veya sınıfın birbirleriyle nasıl konuşacağını belirleyen, içi boş metot imzalarından oluşan kurallar bütünü.
***Neden kullanılır:*** bir sınıfa göbekten bağımlı kalmamak (örneğin gerçek şarj istasyonu cihazı olmadan sahte/mock şarj servisiyle testi çalıştırabilmek) için.
```dart
abstract interface class StationContract{
    Future<void> startCharging(String socketId);
    Stream<double> watchLivePower();  
}
```

---
### 1.2 `implements` (uygulama) vs `extends` vs `with`
### 1.2.1 `implements` (Arayüz sözleşmesi)
**Sözlük anlamı:** bir sınıfın, bir şablonun belirlediği kuralları kabul edip **içini sıfırdan kendisinin doldurması** zorunluluğudur.

***Neden kullanılır:*** Farklı sınıflara ortak bir standart/sözleşme dayatmak, çoklu arayüz desteği sağlamak ve kodda bağımlılıkları azaltmak için.


#### 1.2.2 `extends` (Kalıtım/Miras)
**Sözlük anlamı:** Bir sınıfın, başka bir sınıfın özelliklerini ve metotlarını doğrudan devralması.

***Neden Kullanılır:*** Kod tekrarını önlemek (DRY), mantıksal bir sınıf hiyerarşisi oluşturmak için.


#### 1.2.3 `with` (mixin/yetenek aşılama)
**Sözlük anlammı::** sınıf hiyerarşisini bozmadan, bağımsız bir sınıfa hazır kod blokları (metotlar ve değişkenler) enjekter etme mekanizmasıdır.

***Neden Kullanılır:*** Akraba olmayan sınıflara ortak yetenekler kazandırmak, çoklu kalıtım kimliğini önlemek  ve modülerliği arttırmak için.

---
### 1.3 SOLID Prensipleri (Mobil & Dart Odaklı)
#### 1. S - Single Responsibility Principle (Tek Sorumluluk Prensibi)
***Kural:*** bir sınıfın veya dosyanın değişmesi için **yalnızca 1 sebebi** olmalıdır.

#### 2. O - Open/Closed Principle (Açık/Kapalı Prensibi)
***Kural:*** yazılım varlıkları (sınıflar, modüller) **genişletilmeye AÇIK, ancak değiştirilmeye KAPALI** olmalıdır.

#### 3. L - Liskov Substitution Principle (Liskov Yerine Geçme Prensibi)

***Kural:*** Bir üst sınıfın yerine, onun alt sınıflarından herhangi biri geçirildiğinde sistemin davranışı bozulmamalı ve hata fırlatılmamalıdır.

#### 4. I - Interface Segregation Principle (Arayüz Ayırma Prensibi)
***Kural:*** İstemciler(sınıflar), kullanmadıkları metotları içermeye zorlanmamalıdır. şişman(fat) interface'ler yerine küçük, amaca yönelik arayüzler kurulmalıdır.

#### 5. D - Dependency Inversion Principle (Bağımlılık Tersine Çevirme Prensibi)
***Kural:*** Yüksek seviyeli modüller (UI, iş mantığı), düşük seviyeli (veritabanı, HTTP istemcisi) doğrudan bağlı olmamalıdır. Her ikisi de soyutlamalara (ìnterfac) bağlı olmalıdır.

---
### 1.4 `Coupling` (Bağlaşıklık) & `Cohesion` (Uyum)
**Tightly Coupled (sıkı bağımlı):** Sınıfların birbirinin her detayını bilmesi ve birinde yapılan bir harflik değişiklik diğer 5 dosyayı bozuyorsa sistem sıkı bağımlıdır.

**Loosely Coupled (gevşek bağımlı):** Sınıfların sadece interface üzerinden konuşması. Biri değiştiğinde diğeri etkilenmez.

**High Cohesion (yüksek uyum):** Bir sınıfın sadece ve sadece kendi uzmanlık alanını yapması.

---
## 2. STREAM TEMELLERİ, CUBİT & ENTERPRISE BLOC MİMARİSİ

### 2.1 `Stream` Nedir? (Bloc'un Kalbindeki Motor)
**Sözlük anlamı:** Zaman içinde parça parça gelen, akıp giden asenkron veri dizisi.

***Bloc Sırrı:*** BLOC kütüphanesi sihirili bir şey yapmaz! BLoC'un içinde gizli bir `StreamController` vardır. Event'ler borunun bir ucundan girer (`sink.add`), BLoC onları işler ve diper ucundan ekrana akıtır. (`stream.listen`).

---
### 2.3 BLoC'un 3 Temel Elemanı: `Event`, `State` ve `Emitter`**
**`Event` (Olay):** Kullanıcının veya sistemin BLoC'a attığı emit fişi.

***Mini Sözdizimi:*** `class StartChargingRequested extends ChargingState {final double kwh;}`

**`State` (Durum):** Ekranın o milisaniyedeki dondurulmuş fotoğrafı (snapshot).
***Mini Sözdizimi:*** `class ChargingActiveState extends ChargingState {final double kwh;}` 
**Özel Durumlar:** `Initial`, `Loading`, `Loaded`, `Error`

***Emitter:*** BLoc'un ürettiği yeni state'i ekrana fırlattığı megafon borusu.

***Kural:*** Senkron çalışır; `emit(NewState())` dendiği anda UI'daki builder'lar tetiklenir.

---

### 2.4 Altın Güvenlik Kilidi: `if (!isClosed)`

**Öğrenci Tuzağı / Çözme Sebebi:** Kullanıcı ekrandayken asenkron işlem başlar (`await api.fetchSockets()`). Kullanıcı cevap gelmeden geri tuşuna basıp sayfası kapatır. BLoC/Cubit  yok edildiği (closed) için hemen ardından gelen `emit()` satırı: 

***Hata:*** `StateError: Cannot emit new states after calling close` hatasını fırlatır ve uygulama çöker!

***Çözüm:*** Asenkron `await` satırından sonraki her emit mutlaka şu şekilde korunmalıdır:

```dart
final data = await repository.getData();
if (!isClosed) {
    emit(DataLoaded(data));
}
```

---

## 3. BLOC TÜKETİCİ WİDGET'LARI & KARAR AĞACI

### 3.1 `Side Effect`'in (Yan Etki) Neden 
* Flutter motoru ekranı saniyede 60 kez çizebilir (Rebuild). Eğer siz `BlocBuilder` içine `ScaffoldMessenger.showSnackBar` vya `Navigator.push` yazarsanız; kullanıcı cihazı yan çevirdiğinde veya klavye açıldığında kullanıcıya **üst üste 10 defa SnackBar patlar veya 10 kez yeni sayfa açılır!**
* **Kural:** Yan etkiler SADECE `BlockListener` içine yazılır; çünkü `listener` sayfa rebuild olduğunda değil, **yalnızca State değiştiğinde 1 kez** tetiklenir!

### 3.2 `BlocSelector` (Mikro Performans & Pil tasarrufu)
* **Kavram:** State'in içindeki onlarca alandan sadece **1 tanesini süzüp izlemek**.

---

## 4. EŞİTLİK, DEĞİŞMEZLİK & BLOBOBSERVER
### 4.1 `Referential Equality` vs `Value Equality`
* **Dart Varsayılan (Referans Eşitliği):** İki nesnenin bellekteki (RAM) adresi aynı mı?
`Soket ('A') == Soket('A')` -> **FALSE Çıkar!** \*\* İçerikleri aynı olsa da RAM'deki evleri farklıdır.\*\*

### 4.2 `props` Listesi Yazılmazsa Ne Olur?
* BLoC ekran kartını yormamak için şu denetimi yapar: `if (yeniState ==M eskiState) ekraniCizme();`.
* Eğer siz `StationLoaded` state'ine yeni bir `filterType` alanı eklerseniz ama `props` içine yazmayı unutursanız; BLoC iki state'i eşit zanneder ve **ekranı güncellemez, arayüz donuk kalır!**

### 4.3 `Immutability` (Değişmezlik) & `copyWith`
* **Kural:** State sınıflarının tüm alanları `final` olmalıdır (Değişmez).
* **`copyWith` Mantığı:** Eski nesnenin 5 alanını koruyup, sadece değişen 1 alanını güncelleyerek taze bir nesne üretme yöntemidir.

```dart
final guncel = state.copyWith(isCharging: true); //Diğer alanlar bozulmadan kopyalanır
```

### 4.4 `BlockObserver` (Tüm Uygulamayı Röntgenleme)
* **Kavram:** Uygulamadaki tüm BLoC ve Cubit'lerin arkasında çalışan merkez bir kara kutu/ telemetri kaydedici.
* **Ne işe Yarar?** Hangi ekrandan hangi Event fırlatıldı, State nereden nereye geçti (`onTransition`) ve nerede hata fırlatıldı (`onError`) tek merkezden konsola loglanır. Kurumsal projelerde analitik ve çökme takibi için zorunludur.

---

## 5. CLEAN ARCHİTECTURE KATMANLARI & SORUMLULUK DUVARLARI
### 5.1 `Entity` vs `Model/DTO`
* **`Entity` (Varlık):** Saf iş nesnesidir. Bir şarj soketinin gerçek hayattaki özelliklerini (`id`, `kw`, `durum`) tutar. `fromJson` ve `toJson` İÇERMEZ.
* **`Model/DTO`(Data Transfer Object):** API'den geeln ham JSON verisini karşılayan taşıyıcıdır. `Entity`'den türer; `fromJson` ve `toJson` metotlarını barındırır.
* *"Neden Entity içine `fromJson` yazamıyoruz? "*
* *(Cevap: Yarın backend JSON yerine XML veya Protobuf formatına geçerse; Domain katmanındaki iş kurallarımız ve UI sayfalarımız zerre kadar etkilenmesin, sadece DATA katmanındaki Model etkilensin diye!)*

### 5.2 `UseCase` (Kullanım Senaryosu)
* **Kavram:** Kullanıcının veya sistemin gerçekleştirebileceği **tek ve atomik bir iş kuralı**.
* **Örnekler:** StartChargingSessionUseCase, GetStationSocketsUseCase, RefundWalletBalanceUseCase.
* **Kural:** Her UseCase sınıfının içinde sadece tek bir call() veya execute() fonksiyonu bulunur.

### 5.3 `Repository Contract` (Sözleşme) `Repository Implementation` (Somut)

* **Contract (Domain Katmanında):** Sadece sözleşmedir (abstract interface class StationRepository). Verinin nereden geleceğini bilmez.
* **Implementation (Data Katmanında):** Sözleşmeyi uygulayan somut sınıftır (class StationRepositoryImpl implements StationRepository). Verinin önce yerel diskten mi yoksa internetten mi çekileceğine karar verir.

---

## 6. BAĞIMLILIK YÖNETİMİ: DEPENDENCY INJECTION & `get_it`

### 6.1 Neden `new Dio()` Yazmak Yasaktır?

Eğer 5 ayrı sayfada `final dio = Dio();` derseniz:

* Bellekte 5 ayrı bağlantı havuzu açılır, telefonun soket sınırını zorlar.
* Base URL veya Timeout değiştiğinde 5 ayrı dosyayı elle değiştirmek zorunda kalırsınız.
* Test yazarken sahte (mock) veri enjekte edemezsiniz.


### 6.2 `GetIt` Kayıt Tipleri: `Singleton` vs `LazySingleton` vs `Factory`
**`Singleton:`** Uygulama açıldığı milisaniyede nesneyi üretir ve belleğe çiviler.

**`LazySingleton:`** Uygulama açıldığında üretmez! Ne zaman ilk kez birisi `sl<Dio>()` derse o an üretir ve sonrasında hep aynı nesneyi verir. (Bellek ve açılış hızı dostudur).

**`Factory:`** Her çağrıldığında yepyeni, sıfır bir kopya üretir.

---

## 7. KURUMSAL AĞ MİMARİSİ: DIO, INTERCEPTOR & HTTP STATUS KODLARI
**Sözlük Anlamı:** Ağ isteği telefondan çıkıp internete gitmeden önce veya sunucudan cevap gelip koda düşmeden önce araya girip paketi inceleyen/değiştiren güvenlik noktası.

### 7.2. Bearer Token & Payload
**Bearer Token:** "Bu anahtarı taşıyan kişi giriş yapmaya yetkilidir" anlamına gelen şifrelenmiş kimlik kartı metni (Authorization: Bearer eyJhbGci...).

**Payload:** Bir API isteğiyle sunucuya gönderilen veya sunucudan bize dönen asıl veri gövdesi (Body).

### 7.3 HTTP Durum Kodları Sözlüğü (Sınıfa)

* **200 OK:** İstek başarılı, veri gövdede.
* **201 Created:** Yeni kayıt (örneğin yeni şarj oturumu) başarıyla oluşturuldu.
* **400 Bad Request:** İstemci hatası; eksik veya hatalı parametre gönderdin.
* **401 Unauthorized:** Token yok veya süresi dolmuş; hemen Login'e yönlendir!
* **403 Forbidden:** Giriş yaptın ama bu veriyi görmeye yetkin yok (Admin değilsin).
* **404 Not Found:** Aradığın soket veya istasyon sunucuda bulunamadı.
* **500 Internal Server Error:** Backend sunucusu patladı; istemcilik bir hata yok.

## 8. VERİ DAYANIKLILIĞI: CACHE-FIRST & SAVUNMACI KODLAMA

### 8.1. `Cache-First` (Önce Önbellek) Stratejisi
**Mantık:** Kullanıcı şarj istasyonu listesini açtığında 1 saniye bile beyaz ekranda spinner bekletme! Diskteki dünkü veriyi 0.01 milisaniyede ekrana bas. Arka planda sunucudan taze veriyi çek; gelince ekranı ve diski sessizce güncelle.

### 8.2 `Defensive Programming` (Savunmacı Programlama)
* **Mantık:** Sunucudan gelen veriye asla %100 güvenmeme prensibi.