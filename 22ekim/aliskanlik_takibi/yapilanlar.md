# Alışkanlık Takibi — Yapılan Geliştirmeler ve Yenilikler Raporu

Bu belge, güncellenmiş **`aliskanlik_takibi2.md`** şartnamesi doğrultusunda projeye eklenen yeni özellikleri, mimari kararları, dosya değişikliklerini ve yapılan doğrulama testlerini detaylı ve anlaşılır bir dilde açıklamak amacıyla hazırlanmıştır.

---

## 1. Genel Bakış ve Kapsam

Mevcut çalışan Flutter projesinin mimari yapısı, oturum yönetimi, görev ekleme/düzenleme/arşivleme, streak hesaplama, rozet ve yerel depolama mekanizmaları eksiksiz korunarak aşağıdaki üç ana odak alanında geliştirmeler tamamlanmıştır:

1. **Takvimde Görevlere Özel Soft Renkler ve Renk Açıklaması (Legend)**
2. **Sağ Altta Motivasyon Maskotu ve Zamanlayıcı Yönetimi**
3. **Görev Tamamlandığında Seçilebilir Kutlama Efektleri (Üstten Kayan Mesaj, Parıltı, Alev)**
4. **Profil Ekranında Motivasyon Tercihleri Paneli ve Çevrimdışı/Hugging Face Entegrasyonu**

---

## 2. Takvimde Görevlere Özel Renkler

### 2.1. Soft Renk Paleti ve Kalıcı Renk Yönetimi (`HabitColorService`)
- Her alışkanlığa kendine ait, göz yormayan, pastel/soft bir renk atandı (`lib/core/theme/habit_color_service.dart`).
- **Palet İçeriği:** Adaçayı Yeşili (`#3B6E52`), Soft Deniz Mavisi (`#4A7298`), Soft Lavanta (`#7C6DAF`), Sıcak Terrakotta (`#D97757`), Soft Gül Pembesi (`#C8657B`), Bal Sarısı (`#D49B35`), Soft Turkuaz (`#3D8B8B`), Kül Grisi (`#6E7D88`), Sıcak Kum (`#8B7355`), Zeytin Yeşili (`#5A7D65`), Pastel Leylak (`#9E6B8A`), Pastel Şeftali (`#E28A6E`), Buz Mavisi (`#4D859E`), Yosun Yeşili (`#8A9A5B`).
- **Otomatik Renk Önerisi:** Kullanıcı yeni bir görev eklerken (`HabitFormScreen`), kullanıcının mevcut görevlerinde (arşivlenmişler dahil) henüz kullanılmamış ilk soft renk otomatik olarak seçilir. Kullanıcı dilerse paletten rengi değiştirebilir.
- **Kalıcılık:** Renkler görev nesnesi (`Habit.colorValue` ve `Habit.colorHex`) içinde yerel olarak saklanır. Uygulamanın yeniden açılması, sıralamalar veya görev arşivleme renkleri kesinlikle bozmaz.

### 2.2. Çoklu Görev Tamamlama Noktaları ve "+n" Göstergesi
- Aynı gün birden fazla görev tamamlandığında, takvim hücresi tek bir renge boyanmaz; tamamlanan her görev kendi renginde hücrenin altına ayrı bir yuvarlak nokta olarak yerleştirilir.
- Hücrede en fazla 3 işaret gösterilir. 3'ten fazla görev tamamlandıysa ilk iki görevin rengi ve kalanlar için `+n` (örn: `+1`, `+2`) formatında küçük sayısal gösterge çizilir.
- Tamamlanmamış ve gelecek günler başarı olarak işaretlenmez.

### 2.3. Takvim Renk Göstergesi (`CalendarLegend`) ve Detay Listesi
- Takvim ızgarasının hemen altına `CalendarLegend` bileşeni eklendi. Burada görevlerin ikonları, adları ve soft renkleri kartlar halinde açıklanmaktadır.
- Takvimde herhangi bir güne basıldığında, o gün planlanmış ve tamamlanmış tüm görevler kendi özel soft renk çizgisi, ikonu, başlığı ve sayaç bilgisiyle listelenir.

---

## 3. Motivasyon Maskotu

