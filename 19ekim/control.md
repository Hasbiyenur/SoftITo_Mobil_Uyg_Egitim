# Fitness Su Takip Uygulaması
Bu doküman Flutter Projesinde geliştirme yapacak olan Ajan (antigravity) yapay zeka ve yazılım geliştiriciler için bağlatyıcı bir kılavuzdur. Projede üretilen her kod satırı burdaki kurallara UYMAK ZORUNDADIR.

## 1. Proje Özeti ve Teknolojiler
- **Uygulama adı:** Susadım (akıllı su egzersiz ve kalori takibi uygulaması)

- **Hedef Platformlar:** Ios ve android öncelikli ardından web ve masaüstü platformları.

- **Flutter SDK:** 3.29.0

- **Dart SDK:** 3.0.0

- **Tasarım Dili:** Material 3, Koyu Tema (gece spor salonu paleti, dark obsidian & neon);

---

## Mimari Yapı: Özellik bazlı
kodlar kesinlikle tek bir yerde toplanmayacaktır. Her modülkendi feature klasöründe kodlanacaktır.

```
text
lib/
core/
extension'lar
        constans/app_color.dart
        theme/app_theme.dart
    
    features/
        water_traker/
            controller/
            models/
            view/
            widget/
        workout/
            controller/
            models/
            view/
            widget/

    main.dart
```

#### sadece uygulama başlatma ve tema bölümleri

## 3 Kırmızı Çizgiler Kod Kalite Standartları
1 - **State Yönetim Standartları:**
Sayfa düzeyinde ağır `setState` KULLANILMAYACAKTIR.
Sadece yerel arayüz durumunu yöneten (örneğin buton animasyonları vb.) StatefulWidget kabul edilir.

2 - **UI ve Performans Kuralları:**
Statik tüm widget!lara `const` zorunludur.
Renk ve metin stilleri kesinlikler tema dosyalarına yazılacaktır.
Büyük build methodları yasaktır. 40 satırı geçen build metodları özel widgetlara yazılacaktır.

3 - **Yasaklı Paketler:**
Projede onay almadan harici ağır state paketleri EKLENMEYECEKTİR
Dart'ın ve Flutter'n yerel çekirdek apilerini kullanmak esastır.

## 4 Geliştirme Analiz ve Test Komutları
Ajan yaptığı herhangi bir kod değişikliklerinden sonra mutlaka alttaki komutların çalıştığını doğrulamalıdır.

* **Statik Kod Analizi(0 uyarı ve 0 hata şart):**
```bash
flutter analyze
```

* **Birim ve Widget Testleri:**
```bash
flutter test
```

* **Projeyi Çalıştırma:**
```bash
flutter run 
```

## 5 Ajanın Çıktı ve Yanıt Verme Standartları

**Açıklama:**
Türkçe teknik terimlerin özünü bozmadanr net ve doğrudan olacaktır.

**Değişiklik Sunumları:**
Örnek 500 satırlık bir dosyada 3 satır değiştiyse tüm dosyayı baştan sonra yazma; hedef satırları ve diff yapısını göster.

**Dosya Yolları:**
Bahsedilen ve üretilen her dosya için mutlaka projeye göre tıklanılabilir link ver.

**Doğrulama:** Kod yazdıktan sonra kullanıcıya "Şimdi Flutter analiz ile kontrol edebilirsin" şekline doğrulama yönergeliri ver.