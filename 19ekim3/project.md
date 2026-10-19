# Susadım v1 - Proje Planı ve Spesifikasyon Dokümanı

## 1. Proje Amacı ve Kapsamı
**Susadım v1**, kullanıcıların günlük su tüketim hedeflerini kolayca takip etmelerini, yaptıkları spor/egzersiz aktiviteleriyle yaktıkları kalorileri izlemelerini ve sağlıklı yaşam alışkanlıkları kazanmalarını sağlayan, modern estetiğe (Dark Obsidian & Neon) sahip reaktif bir mobil sağlık uygulamasıdır.

Bu proje, Flutter ekosisteminde **Clean Architecture**, **Feature-Driven Mimari** ve saf **ValueNotifier Reaktif Durum Yönetimi** ilkelerini somutlaştırmak üzere kurgulanmıştır.

---

## 2. Temel Modüller ve İşlevsel Özellikler

### A. Su Takip Modülü (`lib/features/water_tracker`)
- **Dinamik Günlük Hedef:** Kullanıcı tanımlı veya önerilen günlük hedef (varsayılan: 2500 ml).
- **Hızlı Tüketim Butonları:** 
  - Standart Bardak: `+200 ml`
  - Kupa: `+330 ml`
  - Matara / Şişe: `+500 ml`
  - Özel Miktar Ekleme: Manuel giriş diyaloğu.
- **Canlı İlerleme Göstergesi:** Günlük hedefe ulaşma yüzdesini gösteren dairesel/dalga animasyonlu reaktif ilerleme halkası.
- **Tüketim Geçmişi ve Zaman Damgası:** Gün içinde saat bazında eklenen tüketimlerin listelenmesi, tekil silme ve gün sonu sıfırlama.
- **Hidrasyon İpuçları:** Gün boyunca kullanıcıyı motive eden dinamik sağlık ve hidrasyon kartları.

### B. Egzersiz ve Aktivite Modülü (`lib/features/workout`)
- **Aktivite Türleri:** Tempolu Yürüyüş, Koşu, Bisiklet, Yüzme, Ağırlık / Fitness, HIIT.
- **Kalori & Süre Hesaplama:** Girilen süreye (dakika) ve aktivite MET katsayısına göre anlık yakılan kalori tahmini.
- **Günlük Aktivite Özeti:** Yakılan toplam kalori, tamamlanan egzersiz süresi ve aktivite listesi.
- **Su İhtiyacı Entegrasyonu:** Yapılan egzersiz yoğunluğuna göre ek su tüketim önerisi (örn: her 30 dk egzersiz için +250 ml).

### C. Çekirdek Yapı ve Görsel Kimlik (`lib/core`)
- **Tasarım Dili (Dark Obsidian & Neon):**
  - Arka Plan: Koyu Obsidyen (`#12131A`, `#1A1C24`)
  - Su Vurgusu: Neon Aqua / Cyan (`#00D2FF`, `#00F5D4`)
  - Egzersiz Vurgusu: Neon Lime & Enerjik Turuncu (`#70E000`, `#FF9E00`)
  - Metin / Nötr: Saf Beyaz (`#FFFFFF`) ve Soluk Gri (`#A0A5B5`)
- **Uygulama İkonu ve Logo:** Dinamik neon su damlası ve nabız/aktivite halkası birleşimi.
- **Platform Uyumluluğu:** iOS (iPhone 17 ve modern simülatörler) ve Android için optimize edilmiş duyarlı arayüz.

---

## 3. Mimari ve Kodlama Prensipleri (`SKILL.md` Uyumluluğu)

1. **Feature-Driven Modüler Klasör Yapısı:**
   Tüm ekran ve yetenekler `lib/features/<feature_name>/` altında izole modüller halinde inşa edilir:
   - `controllers/`: İş kuralları, durum bildirimleri (`ValueNotifier`) ve veri işleme.
   - `models/`: Değişmez (`immutable`) veri modelleri, `copyWith`, `fromJson` ve `toJson`.
   - `view/`: `StatelessWidget` tabanlı, yalnızca UI düzenini içeren ekran sınıfları.
   - `widgets/`: 40-60 satırı geçmeyen, yeniden kullanılabilir atomik alt bileşenler.

2. **Reaktif State Yönetimi (`ValueNotifier` & `ValueListenableBuilder`):**
   - Ağır üçüncü parti state yönetim paketleri (Bloc, Riverpod vb.) yerine, Flutter'ın yerel ve yüksek performanslı `ValueNotifier` mimarisi kullanılır.
   - Tüm ekran yeniden çizilmez; yalnızca değeri değişen atomik widget `ValueListenableBuilder` ile güncellenir.
   - Controller nesneleri yaşam döngüsü bittiğinde `dispose()` metoduyla dinleyicilerini serbest bırakır.

3. **Clean Code & Performans Standartları:**
   - **Const Zorunluluğu:** Değişmeyen tüm widget ve nesneler `const` anahtar kelimesi ile oluşturulur.
   - **Separation of Concerns:** UI içinde doğrudan iş mantığı, hesaplama veya asenkron veri çağrısı yapılamaz.
   - **Sıfır Hata ve Uyarı:** Kod tabanı `flutter analyze` linter kurallarına tam uyumlu olmalıdır.
   - **Birim Test Edilebilirlik:** Controller ve model katmanları Flutter UI kütüphanesinden bağımsız birim testlerle (`test/features/...`) doğrulanabilir olmalıdır.
