
Endpoint ve JSON Tasarımı

| **İşlem** | **HTTP Metodu** | **URL / Endpoint** | **Header** | **Body JSON / Response JSON** | **Durum** |
|-----------|-----------------|--------------------|------------|-------------------------------|-----------|
| Sipariş oluşturma | POST | /api/v1/siparisler | Authorization: Bearer \<token\><br>Content-Type: application/json | `{"kahve_adi": "Brew", "boyut": "Orta", "adet": 1, "toplam_tutar": 185.50}` | 201 Created (Giriş yapılmışsa)|
| Sipariş oluşturma (Login olmadan) | POST | /api/v1/siparisler | Authorization: Bearer \<token\><br>Content-Type: application/json | - | 401 Unauthorized |
| Cüzdan bakiye sorgulama | GET | /api/v1/kullanici/bakiye | Authorization: Bearer \<token\><br>(İsteğe bağlı: Accept: application/json) | `{"bakiye": 185.50, "para_birimi": "TRY"}` | 200 OK |
| Cüzdan bakiye sorgulama (Sunucu hatası) | GET | /api/v1/kullanici/bakiye | Authorization: Bearer \<token\> | - | 500 Internal Server Error |

Mülakat Sorusu:
    GET idempotenttir, çünkü aynı GET isteği birden fazla kez gönderilse de sunucudaki kaynak değişmez. POST ise idempotent değildir, çünkü aynı POST isteği tekrarlandığında her seferinde yeni bir sipariş oluşturulabilir.





1. KahveSiparisYönetici class ı birden fazla fonksiyonun (indirim uygulama, ödeme türü, veritabanına kaydetme ve bildirim fonksiyonları) görevlerineine bağlı bir şekilde çalıştığı için burada Single Responsibility Principle (Tek Sorumluluk) ihlal edilmiştir ve bu ihlal durum da spagetti kod gibi sorunlara sebep olur. Sınıfı verilen fonksiyonlara göre Bildirim - Ödeme - İndirim - Kayıt adlarında ayrı classlara bölünebilir, KahveSiparisYöneticisi classına bağlı şekilde bu classlar çalıştırılır.

2. Kodun bu kısmındaki durum ise Open/Closed Principle ihlaline sebep oluyor. Bir çok kez if-else kullanılması yeni bir örnek eklenilmek veya değiştirilmek istenildiğinde tüm sorguyu etkiler. 