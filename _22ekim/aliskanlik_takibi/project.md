Alışkanlık Takibi — Proje Rehberi
Bu belge uygulamanın kısa yönlendirmesidir. Ayrıntılı ürün şartnamesi için ALISKANLIK_TAKIBI_PROJE_PLANI.md dosyasını oku. Belgeler çelişirse ürün davranışı için proje planını esas al.
Hedef
Flutter ve Dart ile Türkçe, soft temalı, çevrimdışı bir alışkanlık takibi demosu geliştir. Gerçek backend, Firebase, Supabase, e-posta gönderimi ve işletim sistemi bildirimi ilk sürümün dışında kalır.
Kullanıcı akışı
Demo hesapla giriş yap veya yerel hesap oluştur.
Üç sekmeden Ana Sayfa, Görevler ve Profil arasında gez.
Görevler ekranında alışkanlık oluştur, düzenle ve onayla kaldır.
Bugünkü planlı görevi tikle veya miktar sayacıyla tamamla.
Takvimden günleri, profilden serileri, istatistiklerden oran ve rozetleri gör.
Temel kararlar
Cihazın yerel tarihi ve saati kullanılır; bugünün tarihi koda sabitlenmez.
Her alışkanlığın serisi yalnızca planlı günlerin ardışık tamamlanmasına göre hesaplanır.
Aynı günün ilerlemesi geri alınabilir; aynı gün iki tamamlama kaydı oluşturulmaz.
Hedef saati tamamlamanın son saati değildir; gün bitene kadar görev yapılabilir.
Kaldırılan alışkanlığın geçmiş kayıtları ve geçerli kazanılmış rozetleri korunur.
Hatırlatma sadece uygulama içindedir; kapalı uygulamada sistem bildirimi vaat edilmez.
Demo şifre sıfırlama gerçek e-posta sahipliği doğrulaması değildir.
Belgeler
Dosya
İçerik
ALISKANLIK_TAKIBI_PROJE_PLANI.md
Ekranlar, ayrıntılı kurallar ve Antigravity talimatı
ARCHITECTURE.md
Modüller, veri akışı ve dosya sorumlulukları
TASKS.md
Uygulama sırası ve bitirme ölçütleri
.agents/skills/*/SKILL.md
Görev bazlı AI çalışma talimatları
Çalıştırma
Flutter proje kökünde flutter pub get, ardından uygun cihazda flutter run çalıştır. iOS simülatöründe cihaz adını flutter devices ile doğrulayıp flutter run -d <cihaz-id> kullan. Kontrol için dart format ., flutter analyze ve flutter test çalıştır.