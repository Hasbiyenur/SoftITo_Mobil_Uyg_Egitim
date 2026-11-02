# Susadım (Akıllı Su, Egzersiz ve Kalori Takip Uygulaması) - Proje Planı

## 1. Proje Amacı ve Kapsamı
"Susadım", kullanıcıların günlük su tüketimlerini, spor/egzersiz aktivitelerini ve yaktıkları kalorileri takip etmelerini sağlayan, modern gece spor salonu estetiğine (Dark Obsidian & Neon) sahip bir mobil sağlık uygulamasıdır.

## 2. Temel Modüller ve Özellikler
### A. Su Takip Modülü (`water_tracker`)
- **Günlük Hedef Belirleme:** Kullanıcının günlük su ihtiyacı (varsayılan: 2500 ml).
- **Hızlı Ekleme:** Standart bardak (+200 ml), kupa (+330 ml), matara (+500 ml) veya özel miktar giriş butonları.
- **İlerleme Göstergesi:** Günlük hedefe ulaşma yüzdesini gösteren dairesel veya dalga göstergesi.
- **Tüketim Geçmişi:** Gün içinde saat bazında eklenen su miktarlarının listelenmesi ve gerekirse silinmesi.

### B. Egzersiz ve Kalori Modülü (`workout`)
- **Aktivite Seçimi:** Koşu, Bisiklet, Ağırlık Antrenmanı, Yüzme, HIIT vb.
- **Süre ve Kalori Hesabı:** Girilen süreye (dakika) göre tahmini yakılan kalori hesabı.
- **Günlük Toplam Kalori & Egzersiz Özeti:** Yakılan toplam kalori ve yapılan egzersizlerin listesi.

### C. Uyku Takip Modülü (`sleeptimer`)
- **Uyku ve Uyanma Zamanı Kaydı:** Kişinin uyuduğu (yatış) ve uyandığı (kalkış) zaman bilgisini alma/seçme.
- **Toplam Uyku Süresi Hesabı:** Yatış ve kalkış saatleri arasındaki toplam uyku süresinin (saat ve dakika cinsinden) otomatik hesaplanması.
- **Uyku Hedefi & Analiz:** Günlük hedeflenen uyku süresine (örn. 8 saat) göre başarı durumu ve geçmiş uyku kayıtları listesi.

### D. Çekirdek Yapı (`core`)
- **Tema & Renk Paleti:** Material 3 tabanlı, Koyu Obsidyen arka plan, Neon Mavi (su), Neon Yeşil/Turuncu (egzersiz) ve Neon Mor/İndigo (uyku) vurgu renkleri.
- **Yerel State Yönetimi:** Ağır paketler yerine Flutter'ın yerel `ChangeNotifier` / `ValueNotifier` mimarisi.

## 3. Mimari ve Kod Standartları (Kılavuz: `control.md`)
- Özellik bazlı modüler klasör yapısı (`lib/features/`).
- 40 satırı geçmeyen atomik UI bileşenleri.
- Tüm statik bileşenlerde `const` kullanımı.
- Sıfır hata ve sıfır uyarı (`flutter analyze`).
