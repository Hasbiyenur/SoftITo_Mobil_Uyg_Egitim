# design.md - Uygulamanın Tasarım Sistemi

## 1. Tasarım İlkeleri

- Tasarım modern, sıcak ve dikkat dağıtmayan bir karaktere sahip olmalıdır.


## 2. Görsel Dil

- Stil:  yumuşak ve editoryal.
- Bileşenler: Hafif yuvarlatılmış köşeler ve kontrollü boşluklar.
- İkonlar: Tutarlı bir ikon ailesi kullanılmalıdır.
- Kartlar: Yalnızca içeriği gruplamak veya etkileşimi açıklamak için kullanılmalıdır.
- Animasyonlar: Kısa, işlevsel ve kullanıcıyı bekletmeyecek düzeyde olmalıdır.

## 3. Renk Sistemi

Aşağıdaki değerler başlangıç tasarım paletidir; tasarım uygulaması boyunca merkezi olarak yönetilmelidir.

### Açık Tema

- Ana Turuncu (Primary - #E06A3B)
- İkincil Turuncu (Secondary - #F39C12)
- Arka Plan (Background - #FCF9F5)
- Yüzey (Surface - #FFFFFF)
- Metin (Text - #2C3E50 & #2C2C2C)
- Destekleyici/Vurgu (Accent): Arayüzü zenginleştirmek için yumuşak bej ve toprak tonları.
### Koyu Tema

- Ana Turuncu (Primary - #D35400)
- İkincil Turuncu (Secondary - #A04000) 
- Arka Plan (Background - #1A120B)
- Yüzey (Surface - #2D1F16)
- Metin (Text - #E0DCD3)

### Durum Renkleri

- Başarılı (Success - #27AE60)
- Uyarı (Warning - #F1AC0D)
- Hata (Error - #B03A2E)

### Renk Kullanım Kuralları

- Renkler merkezi bir tema tanımında tutulmalıdır.
- Widget'larda rastgele sabit renkler tanımlanmamalıdır.
- Metin ve arka plan arasında yeterli kontrast sağlanmalıdır.
- Hata ve başarı renkleri anlamlı durumlarda kullanılmalıdır.
- Koyu tema, açık temanın yalnızca renkleri ters çevrilmiş hâli olmamalıdır; uzun metin okumaya uygun kontrast korunmalıdır.

## 4. Tipografi

- Sistem fontu veya projede açıkça belirlenen bir font ailesi kullanılmalıdır.
- Ekran başlıkları, bölüm başlıkları, gövde metinleri ve yardımcı metinler ayrı stillerle tanımlanmalıdır.
- Açıklama metinleri uzun süre okunabilecek rahatlıkta olmalıdır.
- Metin boyutları rastgele widget bazında belirlenmemelidir.
- Metin ölçeklendirme desteklenmeli; büyük erişilebilirlik yazı boyutlarında içerik kırpılmamalıdır.

Önerilen başlangıç ölçekleri:

- Büyük ekran başlığı: 28 px
- Ekran başlığı: 24 px
- Bölüm başlığı: 18 px
- Gövde metni: 16 px
- Yardımcı metin: 14 px
- Küçük etiket: 12 px

## 5. Boşluk Sistemi

4 px tabanlı bir boşluk ölçeği kullanılmalıdır:

- 4 px: Çok küçük aralık
- 8 px: Yakın bileşenler arası aralık
- 12 px: Küçük grup aralığı
- 16 px: Standart iç boşluk
- 24 px: Bölümler arası aralık
- 32 px: Büyük bölüm aralığı

- Aynı türdeki bileşenler aynı boşluk değerlerini kullanmalıdır.
- Ekran kenar boşlukları genel olarak 20–24 px aralığında tutulmalıdır.
- İçerik yoğunluğuna göre bu değerler uyarlanabilir; ancak tutarlılık korunmalıdır.

## 6. Köşe Yuvarlaklıkları ve Bileşenler

- Küçük giriş ve kontrol bileşenleri: 12 px
- Kartlar: 16 px
- Büyük yüzeyler ve modal alanlar: 20 px
- Tam yuvarlak butonlar yalnızca tasarım sisteminde tanımlandığında kullanılmalıdır.

Bu değerler ortak tema veya bileşen tanımlarında merkezi olarak yönetilmelidir.

## 7. Butonlar

- Birincil butonlar temel eylemleri temsil etmelidir.
- İkincil butonlar daha düşük öncelikli eylemlerde kullanılmalıdır.
- Silme gibi yıkıcı işlemler, diğer eylemlerden görsel olarak ayrılmalıdır.
- Buton metinleri kısa ve eylem odaklı olmalıdır.
- İşlem devam ederken tekrar tıklamayla yinelenen kayıt oluşması engellenmelidir.
- Dokunma alanları erişilebilir kullanım için yeterli büyüklükte olmalıdır.

## 8. Form Alanları

- Başlık ve metin alanları birbirinden açıkça ayrılmalıdır.
- İpucu metinleri alanın amacını açıklamalıdır.
- Hata mesajları ilgili alanla ilişkilendirilmelidir.
- Klavye açıldığında odaktaki alan ve kaydetme eylemi kullanılabilir kalmalıdır.
- Metin yazılırken ekranın beklenmedik biçimde sıfırlanması veya odağın kaybolması engellenmelidir.

## 9. Durum Tasarımları

Her veri gösteren ekran gerektiğinde aşağıdaki durumları desteklemelidir:

- Normal içerik
- Boş içerik
- Yüklenme
- Hata
- İşlem başarısı
- Devam eden işlem

Boş durumlar kullanıcıyı bir sonraki uygun eyleme yönlendirmelidir.

## 10. Erişilebilirlik ve Responsive Tasarım

- Metin kontrastı yeterli olmalıdır.
- İkonların anlamı yalnızca renkle ifade edilmemelidir.
- Etkileşimli öğelere erişilebilir etiketler verilmelidir.
- Farklı ekran genişliklerinde taşma oluşmamalıdır.
- Büyük metin boyutlarında içerik kesilmemeli veya eylemler erişilemez hâle gelmemelidir.
- Klavye, güvenli alanlar ve sistem gezinme alanları dikkate alınmalıdır.

## 11. Flutter Uygulama Kuralları

- Tema `ThemeData` ve uygun Material tema yapılandırmaları üzerinden yönetilmelidir.
- Tekrar kullanılan renkler ve metin stilleri merkezi olarak tanımlanmalıdır.
- Aynı görsel bileşen için birden fazla tutarsız stil oluşturulmamalıdır.
- Ekranlara özel farklılıklar ortak tasarım sistemini bozmadan uygulanmalıdır.