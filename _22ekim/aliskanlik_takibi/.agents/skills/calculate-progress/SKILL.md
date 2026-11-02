---
name: calculate-progress
description: Alışkanlık Takibi projesinde planlı gün, aktif seri, başarı rekoru, takvim, rozet, Pomodoro odak süresi veya istatistik hesaplamalarını yazarken ve güncellerken kullan.
---

# İlerleme ve İstatistik Hesaplamaları

1. **Tarih ve Takvim Prensipleri**:
   - Takvim günü farkını yerel gün bileşenlerinden (`DateKey`, 'yyyy-MM-dd') türet; geçen saat sayısını 24'e bölerek takvim günü belirleme.
   - Bir tarih ancak geçerli başlangıç ve plan sürümüne göre planlıysa seriye ve paydaya dahil edilir.
   - Ara dinlenme günleri seriyi bozmaz; kaçırılmış planlı gün bozar.
2. **Görev İstatistikleri**:
   - İstatistikleri tekil `HabitEntry` kayıtlarından hesapla. Kısmi ilerlemeyi tamamlanma sayma; sıfır paydada oranı 0 ve açıklayıcı metni göster.
   - 10, 25 ve 50 planlı gün serileri için rozetleri hesapla; geçmişte kazanılmış geçerli rozetleri seri kırıldı diye kaldırma. Aynı gün geri alma sonucu geçersizleşen rozeti uzlaştır.
3. **Pomodoro Odak Süresi Hesaplaması**:
   - Günlük odak süresi (Focused Minutes), tamamlanmış odak oturumlarının gerçek kaydedilmiş sürelerinden toplanır: `dailyFocusedMinutes = sessions.where((s) => s.phase == 'focus' && s.completed).fold(0, (sum, s) => sum + (s.focusedSeconds ~/ 60))`.
   - Oturum sayısını sabit 25 dakika ile çarparak hesaplama YAPMA; kullanıcı özel sürelerini yansıt.
   - 4 tamamlanan odak oturumu sonrası bir sonraki aşama otomatik olarak uzun mola (`longBreak`) olur.
4. **Veri ve Şema Bütünlüğü (Schema v4)**:
   - Mevcut kullanıcı verilerini, tamamlanma geçmişlerini, streak'leri ve oturumları koru; demo veya kullanıcı verilerini sıfırlama.
   - Eksik alanları varsayılanlarla doldur (ör. süre tercihleri yoksa 25 / 5 / 15 ekle).
5. **Testler**:
   - Ay/yıl geçişleri, aralıklı tekrar, gün değişimi, süre doğrulama, seri hesaplama ve Pomodoro gerçek süre toplamları için birim testleri çalıştır.