### 3.1. Konum ve Vektörel Karakter Tasarımı (`MotivationMascot`)
- `MainShell` içine yerleştirilerek **Ana Sayfa**, **Görevler** ve **Profil** sekmelerinin sağ alt köşesinde, alt navigasyon menüsünün hemen üzerinde yer alması sağlandı.
- Görevler sekmesinde altta "Düzenle / Kaldır" buton çubuğu bulunduğundan, maskot butonları kapatmayacak şekilde dinamik olarak ayarlandı.
- Karakter, projeye harici ağır görsel/font yüklememek amacıyla Flutter `CustomPainter` ile vektörel olarak çizildi: Minik pastel saksı/taş, gülümseyen sevimli yüz, pembe yanaklar, tatlı filiz sapı ve iki yumuşak yeşil yaprak.
- Maskot, kullanıcıyı rahatsız etmeyen hafif ve yumuşak bir dikey salınım (nefes alma) animasyonuna sahiptir. Sistem hareket azaltma (reduce motion) modundaysa animasyon otomatik durur.

### 3.2. Zamanlama, Konuşma Balonu ve Akıllı Duraklatma
- **İlk Mesaj:** Uygulama açılıp etkin kullanım başladığında 15 saniye sonra ilk motivasyon mesajı balon içinde gösterilir.
- **Periyodik Mesajlar:** Sonraki mesajlar varsayılan olarak 5 dakikada bir (kullanıcı tercihine göre 3, 5 veya 10 dakika) konuşma balonunda gösterilir.
- **Konuşma Balonu (`MotivationBubble`):** Maskotun sol-üst tarafına tatlı bir kart görünümünde açılır. Yaklaşık 6 saniye görünür kalır ve istenirse dokunularak anında kapatılabilir.
- **Dokunma ile Cümle:** Maskota tıklandığında hemen yeni bir motivasyon cümlesi gösterilir. Art arda spam yapılmasını önlemek için 10 saniyelik bekleme filtresi uygulanmıştır.
- **Akıllı Duraklatma:**
  - Sekme değişimlerinde zamanlayıcı baştan başlatılmaz, tek bir merkezi `MotivationController` üzerinden yürütülür.
  - Uygulama arka plana geçtiğinde (`AppLifecycleState.paused`), klavye açıldığında veya diyalog açıldığında zamanlayıcı duraklatılır; ekrana dönüldüğünde mesaj yığılması yaşanmaz.
  - Kullanıcı çıkış yaptığında (`logout`) tüm zamanlayıcılar güvenle iptal edilir.
  - Kullanıcı profilden maskotu kapattığında (`mascotEnabled: false`) maskot ve periyodik mesajlar tamamen gizlenir.

### 3.3. Zengin Türkçe Cümle Havuzu (`LocalMotivationMessages`)
- Suçlayıcı veya zorlayıcı olmayan, tamamen destekleyici en az 23 adet kısa Türkçe motivasyon cümlesi hazırlandı.
- Son gösterilen 5 cümle hafızada tutulur ve aynı cümlelerin art arda tekrarlanması önlenir.

---

## 4. Görev Tamamlandığında Kutlama

### 4.1. Kutlama Türleri (`CompletionFeedbackController`)
Görev tik atılarak veya miktar barı doldurularak tamamlandığında, kullanıcının seçtiği kutlama gösterilir:
1. **Üstten Kayan Mesaj (`CompletionBanner` - Varsayılan):** Ekranın üstünden güvenli alandan yumuşakça aşağı kayan, ~2.5 saniye ekranda kalan ve "Bir adım daha attın, harika!", "Tebrikler! Bir görevi daha başarıyla tamamladın." gibi motive edici sözler içeren soft kart.
2. **Yumuşak Parıltı Efekti (`CompletionEffect - sparkle`):** Ekranın üzerinde ~1.5 saniye boyunca pastel altın, adaçayı ve lavanta tonlarında minik yıldız ve parıltı taneciklerinin yükselip kaybolduğu zarif efekt.
3. **Küçük Pastel Alev Efekti (`CompletionEffect - flame`):** ~1.5 saniye boyunca terrakotta, şeftali ve bal tonlarında yukarı süzülen pastel alev tanecikleri.
4. **Kapalı (`off`):** Görev sessizce tamamlanır, kutlama gösterilmez.

