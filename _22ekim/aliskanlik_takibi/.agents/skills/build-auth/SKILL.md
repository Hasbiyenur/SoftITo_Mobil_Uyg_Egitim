---
name: build-auth
description: Alışkanlık Takibi Flutter projesinde demo giriş, kayıt, çıkış, şifremi unuttum, şifre değiştirme veya yerel kullanıcı ayarları/avatar üzerinde çalışırken kullan.
---

# Demo Kimlik ve Kullanıcı Ayarları Akışı

1. **Giriş ve Kayıt**:
   - Girişte logo, e-posta, şifre, Giriş Yap, Kaydol ve Şifremi Unuttum bağlantısını bağla.
   - Demo kullanıcı: `demo@aliskanlik.com` / `demo1234`.
   - Kayıtta ad, soyad, e-posta ve doğrulanan şifreyi al; aynı e-postayı ikinci kez kaydetme.
2. **Şifre Sıfırlama ve Değiştirme**:
   - Şifre sıfırlamada yerel demo kodunu üret, ekranda demo olarak göster, doğrulamadan sonra iki yeni şifre alanını zorunlu tut ve girişe dön.
   - Ayarlar (`SettingsScreen`) içindeki Şifre Değiştir bölümünde: Mevcut şifreyi doğrula, yeni şifre ve yeni şifre tekrarını kontrol et (en az 6 karakter, yeni şifreler eşleşmeli).
3. **Profil ve Avatar Yönetimi**:
   - Avatar seçimi `SettingsScreen`'deki Profil Fotoğrafı bölümünden yapılır (8 hazır avatar seçeneği).
   - Profil sayfasında avatar seçici bulunmaz, sadece aktif avatar gösterilir.
   - Avatar ve tema tercihleri `AppSettings` modeliyle kullanıcı bazında saklanır (`store.appSettingsByUser`).
   - Yeni avatar seçildiğinde anında Ayarlar, Profil ve Ana Sayfa sağ üst avatarında güncellenir.
4. **Güvenlik ve İzolasyon**:
   - Parolayı asla açık metin kaynak dosyasına, JSON'a veya loglara koyma (PBKDF2/SHA256 salt & hash kullanılır).
   - Repository işlemlerini etkin kullanıcıya göre sınırla; çıkışta yalnızca oturumu ve geçici ekran durumunu temizle, diğer hesapların kayıtlarını silme.
   - Çıkış yapıldığında çalışan Pomodoro oturumu varsa duraklatılmalı, oturum durumu bozulmamalıdır.