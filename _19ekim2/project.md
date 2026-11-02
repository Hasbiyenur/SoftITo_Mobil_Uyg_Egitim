# Susadım v1 - Proje Planı ve Spesifikasyon Dokümanı

## 1. Proje Amacı ve Kapsamı
**Susadım v1**, kullanıcıların günlük su tüketim hedeflerini kolayca takip etmelerini, yaptıkları spor/egzersiz aktiviteleriyle yaktıkları kalorileri izlemelerini ve sağlıklı alışkanlıklar kazanmalarını sağlayan modern bir mobil sağlık takip uygulamasıdır.

## 2. Temel Modüller ve Özellikler

### A. Su Takip Modülü (`features/water_tracker`)
- **Günlük Hedef:** Kullanıcı tanımlı veya varsayılan 2500 ml günlük su hedefi.
- **Hızlı Ekleme:** Standart bardak (+200 ml), büyük bardak (+330 ml), matara (+500 ml) ve özel miktar giriş alanları.
- **İlerleme Göstergesi:** Günlük hedefe ulaşma oranını gösteren modern dairesel ve yüzdelik reaktif gösterge.
- **Tüketim Geçmişi & Sıfırlama:** Gün içindeki tüketim kayıtlarının saatleriyle listelenmesi ve gün başında/istendiğinde sıfırlanabilmesi.
- **Hidrasyon İpuçları:** Su tüketiminin sağlığa faydalarını hatırlatan dinamik bildirim/motivasyon kartları.

### B. Egzersiz ve Aktivite Modülü (`features/workout`)
- **Aktivite Türleri:** Tempolu Yürüyüş, Koşu, Bisiklet, Yüzme, Ağırlık / Fitness.
- **Süre ve Kalori Hesaplama:** Seçilen aktivite ve süreye (dakika) göre anlık yakılan kalori tahmini.
- **Günlük Kalori Özeti:** Gün içinde yakılan toplam kalori ve yapılan egzersizlerin listesi.

### C. Tema ve Görsel Deneyim (Karanlık & Aydınlık Mod)
- **Dinamik Tema Desteği:** Kullanıcının tek dokunuşla Koyu Obsidyen (Dark Obsidian) ve Buzul Beyazı / Kristal Aydınlık (Light Ice) temaları arasında geçiş yapabilmesi.
- **Koyu Mod:** Neon Cyan (su) ve Neon Lime (aktivite) vurgulu, gece spor salonu estetiği.
- **Aydınlık Mod:** Ferah beyaz/açık gri zemin, derin okyanus mavisi ve canlı zümrüt yeşili vurgulu gündüz hidrasyon estetiği.
- **Reaktif Tema Yönetimi:** `ValueNotifier<ThemeMode>` mimarisi ile uygulamanın anında ve akıcı biçimde temayı güncellemesi.

### D. Logo ve Görsel Kimlik
- **Uygulama İkonu & Logo:** Su damlası ve canlı dinamizmi temsil eden modern neon mavi ve zümrüt yeşili gradient tasarım.
- **Uygulama İçi Logo Bileşeni:** Başlıkta ve yükleme ekranında parlayan özel logo.
- **iOS AppIcon:** Simülatör ve ana ekran için uygun çözünürlüklerde ikon desteği.

## 3. Mimari ve Kod Standartları (`SKILL.md` Uyumluluğu)
1. **Modüler Dizin Yapısı (`lib/features/`):**
   - `controllers/`: İş mantığı ve `ValueNotifier` tanımları.
   - `models/`: `immutable` sınıflar, `copyWith`, `fromJson` ve `toJson`.
   - `view/`: `StatelessWidget` tabanlı temiz UI.
   - `widgets/`: Küçük, yeniden kullanılabilir atomik bileşenler.
2. **State Yönetimi:**
   - Ağır paketler yerine Flutter'ın saf `ValueNotifier` ve `ValueListenableBuilder` reaktif yapısı.
3. **Performans ve Kalite:**
   - Gereksiz yeniden çizimleri önlemek için tüm uygun yerlerde `const` kullanımı.
   - Sıfır hata ve sıfır lint uyarısı.