### 4.2. Güvenlik ve "Günde Tek Sefer" Kuralı (`celebrationShownAtUtc`)
- **Tek Seferlik Kutlama:** Bir görev tamamlandığında `HabitEntry.celebrationShownAtUtc` alanına UTC zaman damgası kaydedilir. Kullanıcı aynı gün görevi geri alıp (uncheck / decrement) tekrar tamamlarsa, **ikinci bir kutlama tetiklenmez**.
- **Yalnızca Başarılı Kayıtta Tetiklenme:** Kısmi ilerlemede, başarısız kayıtta, ekran açılışında veya demo veri tohumunda asla kutlama patlamaz.
- **Çakışma Önleme:** Hızlı ardışık görev tamamlamalarında efektler veya afişler üst üste binmez; bekleyen zamanlayıcı sıfırlanarak birleşik mesaj gösterilir.
- **Maskot Mesajını Erteleme:** Bir kutlama gerçekleşirken maskotun periyodik konuşma balonu çakışmaması için ertelenir.
- **Erişilebilirlik:** Ekran dokunmalarını engellemez (`IgnorePointer`), ses çıkarmaz ve sistem hareket azaltmayı seçmişse hareketli animasyon yerine sade metin gösterilir.

---

## 5. Motivasyon Tercihleri ve Hugging Face Durumu

### 5.1. Profil Ekranındaki Tercihler Paneli (`MotivationPreferencesPanel`)
Profil sayfasına "Çıkış Yap" butonunun hemen üstüne şık bir ayarlar paneli yerleştirildi:
- **Motivasyon Maskotu:** Açık / Kapalı anahtarı.
- **Mesaj Aralığı:** 3 dakika / 5 dakika / 10 dakika açılır menüsü.
- **Tamamlama Kutlaması:** Üstten Mesaj, Parıltı, Alev ve Kapalı seçenekleri (ChoiceChip).
- **Çevrimiçi Motivasyon Kaynağı (Hugging Face):** Açık / Kapalı anahtarı.

### 5.2. Çevrimdışı Çalışma ve Hugging Face Durumu
- **%100 Çevrimdışı Öncelik:** Motivasyon sistemi internet bağlantısı olmadan, yerel Türkçe cümle havuzuyla eksiksiz ve bağımsız çalışır.
- **Hugging Face Entegrasyonu (`HuggingFaceMotivationSource`):**
  - Servis, 5 saniyelik zaman aşımı (timeout) ve 24 saatlik önbellekleme (`StoreDocument.motivationCache`) kurallarına uygun olarak mimariye entegre edilmiştir.
  - Hiçbir API anahtarı veya gizli token kaynak koduna veya `.env` dosyasına gömülmemiştir.
  - Kullanıcı adı, e-posta, görev adları veya alışkanlık geçmişi gibi hiçbir kişisel veri asla dış servise iletilmez.
  - Herkese açık, token istemeyen ve şartnamedeki kriterlere (Türkçe, <120 karakter, destekleyici dil) uyan bağımsız bir public veri seti yapılandırılmadığı sürece sistem sessizce ve güvenle yerel zengin havuzla (`LocalMotivationMessages`) çalışmaya devam eder.

---

## 6. Veri Tabanı ve Migration (Sürüm 1 → Sürüm 2)

Yerel depolama anahtarı (`habit_tracker_store_v1`) korunarak `StoreDocument` şeması sürüm 2'ye taşındı:
- Eski sürümden gelen kayıtlardaki renk çakışmaları `HabitColorService.resolveColorCollisions` ile otomatik olarak kalıcı benzersiz tonlara dönüştürüldü.
- Eski kullanıcılar, görevler, geçmiş tamamlamalar ve rozetler hiçbir kayba uğramadan korundu.
- Kullanıcı bazlı tercihler (`motivationPreferencesByUser`) ve önbellek (`motivationCache`) alanları eklendi; migration işlemi sırasında sahte kutlama tetiklenmesi engellendi.

---

## 7. Yapılan Doğrulama ve Test Sonuçları

1. **Kod Biçimlendirme:** `dart format lib test` çalıştırıldı, tüm kodlar kurallara göre biçimlendirildi.
2. **Statik Kod Analizi:** `flutter analyze` çalıştırıldı:
   - **Sonuç:** `No issues found!` (0 hata, 0 uyarı).
3. **Birim ve Arayüz Testleri:** `flutter test` çalıştırıldı:
   - Eski testler: 16 test başarıyla geçti.
   - Yeni eklenen testler:
     - `test/habit_color_service_test.dart` (Palette, Hex ve çakışma testleri)
     - `test/motivation_features_test.dart` (Yerel havuz, maskot controller, tercihler ve tek seferlik kutlama testi)
     - `test/calendar_colors_test.dart` (Takvim çoklu renk noktaları ve legend testi)
   - **Genel Test Sonucu:** **27 testin tamamı eksiksiz geçti (`All tests passed!`).**

