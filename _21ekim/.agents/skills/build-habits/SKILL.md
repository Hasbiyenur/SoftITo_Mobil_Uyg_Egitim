name: build-habits description: Alışkanlık Takibi projesinde görev listesi, görev ekleme ve düzenleme, günlük ilerleme, tik/miktar sayacı veya kaldırma geliştirirken kullan.
Alışkanlık iş akışı
PROJECT.md ve ana planın ekran, tarih/seri kurallarını oku. Mevcut Flutter kökünü kullan.
Ekleme ve düzenleme için aynı formu kullan. Başlık, başlangıç tarihi, tekrar aralığı, sayaç türü, hedef miktar/birim, hedef saati ve hatırlatma seçimini doğrula.
Bugünün listesini cihazın yerel takvim gününden ve geçerli plan sürümünden üret. Hedef saati gün sonu kısıtı olarak yorumlama.
Her alışkanlık ve gün için tek HabitEntry tut. Tik veya bar hedefi tamamlanınca Yapılanlar'a taşı; aynı gün geri almayı destekle.
Plan değişikliklerini eski kayıtların anlamını koruyacak sürümlerle sakla. Kaldırmadan önce onay al; geçmiş kayıtları fiziksel olarak silme.
Controller, repository ve saf hesaplama servislerini ayır. Ana sayfa ve görevler ekranlarının aynı değişimden güncellendiğini doğrula.
Gün değişimi, planlanmamış gün, sayaç sınırı, tekrar dokunuş, geri alma, düzenleme ve yeniden açma senaryolarını kontrol et.