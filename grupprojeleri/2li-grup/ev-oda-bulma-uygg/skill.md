---
name: Ev-Oda Bulma Uygulaması Geliştirme Becerisi (Core Development Skill)
description: Bu yetenek, Ev-Oda Bulma uygulamasında yeni bir özellik, ekran veya model geliştirirken proje standartlarına (Clean Architecture, Bloc, Material 3) ve katı UI kurallarına tam uyulmasını garanti altına alır.
---

# Ev-Oda Bulma Uygulaması Geliştirme Becerisi (Core Development Skill)
Bu yetenek, Ev-Oda Bulma uygulamasında yeni bir özellik, ekran veya model geliştirirken proje standartlarına (Clean Architecture, Bloc, Material 3) ve katı UI kurallarına tam uyulmasını garanti altına alır.

## İlgili Dosyalar ve Referanslar
- **Proje Genel Standartları:** `project.md`
- **Ekran Gereksinimleri:** `screens.md`
* **Tasarım Kuralları:** `design.md`



## Geliştirme Çıktı ve Doğrulama Kuralları
- Ajan kod yazarken sadece değiştirilen veya eklenen satırları diff formatında göstermelidir (tüm dosyayı basmak yasaktır).
- Geliştirme bittiğinde ajanın mutlaka şu komutlarla sistemi test etmesi ve kullanıcıya bildirmesi gerekir:
  ```bash
  flutter analyze
  flutter test
  flutter run
  ```


## 2. Geliştirme Kuralları
- Kod okunabilir ve modüler olmalı.

- Her ekran ayrı bir dosyada tutulmalı

- Widget'lar gereksiz yere karmaşıklaştırılmamalı.

- Kod yapısını anlaşılır ve bakımı kolay olmalı.

- Gereksiz paketlerden ve karmaşık mimarilerden kaçınılmalı.

- kodlar kesinlikle tek bir yerde toplanmayacaktır. her modül feature klasöründe kodlanacaktır.

Flutter'ın yerleşik özellikleri yeterli olduğunda öncelikle bu özellikler kullanılmalıdır.Onay alınmadan yeni bir durum yönetimi paketi eklenmemeli veya kalıcı veri saklama yöntemi kesinleştirilmemelidir.


## 6. Mimari Kurallar
- Uygulama küçük ve anlaşılır bir dosya yapısına sahip olmalıdır.

- Her ekran kendi dosyasında bulunmalıdır.

- Aynı veri farklı ekranlarda birbirinden bağımsız kopyalar olarak tutulmamalıdır.

- Uygulamada BloC yapısı en temel ve basit hali ile proje gereksinimlerini kapsayacak şekilde kullanılmalıdır.

## 8. Geliştirme Analiz ve Test Komutları
Ajan yaptığı herhangi bir kod değişikliğinden sonra mutlaka alttaki komutların çalıştığını doğrulamalıdır. 

* **Statik kod analizi (0 uyarı ve 0 hata şart):**
```bash
flutter anaylze 
```

* **Birim ve widget testleri:**
```bash
flutter test
```

* **Projeyi Çalıştırma:**
```bash
flutter run
```

## 9. Ajanın çıktı verme ve yanıt verme standartları
**Açıklamalar:** Türkçe teknik terimlerin özünü bozmadan net ve doğrudan olacaktır.

**Değişiklik sunumları:** örnek 500 satırlık bir dosyada 3 satır değiştiyse tüm dosyayı baştan sona basma; hedef satırları ve diff yapısını göster.

**Dosya yolları:** Bahsedilen ve üretilen her dosya için mutlaka projeye göre tıklanabilir link ver.

**Doğrulama:** Kod yazdıktan sonra kullanıcıya "Şimdi flutter analiz ile kontrol edebilirsin" şeklinde doğrulama yönergeleri ver.