---

## 8. Değişen ve Yeni Eklenen Dosyaların Listesi

### Yeni Eklenen Dosyalar:
- `lib/core/theme/habit_color_service.dart`: Soft renk paleti, hex dönüştürücü ve çakışma önleyici servis.
- `lib/data/models/motivation_preferences.dart`: Kullanıcı motivasyon tercihleri modeli.
- `lib/data/models/motivation_message.dart`: Motivasyon cümle modeli.
- `lib/data/motivation/local_motivation_messages.dart`: 23+ adet yerel Türkçe motivasyon ve kutlama cümlesi.
- `lib/data/motivation/hugging_face_motivation_source.dart`: İsteğe bağlı Hugging Face veri çekme servisi (timeout & offline uyumlu).
- `lib/data/motivation/motivation_repository.dart`: Yerel ve çevrimiçi mesajları koordine eden repo.
- `lib/features/motivation/motivation_controller.dart`: Maskot süresi, konuşma balonu ve tercihler controller'ı.
- `lib/features/motivation/completion_feedback_controller.dart`: Üstten mesaj, parıltı ve alev kutlama yöneticisi.
- `lib/features/motivation/widgets/motivation_mascot.dart`: Vektörel çizilmiş filiz maskotu bileşeni.
- `lib/features/motivation/widgets/motivation_bubble.dart`: Maskot konuşma balonu.
- `lib/features/motivation/widgets/completion_banner.dart`: Üstten kayan motivasyon tebrik bandı.
- `lib/features/motivation/widgets/completion_effect.dart`: Yumuşak parıltı ve pastel alev parçacık animasyonu.
- `lib/features/motivation/widgets/motivation_preferences_panel.dart`: Profil ekranı motivasyon ayarları bileşeni.
- `lib/features/calendar/widgets/calendar_legend.dart`: Takvim renk açıklama göstergesi.
- `test/habit_color_service_test.dart`: Renk servisi testleri.
- `test/motivation_features_test.dart`: Motivasyon ve kutlama testleri.
- `test/calendar_colors_test.dart`: Takvim renkleri ve gösterge testleri.
- `yapilanlar.md`: Yapılan tüm işlemleri açıklayan bu rapor.

### Güncellenen Dosyalar:
- `lib/data/models/habit.dart`: `colorHex` ve `color` yardımcı özellikleri, hex destekli JSON dönüşümü.
- `lib/data/models/habit_entry.dart`: Günde tek kutlama takibi için `celebrationShownAtUtc` alanı.
- `lib/core/storage/store_document.dart`: Sürüm 2 şeması, motivasyon tercihleri/önbelleği ve migration mantığı.
- `lib/data/repositories/habit_repository.dart` & `local_habit_repository.dart`: Motivasyon tercihlerini ve önbelleğini saklama/okuma metotları.
- `lib/data/demo/demo_seed.dart`: Demo görevlerinin soft renkleri ve demo kullanıcısı motivasyon tercihleri.
- `lib/app/app_providers.dart`: Yeni repository ve controller'ların Provider ağacına eklenmesi.
- `lib/app/bootstrap_screen.dart`: Uygulama açılışında motivasyon sisteminin kullanıcıyla başlatılması.
- `lib/app/main_shell.dart`: Maskot, konuşma balonu ve kutlama katmanlarının yerleşimi.
- `lib/features/calendar/screens/calendar_screen.dart`: Çoklu renkli noktalar, `+n` taşma göstergesi, takvim göstergesi (`CalendarLegend`) ve görev detay renklendirmesi.
- `lib/features/habits/habit_controller.dart`: İlk tamamlamada kutlama tetikleme, geri almada damgayı koruma mantığı.
- `lib/features/habits/screens/habit_form_screen.dart`: Boştaki soft rengin otomatik önerilmesi ve palet seçimi.
- `lib/features/profile/screens/profile_screen.dart`: Motivasyon tercihleri panelinin eklenmesi ve çıkışta temizleme.
- `lib/features/auth/screens/login_screen.dart`: Giriş yapıldığında motivasyon oturumunun başlatılması.
- `lib/features/home/screens/home_screen.dart`: Maskotun kartları kapatmaması için alt boşluk optimizasyonu.
