# Roomio - Ev/oda arkadaşı bulma Uygulaması

### Projenin Özeti 
* 18 yaşından büyük öğrencilere ve çalışanlara yönelik ev/oda arkadaşı bulma uygulamasıdır.
* Yaşam tarzı, bütçe, alışkanlıklar ve konum tercihine göre ev arkadaşı/oda arkadaşı, kiralık ev/oda bulmalarına yardımcı olan topluluk odaklı bir platformdur.
* Bu platform sayesinde kullanıcılar ister kendi şehirlerinde isterlerse farklı şehirlerde ev ve oda arayabilir veya kendi evlerindeki boş odaları veya evlerini ev arayanlara kiralayabilir. 

### Hedef Kitle ve Platform
* Hedef Kitle: Üniversite öğrencileri veya 18 yaşından büyük bireyler
* Hedef platformlar: Android, IOS

### Kullanılacak Teknolojiler ve Teknik Bilgiler
* Programlama dili: Dart 3.13.5 (Doğrulandı)
* Flutter Versiyonu: Flutter 3.47.7 (Doğrulandı)
* Mimari: Clean Architecture
* Animasyon: Rive / Modern Flutter Animasyonları (Durum geçişleri, mikro etkileşimler)
* Veri Saklama Yöntemi: Canlı sunucu/backend kullanılmayacak. Başlangıçtaki örnek ev arkadaşı ilanları `assets/roommates.json` dosyasından çekilebilir; kullanıcının oluşturduğu profil, kaydettiği favoriler ve verdiği yeni ilanlar **Hive** kutusunda yerel olarak saklanmalıdır. Başlangıç verileri her açılışta kullanıcının değişikliklerini ezmez.
* State Management: BLoC
* Tasarım Yaklaşımı: Material Design 3 (design.md spesifikasyonu)

### Mimari ve Klasör Yapısı
```text
lib/
core/
    Bloc/
    Error/
    Extensions/
    Style/
    Theme/
    Utils/
    Widgets/
    Routing/
    Di/
data/
    Models/
    Repositories/
entities/
presentation/
    Screens/
    Widgets/
main.dart
```
Proje, Flutter'ın standart dosya yapısını temel alacaktır.
Kodlar, sorumluluklarına göre ayrı klasörlerde tutulacaktır.
Projenin tamamı Clean Architecture kurallarına uygun yapılmalıdır.

### Uygulama Kuralları
* İş mantığı ile UI ayrımı olmalı
* SOLID prensiplerine tam uyumlu olmalı
* Ortam değişkenleri, api keyler gibi gizli tutulması ve repolara pushlanmaması gereken her şey gizlenmeli. 
* Herhangi bir güvenlik açığına izin verilmemeli.


### Uygulamanın Görünüşü İle İlgili Kurallar
* Uygulama logosu telefon ana ekranında gözükmeli.
* Uygulama ilk açıldığında boş gözükmemesi için splash screen ve onboarding screen eklenmeli.
* Uygulamadaki ekranlarda kullanılmak üzere örnek kişiler, ilanlar oluşturulabilir.





