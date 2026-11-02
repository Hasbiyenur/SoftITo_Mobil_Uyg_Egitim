import 'package:flutter/material.dart'; //flutter kütüphanesinden materyal kütüphanesi çekilir.

class HataliveDogruRow extends StatelessWidget {
  // hatalivedogrumu classı stateless widget sayesinde içindeki veriler fonksiyonlar sabit kalır değiştirilemez.
  const HataliveDogruRow({
    super.key,
  }); // oluşturulan widget kimlik bilgisini üst sınıfa aktarır.

  @override
  Widget build(BuildContext context) {
    // uygulamanın temel yapısı kurulur. Widgetların ekranda nasıl nerede duracağını takip eder.
    return Scaffold(
      // ekranın iskeletini kurulur
      appBar: AppBar(title: const Text('Row ve Layout')), // uygulamaın en üstünde bulunan başlık ve aksiyonların bulunduğu kısımdır.
      body: Padding(
        //gövde kısmına içten boşluk bıraktırır
        padding: const EdgeInsets.all(
          16.0,
        ), //tüm kenarlardan boşluk bırakılması istenilmiştir
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // uygulamanın column ile beraber aşağıdan yukarı doğru akmasını sağlar ve uygulama başlangıcı soldan sağa doğru olur
          children: [
            //alt bileşen oluşturulmuştur
            const Text(
              //ekrana sabit bir yazı yazmak için oluşturulmuştur. yazı özelliklendirilmiştir.
              'Hatalı Yapı: A overflowed by *** pixels(sarı siyah şerit)',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 8), //elemanların yani widgetların arasına mesafe bırakılması için yapılmıştır.

            Container(
              // uygulama için çok amaçlı bir widgettır. tasarımda kullanılır.
              color: Colors.amber.shade100,
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red),
                  const SizedBox(width: 8),
                  const Text(
                    'Kısa Metin (Hata vermez ama uzarsa Render Patlar)',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Text(
              'Doğru Yapı: Expanded ve Flexible ile sınırlandırılmıştır.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            Container(
              padding: const EdgeInsets.all(12), // yukarıdaki aynı özellikte
              decoration: BoxDecoration(
                //containera benzer şekilde şekil ve düzenleme yapılan bir sınıftır.
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    //profil iconu oluşturur
                    backgroundColor: Colors.green,
                    child: Icon(Icons.check, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    // ekrandaki boş yerlerin kaplanmasını sağlayan widgettır
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Softito 4.Dönem Mobil Standartı',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        const Text(
                          'Bu metin ne kadar uzun olursa olsun telefonun ekranının genişl,iğinde alt satıra geçer ve asla sarı siyah taşma hatasıüretmez.',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
