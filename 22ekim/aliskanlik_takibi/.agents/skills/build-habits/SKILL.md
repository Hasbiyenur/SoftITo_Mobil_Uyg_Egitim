---
name: build-habits
description: Alışkanlık Takibi projesinde görev listesi, görev ekleme ve düzenleme, günlük ilerleme, tik/miktar sayacı veya kaldırma geliştirirken kullan.
---

# Alışkanlık ve Görev İş Akışı

1. **Plan ve Görev Tanımları**:
   - Ekleme ve düzenleme için aynı formu kullan. Başlık, başlangıç tarihi, tekrar aralığı, sayaç türü (tik veya miktar sayacı), hedef miktar/birim, hedef saati ve hatırlatıcıyı doğrula.
   - Bugünün görev listesini cihazın yerel takvim gününden (`DateKey`) ve geçerli plan sürümünden üret.
2. **Kayıt ve İlerleme**:
   - Her alışkanlık ve gün için tek `HabitEntry` tut.
   - Tik veya miktar hedefi tamamlanınca kartı "Yapılanlar" bölümüne taşı; aynı gün geri almayı (undo) destekle.
   - Tamamlanan görev kartlarında soluk metin veya üstü çizili görünüm kullanırken Koyu ve Açık temada okunabilirliği garanti et (`darkCompletedText: #8F9E95`).
   - Geri alınan görev gün içinde tekrar tamamlandığında `completionRevision` artırılmalı ve kutlama efekti (`onHabitCelebration`) yeniden tetiklenmelidir.
3. **Veri Bütünlüğü**:
   - Plan değişikliklerini eski kayıtların anlamını koruyacak sürümlerle sakla.
   - Görevi kaldırmadan önce kullanıcıdan onay al; geçmiş kayıtları fiziksel olarak silme.
   - Kullanıcı verilerini, görev geçmişini ve streak'leri koru; şema yükseltmelerinde (Schema v4) verileri temizleme.
4. **Mimari Ayrım**:
   - Controller, repository ve hesaplama servislerini ayrık tut.
   - Ana sayfa ve Görevler ekranlarının aynı veri kaynağından senkronize olduğunu doğrula.