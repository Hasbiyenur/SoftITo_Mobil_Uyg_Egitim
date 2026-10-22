name: calculate-progress description: Alışkanlık Takibi projesinde planlı gün, aktif seri, başarı rekoru, takvim, istatistik, rozet veya hatırlatma hesaplamalarını yazarken kullan.
İlerleme hesaplamaları
ALISKANLIK_TAKIBI_PROJE_PLANI.md dosyasının 6.4 ve 6.5 bölümlerini oku; veri modeli için ARCHITECTURE.md belgesine bak.
Takvim günü farkını yerel gün bileşenlerinden türet; geçen saat sayısını 24'e bölerek tekrar gününü belirleme.
Bir tarih ancak geçerli başlangıç ve plan sürümüne göre planlıysa paydaya girer. Ara dinlenme günleri seriyi bozmaz; kaçırılmış planlı gün bozar.
İstatistikleri aynı HabitEntry kayıtlarından hesapla. Kısmi ilerlemeyi tamamlanma sayma; sıfır paydada oranı 0 ve açıklamayı göster.
10, 25 ve 50 planlı gün serileri için rozetleri hesapla; geçmişte kazanılmış geçerli rozetleri seri kırıldı diye kaldırma. Aynı gün geri alma sonucu geçersizleşen yeni rozeti uzlaştır.
Hedef saatinden bir saat önceki uygulama içi hatırlatmayı tekil kimlikle oluştur; uygulama kapalıyken işletim sistemi bildirimi sözü verme.
Ay/yıl sınırı, aralıklı tekrar, gün değişimi, plan sürümü, aynı gün geri alma ve farklı kullanıcı ayrımı için hedefli testler çalıştır.