name: build-auth description: Alışkanlık Takibi Flutter projesinde demo giriş, kayıt, çıkış, şifremi unuttum veya yerel kullanıcı verisi üzerinde çalışırken kullan.
Demo kimlik akışı
Önce kökteki PROJECT.md, ilgili değişiklik için ALISKANLIK_TAKIBI_PROJE_PLANI.md ekran akışları ve ARCHITECTURE.md belgelerini oku.
Girişte logo, e-posta, şifre, Giriş Yap, Kaydol ve Şifremi Unuttum bağlantısını bağla.
Kayıtta ad, soyad, e-posta ve doğrulanan şifreyi al; aynı e-postayı ikinci kez kaydetme.
Şifre sıfırlamada yerel demo kodunu üret, ekranda demo olarak göster, doğrulamadan sonra iki yeni şifre alanını zorunlu tut ve girişe dön.
Gerçek e-posta doğrulaması veya üretim güvenliği iddiasında bulunma. Parolayı açık metin kaynak dosyasına, JSON'a veya loglara koyma.
Repository işlemlerini etkin kullanıcıya göre sınırla; çıkışta yalnızca oturumu ve geçici ekran durumunu temizle, diğer hesapların kayıtlarını silme.
Başarılı ve hatalı giriş, kayıt, kod doğrulama, geçersiz sıfırlama oturumu ve yeniden açılış akışlarını doğrula.