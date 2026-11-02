---
name: build-ui
description: Alışkanlık Takibi Flutter uygulamasının Türkçe ekranlarını, gezinmesini, temasını (Açık/Koyu), Pomodoro sayacını veya ortak widget'larını geliştirirken kullan.
---

# Ekran, Gezinme ve Tema İş Akışı

1. **Gezinme Mimarisi**:
   - `MainShell` alt menüsünde 3 sekme bulunur: `Ana Sayfa` (indeks 0), `Görevler` (indeks 1), `Pomodoro` (indeks 2).
   - Ana sayfa sağ üst butonları: Takvim, Bildirimler ve Profil Avatarı. Profil avatarına tıklandığında `ProfileScreen` açılır.
   - Profil ekranının sağ üstündeki çark simgesi `SettingsScreen`'i açar.
2. **Ayarlar ve Profil**:
   - `SettingsScreen` dikey olarak sırasıyla 4 bölümden oluşur:
     1. **Profil Fotoğrafı**: 8 hazır insan/hayvan avatarı (seçili avatar çerçeve ve tik ile belirtilir).
     2. **Görünüm**: Açık Tema ve Koyu Tema seçimi.
     3. **Şifre Değiştir**: Mevcut şifre, yeni şifre ve yeni şifre tekrarı formu.
     4. **Motivasyon Tercihleri**: Maskot, konuşma balonu ve tamamlama kutlama ayarları.
   - Profil sayfasında avatar seçim alanı bulunmaz; sadece seçilmiş olan avatar gösterilir.
   - Yeni avatar seçildiğinde Ayarlar önizlemesi, Profil ve Ana Sayfa sağ üst avatarı anında güncellenir.
3. **Pomodoro Sayacı**:
   - Pomodoro ekranı sayacın üzerinde "Süre Ayarları" paneli barındırır (Çalışma: 1–180 dk, Kısa Mola: 1–60 dk, Uzun Mola: 1–120 dk; Uzun Mola >= Kısa Mola).
   - "Süreleri Kaydet" ve "Varsayılana Döndür" (25/5/15) butonları bulunur.
   - Oturum hazır durumdayken süre kaydı sayacı anında günceller; aktif/duraklatılmış oturumda kalan süre ve döngü korunur, yeni süreler sonraki aşamalarda geçerli olur ve açıklama gösterilir.
   - 4 tamamlanan çalışma sonrası uzun mola düzeni korunur.
   - Günlük odak süresi, tamamlanmış oturumların gerçek çalışma sürelerinden (`focusedSeconds ~/ 60`) toplanarak hesaplanır (sabit 25 dk ile çarpılmaz).
4. **Tema ve Renk Standartları (Material 3)**:
   - Açık ve Koyu tema tam uyumludur (`app_colors.dart`, `app_theme.dart`).
   - Koyu tema: `#18201D` arka plan, `#242D29` kart/yüzey, `#AEC9A5` birincil renk, `#EEF3EF` başlıklar/yazılar, `#B7C5BC` ikincil yazılar.
   - Asla sabit siyah (`Colors.black`) veya sabit beyaz (`Colors.white`) yüzey/yazı kullanma; temaya duyarlı (`Theme.of(context).colorScheme`) kullan.
   - Takvim görev renklerinin soft pastel tonlarını koru; neon renkler kullanma.
5. **Görsel Kontroller**:
   - Ekran taşmaları, klavye açılma durumları (`viewInsets.bottom`), kontrast ve dokunma alanlarını doğrula.