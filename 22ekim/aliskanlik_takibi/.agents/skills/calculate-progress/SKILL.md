name: build-ui description: Alışkanlık Takibi Flutter uygulamasının Türkçe ekranlarını, gezinmesini, temasını veya ortak widget'larını oluşturup düzenlerken kullan.
Ekran ve etkileşim
PROJECT.md, ana planın 3. bölümü ve ilgili ekranın 6.2 bölümünü oku.
Türkçe Material 3 arayüz ve yumuşak renkler kullan. Logo ve temel görselleri hafif yerel widget'larla çiz.
MainShell içinde sadece Ana Sayfa, Görevler, Profil alt sekmelerini sabit tut. Takvim ve istatistikleri belirtilen giriş noktalarından aç.
Formları gerçek controller işlemlerine bağla; boş onPressed, sahte sayaç, işlevsiz filtre veya gezinmeyen buton bırakma.
Yapılanlar kartlarını aşağı taşı, başlığı tek çizgiyle çiz ve daha soluk göster. Boş, yükleniyor ve hata durumlarını anlaşılır metinlerle sun.
Mobil ekranda taşmaları kontrol et; metin ölçeği, dokunma alanı, kontrast ve klavye açıldığında form görünürlüğünü doğrula.
En az bir erişilebilir cihazda temel ekran geçişlerini ve görev tamamlama akışını çalıştır.